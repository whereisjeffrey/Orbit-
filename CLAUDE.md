# CLAUDE.md — TranslateHelper / TalkSwitch

> Read this file every session before touching any code. It is the single source of truth.

---

## Product Vision

TalkSwitch is a language learning ecosystem built around **real conversation**, not artificial exercises.

- **Keyboard extension** (TalkSwitch): Lives inside WhatsApp and other messaging apps. Translates in real time between English and Portuguese (expanding to more languages). Captures phrases from real conversations.
- **Main app**: Language learning platform. Users study phrases captured from real conversations via flashcards, track progress, and build vocabulary from words they actually use.

**Core insight**: Duolingo teaches you "the cat is on the table." TalkSwitch teaches you what you actually say to real people. The keyboard is the capture layer. The app is the study layer.

---

## Current State (as of March 2026)

### Keyboard Extension — DONE (MVP)
- EN ↔ PT translation via DeepL (primary) + OpenAI gpt-4o-mini (slang/tone refinement)
- Auto-translate on text change (1.8s debounce timer)
- Swipe-to-regenerate alternative translations (Tinder-style, rightward pan)
- Tone selector: Casual / Flirty / Culture / Family
- Language pill (🇧🇷 PT / 🇺🇸 EN) — persists across sessions via UserDefaults
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
5. **Language Selection** — Pick language to learn: EN, PT, ES, FR, DE, IT, JA, KO (flag cards)
6. **Learning Goal** — Select all that apply: Travel ✈️, Work 💼, Casual 👕, Flirty 💃, Culture 🎭, Family 👨‍👩‍👧
7. **Plan Selection** — Pro $9.99/mo (Unlimited phrases, AI coaching, offline) vs Free (10/day, basic)

### Core App
8. **Library** — Deck list, search, My Clipboard section, daily goal tracker, bottom nav
9. **Study Mode** — Flashcard front (word), flip to back (definition + context), spaced repetition rating

---

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

## Roadmap

### Now
- [ ] Firebase project setup (Auth + Firestore)
- [ ] Sign In + Create Account screens (SwiftUI)
- [ ] Forgot Password flow

### Next
- [ ] Onboarding (language + goal + plan screens)
- [ ] Library screen with Firestore-backed decks

### Soon
- [ ] Study mode flashcards
- [ ] Keyboard → Library sync (save phrases from conversations to user's deck)
- [ ] TestFlight external beta

### Future
- [ ] Spanish, French, German support
- [ ] Spaced repetition algorithm (SM-2)
- [ ] Progress tracking + streaks
- [ ] AI pronunciation scoring
