# HANDOFF.md
Last agent: Claude Code
Date: 2026-04-09
Session type: Feature / UI / Debug / Architecture

## What was done this session
- Keyboard send delay: 14 seconds → instant (deferred + cancelled post-translation work, smart delete replacing 2000 IPC calls)
- Translation flash: found 3-4x duplicate performTranslation fire, added de-duplication guard
- Geographic DNA: slang labeled LOCAL/REGIONAL/NATIONWIDE/UNIVERSAL in keyboard + Sol
- Profile backup: locations, interests, status, hints survive reinstalls
- Vocab card feature: auto-detects English words in mistake_log → generates coaching card (language-agnostic, works for all 10 languages)
- Session summary redesigned: big time hero, scannable patterns with target area icons/colors, "New Terms"
- Hint card: separate cyan card with swipe-to-dismiss, doesn't hijack notes
- Hint positioning: all Sol guidance hints appear below latest message (not at top)
- Native double-tap hint waits for correction data readiness
- Onboarding: "Let Orbit Coach personalize" intro page, gray→blue buttons, status reordered
- Nuclear reset button in Settings
- Weekly streak: real data only, Sol sessions count, debug seed removed
- Deck generation: correct API key, language-aware
- Keyboard setup banner: button-style when not installed, resets stale state
- Info.plist: reverted to keyboard-service (correct for Xcode 26)
- Pricing spec: Model B ($5.99/mo, $49.99/yr), 100 translations/week, 14-day no-CC trial
- Featured decks spec: tiered unlock system with interest-based suggestions
- Speaker icon fixed frame, dictation stale text fix, back button tap target enlarged

## Currently in progress / half-finished
- Vocab card: trigger-based detection (English phrase matching) as backup — working but GPT rarely populates slang_notes
- Hint card (keyboard paste tip): works in DEBUG builds, App Group caching issue in release
- Featured decks: spec written, not yet built

## Do NOT touch until this is resolved
- Info.plist NSExtensionPointIdentifier must be "com.apple.keyboard-service" (NOT keyboard-input-mode) for Xcode 26
- Slang notes parsing must use [[String: Any]] not [[String: String]] — GPT returns null values

## Known issues
- WhisperKit rate-limited (429) — falls back to API transcription
- MuseoModerno font files missing from bundle (non-breaking)
- CFPrefs warning on App Group (benign)
- Dictation "Waiting" state can get stuck if URL scheme fails (15s timeout + tap-to-cancel added)

## Next suggested action
- Build featured decks (tiered unlock, AI-generated on tap)
- Card management UX (long-press dismiss, list view multi-select, swipe-to-remove)
- Test vocab card feature more thoroughly
- New TestFlight build
