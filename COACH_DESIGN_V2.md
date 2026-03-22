# Orbit Coach — Detailed UI Design Spec
> Updated: 2026-03-21
> Status: Design brainstorm — every card, state, interaction, and data display

---

## Part A: Brand New User Experience (no data, no messages yet)

This is what someone sees the very first time they tap the Coach tab. They just downloaded the app. They haven't sent any messages yet. They're just clicking around exploring.

### What the screen looks like (empty state)

```
┌──────────────────────────────────────┐
│                                      │
│                                      │
│         [Sol avatar/icon]            │
│                                      │
│  "Hey, I'm Sol. 👋                   │
│                                      │
│   I'm your language coach — and I    │
│   live inside your keyboard.         │
│                                      │
│   Every time you send a voice        │
│   message, I listen and give you     │
│   tips to sound more natural.        │
│                                      │
│   The more you speak, the smarter    │
│   I get."                            │
│                                      │
│                                      │
│  ── How it works ──────────────────  │
│                                      │
│  🎤  Send voice messages like you    │
│      normally do — in WhatsApp,      │
│      Tinder, Instagram, anywhere     │
│                                      │
│  🎯  I'll give you 1-2 tips per     │
│      message — pronunciation,        │
│      grammar, or both                │
│                                      │
│  📊  Over time, I'll track your     │
│      patterns and show you exactly   │
│      where you're improving          │
│                                      │
│  🧠  I know your native language    │
│      brain will try to trick you —   │
│      I'll help you untrain those     │
│      habits                          │
│                                      │
│                                      │
│  ── What you'll unlock ────────────  │
│                                      │
│  After 1 message:                    │
│  ┌─────────┐                        │
│  │  🔓 →🗣 │ Pronunciation insights │
│  └─────────┘                        │
│                                      │
│  After 3 messages:                   │
│  ┌─────────┐                        │
│  │  🔒  📝 │ Grammar scoring        │
│  └─────────┘                        │
│                                      │
│  After 10 messages:                  │
│  ┌─────────┐ ┌─────────┐           │
│  │  🔒  📚 │ │  🔒  💬 │           │
│  │  Vocab   │ │ Fluency  │           │
│  └─────────┘ └─────────┘           │
│                                      │
│  Weekly reports · Milestones ·       │
│  Practice sessions · and more        │
│                                      │
│                                      │
│  ── Ready? ────────────────────────  │
│                                      │
│  ┌──────────────────────────────┐   │
│  │                              │   │
│  │   🎤  Send your first        │   │
│  │      voice message            │   │
│  │                              │   │
│  └──────────────────────────────┘   │
│                                      │
│  Open any messaging app, switch to   │
│  the Orbit keyboard, and tap the     │
│  mic button. I'll be listening. 😊   │
│                                      │
│                                      │
└──────────────────────────────────────┘
```

### Design notes for empty state:
- **Single scroll, no cards** — the whole screen is one welcoming flow, not a bunch of empty cards with lock icons
- **Warm and inviting** — this is the coach introducing itself, not a feature list
- **Progressive unlock preview** — shows what they'll earn by sending messages, creating motivation
- **Clear CTA** — one button, one action: go send a voice message
- **No overwhelming UI** — no gauges, no charts, no settings. Just the introduction.
- **Background** — same TSGradientBackground as the rest of the app, or a subtle warm gradient

### What happens after they send their first voice message:
The empty state is **permanently replaced** by the populated state (Part B below). They never see this introduction again. The coach greeting card collapses to a one-liner, and the score cards start appearing.

### Transition animation:
When they return to the Coach tab after sending their first voice message:
1. Sol's intro text fades out (0.3s)
2. The populated cards fade/slide in from below (0.5s, staggered)
3. Pronunciation gauge unlocks with a small sparkle animation
4. Toast: "🎉 Pronunciation insights unlocked!"

---

## Part B: Populated State (user has sent messages, has data)

This is the ongoing experience. Cards progressively fill with data as the user sends more messages.

### Screen Architecture

One scrollable screen with cards that progressively unlock. No sub-pages or navigation stacks — everything lives on one scroll. Tapping a card opens a detail modal (full-screen overlay).

```
┌──────────────────────────────────┐
│         Coach Tab (scroll)       │
│                                  │
│  [Coach Greeting Card]           │
│  [Score Overview — 4 gauges]     │
│  [Weekly Snapshot Card]          │
│  [Recent Tips Feed]              │
│  [Practice Mode Card]            │
│  [Milestones & Achievements]     │
│  [Language Confidence Index]     │
│                                  │
└──────────────────────────────────┘
```

---

## 1. Coach Greeting Card

**Always visible at the top.** This is how the coach persona lives in the UI.

### Default State (collapsed — shown after first message onward)
```
┌──────────────────────────────────────┐
│  [Sol avatar/icon]                   │
│                                      │
│  "You've been killing it this week,  │
│   Jeffrey. 3 mistakes graduated."    │
│                                      │
│  Last active: 2 hours ago            │
└──────────────────────────────────────┘
```

- The greeting changes dynamically based on activity:
  - **Active user:** progress-based message ("3 mistakes graduated this week")
  - **Returning after absence:** "Welcome back. Here's what's changed since you've been gone."
  - **First few messages:** "You're off to a great start. Keep sending voice messages — I'm learning your patterns."
  - **Big milestone:** "You just graduated ser vs estar. That's HUGE."
- One-liner, warm, never generic
- Shows "Last active" timestamp so it feels alive

---

## 2. Score Overview Card (4 Gauges)

### Layout
```
┌──────────────────────────────────────┐
│  YOUR LEVEL                          │
│                                      │
│  ┌─────────┐    ┌─────────┐         │
│  │  ╭───╮  │    │  ╭───╮  │         │
│  │  │B1 │  │    │  │A2 │  │         │
│  │  ╰───╯  │    │  ╰───╯  │         │
│  │ Pronun. │    │ Grammar │         │
│  └─────────┘    └─────────┘         │
│                                      │
│  ┌─────────┐    ┌─────────┐         │
│  │   🔒    │    │   🔒    │         │
│  │         │    │         │         │
│  │  Vocab  │    │ Fluency │         │
│  └─────────┘    └─────────┘         │
│                                      │
│  ✨ 2 more unlock with more audio    │
│                                      │
└──────────────────────────────────────┘
```

### Each Gauge — Design Options

**Option A: Half-circle speedometer**
- Needle points to current level on an arc from A1 to Native
- Color gradient: red (A1) → orange (A2) → yellow (B1) → green (B2) → blue (C1) → purple (C2)
- Level label in the center
- Category name below

**Option B: Ring/donut**
- Circular progress ring that fills as level increases
- Percentage fill = progress within current level
- Level label in the center
- More compact, modern feel

**Option C: Simple badge**
- Just the level (B1) in a colored circle
- Category name below
- Minimal, scannable
- Tap to see detail

**My recommendation:** Option B (ring/donut) for the main overview — it's compact, modern, and shows progress within a level (not just the level itself). Option A (speedometer) inside the detail modal where there's more space.

### Locked Gauge States
```
┌─────────┐
│   🔒    │
│  ░░░░░  │  ← grayed-out ring
│  Vocab  │
│         │
│ 5 more  │  ← "5 more messages to unlock"
│ messages│
└─────────┘
```

- Grayed out ring, lock icon
- Shows how many more messages needed
- Tapping shows: "Send X more voice messages to unlock Vocabulary insights"

### Unlock Animation
When a category unlocks:
- Lock icon fades out
- Ring fills with color (animated, ~1 second)
- Level appears in center
- Subtle confetti or sparkle effect
- Toast notification: "🎉 Grammar insights unlocked!"

### Tapping a Gauge → Detail Modal
(See Section 7: Detail Modals)

---

## 3. Weekly Snapshot Card

### Collapsed State (default on Coach tab)
```
┌──────────────────────────────────────┐
│  📊 THIS WEEK              Mar 17-21│
│                                      │
│  ✅ Win: Graduated 'ser vs estar'    │
│  📝 Work on: Gender agreement (72%) │
│  🎯 Challenge: Try ordering food    │
│     without switching to English     │
│                                      │
│           [ See full report → ]      │
└──────────────────────────────────────┘
```

- 1 win, 1 work-on, 1 challenge — always exactly 3 items
- "See full report" opens expanded view

### Expanded View (modal or in-place expansion)
```
┌──────────────────────────────────────┐
│  📊 WEEKLY REPORT          Mar 17-21│
│  ← Back                             │
│                                      │
│  ── WINS ────────────────────────── │
│  🎉 Graduated: ser vs estar         │
│  ✅ Gender accuracy: 72% → 81%      │
│  ✅ New words used: 'saudade',      │
│     'madrugada', 'concorrência'     │
│                                      │
│  ── WORK ON ─────────────────────── │
│  ⚠️ Gender agreement: 72%           │
│     Most common: defaulting to      │
│     masculine with -ade words       │
│  ⚠️ Prepositions: 'em' vs 'a'      │
│     for direction (68% accuracy)    │
│                                      │
│  ── BY THE NUMBERS ──────────────── │
│  Messages sent: 47                   │
│  Voice messages: 23                  │
│  Minutes of audio: 12               │
│  Pronunciation score avg: 74        │
│                                      │
│  ── TRENDS ──────────────────────── │
│  [Mini line charts per category]     │
│  Pronunciation: ↑ improving          │
│  Grammar: → plateau                  │
│  Vocabulary: ↑ growing               │
│                                      │
│  ── CHALLENGE ───────────────────── │
│  🎯 This week: Try ordering food    │
│  without switching to English.       │
│  "You have the vocabulary for it —   │
│  'eu gostaria de...' is your friend" │
│                                      │
└──────────────────────────────────────┘
```

### No Data State
If they haven't sent enough messages this week:
```
┌──────────────────────────────────────┐
│  📊 THIS WEEK                        │
│                                      │
│  Not enough data yet this week.      │
│  Send a few more voice messages      │
│  and your report will appear here    │
│  Tuesday night.                      │
│                                      │
└──────────────────────────────────────┘
```

---

## 4. Recent Tips Feed

### Layout
A vertical scrollable list of the most recent coaching tips (last 5-7).

```
┌──────────────────────────────────────┐
│  RECENT TIPS                         │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ 🗣 Mar 21, 5:23 PM            │  │
│  │ Watch the nasal 'ão' in       │  │
│  │ 'coração' — tongue further    │  │
│  │ back.                          │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ 💡 Mar 21, 4:45 PM            │  │
│  │ 'a casa dele' not 'do ele.'   │  │
│  │ Portuguese flips possession.   │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ 🎉 Mar 20                     │  │
│  │ MILESTONE: ser/estar not      │  │
│  │ confused in 14 days!           │  │
│  └────────────────────────────────┘  │
│                                      │
│         [ View all tips → ]          │
└──────────────────────────────────────┘
```

### Tip Card Design Options

**Option A: Flat list (like messages)**
- Simple rows with icon, date, text
- Most scannable
- No borders, just dividers

**Option B: Cards with subtle background**
- Each tip in its own card with slight shadow
- More visual separation
- Feels more polished

**Option C: Timeline with dots**
- Left-side timeline with dots connecting tips chronologically
- Milestones are bigger dots with a different color
- Feels like a journey

**My recommendation:** Option B for v1 — cards with subtle background. Clean, modern, easy to scan. Option C (timeline) for v2 when there's enough history to make a timeline feel meaningful.

### Transfer Insight Tips (special first-time styling)
When the coach surfaces a transfer pattern for the FIRST time, it gets special visual treatment:
```
┌────────────────────────────────────┐
│ 🧠 LANGUAGE INSIGHT        Mar 21  │
│ ──────────────────────────────── │
│ In English you'd say "John's       │
│ house" — possessor first. But      │
│ Portuguese flips it: "a casa do    │
│ John." Your English brain is doing │
│ what it's trained to do.           │
│                                    │
│ This is a normal hurdle. You'll    │
│ untrain it. 💪                     │
└────────────────────────────────────┘
```
- Different background color (subtle blue/purple — "insight" feel)
- Brain icon 🧠 — signals this is about HOW your mind works, not just a correction
- Only shows with full explanation ONCE per pattern
- Subsequent mentions of the same pattern use regular tip styling (short nudge)

### Transfer Nudge Tips (after first insight was shown)
```
┌────────────────────────────────────┐
│ 💡 Mar 23                          │
│ That possessive order again —      │
│ "a casa dele," not "dele casa."    │
│ Getting closer. 👊                 │
└────────────────────────────────────┘
```
- Regular tip styling — no special background
- Short, warm, no re-explanation
- Different wording each time (variety rule applies)

### Milestone Tips (special styling)
```
┌────────────────────────────────────┐
│ 🎉 MILESTONE              Mar 20  │
│ ──────────────────────────────── │
│ You haven't mixed up 'ser' and    │
│ 'estar' in 14 days. That's not    │
│ luck — that's muscle memory.      │
│                                    │
│ One down. ✓                        │
└────────────────────────────────────┘
```
- Different background color (subtle gold/amber)
- Celebration icon
- Stands out from regular tips

---

## 5. Practice Mode Card

### Default State
```
┌──────────────────────────────────────┐
│  💬 PRACTICE                         │
│                                      │
│  "You've been struggling with past   │
│   subjunctive. Want to work on it?"  │
│                                      │
│        [ Start Session ]             │
│                                      │
│  Last session: 2 days ago            │
│  Sessions this week: 3              │
└──────────────────────────────────────┘
```

### Cooldown State
```
┌──────────────────────────────────────┐
│  💬 PRACTICE                         │
│                                      │
│  Great session! Go use what you      │
│  practiced in a real conversation.   │
│                                      │
│  Next session available at 4:30 PM   │
│                                      │
│        [ Start anyway ]              │
│         (grayed out, subtle)         │
└──────────────────────────────────────┘
```

### In-Session View (full screen modal)
```
┌──────────────────────────────────────┐
│  ← End session         3/10         │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ Sol:                           │  │
│  │ "O que você fez no fim de     │  │
│  │  semana? Saiu com amigos?"    │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ You:                           │  │
│  │ [text input or mic button]    │  │
│  └────────────────────────────────┘  │
│                                      │
│                        🎤  [Send]    │
└──────────────────────────────────────┘
```

- Chat bubble interface
- Message counter (3/10) shows progress toward session end
- Mic button for voice input, keyboard for text
- Coach responds in target language with occasional English coaching inline

### Session Wrap-up
```
┌──────────────────────────────────────┐
│  SESSION COMPLETE ✨                  │
│                                      │
│  You nailed the subjunctive today.   │
│  First time you used 'que eu fosse'  │
│  naturally — that's growth.          │
│                                      │
│  ── Session stats ──                 │
│  Messages: 10                        │
│  New vocabulary: 3 words             │
│  SRS items tested: 2 (both correct!) │
│                                      │
│  Go use it in a real conversation.   │
│                                      │
│         [ Done ]                     │
└──────────────────────────────────────┘
```

---

## 6. Milestones & Achievements Card

### Layout
```
┌──────────────────────────────────────┐
│  🏆 MILESTONES                       │
│                                      │
│  ┌──────┐ ┌──────┐ ┌──────┐        │
│  │  ✓   │ │  ✓   │ │ 14/20│        │
│  │ser/  │ │gender│ │ prep │        │
│  │estar │ │ -ade │ │ a/em │        │
│  │      │ │words │ │      │        │
│  │GRAD  │ │GRAD  │ │ 70%  │        │
│  └──────┘ └──────┘ └──────┘        │
│                                      │
│  3 graduated · 2 in progress         │
│                                      │
└──────────────────────────────────────┘
```

- Horizontal scrollable row of milestone badges
- Graduated: checkmark, colored
- In progress: shows count (14/20 clean interactions)
- Tapping shows the history of that specific mistake

### Graduated Badge Design
```
┌──────┐
│  ✓   │  ← green checkmark
│      │
│ser/  │  ← mistake category
│estar │
│      │
│ Oct  │  ← month graduated
│ 2026 │
└──────┘
```

### In-Progress Badge
```
┌──────┐
│ ████ │  ← progress bar (14/20)
│ ░░░░ │
│      │
│ prep │  ← mistake category
│ a/em │
│      │
│ 70%  │  ← current accuracy
└──────┘
```

---

## 7. Detail Modals (tap any gauge or card)

### Shared Modal Structure
Full-screen overlay with back button. Scrollable content.

### Pronunciation Detail
```
┌──────────────────────────────────────┐
│ ← Back              PRONUNCIATION    │
│                                      │
│        ┌─────────────┐               │
│        │   ╭─────╮   │               │
│        │   │     │   │               │
│        │   │ B1  │   │               │
│        │   ╰─────╯   │               │
│        └─────────────┘               │
│   Based on 47 voice messages         │
│                                      │
│ ── PRONUNCIATION SCORE TREND ──── │
│ [Line chart — last 30 days]          │
│ Dots = per-message scores            │
│ Tap a dot to see that message        │
│                                      │
│ ── STRENGTHS ───────────────────── │
│ ✅ Vowel clarity: consistent         │
│ ✅ Stress patterns on 3+ syllable    │
│    words                             │
│                                      │
│ ── WORK ON ─────────────────────── │
│ ⚠️ Nasal 'ão' (coração, não)        │
│    └ Last detected: Mar 21           │
│    └ Occurrences: 8 times            │
│    └ [▶ Hear correct pronunciation]  │
│                                      │
│ ⚠️ Final 's' drops in long          │
│    sentences                         │
│    └ Last detected: Mar 20           │
│    └ Occurrences: 5 times            │
│    └ [▶ Hear correct pronunciation]  │
│                                      │
│ ── PACE ─────────────────────────── │
│ Your avg: 142 words/min              │
│ Native avg: 130 words/min            │
│ 💡 Slowing down slightly could      │
│    improve clarity                   │
│                                      │
└──────────────────────────────────────┘
```

### Grammar Detail
```
┌──────────────────────────────────────┐
│ ← Back                    GRAMMAR    │
│                                      │
│        ┌─────────────┐               │
│        │     A2      │               │
│        └─────────────┘               │
│   Based on 47 voice messages         │
│                                      │
│ ── SUB-CATEGORIES ──────────────── │
│                                      │
│ ▼ Conjugation              B1  ↑    │
│   Your conjugation is strong.        │
│   Past subjunctive needs work.       │
│   Recent: "se eu fosse" ✓           │
│                                      │
│ ▼ Gender Agreement         A2  →    │
│   You default to masculine 68%.      │
│   Most common: -ade words            │
│   (cidade, saudade, liberdade)       │
│   Recent: "uma bar" → "um bar"       │
│                                      │
│ ▼ Prepositions             A2  ↑    │
│   em/a confusion: 72% accuracy       │
│   por/para: 85% — almost there       │
│   Recent: "vou em casa" → "vou       │
│   a casa"                            │
│                                      │
│ ▶ Register (tú/você)      ──  🔒   │
│   Not enough data yet                │
│                                      │
└──────────────────────────────────────┘
```

- Each sub-category is collapsible (▼ expanded, ▶ collapsed)
- Arrow indicators: ↑ improving, → plateau, ↓ declining
- Level badge per sub-category
- Recent examples with corrections inline
- Locked sub-categories show what's needed to unlock

### Vocabulary Detail
```
┌──────────────────────────────────────┐
│ ← Back                  VOCABULARY   │
│                                      │
│        ┌─────────────┐               │
│        │     B1      │               │
│        └─────────────┘               │
│                                      │
│ ── STATS ────────────────────────── │
│ Unique words this month: 342         │
│ New words this week: 27              │
│ Most used: 'legal' (47x)            │
│                                      │
│ ── NEW WORDS LEARNED ────────────── │
│ This week:                           │
│ • saudade • madrugada                │
│ • concorrência • destacar            │
│ • empolgado                          │
│                                      │
│ ── WORD CLOUD ───────────────────── │
│ [Visual word cloud — bigger =        │
│  more frequently used]               │
│                                      │
│ ── RANGE ASSESSMENT ─────────────── │
│ You use everyday vocabulary          │
│ confidently. To reach B2, try        │
│ incorporating more abstract          │
│ concepts and idiomatic expressions.  │
│                                      │
└──────────────────────────────────────┘
```

### Fluency Detail
```
┌──────────────────────────────────────┐
│ ← Back                    FLUENCY    │
│                                      │
│        ┌─────────────┐               │
│        │     A2      │               │
│        └─────────────┘               │
│                                      │
│ ── METRICS ──────────────────────── │
│ Avg sentence length: 8.2 words       │
│ Filler words ('um/uh'): 23%         │
│   ↓ down from 31% last month         │
│ Sentence variety: moderate            │
│                                      │
│ ── PACE ─────────────────────────── │
│ Your speaking pace: 142 wpm          │
│ Native range: 120-140 wpm            │
│ 💡 You're slightly fast — try       │
│    pausing between ideas             │
│                                      │
│ ── STRUCTURE ────────────────────── │
│ You tend to use Subject-Verb-Object. │
│ Try starting sentences with:         │
│ • Time: "Ontem eu..."               │
│ • Location: "No restaurante..."     │
│ • Feeling: "Achei que..."           │
│                                      │
│ ── TREND ────────────────────────── │
│ [30-day line chart]                   │
│ Filler words decreasing ↓ Great!     │
│ Sentence length growing ↑ Good       │
│                                      │
└──────────────────────────────────────┘
```

---

## 8. Language Confidence Index

```
┌──────────────────────────────────────┐
│  🌍 LANGUAGE CONFIDENCE              │
│                                      │
│         ┌─────────┐                  │
│         │         │                  │
│         │   62%   │                  │
│         │         │                  │
│         └─────────┘                  │
│  of your messages are in Portuguese  │
│                                      │
│  [Bar chart — last 4 weeks]          │
│  W1: ████░░░░░░ 38%                 │
│  W2: █████░░░░░ 47%                 │
│  W3: ██████░░░░ 55%                 │
│  W4: ████████░░ 62%                 │
│                                      │
│  ↑ You're using Portuguese more      │
│    every week. Keep it up.           │
│                                      │
└──────────────────────────────────────┘
```

- Only shown if user sends messages in both languages
- Big percentage number = primary metric
- Weekly bar chart shows trend
- Encouraging message based on trend direction

---

## 9. Pop-ups & Transient UI

### Pronunciation Score Toast (after each voice message)
```
┌────────────────────┐
│  🗣 Score: 74      │
│  ░░░░░░░▓▓▓        │
└────────────────────┘
```
- Appears briefly (2 seconds) at the top of the keyboard
- Fades away automatically
- Tap to see tips in the Coach tab
- Only appears if the user has enabled it in settings

### Milestone Notification
```
┌──────────────────────────────────────┐
│  🎉 Milestone!                       │
│                                      │
│  You've mastered 'ser vs estar.'     │
│  Graduated from your mistake profile.│
│                                      │
│        [ View in Coach ]             │
└──────────────────────────────────────┘
```
- Push notification or in-app banner
- Links to the Milestones section

### Category Unlock Notification
```
┌──────────────────────────────────────┐
│  ✨ New insight unlocked!             │
│                                      │
│  Grammar scoring is now available.   │
│  Check your Coach tab to see         │
│  your level.                         │
│                                      │
│        [ See my score ]              │
└──────────────────────────────────────┘
```

### Weekly Report Push Notification (Tuesday night)
```
┌──────────────────────────────────────┐
│  📊 Your weekly report is ready      │
│                                      │
│  1 win · 1 thing to work on ·       │
│  1 challenge                         │
│                                      │
│        [ Open Coach ]                │
└──────────────────────────────────────┘
```

---

## 10. Settings Presets Screen

```
┌──────────────────────────────────────┐
│  COACH SETTINGS                      │
│                                      │
│  ── PRESETS ─────────────────────── │
│                                      │
│  ◉ Full Coaching                     │
│    Everything on — tips, scores,     │
│    alerts, reports                    │
│                                      │
│  ○ Light Coaching                    │
│    Cultural alerts + weekly reports   │
│    only                              │
│                                      │
│  ○ Translation Only                  │
│    Keyboard translates, coach off    │
│                                      │
│  ○ Custom                            │
│    Configure individual features     │
│                                      │
│  ── CUSTOM TOGGLES ──────────────── │
│  (only visible when Custom selected) │
│                                      │
│  Pronunciation tips      [ON]        │
│  Grammar tips             [ON]        │
│  Pronunciation score      [ON]        │
│  Confidence score         [OFF]       │
│  Cultural alerts          [ON]        │
│  Weekly report            [ON]        │
│  Monthly lookback         [ON]        │
│  Practice notifications   [ON]        │
│                                      │
└──────────────────────────────────────┘
```

---

## 11. Monthly Lookback (in-app card, appears once a month)

```
┌──────────────────────────────────────┐
│  📅 YOUR MONTH IN REVIEW    February │
│                                      │
│  One month ago:                      │
│  • Pronunciation: A2                 │
│  • ser/estar: struggling             │
│  • Messages sent: 34                 │
│                                      │
│  Today:                              │
│  • Pronunciation: B1 ↑              │
│  • ser/estar: almost graduated ✓    │
│  • Messages sent: 127               │
│                                      │
│  That's not an app talking —         │
│  that's YOU putting in the work.     │
│                                      │
│        [ Share my progress ]         │
│                                      │
└──────────────────────────────────────┘
```

---

## 12. Orbit Wrapped (Annual — shareable story format)

Vertical swipeable cards designed for Instagram/TikTok stories:

**Card 1:** "Your year in Portuguese" (big text, gradient background)
**Card 2:** "You sent 2,847 messages" (number animation)
**Card 3:** "Your pronunciation went from A2 → B1" (gauge animation)
**Card 4:** "You graduated 7 mistakes" (confetti)
**Card 5:** "Most-used slang: 'tá ligado' (147 times)" (fun stat)
**Card 6:** "Language in the Wild. 🌎" (brand closer)

Each card is shareable individually or as a set.

---

## 13. Exportable Teacher Report

```
┌──────────────────────────────────────┐
│  PROGRESS REPORT                     │
│  Jeffrey Johnson · Portuguese        │
│  Generated: March 21, 2026           │
│                                      │
│  Overall Level: A2 → B1             │
│                                      │
│  Pronunciation: B1                   │
│  Grammar: A2                         │
│  Vocabulary: B1                      │
│  Fluency: A2                         │
│                                      │
│  Top Strengths:                      │
│  • Verb conjugation (present tense)  │
│  • Vowel clarity                     │
│  • Growing vocabulary range          │
│                                      │
│  Areas for Focus:                    │
│  • Gender agreement (-ade words)     │
│  • Prepositions (em vs a)            │
│  • Past subjunctive                  │
│  • Speaking pace (slightly fast)     │
│                                      │
│  Recent Mistake Examples:            │
│  • "uma bar" → "um bar"             │
│  • "vou em casa" → "vou a casa"     │
│                                      │
│  [ Export as PDF ] [ Share ]         │
└──────────────────────────────────────┘
```

---

## 14. Daily Language Fact (Coach tab header)

Small rotating banner below the coach greeting:

```
┌──────────────────────────────────────┐
│  💡 Did you know?                    │
│  70% of English speakers struggle    │
│  with Portuguese nasal vowels.       │
│  You're not alone.             [×]   │
└──────────────────────────────────────┘
```

- Different fact each day
- Dismissable with ×
- Curated library (not AI-generated on the fly)
- Stops showing once library is exhausted

---

## Design Principles Summary

1. **One scroll, no navigation maze** — everything on one page, details in modals
2. **Collapsed by default** — one-liner summaries, tap to expand
3. **Progressive disclosure** — more data unlocks over time, never overwhelm day 1
4. **Positivity first** — lead with wins, then work areas
5. **Real examples** — every score links back to actual messages
6. **Two user modes** — bus stop glancer (30 seconds) and desk studier (15 minutes)
7. **Shareable moments** — milestones, wrapped, reports designed for screenshots
8. **Consistent visual language** — gauges, cards, and colors mean the same thing everywhere
