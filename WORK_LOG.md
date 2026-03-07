# WORK_LOG.md — Append-only change log
> Each agent appends here. Never delete entries. Newest at bottom.

---

## 2026-02-25 — Nigel (OpenClaw)
### Changed
- Initial setup: Tailscale tunnel, SSH key auth, workspace files
### Decided
- Working principles established: no sycophancy, challenge ideas, verify before claiming

## 2026-02-26 — Nigel (OpenClaw)
### Changed
- Fixed mac-connect.sh nohup bug
### Decided
- Tailscale state persisted to workspace file to survive restarts

## 2026-02-28 to 2026-03-01 — Nigel + Antigravity
### Changed
- Firebase Auth + SPM packages added
- Full keyboard extension MVP built
- Apple Sign-In, email/password auth
- DesignSystem.swift built out
### Decided
- Keyboard inline recording permanently impossible (OS blocks AVAudioEngine in extension)
- CLAUDE.md written for project

## 2026-03-02 — Nigel + Antigravity
### Changed
- Full 5-step onboarding flow
- OnboardingPaywallView (credit card, $7.99, today+7 charge date)
- LibraryView with SharedPhraseStore sync
- Light/dark adaptive colors
- 8pt grid documented in DesignSystem
- Sono font shipped and registered
### Decided
- Callback pattern for onboarding (not navigationDestination)
- Keyboard saves phrases as [[String:String]] flat format
- Reset Onboarding button in Settings for testing

## 2026-03-04 — Antigravity
### Changed
- Project renamed TranslateHelper → TalkSwitch
- New TalkSwitch.xcodeproj created
- Keyboard MVP finalized: EN↔ES, swipe-to-regenerate, tone selector
- Several new untracked files added (DeckStore, AddCardSheet, etc.)
### Watch out
- xcworkspace was left pointing at old TranslateHelper.xcodeproj (now fixed by Nigel)

## 2026-03-05 — Nigel (OpenClaw) — Major session
### Changed
- App pivot: language learning → expat companion platform
- New 4-tab nav (Library/Community/Kit/Settings)
- CityModel.swift (8 Mexican cities)
- CommunityView.swift (feed, filters, city selector, FAB)
- KitView.swift (6-tool grid)
- MainTabView.swift (new nav)
- CoworkSpace.swift (data model + 10 CDMX spaces seeded)
- CoworkView.swift (CoreLocation, sort, filters, cards, detail view)
- OnboardingStatusView.swift (expat status picker, 5 options)
- OnboardingInterestsView.swift (12 interests, multi-select grid)
- OnboardingView.swift (updated to 8-step flow)
- BadgeSystem.swift (TrustLevel enum, TrustBadge component)
- NewInTownSection.swift (horizontal scroll, opt-in sheet)
- AskALocalView.swift (real locals list, badges, filters)
- CommunityUserProfileView.swift (full profile, social links, message request)
- SettingsView.swift (Social section: Instagram + LinkedIn handles)
- RootView.swift (simplified, removed keyboard_setup_seen gate)
- CLAUDE.md (comprehensive rewrite)
- HANDOFF.md (created)
- WORK_LOG.md (created)
### Decided
- No pre-arrival "X people arriving same week" push notifications (harassment risk)
- New in Town is pull not push — opt-in, browsable, no unsolicited contact
- Message requests not open DMs
- Instagram/LinkedIn = optional text fields, no OAuth
- Interest tags drive personalisation without asking age
- Vibe Check is next Kit tool to build (AI neighbourhood briefing)
### Watch out
- All seed data (CommunityUser, CoworkSpace) is hardcoded arrays — Firestore swap needed later
- add_files.rb script at /tmp/add_files.rb — run after any new .swift files added via script

## 2026-03-05 (continued) — Nigel
### Changed
- CoworkView: one-time location prompt card (shown once, explains distances aren't stored)
- CoworkView: 'Add a space or fix outdated info' CTA at bottom of list
- CoworkDetailView: 'Suggest an edit' button opens pre-filled submission form
- CoworkSubmitView: full crowd-source form (new space + edit existing) — name, neighbourhood, address, pricing, hours, amenity toggles, notes/lowdown field
### Decided
- Location prompt shown once only (cowork_location_asked AppStorage key)
- Raw location never stored — only used to calculate distances at query time
- 'Suggest an edit' on detail view + 'Add a space' at list bottom = two entry points for community data

## 2026-03-05 — project cleanup
### Problem
add_files.rb had been run 6 times, each creating a complete duplicate PBXGroup copy
of the entire TranslateHelper/ folder. 125 ghost PBXFileReference objects + 26 orphaned
PBXBuildFile entries caused duplicate compile warnings on every file in the project.

### Root cause
TalkSwitch.xcodeproj uses PBXFileSystemSynchronizedRootGroup (Xcode 16+) — files in
TranslateHelper/ are picked up automatically. add_files.rb (old-style PBXGroup approach)
was entirely redundant and additive on every run.

### Fix
- fix_filesync.rb: cleared explicit entries from Sources + Resources phases
- fix_stale_groups.rb: removed 6 stale PBXGroup objects + contents
- fix_final.rb: removed 1 remaining LaunchScreen.storyboard entry
- Result: BUILD SUCCEEDED with zero warnings

### Permanent change
DO NOT run add_files.rb ever again. Just create .swift files in TranslateHelper/ —
fileSystemSynchronizedGroups includes them automatically on next build.

## 2026-03-05 08:45 — Auto-handoff (auto-heartbeat)
### Changed (uncommitted)
 M TranslateHelper/Assets.xcassets/AppIcon.appiconset/TalkSwitch-Icon.png
 M TranslateHelper/Info.plist
 M TranslateHelper/Localizable.xcstrings
 M TranslateHelper/MainTabView.swift
### Files
TranslateHelper/Assets.xcassets/AppIcon.appiconset/TalkSwitch-Icon.png TranslateHelper/Info.plist TranslateHelper/Localizable.xcstrings TranslateHelper/MainTabView.swift 

## 2026-03-05 09:45 — Auto-handoff (auto-heartbeat)
### Changed (uncommitted)
 M TalkSwitch.xcodeproj/project.pbxproj
 M TranslateHelper/Info.plist
### Files
TalkSwitch.xcodeproj/project.pbxproj TranslateHelper/Info.plist 

## 2026-03-05 13:45 — Auto-handoff (auto-heartbeat)
### Changed (uncommitted)
 M TalkSwitch.xcodeproj/xcshareddata/xcschemes/TalkSwitch.xcscheme
 M TranslateHelper/CoworkView.swift
 M TranslateHelper/DesignSystem.swift
 M TranslateHelper/LibraryView.swift
 M TranslateHelper/Localizable.xcstrings
 M TranslateHelper/MainTabView.swift
 M TranslateHelper/MyDecksView.swift
 M TranslateHelper/RootView.swift
### Files
TalkSwitch.xcodeproj/xcshareddata/xcschemes/TalkSwitch.xcscheme TranslateHelper/CoworkView.swift TranslateHelper/DesignSystem.swift TranslateHelper/LibraryView.swift TranslateHelper/Localizable.xcstrings TranslateHelper/MainTabView.swift TranslateHelper/MyDecksView.swift TranslateHelper/RootView.swift 

## 2026-03-05 14:45 — Auto-handoff (auto-heartbeat)
### Changed (uncommitted)
 M TranslateHelper/AddCardSheet.swift
 M TranslateHelper/AskALocalView.swift
 M TranslateHelper/BadgeSystem.swift
 M TranslateHelper/CommunityUserProfileView.swift
 M TranslateHelper/CommunityView.swift
 M TranslateHelper/CoworkSubmitView.swift
 M TranslateHelper/CoworkView.swift
 M TranslateHelper/CreateAccountView.swift
 M TranslateHelper/DeckPhraseListView.swift
 M TranslateHelper/DesignSystem.swift
 M TranslateHelper/FlirtyContextSheet.swift
 M TranslateHelper/ForgotPasswordView.swift
 M TranslateHelper/KeyboardSetupBanner.swift
 M TranslateHelper/KeyboardSetupSplashView.swift
 M TranslateHelper/KitView.swift
 M TranslateHelper/LanguageSelectionView.swift
 M TranslateHelper/LibraryView.swift
 M TranslateHelper/Localizable.xcstrings
 M TranslateHelper/MainTabView.swift
 M TranslateHelper/MyDecksView.swift
 M TranslateHelper/NewInTownSection.swift
 M TranslateHelper/OnboardingGoalsView.swift
 M TranslateHelper/OnboardingInterestsView.swift
 M TranslateHelper/OnboardingLocationView.swift
 M TranslateHelper/OnboardingPaywallView.swift
 M TranslateHelper/OnboardingPlanView.swift
 M TranslateHelper/OnboardingStatusView.swift
 M TranslateHelper/QuickAddSheet.swift
 M TranslateHelper/SettingsView.swift
 M TranslateHelper/SignInView.swift
 M TranslateHelper/StudyOptionsCard.swift
 M TranslateHelper/StudyRevealedCardView.swift
 M TranslateHelper/StudySourceWordView.swift
 M TranslateHelper/WorkTipViews.swift
 M TranslateHelper/WorkView.swift
### Files
TranslateHelper/AddCardSheet.swift TranslateHelper/AskALocalView.swift TranslateHelper/BadgeSystem.swift TranslateHelper/CommunityUserProfileView.swift TranslateHelper/CommunityView.swift TranslateHelper/CoworkSubmitView.swift TranslateHelper/CoworkView.swift TranslateHelper/CreateAccountView.swift TranslateHelper/DeckPhraseListView.swift TranslateHelper/DesignSystem.swift TranslateHelper/FlirtyContextSheet.swift TranslateHelper/ForgotPasswordView.swift TranslateHelper/KeyboardSetupBanner.swift TranslateHelper/KeyboardSetupSplashView.swift TranslateHelper/KitView.swift TranslateHelper/LanguageSelectionView.swift TranslateHelper/LibraryView.swift TranslateHelper/Localizable.xcstrings TranslateHelper/MainTabView.swift TranslateHelper/MyDecksView.swift TranslateHelper/NewInTownSection.swift TranslateHelper/OnboardingGoalsView.swift TranslateHelper/OnboardingInterestsView.swift TranslateHelper/OnboardingLocationView.swift TranslateHelper/OnboardingPaywallView.swift TranslateHelper/OnboardingPlanView.swift TranslateHelper/OnboardingStatusView.swift TranslateHelper/QuickAddSheet.swift TranslateHelper/SettingsView.swift TranslateHelper/SignInView.swift TranslateHelper/StudyOptionsCard.swift TranslateHelper/StudyRevealedCardView.swift TranslateHelper/StudySourceWordView.swift TranslateHelper/WorkTipViews.swift TranslateHelper/WorkView.swift 

## 2026-03-05 15:44 — Auto-handoff (auto-heartbeat)
### Changed (uncommitted)
 M TranslateHelper/AddCardSheet.swift
 M TranslateHelper/AskALocalView.swift
 M TranslateHelper/CommunityUserProfileView.swift
 M TranslateHelper/CommunityView.swift
 M TranslateHelper/CoworkSubmitView.swift
 M TranslateHelper/CoworkView.swift
 M TranslateHelper/DeckPhraseListView.swift
 M TranslateHelper/DesignSystem.swift
 M TranslateHelper/KitView.swift
 M TranslateHelper/LibraryView.swift
 M TranslateHelper/MainTabView.swift
 M TranslateHelper/MyDecksView.swift
 M TranslateHelper/NewInTownSection.swift
 M TranslateHelper/OnboardingGoalsView.swift
 M TranslateHelper/OnboardingLocationView.swift
 M TranslateHelper/OnboardingPaywallView.swift
 M TranslateHelper/SettingsView.swift
 M TranslateHelper/WorkTipStore.swift
 M TranslateHelper/WorkView.swift
### Files
TranslateHelper/AddCardSheet.swift TranslateHelper/AskALocalView.swift TranslateHelper/CommunityUserProfileView.swift TranslateHelper/CommunityView.swift TranslateHelper/CoworkSubmitView.swift TranslateHelper/CoworkView.swift TranslateHelper/DeckPhraseListView.swift TranslateHelper/DesignSystem.swift TranslateHelper/KitView.swift TranslateHelper/LibraryView.swift TranslateHelper/MainTabView.swift TranslateHelper/MyDecksView.swift TranslateHelper/NewInTownSection.swift TranslateHelper/OnboardingGoalsView.swift TranslateHelper/OnboardingLocationView.swift TranslateHelper/OnboardingPaywallView.swift TranslateHelper/SettingsView.swift TranslateHelper/WorkTipStore.swift TranslateHelper/WorkView.swift 

## 2026-03-05 16:44 — Auto-handoff (auto-heartbeat)
### Changed (uncommitted)
 M TranslateHelper/AddCardSheet.swift
 M TranslateHelper/AskALocalView.swift
 M TranslateHelper/AuthManager.swift
 M TranslateHelper/CafeSpace.swift
 M TranslateHelper/CommunityUserProfileView.swift
 M TranslateHelper/CommunityView.swift
 M TranslateHelper/CoworkSpace.swift
 M TranslateHelper/CoworkSubmitView.swift
 M TranslateHelper/CoworkView.swift
 M TranslateHelper/DeckPhraseListView.swift
 M TranslateHelper/DesignSystem.swift
 M TranslateHelper/KeyboardSetupBanner.swift
 M TranslateHelper/KitView.swift
 M TranslateHelper/LibraryView.swift
 M TranslateHelper/Localizable.xcstrings
 M TranslateHelper/MainTabView.swift
 M TranslateHelper/MyDecksView.swift
 M TranslateHelper/NewInTownSection.swift
 M TranslateHelper/OnboardingPaywallView.swift
 M TranslateHelper/SettingsView.swift
 M TranslateHelper/WorkView.swift
?? TranslateHelper/PlacePhotoCarousel.swift
?? TranslateHelper/PlacePhotoStore.swift
### Files
TranslateHelper/AddCardSheet.swift TranslateHelper/AskALocalView.swift TranslateHelper/AuthManager.swift TranslateHelper/CafeSpace.swift TranslateHelper/CommunityUserProfileView.swift TranslateHelper/CommunityView.swift TranslateHelper/CoworkSpace.swift TranslateHelper/CoworkSubmitView.swift TranslateHelper/CoworkView.swift TranslateHelper/DeckPhraseListView.swift TranslateHelper/DesignSystem.swift TranslateHelper/KeyboardSetupBanner.swift TranslateHelper/KitView.swift TranslateHelper/LibraryView.swift TranslateHelper/Localizable.xcstrings TranslateHelper/MainTabView.swift TranslateHelper/MyDecksView.swift TranslateHelper/NewInTownSection.swift TranslateHelper/OnboardingPaywallView.swift TranslateHelper/SettingsView.swift TranslateHelper/WorkView.swift TranslateHelper/PlacePhotoCarousel.swift TranslateHelper/PlacePhotoStore.swift 

## 2026-03-06 08:45 — Auto-handoff (auto-heartbeat)
### Changed (uncommitted)
 M TranslateHelper/Localizable.xcstrings
### Files
TranslateHelper/Localizable.xcstrings 

## 2026-03-06 09:45 — Auto-handoff (auto-heartbeat)
### Changed (uncommitted)
 M TranslateHelper/Localizable.xcstrings
### Files
TranslateHelper/Localizable.xcstrings 

## 2026-03-07 19:23 — Auto-handoff (auto-heartbeat)
### Changed (uncommitted)
 M TranslateHelper/Assets.xcassets/DailyGoalBackground.imageset/background_dark.png
 M TranslateHelper/CommunityView.swift
 M TranslateHelper/CoworkView.swift
 M TranslateHelper/DesignSystem.swift
 M TranslateHelper/KitView.swift
 M TranslateHelper/LibraryView.swift
 M TranslateHelper/Localizable.xcstrings
 M TranslateHelper/MainTabView.swift
 M TranslateHelper/WeeklyLibraryWidgets.swift
 M TranslateHelper/WorkTipViews.swift
 M TranslateHelper/WorkView.swift
### Files
TranslateHelper/Assets.xcassets/DailyGoalBackground.imageset/background_dark.png TranslateHelper/CommunityView.swift TranslateHelper/CoworkView.swift TranslateHelper/DesignSystem.swift TranslateHelper/KitView.swift TranslateHelper/LibraryView.swift TranslateHelper/Localizable.xcstrings TranslateHelper/MainTabView.swift TranslateHelper/WeeklyLibraryWidgets.swift TranslateHelper/WorkTipViews.swift TranslateHelper/WorkView.swift 

## 2026-03-07 19:53 — Auto-handoff (auto-heartbeat)
### Changed (uncommitted)
 M TranslateHelper/DesignSystem.swift
 M TranslateHelper/Info.plist
 M TranslateHelper/LibraryView.swift
 M TranslateHelper/WeeklyLibraryWidgets.swift
?? TranslateHelper/Comfortaa-Medium.ttf
### Files
TranslateHelper/DesignSystem.swift TranslateHelper/Info.plist TranslateHelper/LibraryView.swift TranslateHelper/WeeklyLibraryWidgets.swift TranslateHelper/Comfortaa-Medium.ttf 

## 2026-03-07 20:46 — Auto-handoff (auto-heartbeat)
### Changed (uncommitted)
 M TranslateHelper/Localizable.xcstrings
### Files
TranslateHelper/Localizable.xcstrings 
