---
description: UI/UX design skill. Generates intelligent design system recommendations and enforces SwiftUI design standards for TalkSwitch iOS.
---

# UI/UX Pro Max Skill — TalkSwitch iOS

*Sourced from nextlevelbuilder/ui-ux-pro-max-skill (v2.0), adapted for native SwiftUI.*

**Auto-activates when:** you ask to "build a screen", "design a view", "create UI", "improve the layout", or similar.

**Announce at start:** "I'm using the UI/UX Pro Max skill — generating design system recommendations first."

---

## Step 1: Design System Check (run before any UI code)

Before writing a single line of SwiftUI, confirm:

```
□ Colors:      Use DesignSystem.swift tokens (tsBackground, tsCard, tsAccent, tsLabel, tsSecondary)
□ Spacing:     4pt base grid — ONLY multiples of 4 (4, 8, 12, 16, 20, 24, 32, 40, 48)
□ Typography:  system(..) with defined sizes — or Sono font for brand text
□ Corners:     8 / 12 / 14 / 16 / 24 (cards) / 9999 (pill/capsule) ONLY
□ Gradients:   Use LinearGradient.tsBluePrimary or .tsVibrant — no ad-hoc gradients
□ Icons:       SF Symbols only — no emoji as icons in UI components
□ Dark Mode:   All colors via DesignSystem.swift adaptive tokens — never hardcoded hex
```

---

## Step 2: Style Selection

**TalkSwitch Design Identity:**
- **Style**: Dark-first, glassmorphic accents, premium feel
- **Mood**: Confident, modern, slightly playful — not corporate
- **Stack**: SwiftUI (iOS 16+) — no UIKit in main app views

**Available styles to reference:**
| Context | Recommended |
|---------|-------------|
| Cards/containers | `Color.tsCard` bg + `cornerRadius(24)` + subtle border |
| Primary CTAs | `LinearGradient.tsBluePrimary` capsule + shadow |
| Secondary CTAs | Outline style — `.stroke(Color.tsAccent.opacity(0.4))` |
| Destructive | `.red` tint, never gradient |
| Empty states | centered icon + label + subtext, no heavy decorations |
| Headers | 30pt bold, `.tsLabel` color, no navigation bar |

---

## Step 3: UX Checklist (Pre-Delivery)

Run before declaring any UI complete:

```
□ Every tappable element has a visual feedback state (scaleEffect or opacity on press)
□ Loading states are covered — never blank screen during async operations
□ Error states are covered — never silent failure
□ Empty states are covered — prompt the user toward the next action
□ Bottom content clears the custom tab bar (padding .bottom 120 minimum)
□ Sheets use .presentationDetents([.medium]) or .large — never default height
□ All text is .tsLabel or .tsSecondary — no hardcoded Color.white or Color.black
□ Accessibility: minimum tap target 44×44pt, never smaller
□ NavigationStack wraps the view if any .navigationDestination is used
□ No layout breaks at font size XL (Dynamic Type stress test)
```

---

## Step 4: Anti-Patterns (NEVER do these)

- ❌ Hardcoded hex colors in views — use DesignSystem.swift tokens
- ❌ Magic spacing numbers (padding(13), padding(22)) — use the 4pt grid
- ❌ `NavigationView` — use `NavigationStack`
- ❌ Flat, colorless buttons — every CTA needs visual hierarchy
- ❌ Missing loading/error/empty states — all three must be handled
- ❌ UIKit in SwiftUI views — keyboard extension is UIKit only
- ❌ More than 2 CTA buttons visible at once — pick a primary
- ❌ Generic SF Symbol icons without labels on new screens (label everything)

---

## Step 5: Component Reuse Priority

Before building a new component, check if it already exists:

| Need | Use |
|------|-----|
| Primary button | `TSButton` |
| Text input | `TSTextField` |
| Gradient pill | `TSGradientPill` |
| Progress ring | `TSProgressRing` |
| Logo | `TSLogoIcon` / `TSWordmark` |
| Divider | `TSDivider` |
| Deck grid card | `DeckCard` / `UserDeckCard` |
| Featured list row | `FeaturedDeckRow` / `LockedFlirtingRow` |

If the component doesn't exist and will be reused → add it to `DesignSystem.swift`.
If it's one-off → define it as a private struct in the same file.

---

## TalkSwitch UI Mood Board (reference for all new screens)

- **Inspiration**: Duolingo (gamified progress) × Linear (dark, minimal, fast) × Locket (warmth)
- **Don't look like**: generic App Store freeware, over-gradiated Gen-Z apps
- **Premium signals**: consistent spacing, confident typography, restrained animation
- **Animation philosophy**: micro-animations only — spring on hover/select, ease on appear, nothing auto-playing
