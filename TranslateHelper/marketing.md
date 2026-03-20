# Orbit — Marketing Strategy

> **Purpose:** Private working doc. Checklist + strategy for getting the keyboard into people's hands.
> **North Star:** Get the keyboard spreading organically worldwide before any regional/community rollout.

---

## The Two Pillars

| 📣 The Megaphone | 💬 The Conversation |
|---|---|
| Getting eyeballs on the product | Making those eyeballs tell their friends |
| Outbound — press, social, Reddit, video | In-app — pricing unlocks, referrals, ratings |
| We push the message out | The product pulls people in |

---

## 📣 Part 1: The Megaphone

*Tactics to get the keyboard in front of strangers.*

---

### 1. Reddit (Free, High ROI)

**Target communities:**

| Subreddit | Why it fits |
|---|---|
| r/keyboards | Hardware nerds love novel input methods |
| r/languagelearning | Core audience — learning a language is the whole point |
| r/polyglot | Power users who will become evangelists |
| r/LearnSpanish, r/LearnJapanese, etc. | Language-specific communities for each supported language |
| r/productivity | The "type in English, send in Spanish" use case is a productivity win |
| r/iphone / r/apple | iOS keyboard = native audience |

**How to post well:**
- Lead with the demo, not the pitch. "I built a keyboard that auto-translates in real-time" + a screen recording.
- Be the builder. "I've been working on this for X months, would love feedback."
- Don't link first. Post the video/gif first, drop the App Store link only in comments.
- Engage every reply for the first 2–3 hours. Reddit rewards engagement velocity.

**Agent automation opportunity:**
> An AI agent can monitor these subreddits daily for posts like "best translation app," "keyboard for learning Spanish," "how do I type in another language on iPhone" and flag them for you to reply to manually — or draft a reply for your approval. Tools: `PRAW` (Python Reddit API) + a simple LLM prompt.

---

### 2. Short-Form Video (Highest Viral Ceiling)

**Platform priority:** TikTok → Instagram Reels → YouTube Shorts

**The hook that works:**
> *"Watch me send a text in Spanish without knowing a single word."* [shows typing in English, keyboard auto-translates, hits send]

**Video ideas:**

- **The 30-second demo** — Type in English, output appears in Spanish/Japanese/etc. No talking needed.
- **"I used this keyboard for a week in Mexico"** — Travel + language = massive engagement.
- **POV: You're texting your girlfriend's family in her language** — Emotional, shareable.
- **"How I learned 50 words without studying"** — Positions the flashcard side of the app.
- **Side-by-side with Google Translate** — Shows the keyboard advantage (in-line, no switching apps).

**Tips:**
- You don't need perfect production. Screen-record directly on iPhone + voiceover wins on TikTok.
- Post 3–5 times before judging. Algorithms need ramp-up.
- If one video gets traction, make 3 variations immediately. Ride the wave.

**Agent automation opportunity:**
> An agent can scrape trending audio/sounds on TikTok in the "language learning" niche and suggest content angles to match trending formats. Also can track comment sentiment on your videos and surface questions to turn into future videos.

---

### 3. ProductHunt Launch

**Best for:** One-time spike in tech-early-adopter users + press pickups.

**How to maximize it:**
- Launch on a **Tuesday or Wednesday** — highest traffic days.
- Line up 20–30 people to upvote and comment in the first hour. Quality comments beat raw votes.
- Write a compelling maker post: the "why I built this" story is more important than features.
- Offer a PH-exclusive promo (free first month, locked-in low price) — ties directly into pricing strategy below.
- Respond to every comment on launch day.

**What to expect:** 200–2,000 new signups depending on placement. Even #5 on the day moves the needle.

---

### 4. Language-Learning YouTubers

**Why this works:** Their audience is *already* motivated to learn languages and buy tools. A mid-size creator (50K–500K subscribers) in this niche converts better than a 5M tech channel.

**Target creator types:**

- Polyglot vloggers (people documenting their language-learning journey)
- "Learn X in Y days" challenge creators
- Expat/travel YouTubers in Spanish-speaking countries
- Teachers who post lesson content

**Outreach approach:**
- Don't pitch via generic contact forms. Find their personal email (often in About section or Linktree), or DM on Instagram.
- Subject line: *"Free app for your audience — real-time translation keyboard"*
- Offer: Free Pro access for them + a discount code to share with their audience.
- Keep it to 3 sentences. They get pitches all day.

**Agent automation opportunity:**
> An agent can search YouTube for channels in the language-learning niche, filter by subscriber count and recent upload frequency, scrape contact info from About pages and Linktrees, and output a prioritized outreach list. You still write the actual emails, but the list-building is fully automatable.

---

### 5. Press Outreach

**Targets:**

| Publication | Angle |
|---|---|
| 9to5Mac | "New iOS keyboard uses AI to auto-translate as you type" |
| MacRumors | Same — they cover App Store novelties |
| The Verge | "This keyboard could change how bilingual families text" |
| TechCrunch | AI-powered language tool angle |
| Language-specific blogs | "The best tools for learning Spanish in 2026" roundups |

**Press kit essentials:**
- 30-second demo video (no watermarks)
- 3–4 high-res screenshots
- 1-paragraph "what it does" + 1-paragraph "why it matters"
- Your email + availability for a quick call

**Agent automation opportunity:**
> An agent can monitor tech news RSS feeds and journalist Twitter/X accounts for coverage of "language apps" or "iOS keyboards," identify writers who cover this beat, and surface their recent articles + contact info. Personalizing outreach to what they *just* wrote about dramatically increases reply rates.

---

### 6. App Store Optimization (ASO)

This is passive, ongoing marketing — get it right once and it compounds forever.

**Target keywords:**
- `translator keyboard`
- `real-time translation keyboard`
- `AI keyboard translator`
- `type in Spanish keyboard`
- `language learning keyboard`
- `keyboard auto translate`

**Tips:**
- First screenshot should show the keyboard in action with translated text visible — no words needed.
- App title: include your most important keyword (e.g., "wandr — AI Translator Keyboard")
- Subtitle: "Type in any language, instantly"
- Ratings are a ranking signal — see The Conversation section for how to drive these.

---

## 💬 Part 2: The Conversation

*Making users do the marketing for you.*

---

### 1. Pricing — The Unlock Model

**Four tiers. Each one earns its place.**

| Plan | Monthly | Annual | CTA |
|------|---------|--------|-----|
| **Free** | $0 | — | Continue for Free |
| **Founder** | $1.99/mo locked | — | Claim Founding Price ✨ |
| **Standard / Pro** | $4.99/mo | — | Get Standard |
| **Coach** | $14.99/mo | $149.99/yr | Try Coach Free for 30 Days |

**Founder — The Unlock:**
```
Standard Price:   $4.99/month

─────────────────────────────────────────
✨ Lock in our Founding Price
   $1.99/month — forever
─────────────────────────────────────────
   To claim this price:
   • Share wandr with 3 friends, AND
   • Post about it on social media

   [Claim Founding Price]   [Pay Full Price]
```

**The honor system:**
- Do **not** ask for proof. No screenshots, no confirmation links.
- The CTA language should feel like an invitation, not a contract.
- Asking for proof signals distrust. Trusting them signals you're a brand that respects its users.
- Rough math: even if 40% actually share it, that's 40% of your base doing free marketing.

**Coach — The Premium Tier:**
- $14.99/month or **$149.99/year** (2 months free — the standard playbook, clean and easy to communicate)
- 30-day free period upfront: "Pay nothing today, billed $149.99 in 30 days, cancel anytime"
  - This is stronger than a free trial psychologically — users have skin in the game
  - Apple StoreKit supports this natively with introductory offer periods
- **500 coaching analyses/month soft cap** — at $0.01/analysis, max AI cost is $5.00, margin is 67% at worst
- When the cap is reached: transcript still sends normally, coaching feedback gracefully paused
  > "You've been putting in serious work today — Coach is recharging and will be back with you shortly. 🔋"
- In practice: a normal user (20 audios/day) hits ~400/month — comfortably under the cap, extra margin left on the table

---

### 2. Early Adopter Grandfathering — Suggested Language

When a user claims the founding price, show a confirmation screen:

---

> **You're in. Welcome, founder.**
>
> Your $1.99/month rate is locked in — for life. No matter what wandr becomes, this is your price. Always.
>
> We're early, we're scrappy, and we're building something we genuinely believe in. If wandr ever makes your day a little easier — helps you connect with someone in their language, gets a laugh from a friend, saves you an awkward moment — that's everything to us.
>
> If you feel like telling someone about it, we'd love that. But no pressure. We're just glad you're here.

---

**Why this tone works:**
- It's human, not corporate.
- "For life" creates real perceived value — this isn't a promo, it's a standing commitment.
- The last paragraph plants the seed for sharing without any obligation or desperation.

---

### 3. App Store Rating Prompt

**Timing is everything.** Don't ask on first launch. Don't ask randomly.

**Optimal trigger:**
- User has opened the app **5+ times** AND
- It has been at least **10 days** since install AND
- They just completed a positive action (finished a study session, sent a phrase, hit a streak milestone)

**Flow:**
1. Show a soft "Are you enjoying wandr?" card (Yes / Not Really)
2. If **Yes** → trigger Apple's native `SKStoreReviewRequest`
3. If **Not Really** → show a feedback form (email or text field) — capture the issue, do **not** send them to the App Store to vent

> Apple's native rating prompt can only be shown **3 times per year** per user. Use them on the highest-signal moments only.

---

### 4. In-App Referral Flow

**Simple referral mechanics:**
- Every user gets a personal referral link (`wandr.app/join/username`)
- Share button lives in Settings; also surfaces after a streak milestone or positive moment
- When a referred user downloads and creates an account: both users get **1 week of Pro free**

**Pre-written share copy (paste into share sheet):**
> *"I've been using this keyboard that translates as I type — it's kind of wild. Try it free: [link]"*

Pre-written copy is key. Most people won't write their own message — removing that friction is the difference between a share and an abandon.

**Agent automation opportunity:**
> An agent monitors referral conversions and fires a personalized push when their link converts: *"Your link just got someone new on wandr 🎉"* — personalized affirmation outperforms generic reward pings.

---

### 5. Social Share at "Magic Moments"

Identify the moments in the app where the user feels something. Then ask them to share *at that exact moment*.

**Magic moments in wandr:**

| Moment | Trigger | Suggested copy |
|---|---|---|
| First keyboard translation sent | After first successful keyboard use | *"You just typed in English and sent it in Spanish. That feeling? That's wandr."* |
| 7-day streak | Streak milestone card appears | *"7 days in a row. You're actually doing this."* |
| 100 phrases learned | Milestone reached | *"100 phrases. That's not an app anymore — that's a habit."* |

Each of these moments gets a `[Share this moment]` button. The copy is already written — they just tap.

---

## 🗓️ Launch Checklist

### Product
- [ ] Finalize pricing tiers + founding price flow in app
- [ ] Implement App Store rating prompt trigger logic
- [ ] Implement referral link system
- [ ] Write founding price confirmation screen copy
- [ ] Set up social share flows for magic moments

### Content
- [ ] Record 30-second keyboard demo video (no talking version)
- [ ] Record 60-second "story" version with voiceover
- [ ] Write press kit (1 page: what it does + why it matters + screenshots)
- [ ] Draft subreddit post copy (3 versions for different communities)

### Outreach
- [ ] Set up ProductHunt page + find hunters to support launch
- [ ] Build YouTuber outreach list (target: 20 creators, 50K–500K subs)
- [ ] Send first 5 press pitches
- [ ] Optimize ASO keywords + screenshots

---

*Last updated: March 2026*
