-- ============================================================
-- TalkSwitch Coach — Full Schema Migration
-- 2026-03-18
--
-- Tables:
--   1. coaching_usage          — monthly soft cap tracking
--   2. coaching_sessions       — one row per audio message analyzed
--   3. coaching_mistakes       — per-rule error inventory + streaks
--   4. coach_cefr_assessments  — per-session CEFR eval (silent, for leveling)
--   5. coach_user_profile      — aggregate level + audio minutes per user
--   6. coach_weekly_reports    — generated weekly reports
--
-- RPC Functions:
--   increment_coaching_usage   — atomic monthly cap counter
--   get_active_mistakes        — fetch user's current error inventory
--   upsert_coaching_mistake    — insert or update a mistake + streak logic
-- ============================================================


-- ─── Extensions ──────────────────────────────────────────────────────────────

create extension if not exists "uuid-ossp";


-- ─── 1. coaching_usage ───────────────────────────────────────────────────────
-- Tracks how many coaching analyses a user has done this calendar month.
-- One row per (user_id, month_key). Used to enforce the 300/month soft cap.

create table if not exists coaching_usage (
  id            uuid primary key default uuid_generate_v4(),
  user_id       uuid not null references auth.users(id) on delete cascade,
  month_key     text not null,          -- format: "2026-03"
  count         int  not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),

  unique (user_id, month_key)
);

create index if not exists idx_coaching_usage_user_month
  on coaching_usage (user_id, month_key);


-- ─── 2. coaching_sessions ────────────────────────────────────────────────────
-- One row per voice message analyzed by Coach.
-- Stores the full transcript, LLM output, errors found, and quality score.
-- audio_duration_seconds feeds into cumulative minutes tracking.

create table if not exists coaching_sessions (
  id                    uuid primary key default uuid_generate_v4(),
  user_id               uuid not null references auth.users(id) on delete cascade,
  language_code         text not null,          -- e.g. "es", "pt", "fr"
  transcript            text not null,
  corrected_text        text,                   -- null if no corrections needed
  feedback_message      text not null,          -- the warm coaching note shown to user
  errors_found          jsonb not null default '[]',  -- array of DetectedError
  correctly_used_rules  jsonb not null default '[]',  -- rule_keys user got right
  quality_score         int,                    -- 0–100, null if cap reached
  had_recurring_error   boolean not null default false,
  had_mastery_moment    boolean not null default false,
  audio_duration_seconds int,                   -- populated when audio input is used
  word_count            int,                    -- derived from transcript length
  analyses_this_month   int,                    -- snapshot of usage count at time of session
  included_in_level_calc boolean not null default false, -- true after 15-min threshold
  created_at            timestamptz not null default now()
);

create index if not exists idx_coaching_sessions_user_lang
  on coaching_sessions (user_id, language_code, created_at desc);

create index if not exists idx_coaching_sessions_created
  on coaching_sessions (user_id, created_at desc);


-- ─── 3. coaching_mistakes ────────────────────────────────────────────────────
-- Per-rule error inventory. One row per (user, language, rule_key).
-- Tracks how often a rule is violated, streak of correct usages, and mastery.
-- This is what "Still Working On This" and "You Fixed This" pull from.

create table if not exists coaching_mistakes (
  id                    uuid primary key default uuid_generate_v4(),
  user_id               uuid not null references auth.users(id) on delete cascade,
  language_code         text not null,
  error_category        text not null,   -- pronunciation | gender_articles | verb_tenses | prepositions | tone_formality | word_pairings
  rule_key              text not null,   -- normalized snake_case, e.g. "ser_vs_estar"
  rule_description      text not null,   -- human-readable explanation of the rule
  surface_examples      jsonb not null default '[]',  -- up to 5 recent surface_forms seen
  occurrence_count      int  not null default 1,      -- total times this error appeared
  correct_streak        int  not null default 0,      -- consecutive correct usages
  resolved              boolean not null default false,
  resolved_at           timestamptz,                  -- when streak hit mastery threshold
  times_surfaced_in_report int not null default 0,    -- how many weekly reports included this
  first_seen_at         timestamptz not null default now(),
  last_seen_at          timestamptz not null default now(),
  updated_at            timestamptz not null default now(),

  unique (user_id, language_code, rule_key)
);

create index if not exists idx_coaching_mistakes_user_lang
  on coaching_mistakes (user_id, language_code, resolved, last_seen_at desc);

create index if not exists idx_coaching_mistakes_unresolved
  on coaching_mistakes (user_id, language_code, resolved)
  where resolved = false;


-- ─── 4. coach_cefr_assessments ───────────────────────────────────────────────
-- Silent per-session CEFR evaluation. Never shown to user directly.
-- Accumulates across sessions to compute the rolling level in coach_user_profile.
-- Only populated after the user crosses the 15-minute audio threshold.

create table if not exists coach_cefr_assessments (
  id                        uuid primary key default uuid_generate_v4(),
  user_id                   uuid not null references auth.users(id) on delete cascade,
  session_id                uuid references coaching_sessions(id) on delete set null,
  language_code             text not null,
  assessed_level            text not null,   -- A1 | A2 | B1 | B2 | C1 | C2
  assessed_sublevel         text not null default 'mid',  -- low | mid | high
  criteria_evaluated        jsonb not null default '{}',  -- { "can_do_B2_1": "met" | "partial" | "absent", ... }
  criteria_met_count        int  not null default 0,      -- how many next-level criteria met
  criteria_total_count      int  not null default 0,      -- total criteria evaluated for next level
  model_confidence          text not null default 'medium',  -- low | medium | high
  error_rate                numeric(5,2),   -- errors per 100 words this session
  vocabulary_richness       numeric(5,4),   -- type-token ratio (0.0–1.0)
  tense_diversity_score     int,            -- count of distinct tense forms used
  cumulative_minutes_at_time numeric(6,2),  -- total audio minutes at time of this assessment
  created_at                timestamptz not null default now()
);

create index if not exists idx_cefr_assessments_user_lang
  on coach_cefr_assessments (user_id, language_code, created_at desc);


-- ─── 5. coach_user_profile ───────────────────────────────────────────────────
-- One row per (user, language). The single source of truth for:
--   - cumulative audio minutes (the 15-minute gate)
--   - current CEFR level and sublevel
--   - which next-level criteria are met (drives the half-circle UI)
--   - 30-day rolling metrics
-- Updated after each coaching session by the edge function.

create table if not exists coach_user_profile (
  id                        uuid primary key default uuid_generate_v4(),
  user_id                   uuid not null references auth.users(id) on delete cascade,
  language_code             text not null,

  -- Audio threshold gate
  cumulative_audio_minutes  numeric(8,2) not null default 0,
  level_unlocked            boolean not null default false,
  level_unlocked_at         timestamptz,

  -- Current level (null until unlocked)
  current_level             text,          -- A1 | A2 | B1 | B2 | C1 | C2
  current_sublevel          text,          -- low | mid | high
  level_updated_at          timestamptz,
  previous_level            text,          -- for detecting level-up moments
  previous_sublevel         text,

  -- Next-level criteria progress (drives half-circle UI)
  next_level_criteria_met   int  not null default 0,
  next_level_criteria_total int  not null default 8,   -- standard CEFR set
  criteria_detail           jsonb not null default '{}', -- which specific criteria are met

  -- 30-day rolling metrics (recomputed per session)
  error_rate_30d            numeric(5,2),  -- avg errors per 100 words, last 30 days
  vocabulary_richness_30d   numeric(5,4),  -- avg TTR, last 30 days
  tense_diversity_30d       numeric(5,2),  -- avg distinct tense forms, last 30 days
  quality_score_30d         numeric(5,2),  -- avg quality score, last 30 days

  -- Session counts
  total_sessions            int not null default 0,
  total_words_analyzed      int not null default 0,

  created_at                timestamptz not null default now(),
  updated_at                timestamptz not null default now(),

  unique (user_id, language_code)
);

create index if not exists idx_coach_user_profile_user
  on coach_user_profile (user_id);


-- ─── 6. coach_weekly_reports ─────────────────────────────────────────────────
-- Generated every Tuesday. Stores both the collapsed push preview
-- and the full structured report body. Users can scroll back through
-- past reports in CoachView.

create table if not exists coach_weekly_reports (
  id                    uuid primary key default uuid_generate_v4(),
  user_id               uuid not null references auth.users(id) on delete cascade,
  language_code         text not null,
  week_start            date not null,   -- Monday of the report week
  week_end              date not null,   -- Sunday of the report week

  -- Delivery
  generated_at          timestamptz not null default now(),
  sent_at               timestamptz,     -- when push notification fired
  opened_at             timestamptz,     -- when user tapped to expand

  -- Content
  notification_preview  text not null,   -- 2-line push notification text
  report_body           jsonb not null,  -- structured: { still_working_on, fixed_this, one_thing, level_summary }

  -- Snapshot of state at report time
  level_at_generation   text,            -- e.g. "B1"
  sublevel_at_generation text,           -- e.g. "mid"
  sessions_included     jsonb not null default '[]',  -- array of session IDs

  -- Stats for the week (secondary, shown small)
  session_count_this_week int not null default 0,
  words_analyzed_this_week int not null default 0,

  created_at            timestamptz not null default now(),

  unique (user_id, language_code, week_start)
);

create index if not exists idx_coach_weekly_reports_user
  on coach_weekly_reports (user_id, language_code, week_start desc);


-- ═══════════════════════════════════════════════════════════════
-- RPC FUNCTIONS
-- ═══════════════════════════════════════════════════════════════


-- ─── increment_coaching_usage ────────────────────────────────────────────────
-- Atomically increments the monthly usage counter and returns the new count.
-- Called at the top of every analyze-audio-coach invocation.

create or replace function increment_coaching_usage(
  p_user_id   uuid,
  p_month_key text
)
returns int
language plpgsql
security definer
as $$
declare
  new_count int;
begin
  insert into coaching_usage (user_id, month_key, count, updated_at)
  values (p_user_id, p_month_key, 1, now())
  on conflict (user_id, month_key)
  do update set
    count      = coaching_usage.count + 1,
    updated_at = now()
  returning count into new_count;

  return new_count;
end;
$$;


-- ─── get_active_mistakes ─────────────────────────────────────────────────────
-- Returns the user's unresolved mistakes ordered by recency + frequency.
-- The edge function uses this to build the "known weak areas" block
-- that is injected into the GPT system prompt.

create or replace function get_active_mistakes(
  p_user_id       uuid,
  p_language_code text,
  p_limit         int default 15
)
returns table (
  rule_key          text,
  rule_description  text,
  error_category    text,
  occurrence_count  int,
  correct_streak    int,
  surface_examples  jsonb,
  last_seen_at      timestamptz
)
language sql
security definer
as $$
  select
    rule_key,
    rule_description,
    error_category,
    occurrence_count,
    correct_streak,
    surface_examples,
    last_seen_at
  from coaching_mistakes
  where user_id       = p_user_id
    and language_code = p_language_code
    and resolved      = false
  order by
    last_seen_at    desc,
    occurrence_count desc
  limit p_limit;
$$;


-- ─── upsert_coaching_mistake ─────────────────────────────────────────────────
-- Insert or update a mistake record.
-- When was_correct = true: increments the correct_streak.
--   If streak reaches 3: marks the rule as resolved (mastery moment).
-- When was_correct = false: resets streak, increments occurrence_count,
--   appends to surface_examples (capped at 5).
-- Returns a JSON object with { mastery_moment: bool }.

create or replace function upsert_coaching_mistake(
  p_user_id          uuid,
  p_language_code    text,
  p_error_category   text,
  p_rule_key         text,
  p_rule_description text,
  p_surface_form     text,
  p_was_correct      boolean
)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_new_streak       int;
  v_mastery_moment   boolean := false;
  v_mastery_threshold int := 3;
begin
  if p_was_correct then
    -- ── Correct usage: increment streak ──────────────────────────────────
    insert into coaching_mistakes (
      user_id, language_code, error_category,
      rule_key, rule_description, correct_streak,
      occurrence_count, resolved, last_seen_at, updated_at
    )
    values (
      p_user_id, p_language_code, p_error_category,
      p_rule_key, p_rule_description, 1,
      0, false, now(), now()
    )
    on conflict (user_id, language_code, rule_key)
    do update set
      correct_streak = coaching_mistakes.correct_streak + 1,
      last_seen_at   = now(),
      updated_at     = now()
    returning correct_streak into v_new_streak;

    -- Check for mastery
    if v_new_streak >= v_mastery_threshold then
      update coaching_mistakes
      set
        resolved    = true,
        resolved_at = now(),
        updated_at  = now()
      where user_id       = p_user_id
        and language_code = p_language_code
        and rule_key      = p_rule_key
        and resolved      = false;

      if found then
        v_mastery_moment := true;
      end if;
    end if;

  else
    -- ── Incorrect usage: log the error ───────────────────────────────────
    insert into coaching_mistakes (
      user_id, language_code, error_category,
      rule_key, rule_description,
      surface_examples, occurrence_count,
      correct_streak, resolved, last_seen_at, updated_at
    )
    values (
      p_user_id, p_language_code, p_error_category,
      p_rule_key, p_rule_description,
      case when p_surface_form = '' then '[]'::jsonb
           else jsonb_build_array(p_surface_form) end,
      1, 0, false, now(), now()
    )
    on conflict (user_id, language_code, rule_key)
    do update set
      occurrence_count = coaching_mistakes.occurrence_count + 1,
      correct_streak   = 0,   -- reset streak on error
      surface_examples = (
        -- Keep last 5 surface examples only
        select jsonb_agg(ex)
        from (
          select ex
          from jsonb_array_elements_text(
            coaching_mistakes.surface_examples || jsonb_build_array(p_surface_form)
          ) as ex
          limit 5
        ) sub
      ),
      last_seen_at     = now(),
      updated_at       = now(),
      -- If they had previously resolved this rule, re-open it
      resolved         = false,
      resolved_at      = case when coaching_mistakes.resolved then null else coaching_mistakes.resolved_at end;
  end if;

  return jsonb_build_object('mastery_moment', v_mastery_moment);
end;
$$;


-- ─── increment_audio_minutes ─────────────────────────────────────────────────
-- Called by the edge function after each audio session.
-- Adds seconds to cumulative_audio_minutes and flips level_unlocked
-- when the user crosses the 15-minute (900 second) threshold.
-- Returns { unlocked_now: bool, cumulative_minutes: numeric }

create or replace function increment_audio_minutes(
  p_user_id            uuid,
  p_language_code      text,
  p_duration_seconds   int
)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_minutes_added      numeric := p_duration_seconds::numeric / 60.0;
  v_new_total          numeric;
  v_was_unlocked       boolean;
  v_unlocked_now       boolean := false;
  v_threshold_minutes  numeric := 15.0;
begin
  -- Upsert the profile row
  insert into coach_user_profile (user_id, language_code, cumulative_audio_minutes, updated_at)
  values (p_user_id, p_language_code, v_minutes_added, now())
  on conflict (user_id, language_code)
  do update set
    cumulative_audio_minutes = coach_user_profile.cumulative_audio_minutes + v_minutes_added,
    total_sessions           = coach_user_profile.total_sessions + 1,
    updated_at               = now()
  returning cumulative_audio_minutes, level_unlocked
    into v_new_total, v_was_unlocked;

  -- Check if this push crosses the threshold
  if not v_was_unlocked and v_new_total >= v_threshold_minutes then
    update coach_user_profile
    set
      level_unlocked    = true,
      level_unlocked_at = now(),
      updated_at        = now()
    where user_id       = p_user_id
      and language_code = p_language_code;

    -- Also mark all existing sessions as included in level calc
    update coaching_sessions
    set included_in_level_calc = true
    where user_id       = p_user_id
      and language_code = p_language_code;

    v_unlocked_now := true;
  end if;

  return jsonb_build_object(
    'unlocked_now',       v_unlocked_now,
    'cumulative_minutes', v_new_total
  );
end;
$$;


-- ─── get_weekly_report_data ───────────────────────────────────────────────────
-- Pulls everything needed to generate a weekly report for a user.
-- Returns: recurring mistakes, newly resolved mistakes, one focus suggestion,
-- and current level state. Called by the report generation job.

create or replace function get_weekly_report_data(
  p_user_id       uuid,
  p_language_code text,
  p_week_start    date,
  p_week_end      date
)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_recurring      jsonb;
  v_fixed          jsonb;
  v_level          jsonb;
  v_session_count  int;
  v_word_count     int;
begin
  -- ── Recurring mistakes: appeared in 2+ sessions this week ────────────────
  select jsonb_agg(row_to_json(r))
  into v_recurring
  from (
    select
      m.rule_key,
      m.rule_description,
      m.error_category,
      m.occurrence_count,
      m.surface_examples
    from coaching_mistakes m
    where m.user_id        = p_user_id
      and m.language_code  = p_language_code
      and m.resolved       = false
      -- appeared in at least 2 sessions in this week window
      and (
        select count(distinct cs.id)
        from coaching_sessions cs,
             jsonb_array_elements(cs.errors_found) as err
        where cs.user_id        = p_user_id
          and cs.language_code  = p_language_code
          and cs.created_at     between p_week_start::timestamptz
                                    and (p_week_end::timestamptz + interval '1 day')
          and err->>'rule_key'  = m.rule_key
      ) >= 2
    order by m.last_seen_at desc
    limit 3
  ) r;

  -- ── Fixed this week: rules that resolved in the last 30 days ─────────────
  select jsonb_agg(row_to_json(f))
  into v_fixed
  from (
    select
      rule_key,
      rule_description,
      error_category,
      resolved_at,
      occurrence_count
    from coaching_mistakes
    where user_id        = p_user_id
      and language_code  = p_language_code
      and resolved       = true
      and resolved_at    >= now() - interval '30 days'
    order by resolved_at desc
    limit 2
  ) f;

  -- ── Session stats for the week ────────────────────────────────────────────
  select
    count(*),
    coalesce(sum(word_count), 0)
  into v_session_count, v_word_count
  from coaching_sessions
  where user_id       = p_user_id
    and language_code = p_language_code
    and created_at    between p_week_start::timestamptz
                          and (p_week_end::timestamptz + interval '1 day');

  -- ── Current level snapshot ────────────────────────────────────────────────
  select jsonb_build_object(
    'level',              current_level,
    'sublevel',           current_sublevel,
    'criteria_met',       next_level_criteria_met,
    'criteria_total',     next_level_criteria_total,
    'level_unlocked',     level_unlocked,
    'cumulative_minutes', cumulative_audio_minutes
  )
  into v_level
  from coach_user_profile
  where user_id       = p_user_id
    and language_code = p_language_code;

  return jsonb_build_object(
    'recurring_mistakes', coalesce(v_recurring, '[]'::jsonb),
    'fixed_mistakes',     coalesce(v_fixed,     '[]'::jsonb),
    'level',              coalesce(v_level,      '{}'::jsonb),
    'session_count',      v_session_count,
    'word_count',         v_word_count
  );
end;
$$;


-- ─── Row Level Security ───────────────────────────────────────────────────────
-- Users can only read their own data. All writes go through
-- security-definer RPC functions above (no direct client writes needed).

alter table coaching_usage          enable row level security;
alter table coaching_sessions       enable row level security;
alter table coaching_mistakes       enable row level security;
alter table coach_cefr_assessments  enable row level security;
alter table coach_user_profile      enable row level security;
alter table coach_weekly_reports    enable row level security;

-- Read policies (users see only their own rows)
create policy "users read own coaching_usage"
  on coaching_usage for select
  using (auth.uid() = user_id);

create policy "users read own coaching_sessions"
  on coaching_sessions for select
  using (auth.uid() = user_id);

create policy "users read own coaching_mistakes"
  on coaching_mistakes for select
  using (auth.uid() = user_id);

create policy "users read own cefr_assessments"
  on coach_cefr_assessments for select
  using (auth.uid() = user_id);

create policy "users read own coach_profile"
  on coach_user_profile for select
  using (auth.uid() = user_id);

create policy "users read own weekly_reports"
  on coach_weekly_reports for select
  using (auth.uid() = user_id);
