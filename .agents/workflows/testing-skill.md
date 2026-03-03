---
description: TDD Skill. Never write implementation code without a failing test first.
---
# TDD Skill — TalkSwitch iOS

triggers: ["create component", "fix bug", "refactor", "new service"]
instruction: "Never write implementation code without a failing test first."

## Practical TDD for Swift/iOS

### Where Tests Are Required (before implementation)

| Layer | Test Type | Tool |
|-------|-----------|------|
| Services (`DeckGenerationService`, `AuthManager`, etc.) | Unit tests | XCTest |
| Data parsing (JSON → model) | Unit tests | XCTest |
| Business logic (spaced repetition, card scoring) | Unit tests | XCTest |
| Firestore CRUD (`DeckStore`) | Integration tests | XCTest + mock Firestore |

### Where Tests Are Pragmatic (not strictly required first)

| Layer | Reason |
|-------|--------|
| SwiftUI views | Snapshot/UI testing is brittle and slow — test logic, not layout |
| Keyboard extension UI | UIKit in extension — test the service layer, not `KeyboardViewController` layout |

## The TDD Loop (for each new service or function)

```
1. Write the test (it must fail — RED)
2. Write the minimum implementation to make it pass (GREEN)  
3. Refactor without breaking the test (REFACTOR)
```

## Example: Before adding a new method to DeckGenerationService

```swift
// ❌ WRONG — implement first, test later
func parseCards(from raw: String) throws -> [GeneratedCard] { ... }

// ✅ RIGHT — test first
func testParseCards_validJSON_returnsCards() throws {
    let json = "[{\"sourceText\":\"Hello\",\"translatedText\":\"Hola\",\"notes\":\"Basic greeting\"}]"
    let cards = try DeckGenerationService.shared.parseCards(from: json)
    XCTAssertEqual(cards.count, 1)
    XCTAssertEqual(cards[0].sourceText, "Hello")
}
// NOW write the implementation.
```

## Where to Put Tests

```
TranslateHelperTests/
  ├── DeckGenerationServiceTests.swift
  ├── AuthManagerTests.swift
  ├── SharedPhraseStoreTests.swift
  └── SpacedRepetitionTests.swift    ← when SM-2 is implemented
```

If the test target doesn't exist yet, create it via Xcode → File → New → Target → Unit Testing Bundle.
