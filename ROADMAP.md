
## Pricing Structure

**Last reviewed: March 2026**

Four tiers. Each one earns its place.

| Plan | Monthly | Annual | Who it's for |
|------|---------|--------|--------------|
| **Free** | $0 | — | Try-before-you-buy; 15 keyboard translations/day |
| **Founder** | $1.99/mo (locked) | — | Early believers; claimable via honour-system share |
| **Standard / Pro** | $4.99/mo | — | Full access; keyboard + decks + voice |
| **Coach** | $14.99/mo | **$149.99/yr** | Power users who want to actually get better |

### Coach Plan — Billing Design

**Monthly:** $14.99/month, billed after the first 30 days.
- "Pay nothing today, billed $149.99 in 30 days, cancel anytime before then" framing
- StoreKit: auto-renewable subscription with 30-day introductory free period

**Annual:** $149.99/year (= $12.50/month) — 2 months free vs. monthly.
- Default CTA on the Coach plan card
- Framing: "Billed $149.99 after your first 30 days. Cancel anytime."

### Coach Plan — Usage Ceiling (Soft Cap)

**Cap:** 500 coaching analyses per month.

| Usage type | Daily audios | Monthly total | AI cost | Margin |
|---|---|---|---|---|
| Light | 5/day | 150 | ~$1.50 | ~$13.49 (90%) |
| Normal | 20/day | ~400 | ~$4.00 | ~$10.99 (73%) |
| Heavy | 50/day | cap hit day 10 | $5.00 max | ~$9.99 (67%) |
| Extreme | 100+/day | cap hit day 5 | $5.00 max | ~$9.99 (67%) |

**How the soft cap works — not a hard wall:**
When a user hits 500 analyses, the transcript is still cleaned up and sent normally.
They simply don't receive AI coaching feedback for that session.

**Message shown when cap is reached:**
> "You've been putting in serious work today — Coach is recharging and will be back with you shortly. Your message looks great. 🔋"

This turns a ceiling into a flex. Heavy users feel engaged, not punished.

### Founder Plan — Clarification

- Price: **$1.99/month, locked forever** as long as the user remains subscribed
- Claimed via honour system: share with 3 friends + post on social (no proof required)
- Does **not** include Coach features — Coach is a separate, higher tier
- If a Founder user churns and re-subscribes, they re-enter at the prevailing rate

---

## Onboarding: Intent-Based Personalisation (future)

**Trigger:** User selects "Just Arrived" or "Planning to Visit" on the expat status screen.

**Follow-up question:** "How long are you planning to stay?"
- 1–3 months
- 3+ months
- Travelling multiple Mexican cities
- Travelling multiple LatAm countries *(future — requires multi-country platform)*

**What changes downstream based on answer:**

| Intent | Show | Hide |
|--------|------|------|
| 1–3 months | Airbnb tips, cowork, SIM, currency, short-term scam radar | Long-term rental guides, visa/banking bureaucracy |
| 3+ months | Rental guides, banking, visa timelines, long-term community | Short-stay Airbnb focus |
| Multi-city Mexico | City-switcher prominent, per-city Kit content | Single-city neighbourhood deep-dives |
| Multi-LatAm | Country selector, broader platform features | City-specific content |

**Future value unlocked:**
- Visa expiry alerts ("your 180-day FMM window is coming up in 30 days")
- Partner integrations shown only when relevant (Airbnb API vs Inmuebles24/Homie for long stays)
- Community matching by duration ("others here for the same window")
- Personalised Kit ordering (cowork first for short stays, bureaucracy first for long stays)

**AppStorage key to add:** `stay_intent` — enum: short / long / multi_mx / multi_latam


## Profile Photos + Social Link Discovery (future)

### Profile Photos
- Email/password users have no photo — need a profile photo picker
- Google Sign-In already pulls photoURL automatically
- Apple Sign-In does not provide a photo
- Add photo picker (camera + library) in Settings, optional, no prompt
- Placeholder: initials avatar (already in place)

### Social Link Discovery — Two Separate Things

**1. Seeing others' Instagram/LinkedIn → already built, gated behind Pro**
- Pro users unlock blurred social links on community profiles
- The upgrade sheet does the selling — no extra prompt needed

**2. Adding your own Instagram/LinkedIn → separate ask, no gate**
- Purely about being findable by other Pro users
- DO NOT prompt during onboarding — zero context, feels invasive
- DO NOT use time-based nudges — feels like surveillance
- Best mechanic: PULL not PUSH
  - Pro users who can now see everyone else's links will naturally wonder
    "can people see mine?" — Settings satisfies that curiosity
  - No prompt needed — the product creates the question, Settings answers it
- If we ever add a nudge: trigger after first community post only
  ("Nice one. Want people to find you on Instagram? Add your handle in Settings.")
  One time, dismissable, never repeated.

### Key Principle
Never frame social link prompts as verification ("so people know you're real")
— implies the user is currently untrustworthy. Bad first impression.
Frame it purely as discoverability and connection.


## Profile Photos + Social Link Discovery (future)

### Profile Photos
- Email/password users have no photo — need a profile photo picker
- Google Sign-In already pulls photoURL automatically
- Apple Sign-In does not provide a photo
- Add photo picker (camera + library) in Settings, optional, no prompt
- Placeholder: initials avatar (already in place)

### Social Link Discovery — Two Separate Things

**1. Seeing others' Instagram/LinkedIn → already built, gated behind Pro**
- Pro users unlock blurred social links on community profiles
- The upgrade sheet does the selling — no extra prompt needed

**2. Adding your own Instagram/LinkedIn → separate ask, no gate**
- Purely about being findable by other Pro users
- DO NOT prompt during onboarding — zero context, feels invasive
- DO NOT use time-based nudges — feels like surveillance
- Best mechanic: PULL not PUSH
  - Pro users who can now see everyone else's links will naturally wonder
    "can people see mine?" — Settings satisfies that curiosity
  - No prompt needed — the product creates the question, Settings answers it
- If we ever add a nudge: trigger after first community post only
  ("Nice one. Want people to find you on Instagram? Add your handle in Settings.")
  One time, dismissable, never repeated.

### Key Principle
Never frame social link prompts as verification ("so people know you're real")
— implies the user is currently untrustworthy. Bad first impression.
Frame it purely as discoverability and connection.


---

## Outings — Spontaneous City Invitations (future feature)

### What it is
Outings is NOT the same as Events. The distinction:
- **Events** = organized, public, promoted ahead of time (meetup Friday 7pm with RSVP)
- **Outings** = spontaneous, casual, low-commitment invitations between people in the same city right now
  - "I'm heading to the Anthropology Museum Sunday afternoon — DM if you want to join"
  - "Putting together a pub crawl this Friday, message me"
  - "Wine tasting Saturday evening in Condesa, a few spots left"

### Why it's a real differentiator
- Facebook Events = organized, algorithmic, buried
- WhatsApp = already have the group, not for discovery
- Meetup.com = formal, event-centric, not made for expats
- Outings is the spontaneous social layer nobody owns cleanly

### Cold-start problem — THIS IS MORE ACUTE FOR OUTINGS THAN OTHER POST TYPES
Outings are time-sensitive by definition. A question about dentists in Roma Norte is still
valuable 6 months later. An outing posted 3 days ago is dead. This means:
- The bar for "enough users to make Outings feel alive" is **higher** than for the rest of community
- Empty Outings tab = trust-destroying, worse than no tab at all
- **Do NOT ship Outings until a city hits ~500 MAU** — use a feature flag
- When ready, launch with an "Introducing Outings" splash/coach mark

### Rollout gating
- Feature flag: `outings_enabled` (AppStorage or remote config)
- Threshold: 500 MAU in the active city before flipping on
- Below threshold: Outings tab simply does not appear in the filter strip
- At flip: push notification / in-app banner "Introducing Outings — be the first to go somewhere"

### Filter tab order (Community feed chips)
```
All → Questions → Outings → Events → Recs → Warnings
```
Rationale:
- Questions first: highest utility for new arrivals
- Outings second: high energy, social, time-sensitive — put it early
- Events third: organized, slightly more effort to create
- Recs fourth: evergreen, less time-bound
- Warnings last: negative framing at the start sets wrong tone

### Outings icon
- SF Symbol: `figure.walk.circle.fill` or `map.circle.fill` or `building.columns` (museum/city feel)
- Color: warm coral / amber `#FF6B35` to feel spontaneous and warm vs the cooler event purple
- Filter chip emoji: 🏙️ (city skyline)

### Outing post — additional fields
When user selects Outings as post type in ComposePostSheet:
- **Where** (optional free text: venue / neighbourhood)
- **When** (optional: today / tomorrow / this weekend / date picker)
- **How to join** (DM me / comment below / link)
These are optional — don't force structure, keep it casual

### Seed data for mockup (use while feature is in development)
```
"I'm heading to the Anthropology Museum Sunday around 1pm — DM me if you want to join! Great spot to explore for a few hours."
— Alex P., Polanco · today

"Putting together a small pub crawl this Friday: Condesa → Roma → Centro. Meeting at Bar Oriente at 9pm. Message me if you're in."
— Camille F., Condesa · 3h

"Wine tasting at a natural wine bar in Juárez, Saturday evening, ~6pm. 4 people already confirmed, room for 2 more. DM."
— Tom W., Juárez · 5h
```

---

## Community Onboarding — First-Visit Coach Marks

### When to trigger
- NOT during signup flow — user has no context yet
- Trigger on **first time user taps the Community tab** (AppStorage flag: `community_onboarding_seen`)
- Single session, 3 coach marks, then never again

### The 3 coach marks
1. **Filter chips** (highlight the pill row)
   > "Filter by what matters — Questions, Outings, Events and more. Tap any to focus the feed."

2. **WhatsApp Groups pill / Group Directory** (highlight the pill)
   > "Find your people — discover WhatsApp groups for expats in your city."

3. **Composer bar / FAB** (highlight the + button)
   > "Got something to share? Ask a question, post a rec, or start an outing."

### Implementation notes
- Use a dimmed overlay + cutout highlight circle/rect (standard coach mark pattern)
- Each tap advances to next mark; tap outside = dismiss all
- Never repeat. One time, forever.
- Keep copy minimal — one sentence per mark

---

## Phased Growth Rollout Strategy

### The keyboard is the Trojan horse
The keyboard is an immediate, personal-use hook that doesn't depend on other users.
It should be the primary value driver for early subscriptions and beta recruitment.
- Lead with keyboard + Library as the reason to subscribe ($4.99–$7.99/mo)
- Community is the retention driver that compounds over time, not the acquisition hook

### Phase 1 — Keyboard-first (now → ~1,000 paying users)
- Keyboard + Library + DEX as core value
- Community tab visible but clearly early-stage — that's fine, set expectations
- Beta program: invite power users, offer free/discounted access, ask for activity
- Seed content yourself where needed (you become the community for a while — that's normal)
- WhatsApp Group Directory: can launch even at this stage since it's curated by you, not UGC-dependent

### Phase 2 — Community opens city by city (~300 MAU per city)
- Questions, Recs, Warnings, Events fully on
- First-visit coach marks enabled
- Still no Outings

### Phase 3 — Outings flips on per city (~500 MAU per city)
- Feature flag flips city-by-city
- "Introducing Outings" in-app splash moment
- Push notification to city users: "Something new just dropped — check it out"

### Phase 4 — Platform network effects
- Community matching by interest/duration (from onboarding intent data)
- Visa alerts, city-switcher, multi-LatAm expansion (ROADMAP future section above)

---

## Sol Intelligence Roadmap — Personalized Conversations

### Phase 1 — Gemini-seeded local knowledge (building now)
- Gemini Flash API call on onboarding completion → generates 5-7 DEEP local references
  matched to user's city + interests (photography, remote work, nightlife, etc.)
- Each reference includes: what it is, why it's interesting, interest connection,
  what's nearby, 3 conversation hooks — enough depth for 3-4 exchanges per topic
- References stored in user profile as "conversation pool"
- Sol's system prompt reads from pool, uses 1-2 per session
- Background refresh after each Sol session: Gemini sees conversation history,
  generates more references based on what they actually talked about
- Cost: <$0.01/month per user (Gemini Flash)

### Phase 2 — Engagement scoring (~100 users per city)
- Track which references generate high engagement (3+ exchanges) vs low (1 reply, topic change)
- Tag references: high_engagement, low_engagement, user_provided
- Sol prioritizes high-engagement references for new users with similar interests
- User-provided facts (from Sol memory) always rank highest

### Phase 3 — Community intelligence (~500 users per city)
- Conversation pool becomes hybrid: user facts + community-validated references + Gemini fresh
- "70 remote workers in CDMX love Café Nin in Roma Norte" → Sol recommends it to new remote workers
- Community data is aggregated and anonymized — no individual conversations shared
- Sol becomes the collective knowledge of every expat in that city
- New users get day-1 personalization from community data, not just Gemini guesses

### Phase 4 — Cross-city intelligence (~5,000+ total users)
- User moving from CDMX to Medellín? Sol pre-loads Medellín references
  weighted by what similar users (same interests, same origin city) found valuable
- "People who loved Roma Norte in CDMX tend to love El Poblado in Medellín"
- Pre-arrival conversation: "I see you're heading to Medellín — want me to
  switch to Colombian Spanish and start prepping you?"

---

## Lightning Round Roadmap (shelved for v1.1)

### Phase 1 — Database-backed cards
- Generate 500 cards per language using Claude Sonnet (one-time, $1.35/language)
- Auto-audit each card with a second Sonnet call (pass/fail verification)
- Store verified cards in Firebase/local database tagged by: language, category,
  difficulty, specific pattern
- Lightning Round pulls from database — zero API calls at runtime, instant load

### Phase 2 — Personalized hybrid (with revenue)
- Database serves 7-8 cards per round (zero cost)
- Claude Haiku generates 2-3 cards targeting user's specific recent mistakes ($0.0006)
- Total cost per round: <$0.001
- Cards from Haiku get auto-audited and added to database for future users

### Phase 3 — Community card pool
- Cards generated for User A can serve User B (same language, level, mistake category)
- Database grows exponentially with users
- Eventually: zero API calls needed, infinite variety from community pool

### Beta recruitment script (for reference)
> "We're building the expat companion app for Mexico City. The keyboard alone is worth it —
> but we're also building the best community layer for expats and we need activity.
> In exchange for [free access / deep discount], we'd love you to be active in the feed.
> Totally organic — just post what you'd actually post. We'll let you know when Outings is ready."
