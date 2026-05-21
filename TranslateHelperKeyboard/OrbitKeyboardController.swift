import KeyboardKit
import SwiftUI
import Combine

/// Orbit keyboard — KeyboardKit native keyboard with Orbit features above the fold.
class OrbitKeyboardController: KeyboardInputViewController {

    let orbitState = OrbitKeyboardState()

    override func viewWillSetupKeyboardKit() {
        super.viewWillSetupKeyboardKit()

        // Match native iOS — no vibration, yes click sounds
        state.feedbackContext.settings.isHapticFeedbackEnabled = false
        state.feedbackContext.settings.isAudioFeedbackEnabled = true

        // Autocorrect via Apple's built-in UITextChecker
        let autocompleteService = UITextCheckerAutocompleteService()
        autocompleteService.locale = Locale(identifier: "en")
        services.autocompleteService = autocompleteService

        NSLog("ORBIT_KBD: configured with autocorrect")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Check for dictation result when keyboard comes back on screen
        checkForPendingDictation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Double-check — viewWillAppear doesn't always fire when iOS reuses the process
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.checkForPendingDictation()
        }
    }

    override func viewWillSetupKeyboardView() {
        NSLog("ORBIT_KBD: setting up view")

        let state = self.orbitState
        let translateAction: () -> Void = { [weak self] in self?.handleTranslate() }
        let micAction: () -> Void = { [weak self] in self?.handleMic() }
        let saveAction: () -> Void = { [weak self] in self?.handleSavePhrase() }

        setupKeyboardView { controller in
            OrbitKeyboardPage(
                services: controller.services,
                state: controller.state,
                orbitState: state,
                onTranslate: translateAction,
                onMic: micAction,
                onSave: saveAction
            )
        }
    }

    // MARK: - Translate

    private func handleTranslate() {
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let after = textDocumentProxy.documentContextAfterInput ?? ""
        let fullText = (before + after).trimmingCharacters(in: .whitespacesAndNewlines)

        guard !fullText.isEmpty else {
            NSLog("ORBIT_KBD: no text to translate")
            return
        }

        NSLog("ORBIT_KBD: translating '\(fullText.prefix(60))'")

        let detector = LanguageDetector()
        let detected = detector.detectLanguage(from: fullText) ?? "en"
        let baseCode = detected.components(separatedBy: "-").first ?? "en"
        let targetCode = LanguageManager.shared.targetLangRequired
        let native = UserDefaults(suiteName: "group.com.jeff.translatehelper")?.string(forKey: "talkswitch_native_lang") ?? "en"
        let isNative = baseCode == native || (baseCode == "en" && native == "en")
        let destLang = isNative ? targetCode : native
        let sourceProf = TSProfiles[baseCode] ?? TSProfiles["en"]!
        let destProf = TSProfiles[destLang] ?? TSProfiles[targetCode]!

        DispatchQueue.main.async {
            self.orbitState.isTranslating = true
            self.orbitState.originalText = fullText
            self.orbitState.translatedText = "Translating..."
            self.orbitState.showTranslation = true
        }

        TranslationService.shared.translate(
            text: fullText,
            from: sourceProf.deepL,
            to: destProf.deepL,
            style: .natural
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.orbitState.isTranslating = false
                switch result {
                case .success(let translation):
                    self.orbitState.translatedText = translation
                    self.clearAndInsert(translation)
                    self.orbitState.notesText = "💡 Translated with \(self.orbitState.selectedTone.displayName) tone"
                    NSLog("ORBIT_KBD: ✅ '\(fullText.prefix(30))' → '\(translation.prefix(30))'")
                case .failure(let error):
                    self.orbitState.translatedText = "⚠️ Translation failed"
                    NSLog("ORBIT_KBD: ❌ \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Mic / Dictation

    private var dictationPollTimer: Timer?

    private func handleMic() {
        // If already waiting, tap cancels
        if dictationPollTimer != nil {
            stopDictationPolling()
            orbitState.isRecording = false
            NSLog("ORBIT_KBD: dictation cancelled")
            return
        }

        // Clear existing text so the dictation result replaces it
        if let existing = textDocumentProxy.documentContextBeforeInput {
            for _ in 0..<existing.count { textDocumentProxy.deleteBackward() }
        }
        if let after = textDocumentProxy.documentContextAfterInput, !after.isEmpty {
            textDocumentProxy.adjustTextPosition(byCharacterOffset: after.count)
            for _ in 0..<after.count { textDocumentProxy.deleteBackward() }
        }

        // Write request timestamp so polling ignores stale results
        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        defaults?.set(Date().timeIntervalSince1970, forKey: "dictate_request_timestamp")
        defaults?.synchronize()

        // Open main app dictation screen
        let lang = LanguageManager.shared.targetLangRequired
        if let url = URL(string: "translatehelper://dictate?lang=\(lang)") {
            var responder: UIResponder? = self
            while let r = responder {
                if let app = r as? UIApplication { app.open(url); return }
                responder = r.next
            }
        }

        // Show recording state in the bar
        orbitState.isRecording = true
        orbitState.recordingSeconds = 0

        // Start polling for the dictation result from the main app
        startDictationPolling()
        NSLog("ORBIT_KBD: dictation started, polling")
    }

    private func startDictationPolling() {
        dictationPollTimer?.invalidate()
        // Poll every 0.5s for up to 30 seconds
        dictationPollTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForPendingDictation()
        }
        // Timeout after 30s
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            guard let self = self, self.dictationPollTimer != nil else { return }
            self.stopDictationPolling()
            self.orbitState.isRecording = false
            NSLog("ORBIT_KBD: dictation polling timed out")
        }
        // Count up timer for UI
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self, self.orbitState.isRecording else { timer.invalidate(); return }
            self.orbitState.recordingSeconds += 1
        }
    }

    private func stopDictationPolling() {
        dictationPollTimer?.invalidate()
        dictationPollTimer = nil
    }

    private func checkForPendingDictation() {
        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        let requestTs = defaults?.double(forKey: "dictate_request_timestamp") ?? 0
        let resultTs  = defaults?.double(forKey: "dictate_result_timestamp")  ?? 0
        guard resultTs > requestTs,
              let dictated = defaults?.string(forKey: "dictate_result"),
              !dictated.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Read result
        let detectedLang = defaults?.string(forKey: "dictate_result_language") ?? LanguageManager.shared.targetLangRequired

        // Clear the result from App Group
        defaults?.removeObject(forKey: "dictate_result")
        defaults?.removeObject(forKey: "dictate_result_language")
        defaults?.removeObject(forKey: "dictate_result_timestamp")
        defaults?.removeObject(forKey: "dictate_mode")
        defaults?.synchronize()

        stopDictationPolling()
        orbitState.isRecording = false

        // Clear stale text and insert dictated text
        if let after = textDocumentProxy.documentContextAfterInput, !after.isEmpty {
            textDocumentProxy.adjustTextPosition(byCharacterOffset: after.count)
        }
        while let before = textDocumentProxy.documentContextBeforeInput, !before.isEmpty {
            for _ in 0..<before.count { textDocumentProxy.deleteBackward() }
        }
        textDocumentProxy.insertText(dictated)

        NSLog("ORBIT_KBD: dictation result received: '\(dictated.prefix(40))'")

        // Auto-translate the dictated text
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.handleTranslate()
        }
    }

    // MARK: - Save

    private func handleSavePhrase() {
        let source = orbitState.originalText
        let translation = orbitState.translatedText
        guard !source.isEmpty, !translation.isEmpty,
              translation != "Translating...",
              translation != "⚠️ Translation failed" else { return }

        let appGroup = "group.com.jeff.translatehelper"
        guard let defaults = UserDefaults(suiteName: appGroup) else { return }
        let targetCode = LanguageManager.shared.targetLangRequired
        let native = defaults.string(forKey: "talkswitch_native_lang") ?? "en"

        let entry: [String: String] = [
            "id": UUID().uuidString,
            "sourceText": source,
            "translation": translation,
            "sourceLang": native,
            "targetLang": targetCode,
            "savedAt": ISO8601DateFormatter().string(from: Date())
        ]

        let key = "talkswitch_saved_phrases"
        var existing = defaults.array(forKey: key) as? [[String: String]] ?? []
        existing.insert(entry, at: 0)
        defaults.set(existing, forKey: key)
        defaults.synchronize()

        orbitState.showSavedConfirmation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.orbitState.showSavedConfirmation = false
        }
        NSLog("ORBIT_KBD: saved phrase")
    }

    // MARK: - Helpers

    private func clearAndInsert(_ text: String) {
        if let after = textDocumentProxy.documentContextAfterInput, !after.isEmpty {
            textDocumentProxy.adjustTextPosition(byCharacterOffset: after.count)
        }
        var safety = 0
        while let before = textDocumentProxy.documentContextBeforeInput, !before.isEmpty, safety < 20 {
            for _ in 0..<before.count { textDocumentProxy.deleteBackward() }
            safety += 1
        }
        textDocumentProxy.insertText(text)
    }
}

// MARK: - State

class OrbitKeyboardState: ObservableObject {
    @Published var selectedTone: Tone = .casual
    @Published var isToneExpanded = false
    @Published var isNotesOpen = false
    @Published var showTranslation = false
    @Published var isTranslating = false
    @Published var originalText = ""
    @Published var translatedText = ""
    @Published var notesText = ""
    @Published var pronunciationText = ""
    @Published var showSavedConfirmation = false
    @Published var isRecording = false
    @Published var recordingSeconds = 0
}

// MARK: - Keyboard Page

struct OrbitKeyboardPage: View {

    var services: Keyboard.Services
    var state: Keyboard.State
    @ObservedObject var orbitState: OrbitKeyboardState
    var onTranslate: () -> Void
    var onMic: () -> Void
    var onSave: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // === Orbit layer (above the fold) — reacts to orbitState ===
            OrbitOverlay(
                orbitState: orbitState,
                onTranslate: onTranslate,
                onMic: onMic,
                onSave: onSave
            )

            // === Native keyboard (below the fold) — isolated from orbitState ===
            OrbitKeyboardView(services: services, state: state)
        }
    }
}

/// Orbit UI layer — translation strip, notes, bar. Observes orbitState.
struct OrbitOverlay: View {
    @ObservedObject var orbitState: OrbitKeyboardState
    var onTranslate: () -> Void
    var onMic: () -> Void
    var onSave: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if orbitState.showTranslation {
                TranslationStrip(
                    originalText: orbitState.originalText,
                    translatedText: orbitState.translatedText,
                    onSave: onSave
                )
            }

            if orbitState.isNotesOpen && !orbitState.notesText.isEmpty {
                NotesDrawer(
                    notesText: orbitState.notesText,
                    pronunciationText: orbitState.pronunciationText,
                    onSaveToDeck: onSave,
                    onClose: { orbitState.isNotesOpen = false }
                )
            }

            OrbitBar(
                selectedTone: $orbitState.selectedTone,
                isNotesOpen: $orbitState.isNotesOpen,
                isToneExpanded: $orbitState.isToneExpanded,
                isRecording: orbitState.isRecording,
                recordingSeconds: orbitState.recordingSeconds,
                onTranslate: onTranslate,
                onMic: onMic
            )

            if orbitState.showSavedConfirmation {
                Text("✅ Saved to Deck")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.green)
                    .padding(.bottom, 2)
            }
        }
    }
}

/// Isolated KeyboardView — does NOT observe orbitState, so state changes
/// in the Orbit layer don't cause the keyboard to re-render and reset shift/caps.
struct OrbitKeyboardView: View {
    var services: Keyboard.Services
    var state: Keyboard.State

    var body: some View {
        KeyboardView(
            services: services,
            buttonContent: { params in
                if case .primary = params.item.action {
                    Text("return")
                        .font(.system(size: 16))
                } else {
                    params.view
                }
            },
            buttonView: { $0.view },
            collapsedView: { $0.view },
            emojiKeyboard: { $0.view },
            toolbar: { _ in EmptyView() }
        )
        .keyboardButtonStyle(builder: { params in
            nativeButtonStyle(for: params)
        })
        .keyboardGestureConfiguration(
            GestureButtonConfiguration(
                longPressDelay: 0.5
            )
        )
    }

    private func nativeButtonStyle(for params: Keyboard.ButtonStyleBuilderParams) -> Keyboard.ButtonStyle {
        var style = params.standardStyle()
        let isSpecialKey: Bool
        switch params.action {
        case .shift, .backspace, .keyboardType, .primary:
            isSpecialKey = true
        default:
            isSpecialKey = false
        }
        if params.isPressed {
            style.backgroundColor = isSpecialKey
                ? Color(red: 0.39, green: 0.39, blue: 0.40)
                : Color(red: 0.28, green: 0.28, blue: 0.29)
        } else {
            style.backgroundColor = isSpecialKey
                ? Color(red: 0.28, green: 0.28, blue: 0.29)
                : Color(red: 0.39, green: 0.39, blue: 0.40)
        }
        style.cornerRadius = 5
        return style
    }
}
