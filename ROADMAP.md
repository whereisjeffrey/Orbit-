
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

