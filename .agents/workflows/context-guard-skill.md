---
description: Context Guard. Must be loaded before any code generation. Prevents use of deprecated libraries, outdated patterns, and cross-domain hallucinations.
---
# CONTEXT_GUARD Skill — TalkSwitch iOS

CRITICAL INSTRUCTION. Must be loaded before any code generation.

## 1. Memory & State Validation

Before generating ANY code:
- Read `CLAUDE.md` — architectural decisions, locked patterns, "What NOT to Do", scaling triggers
- Check which target the file belongs to (main app = SwiftUI, keyboard = UIKit)
- View the file before editing — never assume its current state

## 2. Temporal Guardrails — The "No-Zombie" Rule

- **Strict Ban**: Do NOT use Swift/SwiftUI patterns deprecated before 2024
- **iOS Version Lock**: Project targets iOS 16+
  - ✅ `NavigationStack` — never `NavigationView`
  - ✅ `.onChange(of:) { oldVal, newVal in }` — iOS 17 two-param syntax
  - ❌ `.onChange(of:) { newVal in }` — deprecated in iOS 17
  - ✅ `async/await` Firebase — never callback-style
  - ❌ No `UIKit` inside SwiftUI views (main app only)
- **Deprecation Check**: If unsure, explicitly flag it — never silently use a suspect API

## 3. Domain Isolation

- **Main App**: SwiftUI only
- **Keyboard Extension**: UIKit only (OS enforced — `UIInputViewController`)
- **Services**: Pure Swift, zero UI framework imports
- Do NOT add mic recording to the keyboard extension (permanently locked — see CLAUDE.md)
- Do NOT mix UIKit into SwiftUI views
- Do NOT suggest backend changes without confirming Firebase vs Supabase context

## 4. Scaling Trigger Check

Before every session, scan CLAUDE.md's `⏰ Scaling Milestones` section.
If any trigger condition is met, surface it BEFORE other work.

## 5. Explicit Assumptions Protocol

At the end of EVERY response containing code, append:

### 🛡️ Assumptions & Risks
1. **Library/API versions assumed**: [list any]
2. **Missing context**: [anything that could affect correctness]
3. **Confidence**: Low / Medium / High — that the code matches current project state
