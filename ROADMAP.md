
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

**1. Seeing others Instagram/LinkedIn → already built, gated behind Pro**
- Pro users unlock blurred social links on community profiles
- The upgrade sheet does the selling — no extra prompt needed

**2. Adding your own Instagram/LinkedIn → separate ask, no gate**
- This is purely about being findable by other Pro users
- DO NOT prompt during onboarding — zero context, feels invasive
- DO NOT use time-based nudges — feels like surveillance
- Best mechanic: PULL not PUSH
  - Pro users who can now see everyone elses links will naturally wonder
    "can people see mine?" — Settings satisfies that curiosity
  - No prompt needed — the product creates the question, Settings answers it
- If we ever add a nudge: trigger it contextually after first community post
  ("Nice one. Want people to find you on Instagram? Add your handle in Settings.")
  — one time only, dismissable, never repeated

### Key Principle
Never frame social link prompts as verification ("so people know youre real")
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
