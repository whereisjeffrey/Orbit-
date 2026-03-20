# HANDOFF.md
Last agent: Antigravity
Date: 2026-03-19 09:17
Session type: UI / Content / Architecture

---

## ⚠️ CRITICAL PATH NOTE
The project is at `/Users/jeffrey/Desktop/Orbit/` — NOT `TalkSwitch/`.
If your workspace points to `TalkSwitch/TranslateHelper`, you are in the wrong place.
All Swift source files live in `/Users/jeffrey/Desktop/Orbit/TranslateHelper/`.

---

## What was done this session

### Deck rename (StarterDeckSeeder.swift)
- Removed " I" suffix from all starter deck names:
  - "Timeless Adages I" → "Timeless Adages"
  - "Euphemisms I" → "Euphemisms"
  - "Dating & Romance I" → "Dating & Romance"
- Applied to both static Spanish path and AI-generation path

### DeckClipboardWidget UI (WeeklyLibraryWidgets.swift)
- User reverted the icon/tint-bar changes — the widget header is back to plain `deck.name` text
- User made other changes: streak card simplified to plain day boxes (CalendarDayCell removed, replaced with simple VStack blocks)
- Search bar focus state added to LibraryView.swift

### Euphemisms prompt overhaul (StarterDeckSeeder.swift)
- The `.euphemisms` systemPrompt and userPrompt are now explicitly targeting the **cheeky double-meaning** kind — expressions that sound innocent but carry a suggestive/humorous undertone
- Explicitly rejects the "boring PC" euphemisms (passed away, let go, big-boned)
- Uses Spanish f14 deck as the benchmark/example energy for other languages
- This affects AI-generated decks for all non-Spanish languages

### CLAUDE.md path fix
- Updated Project Structure section to show correct path `/Users/jeffrey/Desktop/Orbit/`
- Added ⚠️ PATH WARNING banner at the top so future agents don't look in the wrong place

---

## Currently in progress / half-finished
- Euphemisms improvement: deck name says "Euphemisms" but the deck description still says "cheeky double meaning" — may want to revisit deck description wording on the next pass
- The AI-generated decks for non-Spanish languages will now generate the right kind of euphemisms, but existing seeded decks for users who signed up before this change won't regenerate unless they switch language and back

---

## Do NOT touch until this is resolved
- `NSExtensionPointIdentifier` in `TranslateHelperKeyboard/Info.plist` — must stay `com.apple.keyboard-input-mode`
- `portugueseBR` in TranslationService.Language enum — needed for compilation
- App Group ID `group.com.jeff.translatehelper` — changing this breaks keyboard→library sync
- `KeyboardViewController.swift` — MVP complete, do not refactor unless fixing bugs

---

## Known issues
- Duplicate Compile Sources warnings (cosmetic Xcode issue — harmless)
- Existing users' decks won't auto-update to new names (persisted in UserDefaults) — they'd need to switch language target and back to trigger a reseed

---

## Next suggested action
- Review the Euphemisms f14 Spanish static deck (FeaturedDeckContent.swift) — it's already great but the deck description shown in the UI could be sharper ("30 phrases with a double meaning" is a bit vague)
- Consider: should we rename "Euphemisms" to something more evocative? "Double Take", "Between the Lines", or keep as is?
