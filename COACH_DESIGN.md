# Orbit Coach — UI Design Plan
> Written: 2026-03-21
> Status: Design brainstorm — layout and behavior specs

---

## Part 1: Coach Tab — Landing Page

### First Visit (no data yet)
The user opens the Coach tab for the first time. No scores, no data, no history.

**Screen contents:**
1. **Hero section** — Coach persona introduction
   > "Hey, I'm [Name]. I listen to your voice messages and help you sound more natural — without getting in your way. The more you speak, the smarter I get."

2. **How it works** — 3 simple steps, visual icons
   - 🎤 "Send voice messages like you normally do"
   - 🎯 "I'll give you 1-2 tips per message — pronunciation, grammar, or both"
   - 📊 "Over time, I'll track your patterns and show you exactly where you're improving"

3. **What to expect** — Timeline
   - "After your 1st voice message → pronunciation insights"
   - "After 3 messages → grammar patterns emerge"
   - "After 8-10 messages → full profile with vocabulary and fluency scores"
   - "Every week → a progress report that shows your wins"

4. **How to get the most out of Coach**
   - "Speak naturally — don't try to be perfect. I learn more from your real speech."
   - "Mix it up — order food, chat with friends, argue with your landlord. Variety helps me understand your strengths."
   - "Check in weekly — your Tuesday report is where the magic happens."

5. **CTA button** — "Send your first voice message" → deep links to keyboard

---

### Returning Visit (with data)
User has sent voice messages and has scores/data.

**Screen layout (top to bottom):**

#### A. Score Overview (4 half-circle gauges)
```
┌─────────────────────────────────────┐
│  ┌───────┐  ┌───────┐              │
│  │ Pron. │  │ Gram. │              │
│  │  B1   │  │  A2   │              │
│  └───────┘  └───────┘              │
│  ┌───────┐  ┌───────┐              │
│  │ Vocab │  │Fluency│              │
│  │  🔒   │  │  🔒   │              │
│  └───────┘  └───────┘              │
│                                     │
│  "2 more insights unlock as you     │
│   send more voice messages"         │
└─────────────────────────────────────┘
```

- Each gauge is a half-circle speedometer
- Level shown inside: A1 → A2 → B1 → B2 → C1 → C2 → Native
- Locked gauges show 🔒 with a subtle "unlock after X messages" label
- Tapping a gauge opens its detail modal

#### B. Weekly Pronunciation Score Trend
Small line chart showing per-message pronunciation scores over the past 7 days.
- Dots for each message, line connecting them
- Tap a dot to see the specific message and tips from that moment
- Overall trend arrow (↑ improving, → plateau, ↓ new challenge)

#### C. Recent Tips (last 3-5)
Scrollable list of recent coaching tips, most recent first:
```
┌─────────────────────────────────────┐
│ 🗣 Mar 21 — "Watch the 'ão' sound  │
│ in 'coração' — your tongue needs   │
│ to be further back."               │
├─────────────────────────────────────┤
│ 💡 Mar 21 — "Remember: 'a casa     │
│ dele' not 'do ele.' Portuguese     │
│ flips the possession."             │
├─────────────────────────────────────┤
│ 🎉 Mar 20 — MILESTONE: You haven't │
│ mixed up ser/estar in 14 days!     │
└─────────────────────────────────────┘
```

#### D. Practice Mode Card
```
┌─────────────────────────────────────┐
│ 💬 Ready to practice?              │
│                                     │
│ "You've been struggling with past   │
│  subjunctive. Want to work on it?"  │
│                                     │
│        [ Start Session ]            │
└─────────────────────────────────────┘
```

---

## Part 2: Category Detail Modals

Each scoring category opens a full modal when tapped. All modals share the same structure but with category-specific content.

### Modal Structure (shared)
```
┌─────────────────────────────────────┐
│ ← Back            [Category Name]   │
│                                     │
│        ┌─────────────┐              │
│        │  Half-circle │              │
│        │   gauge      │              │
│        │    B1        │              │
│        └─────────────┘              │
│   "Based on 47 voice messages"      │
│                                     │
│ ─── STRENGTHS ─────────────────── │
│ ✅ Thing they're good at            │
│ ✅ Another strength                 │
│                                     │
│ ─── WORK ON ──────────────────── │
│ ⚠️ Specific weak area              │
│ ⚠️ Another weak area               │
│                                     │
│ ─── RECENT EXAMPLES ─────────── │
│ "Mar 21: said 'do ele' → should    │
│  be 'dele'"                         │
│ "Mar 19: mixed up por/para"         │
│                                     │
│ ─── TREND ────────────────────── │
│ [Mini line chart — last 30 days]    │
│ "↑ Improving — you've moved from   │
│  A2 to B1 this month"              │
└─────────────────────────────────────┘
```

### Pronunciation Modal — Specific Content
**Strengths section might show:**
- "Your vowel sounds are consistently clear"
- "Good stress patterns on 3+ syllable words"

**Work On section might show:**
- "The nasal 'ão' sound (coração, não) — tongue position"
- "Final 's' tends to drop in longer sentences"
- "The 'lh' sound (trabalho, filho) — sounds like 'ly' instead of 'lh'"

**Expandable:** Tap any item to see:
- When it was last detected
- How many times it's occurred
- Audio comparison (if Monthly Voice Comparison data exists)
- "Practice this" button (links to a targeted pronunciation exercise)

### Grammar Modal — Specific Content
**Sub-categories (collapsible sections):**

**Conjugation**
- Current level indicator
- Specific weak spots: "Past subjunctive is your biggest gap"
- Recent examples with corrections

**Gender Agreement**
- Pattern summary: "You default to masculine 68% of the time"
- Most common mistakes: "la mesa → 'el mesa' (3 times this week)"

**Prepositions**
- "en/a confusion for direction: 72% accuracy"
- "'por' vs 'para': 85% accuracy — almost there"

**Register (tú vs usted)**
- "You're consistent with informal — good for casual conversations"
- "Formal register not yet tested — try it in a practice session"

**Each sub-category is expandable.** Collapsed = one-line summary with a level badge. Expanded = full detail with examples and trend.

### Vocabulary Modal — Specific Content
- "Unique words used this month: 342"
- "Most used words: [word cloud or top 10 list]"
- "Words you've learned this month: [list of new words that appeared after your first week]"
- "Vocabulary range: B1 — you use common everyday vocabulary confidently. To reach B2, try incorporating more abstract concepts and idiomatic expressions."

### Fluency Modal — Specific Content
- "Average sentence length: 8.2 words (B1 typical: 7-10)"
- "Filler word frequency: 'um/uh' appears in 23% of sentences — down from 31% last month"
- "Sentence structure variety: moderate — you tend to use Subject-Verb-Object. Try starting sentences with time expressions or locations."
- "Natural flow score: 74/100 — based on pause patterns, filler frequency, and sentence complexity"

---

## Part 3: Collapsed vs Expanded States

### Coach Tab — Cards

**Collapsed state (default):**
Each section is a card showing:
- Category icon + name
- Level badge (A1-C2 or 🔒)
- One-line summary: "Your pronunciation is at B1 — nasal sounds need work"
- Subtle chevron indicating expandability

**Tapping a card → opens the full modal (Part 2)**

### In-Keyboard Coaching Tips

**Collapsed state:**
The correction/coaching card in the keyboard shows max 2 tips in the existing green card format. No expansion needed — the keyboard is for quick glances.

**For deeper analysis:** The Coach tab in the main app is where users go to dig in.

---

## Part 4: User Journey States

### State 1: Brand new (0 voice messages)
- Coach tab shows intro/onboarding (Part 1 first visit)
- All 4 gauges show 🔒
- No tips, no history
- CTA: "Send your first voice message"

### State 2: Getting started (1-3 voice messages)
- Pronunciation gauge unlocked (rough score)
- Grammar/Vocab/Fluency still 🔒
- 1-3 recent tips showing
- "Grammar unlocks after 3 voice messages" teaser

### State 3: Building profile (4-9 voice messages)
- Pronunciation + Grammar unlocked
- Vocab/Fluency still 🔒
- Pattern detection starting to work
- First personalized callbacks appearing
- "Full profile unlocks after 10 voice messages"

### State 4: Full profile (10+ voice messages)
- All 4 gauges active
- Weekly report available
- Practice mode personalized to weak spots
- Milestone callbacks when patterns resolve
- Rich detail in all modals

### State 5: Mature user (50+ voice messages)
- Trend lines meaningful (30+ days of data)
- Monthly voice comparison available
- "Your voice is changing" feature active
- Deep sub-category analysis in Grammar modal
- Practice mode uses spaced repetition from real conversation history

---

## Design Principles

1. **Progressive disclosure** — show more as they use more. Never overwhelm on day 1.
2. **Collapsed by default** — everything starts as a one-line summary. Depth is opt-in.
3. **Positivity-first** — lead with strengths, then work areas. Never make someone feel bad about their level.
4. **Real examples** — every insight links back to a specific message they sent. Abstract scores without context are meaningless.
5. **Actionable** — every "work on" item should have a clear next step (practice session, specific tip, or just awareness).
6. **Two user modes** — passive glancer (bus stop, 30 seconds) and active studier (desk, 15 minutes). Both get value from the same screen at different depths.
