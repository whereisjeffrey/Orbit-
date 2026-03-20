// analyze-audio-coach/index.ts
// TalkSwitch Coach — Edge Function
//
// Flow:
//   1. Enforce monthly soft cap (300 analyses)
//   2. Fetch user's active mistake inventory
//   3. Call GPT-4o with full prompt (6 detection layers + CEFR assessment)
//   4. Parse structured response
//   5. Upsert mistakes + update streaks
//   6. Log CEFR assessment (silent — for level computation)
//   7. Increment audio minutes (triggers 15-min unlock if threshold crossed)
//   8. Compute per-category scores
//   9. Return feedback payload to app

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

// ─── Constants ────────────────────────────────────────────────────────────────

const MONTHLY_CAP = 300;
const OPENAI_MODEL = "gpt-4o";
const MASTERY_STREAK_THRESHOLD = 3;

const CATEGORY_WEIGHTS: Record<string, number> = {
  pronunciation: 1.5,
  gender_articles: 1.3,
  verb_tenses: 1.3,
  prepositions: 1.0,
  tone_formality: 1.0,
  word_pairings: 0.8,
};

const SEVERITY_PENALTIES: Record<string, number> = {
  major: 10, // changes meaning or grammatically broken
  minor: 3,  // sounds unnatural but understandable
};

// CEFR levels in order — used for sublevel progression logic
const CEFR_LEVELS = ["A1", "A2", "B1", "B2", "C1", "C2"] as const;
type CEFRLevel = typeof CEFR_LEVELS[number];
type CEFRSublevel = "low" | "mid" | "high";

// ─── Types ────────────────────────────────────────────────────────────────────

interface CoachRequest {
  user_id: string;
  transcript: string;
  language_code: string;    // e.g. "pt", "es"
  language_name: string;    // e.g. "Portuguese", "Spanish"
  native_language: string;  // e.g. "English"
  audio_duration_seconds?: number; // populated when audio input is used
  low_confidence_words?: string[]; // from SFSpeechRecognizer segment data
}

interface DetectedError {
  error_category: string;   // pronunciation | gender_articles | verb_tenses | prepositions | tone_formality | word_pairings
  rule_key: string;         // normalized snake_case identifier
  rule_description: string; // human-readable rule
  surface_form: string;     // what the user said
  correct_form: string;     // what they should say
  severity: "major" | "minor";
  generalizes_to?: string;  // optional: other contexts this rule applies
}

// CEFR can-do criteria evaluation per session
interface CEFRCriterion {
  criterion_id: string;     // e.g. "B2_fluency_1"
  description: string;      // e.g. "Can interact with spontaneity"
  status: "met" | "partial" | "absent";
}

interface GPTCoachResponse {
  corrected_text: string | null;
  overall_quality_score: number;     // 0-100
  feedback_message: string;          // warm coaching note (2-4 sentences)
  errors_found: DetectedError[];
  correctly_used_rules: string[];    // rule_keys the user got RIGHT (for streak)
  is_perfect: boolean;
  // CEFR assessment (new)
  cefr_assessment: {
    assessed_level: CEFRLevel;
    assessed_sublevel: CEFRSublevel;
    confidence: "low" | "medium" | "high";
    error_rate: number;              // errors per 100 words
    vocabulary_richness: number;     // type-token ratio 0.0-1.0
    tense_diversity_score: number;   // count of distinct tense forms
    next_level_criteria: CEFRCriterion[]; // evaluated against next level up
  };
}

interface CategoryScore {
  category: string;
  score: number;                     // 0-100
  trend: "improving" | "steady" | "slipping";
  active_issue_count: number;
  label: string;
}

interface CoachResponsePayload {
  feedback_message: string;
  corrected_text: string | null;
  quality_score: number;
  is_perfect: boolean;
  had_mastery_moment: boolean;
  mastered_rules: string[];          // rule descriptions for celebration
  category_scores: CategoryScore[];
  analyses_this_month: number;
  cap_reached: boolean;
  cap_message?: string;
  // Level gate info (new)
  level_unlocked: boolean;
  level_unlocked_now: boolean;       // true only on the session that crosses the threshold
  cumulative_audio_minutes: number;
}

// ─── Main Handler ─────────────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, content-type",
      },
    });
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const openAIKey = Deno.env.get("OPENAI_API_KEY")!;
    const body: CoachRequest = await req.json();

    const {
      user_id,
      transcript,
      language_code,
      language_name,
      native_language,
      audio_duration_seconds,
      low_confidence_words = [],
    } = body;

    // ── 1. Enforce Monthly Cap ─────────────────────────────────────────────
    const monthKey = new Date().toISOString().slice(0, 7); // "2026-03"

    const { data: usageCount } = await supabase.rpc("increment_coaching_usage", {
      p_user_id: user_id,
      p_month_key: monthKey,
    });

    if (usageCount > MONTHLY_CAP) {
      // Still increment audio minutes even if cap is reached
      let minutesResult = { unlocked_now: false, cumulative_minutes: 0 };
      if (audio_duration_seconds && audio_duration_seconds > 0) {
        const { data } = await supabase.rpc("increment_audio_minutes", {
          p_user_id: user_id,
          p_language_code: language_code,
          p_duration_seconds: audio_duration_seconds,
        });
        if (data) minutesResult = data;
      }

      const { data: profile } = await supabase
        .from("coach_user_profile")
        .select("level_unlocked, cumulative_audio_minutes")
        .eq("user_id", user_id)
        .eq("language_code", language_code)
        .maybeSingle();

      const payload: CoachResponsePayload = {
        feedback_message:
          "You've been putting in serious work this month — Coach is recharging and will be back with you shortly. Your message looks great. 🔋",
        corrected_text: null,
        quality_score: -1,
        is_perfect: false,
        had_mastery_moment: false,
        mastered_rules: [],
        category_scores: [],
        analyses_this_month: usageCount,
        cap_reached: true,
        cap_message: "Monthly coaching limit reached. You've done incredible work this month.",
        level_unlocked: profile?.level_unlocked ?? false,
        level_unlocked_now: minutesResult.unlocked_now,
        cumulative_audio_minutes: profile?.cumulative_audio_minutes ?? minutesResult.cumulative_minutes,
      };
      return json(payload);
    }

    // ── 2. Fetch Active Mistake Inventory ──────────────────────────────────
    const { data: activeMistakes } = await supabase.rpc("get_active_mistakes", {
      p_user_id: user_id,
      p_language_code: language_code,
      p_limit: 15,
    });

    const inventoryBlock = buildInventoryBlock(activeMistakes ?? []);

    // Compute word count for CEFR context
    const wordCount = transcript.trim().split(/\s+/).filter(Boolean).length;

    // ── 3. Build & Send GPT-4o Prompt ─────────────────────────────────────
    const systemPrompt = buildSystemPrompt(
      language_name,
      native_language,
      inventoryBlock
    );

    const userMessage = buildUserMessage(
      transcript,
      language_name,
      wordCount,
      low_confidence_words
    );

    const gptResponse = await callGPT(openAIKey, systemPrompt, userMessage);

    // ── 4. Parse GPT Response ──────────────────────────────────────────────
    let parsed: GPTCoachResponse;
    try {
      const raw = gptResponse.choices[0].message.content;
      parsed = JSON.parse(raw);
    } catch {
      return json({
        feedback_message: "Great effort! Keep speaking — Coach is working on its analysis.",
        corrected_text: null,
        quality_score: 75,
        is_perfect: false,
        had_mastery_moment: false,
        mastered_rules: [],
        category_scores: [],
        analyses_this_month: usageCount,
        cap_reached: false,
        level_unlocked: false,
        level_unlocked_now: false,
        cumulative_audio_minutes: 0,
      } as CoachResponsePayload);
    }

    // ── 5. Upsert Mistakes + Streaks ───────────────────────────────────────
    const masteredRuleDescriptions: string[] = [];
    let hadMasteryMoment = false;

    // Process errors found this session
    for (const error of parsed.errors_found) {
      await supabase.rpc("upsert_coaching_mistake", {
        p_user_id: user_id,
        p_language_code: language_code,
        p_error_category: error.error_category,
        p_rule_key: error.rule_key,
        p_rule_description: error.rule_description,
        p_surface_form: error.surface_form,
        p_was_correct: false,
      });
    }

    // Process rules the user got RIGHT (streak building)
    for (const ruleKey of (parsed.correctly_used_rules ?? [])) {
      const { data: result } = await supabase.rpc("upsert_coaching_mistake", {
        p_user_id: user_id,
        p_language_code: language_code,
        p_error_category: "",
        p_rule_key: ruleKey,
        p_rule_description: "",
        p_surface_form: "",
        p_was_correct: true,
      });

      if (result?.mastery_moment) {
        hadMasteryMoment = true;
        const { data: rule } = await supabase
          .from("coaching_mistakes")
          .select("rule_description")
          .eq("user_id", user_id)
          .eq("language_code", language_code)
          .eq("rule_key", ruleKey)
          .single();

        if (rule?.rule_description) {
          masteredRuleDescriptions.push(rule.rule_description);
        }
      }
    }

    // Log the session
    const { data: sessionRow } = await supabase
      .from("coaching_sessions")
      .insert({
        user_id,
        language_code,
        transcript,
        corrected_text: parsed.corrected_text,
        feedback_message: parsed.feedback_message,
        errors_found: parsed.errors_found,
        correctly_used_rules: parsed.correctly_used_rules ?? [],
        quality_score: parsed.overall_quality_score,
        had_recurring_error: parsed.errors_found.some((e) =>
          (activeMistakes ?? []).some((m: any) => m.rule_key === e.rule_key)
        ),
        had_mastery_moment: hadMasteryMoment,
        audio_duration_seconds: audio_duration_seconds ?? null,
        word_count: wordCount,
        analyses_this_month: usageCount,
        included_in_level_calc: false, // will be flipped by increment_audio_minutes if threshold crossed
      })
      .select("id")
      .single();

    const sessionId = sessionRow?.id ?? null;

    // ── 6. Log CEFR Assessment (silent) ────────────────────────────────────
    // Only store if the assessment came back with data
    const cefr = parsed.cefr_assessment;
    if (cefr && cefr.assessed_level) {
      const criteriaDetail: Record<string, string> = {};
      let criteriaMetCount = 0;
      for (const c of (cefr.next_level_criteria ?? [])) {
        criteriaDetail[c.criterion_id] = c.status;
        if (c.status === "met") criteriaMetCount++;
      }

      await supabase.from("coach_cefr_assessments").insert({
        user_id,
        session_id: sessionId,
        language_code,
        assessed_level: cefr.assessed_level,
        assessed_sublevel: cefr.assessed_sublevel ?? "mid",
        criteria_evaluated: criteriaDetail,
        criteria_met_count: criteriaMetCount,
        criteria_total_count: cefr.next_level_criteria?.length ?? 0,
        model_confidence: cefr.confidence ?? "medium",
        error_rate: cefr.error_rate ?? null,
        vocabulary_richness: cefr.vocabulary_richness ?? null,
        tense_diversity_score: cefr.tense_diversity_score ?? null,
      });

      // Update the rolling level in coach_user_profile
      // We recompute from the last 10 assessments to smooth out outliers
      await updateRollingLevel(supabase, user_id, language_code, cefr, criteriaDetail, criteriaMetCount);
    }

    // ── 7. Increment Audio Minutes ─────────────────────────────────────────
    let minutesResult = { unlocked_now: false, cumulative_minutes: 0 };
    if (audio_duration_seconds && audio_duration_seconds > 0) {
      const { data } = await supabase.rpc("increment_audio_minutes", {
        p_user_id: user_id,
        p_language_code: language_code,
        p_duration_seconds: audio_duration_seconds,
      });
      if (data) minutesResult = data;
    }

    // Fetch current profile for level state
    const { data: profile } = await supabase
      .from("coach_user_profile")
      .select("level_unlocked, cumulative_audio_minutes, current_level, current_sublevel, next_level_criteria_met, next_level_criteria_total")
      .eq("user_id", user_id)
      .eq("language_code", language_code)
      .maybeSingle();

    // ── 8. Compute Category Scores ─────────────────────────────────────────
    const categoryScores = await computeCategoryScores(
      supabase,
      user_id,
      language_code
    );

    // ── 9. Build & Return Payload ──────────────────────────────────────────
    const payload: CoachResponsePayload = {
      feedback_message: parsed.feedback_message,
      corrected_text: parsed.corrected_text,
      quality_score: parsed.overall_quality_score,
      is_perfect: parsed.is_perfect,
      had_mastery_moment: hadMasteryMoment,
      mastered_rules: masteredRuleDescriptions,
      category_scores: categoryScores,
      analyses_this_month: usageCount,
      cap_reached: false,
      level_unlocked: profile?.level_unlocked ?? false,
      level_unlocked_now: minutesResult.unlocked_now,
      cumulative_audio_minutes: profile?.cumulative_audio_minutes ?? minutesResult.cumulative_minutes,
    };

    return json(payload);
  } catch (err) {
    console.error("[Coach] Fatal error:", err);
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});

// ─── CEFR Rolling Level Update ────────────────────────────────────────────────
// Recomputes the user's level from the last 10 CEFR assessments.
// Uses a simple majority vote on level + sublevel to smooth out outliers.
// Only updates if the user has crossed the 15-minute threshold.

async function updateRollingLevel(
  supabase: any,
  userId: string,
  languageCode: string,
  latestCefr: GPTCoachResponse["cefr_assessment"],
  criteriaDetail: Record<string, string>,
  criteriaMetCount: number
) {
  // Check threshold first
  const { data: profile } = await supabase
    .from("coach_user_profile")
    .select("level_unlocked, current_level, current_sublevel")
    .eq("user_id", userId)
    .eq("language_code", languageCode)
    .maybeSingle();

  if (!profile?.level_unlocked) {
    // Still below threshold — don't surface a level yet
    return;
  }

  // Get last 10 assessments
  const { data: recent } = await supabase
    .from("coach_cefr_assessments")
    .select("assessed_level, assessed_sublevel, model_confidence")
    .eq("user_id", userId)
    .eq("language_code", languageCode)
    .order("created_at", { ascending: false })
    .limit(10);

  if (!recent || recent.length < 3) {
    // Need at least 3 before we commit to a level — too early
    return;
  }

  // Weighted vote: high confidence = 3 votes, medium = 2, low = 1
  const confidenceWeight: Record<string, number> = { high: 3, medium: 2, low: 1 };
  const levelVotes: Record<string, number> = {};
  const sublevelVotes: Record<string, number> = {};
  let totalWeight = 0;

  for (const a of recent) {
    const w = confidenceWeight[a.model_confidence] ?? 1;
    levelVotes[a.assessed_level] = (levelVotes[a.assessed_level] ?? 0) + w;
    const key = `${a.assessed_level}_${a.assessed_sublevel}`;
    sublevelVotes[key] = (sublevelVotes[key] ?? 0) + w;
    totalWeight += w;
  }

  // Pick the winning level
  const computedLevel = Object.entries(levelVotes).sort((a, b) => b[1] - a[1])[0][0] as CEFRLevel;

  // Pick the winning sublevel within that level
  const sublevelEntries = Object.entries(sublevelVotes)
    .filter(([k]) => k.startsWith(computedLevel + "_"))
    .sort((a, b) => b[1] - a[1]);
  const computedSublevel = sublevelEntries.length > 0
    ? (sublevelEntries[0][0].split("_")[1] as CEFRSublevel)
    : "mid";

  // Only update if level changed (avoid thrashing)
  const levelChanged =
    computedLevel !== profile.current_level ||
    computedSublevel !== profile.current_sublevel;

  await supabase
    .from("coach_user_profile")
    .update({
      previous_level: levelChanged ? profile.current_level : undefined,
      previous_sublevel: levelChanged ? profile.current_sublevel : undefined,
      current_level: computedLevel,
      current_sublevel: computedSublevel,
      level_updated_at: levelChanged ? new Date().toISOString() : undefined,
      next_level_criteria_met: criteriaMetCount,
      next_level_criteria_total: latestCefr.next_level_criteria?.length ?? 8,
      criteria_detail: criteriaDetail,
      quality_score_30d: null, // will be recomputed by category score fn
      updated_at: new Date().toISOString(),
    })
    .eq("user_id", userId)
    .eq("language_code", languageCode);
}

// ─── GPT Prompt Builders ──────────────────────────────────────────────────────

function buildInventoryBlock(mistakes: any[]): string {
  if (!mistakes || mistakes.length === 0) {
    return "No known weak areas yet — this may be their first session.";
  }

  return mistakes
    .map((m) => {
      const examples = (m.surface_examples ?? []).slice(0, 3).join(", ");
      return `- [${m.rule_key}] ${m.rule_description}${examples ? ` — seen in: "${examples}"` : ""}`;
    })
    .join("\n");
}

function buildSystemPrompt(
  languageName: string,
  nativeLanguage: string,
  inventoryBlock: string
): string {
  return `You are a warm, encouraging language coach for a user learning ${languageName}. Their native language is ${nativeLanguage}.

YOUR CHARACTER:
- You are like a brilliant, patient friend who speaks this language fluently
- You genuinely want them to feel the language, not just survive it
- You celebrate progress and are honest about what needs work — but never discouraging
- You are never clinical, robotic, or patronizing

TONE RULES (follow precisely — these are not suggestions):
- NEVER say how many times they've made a mistake
- NEVER use the word "wrong" or "incorrect" — use "almost", "close", "just a small shift here"
- Frame recurring errors as "this one takes time" — normalize the challenge, don't pathologize failure
- When a mistake matches their known weak area: acknowledge it warmly as something they're "still building"
- When they CORRECTLY USE a previous weak area: celebrate it explicitly and specifically
- If everything is correct: celebrate genuinely — do not invent problems
- End every note with forward momentum ("you're building this", "it's getting there", "nearly automatic now")
- Keep the feedback_message to 2–4 sentences max. Warm, specific, human. Not a list.

THEIR KNOWN WORKING AREAS (cross-reference these against what they just said):
${inventoryBlock}

DETECTION TASK — analyze the transcript across ALL SIX dimensions simultaneously:

1. PRONUNCIATION — infer from transcription anomalies (words the recognizer may have heard differently than intended)
2. GENDER & ARTICLES — wrong gender on nouns, missing or incorrect articles, adjective agreement
3. VERB TENSES — wrong tense selection, incorrect conjugation, subjunctive errors, ser vs estar, être vs avoir
4. PREPOSITIONS — idiomatic preposition choices (at/on/in, por/para, à/en/dans, em/a/de)
5. TONE & FORMALITY — unnatural phrasing, register mismatch, overly literal translation, socially awkward choices
6. WORD PAIRINGS — collocations that are technically possible but unnatural to native speakers

GENERALIZATION RULE — CRITICAL:
When you identify a mistake, think about the UNDERLYING RULE being violated, not the specific phrase.
Assign a rule_key that generalizes across all surface forms of the same error.
Example: "on the beach" and "on the hospital" both map to rule_key: "preposition_location_at_vs_on"
The rule_description should explain the general principle, not just fix the specific phrase.

QUALITY SCORE (overall_quality_score, 0-100):
- 90-100: Near-perfect or perfect. Fluent, natural, correct.
- 75-89: Strong with minor issues. Clearly communicating well.
- 55-74: Getting there. Some recurring patterns to address.
- 40-54: Several areas active. Understandable but noticeably non-native.
- 0-39: Significant patterns. Needs consistent attention.

SEVERITY:
- "major": Error that changes the meaning or makes it grammatically broken
- "minor": Error that sounds unnatural but is understandable

CORRECTLY USED RULES:
Look at the user's known weak areas (listed above). If they correctly handled any of those specific rules in this message, list those rule_keys in correctly_used_rules. This is how streaks are built toward mastery.

CEFR ASSESSMENT:
Evaluate the transcript against the CEFR framework. Identify the level that best describes the user's demonstrated proficiency in this message. Be conservative — don't round up.

For next_level_criteria, evaluate the user against the criteria of the level ABOVE your assessed_level.
Use exactly these criterion_ids for each level:

If assessed_level is A1, evaluate against A2 criteria:
  A2_vocabulary_range, A2_grammatical_accuracy, A2_interaction, A2_coherence, A2_everyday_topics

If assessed_level is A2, evaluate against B1 criteria:
  B1_maintaining_interaction, B1_range_topics, B1_flexibility, B1_fluency, B1_circumlocution

If assessed_level is B1, evaluate against B2 criteria:
  B2_fluency_1, B2_argumentation, B2_vocabulary_breadth, B2_grammatical_control, B2_register_awareness, B2_clarity, B2_interacting_native, B2_coherence

If assessed_level is B2, evaluate against C1 criteria:
  C1_spontaneity, C1_precise_vocabulary, C1_complex_structures, C1_implicit_meaning, C1_discourse_markers, C1_nuance, C1_flexibility, C1_academic_register

If assessed_level is C1 or C2, evaluate against C2 criteria:
  C2_precision, C2_idiomatic, C2_ambiguity, C2_register_mastery, C2_native_like

error_rate: calculate as (number of errors found / word count provided) * 100
vocabulary_richness: estimate the type-token ratio (unique words / total words), 0.0–1.0
tense_diversity_score: count how many distinct verb tenses/moods appear in the transcript

RESPOND WITH ONLY VALID JSON in this exact structure:
{
  "corrected_text": "string or null if no corrections needed",
  "overall_quality_score": 0-100,
  "feedback_message": "warm 2-4 sentence coaching note",
  "is_perfect": true/false,
  "errors_found": [
    {
      "error_category": "pronunciation|gender_articles|verb_tenses|prepositions|tone_formality|word_pairings",
      "rule_key": "snake_case_generalized_rule_identifier",
      "rule_description": "The general underlying rule being violated",
      "surface_form": "what they said",
      "correct_form": "what they should say",
      "severity": "major|minor",
      "generalizes_to": "optional: other contexts this rule applies in"
    }
  ],
  "correctly_used_rules": ["rule_key_1", "rule_key_2"],
  "cefr_assessment": {
    "assessed_level": "A1|A2|B1|B2|C1|C2",
    "assessed_sublevel": "low|mid|high",
    "confidence": "low|medium|high",
    "error_rate": 0.0,
    "vocabulary_richness": 0.0,
    "tense_diversity_score": 0,
    "next_level_criteria": [
      {
        "criterion_id": "B2_fluency_1",
        "description": "Can interact with a degree of fluency and spontaneity",
        "status": "met|partial|absent"
      }
    ]
  }
}`;
}

function buildUserMessage(
  transcript: string,
  languageName: string,
  wordCount: number,
  lowConfidenceWords: string[]
): string {
  let msg = `Transcript (${languageName}): "${transcript}"\nWord count: ${wordCount}`;

  if (lowConfidenceWords.length > 0) {
    msg += `\n\nWords the speech recognizer flagged as low-confidence (possible pronunciation issues): ${lowConfidenceWords.join(", ")}`;
  }

  return msg;
}

// ─── GPT Call ─────────────────────────────────────────────────────────────────

async function callGPT(apiKey: string, systemPrompt: string, userMessage: string) {
  const res = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: OPENAI_MODEL,
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userMessage },
      ],
      temperature: 0.4,
      max_tokens: 1800,
      response_format: { type: "json_object" },
    }),
  });

  if (!res.ok) {
    throw new Error(`OpenAI error: ${res.status} ${await res.text()}`);
  }

  return res.json();
}

// ─── Category Score Computation ───────────────────────────────────────────────

async function computeCategoryScores(
  supabase: any,
  userId: string,
  languageCode: string
): Promise<CategoryScore[]> {
  const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();

  const { data: sessions } = await supabase
    .from("coaching_sessions")
    .select("errors_found, quality_score, created_at")
    .eq("user_id", userId)
    .eq("language_code", languageCode)
    .gte("created_at", thirtyDaysAgo)
    .order("created_at", { ascending: false });

  if (!sessions || sessions.length === 0) {
    return defaultCategoryScores();
  }

  const now = Date.now();
  const sevenDaysAgo = now - 7 * 24 * 60 * 60 * 1000;
  const fourteenDaysAgo = now - 14 * 24 * 60 * 60 * 1000;

  const categories = Object.keys(CATEGORY_WEIGHTS);
  const scores: CategoryScore[] = [];

  for (const category of categories) {
    const recentSessions = sessions.filter(
      (s: any) => new Date(s.created_at).getTime() > sevenDaysAgo
    );
    const olderSessions = sessions.filter((s: any) => {
      const t = new Date(s.created_at).getTime();
      return t > fourteenDaysAgo && t <= sevenDaysAgo;
    });

    const recentScore = scoreForCategory(category, recentSessions, 2.0);
    const olderScore = scoreForCategory(category, olderSessions, 0.75);

    const blended =
      recentSessions.length > 0
        ? recentScore * 0.7 + (olderSessions.length > 0 ? olderScore * 0.3 : recentScore * 0.3)
        : olderScore;

    const finalScore = Math.round(Math.max(0, Math.min(100, blended)));

    let trend: "improving" | "steady" | "slipping" = "steady";
    if (recentSessions.length > 0 && olderSessions.length > 0) {
      const diff = recentScore - olderScore;
      if (diff >= 5) trend = "improving";
      else if (diff <= -5) trend = "slipping";
    }

    const { count: activeCount } = await supabase
      .from("coaching_mistakes")
      .select("id", { count: "exact" })
      .eq("user_id", userId)
      .eq("language_code", languageCode)
      .eq("error_category", category)
      .eq("resolved", false);

    scores.push({
      category,
      score: finalScore,
      trend,
      active_issue_count: activeCount ?? 0,
      label: categoryLabel(category),
    });
  }

  return scores;
}

function scoreForCategory(
  category: string,
  sessions: any[],
  recencyMultiplier: number
): number {
  if (sessions.length === 0) return 75;

  let totalWeight = 0;
  let weightedScore = 0;

  for (const session of sessions) {
    const errors: DetectedError[] = session.errors_found ?? [];
    const categoryErrors = errors.filter((e) => e.error_category === category);

    let sessionScore = 100;
    for (const error of categoryErrors) {
      sessionScore -= SEVERITY_PENALTIES[error.severity] ?? 3;
    }
    sessionScore = Math.max(0, sessionScore);

    const weight = recencyMultiplier;
    weightedScore += sessionScore * weight;
    totalWeight += weight;
  }

  return totalWeight > 0 ? weightedScore / totalWeight : 75;
}

function defaultCategoryScores(): CategoryScore[] {
  return Object.keys(CATEGORY_WEIGHTS).map((cat) => ({
    category: cat,
    score: 0,
    trend: "steady" as const,
    active_issue_count: 0,
    label: categoryLabel(cat),
  }));
}

function categoryLabel(category: string): string {
  const labels: Record<string, string> = {
    pronunciation: "Pronunciation",
    gender_articles: "Gender & Articles",
    verb_tenses: "Verb Tenses",
    prepositions: "Prepositions",
    tone_formality: "Tone & Formality",
    word_pairings: "Word Pairings",
  };
  return labels[category] ?? category;
}

// ─── Utilities ────────────────────────────────────────────────────────────────

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
}
