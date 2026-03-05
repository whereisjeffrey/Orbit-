# HANDOFF.md
Last agent: Nigel (OpenClaw)
Date: 2026-03-05 08:45
Session type: Architecture / Feature build

## What was done this session
- Restructured app from language-learning tool to expat companion platform
- New 4-tab nav: Library / Community / Kit / Settings (removed Keyboard + Stats tabs)
- Built CommunityView: feed with post types, city selector, quick-access pills
- Built KitView: 6-tool grid (Cowork live, others placeholder)
- Built full Cowork feature: CoreLocation, filters, 10 CDMX spaces, detail view
- Built onboarding status screen (how long in city → user_expat_status)
- Built onboarding interests screen (12-tile grid → user_interests)
- Built BadgeSystem: TrustLevel enum, TrustBadge view
- Built NewInTownSection: horizontal scroll, opt-in sheet, pull-not-push
- Built real AskALocalView: locals list with trust badges, interest filters
- Built CommunityUserProfileView: full profile, social links, message request
- Added Instagram + LinkedIn handle fields to SettingsView
- Fixed xcworkspace to reference TalkSwitch.xcodeproj (was broken after rename)
- Fixed RootView (removed keyboard_setup_seen gate for testing)
- Updated CLAUDE.md comprehensively
- All changes committed, build passing

## Currently in progress / half-finished
- Seed data (CommunityUser, CoworkSpace) is hardcoded — needs Firestore later
- GroupDirectoryView is placeholder only
- All Kit tools except Cowork are placeholders
- Message requests show an alert stub — no real messaging backend yet
- New in Town opt-in timing logic (show after first engagement) not yet wired

## Do NOT touch until this is resolved
- KeyboardViewController.swift — keyboard is MVP complete, leave alone unless fixing bugs
- NSExtensionPointIdentifier in TranslateHelperKeyboard/Info.plist — MUST stay as com.apple.keyboard-input-mode
- OnboardingView.swift step numbering — 8 steps now, don't reorder or collapse
- RootView.swift — simplified intentionally, keyboard_setup_seen gate removed for testing

## Known issues
- Duplicate Compile Sources warnings (harmless, cosmetic Xcode issue)
- UI showing old screens on device: do Cmd+Shift+K clean then delete app from phone then Cmd+R

## Next suggested action
Build Vibe Check V1 — Kit tool, address/neighbourhood input → GPT-4o briefing output
