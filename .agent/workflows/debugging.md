---
description: How to debug any bug in this project
---

# Debugging Methodology: No Trial and Error

## The Rule
**Never attempt a fix one variable at a time.** This wastes build cycles, deploy time, and testing time.

## The Required Process

### Step 1 — Map ALL Variables First
Before touching a single line of code, produce a complete written list of every possible root cause for the observed behavior. Think adversarially — consider:
- Data pipeline: who writes the value, who reads it, are they in the same process?
- Caching: could in-memory state be stale vs. disk state?
- Lifecycle: does the function that reads state actually fire at the moment you assume?
- Fallbacks: if the primary read fails (nil), what value does the code default to, and is that default masking the real failure?
- Cross-process boundaries: App Extensions (keyboards, share extensions, widgets) run in a SEPARATE PROCESS from the main app. Shared state between them must go through an App Group container. Even with App Groups, the extension's UserDefaults cache can lag behind the main app's writes.
- Entitlements: both the main app target and every extension target must declare the same App Group identifier in their `.entitlements` file, AND in the Apple Developer Portal. A mismatch silently makes `UserDefaults(suiteName:)` return nil — all writes become no-ops.
- Order of operations: is there a race condition between two async calls that both update the same piece of UI or state?

### Step 2 — Address ALL Variables Simultaneously
Once the list is complete, implement fixes for **every item on the list** in a single pass. Do not pick the "most likely" one and try it first. This is an explicit project standard.

### Step 3 — One Build to Validate
After the comprehensive fix is deployed, perform one full rebuild and test. If it still fails, return to Step 1 with the new information and repeat.

---

## Orbit-Specific: App Group / Keyboard Extension Rules

### The App Group
All shared state between the main app and the keyboard extension flows through:
```
group.com.jeff.translatehelper
```

Both `TranslateHelper/TranslateHelper.entitlements` and
`TranslateHelperKeyboard/TranslateHelperKeyboard.entitlements` must declare this group.

### Key Naming Convention
| Key | Owner | Purpose |
|---|---|---|
| `talkswitch_target_lang` | **Main app ONLY** | The language the user is learning. Written by Onboarding and Settings. The keyboard READS this but must NEVER write to it. |
| `talkswitch_lang` | Keyboard + Main app | Transient direction key (en or target). Keyboard writes this freely. |

### The Golden Rule for the Keyboard Extension
The keyboard MUST call `UserDefaults(suiteName:)?.synchronize()` immediately before EVERY read of `talkswitch_target_lang`. The keyboard extension is a separate process with a persistent in-memory cache that does NOT automatically refresh when the main app writes new values.

### What the keyboard must never do
- Write to `talkswitch_target_lang` — this permanently destroys the user's settings choice.
- Use `selectedLanguage` as the sole fallback when reading target language — `selectedLanguage` is an in-memory variable from `viewDidLoad` and goes stale the moment the user changes Settings.

### The Lifecycle Trap
`viewWillAppear` does NOT fire on a keyboard extension if the keyboard was already loaded in memory when the user navigated away and returned. **Do not rely on lifecycle methods alone** to sync state. Always verify state at the moment-of-use (i.e., inside `performTranslation` itself).
