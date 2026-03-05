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
