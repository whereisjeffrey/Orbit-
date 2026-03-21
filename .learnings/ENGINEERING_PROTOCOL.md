# Engineering Protocol
> Every agent working on this project MUST follow this protocol.
> Written after the WhisperKit Portuguese detection incident (2026-03-21).
> This is not optional. This is how we work.

---

## Rule 1: Never say "it's fixed"

**Say instead:**
- "I've made a change that should address this based on [evidence]. Let's verify."
- "The logs showed X was the problem. I've addressed X. Can you test and check for [specific log line]?"

**Never:**
- "That should be fixed now"
- "Try building again — should work"
- "The Korean should be gone"

Until the user confirms it works, it is not fixed. Period.

---

## Rule 2: Diagnose before you operate

When a bug is reported:

### Step 1: List ALL possible variables
Before writing a single line of code, enumerate every variable in the chain that could cause the symptom. Write them down. Show them to the user.

### Step 2: Add diagnostic logging for ALL variables in ONE pass
Don't add one log, test, add another log, test. Add logging for every variable at once so one test run gives us the full picture.

### Step 3: Ask for ONE test run
User tests once. Reads back the logs. Now we know exactly which variable failed.

### Step 4: Fix the actual root cause
Not the first guess. The one the logs pointed to.

### Step 5: Verify with specific expected output
Tell the user exactly what log line to look for that confirms the fix worked.

---

## Rule 3: No single-variable guessing loops

**Bad pattern (what happened):**
```
Guess A → "fixed!" → didn't work →
Guess B → "fixed!" → didn't work →
Guess C → "fixed!" → didn't work →
... 8 iterations later ...
Guess H → actually the root cause
```

**Good pattern:**
```
List variables A through H →
Add logging for all 8 →
One test → logs show H is the problem →
Fix H → verify
```

This takes 2 iterations instead of 8. It respects the user's time and energy.

---

## Rule 4: Separate essential from optional in try/catch

When initializing critical systems:
```swift
// GOOD: essential step sets state, optional step has its own catch
let pipe = try await WhisperKit(config)
sharedPipe = pipe          // ← state set immediately
sharedReady = true         // ← ready immediately

do {
    try await pipe.warmup()  // optional
} catch {
    log("warm-up failed, non-fatal")
}

// BAD: optional step can take down essential state
do {
    let pipe = try await WhisperKit(config)
    try await pipe.warmup()  // ← if this throws...
    sharedPipe = pipe         // ← ...this never runs
    sharedReady = true        // ← ...and this never runs
} catch {
    sharedReady = false       // ← everything is broken
}
```

---

## Rule 5: Track what was actually tested

After any change, log:
- What was changed
- What the expected behavior is
- What specific log output confirms success
- What the user actually reported

This prevents the "I thought we fixed that" problem where nobody can remember what was actually verified vs assumed.

---

## Rule 6: Be honest about uncertainty

It's OK to say:
- "I'm not sure if this is the root cause"
- "There are 3 possible causes — let's narrow it down"
- "I was wrong about the last fix"
- "I need more information before I can diagnose this"

It's NOT OK to:
- Present a guess as a conclusion
- Skip verification to move faster
- Blame the tool/API without evidence
- Assume a fix worked because the code looks right

---

## Rule 7: Apply to ALL work, not just bugs

This protocol applies to:
- Bug fixes (obviously)
- New feature implementation (verify each step)
- Performance optimization (measure before and after)
- Any change where the user will test the result

The core principle: **measure twice, cut once.**

---

## When to reference this document

- Before starting any debugging session
- After any failed fix attempt
- When tempted to say "it's fixed" or "should work now"
- During code review of your own changes
- At the start of every new session (read alongside CLAUDE.md and HANDOFF.md)
