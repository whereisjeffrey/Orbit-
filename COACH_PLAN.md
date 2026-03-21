# Orbit Coach — Product Plan
> Written: 2026-03-20
> Status: Pre-implementation brainstorm — approved directions only

---

## Product Philosophy

**Orbit is not a language learning app. It's a language living app.**

The user doesn't open Orbit to study. They open WhatsApp to text their landlord, flirt with someone, or order food. Orbit lives inside that flow and makes them better without them trying.

Every feature must pass this test: **"Would a busy expat in Mexico City actually want this interrupting their Tuesday?"**

Core brand principle: **"Language in the Wild."**

---

## Pricing Tiers

### Orbit Free
- **30 full-featured messages per month** (typed or voice — no distinction)
- Full experience: slang tones, notes, corrections, voice translate — everything
- After 30 messages: basic DeepL translation only (no refinement, no notes, no coach)
- Users still get value (basic translation), still open the app daily, but miss the magic

**Why 30:** Enough to fall in love across several days. Not enough to live on. Basic translation after the limit keeps them engaged without making them feel abandoned.

### Orbit Pro — $7.99/month ($59.99/year)
- Unlimited everything: messages, voice, all tones, coach, weekly reports, practice mode
- Single tier — no feature gating between paid levels
- Annual option shown prominently: "$5/month — save 37%"

**Why one paid tier:** Audio transcription is now on-device (WhisperKit) = $0.00 cost. GPT-4o-mini calls for coaching/refinement = ~$0.0003 per message. Even a power user costs <$0.50/month. Margins are 85-95%. No reason to gate features into a higher tier.

**Why $7.99:** Sweet spot for productivity apps targeting higher-income users. Impulse-purchase friendly. Same as Duolingo. The value prop is stronger: "For less than the cost of one language lesson, get a full-time coach for a month."

---

## Coach Feature — Core Loop

### Per-Audio Coaching (passive, background)
Every voice message gets a maximum of **2 tips**. The prompt chooses the 2 most impactful — could be:
- 2 pronunciation tips
- 2 grammar tips
- 1 of each

No hard rule on the split. Let the AI pick what matters most for that specific message.

Never more than 2. Users are busy — this is about drip-feeding improvement, not overwhelming.

### Per-Message Pronunciation Score (toggleable)
Each voice message gets a pronunciation score (0-100) displayed as a small badge.
- **Per message** (not daily) — so users can pinpoint exactly which message had issues
- A score of 99 = "you're good, move on." A score of 62 = "something in here needs attention, read the tips"
- Daily aggregate scores were considered but rejected — they confuse users when scores fluctuate day-to-day without clear reasons
- **Settings options:** Per message / Off (default: per message for Coach users)
- Introduced via onboarding so users know it's optional

### Emotional Variety in Coaching
The prompt must vary its emotional tone across tips. Never robotic, never the same voice twice in a row:
- Sometimes **playful:** "There's that sneaky preposition again!"
- Sometimes **matter-of-fact:** "Quick note — 'at the beach,' not 'on the beach.'"
- Sometimes **celebratory:** "YES. You nailed 'estar' vs 'ser.' That's a hard one."
- Sometimes **empathetic:** "This one trips up literally everyone. You're not alone."

This variety is what makes it feel like a real friend/teacher, not a bot.

### Personalized Callbacks
The coach tracks recurring mistakes and calls them out with empathy:
- Pattern detected (same mistake 3+ times): "That sneaky preposition again — 'at the beach' not 'on the beach.' You're getting closer."
- Past mistake corrected: "You got 'estar' right this time — you're building the instinct."
- Callback to earlier practice sessions: "Remember our conversation about ordering at the taqueria? You just used 'me gustaría' naturally — that's growth."

### Milestone Callbacks
After the coach detects that a previously recurring mistake hasn't appeared for 2 weeks:
> "Hey, you haven't mixed up 'ser' and 'estar' in 14 days. That's not luck — that's muscle memory forming. One down."

This is critical for retention. It gives people concrete, undeniable evidence of progress. Most language learners can't feel their own improvement — this makes it visible.

### Native Language Transfer Coaching
When users make errors that stem from directly translating structures from English:
- Identify the English pattern they're applying
- Explain why the target language does it differently
- Be empathetic: acknowledge their instinct makes sense in English
- Example: "I know in English you'd say 'Eli's house,' but in Portuguese it flips — 'a casa dele.' The possession word comes after, not before. Tricky but you'll get it."

### Mistake Profile System
Stored locally (App Group UserDefaults or JSON blob). Tracks per user:
- Categorized mistakes with frequency and recency
- Pattern detection (e.g., "defaults to masculine articles")
- Improvement tracking (mistakes that stopped occurring)
- Timestamps for spaced repetition scheduling

Profile is sent as context (~200 tokens) with each coaching API call. Example:
```
GENDER AGREEMENT: weak (7 errors in 2 weeks, mostly masculine default)
PREPOSITIONS: moderate (4 errors, en/a confusion for direction)
SER vs ESTAR: weak (5 errors, especially with locations)
CONJUGATION: strong (1 error in 2 weeks)
PRONUNCIATION: moderate (drops final 's' sounds frequently)
```

---

## Scoring System

### 4 Categories (v1)
1. **Pronunciation** — accent, stress patterns, vowel/consonant sounds
2. **Grammar** — conjugation, gender agreement, prepositions, ser/estar
3. **Vocabulary** — range and sophistication of words used
4. **Fluency** — sentence structure, filler words, natural flow

Sub-categories (conjugation, gender, prepositions, register) live as drill-downs inside Grammar. Keeps the UI clean.

### Progressive Unlock
Categories unlock as the user provides more audio data:
- **Pronunciation:** unlocks after **1st voice message** (rough initial score)
- **Grammar:** unlocks after **3 voice messages**
- **Vocabulary:** unlocks after **8-10 voice messages**
- **Fluency:** unlocks after **8-10 voice messages**

Each unlock is a small celebration: "You just unlocked your Grammar score!"

Below the active gauges, show locked categories: "3 more insights unlock as you send more voice messages" — teases without overwhelming.

### Level Scale
A1 → A2 → B1 → B2 → C1 → C2 → Native-like

Half-circle gauge (speedometer style) per category. Even C2 speakers get value — catches fossilized errors, regional pronunciation quirks.

Scores refine over time as more data is collected. Initial scores are clearly marked as preliminary.

---

## Weekly Report (Tuesday nights)

Short, human-feeling summary. Not a report card — a friend checking in.

Contents:
- **Top 3 things to work on** (based on most frequent recent mistakes)
- **Wins this week** (mistakes you stopped making, new words/phrases used)
- **Positive reinforcement** for improvements
- **One challenge for the week** (based on weakest category)
- **Overall trend** (improving / plateau / new challenge area)

Tone: encouraging, never judgmental. "Dude, you've been killing it this week" not "Your score decreased by 3%."

---

## Practice Mode

### Philosophy
Short, contextual conversation sessions with an AI that knows your city, interests, mistakes, and progress. Not a chatbot — a coach drill disguised as a casual conversation.

### Structure
- **5-10 exchanges per session** (message count, not time)
- Session ends with a wrap-up: "Good session. You nailed the subjunctive today. Go use it in a real conversation."
- **2-hour cooldown** before next session (soft — user can override with "Start anyway")
- No marathon sessions — prevents becoming "just another chatbot app"

### Contextual & Personal
- Knows user's city, interests, level, and current weak spots
- Steers conversation toward relevant real-world scenarios: "You're in CDMX — have you tried ordering at a taquería without switching to English? Let's practice."
- Uses interests naturally: if user likes football, the AI might bring up last night's match — in the target language

### Stealth Spaced Repetition
The AI secretly reinforces past lessons through natural conversation:
- User learned "a casa dele" 12 days ago, got it right 2/3 times
- AI steers conversation toward possessives: "Tell me about your friend's apartment"
- If user gets it right → extend interval (1 day → 3 → 7 → 14 → 30)
- If wrong again → reset to 1 day

This is invisible to the user. They think they're chatting. The AI is strategically testing and reinforcing.

### Callbacks to Previous Sessions
- "Last time we practiced ordering food, you struggled with 'me gustaría.' How about we try it again?"
- Makes the AI feel like a real teacher who remembers your journey
- Reinforces that this is a relationship, not a random chatbot

### Rewards
No badges, streaks, or gamification. Instead, human acknowledgment:
- "You used the subjunctive naturally for the first time today. That's a big deal."
- "Three sessions ago you couldn't get through a food order without switching to English. Today you did the whole thing."

---

## Coach Persona

The coach has a name and personality. Introduces itself during onboarding:

> "Hey, I'm [Name]. I'll be in the background watching your messages and giving you tips as you go. Don't worry, I'm chill — I won't interrupt every message. But when I notice something, I'll let you know."

**Name candidates:** Rio, Sol, Kai, Luca (warm, gender-neutral, works across cultures)

**Branding strategy (phased):**
- v1: Name only, text-based introduction. No mascot, no illustrations. Zero branding cost.
- v1.5: If users love the coach, add a simple avatar/icon (parrot concept on the table)
- v2: If brand is proven, full mascot with illustrated states. Invest in branding assets only after validation.

**Characteristics:**
- Personality: warm, encouraging, slightly playful, never condescending
- Knows when to back off (respects "don't show me this again")
- Feels like a friend who happens to be fluent, not a teacher grading you

---

## Additional Features

### Confidence Score (toggleable)
Before tapping "Replace" to insert a message, show a small badge: "Sounds 87% native."
- Creates addictive micro-feedback loop
- Users rephrase to beat their own score (learning without realizing)
- **Must be toggleable** — some users won't want this in every conversation
- Introduced as an opt-in feature so users know they can turn it off

### Cultural Landmine Alerts
Flag phrases that are grammatically correct but culturally wrong:
- "estoy excitado" (means "I'm sexually aroused" not "I'm excited")
- Contextual warnings before sending
- Viral potential — users will screenshot and share these saves
- Includes native language transfer warnings (English patterns that don't work)

### Monthly Voice Comparison ("Your Voice is Changing")
Once per month, find matching phrases from early recordings vs recent ones.
- Same word/phrase, natural comparison
- If improved: celebrate it
- If no improvement: neutral framing — "This is a tricky one. Keep at it."
- If no good comparison pair exists: skip that month (never force it)
- Always positively reinforcing — filter for moments of growth

### Orbit Wrapped (Annual)
Shareable year-in-review card (like Spotify Wrapped):
- "You sent 2,847 messages in Portuguese this year"
- "Your pronunciation improved 34%"
- "You stopped making the 'ser vs estar' mistake in October"
- "Your most-used slang: 'tá ligado' (147 times)"
- "You graduated from A2 to B1"

Zero cost to generate (aggregated profile data). Highest-virality feature possible. Free marketing when users share on social media.

### Streak Without Guilt
Track "active weeks" not daily streaks:
- Send at least one voice message this week → you're on streak
- Miss a week? No guilt trip: "Welcome back. Here's what's changed since you've been gone."
- Expats travel, get busy. Punishing them for living their life is anti-brand.

---

## Settings & User Control

All coach features individually toggleable:
- Pronunciation tips per audio: on/off
- Grammar tips per audio: on/off
- Confidence score before sending: on/off
- Cultural landmine alerts: on/off
- Practice mode notifications: on/off
- Weekly report: on/off

Master toggle: "Coach Mode" on/off (disables all coaching, keeps translation)

Any in-flow prompt has a subtle "x" or "Don't show" option. Respect that some users just want translations.

---

## Cost Analysis

| Component | Service | Cost per message |
|-----------|---------|-----------------|
| Transcription | WhisperKit (on-device) | $0.00 |
| Translation | DeepL Free API | $0.00 |
| Refinement | GPT-4o-mini | ~$0.00005 |
| Pronunciation + grammar tip | GPT-4o-mini | ~$0.0001 |
| Profile indexing | GPT-4o-mini | ~$0.00015 |
| **Total** | | **~$0.0003** |

Heavy user (20 audio messages/day): ~$0.18/month
At $7.99/month: **85-95% gross margin**

TTS playback: Using Apple's AVSpeechSynthesizer with Premium/Enhanced voices (on-device, $0.00). Code already selects best available voice. Nudge banner prompts users to download enhanced voices if not installed.

---

## Implementation Priority

### Phase 1 (next 2-3 sessions)
1. Per-audio pronunciation tip + grammar tip
2. Mistake profile system (stored locally, indexed per message)
3. Native language transfer coaching (English → target language pattern detection)
4. Confidence score badge (toggleable)
5. Settings toggles for all coach features

### Phase 2
1. 4-category scoring with progressive unlock
2. Weekly report (Tuesday nights)
3. Practice mode (5-10 exchange sessions with spaced repetition)
4. Coach persona (name, personality, onboarding introduction)

### Phase 3
1. Monthly voice comparison
2. Cultural landmine alerts
3. Orbit Wrapped (annual)
4. Streak tracking (weekly, no guilt)

---

## Open Items (TBD)
- [ ] Coach persona name and characteristics
- [ ] Practice mode: exact conversation prompts and personality
- [ ] Weekly report: visual design and delivery mechanism (push notification? in-app?)
- [ ] Orbit Wrapped: visual design and sharing format
- [ ] DeepL free tier limits: monitor usage, plan upgrade trigger
