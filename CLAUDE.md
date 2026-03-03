# CLAUDE.md — TranslateHelper / TalkSwitch

> Read this file every session before touching any code. It is the single source of truth.

---

## Product Vision

TalkSwitch is a language learning ecosystem built around **real conversation**, not artificial exercises.

- **Keyboard extension** (TalkSwitch): Lives inside WhatsApp and other messaging apps. Translates in real time between English and Spanish (Portuguese and other languages coming in future versions). Captures phrases from real conversations.
- **Main app**: Language learning platform. Users study phrases captured from real conversations via flashcards, track progress, and build vocabulary from words they actually use.

**Core insight**: Duolingo teaches you "the cat is on the table." TalkSwitch teaches you what you actually say to real people. The keyboard is the capture layer. The app is the study layer.

---

## Current State (as of March 2026)

### Keyboard Extension — DONE (MVP)
- EN ↔ ES translation via DeepL (primary) + OpenAI gpt-4o-mini (slang/tone refinement)
- Auto-translate on text change (1.8s debounce timer)
- Swipe-to-regenerate alternative translations (Tinder-style, rightward pan)
- Tone selector: Casual / Flirty / Culture / Family
- Language pill (🇲🇽 ES / 🇺🇸 EN) — persists across sessions via UserDefaults
- `PrimaryLanguage = mul` in keyboard plist (supports all languages)
- Input/output card layout + notes card for context
- Speaker button with Apple Enhanced/Premium voice support

### Main App — TO BUILD
All screens designed in Google Stitch. Implementation order below.

### Known Architecture Decisions (do NOT relitigate these)
- Native iOS mic handles recording — keyboard extension process cannot access microphone (OS blocks it even with Full Access). Do not add DictateVC/URL scheme complexity.
- User controls recording start/stop via mic button tap — no auto-silence detection (people pause to think, especially in a second language)
- `textDidChange` auto-translate: 1.8s debounce after last keystroke
- Swipe-to-regenerate uses `UIPanGestureRecognizer`, not `UISwipeGestureRecognizer` (needs drag distance for animation)

---

## Tech Stack

| Layer | Technology |
|---|---|
| iOS Native | Swift / SwiftUI (new screens) + UIKit (keyboard extension) |
| Keyboard Extension | UIKit — `UIInputViewController` subclass |
| Backend | Firebase (Auth + Firestore) |
| Translation | DeepL API (primary), OpenAI gpt-4o-mini (refinement) |
| TTS | AVSpeechSynthesizer (Apple Enhanced/Premium voices) |
| Inter-process | App Group: `group.com.jeff.translatehelper` |

---

## Bundle IDs & Identifiers

- Main app: `com.jeffrey.TranslateHelper`
- Keyboard extension: `com.jeffrey.TranslateHelper.Keyboard`
- App Group: `group.com.jeff.translatehelper`
- URL scheme: `translatehelper://` (in main app Info.plist)

---

## Project Structure

```
TranslateHelper/
├── CLAUDE.md                          ← you are here
├── Config.swift                       ← API keys (gitignored — never commit keys)
├── TranslateHelper/                   ← Main app
│   ├── DictateViewController.swift    ← Voice recording (sequential pt-BR → en-US)
│   └── Assets.xcassets/
│       └── AppIcon.appiconset/        ← TalkSwitch icon
└── TranslateHelperKeyboard/           ← Keyboard extension
    ├── KeyboardViewController.swift   ← ALL keyboard UI + translation logic (~1300 lines)
    ├── Services/
    │   ├── TalkSwitchAPI.swift        ← DeepL + OpenAI API calls
    │   └── SpeechService.swift        ← TTS (speaker button)
    └── Assets.xcassets/
        └── TalkSwitchLogo.imageset/
```

---

## Screen Inventory (implement in this order)

### Auth Flow
1. **Sign In** — Email/password, Google+Apple social login, link to Create Account
2. **Create Account** — Full name, email, password, Terms agreement
3. **Forgot Password** — Email input → Send Reset Link
4. **Check Your Email** — Confirmation screen after reset link sent

### Onboarding Flow (new users only, shown once)
5. **Language Selection** — **Spanish (ES) is the default pre-selected language for v1 launch.** Other languages (PT, FR, DE, IT, JA, KO) are shown but dimmed with a "Coming Soon" badge. Users cannot select them.
6. **Learning Goal** — Select all that apply: Travel ✈️, Work 💼, Casual 👕, Flirty 💃, Culture 🎭, Family 👨‍👩‍👧
7. **Plan Selection** — Pro $9.99/mo (Unlimited phrases, AI coaching, offline) vs Free (10/day, basic)

### Core App
8. **Library** — Deck list, search, My Clipboard section, daily goal tracker, bottom nav
9. **Study Mode** — Flashcard front (word), flip to back (definition + context), spaced repetition rating

---


## Spacing & Grid System

**All spacing uses a 4pt base grid. Prefer multiples of 8.**

| Use case | Values |
|---|---|
| Spacing / padding | 4, 8, 12, 16, 20, 24, 32, 40, 48, 56, 64 |
| Icon sizes | 16, 20, 24, 32, 40, 44, 48, 56, 64 |
| Corner radius | 8, 12, 14, 16, 24 (cards), 9999 (pill) |

**Rules:**
- Never use odd numbers (1, 3, 5, 7...) for spacing
- Never use values like 15, 22, 35 — always round to nearest grid unit
- When a % change is requested: calculate → round to nearest 8
- Horizontal padding on screens: **24pt** (standard)
- Card internal padding: **16pt** or **20pt**

## Design System

All screens follow these rules:

- **Mode**: Dark mode throughout (no light mode for now)
- **Background**: Near-black navy (`#0A0E1A` or similar)
- **Primary accent**: Blue `#007AFF`
- **Text**: White primary, `#8E8E93` secondary
- **Buttons**: Full-width, rounded corners (14pt radius), solid blue fill
- **Cards**: Subtle border, rounded corners, slightly lighter than background
- **Typography**: SF Pro (system font) — semibold for headings, regular for body
- **Navigation**: Bottom tab bar with 5 items (Home, Library, +, Stats, Profile)

---

## API Setup

Keys live in `Config.swift` (never in source control):

```swift
struct Config {
    static let deepLAPIKey = "..."
    static let openAIAPIKey = "..."
}
```

In `TalkSwitchAPI.swift`, reference via `APIConfig.openAIAPIKey` and `APIConfig.deepLAPIKey`.

---

## Coding Conventions

- **SwiftUI** for all new main app screens
- **UIKit only** for keyboard extension (iOS system requirement — do not mix)
- **Surgical edits**: never rewrite working code; replace only what needs changing
- **No inline Python in SSH commands** — write to temp file, scp, then execute
- **Commit after every meaningful change**
- **Test on device** before declaring anything "done" — simulator lies for keyboard extensions

---

## What NOT to Do

- Do NOT add microphone recording back to the keyboard extension — the OS blocks it, we've been through this
- Do NOT reopen DictateViewController from the keyboard — creates bad UX (context switching)
- Do NOT auto-detect silence and stop recording — users pause to think
- Do NOT put API keys in any committed file
- Do NOT rewrite KeyboardViewController.swift from scratch — it works, edit surgically
- Do NOT use `UISwipeGestureRecognizer` for the translation swipe — use `UIPanGestureRecognizer`

---

## Keyboard UX (locked decisions)

- Tapping the TalkSwitch bar shows a one-time tip (first time only), never leaves WhatsApp
- Language pill top-right: tap to toggle EN/PT, syncs with iOS dictation language changes
- Language persists via `UserDefaults.standard` key `talkswitch_lang`
- Recording: user uses native iOS mic bottom-right, TalkSwitch auto-translates via `textDidChange`
- Swipe output card rightward to get an alternative translation (swipe hint shown after first translation)

---

## ⏰ Scaling Milestones — Read These Every Session

> These are time-sensitive decisions Jeff intentionally deferred. If any trigger condition below is met,
> surface the relevant reminder BEFORE starting any other work. He will not remember these himself.

---

### 🔴 TRIGGER: ~1,000 active users OR first signs of unexpected API spend

**Action:** Migrate OpenAI API key off the device binary and onto a backend proxy.

**Why:** The API key is currently hardcoded in `Config.swift` inside the app binary. Anyone with
a reverse-engineering tool (e.g. `strings`, Frida, class-dump) can extract it from a distributed
IPA. At small scale this is acceptable risk. At 1,000+ users the app is a public target.

**What to build:** A lightweight backend (Supabase Edge Function or Cloudflare Worker) that:
1. Receives translation requests from the app (authenticated with the user's session token)
2. Holds the real OpenAI key server-side (environment variable, never in the binary)
3. Forwards the call to OpenAI and returns the result
4. Can enforce per-user rate limits to prevent any single user from abusing the system

**Files to change when doing this:**
- `Config.swift` — remove `openAIAPIKey`
- `TalkSwitchAPI.swift` — change all 6 OpenAI endpoints to point to the proxy instead
- Add auth header (Firebase ID token) to every proxied request

---

### 🟡 TRIGGER: Monthly OpenAI spend approaches $30–40/month

**Action:** Raise the OpenAI monthly spend cap on platform.openai.com (currently set low for safety).
Also evaluate whether the Supabase phrase cache is deployed — if not, this is the right moment.
Cache can cut API spend by 40–55% at this user scale.

---

### 🟡 TRIGGER: Expanding to new Spanish dialect regions (Colombia, Costa Rica, Argentina, etc.)

**Action:** Update `buildLocationInstruction()` in `TalkSwitchAPI.swift` to handle regional
Spanish dialects (Mexican, Colombian, Costa Rican, Argentinian are distinct in slang).
The v1 prompt is tuned for general Latin American Spanish ↔ English. Regional expansions
require dialect-specific prompt strategies and localityTag support.
Also update the `TranslationService.Language` enum and `TSProfiles` dict in `KeyboardViewController.swift`.

---

### 🟢 TRIGGER: ~5,000 users OR $8K+ MRR

**Action:** This is the right moment to consider a first angel raise ($150K–$300K).
Jeff has been advised to wait until this point — do NOT suggest fundraising before these
thresholds are hit. At this scale the unit economics are provable and leverage is real.

---

### 🟢 TRIGGER: TestFlight beta has 50+ testers

**Action:** Remind Jeff to:
1. Ask every tester personally for an App Store review on launch day
2. Reviews in the first 72 hours are critical for early App Store ranking
3. Target 25+ reviews in first week — algorithms reward early review velocity

---

## 🚀 Go-To-Market Strategy (Do Not Relitigate These Decisions)

> These are settled marketing decisions from extensive planning sessions. Treat as locked
> unless Jeff explicitly reopens them.

---

### Ideal Customer Profile (ICP) — Locked

**Primary user:** English-speaking American living in or visiting Mexico, trying to
communicate naturally with Spanish-speaking locals over WhatsApp.

**Why this and not "Spanish speakers in America":**
- Spanish speakers in America already speak Spanish — no translation needed
- Their American social circle uses iMessage/SMS, not WhatsApp
- Americans IN Mexico face daily communication friction with locals
- Mexicans use WhatsApp as their primary (often only) messaging app
- The "stay in WhatsApp, don't context switch" value prop is strongest for this user

**Primary cities to target:** Mexico City (CDMX), Playa del Carmen, Oaxaca,
San Miguel de Allende, Puerto Vallarta.

---

### App Store Strategy — Locked

**Do NOT compete on:**
- "Language learning app" → owned by Duolingo/Babbel/Rosetta Stone forever
- "Translation app" → owned by Google Translate

**DO own these low-competition keywords (nobody's there):**
- `whatsapp translation keyboard`
- `mexico spanish slang`
- `expat translation app`
- `american mexico spanish`
- `keyboard translator spanish`

**Primary acquisition is NOT organic App Store search.** Order of priority:
1. Community outreach (Facebook groups, Reddit r/expatmx, WhatsApp groups)
2. TikTok/Reels content → people search store *after* seeing video
3. Influencer affiliate program (see below)
4. Niche ASO keywords (passive, always-on, free)

**App Store launch day playbook:**
- TestFlight beta users CANNOT leave App Store reviews (TestFlight feedback is invisible publicly)
- On launch day: personally contact every TestFlight tester → ask them to re-download from
  App Store and leave a review within 48 hours
- Target 25+ reviews in first 72 hours — algorithm rewards early review velocity
- Do NOT launch "quietly" — coordinate a simultaneous blast across all communities

---

### Influencer Affiliate Program — Build This Before Launch

**Target influencers:** "Gringo in Mexico" / "American in Mexico" accounts on TikTok + Instagram.
Search: `#gringoinmexico` `#americaninmexico` `#expatmexico` `#digitalnomadmexico`
Sweet spot: **5K–80K followers, >3% engagement rate.**

**Payment model:** Flat $10 per Pro subscriber conversion (NOT per download).
- Only triggers when someone subscribes to Pro using the influencer's code
- Bonus tier: 1–10 = $10 each, 11–25 = $12 each, 25+ = $15 each
- Pay monthly via Venmo/PayPal (US) or Wise (Mexican influencers)
- Minimum 5 conversions ($50) before payout to reduce processing overhead

**Technical funnel (two layers):**

Layer 1 — **Branch.io** (free up to 10K attributed installs/month):
- Each influencer gets a unique deep link: `talkswitch.app.link/[theirname]`
- Tracks clicks → installs automatically, no manual work
- Dashboard shows: Pedro → 47 clicks → 31 installs

Layer 2 — **In-app promo code** (payment trigger):
- Each influencer also gets a unique code (e.g. `GRINGO`, `PEDRO`, `CDMX`)
- Code shown on Plan Selection screen: "Have a code? Enter it for 30% off"
- When user enters code + subscribes Pro → backend records attribution → pay influencer
- This is the payment trigger, Branch.io is the tracking layer

**Files to build when implementing:**
- Promo code field on `OnboardingView` Plan Selection screen
- Backend table: `promo_codes` (code, influencer_name, discount_pct, conversions, amount_owed)
- Payout tracking spreadsheet (Google Sheets for now, manual monthly)

**DM outreach template (personalize each one):**
> Hey [Name], I've been watching your Mexico content — [specific reference].
> I'm an expat myself and built a translation app called TalkSwitch specifically for
> Americans in Mexico. Real slang, not book Spanish.
> I'd love to give you free lifetime Pro + a $10/subscriber affiliate deal.
> No script, no required post — just use it and mention it if you love it.
> Worth a shot? I'll send you a promo code.

---

### Pricing — Locked

| Plan | Price | Key Limits |
|------|-------|------------|
| **Free** | $0 | 15 translations/day, 20 saved phrases, ads shown |
| **Pro** | $7.99/month OR $49.99/year | Unlimited, offline, TTS, city slang, ad-free |

- Lead with annual plan on paywall — highlight it as "Most Popular"
- Launch offer (first 60 days): $39.99/year "Founding Member" pricing
- Give new users a 7-day full Pro trial on first install — loss aversion drives conversion
- Show upgrade nudge at translation #14 (one before the 15/day limit hits)

---

## Roadmap

### ✅ Done (March 2026)
- [x] Firebase Auth (Sign In, Create Account, Forgot Password, Apple + Google)
- [x] Onboarding flow (Language → Goals → Location → Plan → Paywall)
- [x] Library screen UI (My Clipboard, Deck grid, Daily Goal)
- [x] Study mode (flashcard front/back, spaced repetition prompt, StudyOptionsCard)
- [x] Keyboard extension MVP (translation, slang tones, swipe-to-regenerate, TTS)

---

### 🔨 Now — Firestore Data Layer

- [ ] `DeckStore` — ObservableObject backed by Firestore `users/{uid}/decks`
- [ ] `MyDecksView` — Wire real Firestore data (skeleton UI done in MyDecksView.swift)
- [ ] Keyboard → Firestore clipboard sync (when user saves from keyboard, write to `users/{uid}/clipboard`)
- [ ] LibraryView "See All" → navigates to MyDecksView
- [ ] "+" FAB in MainTabView → opens CreateDeckSheet

---

### 🔜 Next — Deck System (AI + Manual)

This is a core differentiator. Details:

**AI Deck Generation:**
- User enters name + description (e.g. "Medical School - Radiology")
- App calls GPT-4o-mini: generates 25 Spanish↔English flashcard pairs as JSON
- Cost: ~500 tokens = ~$0.000075/deck. Essentially free.
- Commonly generated decks (medical, food, sports) get cached in Firestore `featured_decks`
  so the second user who generates the same category just gets the cached version instantly.
- Prompt format: returns `[{sourceText, translatedText, notes, audioHint}]`

**Manual Card Addition:**
- After deck creation, deck detail view with "Add Card" button
- Simple form: English word → Spanish word → optional note
- Edit / delete existing cards

**Featured Deck Import:**
- TalkSwitch-curated decks stored in `featured_decks` Firestore collection (shared, not per-user)
- Launch set (ready to populate): Mexico City Slang, Romantic Phrases, Medical Spanish,
  Food & Markets, Construction & Trades, Sports & Fútbol
- User taps "Add" → copies featured deck into their own `users/{uid}/decks` collection

**Seasonal Auto-Decks:**
- Default: one new deck per season (Spring/Summer/Fall/Winter + year)
- Clipboard phrases auto-tagged with current season on save
- "Conquered" deck: when a card is recalled correctly 3× in a row (SM-2 logic), it moves here
- These decks show stats: "You learned 47 phrases in Winter 2026"
- User setting (future): toggle between seasonal / monthly auto-grouping

**Implementation files to create/modify:**
- `DeckStore.swift` — Firestore CRUD + real-time listener for user's decks
- `MyDecksView.swift` — Skeleton done; wire to DeckStore
- `DeckDetailView.swift` — Cards list + add/edit/delete card UI
- `AIGenerationService.swift` — GPT-4o-mini deck generation call
- `FeaturedDeckService.swift` — Fetch from shared Firestore collection

---

### 🔜 Soon

- [ ] Study mode: spaced repetition scoring (SM-2 algorithm)
- [ ] Keyboard → Library sync (phrases from real conversations → clipboard deck)
- [ ] "Conquered" card logic (3× recall → move to Conquered deck)
- [ ] Seasonal auto-deck creation trigger
- [ ] Stats per deck: added this week/month/year, mastery %
- [ ] TestFlight external beta

---

### Future

- [ ] Affiliate promo code field on Plan Selection screen
- [ ] Branch.io deep link tracking for influencer program
- [ ] Portuguese support (next language after Spanish)
- [ ] French, German, Italian, Japanese, Korean support
- [ ] Progress tracking + streaks + annual wrapped
- [ ] AI pronunciation scoring
- [ ] Ads integration (free tier) — AdMob or equivalent

