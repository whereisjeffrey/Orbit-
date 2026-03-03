---
description: Brainstorming skill. Turn ideas into fully formed designs through collaborative Socratic dialogue before touching any code.
---

# Brainstorming Ideas Into Designs

*Sourced from obra/superpowers, adapted for TalkSwitch iOS.*

**Announce at start:** "I'm using the brainstorming skill — no code until we have an approved design."

## Overview

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.
Start by understanding the current project context (read `CLAUDE.md` first), then ask questions
one at a time to refine the idea. Once the design is understood, present it and get approval.

<HARD-GATE>
Do NOT write any code, create any files, or take any implementation action until you have
presented a design and the user has approved it. Every feature — even "simple" ones.
</HARD-GATE>

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every feature goes through this process. "Simple" is where unexamined assumptions cause the
most wasted work. The design can be short (a few sentences) but you MUST present and get approval.

## Checklist (in order)

1. **Explore project context** — read `CLAUDE.md`, check relevant files, recent git changes
2. **Ask clarifying questions** — one at a time, understand purpose, constraints, success criteria
3. **Propose 2–3 approaches** — with trade-offs and your recommendation
4. **Present design** — section by section, get approval after each section
5. **Write design doc** — save to `docs/plans/YYYY-MM-DD-<topic>-design.md`
6. **Hand off to planning** — invoke the writing-plans skill, nothing else

## The Process

**Understanding the idea:**
- Read `CLAUDE.md` and any relevant `.swift` files before asking questions
- Ask ONE question per message — if a topic needs more depth, break into multiple exchanges
- Prefer multiple-choice questions when possible
- Focus on: purpose, constraints, success criteria

**Exploring approaches:**
- Propose 2–3 different approaches with trade-offs
- Lead with your recommendation and explain why
- Apply YAGNI ruthlessly — remove unnecessary features from every design

**Presenting the design:**
- Once you understand what's being built, present the design
- Scale each section to its complexity (a few sentences to 200-300 words)
- Ask "does this look right so far?" after each section
- Cover: architecture, components, data flow, error handling, testing approach

## After Approval

- Save design to `docs/plans/YYYY-MM-DD-<topic>-design.md`
- Commit the design doc to git
- Then invoke the writing-plans skill — **ONLY that skill, nothing else**

## Key Principles

- **One question at a time** — don't overwhelm
- **YAGNI** — if it's not in the current scope, cut it
- **Explore alternatives** — always 2–3 approaches before settling
- **Incremental validation** — present, get approval, then move forward
- **iOS domain** — always reference `CLAUDE.md` locked decisions before proposing anything
