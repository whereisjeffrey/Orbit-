---
description: Troubleshooting skill. Systematic error handling and debugging patterns to diagnose and fix problems in the TalkSwitch iOS app.
---

# Error Handling & Troubleshooting Skill

*Sourced from wshobson/agents error-handling-patterns, adapted for Swift/iOS.*

## When to Use This Skill

- A bug is reported or observed
- A crash or unexpected API error occurs
- An async/concurrent issue appears
- A feature isn't behaving as expected after a build

## Phase 1: Diagnose Before Fixing

**HARD RULE: Never write a fix before identifying the root cause.**

1. **Reproduce it** — what exact steps trigger it?
2. **Isolate the layer** — is it UI, service, API, or data?
3. **Read the actual error** — full stack trace, not just the last line
4. **Check logs** — Xcode console, Firebase console, or OpenAI spend dashboard

```
UI Layer (SwiftUI/UIKit)
  ↓ State not updating? Check @StateObject vs @ObservedObject ownership
Service Layer (AuthManager, DeckGenerationService, TalkSwitchAPI)
  ↓ async/await error? Check Task cancellation, MainActor isolation
API Layer (OpenAI, DeepL, Firebase)
  ↓ Network error? Check response codes, JSON parsing, API key validity
Data Layer (UserDefaults, Firestore, SharedPhraseStore)
  ↓ Missing data? Check app group ID, Firestore rules, UserDefaults suite name
```

## Error Categories — Swift/iOS

**Recoverable (handle gracefully):**
- Network timeouts → retry with exponential backoff
- API rate limits → queue requests, show loading state
- Firestore permission denied → re-auth, prompt sign in
- JSON parsing failure → fallback to cached data + log

**Unrecoverable (crash fast, don't hide):**
- Programming bugs (force-unwrap on nil, out-of-bounds)
- Missing required configuration (no API key, no app group)
- iOS OS requirements violated (mic in keyboard extension — LOCKED in CLAUDE.md)

## Swift Error Handling Patterns

### Pattern 1: Result Type (prefer over throws for API calls)

```swift
enum APIError: LocalizedError {
    case networkFailed(statusCode: Int)
    case parsingFailed(String)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .networkFailed(let code): return "Network error (\(code)). Check your connection."
        case .parsingFailed(let msg): return "Could not read response: \(msg)"
        case .unauthorized: return "Session expired. Please sign in again."
        }
    }
}
```

### Pattern 2: Graceful Degradation (never show blank screens)

```swift
// ✅ Always provide fallback
func loadDeck() async {
    do {
        decks = try await deckStore.fetchFromFirestore()
    } catch {
        decks = deckStore.loadFromLocalCache() // graceful fallback
        errorBanner = "Couldn't sync — showing cached decks"
    }
}
```

### Pattern 3: Never Swallow Errors

```swift
// ❌ WRONG — error disappears silently
do { try riskyThing() } catch { }

// ✅ RIGHT — log it, show it or propagate it
do { try riskyThing() } catch {
    print("⚠️ [TalkSwitch] \(#function) failed: \(error)")
    self.errorMessage = error.localizedDescription
}
```

### Pattern 4: MainActor for UI Updates

```swift
// ✅ Always update UI on main actor from async contexts
Task {
    do {
        let cards = try await DeckGenerationService.shared.generateFlirtingDeck(...)
        await MainActor.run { self.generatedCards = cards }
    } catch {
        await MainActor.run { self.generationError = error.localizedDescription }
    }
}
```

## TalkSwitch-Specific Debugging Checklist

```
□ API key issue?         → Check Config.swift and TranslateHelperKeyboard/Config.swift
□ App Group not syncing? → Verify suite: "group.com.jeff.translatehelper" in both targets
□ Keyboard not updating? → UserDefaults.standard vs UserDefaults(suiteName:) — use the group
□ Firebase auth failing? → Check GoogleService-Info.plist is in the correct target
□ OpenAI returning 429?  → Rate limit hit — check spend dashboard, consider caching
□ Navigation not working?→ Confirm NavigationStack wraps the view in MainTabView
□ Sheet not dismissing?  → Check @Environment(\.dismiss) vs isPresented binding ownership
□ Keyboard extension crash? → Never access microphone, camera, or cross-process resources
```

## Best Practices

1. **Fail fast** — validate inputs at entry points, not deep in the stack
2. **Meaningful messages** — "Translation failed (network error)" not "Error occurred"  
3. **Log at origin** — log once where the error is caught, don't re-log when re-thrown
4. **Context in errors** — include function name, relevant IDs: `"DeckStore.fetch uid=\(uid)"`
5. **User-facing vs dev logs** — `print()` for dev, `errorMessage` for users
6. **Clean up resources** — use `defer` for anything that needs teardown

## After Fixing

- Write a regression test that would have caught this bug
- Add the failure case to the relevant error enum if it was untyped
- If it was a UI-layer issue, check if the same pattern exists elsewhere
