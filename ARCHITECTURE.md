# TalkSwitch Keyboard Architecture

## Component Hierarchy

```
KeyboardViewController (UIInputViewController)
│
├── TopBarView
│   ├── TalkSwitch Button (🔄)
│   ├── Direction Label (Auto: X → Y)
│   └── Settings Button (⚙️)
│
├── ResultPanelView (Expandable)
│   ├── Handle (drag indicator)
│   ├── Output TextView (translation result)
│   ├── Tone Stack (4 buttons)
│   │   ├── 😊 Casual
│   │   ├── 📝 Neutral
│   │   ├── 💼 Professional
│   │   └── 😉 Flirty
│   └── Action Stack (4 buttons)
│       ├── Replace
│       ├── Copy
│       ├── Save
│       └── Send
│
└── Next Keyboard Button (🌐)
```

## Data Flow

```
User Types Text
    ↓
textDidChange() called
    ↓
updateCurrentInputText()
    ↓
detectLanguageAndUpdateDirection()
    ↓
LanguageDetector.detectLanguage()
    ↓
Determine direction (compose/understand)
    ↓
Update direction label
    
User Taps TalkSwitch
    ↓
topBarDidTapTalkSwitch()
    ↓
performTranslation()
    ↓
TalkSwitchAPI.translate() [STUBBED]
    ↓
Show loading state
    ↓
Wait 1 second (simulated network)
    ↓
Return mock translation
    ↓
resultPanelView.showResult()
    ↓
Panel expands with animation
    
User Taps Action Button
    ↓
Delegate method called
    ↓
├── Replace: Delete text + insert translation
├── Copy: Copy to pasteboard
├── Save: Store in PhraseStore
└── Send: Insert translation + newline
```

## Language Detection Logic

```
Input Text
    ↓
NLLanguageRecognizer.processString()
    ↓
Get dominant language + confidence
    ↓
Compare with nativeLanguage
    ↓
┌─────────────────────────────────┐
│ Detected == Native?             │
├─────────────────────────────────┤
│ YES → Compose Mode              │
│       (native → target)         │
│       Example: en → pt          │
│                                 │
│ NO  → Understand Mode           │
│       (detected → native)       │
│       Example: pt → en          │
└─────────────────────────────────┘
    ↓
Update direction label
```

## File Structure

```
TranslateHelperKeyboard/
│
├── KeyboardViewController.swift
│   └── Main controller, coordinates all components
│
├── Models/
│   └── Tone.swift
│       └── Enum: casual, neutral, professional, flirty
│
├── Services/
│   ├── LanguageDetector.swift
│   │   └── Uses NaturalLanguage framework
│   │
│   ├── TalkSwitchAPI.swift
│   │   └── Stubbed translation API
│   │
│   └── PhraseStore.swift
│       └── Local storage (UserDefaults)
│
└── Views/
    ├── TopBarView.swift
    │   └── Top UI bar with button + labels
    │
    └── ResultPanelView.swift
        └── Expandable panel with results + actions
```

## Delegate Pattern

```
┌─────────────────────────────────────────┐
│ KeyboardViewController                  │
│                                         │
│ Implements:                             │
│ • TopBarViewDelegate                    │
│ • ResultPanelViewDelegate               │
└─────────────────────────────────────────┘
         ↑                    ↑
         │                    │
    delegates to         delegates to
         │                    │
         │                    │
┌────────┴────────┐   ┌───────┴──────────┐
│ TopBarView      │   │ ResultPanelView  │
│                 │   │                  │
│ Events:         │   │ Events:          │
│ • tapTalkSwitch │   │ • tapReplace     │
│ • tapSettings   │   │ • tapCopy        │
└─────────────────┘   │ • tapSave        │
                      │ • tapSend        │
                      │ • selectTone     │
                      └──────────────────┘
```

## State Management

```
KeyboardViewController Properties:
├── currentInputText: String
├── currentDetectedLanguage: String?
├── currentDirection: TranslationMode
├── currentTone: Tone
├── lastTranslationResult: TranslationResponse?
├── nativeLanguage: String (default: "en")
└── targetLanguage: String (default: "pt")

UI State:
├── TopBarView
│   ├── isLoading: Bool
│   └── directionText: String
│
└── ResultPanelView
    ├── isExpanded: Bool
    ├── currentOutputText: String
    └── selectedTone: Tone
```

## API Contract (Stubbed)

```
Request:
┌─────────────────────────────────┐
│ TranslationRequest              │
├─────────────────────────────────┤
│ input: String                   │
│ sourceLang: String?             │
│ targetLang: String              │
│ tone: Tone                      │
│ mode: TranslationMode           │
└─────────────────────────────────┘
         ↓
    [Network Call - STUBBED]
         ↓
Response:
┌─────────────────────────────────┐
│ TranslationResponse             │
├─────────────────────────────────┤
│ output: String                  │
│ detectedSourceLang: String?     │
│ notes: String?                  │
└─────────────────────────────────┘
```

## Animation Timeline

```
User Taps TalkSwitch
    ↓
t=0ms: Show loading indicator
       Expand panel (40px → 280px)
       Animation: 300ms ease-out
    ↓
t=300ms: Panel fully expanded
         Loading indicator spinning
    ↓
t=1000ms: API returns (stubbed delay)
    ↓
t=1000ms: Hide loading indicator
          Show translation text
          Highlight selected tone button
```

## Memory Considerations

```
Keyboard Extension Constraints:
├── Limited memory (~30MB)
├── Limited execution time
└── No background execution

Optimizations:
├── Only store last 500 chars of input
├── Limit phrase storage to 100 items
├── Use lightweight UI components
├── Async/await for non-blocking API calls
└── Minimal logging in production
```

## Integration Points

```
iOS System
    ↓
textDocumentProxy (UITextDocumentProxy)
    ↓
KeyboardViewController
    ↓
├── Read: documentContextBeforeInput
├── Write: insertText()
├── Delete: deleteBackward()
└── Pasteboard: UIPasteboard.general

App Group (Optional)
    ↓
UserDefaults(suiteName: "group.com.translatehelper")
    ↓
PhraseStore
    ↓
Shared between keyboard + main app
```

## Testing Flow

```
1. Build & Install
   └── Xcode: Cmd+R

2. Enable Keyboard
   └── Settings → General → Keyboard → Keyboards → Add New Keyboard

3. Test in Notes
   ├── Type text: "Hello world"
   ├── Tap TalkSwitch
   ├── Verify: Panel expands
   ├── Verify: Shows "[Composed] Translation of: 'Hello world' (en → pt)"
   ├── Tap tone button
   ├── Verify: Re-translates with new tone
   ├── Tap Replace
   └── Verify: Text inserted into Notes

4. Test Language Detection
   ├── Type Portuguese text
   ├── Verify: Direction changes to "pt → en"
   ├── Tap TalkSwitch
   └── Verify: Shows "[Understood]" mode
```

## Future Extension Points

```
Settings Panel (TODO)
├── Language selection
├── Tone preference
└── API key configuration

Real API Integration (TODO)
├── Replace stubbed TalkSwitchAPI
├── Add error handling
├── Add retry logic
└── Add rate limiting

Enhanced UI (TODO)
├── Dark mode support
├── Haptic feedback
├── Toast notifications
└── Internal text field for preview
```
