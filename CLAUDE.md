# Orbit — CLAUDE.md
> Read this at the start of every session. No exceptions.
> Last updated: 2026-03-19 by Antigravity

> ⚠️ **PATH WARNING FOR ALL AGENTS:** The project lives at `/Users/jeffrey/Desktop/Orbit/` — NOT `TalkSwitch/`. If your workspace is pointing to `TalkSwitch/TranslateHelper`, you are in the wrong place. Always verify paths before editing files.

---

## 🤖 Auto-Documentation Rules (MANDATORY for all agents)

These rules apply to Antigravity, Claude Code, Nigel, or any AI working on this project.

### After every 5 file modifications:
Append to `WORK_LOG.md`:
```
## [DATE TIME] — [Agent name]
### Changed
- file.swift: what and why
### Decided
- Any decisions made, with reasoning
### Watch out
- Anything fragile or that could break
```

### When the session ends (user says bye/done/thanks/closing Xcode/goes idle 20+ min):
1. Append session summary to `WORK_LOG.md`
2. Rewrite `HANDOFF.md` with current state (see template below)
3. Update "Current State" section of this file if architecture changed

### At the start of every session:
1. Read this file (CLAUDE.md) fully
2. Read `HANDOFF.md` — the previous agent's last known state
3. Run `git log --oneline -10` to see what changed since last time
4. Do NOT assume you know the current state from memory alone

---

## 🏗️ What This App Is

**Orbit** — expat companion app for digital nomads and long-term expats.
Not a language learning app. Language tools (keyboard, decks) are features within a larger platform.

**Launch market:** Mexico City (Spanish)
**Target users:** Digital nomads + expats, 20–50, active workforce
**Price:** $7.99/month Pro, free tier available

### Core value prop
"Live like you belong there." The keyboard translates. The community connects. The Kit tools solve the practical stuff nobody tells you about.

---

## 📁 Project Structure

```
/Users/jeffrey/Desktop/Orbit/          ← ROOT — this is where everything lives
├── Orbit.xcodeproj                    ← USE THIS to open in Xcode
├── TranslateHelper.xcworkspace        ← CocoaPods workspace (references Orbit.xcodeproj)
├── TranslateHelper/                   ← Main app Swift files (ALL of them)
├── TranslateHelperKeyboard/           ← Keyboard extension Swift files
├── Pods/                              ← CocoaPods (do not edit)
├── CLAUDE.md                          ← You are here
├── HANDOFF.md                         ← Current session state (rewritten each session)
├── WORK_LOG.md                        ← Append-only audit trail
├── ROADMAP.md                         ← Feature roadmap
└── QUICK_START.md                     ← Stale setup doc from early build (mostly ignore)
```

> The app target is named **TranslateHelper** inside Xcode but the product/brand name is **Orbit**.
> The bundle ID `com.jeffrey.TranslateHelper` is intentionally kept as-is for App Store continuity.

---

## 📱 App Architecture

### Entry Point
`AppDelegate` (@main) → `SceneDelegate` → `UIHostingController(rootView: RootView())`
RootView routes: not signed in → SignInView | no onboarding → OnboardingView | else → MainTabView

### Navigation (4 tabs)
| Tab | View | Purpose |
|-----|------|---------|
| Library | LibraryView | Phrase decks, study mode |
| Community | CommunityView | Feed, New in Town, Ask a Local, Groups |
| Kit | KitView | Practical tools (Cowork, Currency, SIM, etc.) |
| Settings | SettingsView | Account, social handles, theme, debug |

### Onboarding (8 steps — OnboardingView.swift)
1. Language selection (Spanish pre-selected — only language for now)
2. Goals (why learning)
3. Location (what city)
4. **Status** — how long in city → saves to `user_expat_status`
5. **Interests** — 12-tile grid → saves to `user_interests` (comma-separated)
6. Plan (Free vs Pro $7.99)
7. Paywall (credit card)
8. Keyboard setup splash

### Key AppStorage Keys
```
onboarding_complete     bool    — gates RootView
user_expat_status       string  — just_arrived/settling/local/planning/visiting
user_interests          string  — comma-separated ids e.g. "remote_work,nightlife,food"
instagram_handle        string  — optional social handle
linkedin_handle         string  — optional social handle
new_in_town_opt_in      bool    — visible in New in Town section
selected_city_id        string  — e.g. "mx_cdmx" (default)
appTheme                int     — 0=light, 1=dark
talkswitch_lang         string  — keyboard language (in App Group)
talkswitch_target_lang  string  — keyboard target (in App Group)
```

### App Group
`group.com.jeff.translatehelper` — shared between main app + keyboard extension
Keys: `talkswitch_saved_phrases`, `talkswitch_lang`, `talkswitch_target_lang`

### Bundle IDs
- Main app: `com.jeffrey.TranslateHelper`
- Keyboard: `com.jeffrey.TranslateHelper.Keyboard`

---

## 🎨 Design System (DesignSystem.swift)

All colours are semantic tokens — NEVER hardcode hex values in views.

| Token | Light | Dark | Use for |
|-------|-------|------|---------|
| `.tsBackground` | #FFFFFF | #000000 | Page backgrounds |
| `.tsCard` | #F2F2F7 | #1C1C1E | Card surfaces |
| `.tsLabel` | #000000 | #FFFFFF | Primary text — NEVER use .white directly |
| `.tsSecondary` | #3C3C43/60% | #8E8E93 | Secondary text |
| `.tsAccent` | #007AFF | #007AFF | Interactive elements |
| `.tsBorder` | system | system | Dividers, strokes |
| `.tsInputBg` | #F2F2F7 | #1C1C1E | Text field backgrounds |

**8pt grid rule:** All spacing must be multiples of 4 (prefer 8). Never odd numbers.

**Fonts:**
- **Momo Trust Display (MomoTrustDisplay-Regular.ttf)**: PRIMARY BRAND FONT — use for the Orbit wordmark, splash screen brand text, and any display headline carrying the Orbit brand. Call `.font(.momoTrustDisplay(size))` from DesignSystem.swift. This is the font that represents Orbit as a brand.
- Sono-Regular: legacy wordmark, kept for backwards-compatible contexts only
- SF Pro: all body copy and UI text

**Reusable components:** `TSButton`, `TSTextField`, `TSGradientBackground`, `OrbitWordmark`, `TSProgressRing`, `ScaleButtonStyle`, `TrustBadge`

---

## ⌨️ Keyboard Extension (TranslateHelperKeyboard/)

### CRITICAL — DO NOT CHANGE THESE
```xml
NSExtensionPointIdentifier = com.apple.keyboard-input-mode  ← NEVER change this
PrimaryLanguage = mul
```
Antigravity has previously changed `NSExtensionPointIdentifier` to wrong values breaking the extension. Check `TranslateHelperKeyboard/Info.plist` after any keyboard session.

### Architecture
- `KeyboardViewController.swift` — all keyboard UI + logic (~941 lines)
- `TalkSwitchAPI.swift` — DeepL + OpenAI gpt-4o-mini
- Language: EN ↔ ES (Spanish). `portugueseBR` kept in `TranslationService.Language` enum for compilation only.
- Default language: `"es"` (Spanish)
- Inline recording: **permanently impossible** — iOS blocks AVAudioEngine in extension process. Do NOT attempt.
- Swipe-to-regenerate: UIPanGestureRecognizer on outputCard, threshold 90pt rightward

### App Group sync (keyboard → library)
`saveTapped()` writes to App Group UserDefaults key `talkswitch_saved_phrases` as `[[String:String]]`
Fields: `{id, sourceText, translation, sourceLang, targetLang, savedAt}`

---

## 🌍 Community Layer (CommunityView.swift)

### Feed post types
Questions / Recs / Warnings / Events — all tagged, time-limited (events expire, questions close when answered)

### New in Town section
- `NewInTownSection.swift` — horizontal scroll of recent arrivals
- Opt-in only (`new_in_town_opt_in` AppStorage key)
- Opt-in asked once, after first community engagement — NOT at signup
- Pull not push — no unsolicited notifications sent to newcomers

### Ask a Local (AskALocalView.swift)
- Only shows users with `isAvailableForLocal = true`
- Sorted by `questionsAnswered` desc
- Trust badges from `BadgeSystem.swift`

### Trust Badge System (BadgeSystem.swift)
```
TrustLevel: New Arrival → Getting Settled → Local → Trusted Local → City Expert
Derived from: user_expat_status + questionsAnswered count
```

### Message system
- Message requests only — not open DMs
- Recipient must accept before conversation starts
- Report + block available on all profiles

### Community User Profile (CommunityUserProfileView.swift)
Shows: avatar (initials-based, colour from id hash), trust badge, bio, stats, interests, Instagram/LinkedIn links, message request CTA

---

## 🧰 Kit Tab (KitView.swift)

### Live tools
| Tool | File | Status |
|------|------|--------|
| Cowork | CoworkView.swift + CoworkSpace.swift | ✅ Full — 10 CDMX spaces seeded |
| Currency | — | 🔲 Placeholder |
| SIM Guide | — | 🔲 Placeholder |
| Neighbourhoods | — | 🔲 Placeholder |
| Bureaucracy | — | 🔲 Placeholder |
| Scam Radar | — | 🔲 Placeholder |

### Cowork feature
- Location-aware via CoreLocation (`CoworkLocationManager`)
- Sort: Distance / Price
- Filters: Call rooms / Coffee / Fast WiFi / Late hours
- Detail view: amenity cards, pricing, address, Get Directions → Apple Maps
- Seed data: 10 CDMX spaces in `cdmxCoworkSpaces` array

### City infrastructure (CityModel.swift)
8 Mexican cities seeded. `selected_city_id` AppStorage key. All features city-filtered.

---

## 🔥 Firebase + Auth

- Firebase SDK 12.10.0 via SPM (NOT CocoaPods)
- `FirebaseApp.configure()` in AppDelegate
- `AuthManager.swift` — email/password + Apple Sign-In (SHA256 nonce) + Google Sign-In UI stub
- `GoogleService-Info.plist` in bundle
- Apple Sign-In: `OAuthProvider.appleCredential(withIDToken:rawNonce:fullName:)`

---

## 🚫 Do Not Touch List

| Thing | Why |
|-------|-----|
| `NSExtensionPointIdentifier` in keyboard Info.plist | Must be `com.apple.keyboard-input-mode` — wrong value breaks extension entirely |
| `portugueseBR` in TranslationService.Language enum | Needed for compilation even though PT isn't active |
| Default keyboard language `"es"` | Spanish pivot is intentional |
| App Group ID `group.com.jeff.translatehelper` | Changing this breaks keyboard→library sync |
| `Sono-Regular.ttf` in bundle | Must stay in Copy Bundle Resources |
| SceneDelegate window setup | App uses UIKit entry point, not SwiftUI @main — don't add @main to any SwiftUI file |

---

## 🔄 Adding Files to Xcode Project

When adding new Swift files via script, run:
```bash
ruby /tmp/add_files.rb
```
This uses the `xcodeproj` gem to add all unregistered `.swift` files from the TranslateHelper folder.
If the script isn't at `/tmp/`, copy it from the Nigel workspace or recreate it.

---

## 📋 Current Priorities

1. **Vibe Check** — Kit tool: neighbourhood safety briefing (AI + curated). V1 = type address → GPT-4o briefing
2. **Events tab** in Community — skeleton + Eventbrite API integration
3. **Pre-Arrival Intel Pack** — synthesises Kit + Community before user lands in a city
4. **Wire interests/status** to Community feed filtering
5. **TestFlight / App Store** — Jeffrey working on submission

---

## HANDOFF.md Template (rewrite this at end of every session)

```markdown
# HANDOFF.md
Last agent: [Nigel / Antigravity]
Date: [DATE]
Session type: [UI / Debug / Feature / Architecture]

## What was done this session
- 

## Currently in progress / half-finished
- 

## Do NOT touch until this is resolved
- 

## Known issues
- 

## Next suggested action
- 
```
