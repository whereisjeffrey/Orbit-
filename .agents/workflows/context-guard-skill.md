---
description: Context Guard. Must be loaded before any code generation. Prevents use of deprecated libraries, outdated patterns, and cross-domain hallucinations.
---
# CONTEXT_GUARD Skill
description: CRITICAL INSTRUCTION. Must be loaded before any code generation. Prevents use of deprecated libraries, outdated patterns, and cross-domain hallucinations.

## 1. Memory & State Validation
Before generating any code, you MUST perform a "State Check" by reading:
- `project.pbxproj` or `Package.swift` (for current dependency versions)
- `README.md` (for architectural intent)
- Last 3 entries in `git log` (if available)

## 2. Temporal Guardrails (The "No-Zombie" Rule)
- **Strict Ban**: Do NOT use code patterns from tutorials older than 2024 unless explicitly requested.
- **Version Lock**: If the project specifies iOS 16+, reject any code using deprecated iOS 14 patterns.
- **Deprecation Check**: If you are unsure if a method is deprecated, you must ask the user or run a search query specifically for "deprecation status [method name]".

## 3. Domain Isolation
- You are strictly scoped to the domain: **iOS Native App Development (Swift/SwiftUI)**.
- Do NOT import logic from completely different domains (e.g., do not use CSS-in-JS libraries if we are writing a SwiftUI view).

## 4. Explicit Assumptions Protocol
At the end of EVERY response, you must append a section called "## 🛡️ Assumptions & Risks":
1. List any assumption made about library versions.
2. List any context you felt was missing.
3. State confidence level (Low/Medium/High) that the code provided matches the *current* project state.
