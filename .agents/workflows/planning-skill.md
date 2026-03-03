---
description: Implementation planning skill. Write bite-sized, test-first implementation plans before touching any code.
---

# Writing Plans — TalkSwitch iOS

*Sourced from obra/superpowers, adapted for TalkSwitch Swift/iOS.*

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Prerequisite:** Run the brainstorming skill first. This skill only runs after a design is approved.

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Overview

Write comprehensive, bite-sized implementation plans. Assume zero context. Document every file
to touch, every test to write, every command to run. DRY. YAGNI. TDD. Commit frequently.

## Bite-Sized Task Granularity

Each step = ONE action (2–5 minutes):
- "Write the failing XCTest" — step
- "Run it to confirm it fails" — step
- "Write the minimum Swift code to pass" — step
- "Run all tests, confirm green" — step
- "Commit" — step

## Plan Document Header

Every plan MUST start with:

```markdown
# [Feature Name] Implementation Plan

> **REQUIRED:** Use the testing-skill (TDD) for every implementation step.

**Goal:** [One sentence]
**Architecture:** [2–3 sentences about approach]
**Files to touch:** [exact paths]

---
```

## Task Structure Template

```markdown
### Task N: [Component Name]

**Files:**
- Create: `TranslateHelper/ExactPath/NewFile.swift`
- Modify: `TranslateHelper/ExactPath/ExistingFile.swift` (lines ~123-145)
- Test: `TranslateHelperTests/ExactPath/NewFileTests.swift`

**Step 1: Write the failing test**
[exact test code]

**Step 2: Run test — must fail**
Product → Test (⌘U) — expect: FAIL with "X not defined"

**Step 3: Write minimal implementation**
[exact implementation code]

**Step 4: Run all tests — must pass**
⌘U — expect: All tests green

**Step 5: Build on device/simulator**
⌘R — expect: No warnings, feature visible

**Step 6: Commit**
`git commit -m "feat: [description]"`
```

## iOS-Specific Rules

- Always specify the target (main app vs keyboard extension) for every file
- SwiftUI view tests → test the ViewModel/service, not the view layout itself  
- For keyboard extension changes → must test on DEVICE not simulator
- Reference `CLAUDE.md` locked decisions in any plan that touches auth, keyboard, or navigation

## Execution Handoff

After saving the plan, offer:

**"Plan saved to `docs/plans/<filename>.md`. Two options:**

**1. I implement it now** — step by step in this session with checkpoints between tasks

**2. Open a fresh session** — paste the plan in with executing-plans context

Which do you prefer?"
