# Orbit — Pricing & Trial Spec
> Last updated: 2026-04-09

---

## Pricing

| Plan | Price |
|------|-------|
| Monthly | $5.99/mo |
| Annual | $49.99/yr (save 30%) |

---

## 14-Day Free Trial (No Credit Card)

Full access for 14 days from install date. No StoreKit, no payment info collected.

### Trial Timeline

| Day | Action |
|-----|--------|
| 1 | Onboarding screen: "Full experience free for 14 days. No credit card. No surprises." |
| 1-10 | Silent. No reminders. Let the product build the habit. |
| 11 | Gentle banner: "3 days left — you've saved X words and had Y conversations with Sol" |
| 13 | Warmer: "Your full access ends tomorrow. Your saved words and progress stay — upgrade anytime." |
| 14 | Lock to free tier. First time they hit a locked feature, show upgrade prompt with their personal usage stats. |

### Key Principles
- Tell them upfront — no surprises, ever
- Show their own usage data in upgrade prompts ("You used Orbit 83 times in 2 weeks")
- Nothing gets deleted — locked, not lost
- "Maybe later" is always an option — no hard sell
- Free tier is genuinely useful — they choose to level up, not forced

### Implementation
- Store `install_date` on first launch (App Group so keyboard can read it)
- `Date() - install_date < 14 days` → full access
- No StoreKit until user actively chooses to subscribe

---

## Free vs Pro Feature Matrix

| Feature | Free | Pro |
|---------|------|-----|
| **KEYBOARD** | | |
| Translations | 100/week | Unlimited |
| Tones (casual/slang/flirty/work) | All 4 | All 4 |
| Wingman mode | Locked | Unlocked |
| Smart coaching notes | Hidden | Shown |
| Geographic DNA labels | Hidden | Shown |
| Save words from keyboard | Locked | Unlocked |
| **SOL (COACH)** | | |
| Conversations | 3/day | Unlimited |
| Save words from Sol | Locked | Unlocked |
| Session summaries | Locked | Unlocked |
| **LEARN** | | |
| Clipboard / saved phrases | View only | Full access |
| Study cards (review/SRS) | Locked | Unlocked |
| AI deck generation | Locked | Unlocked |
| Target areas / mistake tracking | Locked | Unlocked |
| **OTHER** | | |
| Community messaging | Locked | Unlocked |
| Weekly streak tracking | Free | Free |
| Onboarding | Free | Free |

---

## What Counts as a Translation

| Action | Counts? |
|--------|---------|
| Type/speak → translate → browse tones/versions | No |
| Tap **Replace** (drops translation into chat) | **Yes — 1 translation** |
| Paste incoming message → translation appears | **Yes — 1 translation** |
| Swipe for version 2, 3, etc. | No |
| Switch tone on same message | No |

### Weekly Counter
- Track `keyboard_translations_this_week` + `keyboard_week_start` in App Group
- Increment on Replace tap (outgoing) or translation display (incoming paste)
- Reset every Monday (calendar week)
- When counter hits 100: show upgrade prompt instead of translating

---

## Conversion Pressure Points

1. **Mid-week keyboard wall** — heavy user hits 100 on Wed/Thu. 3-4 days of Google Translate dance.
2. **Can't save anything** — every "Save" button on free tier shows upgrade prompt.
3. **Sol daily limit** — 3 conversations enough to get hooked. 4th attempt shows upgrade.
4. **Notes/DNA hidden** — translation works but they miss the "why."
5. **Study locked** — clipboard becomes a teaser they can see but can't use.

---

## Competitive Positioning

Orbit is NOT a language learning app. It's a **daily-use convenience tool that teaches you as you go**.

- Google Translate: free but robotic, requires app switching
- Gboard translate: in-keyboard but no local slang, no learning
- Duolingo: teaches but not useful in real conversations
- **Orbit: translates like a local AND teaches you — right inside WhatsApp**

The keyboard is the hook (beats Google Translate on quality).
The learning layer is the upgrade (nobody else has it).
You're not charging for translation — you're charging for **growth**.

---

## Target Market & Acquisition

### Primary: US expats in Latin America
- 800K+ Americans in Mexico alone
- Target: US App Store + current location in Mexico/Colombia/Brazil/etc.
- Language: English-dominant users in Spanish/Portuguese-speaking countries

### Meta Ads Targeting
1. Location: Living in → Mexico (or target country)
2. Age: 20-50
3. Language: English (US)
4. Interests: WhatsApp, Expatriate, Remote work, Travel
5. Exclude: Native Spanish speakers

### Expected Unit Economics
- CAC: $15-40 per paying subscriber
- LTV at $5.99/mo (3% churn): ~$198
- LTV at $49.99/yr (70% renewal): ~$165
- ROI: 4-5x at midrange CAC

---

*This spec is a planning document. Implementation pending Jeffrey's final review.*
