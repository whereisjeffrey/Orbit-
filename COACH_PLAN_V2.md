# Orbit Coach — Product Plan v2
> Updated: 2026-03-21
> Status: Comprehensive brainstorm — all ideas captured, ready for prioritization

---

## Product Philosophy

**Orbit is not a language learning app. It's a language living app.**

Every feature must pass: **"Would a busy expat actually want this interrupting their Tuesday?"**

Core brand principle: **"Language in the Wild."**

---

## Pricing Tiers

### Orbit Free
- **30 full-featured messages per month** (typed or voice — no distinction)
- Full experience: slang tones, notes, corrections, voice — everything
- After 30: basic DeepL translation only (no refinement, no notes, no coach)

### Orbit Pro — $7.99/month ($59.99/year)
- Unlimited everything
- Single tier — no feature gating
- Annual: "$5/month — save 37%"

---

## Coach Feature — Core Loop

### Per-Audio Coaching
Every voice message gets a maximum of **2 tips**. The prompt chooses the 2 most impactful — could be:
- 2 pronunciation tips
- 2 grammar tips
- 1 of each

No hard rule on the split. Let the AI pick what matters most for that specific message.

### Per-Message Pronunciation Score (toggleable)
Each voice message gets a score (0-100).
- **Per message** (not daily) — so users can pinpoint exactly which message had issues
- Score of 99 = "you're good." Score of 62 = "something here needs attention, read the tips"
- **Scores are relative to the user's level.** A1 user gets scored against A1 expectations. If they "graduate" to A2, scores reset relative to A2.
- Start above a baseline (e.g., 60%) so nobody feels like they're failing from day one
- **Settings:** Per message / Off
- **Introduced after 1 week of use** — not on day one. Let them get comfortable first, then offer it: "You've been sending voice messages for a week. Want to see how your pronunciation scores? You can turn this on in Settings."

When scoring, the prompt should pop up and fade away — not block the UI. Quick glance, not a gate.

### Noisy Environment / Low Confidence Safeguard
If the system isn't confident it can accurately score pronunciation (background noise, unclear audio, user sounds sick):
- Don't show a pronunciation score for that message
- Optionally show: "Couldn't score this one clearly — try a quieter spot next time"
- **Never give a bad score based on bad data.** Silence is better than a wrong number.

### Emotional Variety in Coaching
The prompt must vary its emotional tone. Never robotic, never the same voice twice in a row:
- **Playful:** "There's that sneaky preposition again!"
- **Matter-of-fact:** "Quick note — 'at the beach,' not 'on the beach.'"
- **Celebratory:** "YES. You nailed 'estar' vs 'ser.' That's a hard one."
- **Empathetic:** "This one trips up literally everyone. You're not alone."
- **Philosophical:** "Try slowing down a bit — it can actually improve both your pronunciation and how well people understand you. Speed ≠ fluency."

### Philosophical/Meta Tips (beyond technical corrections)
Not just grammar and pronunciation — occasional wisdom about the learning process itself:
- "Slowing down can improve both pronunciation AND comprehension. Try it."
- "Making mistakes in real conversations is worth 10x more than getting drills right."
- "If you understood the reply, your message worked — even if it wasn't perfect."
- "Native speakers make grammar mistakes too. Fluency isn't perfection."

These should appear rarely (~1 in 10 messages) and only when contextually relevant.

---

## Personalized Callbacks

### Recurring Mistake Callbacks
- Pattern detected (3+ times): "That sneaky preposition again — 'at the beach' not 'on the beach.'"
- Past mistake corrected: "You got 'estar' right this time — you're building the instinct."

### Milestone Callbacks
After a previously recurring mistake hasn't appeared for 2 weeks:
> "Hey, you haven't mixed up 'ser' and 'estar' in 14 days. That's not luck — that's muscle memory forming. One down."

### Mistake Graduation
When a mistake hasn't occurred in **20 interactions**, it officially "graduates":
> "You've mastered 'ser vs estar.' Graduated from your mistake profile."
- Push notification worthy
- Users will screenshot and share these
- Creates tangible, undeniable progress markers

### Session Callbacks (timing matters)
- "Last session you struggled with X" — OK but can feel like nagging
- "Three weeks ago you couldn't do X, now you can" — POWERFUL
- Rule: **callbacks should reference enough time ago to feel meaningful.** Minimum 1 week gap before referencing a past struggle.

### Stealth Spaced Repetition
The AI secretly reinforces past lessons through natural conversation in Practice Mode:
- User learned "a casa dele" 12 days ago, got it right 2/3 times
- AI steers conversation toward possessives without being obvious
- Intervals: 1 day → 3 → 7 → 14 → 30 days
- If correct → extend interval. If wrong → reset to 1 day.

**Occasional fourth-wall break (1 in 4 times when they get it right):**
> "By the way, you just used 'a casa dele' perfectly. That was giving you trouble two weeks ago."

Not every time — too often feels surveillance-y. Occasionally = proud teacher moment.

### Strategic Tip Selection (not random)
Don't just pick the "most significant" mistake. Use a sophisticated strategy:
1. Check the mistake profile for items currently in spaced repetition
2. Prioritize items that are due for reinforcement based on SRS intervals
3. Track if the user corrected a previous tip — if yes, acknowledge it
4. If no SRS items are due, then pick the most impactful new mistake
5. Over time, systematically work through all weak areas rather than hammering the same one

This is spaced repetition applied to real-time coaching — not just in practice sessions.

---

## Transfer Pattern Library (MOAT)

### What it is
A curated database of the most common transfer errors for each L1→L2 pair:
- English → Portuguese: possessive word order, ser/estar, gender defaults, false cognates
- English → Spanish: ser/estar, subjunctive avoidance, preposition confusion
- English → French: gender agreement, tu/vous register, false cognates
- (etc. for all 40 languages)

### How it's built
1. Start with **researched common mistakes** per language pair (academic sources, teacher forums)
2. Over time, **user-generated data enriches it** — as thousands of users generate corrections, patterns emerge
3. The library feeds into coaching prompts so the AI catches patterns proactively

### Why it's a moat
- Over time: the world's largest real-world database of language transfer patterns
- Valuable for: linguistics research, product improvement, content marketing
- Content marketing goldmine: "We analyzed 1 million voice messages from Portuguese learners. Here are the 10 mistakes every English speaker makes."
- Competitors can't replicate this without the user base generating the data

### Training the model
Feed the transfer library into coaching prompts:
```
TRANSFER PATTERNS FOR ENGLISH → PORTUGUESE:
1. Possessive word order: English "John's house" → Portuguese "a casa do John" (not "do John casa")
2. Ser/Estar confusion: English uses one "to be" → Portuguese distinguishes permanent/temporary
3. Gender default: English has no grammatical gender → Portuguese speakers default to masculine
4. False cognates: "embarazada" ≠ embarrassed, "constipado" ≠ constipated
[etc.]

When the user makes an error matching one of these patterns, acknowledge the transfer:
"I know in English you'd say it this way, but Portuguese flips it..."
```

---

## Scoring System

### 4 Categories (v1)
1. **Pronunciation** — accent, stress patterns, vowel/consonant sounds
2. **Grammar** — conjugation, gender agreement, prepositions, ser/estar
3. **Vocabulary** — range and sophistication of words used
4. **Fluency** — sentence structure, filler words, natural flow, **speaking pace**

### Progressive Unlock
- **Pronunciation:** after 1st voice message
- **Grammar:** after 3 messages
- **Vocabulary:** after 8-10 messages
- **Fluency:** after 8-10 messages

### Level Scale
A1 → A2 → B1 → B2 → C1 → C2 → Native-like

### Data Integrity
**All metrics must be percentage-based, not raw counts.**
- If a user sends twice as many messages one week, their error COUNT goes up but their error RATE may be the same
- Always report: "You used correct gender agreement 78% of the time" not "You made 12 gender mistakes"
- Trends compare rates week-over-week, not totals
- This prevents false signals from variable usage patterns

### Speaking Pace Tracking
Track and coach on speaking speed:
- Words per minute estimate from transcription timing
- Compare to native speaker baselines for the target language
- Tip when too fast: "Try slowing down a bit — it helps both your pronunciation and how well others understand you"
- Track improvement over time

### Language Confidence Index
A single number: what percentage of their communication is in the target language vs English.
- Watch it go from 30% to 70% over months
- **Only shown if they're using both languages** — if English-only, don't show this metric
- The ultimate progress metric for someone living abroad

---

## Reports

### Weekly Report (Tuesday nights)
**Default view (compact):**
- 1 win
- 1 thing to work on
- 1 challenge for the week

**Expanded view (tap to see more):**
- Top 3 things to work on (based on most frequent recent mistakes)
- All wins this week (mistakes stopped, new words, milestones)
- Positive reinforcement
- Overall trend arrow
- Per-category mini-summaries

Tone: "Dude, you've been killing it this week" not "Your score decreased by 3%."

### Monthly Lookback
Once a month, a slightly longer message:
> "One month ago, you were struggling with ser/estar, your pronunciation was at A2, and you'd sent 34 voice messages. Today, ser/estar is almost graduated, your pronunciation is at B1, and you've sent 127 messages. That's not an app talking — that's YOU putting in the work."

Monthly perspective makes the daily grind feel worthwhile.

### Quarterly Mini-Wrapped
A smaller version of Orbit Wrapped at months 3, 6, 9:
- "Your spring check-in"
- 3-4 key stats in shareable card format
- Gives 4 retention moments per year instead of just 1
- Users might churn before an annual wrapped — quarterly catches them sooner

### Orbit Wrapped (Annual)
Shareable year-in-review in **Instagram/TikTok story format** — vertical, swipeable cards:
- Card 1: "You sent 2,847 messages in Portuguese this year"
- Card 2: "Your pronunciation improved 34%"
- Card 3: "You stopped making the ser vs estar mistake in October"
- Card 4: "Your most-used slang: 'tá ligado' (147 times)"
- Card 5: "You graduated from A2 to B1"

Design for the share channel — aspect ratio matters. Not a PDF.

### Exportable Progress Report
A document users can share with their actual language teachers:
- Full profile summary
- Strengths and weak areas
- Specific examples of recurring mistakes
- Progress over time
- Teacher can use this to plan lessons around real gaps

---

## Cultural Landmine System

### Types of Landmines

**Meaning landmines:**
- "estoy excitado" = sexually aroused, not excited
- "embarazada" = pregnant, not embarrassed
- "constipado" (PT) = have a cold, not constipated

**Formality landmines:**
- Using "tu" with someone who expects "usted"
- Calling someone "gorda" as a term of endearment (context-dependent)

**Regional landmines:**
- "Coger" = to grab (Spain) vs vulgar (Latin America)
- Words fine in one country but obscene in another

**False cognate alerts:**
- Build a database of 50-100 most dangerous false cognates per language pair
- This is the most shareable content category

**Gesture/emoji landmines (future):**
- Thumbs up offensive in some Middle Eastern contexts
- OK hand sign vulgar in Brazil

### Contextual Awareness
**Don't assume it's always a mistake.** If someone types "estoy excitado" to their romantic partner, it might be intentional.

Alert format:
> "Heads up — 'excitado' in Spanish usually means sexually aroused, not excited. Did you mean 'emocionado'?"
> [Keep as is] [Change it]

The "Keep as is" option is critical. Respect user intent.

---

## Practice Mode

### Structure
- 5-10 exchanges per session
- 2-hour cooldown (soft override available)
- Session wrap-up with summary

### Contextual & Personal
- Knows city, interests, level, weak spots
- Steers toward relevant real-world scenarios
- Uses interests naturally

### Stealth Spaced Repetition
- Hides SRS inside natural conversation
- Intervals: 1, 3, 7, 14, 30 days
- Occasional acknowledgment (1 in 4 times) when user gets a tested item right

### Rewards
Human acknowledgment, not gamification:
- "You used the subjunctive naturally for the first time today."
- "Three sessions ago you couldn't get through a food order. Today you did."

---

## Monthly Voice Comparison

### Audio Storage Strategy
**Don't store every full message.** Instead:
- When the coach detects the user saying a keyword/phrase for the first time, save **just that 2-3 second clip**
- Build a curated library of pronunciation snapshots per user
- Compare same word/phrase across months

### Privacy
Explicit consent required:
> "Sol saves short clips of your pronunciation to show you your progress over time. We never share these. You can delete them anytime."

### Comparison Logic
- Find matching phrases from early vs recent recordings
- If improved: celebrate
- If no improvement: neutral — "This is a tricky one. Keep at it."
- If no good pair exists: skip that month

---

## Coach Persona

**Name candidates:** Rio, Sol, Kai, Luca

**Branding (phased):**
- v1: Name only, text introduction
- v1.5: Simple avatar/icon
- v2: Full mascot (parrot concept on table)

**Personality:** warm, encouraging, slightly playful, never condescending

### Daily Language Fact (on Coach tab open)
When user opens the Coach tab, show one language fact:
- "70% of English speakers struggle with Portuguese nasal vowels"
- "The word 'saudade' has no direct English translation"
- Different every time

**Concern:** Quality control across 40 languages. Mitigation:
- Curate a library of 50-100 facts per language pair (not AI-generated on the fly)
- Rotate through them
- Mark as "seen" so they don't repeat
- If library runs out, stop showing (don't generate random ones)

---

## Settings & User Control

### Presets (instead of 7 individual toggles)
- **Full Coaching** — everything on
- **Light Coaching** — just cultural alerts and weekly reports
- **Translation Only** — coach off, just the keyboard
- **Custom** — toggle individual features

### Individual Toggles (under Custom)
- Pronunciation tips per audio: on/off
- Grammar tips per audio: on/off
- Pronunciation score per message: on/off
- Confidence score before sending: on/off
- Cultural landmine alerts: on/off
- Practice mode notifications: on/off
- Weekly report: on/off
- Monthly lookback: on/off

### Latency Consideration
Some coaching data (tips, scores) can be delivered asynchronously:
- Tips show in the keyboard immediately after translation
- Detailed analysis goes to the Coach tab (not in-conversation)
- Daily/weekly summaries delivered via push notification or in-app badge
- Never block the conversation flow with heavy processing

---

## Cost Analysis

| Component | Service | Cost per message |
|-----------|---------|-----------------|
| Transcription (EN) | WhisperKit on-device | $0.00 |
| Transcription (other) | Whisper API | ~$0.006/min |
| Translation | DeepL Free API | $0.00 |
| Refinement | GPT-4o-mini | ~$0.00005 |
| Coaching tips | GPT-4o-mini | ~$0.0001 |
| Profile indexing | GPT-4o-mini | ~$0.00015 |
| **Total (EN)** | | **~$0.0003** |
| **Total (other)** | | **~$0.006** |

Heavy user (20 messages/day, mixed EN/target): ~$2-3/month
At $7.99/month: **60-85% gross margin**

---

## Implementation Priority

### Phase 1 (ship first)
1. Per-audio 2 tips (pronunciation/grammar, AI picks)
2. Mistake profile system (stored locally)
3. Native language transfer coaching
4. Per-message pronunciation score (toggleable, introduced after 1 week)
5. Settings presets (Full / Light / Translation Only / Custom)

### Phase 2
1. 4-category scoring with progressive unlock
2. Weekly report (compact + expanded)
3. Practice mode with stealth spaced repetition
4. Coach persona introduction
5. Milestone callbacks + mistake graduation
6. Transfer pattern library (initial research-based version)

### Phase 3
1. Monthly voice comparison (with audio clip storage + consent)
2. Cultural landmine alerts (with false cognate database)
3. Monthly lookback
4. Quarterly mini-wrapped
5. Language Confidence Index
6. Exportable teacher report
7. Daily language facts (curated library)

### Phase 4
1. Orbit Wrapped (annual, shareable story format)
2. Speaking pace tracking
3. Transfer library enrichment from user data
4. Regional landmine database expansion
5. Philosophical/meta coaching tips

---

## Open Items (TBD)
- [ ] Coach persona name — final decision
- [ ] Practice mode conversation prompts
- [ ] Weekly report visual design
- [ ] Orbit Wrapped visual design (Instagram story format)
- [ ] Transfer pattern library — initial research per language pair
- [ ] Audio clip storage architecture + privacy consent flow
- [ ] False cognate database — 50-100 per language pair
- [ ] Language fact library — 50-100 curated facts per language pair
- [ ] Onboarding flow for first-time keyboard users (separate doc needed)
- [ ] Confidence score — scoring rubric relative to user level
- [ ] Prompt design for strategic SRS tip selection
