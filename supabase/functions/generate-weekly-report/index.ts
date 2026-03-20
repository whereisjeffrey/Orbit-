// generate-weekly-report/index.ts
// TalkSwitch Coach — Weekly Report Generator
//
// Called by a scheduled cron job every Tuesday at 19:00 local time per user.
// Can also be called manually for a specific user (for testing / backfill).
//
// Flow:
//   1. Determine which users need a report this week
//   2. Pull their weekly data via get_weekly_report_data RPC
//   3. Call GPT-4o to author the report in natural language
//   4. Store the report in coach_weekly_reports
//   5. Send push notification via Expo Push API
//
// Request body (optional — if omitted, processes all eligible users):
//   { user_id?: string, language_code?: string, week_start?: string }

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

// ─── Constants ────────────────────────────────────────────────────────────────

const OPENAI_MODEL = "gpt-4o";

// CEFR level descriptions shown in the report footer
const CEFR_DESCRIPTIONS: Record<string, { label: string; summary: string }> = {
  A1: {
    label: "Beginner",
    summary: "Can use familiar everyday expressions and very basic phrases.",
  },
  A2: {
    label: "Elementary",
    summary: "Can communicate in simple, routine tasks on familiar topics.",
  },
  B1: {
    label: "Intermediate",
    summary: "Can deal with most situations likely to arise while travelling. Can describe experiences and briefly explain opinions.",
  },
  B2: {
    label: "Upper Intermediate",
    summary: "Can interact with a degree of fluency and spontaneity that makes regular interaction with native speakers quite possible.",
  },
  C1: {
    label: "Advanced",
    summary: "Can express ideas fluently and spontaneously. Can use language flexibly and effectively for social, academic, and professional purposes.",
  },
  C2: {
    label: "Mastery",
    summary: "Can understand virtually everything heard or read. Can express spontaneously, very fluently and precisely.",
  },
};

// ─── Types ────────────────────────────────────────────────────────────────────

interface RecurringMistake {
  rule_key: string;
  rule_description: string;
  error_category: string;
  occurrence_count: number;
  surface_examples: string[];
}

interface FixedMistake {
  rule_key: string;
  rule_description: string;
  error_category: string;
  resolved_at: string;
  occurrence_count: number;
}

interface LevelSnapshot {
  level: string | null;
  sublevel: string | null;
  criteria_met: number;
  criteria_total: number;
  level_unlocked: boolean;
  cumulative_minutes: number;
}

interface WeeklyReportData {
  recurring_mistakes: RecurringMistake[];
  fixed_mistakes: FixedMistake[];
  level: LevelSnapshot;
  session_count: number;
  word_count: number;
}

interface GeneratedReport {
  notification_preview: string;       // 2-line push notification
  still_working_on: ReportSection[];  // up to 3 recurring issues
  fixed_this: ReportSection[];        // up to 2 resolved issues
  one_thing: string;                  // single forward-looking focus
  level_summary: string;              // 1-2 sentences on level state
}

interface ReportSection {
  rule_key: string;
  category: string;
  headline: string;   // e.g. "Ser vs. Estar"
  body: string;       // 2-3 sentence explanation
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

    const body = req.method === "POST" ? await req.json().catch(() => ({})) : {};
    const { user_id: specificUserId, language_code: specificLang } = body;

    // Compute week window (Mon–Sun of the most recently completed week)
    const now = new Date();
    const weekStart = getMostRecentMonday(now);
    const weekEnd = new Date(weekStart);
    weekEnd.setDate(weekEnd.getDate() + 6);

    const weekStartStr = weekStart.toISOString().slice(0, 10);
    const weekEndStr = weekEnd.toISOString().slice(0, 10);

    // ── Determine which users to process ──────────────────────────────────
    let usersToProcess: { user_id: string; language_code: string; expo_push_token?: string }[] = [];

    if (specificUserId && specificLang) {
      // Manual invocation for a specific user
      usersToProcess = [{ user_id: specificUserId, language_code: specificLang }];
    } else {
      // Find all Coach users who:
      //  - have crossed the 15-minute threshold
      //  - had at least 1 session this week
      //  - haven't already received a report for this week_start
      const { data: eligibleUsers } = await supabase
        .from("coach_user_profile")
        .select("user_id, language_code")
        .eq("level_unlocked", true);

      for (const u of (eligibleUsers ?? [])) {
        // Check they had sessions this week
        const { count: sessionCount } = await supabase
          .from("coaching_sessions")
          .select("id", { count: "exact" })
          .eq("user_id", u.user_id)
          .eq("language_code", u.language_code)
          .gte("created_at", weekStartStr)
          .lte("created_at", weekEndStr + "T23:59:59Z");

        if ((sessionCount ?? 0) === 0) continue;

        // Check report not already generated this week
        const { data: existingReport } = await supabase
          .from("coach_weekly_reports")
          .select("id")
          .eq("user_id", u.user_id)
          .eq("language_code", u.language_code)
          .eq("week_start", weekStartStr)
          .maybeSingle();

        if (existingReport) continue;

        usersToProcess.push(u);
      }
    }

    const results: { user_id: string; status: string; error?: string }[] = [];

    // ── Process each user ─────────────────────────────────────────────────
    for (const user of usersToProcess) {
      try {
        // Pull report data
        const { data: reportData } = await supabase.rpc("get_weekly_report_data", {
          p_user_id: user.user_id,
          p_language_code: user.language_code,
          p_week_start: weekStartStr,
          p_week_end: weekEndStr,
        }) as { data: WeeklyReportData };

        if (!reportData) {
          results.push({ user_id: user.user_id, status: "skipped_no_data" });
          continue;
        }

        // Get user's language name for the prompt
        const { data: profileRow } = await supabase
          .from("coach_user_profile")
          .select("current_level, current_sublevel")
          .eq("user_id", user.user_id)
          .eq("language_code", user.language_code)
          .maybeSingle();

        const languageName = languageCodeToName(user.language_code);

        // Generate report with GPT
        const generated = await generateReport(
          openAIKey,
          languageName,
          reportData,
          weekStartStr,
          weekEndStr
        );

        // Build the full report body JSON
        const reportBody = {
          still_working_on: generated.still_working_on,
          fixed_this: generated.fixed_this,
          one_thing: generated.one_thing,
          level_summary: generated.level_summary,
          level: reportData.level,
          cefr_description: reportData.level.level
            ? CEFR_DESCRIPTIONS[reportData.level.level]
            : null,
        };

        // Store the report
        await supabase.from("coach_weekly_reports").insert({
          user_id: user.user_id,
          language_code: user.language_code,
          week_start: weekStartStr,
          week_end: weekEndStr,
          notification_preview: generated.notification_preview,
          report_body: reportBody,
          level_at_generation: reportData.level.level,
          sublevel_at_generation: reportData.level.sublevel,
          session_count_this_week: reportData.session_count,
          words_analyzed_this_week: reportData.word_count,
          sessions_included: [],
          sent_at: null, // will be set when push fires
        });

        // Send push notification (if token available)
        if (user.expo_push_token) {
          await sendPushNotification(
            user.expo_push_token,
            generated.notification_preview
          );

          // Mark as sent
          await supabase
            .from("coach_weekly_reports")
            .update({ sent_at: new Date().toISOString() })
            .eq("user_id", user.user_id)
            .eq("language_code", user.language_code)
            .eq("week_start", weekStartStr);
        }

        results.push({ user_id: user.user_id, status: "generated" });
      } catch (err) {
        console.error(`[WeeklyReport] Error for user ${user.user_id}:`, err);
        results.push({ user_id: user.user_id, status: "error", error: String(err) });
      }
    }

    return json({ week_start: weekStartStr, processed: results.length, results });
  } catch (err) {
    console.error("[WeeklyReport] Fatal error:", err);
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});

// ─── Report Generation with GPT ───────────────────────────────────────────────

async function generateReport(
  apiKey: string,
  languageName: string,
  data: WeeklyReportData,
  weekStart: string,
  weekEnd: string
): Promise<GeneratedReport> {
  const systemPrompt = buildReportSystemPrompt(languageName);
  const userMessage = buildReportUserMessage(data, weekStart, weekEnd);

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
      temperature: 0.5,
      max_tokens: 1400,
      response_format: { type: "json_object" },
    }),
  });

  if (!res.ok) {
    throw new Error(`OpenAI error for report: ${res.status} ${await res.text()}`);
  }

  const result = await res.json();
  return JSON.parse(result.choices[0].message.content) as GeneratedReport;
}

function buildReportSystemPrompt(languageName: string): string {
  return `You are writing a weekly language coaching report for someone learning ${languageName}.

YOUR VOICE:
- Human. Warm. Direct. Like a coach who's genuinely been paying attention all week.
- Never clinical, never robotic, never a list masquerading as prose.
- Don't congratulate them for sending messages — they were just living their life. Only celebrate real language progress.
- No emojis in body text. The notification_preview can use one sparingly.

REPORT STRUCTURE — output exactly this JSON shape:
{
  "notification_preview": "2-line string. Line 1: the most important thing this week (1 sentence). Line 2: a hook that makes them want to open it (1 sentence). Maximum 120 characters total.",
  "still_working_on": [
    {
      "rule_key": "exact rule_key from input",
      "category": "error_category from input",
      "headline": "2-4 word title, e.g. 'Ser vs. Estar'",
      "body": "2-3 sentences. Explain the rule naturally. Use a concrete example from their actual usage. End with something that normalizes the difficulty or points to the pattern."
    }
  ],
  "fixed_this": [
    {
      "rule_key": "exact rule_key from input",
      "category": "error_category from input",
      "headline": "2-4 word title",
      "body": "2 sentences max. Celebrate specifically. Name what they did right. Connect it to the work they've put in."
    }
  ],
  "one_thing": "Single sentence. A forward-looking micro-focus for the week ahead. Not a homework assignment. A direction.",
  "level_summary": "1-2 sentences max. Be honest about where they are. If they're moving, say so specifically. If they're stuck on something in particular, name it. Don't be vague."
}

RULES:
- still_working_on: include all items from the input (max 3). If none, return empty array — do not invent content.
- fixed_this: include all items from the input (max 2). If none, return empty array.
- one_thing: derive directly from the most important recurring issue. If no recurring issues, derive from their level progress.
- level_summary: only include if level is not null. Otherwise omit or return empty string.
- NEVER make up mistakes or praise that aren't in the input data.`;
}

function buildReportUserMessage(
  data: WeeklyReportData,
  weekStart: string,
  weekEnd: string
): string {
  const lines: string[] = [
    `Week: ${weekStart} to ${weekEnd}`,
    `Sessions this week: ${data.session_count}`,
    `Words analyzed: ${data.word_count}`,
    "",
  ];

  if (data.recurring_mistakes.length > 0) {
    lines.push("RECURRING MISTAKES (appeared in 2+ sessions this week):");
    for (const m of data.recurring_mistakes) {
      const examples = (m.surface_examples ?? []).slice(0, 2).join(", ");
      lines.push(`- rule_key: ${m.rule_key}`);
      lines.push(`  category: ${m.error_category}`);
      lines.push(`  rule: ${m.rule_description}`);
      if (examples) lines.push(`  recent examples: "${examples}"`);
      lines.push(`  total occurrences all time: ${m.occurrence_count}`);
    }
    lines.push("");
  } else {
    lines.push("RECURRING MISTAKES: none this week");
    lines.push("");
  }

  if (data.fixed_mistakes.length > 0) {
    lines.push("RECENTLY RESOLVED (user has now mastered these):");
    for (const f of data.fixed_mistakes) {
      lines.push(`- rule_key: ${f.rule_key}`);
      lines.push(`  category: ${f.error_category}`);
      lines.push(`  rule: ${f.rule_description}`);
      lines.push(`  resolved: ${f.resolved_at}`);
      lines.push(`  how long it took: appeared ${f.occurrence_count} times before mastery`);
    }
    lines.push("");
  } else {
    lines.push("RECENTLY RESOLVED: none");
    lines.push("");
  }

  if (data.level.level_unlocked && data.level.level) {
    lines.push(`CURRENT LEVEL: ${data.level.level} (${data.level.sublevel ?? "mid"})`);
    lines.push(`Next level criteria met: ${data.level.criteria_met} of ${data.level.criteria_total}`);
  } else {
    lines.push(`LEVEL: Not yet unlocked (${(data.level.cumulative_minutes ?? 0).toFixed(1)} of 15 minutes of audio accumulated)`);
  }

  return lines.join("\n");
}

// ─── Push Notification ────────────────────────────────────────────────────────

async function sendPushNotification(expoPushToken: string, previewText: string) {
  const lines = previewText.split("\n");
  const title = lines[0] ?? "Your weekly Spanish update";
  const body = lines[1] ?? "Tap to see what we noticed this week.";

  await fetch("https://exp.host/--/api/v2/push/send", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      to: expoPushToken,
      title,
      body,
      sound: "default",
      data: { type: "weekly_coach_report" },
    }),
  });
}

// ─── Utilities ────────────────────────────────────────────────────────────────

function getMostRecentMonday(date: Date): Date {
  const d = new Date(date);
  const day = d.getDay(); // 0 = Sunday
  const diff = day === 0 ? -6 : 1 - day; // roll back to Monday
  d.setDate(d.getDate() + diff);
  d.setHours(0, 0, 0, 0);
  return d;
}

function languageCodeToName(code: string): string {
  const map: Record<string, string> = {
    es: "Spanish",
    pt: "Portuguese",
    fr: "French",
    it: "Italian",
    de: "German",
    zh: "Chinese (Mandarin)",
    ja: "Japanese",
    ko: "Korean",
    ar: "Arabic",
    ru: "Russian",
    nl: "Dutch",
    pl: "Polish",
    tr: "Turkish",
    hi: "Hindi",
  };
  return map[code] ?? code;
}

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
}
