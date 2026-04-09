import UIKit
import AVFoundation
import NaturalLanguage

struct TSLangProfile {
    let code: String
    let deepL: TranslationService.Language
    let flag: String
    let name: String
    let emojiFont: Bool // some generic flag fallback
}

let TSProfiles: [String: TSLangProfile] = [
    // Tier 1 — DeepL supported
    "en": TSLangProfile(code: "en", deepL: .english,      flag: "🇺🇸", name: "ENGLISH",     emojiFont: true),
    "pt": TSLangProfile(code: "pt", deepL: .portugueseBR,  flag: "🇧🇷", name: "PORTUGUESE",  emojiFont: true),
    "es": TSLangProfile(code: "es", deepL: .spanish,       flag: "🇪🇸", name: "SPANISH",     emojiFont: true),
    "fr": TSLangProfile(code: "fr", deepL: .french,        flag: "🇫🇷", name: "FRENCH",      emojiFont: true),
    "de": TSLangProfile(code: "de", deepL: .german,        flag: "🇩🇪", name: "GERMAN",      emojiFont: true),
    "it": TSLangProfile(code: "it", deepL: .italian,       flag: "🇮🇹", name: "ITALIAN",     emojiFont: true),
    "ja": TSLangProfile(code: "ja", deepL: .japanese,      flag: "🇯🇵", name: "JAPANESE",    emojiFont: true),
    "ko": TSLangProfile(code: "ko", deepL: .korean,        flag: "🇰🇷", name: "KOREAN",      emojiFont: true),
    "ar": TSLangProfile(code: "ar", deepL: .arabic,        flag: "🇦🇪", name: "ARABIC",      emojiFont: true),
    "zh": TSLangProfile(code: "zh", deepL: .chinese,       flag: "🇨🇳", name: "CHINESE",     emojiFont: true),
    "ru": TSLangProfile(code: "ru", deepL: .russian,       flag: "🇷🇺", name: "RUSSIAN",     emojiFont: true),
    "nl": TSLangProfile(code: "nl", deepL: .dutch,         flag: "🇳🇱", name: "DUTCH",       emojiFont: true),
    "pl": TSLangProfile(code: "pl", deepL: .polish,        flag: "🇵🇱", name: "POLISH",      emojiFont: true),
    "tr": TSLangProfile(code: "tr", deepL: .turkish,       flag: "🇹🇷", name: "TURKISH",     emojiFont: true),
    "uk": TSLangProfile(code: "uk", deepL: .ukrainian,     flag: "🇺🇦", name: "UKRAINIAN",   emojiFont: true),
    "cs": TSLangProfile(code: "cs", deepL: .czech,         flag: "🇨🇿", name: "CZECH",       emojiFont: true),
    "ro": TSLangProfile(code: "ro", deepL: .romanian,      flag: "🇷🇴", name: "ROMANIAN",    emojiFont: true),
    "bg": TSLangProfile(code: "bg", deepL: .bulgarian,     flag: "🇧🇬", name: "BULGARIAN",   emojiFont: true),
    "el": TSLangProfile(code: "el", deepL: .greek,         flag: "🇬🇷", name: "GREEK",       emojiFont: true),
    "sv": TSLangProfile(code: "sv", deepL: .swedish,       flag: "🇸🇪", name: "SWEDISH",     emojiFont: true),
    "da": TSLangProfile(code: "da", deepL: .danish,        flag: "🇩🇰", name: "DANISH",      emojiFont: true),
    "no": TSLangProfile(code: "no", deepL: .norwegian,     flag: "🇳🇴", name: "NORWEGIAN",   emojiFont: true),
    "fi": TSLangProfile(code: "fi", deepL: .finnish,       flag: "🇫🇮", name: "FINNISH",     emojiFont: true),
    "hu": TSLangProfile(code: "hu", deepL: .hungarian,     flag: "🇭🇺", name: "HUNGARIAN",   emojiFont: true),
    "sk": TSLangProfile(code: "sk", deepL: .slovak,        flag: "🇸🇰", name: "SLOVAK",      emojiFont: true),
    "id": TSLangProfile(code: "id", deepL: .indonesian,    flag: "🇮🇩", name: "INDONESIAN",  emojiFont: true),
    "vi": TSLangProfile(code: "vi", deepL: .vietnamese,    flag: "🇻🇳", name: "VIETNAMESE",  emojiFont: true),
    "he": TSLangProfile(code: "he", deepL: .hebrew,        flag: "🇮🇱", name: "HEBREW",      emojiFont: true),
    "hr": TSLangProfile(code: "hr", deepL: .croatian,      flag: "🇭🇷", name: "CROATIAN",    emojiFont: true),
    // Tier 2 — GPT-only (DeepL fallback to English, GPT refinement handles actual translation)
    "hi": TSLangProfile(code: "hi", deepL: .hindi,         flag: "🇮🇳", name: "HINDI",       emojiFont: true),
    "bn": TSLangProfile(code: "bn", deepL: .bengali,       flag: "🇧🇩", name: "BENGALI",     emojiFont: true),
    "ur": TSLangProfile(code: "ur", deepL: .urdu,          flag: "🇵🇰", name: "URDU",        emojiFont: true),
    "sw": TSLangProfile(code: "sw", deepL: .swahili,       flag: "🇰🇪", name: "SWAHILI",     emojiFont: true),
    "th": TSLangProfile(code: "th", deepL: .thai,          flag: "🇹🇭", name: "THAI",        emojiFont: true),
    "fa": TSLangProfile(code: "fa", deepL: .persian,       flag: "🇮🇷", name: "PERSIAN",     emojiFont: true),
    "ms": TSLangProfile(code: "ms", deepL: .malay,         flag: "🇲🇾", name: "MALAY",       emojiFont: true),
    "tl": TSLangProfile(code: "tl", deepL: .filipino,      flag: "🇵🇭", name: "FILIPINO",    emojiFont: true),
    "af": TSLangProfile(code: "af", deepL: .afrikaans,     flag: "🇿🇦", name: "AFRIKAANS",   emojiFont: true),
    "ta": TSLangProfile(code: "ta", deepL: .tamil,         flag: "🇮🇳", name: "TAMIL",       emojiFont: true),
    "ca": TSLangProfile(code: "ca", deepL: .catalan,       flag: "🇪🇸", name: "CATALAN",     emojiFont: true),
]

class KeyboardViewController: UIInputViewController {

    // MARK: - State

    private var heightConstraint: NSLayoutConstraint!
    private let expandedHeight: CGFloat = 340
    private let fullExpandedHeight: CGFloat = 500
    private let emptyHeight: CGFloat = 80
    private var isOutputExpanded: Bool = false
    private var isRecording: Bool = false
    private var lowConfidenceWords: [String] = []

    private var inputText: String = ""
    private var detectedLanguage: String = ""
    private var currentTone: String = "casual"
    private var selectedLanguage: String = LanguageManager.shared.targetLangRequired // persisted preference — reads from App Group

    /// The user's native language — defaults to "en" but supports any language.
    /// Read from App Group so it can be set in onboarding/settings.
    private var nativeLang: String {
        UserDefaults(suiteName: "group.com.jeff.translatehelper")?.string(forKey: "talkswitch_native_lang") ?? "en"
    }
    private var lastSourceWasSpeech: Bool = false
    private var lastSpeechDetectedLang: String = ""  // WhisperKit's language detection (more reliable than text detection)
    private var deferredPostTranslation: DispatchWorkItem?  // cancelled on Replace so keyboard releases instantly
    private var lastTranslationText: String = ""      // de-duplicate guard
    private var lastTranslationTime: TimeInterval = 0 // de-duplicate guard

    // MARK: - Wingman State
    private var isWingmanMode: Bool = false
    private var wingmanOnboardingShown: Bool = false
    private var wingmanOptions: [TalkSwitchAPI.WingmanOption] = []
    private var isLoadingWingman: Bool = false
    private var currentWingmanIndex: Int = 0

    // MARK: - Paste Detection
    private var previousTextLength: Int = 0
    private var translationsSent: Int = 0
    private var isPasteTranslationActive: Bool = false  // blocks normal translate from overriding paste
    #if DEBUG
    private var pasteHintShown: Bool = false  // resets each session in debug
    #else
    private var pasteHintShown: Bool = false
    #endif

    // MARK: - UI Elements

    private let emptyBar = UIView()
    private let emptyLabel = UILabel()
    private let langPill = UIButton(type: .system)
    private let micButton = UIButton(type: .system)

    private let panel = UIView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private var enhancedVoiceBanner: UIView?
    private var translationVersion: Int = 0
    private var recentNoteTopics: [String] = []  // tracks recent slang/notes to avoid repeats

    // Translate clipboard button + Remove button + layout constraints
    private let translateClipboardBtn = UIButton(type: .system)
    private let removeBtn = UIButton(type: .system)
    private var micLeadingToEdge: NSLayoutConstraint!    // full width (no translate/remove)
    private var micLeadingToThird: NSLayoutConstraint!   // right third (translate + remove visible)
    private var translationHistory: [String] = []
    private var pendingTranslationTasks: [URLSessionTask] = []  // cancel on new translation
    private var currentHistoryIndex: Int = -1
    private let swipeHintLabel = UILabel()

    // Recording bar controls (WhatsApp-style)
    private let trashRecordBtn   = UIButton(type: .system)
    private let sendRecordBtn    = UIButton(type: .system)
    private let recordingDotLbl  = UILabel()
    private let recordingTimeLbl = UILabel()
    private var recordingTimer:  Timer?
    private var blinkTimer:      Timer?
    private var recordingSeconds = 0

    private let directionLabel = UILabel()
    private let inputCard = UIView()
    private let inputLangLabel = UILabel()
    private let inputTextLabel = UILabel()
    private let outputCard = UIView()
    private let outputLangLabel = UILabel()
    private let outputTextLabel = UILabel()
    private let notesCard = UIView()
    private let notesIcon = UILabel()
    private let notesTextLabel = UILabel()
    
    private let correctionCard = UIView()
    private let correctionIcon = UILabel()
    private let correctionHeader = UILabel()
    private let correctionTextLabel = UILabel()

    private let coachCard = UIView()
    private let hintCard = UIView()
    private let hintTextLabel = UILabel()
    private let coachIcon = UILabel()
    private let coachHeader = UILabel()
    private let coachTextLabel = UILabel()
    private let toneStack = UIStackView()
    private let actionStack = UIStackView()

    // Wingman UI
    private let wingmanToggle = UIStackView()
    private let wingmanOptionsStack = UIStackView()
    private let wingmanOnboardingCard = UIView()

    // Paste translation icons
    private let pastePlayBtn = UIButton(type: .system)   // speaker on input card (Portuguese)
    private let pasteClearBtn = UIButton(type: .system)   // X on output card (clear & dismiss)
    private let loadingSpinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.translatesAutoresizingMaskIntoConstraints = false
        s.hidesWhenStopped = true
        s.color = UIColor.systemBlue.withAlphaComponent(0.6)
        return s
    }()

    private let tones: [(id: String, label: String, icon: String)] = [
        ("casual",  "Casual",  "😊"),
        ("slang",   "Slang",   "🗣️"),
        ("work",    "Work",    "💼"),
        ("flirty",  "Flirty",  "🔥")
    ]

    // MARK: - Colors (always dark — consistent premium feel regardless of system theme)

    private var panelBg: UIColor {
        UIColor(red: 0.13, green: 0.13, blue: 0.14, alpha: 1.0)
    }
    private var cardBg: UIColor {
        UIColor(white: 0.18, alpha: 1.0)
    }
    private var textPrimary: UIColor {
        .white
    }
    private var textSecondary: UIColor {
        UIColor(white: 0.6, alpha: 1.0)
    }


    // MARK: - Lifecycle

    private func checkForPendingDictation() {
        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        let requestTs = defaults?.double(forKey: "dictate_request_timestamp") ?? 0
        let resultTs  = defaults?.double(forKey: "dictate_result_timestamp")  ?? 0
        guard resultTs > requestTs,
              let dictated = defaults?.string(forKey: "dictate_result"),
              !dictated.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Read language + mode written by DictateViewController
        let detectedLang = defaults?.string(forKey: "dictate_result_language") ?? selectedLanguage
        let dictateMode  = defaults?.string(forKey: "dictate_mode") ?? ""

        defaults?.removeObject(forKey: "dictate_result")
        defaults?.removeObject(forKey: "dictate_result_language")
        defaults?.removeObject(forKey: "dictate_result_timestamp")
        defaults?.removeObject(forKey: "dictate_mode")
        defaults?.synchronize()

        stopDictationPolling()

        // Append dictated text to whatever is already in the field (cumulative)
        let existingBefore = textDocumentProxy.documentContextBeforeInput ?? ""
        let existingAfter  = textDocumentProxy.documentContextAfterInput  ?? ""
        let existingText   = (existingBefore + existingAfter).trimmingCharacters(in: .whitespacesAndNewlines)
        let separator      = existingText.isEmpty ? "" : " "
        textDocumentProxy.insertText(separator + dictated)

        // Brief delay so the proxy updates, then read full combined text
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            guard let self = self else { return }
            let before = self.textDocumentProxy.documentContextBeforeInput ?? ""
            let after  = self.textDocumentProxy.documentContextAfterInput  ?? ""
            let fullText = (before + after).trimmingCharacters(in: .whitespacesAndNewlines)
            let textToTranslate = fullText.isEmpty ? dictated : fullText

            self.lastSourceWasSpeech = true
            self.lastSpeechDetectedLang = detectedLang

            // Accent-coach mode: speech was recorded in the target language for pronunciation critique.
            // Force into the gentle-correction / native-speaker feedback path.
            let targetCode = LanguageManager.shared.targetLangRequired
            if dictateMode == "accent_coach" || detectedLang == targetCode {
                self.performTranslation(text: textToTranslate, source: "accent_coach")
            } else {
                self.performTranslation(text: textToTranslate, source: "speech")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Sync with iOS dictation language slider
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(inputModeChanged),
            name: UITextInputMode.currentInputModeDidChangeNotification,
            object: nil
        )
        NSLog("TSKBD_LOADED ✅")

        // Validate: target language must be set (onboarding writes it at step 1)
        if !LanguageManager.shared.hasTargetLanguage {
            NSLog("⚠️ TSKBD: No target language set — user may not have completed onboarding")
        }

        // Restore persisted language preference
        let appGroup = "group.com.jeff.translatehelper"
        let defaults = UserDefaults(suiteName: appGroup)
        let saved = defaults?.string(forKey: "talkswitch_lang") ?? LanguageManager.shared.targetLangRequired
        selectedLanguage = saved
        updateLangPill()

        // Signal to the main app that the keyboard has been activated at least once.
        // LibraryView's KeyboardSetupBanner reads this to auto-hide itself.
        if defaults?.bool(forKey: "keyboard_has_launched") != true {
            defaults?.set(true, forKey: "keyboard_has_launched")
            defaults?.synchronize()
        }

        #if DEBUG
        // Reset the Natural Voice banner counter on every launch in debug builds
        // so the purple card is always testable without having to reinstall.
        UserDefaults.standard.removeObject(forKey: Self.kVoiceBannerCount)
        UserDefaults.standard.removeObject(forKey: Self.kVoiceBannerDismissed)
        #endif


        // Force dark appearance — all system colors resolve to dark variants,
        // so alpha-blended cards look correct regardless of host app theme.
        overrideUserInterfaceStyle = .dark

        heightConstraint = view.heightAnchor.constraint(equalToConstant: emptyHeight)
        heightConstraint.priority = .required
        heightConstraint.isActive = true
        view.backgroundColor = panelBg

        setupEmptyBar()
        setupPanel()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.autoDetect()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Cancel all pending API calls and flush buffers before keyboard dismisses
        TalkSwitchAPI.shared.cancelAllTasks()
        TalkSwitchAPI.shared.flushPersonaBuffer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // iOS is about to kill us — dump everything non-essential to survive
        TalkSwitchAPI.shared.cancelAllTasks()
        TalkSwitchAPI.shared.flushPersonaBuffer()
        SpeechService.shared.clearAudioCache()
        translationHistory.removeAll()
        NSLog("TSKBD_MEMORY: ⚠️ memory warning — cleared all caches")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForPendingDictation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.autoDetect()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Re-run autoDetect when keyboard becomes visible again — viewWillAppear
        // doesn't always fire when iOS reuses the keyboard process.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            guard let self = self else { return }
            // Only run if we're showing the empty bar but there's text in the field
            if !self.emptyBar.isHidden {
                let before = self.textDocumentProxy.documentContextBeforeInput ?? ""
                let after = self.textDocumentProxy.documentContextAfterInput ?? ""
                let text = (before + after).trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty {
                    self.autoDetect()
                }
            }
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            view.backgroundColor = panelBg
            applyColors()
        }
    }

    // MARK: - Auto Detection

    private func autoDetect() {
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let after  = textDocumentProxy.documentContextAfterInput  ?? ""
        let fieldText = (before + after).trimmingCharacters(in: .whitespacesAndNewlines)

        guard !fieldText.isEmpty else { showEmpty(); return }

        // Check if the text in the field is in the target language.
        // If so, the user likely pasted an incoming message — translate to English.
        let targetCode = LanguageManager.shared.targetLangRequired

        if fieldText.count >= 8 {
            let detected = detectLanguage(fieldText)
            let recognizer = NLLanguageRecognizer()
            recognizer.processString(fieldText)
            let nlLang = recognizer.dominantLanguage?.rawValue.components(separatedBy: "-").first ?? "und"

            let isTargetLang = detected.code == targetCode || nlLang == targetCode
            let isNotNative = (detected.code != nativeLang && detected.code != "und") ||
                              (nlLang != nativeLang && nlLang != "und")

            if isTargetLang || isNotNative {
                // Non-native text in field — go to small keyboard with Translate button.
                // Don't try to translate from the proxy (it truncates unpredictably).
                // User taps Translate → reads full clipboard → complete translation.
                NSLog("TSKBD_AUTODETECT: non-native text — showing Speak + Translate")
                showEmpty()
                return
            }
        }

        previousTextLength = fieldText.count
        performTranslation(text: fieldText, source: "field")
    }

    private func performTranslation(text: String, source: String) {
        // ── De-duplicate: skip if same text was already submitted within 3 seconds ──
        let now = Date().timeIntervalSince1970
        if text == lastTranslationText && (now - lastTranslationTime) < 3.0 {
            NSLog("TSKBD_DEDUP: skipping duplicate — source=\(source) (%.1fs since last)", now - lastTranslationTime)
            return
        }
        lastTranslationText = text
        lastTranslationTime = now
        NSLog("TSKBD_TRANSLATE: source=\(source) text='\(text.prefix(40))'")
        // Cancel ALL pending API tasks from previous translations — frees memory immediately
        TalkSwitchAPI.shared.cancelAllTasks()

        inputText = text

        let detected = detectLanguage(text)
        detectedLanguage = detected.code

        let appGroup = "group.com.jeff.translatehelper"
        let defaults = UserDefaults(suiteName: appGroup)
        let targetCode = LanguageManager.shared.targetLangRequired

        // Accent-coach mode: user spoke Spanish for pronunciation practice.
        // Force the isSourceTarget flag so we always enter the gentle-correction path
        // regardless of what detectLanguage() returns (numbers, proper nouns etc. can
        // look like English to the heuristic even when the words are Spanish).
        let isSourceTarget = source == "accent_coach" ? true : (detected.code == targetCode)
        let native = nativeLang
        let inProf = isSourceTarget ? (TSProfiles[targetCode] ?? TSProfiles["es"]!) : (TSProfiles[native] ?? TSProfiles["en"]!)
        let outProf = isSourceTarget ? (TSProfiles[native] ?? TSProfiles["en"]!) : (TSProfiles[targetCode] ?? TSProfiles["es"]!)

        // Direction header + language mapping
        if isSourceTarget {
            directionLabel.text = inProf.flag
        } else {
            directionLabel.text = "\(inProf.flag) → \(outProf.flag)"
        }

        inputLangLabel.text = "\(inProf.flag) \(inProf.name)"
        outputLangLabel.text = "\(outProf.flag) \(outProf.name)"

        let sourceLang = inProf.deepL
        let targetLang = outProf.deepL

        // Input
        inputTextLabel.text = text

        // Show loading state
        outputTextLabel.text = "Translating..."
        showPanel()
        loadingSpinner.startAnimating()

        // Map tone to DeepL style
        let style: TranslationService.TranslationStyle
        switch currentTone {
        case "casual", "slang", "flirty": style = .casual
        case "work": style = .formal
        default: style = .natural
        }

        // Target language speech — show corrected version in output card (same UI as English path)
        let targetName = TSProfiles[targetCode]?.name.capitalized ?? "target language"
        if isSourceTarget {
            // Show output card (corrected version goes here) + correction card (tips)
            // Hide input card — it's redundant with the WhatsApp text box
            self.inputCard.isHidden = true
            self.outputCard.isHidden = false
            self.correctionCard.isHidden = false
            self.correctionCard.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.05)
            self.correctionIcon.text = "💬"
            self.correctionHeader.text = "NATIVE"
            self.correctionTextLabel.text = "Analyzing your \(targetName)..."
            self.coachCard.isHidden = true

            // Input card shows original text with target language flag
            inputLangLabel.text = "\(TSProfiles[targetCode]?.flag ?? "🌐") \(TSProfiles[targetCode]?.name ?? targetCode)"
            inputTextLabel.text = text

            // Output card shows loading state
            outputLangLabel.text = "\(TSProfiles[targetCode]?.flag ?? "🌐") \(targetName.uppercased())"
            outputTextLabel.text = "Translating..."
            showPanel()

            // Defer coaching tips — cancelled if user taps Replace
            if source == "accent_coach" {
                lowConfidenceWords = ["[spoken aloud — focus on accent, rhythm, and pronunciation tips]"]
                let spokenLang = self.lastSpeechDetectedLang.isEmpty ? targetCode : self.lastSpeechDetectedLang
                let work = DispatchWorkItem { [weak self] in
                    self?.fetchCoachingTipsForCorrectionCard(spokenText: text, spokenLanguage: spokenLang)
                }
                self.deferredPostTranslation = work
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
            }

            // Send directly to OpenAI for correction + tone (skip DeepL — same language)
            let tone = Tone(rawValue: self.currentTone) ?? .casual

            TalkSwitchAPI.shared.refineTranslation(
                original: text,
                deeplTranslation: text,  // no DeepL translation — pass original as the "base"
                sourceLang: targetCode,
                targetLang: targetCode,  // same language — correction, not translation
                tone: tone
            ) { [weak self] refineResult in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.loadingSpinner.stopAnimating()

                    switch refineResult {
                    case .success(let refined):
                        self.translationHistory = [refined.output]
                        self.currentHistoryIndex = 0
                        self.outputTextLabel.text = refined.output
                        self.updateSwipeHint()

                        if let notes = refined.notes {
                            self.correctionCard.isHidden = false
                            self.correctionIcon.text = "💬"
                            self.correctionHeader.text = "NATIVE"
                            self.correctionTextLabel.text = "💡 \(self.capToTwoSentences(notes))"
                        }

                        NSLog("TSKBD_CORRECTED: \(text) → \(refined.output)")
                        // Defer post-correction work — no immediate API calls
                        let hasNotes = refined.notes != nil
                        self.deferredPostTranslation?.cancel()
                        let work = DispatchWorkItem { [weak self] in
                            guard let self = self else { return }
                            if !hasNotes { self.updateNotes(original: text, translated: refined.output) }
                            TalkSwitchAPI.shared.recordTranslationForPersona(original: text, translated: refined.output, tone: tone)
                        }
                        self.deferredPostTranslation = work
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)

                    case .failure:
                        // Correction failed — show original text as-is
                        self.translationHistory = [text]
                        self.currentHistoryIndex = 0
                        self.outputTextLabel.text = text
                        self.updateSwipeHint()
                        self.correctionHeader.text = "NATIVE"
                        self.correctionTextLabel.text = "Your \(targetName) sounds good here."
                        NSLog("TSKBD_CORRECT_FALLBACK: showing original text")
                    }
                }
            }

            // Fire gentle correction — only for mistake tracking, don't overwrite UI
            // (refinement already set the correction card text — avoid flash)
            TalkSwitchAPI.shared.getGentleCorrection(text: text, language: targetCode) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let correction):
                        if correction.severity != "natural" {
                            // Queue mistake for profile — but don't touch the correction card
                            self?.queueMistakeForProfile(
                                userSaid: correction.userSaid,
                                nativeSay: correction.nativeSay,
                                explanation: correction.explanation,
                                category: correction.category,
                                language: targetCode
                            )
                        }
                    case .failure:
                        break
                    }
                }
            }

            return // Skip DeepL — we're correcting, not translating

        } else {
            self.correctionCard.isHidden = true
            self.outputCard.isHidden = false
            // Show X on input card so user can always clear, hide X on output
            self.pastePlayBtn.isHidden = false   // X on input card
            self.pasteClearBtn.isHidden = true    // no X on output (speaker is there)
        }

        // Call DeepL API first (always)
        TranslationService.shared.translate(
            text: text,
            from: sourceLang,
            to: targetLang,
            style: style
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let translation):
                    self.translationVersion = 0
                    NSLog("TSKBD_TRANSLATED: \(text) → \(translation)")

                    let tone = Tone(rawValue: self.currentTone) ?? .casual

                    // ── Fire speech coaching tips (only when speaking in target language) ──
                    let spokenLang = self.lastSourceWasSpeech && !self.lastSpeechDetectedLang.isEmpty
                        ? self.lastSpeechDetectedLang
                        : detected.code
                    if self.lastSourceWasSpeech && spokenLang != self.nativeLang {
                        // Defer coaching tips — cancelled if user taps Replace
                        let coachWork = DispatchWorkItem { [weak self] in
                            self?.fetchCoachingTips(spokenText: text, spokenLanguage: spokenLang)
                        }
                        self.deferredPostTranslation = coachWork
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: coachWork)
                    } else {
                        self.coachCard.isHidden = true
                    }

                    // ── Refinement path: keep spinner until GPT returns ──
                    let needsRefinement = self.currentTone == "slang"
                        || self.currentTone == "flirty"
                        || self.currentTone == "casual"
                        || self.currentTone == "work"

                    if needsRefinement {
                        // Show refining state while GPT polishes the DeepL translation
                        self.outputTextLabel.text = "✨ Refining..."
                        let langCode = detected.code

                        TalkSwitchAPI.shared.refineTranslation(
                            original: text,
                            deeplTranslation: translation,
                            sourceLang: langCode,
                            targetLang: targetCode,
                            tone: tone
                        ) { [weak self] refineResult in
                            DispatchQueue.main.async {
                                guard let self = self else { return }
                                switch refineResult {
                                case .success(let refined):
                                    self.loadingSpinner.stopAnimating()
                                    // Show ONLY the final refined translation — one reveal, no flicker
                                    self.translationHistory = [refined.output]
                                    self.currentHistoryIndex = 0
                                    self.outputTextLabel.text = refined.output
                                    self.updateSwipeHint()
                                    if let notes = refined.notes {
                                        self.notesCard.isHidden = false
                                        let icon: String
                                        switch self.currentTone {
                                        case "flirty": icon = "😏"
                                        case "slang":  icon = "🔥"
                                        default:       icon = "💬"
                                        }
                                        self.notesTextLabel.text = "\(icon) \(self.capToTwoSentences(notes))"
                                    }
                                    NSLog("TSKBD_REFINED: \(text) → \(refined.output)")
                                    // ── Defer post-translation work — cancelled if user taps Replace ──
                                    let hasRefinedNotes = refined.notes != nil
                                    self.deferredPostTranslation?.cancel()
                                    let work = DispatchWorkItem { [weak self] in
                                        guard let self = self else { return }
                                        // Skip updateNotes if refinement already provided notes — avoids flash
                                        if !hasRefinedNotes {
                                            self.updateNotes(original: text, translated: refined.output)
                                        }
                                        TalkSwitchAPI.shared.recordTranslationForPersona(original: text, translated: refined.output, tone: tone)
                                        self.queueTTSCache(text: refined.output, language: targetCode)
                                    }
                                    self.deferredPostTranslation = work
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
                                    // Progressive hints — spaced out across first few translations
                                    self.translationsSent += 1
                                    if self.translationsSent == 1 {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                            self.showPasteHint()
                                        }
                                    } else if self.translationsSent == 3 {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                            self.showSaveHint()
                                        }
                                    }
                                case .failure:
                                    self.loadingSpinner.stopAnimating()
                                    // Refinement failed — show DeepL translation as fallback
                                    self.translationHistory = [translation]
                                    self.currentHistoryIndex = 0
                                    self.outputTextLabel.text = translation
                                    self.updateSwipeHint()
                                    NSLog("TSKBD_REFINE_FALLBACK: using DeepL translation")
                                    // ── Defer post-translation work — cancelled if user taps Replace ──
                                    self.deferredPostTranslation?.cancel()
                                    let work = DispatchWorkItem { [weak self] in
                                        guard let self = self else { return }
                                        self.updateNotes(original: text, translated: translation)
                                        TalkSwitchAPI.shared.recordTranslationForPersona(original: text, translated: translation, tone: tone)
                                    }
                                    self.deferredPostTranslation = work
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
                                }
                            }
                        }
                    } else {
                        // No refinement needed — show DeepL translation directly
                        self.loadingSpinner.stopAnimating()
                        self.translationHistory = [translation]
                        self.currentHistoryIndex = 0
                        self.outputTextLabel.text = translation
                        self.updateSwipeHint()
                        // ── Defer post-translation work — cancelled if user taps Replace ──
                        self.deferredPostTranslation?.cancel()
                        let work = DispatchWorkItem { [weak self] in
                            guard let self = self else { return }
                            self.updateNotes(original: text, translated: translation)
                            TalkSwitchAPI.shared.recordTranslationForPersona(original: text, translated: translation, tone: tone)
                            self.queueTTSCache(text: translation, language: targetCode)
                        }
                        self.deferredPostTranslation = work
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
                    }

                case .failure(let error):
                    self.loadingSpinner.stopAnimating()
                    self.outputTextLabel.text = "⚠️ Translation failed"
                    self.notesCard.isHidden = false
                    self.notesTextLabel.text = "Error: \(error.localizedDescription)"
                    NSLog("TSKBD_ERROR: \(error.localizedDescription)")
                }
            }
        }
    }

    /// Hard-caps any notes string to 2 sentences max, regardless of what GPT returned.
    private func capToTwoSentences(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Cap to ONE sentence
        var firstSentence = ""
        for char in trimmed {
            firstSentence.append(char)
            if char == "." || char == "!" || char == "?" {
                break
            }
        }
        let result = firstSentence.isEmpty ? trimmed : firstSentence.trimmingCharacters(in: .whitespaces)
        // Hard cap at 80 characters — if GPT still rambles, we cut it
        if result.count > 80 {
            let cutoff = result.index(result.startIndex, offsetBy: 77)
            if let lastSpace = result[result.startIndex..<cutoff].lastIndex(of: " ") {
                return String(result[result.startIndex..<lastSpace]) + "…"
            }
            return String(result[result.startIndex..<cutoff]) + "…"
        }
        return result
    }

    private func updateNotes(original: String, translated: String) {
        // Always show notes with smart coaching from OpenAI
        notesCard.isHidden = false
        notesTextLabel.text = "💭 Loading tips..."
        
        let detected = detectLanguage(original)
        let sourceLang = detected.code
        let appGroupNotes = "group.com.jeff.translatehelper"
        let targetCode = LanguageManager.shared.targetLangRequired
        // Notes are always ABOUT the target language phrase, regardless of direction.
        // When user speaks Portuguese, sourceLang = "pt" and we want notes about Portuguese.
        // When user types English, sourceLang = "en" and we want notes about Portuguese.
        // In both cases, targetLang should be the target language.
        let targetLang = targetCode
        let tone = Tone(rawValue: currentTone) ?? .casual
        
        // Add pronunciation context if we have low-confidence words from speech
        let pronunciationContext: String?
        if !lowConfidenceWords.isEmpty {
            pronunciationContext = "The user SPOKE this (not typed). These words had low recognition confidence (possible mispronunciation): \(lowConfidenceWords.joined(separator: ", ")). Include pronunciation tips for these words."
            lowConfidenceWords = [] // Reset for next use
        } else {
            pronunciationContext = nil
        }
        
        // Pass recent note topics so the model mixes things up — not a hard ban, just variety
        let recentContext = recentNoteTopics.isEmpty ? nil :
            "VARIETY: These phrases were covered recently — mix it up and teach something different if possible. Don't ban them entirely, but avoid explaining the same phrase multiple times in a session: \(recentNoteTopics.suffix(10).joined(separator: ", "))"

        TalkSwitchAPI.shared.getSmartNotes(
            original: original,
            translated: translated,
            sourceLang: sourceLang,
            targetLang: targetLang,
            tone: tone,
            pronunciationContext: pronunciationContext,
            recentNotesContext: recentContext
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let notes):
                    let capped = self.capToTwoSentences(notes)

                    // Safety net: if GPT wrote the note entirely in the target language
                    // instead of English, discard it.
                    let noteRecognizer = NLLanguageRecognizer()
                    noteRecognizer.processString(capped)
                    let noteLang = noteRecognizer.dominantLanguage?.rawValue.components(separatedBy: "-").first ?? "en"
                    if noteLang != "en" && noteLang != "und" {
                        NSLog("TSKBD_NOTES: rogue note in \(noteLang), hiding")
                        self.notesCard.isHidden = true
                        return
                    }

                    self.notesTextLabel.text = capped
                    // Track this note's key phrase to avoid future repeats
                    let words = capped.components(separatedBy: "'")
                    if words.count >= 2 {
                        self.recentNoteTopics.append(words[1])  // extract quoted phrase
                        if self.recentNoteTopics.count > 15 {
                            self.recentNoteTopics.removeFirst()
                        }
                    }
                case .failure(let error):
                    self.notesTextLabel.text = "⚠️ Error loading phrase tips: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Speech Coaching Tips (per-audio)

    /// Fetches coaching tips and appends them to the correction card (for target-language speech).
    /// Shows pronunciation tip with 🗣 and grammar tip with 💡, below the native correction.
    private func fetchCoachingTipsForCorrectionCard(spokenText: String, spokenLanguage: String) {
        let mistakeProfile = ""  // TODO: load from UserDefaults once profile system is built

        TalkSwitchAPI.shared.getSpeechCoachingTips(
            spokenText: spokenText,
            spokenLanguage: spokenLanguage,
            nativeLanguage: nativeLang,
            mistakeProfile: mistakeProfile
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let tips):
                    var tipLines: [String] = []
                    if let pron = tips.pronunciationTip {
                        tipLines.append("🗣 \(self.capToTwoSentences(pron))")
                    }
                    if let gram = tips.grammarTip {
                        tipLines.append("💡 \(self.capToTwoSentences(gram))")
                    }
                    guard !tipLines.isEmpty else { return }

                    // Replace correction text with coaching tips (don't stack)
                    self.correctionTextLabel.text = tipLines.joined(separator: "\n\n")
                    NSLog("TSKBD_COACH: pron=\(tips.pronunciationTip ?? "none") gram=\(tips.grammarTip ?? "none")")
                case .failure(let error):
                    NSLog("TSKBD_COACH_ERROR: \(error.localizedDescription)")
                }
            }
        }
    }

    /// Fetches coaching tips for the English→target translation path (shown in separate coach card).
    /// Only fires for voice messages where the user spoke in the target language.
    private func fetchCoachingTips(spokenText: String, spokenLanguage: String) {
        coachCard.isHidden = false
        coachTextLabel.text = "🎯 Analyzing your speech..."

        let mistakeProfile = ""

        TalkSwitchAPI.shared.getSpeechCoachingTips(
            spokenText: spokenText,
            spokenLanguage: spokenLanguage,
            nativeLanguage: nativeLang,
            mistakeProfile: mistakeProfile
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let tips):
                    var lines: [String] = []
                    if let pron = tips.pronunciationTip {
                        lines.append("🗣 \(pron)")
                    }
                    if let gram = tips.grammarTip {
                        lines.append("💡 \(gram)")
                    }
                    if lines.isEmpty {
                        self.coachCard.isHidden = true
                    } else {
                        self.coachTextLabel.text = lines.joined(separator: "\n\n")
                    }
                    NSLog("TSKBD_COACH: pron=\(tips.pronunciationTip ?? "none") gram=\(tips.grammarTip ?? "none")")
                case .failure(let error):
                    self.coachCard.isHidden = true
                    NSLog("TSKBD_COACH_ERROR: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showBasicNotes(original: String) {
        let lower = original.lowercased()
        let idioms = ["let it slide", "off the hook", "break a leg", "piece of cake",
                       "hang in there", "no big deal", "hit the nail", "under the weather",
                       "qué onda", "no manches", "está chido", "órale", "sale",
                       "de nada", "con todo", "ya estuvo", "a huevo", "chamba"]
        let foundIdiom = idioms.first(where: { lower.contains($0) })

        if let idiom = foundIdiom {
            notesTextLabel.text = "💡 \"\(idiom)\" is an idiom — translated for meaning, not literally."
        } else {
            let targetCode = LanguageManager.shared.targetLangRequired
            let detected = detectLanguage(original).code
            if detected == targetCode {
                notesTextLabel.text = "💡 Keep practicing! Your local slang notes will appear here."
            } else {
                notesCard.isHidden = true
            }
        }
    }

    // MARK: - Empty State

    private func setupEmptyBar() {
        emptyBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyBar)
        NSLayoutConstraint.activate([
            emptyBar.topAnchor.constraint(equalTo: view.topAnchor),
            emptyBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyBar.heightAnchor.constraint(equalToConstant: emptyHeight),
        ])

        // Shared style — matches the action buttons in the big keyboard (Replace/Save/Speak)
        let btnStyle: (UIButton, String) -> Void = { btn, title in
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.setTitle(title, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            btn.layer.cornerRadius = 10
            btn.layer.borderWidth = 1.0
            btn.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
            btn.clipsToBounds = true
        }

        // Remove button (far left — clears text field)
        btnStyle(removeBtn, "🗑️ Remove")
        removeBtn.isHidden = true
        removeBtn.addTarget(self, action: #selector(removeTextTapped), for: .touchUpInside)
        emptyBar.addSubview(removeBtn)

        // Translate button (center)
        btnStyle(translateClipboardBtn, "📋 Translate")
        translateClipboardBtn.isHidden = true
        translateClipboardBtn.addTarget(self, action: #selector(translateClipboardTapped), for: .touchUpInside)
        emptyBar.addSubview(translateClipboardBtn)

        // Speak button (far right)
        btnStyle(micButton, "🎤 Speak")
        micButton.addTarget(self, action: #selector(micTapped), for: .touchUpInside)
        emptyBar.addSubview(micButton)

        // langPill and emptyLabel kept as hidden
        langPill.translatesAutoresizingMaskIntoConstraints = false
        langPill.isHidden = true
        emptyBar.addSubview(langPill)
        updateLangPill()

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.isHidden = true
        emptyBar.addSubview(emptyLabel)

        // Switchable constraints for mic button leading edge
        micLeadingToEdge = micButton.leadingAnchor.constraint(equalTo: emptyBar.leadingAnchor, constant: 10)
        micLeadingToThird = micButton.leadingAnchor.constraint(equalTo: translateClipboardBtn.trailingAnchor, constant: 6)
        micLeadingToEdge.isActive = true

        NSLayoutConstraint.activate([
            // Mic (Speak) — right, fixed 38pt height, centered vertically
            micButton.trailingAnchor.constraint(equalTo: emptyBar.trailingAnchor, constant: -10),
            micButton.centerYAnchor.constraint(equalTo: emptyBar.centerYAnchor),
            micButton.heightAnchor.constraint(equalToConstant: 38),

            // Remove — left, fixed 38pt height, centered vertically
            removeBtn.leadingAnchor.constraint(equalTo: emptyBar.leadingAnchor, constant: 10),
            removeBtn.centerYAnchor.constraint(equalTo: emptyBar.centerYAnchor),
            removeBtn.heightAnchor.constraint(equalToConstant: 38),

            // Translate — center, fixed 38pt height, centered vertically
            translateClipboardBtn.leadingAnchor.constraint(equalTo: removeBtn.trailingAnchor, constant: 6),
            translateClipboardBtn.centerYAnchor.constraint(equalTo: emptyBar.centerYAnchor),
            translateClipboardBtn.heightAnchor.constraint(equalToConstant: 38),
            translateClipboardBtn.widthAnchor.constraint(equalTo: removeBtn.widthAnchor),

            // All three equal width
            micButton.widthAnchor.constraint(equalTo: removeBtn.widthAnchor),

            langPill.trailingAnchor.constraint(equalTo: emptyBar.trailingAnchor, constant: -12),
            langPill.centerYAnchor.constraint(equalTo: emptyBar.centerYAnchor),
            langPill.heightAnchor.constraint(equalToConstant: 26),

            emptyLabel.centerXAnchor.constraint(equalTo: emptyBar.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: emptyBar.centerYAnchor),
        ])

        // ── Recording bar (hidden until mic is tapped) ──────────────────────
        // Trash / cancel (left)
        trashRecordBtn.translatesAutoresizingMaskIntoConstraints = false
        let trashCfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        trashRecordBtn.setImage(UIImage(systemName: "trash", withConfiguration: trashCfg), for: .normal)
        trashRecordBtn.tintColor = UIColor.systemRed
        trashRecordBtn.addTarget(self, action: #selector(cancelRecording), for: .touchUpInside)
        trashRecordBtn.isHidden = true
        emptyBar.addSubview(trashRecordBtn)

        // Blinking red dot (centre-left of timer)
        recordingDotLbl.translatesAutoresizingMaskIntoConstraints = false
        recordingDotLbl.text = "●"
        recordingDotLbl.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        recordingDotLbl.textColor = UIColor.systemRed
        recordingDotLbl.isHidden = true
        emptyBar.addSubview(recordingDotLbl)

        // Elapsed time (centre)
        recordingTimeLbl.translatesAutoresizingMaskIntoConstraints = false
        recordingTimeLbl.text = "0:00"
        recordingTimeLbl.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        recordingTimeLbl.textColor = UIColor.label
        recordingTimeLbl.isHidden = true
        emptyBar.addSubview(recordingTimeLbl)

        // Send / paper-plane (right, blue circle)
        sendRecordBtn.translatesAutoresizingMaskIntoConstraints = false
        let sendCfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        sendRecordBtn.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: sendCfg), for: .normal)
        sendRecordBtn.tintColor = .white
        sendRecordBtn.backgroundColor = UIColor.systemBlue
        sendRecordBtn.layer.cornerRadius = 20
        sendRecordBtn.clipsToBounds = true
        sendRecordBtn.addTarget(self, action: #selector(sendRecording), for: .touchUpInside)
        sendRecordBtn.isHidden = true
        emptyBar.addSubview(sendRecordBtn)

        NSLayoutConstraint.activate([
            trashRecordBtn.leadingAnchor.constraint(equalTo: emptyBar.leadingAnchor, constant: 16),
            trashRecordBtn.centerYAnchor.constraint(equalTo: emptyBar.centerYAnchor),
            trashRecordBtn.widthAnchor.constraint(equalToConstant: 36),
            trashRecordBtn.heightAnchor.constraint(equalToConstant: 36),

            sendRecordBtn.trailingAnchor.constraint(equalTo: emptyBar.trailingAnchor, constant: -12),
            sendRecordBtn.centerYAnchor.constraint(equalTo: emptyBar.centerYAnchor),
            sendRecordBtn.widthAnchor.constraint(equalToConstant: 40),
            sendRecordBtn.heightAnchor.constraint(equalToConstant: 40),

            recordingDotLbl.centerXAnchor.constraint(equalTo: emptyBar.centerXAnchor, constant: -20),
            recordingDotLbl.centerYAnchor.constraint(equalTo: emptyBar.centerYAnchor),

            recordingTimeLbl.leadingAnchor.constraint(equalTo: recordingDotLbl.trailingAnchor, constant: 5),
            recordingTimeLbl.centerYAnchor.constraint(equalTo: emptyBar.centerYAnchor),
        ])
    }

    @objc private func inputModeChanged() {
        guard let lang = textInputMode?.primaryLanguage else { return }
        let appGroup = "group.com.jeff.translatehelper"
        let defaults = UserDefaults(suiteName: appGroup)
        let targetCode = LanguageManager.shared.targetLangRequired
        
        let newLang = lang.hasPrefix(targetCode) ? targetCode : nativeLang
        guard newLang != selectedLanguage else { return }
        selectedLanguage = newLang
        defaults?.set(selectedLanguage, forKey: "talkswitch_lang")
        defaults?.synchronize()
        updateLangPill()
        NSLog("TSKBD_LANG_SYNC: iOS slider → \(selectedLanguage)")
    }

    @objc private func langPillTapped() {
        let appGroup = "group.com.jeff.translatehelper"
        let defaults = UserDefaults(suiteName: appGroup)
        let targetCode = LanguageManager.shared.targetLangRequired
        
        selectedLanguage = (selectedLanguage == targetCode) ? nativeLang : targetCode
        defaults?.set(selectedLanguage, forKey: "talkswitch_lang")
        defaults?.synchronize()
        updateLangPill()
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        NSLog("TSKBD_LANG: \(selectedLanguage)")
    }

    private func updateLangPill() {
        let prof = TSProfiles[selectedLanguage] ?? TSProfiles["en"]!
        langPill.setTitle("\(prof.flag) \(prof.code.uppercased())", for: .normal)
        langPill.setTitleColor(.white, for: .normal)
        if selectedLanguage == nativeLang {
            langPill.backgroundColor = UIColor.systemGreen
        } else {
            langPill.backgroundColor = UIColor.systemBlue
        }
    }

    // MARK: - Panel

    private func setupPanel() {
        panel.translatesAutoresizingMaskIntoConstraints = false
        panel.isHidden = true
        view.addSubview(panel)
        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(equalTo: view.topAnchor),
            panel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            panel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // Scrollable content
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        panel.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 6
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: panel.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: panel.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 6),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -10),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -6),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -20),
        ])

        // === Top bar: direction + close ===
        let topBar = UIView()
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.heightAnchor.constraint(equalToConstant: 24).isActive = true

        directionLabel.translatesAutoresizingMaskIntoConstraints = false
        directionLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        directionLabel.textColor = UIColor.systemBlue
        topBar.addSubview(directionLabel)

        NSLayoutConstraint.activate([
            directionLabel.leadingAnchor.constraint(equalTo: topBar.leadingAnchor),
            directionLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
        ])
        contentStack.addArrangedSubview(topBar)

        // === Input card ===
        setupInputCard()
        contentStack.addArrangedSubview(inputCard)

        // === Output card ===
        setupOutputCard()
        contentStack.addArrangedSubview(outputCard)

        // === Correction card ===
        setupCorrectionCard()
        contentStack.addArrangedSubview(correctionCard)

        // === Coach card (pronunciation + grammar tips for voice messages) ===
        setupCoachCard()
        contentStack.addArrangedSubview(coachCard)

        // === Notes card ===
        setupNotesCard()
        contentStack.addArrangedSubview(notesCard)

        // === Hint card (tips like paste-to-translate, save phrases — swipe to dismiss) ===
        setupHintCard()
        contentStack.addArrangedSubview(hintCard)
        hintCard.isHidden = true

        // === Tone selector ===
        setupToneStack()
        contentStack.addArrangedSubview(toneStack)

        // === Wingman toggle (below tone tabs, only visible in flirty mode) ===
        setupWingmanToggle()
        contentStack.addArrangedSubview(wingmanToggle)
        wingmanToggle.isHidden = true

        // === Wingman options cards ===
        setupWingmanOptionsStack()
        contentStack.addArrangedSubview(wingmanOptionsStack)
        wingmanOptionsStack.isHidden = true

        // === Wingman onboarding card ===
        setupWingmanOnboarding()
        contentStack.addArrangedSubview(wingmanOnboardingCard)
        wingmanOnboardingCard.isHidden = true

        // === Action buttons ===
        setupActionStack()
        contentStack.addArrangedSubview(actionStack)
    }

    // MARK: - Mode Selector
    
    // (Mode selector and mic removed — coaching is handled via smart notes)
    
    private func setupInputCard() {
        inputCard.backgroundColor = cardBg
        inputCard.layer.cornerRadius = 10
        inputCard.translatesAutoresizingMaskIntoConstraints = false

        inputLangLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        inputLangLabel.textColor = textSecondary
        inputLangLabel.translatesAutoresizingMaskIntoConstraints = false
        inputCard.addSubview(inputLangLabel)

        inputTextLabel.font = UIFont.systemFont(ofSize: 15)
        inputTextLabel.textColor = textPrimary
        inputTextLabel.numberOfLines = 2
        inputTextLabel.translatesAutoresizingMaskIntoConstraints = false
        inputCard.addSubview(inputTextLabel)

        // Tap to expand input too
        let inputTap = UITapGestureRecognizer(target: self, action: #selector(outputCardTapped))
        inputCard.addGestureRecognizer(inputTap)
        inputCard.isUserInteractionEnabled = true

        // X clear button on input card — subtle gray matching the charcoal card
        let xCfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        pastePlayBtn.setImage(UIImage(systemName: "xmark", withConfiguration: xCfg), for: .normal)
        pastePlayBtn.tintColor = UIColor.white.withAlphaComponent(0.35)
        pastePlayBtn.backgroundColor = .clear
        pastePlayBtn.layer.cornerRadius = 16
        pastePlayBtn.layer.borderWidth = 1.0
        pastePlayBtn.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        pastePlayBtn.clipsToBounds = true
        pastePlayBtn.translatesAutoresizingMaskIntoConstraints = false
        pastePlayBtn.isHidden = true
        pastePlayBtn.addTarget(self, action: #selector(inputClearTapped), for: .touchUpInside)
        inputCard.addSubview(pastePlayBtn)

        NSLayoutConstraint.activate([
            inputCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            inputLangLabel.topAnchor.constraint(equalTo: inputCard.topAnchor, constant: 8),
            inputLangLabel.leadingAnchor.constraint(equalTo: inputCard.leadingAnchor, constant: 12),
            inputTextLabel.topAnchor.constraint(equalTo: inputLangLabel.bottomAnchor, constant: 2),
            inputTextLabel.leadingAnchor.constraint(equalTo: inputCard.leadingAnchor, constant: 12),
            inputTextLabel.trailingAnchor.constraint(equalTo: pastePlayBtn.leadingAnchor, constant: -8),
            inputTextLabel.bottomAnchor.constraint(equalTo: inputCard.bottomAnchor, constant: -8),
            pastePlayBtn.trailingAnchor.constraint(equalTo: inputCard.trailingAnchor, constant: -10),
            pastePlayBtn.centerYAnchor.constraint(equalTo: inputCard.centerYAnchor),
            pastePlayBtn.widthAnchor.constraint(equalToConstant: 32),
            pastePlayBtn.heightAnchor.constraint(equalToConstant: 32),
        ])
    }

    private func setupOutputCard() {
        outputCard.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        outputCard.layer.cornerRadius = 10
        outputCard.layer.borderWidth = 1
        outputCard.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        outputCard.translatesAutoresizingMaskIntoConstraints = false
        outputCard.clipsToBounds = true

        outputLangLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        outputLangLabel.textColor = UIColor.systemBlue
        outputLangLabel.translatesAutoresizingMaskIntoConstraints = false
        outputCard.addSubview(outputLangLabel)

        outputTextLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        outputTextLabel.textColor = textPrimary
        outputTextLabel.numberOfLines = 4
        outputTextLabel.translatesAutoresizingMaskIntoConstraints = false
        outputCard.addSubview(outputTextLabel)

        // Speaker button styling: smaller, outline on the circle
        let speakerBtn = UIButton(type: .system)
        speakerBtn.translatesAutoresizingMaskIntoConstraints = false
        let speakerConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        speakerBtn.setImage(UIImage(systemName: "speaker.wave.2", withConfiguration: speakerConfig), for: .normal)
        speakerBtn.tintColor = UIColor.systemBlue
        speakerBtn.backgroundColor = .clear
        speakerBtn.layer.cornerRadius = 16
        speakerBtn.layer.borderWidth = 1.0
        speakerBtn.layer.borderColor = UIColor.systemBlue.cgColor
        speakerBtn.clipsToBounds = true
        speakerBtn.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        outputCard.addSubview(speakerBtn)

        // Tap to expand/collapse
        let expandTap = UITapGestureRecognizer(target: self, action: #selector(outputCardTapped))
        outputCard.addGestureRecognizer(expandTap)
        outputCard.isUserInteractionEnabled = true

        // Pan gesture — swipe right for alternative translation (Tinder style)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(outputCardPanned(_:)))
        pan.require(toFail: expandTap)
        outputCard.addGestureRecognizer(pan)

        // Swipe hint label
        swipeHintLabel.translatesAutoresizingMaskIntoConstraints = false
        swipeHintLabel.text = "swipe for another version →"
        swipeHintLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        swipeHintLabel.textColor = UIColor.systemBlue.withAlphaComponent(0.55)
        swipeHintLabel.textAlignment = .right
        swipeHintLabel.isHidden = true
        outputCard.addSubview(swipeHintLabel)

        // X clear button for paste mode — clears text and dismisses paste translation
        let xConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        pasteClearBtn.setImage(UIImage(systemName: "xmark", withConfiguration: xConfig), for: .normal)
        pasteClearBtn.tintColor = UIColor.systemBlue
        pasteClearBtn.backgroundColor = .clear
        pasteClearBtn.layer.cornerRadius = 16
        pasteClearBtn.layer.borderWidth = 1.0
        pasteClearBtn.layer.borderColor = UIColor.systemBlue.cgColor
        pasteClearBtn.clipsToBounds = true
        pasteClearBtn.translatesAutoresizingMaskIntoConstraints = false
        pasteClearBtn.isHidden = true  // only visible during paste translation
        pasteClearBtn.addTarget(self, action: #selector(pasteClearTapped), for: .touchUpInside)
        outputCard.addSubview(pasteClearBtn)

        // Spinner — centred overlay inside the output card
        outputCard.addSubview(loadingSpinner)

        NSLayoutConstraint.activate([
            outputCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            outputLangLabel.topAnchor.constraint(equalTo: outputCard.topAnchor, constant: 8),
            outputLangLabel.leadingAnchor.constraint(equalTo: outputCard.leadingAnchor, constant: 12),
            speakerBtn.trailingAnchor.constraint(equalTo: outputCard.trailingAnchor, constant: -10),
            speakerBtn.centerYAnchor.constraint(equalTo: outputCard.centerYAnchor),
            speakerBtn.widthAnchor.constraint(equalToConstant: 32),
            speakerBtn.heightAnchor.constraint(equalToConstant: 32),
            pasteClearBtn.trailingAnchor.constraint(equalTo: outputCard.trailingAnchor, constant: -10),
            pasteClearBtn.centerYAnchor.constraint(equalTo: outputCard.centerYAnchor),
            pasteClearBtn.widthAnchor.constraint(equalToConstant: 32),
            pasteClearBtn.heightAnchor.constraint(equalToConstant: 32),
            outputTextLabel.topAnchor.constraint(equalTo: outputLangLabel.bottomAnchor, constant: 2),
            outputTextLabel.leadingAnchor.constraint(equalTo: outputCard.leadingAnchor, constant: 12),
            outputTextLabel.trailingAnchor.constraint(equalTo: speakerBtn.leadingAnchor, constant: -8),
            outputTextLabel.bottomAnchor.constraint(equalTo: outputCard.bottomAnchor, constant: -10),
            swipeHintLabel.bottomAnchor.constraint(equalTo: outputCard.bottomAnchor, constant: -4),
            swipeHintLabel.trailingAnchor.constraint(equalTo: speakerBtn.leadingAnchor, constant: -6),
            loadingSpinner.trailingAnchor.constraint(equalTo: speakerBtn.leadingAnchor, constant: -8),
            loadingSpinner.centerYAnchor.constraint(equalTo: outputCard.centerYAnchor),
        ])
    }

    // MARK: - Swipe for alternative translation

    @objc private func outputCardPanned(_ gesture: UIPanGestureRecognizer) {
        // Disable swipe on paste translations — no alternative versions needed
        if isPasteTranslationActive {
            gesture.state = .cancelled
            return
        }
        let tx = gesture.translation(in: outputCard).x
        let canGoBack    = currentHistoryIndex > 0
        let canGoForward = true // always: either advance index or fetch new

        switch gesture.state {
        case .changed:
            if tx > 0 && canGoForward {
                // Rightward swipe → new version
                let clamped = max(0, tx)
                outputCard.transform = CGAffineTransform(translationX: clamped, y: 0)
                    .rotated(by: clamped / 800)
                let progress = min(clamped / 120, 1.0)
                outputCard.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                    .blend(with: UIColor.systemGreen.withAlphaComponent(0.18), ratio: progress)
            } else if tx < 0 && canGoBack {
                // Leftward swipe → go back in history
                let clamped = min(0, tx)
                outputCard.transform = CGAffineTransform(translationX: clamped, y: 0)
                    .rotated(by: clamped / 800)
                let progress = min(abs(clamped) / 120, 1.0)
                outputCard.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                    .blend(with: UIColor.systemOrange.withAlphaComponent(0.18), ratio: progress)
            }

        case .ended, .cancelled:
            if tx > 90 {
                // Committed right swipe — fly card off right, fetch/advance
                UIView.animate(withDuration: 0.22, animations: {
                    self.outputCard.transform = CGAffineTransform(translationX: 500, y: 0)
                        .rotated(by: 0.18)
                    self.outputCard.alpha = 0
                }) { _ in
                    self.outputCard.transform = .identity
                    self.outputCard.alpha = 1
                    self.outputCard.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                    self.advanceForward()
                }
            } else if tx < -90 && canGoBack {
                // Committed left swipe — fly card off left, go back
                UIView.animate(withDuration: 0.22, animations: {
                    self.outputCard.transform = CGAffineTransform(translationX: -500, y: 0)
                        .rotated(by: -0.18)
                    self.outputCard.alpha = 0
                }) { _ in
                    self.outputCard.transform = .identity
                    self.outputCard.alpha = 1
                    self.outputCard.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                    self.goBack()
                }
            } else {
                // Snap back
                UIView.animate(withDuration: 0.2) {
                    self.outputCard.transform = .identity
                    self.outputCard.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                }
            }
        default: break
        }
    }

    /// Move to the next translation — use cached history if possible, otherwise fetch a new one.
    private func advanceForward() {
        let nextIndex = currentHistoryIndex + 1
        if nextIndex < translationHistory.count {
            // Already have this version cached — show instantly
            currentHistoryIndex = nextIndex
            let cached = translationHistory[nextIndex]
            showHistoryEntry(cached, slideFromLeft: false)
            updateSwipeHint()
        } else {
            // Need to generate a new alternative
            generateAlternativeTranslation()
        }
    }

    /// Go back one step in translation history (no API call needed).
    private func goBack() {
        guard currentHistoryIndex > 0 else { return }
        currentHistoryIndex -= 1
        let previous = translationHistory[currentHistoryIndex]
        showHistoryEntry(previous, slideFromLeft: true)
        updateSwipeHint()
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        NSLog("TSKBD_HISTORY_BACK: v\(currentHistoryIndex + 1)")
    }

    /// Animate the output card sliding in and update its text.
    private func showHistoryEntry(_ text: String, slideFromLeft: Bool) {
        outputTextLabel.text = text
        let startX: CGFloat = slideFromLeft ? -400 : 400
        outputCard.transform = CGAffineTransform(translationX: startX, y: 0)
        UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.82,
                       initialSpringVelocity: 0.5) {
            self.outputCard.transform = .identity
        }
    }

    private func generateAlternativeTranslation() {
        translationVersion += 1
        let version = translationVersion
        let previousTranslation = translationHistory.last ?? outputTextLabel.text ?? ""
        outputTextLabel.text = "✨ Getting version \(version + 1)…"
        swipeHintLabel.isHidden = true
        outputCard.isHidden = false

        let targetCode = LanguageManager.shared.targetLangRequired
        let tone = Tone(rawValue: currentTone) ?? .casual
        TalkSwitchAPI.shared.alternativeTranslation(
            original: inputText,
            currentTranslation: previousTranslation,
            sourceLang: detectedLanguage,
            targetLang: targetCode,
            tone: tone,
            variation: version
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let refined):
                    // Append to history and advance index
                    self.translationHistory.append(refined.output)
                    self.currentHistoryIndex = self.translationHistory.count - 1
                    if let notes = refined.notes, !notes.isEmpty {
                        self.notesCard.isHidden = false
                        self.notesTextLabel.text = notes
                    }
                    self.showHistoryEntry(refined.output, slideFromLeft: false)
                    self.updateSwipeHint()
                case .failure:
                    self.outputTextLabel.text = "Couldn't get another version — try again"
                    self.updateSwipeHint()
                }
            }
        }
    }

    /// Update the swipe hint label to reflect current position in history.
    private func updateSwipeHint() {
        swipeHintLabel.isHidden = false
        swipeHintLabel.text = "swipe for another version →"
    }

    private func setupNotesCard() {
        notesCard.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.12)
        notesCard.layer.cornerRadius = 10
        notesCard.translatesAutoresizingMaskIntoConstraints = false

        notesIcon.text = "📝"
        notesIcon.font = UIFont.systemFont(ofSize: 14)
        notesIcon.translatesAutoresizingMaskIntoConstraints = false
        notesCard.addSubview(notesIcon)

        let notesHeader = UILabel()
        notesHeader.text = "NOTES"
        notesHeader.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        notesHeader.textColor = UIColor.systemOrange
        notesHeader.translatesAutoresizingMaskIntoConstraints = false
        notesCard.addSubview(notesHeader)

        notesTextLabel.font = UIFont.systemFont(ofSize: 14.5)
        notesTextLabel.textColor = textPrimary
        notesTextLabel.numberOfLines = 0
        notesTextLabel.translatesAutoresizingMaskIntoConstraints = false
        notesCard.addSubview(notesTextLabel)

        NSLayoutConstraint.activate([
            notesCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            notesIcon.topAnchor.constraint(equalTo: notesCard.topAnchor, constant: 8),
            notesIcon.leadingAnchor.constraint(equalTo: notesCard.leadingAnchor, constant: 10),
            notesHeader.centerYAnchor.constraint(equalTo: notesIcon.centerYAnchor),
            notesHeader.leadingAnchor.constraint(equalTo: notesIcon.trailingAnchor, constant: 4),
            notesTextLabel.topAnchor.constraint(equalTo: notesIcon.bottomAnchor, constant: 4),
            notesTextLabel.leadingAnchor.constraint(equalTo: notesCard.leadingAnchor, constant: 12),
            notesTextLabel.trailingAnchor.constraint(equalTo: notesCard.trailingAnchor, constant: -12),
            notesTextLabel.bottomAnchor.constraint(equalTo: notesCard.bottomAnchor, constant: -8),
        ])
    }

    private func setupHintCard() {
        hintCard.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.10)
        hintCard.layer.cornerRadius = 10
        hintCard.layer.borderWidth = 1
        hintCard.layer.borderColor = UIColor.systemPurple.withAlphaComponent(0.25).cgColor
        hintCard.translatesAutoresizingMaskIntoConstraints = false
        hintCard.clipsToBounds = true

        // Top row: 📋 TIP inline
        let hintHeader = UILabel()
        hintHeader.text = "📋 TIP"
        hintHeader.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        hintHeader.textColor = UIColor.systemPurple
        hintHeader.translatesAutoresizingMaskIntoConstraints = false
        hintCard.addSubview(hintHeader)

        hintTextLabel.font = UIFont.systemFont(ofSize: 13)
        hintTextLabel.textColor = textPrimary
        hintTextLabel.numberOfLines = 0
        hintTextLabel.translatesAutoresizingMaskIntoConstraints = false
        hintCard.addSubview(hintTextLabel)

        // Dismiss button — pill shape
        let dismissBtn = UIButton(type: .system)
        dismissBtn.setTitle("Swipe to dismiss →", for: .normal)
        dismissBtn.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        dismissBtn.setTitleColor(UIColor.systemPurple, for: .normal)
        dismissBtn.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.12)
        dismissBtn.layer.cornerRadius = 12
        dismissBtn.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        dismissBtn.translatesAutoresizingMaskIntoConstraints = false
        dismissBtn.addTarget(self, action: #selector(hintCardSwiped), for: .touchUpInside)
        hintCard.addSubview(dismissBtn)

        NSLayoutConstraint.activate([
            hintCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            hintHeader.topAnchor.constraint(equalTo: hintCard.topAnchor, constant: 8),
            hintHeader.leadingAnchor.constraint(equalTo: hintCard.leadingAnchor, constant: 12),
            hintTextLabel.topAnchor.constraint(equalTo: hintHeader.bottomAnchor, constant: 4),
            hintTextLabel.leadingAnchor.constraint(equalTo: hintCard.leadingAnchor, constant: 12),
            hintTextLabel.trailingAnchor.constraint(equalTo: hintCard.trailingAnchor, constant: -12),
            hintTextLabel.bottomAnchor.constraint(equalTo: dismissBtn.topAnchor, constant: -8),
            dismissBtn.trailingAnchor.constraint(equalTo: hintCard.trailingAnchor, constant: -12),
            dismissBtn.bottomAnchor.constraint(equalTo: hintCard.bottomAnchor, constant: -8),
        ])

        // Swipe right to dismiss
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(hintCardSwiped))
        swipe.direction = .right
        hintCard.addGestureRecognizer(swipe)
    }

    @objc private func hintCardSwiped() {
        UIView.animate(withDuration: 0.3, animations: {
            self.hintCard.transform = CGAffineTransform(translationX: 400, y: 0)
            self.hintCard.alpha = 0
        }) { _ in
            self.hintCard.isHidden = true
            self.hintCard.transform = .identity
            self.hintCard.alpha = 1
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func setupCorrectionCard() {
        correctionCard.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.10)
        correctionCard.layer.cornerRadius = 10
        correctionCard.translatesAutoresizingMaskIntoConstraints = false

        correctionIcon.text = "💬"
        correctionIcon.font = UIFont.systemFont(ofSize: 14)
        correctionIcon.translatesAutoresizingMaskIntoConstraints = false
        correctionCard.addSubview(correctionIcon)

        correctionHeader.text = "NATIVE"
        correctionHeader.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        correctionHeader.textColor = UIColor.systemGreen
        correctionHeader.translatesAutoresizingMaskIntoConstraints = false
        correctionCard.addSubview(correctionHeader)

        correctionTextLabel.font = UIFont.systemFont(ofSize: 14.5)
        correctionTextLabel.textColor = textPrimary
        correctionTextLabel.numberOfLines = 0
        correctionTextLabel.translatesAutoresizingMaskIntoConstraints = false
        correctionCard.addSubview(correctionTextLabel)

        NSLayoutConstraint.activate([
            correctionCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            correctionIcon.topAnchor.constraint(equalTo: correctionCard.topAnchor, constant: 8),
            correctionIcon.leadingAnchor.constraint(equalTo: correctionCard.leadingAnchor, constant: 10),
            correctionHeader.centerYAnchor.constraint(equalTo: correctionIcon.centerYAnchor),
            correctionHeader.leadingAnchor.constraint(equalTo: correctionIcon.trailingAnchor, constant: 4),
            correctionTextLabel.topAnchor.constraint(equalTo: correctionIcon.bottomAnchor, constant: 4),
            correctionTextLabel.leadingAnchor.constraint(equalTo: correctionCard.leadingAnchor, constant: 12),
            correctionTextLabel.trailingAnchor.constraint(equalTo: correctionCard.trailingAnchor, constant: -12),
            correctionTextLabel.bottomAnchor.constraint(equalTo: correctionCard.bottomAnchor, constant: -8),
        ])
    }

    private func setupCoachCard() {
        coachCard.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        coachCard.layer.cornerRadius = 10
        coachCard.translatesAutoresizingMaskIntoConstraints = false
        coachCard.isHidden = true  // Only shown for voice messages

        coachIcon.text = "🎯"
        coachIcon.font = UIFont.systemFont(ofSize: 14)
        coachIcon.translatesAutoresizingMaskIntoConstraints = false
        coachCard.addSubview(coachIcon)

        coachHeader.text = "COACH"
        coachHeader.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        coachHeader.textColor = UIColor.systemBlue
        coachHeader.translatesAutoresizingMaskIntoConstraints = false
        coachCard.addSubview(coachHeader)

        coachTextLabel.font = UIFont.systemFont(ofSize: 13)
        coachTextLabel.textColor = textPrimary
        coachTextLabel.numberOfLines = 0
        coachTextLabel.translatesAutoresizingMaskIntoConstraints = false
        coachCard.addSubview(coachTextLabel)

        NSLayoutConstraint.activate([
            coachCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            coachIcon.topAnchor.constraint(equalTo: coachCard.topAnchor, constant: 8),
            coachIcon.leadingAnchor.constraint(equalTo: coachCard.leadingAnchor, constant: 10),
            coachHeader.centerYAnchor.constraint(equalTo: coachIcon.centerYAnchor),
            coachHeader.leadingAnchor.constraint(equalTo: coachIcon.trailingAnchor, constant: 4),
            coachTextLabel.topAnchor.constraint(equalTo: coachIcon.bottomAnchor, constant: 4),
            coachTextLabel.leadingAnchor.constraint(equalTo: coachCard.leadingAnchor, constant: 12),
            coachTextLabel.trailingAnchor.constraint(equalTo: coachCard.trailingAnchor, constant: -12),
            coachTextLabel.bottomAnchor.constraint(equalTo: coachCard.bottomAnchor, constant: -8),
        ])
    }

    private func setupToneStack() {
        toneStack.axis = .horizontal
        toneStack.distribution = .fillEqually
        toneStack.spacing = 6
        toneStack.translatesAutoresizingMaskIntoConstraints = false
        toneStack.heightAnchor.constraint(equalToConstant: 32).isActive = true

        for (i, tone) in tones.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle("\(tone.icon) \(tone.label)", for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            btn.layer.cornerRadius = 16
            btn.clipsToBounds = true
            btn.tag = i
            btn.addTarget(self, action: #selector(toneTapped(_:)), for: .touchUpInside)
            toneStack.addArrangedSubview(btn)
        }
        updateToneSelection()
    }

    private func setupActionStack() {
        actionStack.axis = .horizontal
        actionStack.distribution = .fillEqually
        actionStack.spacing = 8
        actionStack.translatesAutoresizingMaskIntoConstraints = false
        actionStack.heightAnchor.constraint(equalToConstant: 38).isActive = true

        let actions: [(String, Selector)] = [
            ("Replace ↩️", #selector(replaceTapped)),
            // Clear button removed — clearing is done via X icon on the paste translation card
            ("Save 💾", #selector(saveTapped)),
            ("🎤 Speak", #selector(micTapped)),
        ]
        for (title, action) in actions {
            let btn = UIButton(type: .custom)
            btn.setTitle(title, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            btn.layer.cornerRadius = 10
            btn.layer.borderWidth = 1.0
            btn.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
            btn.clipsToBounds = true
            btn.addTarget(self, action: action, for: .touchUpInside)
            actionStack.addArrangedSubview(btn)
        }
    }

    // MARK: - Wingman UI Setup

    private func setupWingmanToggle() {
        wingmanToggle.axis = .horizontal
        wingmanToggle.distribution = .fillEqually
        wingmanToggle.spacing = 6
        wingmanToggle.translatesAutoresizingMaskIntoConstraints = false
        wingmanToggle.heightAnchor.constraint(equalToConstant: 32).isActive = true

        let translateBtn = UIButton(type: .system)
        translateBtn.setTitle("💬 Translate", for: .normal)
        translateBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        translateBtn.layer.cornerRadius = 16
        translateBtn.clipsToBounds = true
        translateBtn.tag = 0
        translateBtn.addTarget(self, action: #selector(wingmanToggleTapped(_:)), for: .touchUpInside)
        wingmanToggle.addArrangedSubview(translateBtn)

        let wingmanBtn = UIButton(type: .system)
        wingmanBtn.setTitle("🔥 Wingman", for: .normal)
        wingmanBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        wingmanBtn.layer.cornerRadius = 16
        wingmanBtn.clipsToBounds = true
        wingmanBtn.tag = 1
        wingmanBtn.addTarget(self, action: #selector(wingmanToggleTapped(_:)), for: .touchUpInside)
        wingmanToggle.addArrangedSubview(wingmanBtn)

        updateWingmanToggleUI()
    }

    private func updateWingmanToggleUI() {
        for (i, v) in wingmanToggle.arrangedSubviews.enumerated() {
            guard let btn = v as? UIButton else { continue }
            let isActive = (i == 0 && !isWingmanMode) || (i == 1 && isWingmanMode)
            if isActive {
                // Same style as the tone tabs — blue fill, white text
                btn.backgroundColor = UIColor.systemBlue
                btn.setTitleColor(.white, for: .normal)
            } else {
                btn.backgroundColor = cardBg
                btn.setTitleColor(textPrimary, for: .normal)
            }
        }
    }

    @objc private func wingmanToggleTapped(_ sender: UIButton) {
        isWingmanMode = sender.tag == 1
        updateWingmanToggleUI()

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        if isWingmanMode {
            // Show wingman UI, hide normal output
            outputCard.isHidden = true
            notesCard.isHidden = true
            correctionCard.isHidden = true
            coachCard.isHidden = true

            // Show onboarding every time in DEBUG so we can review the copy.
            // TODO: Before shipping, restore the ts_wingman_onboarded persistence check.
            #if DEBUG
            wingmanOnboardingCard.isHidden = false
            #else
            if !wingmanOnboardingShown {
                let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
                if !(defaults?.bool(forKey: "ts_wingman_onboarded") ?? false) {
                    wingmanOnboardingCard.isHidden = false
                    wingmanOnboardingShown = true
                    defaults?.set(true, forKey: "ts_wingman_onboarded")
                    defaults?.synchronize()
                }
            }
            #endif

            // If there's already text, auto-trigger Wingman
            if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                fetchWingmanOptions(situation: inputText)
            }
        } else {
            // Back to translate mode
            wingmanOptionsStack.isHidden = true
            wingmanOnboardingCard.isHidden = true
            outputCard.isHidden = false
            notesCard.isHidden = false

            // Re-translate if we have text
            if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                performTranslation(text: inputText, source: "wingman-off")
            }
        }

        NSLog("TSKBD_WINGMAN: mode=\(isWingmanMode ? "on" : "off")")
    }

    private func setupWingmanOptionsStack() {
        wingmanOptionsStack.axis = .vertical
        wingmanOptionsStack.spacing = 8
        wingmanOptionsStack.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupWingmanOnboarding() {
        wingmanOnboardingCard.backgroundColor = wingmanOrange.withAlphaComponent(0.1)
        wingmanOnboardingCard.layer.cornerRadius = 12
        wingmanOnboardingCard.layer.borderWidth = 1
        wingmanOnboardingCard.layer.borderColor = wingmanOrange.withAlphaComponent(0.2).cgColor
        wingmanOnboardingCard.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = textPrimary

        let text = NSMutableAttributedString()
        text.append(NSAttributedString(
            string: "Meet your Orbit Wingman 🪩\n",
            attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: UIColor.white]
        ))
        text.append(NSAttributedString(
            string: "Just describe what's going on and we'll set you up with something smooth.\n\n",
            attributes: [.font: UIFont.systemFont(ofSize: 13), .foregroundColor: UIColor.white.withAlphaComponent(0.8)]
        ))
        text.append(NSAttributedString(
            string: "\"She just said she loves coffee — what do I say?\"\n\"We matched on Tinder, give me a fun opener\"",
            attributes: [
                .font: UIFont.italicSystemFont(ofSize: 12),
                .foregroundColor: UIColor.white.withAlphaComponent(0.6)
            ]
        ))
        label.attributedText = text

        wingmanOnboardingCard.addSubview(label)

        let dismissBtn = UIButton(type: .system)
        dismissBtn.setTitle("Got it 🔥", for: .normal)
        dismissBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        dismissBtn.setTitleColor(.white, for: .normal)
        dismissBtn.backgroundColor = wingmanOrange.withAlphaComponent(0.3)
        dismissBtn.layer.cornerRadius = 12
        dismissBtn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24)
        dismissBtn.translatesAutoresizingMaskIntoConstraints = false
        dismissBtn.addTarget(self, action: #selector(dismissWingmanOnboarding), for: .touchUpInside)
        wingmanOnboardingCard.addSubview(dismissBtn)

        NSLayoutConstraint.activate([
            wingmanOnboardingCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            label.topAnchor.constraint(equalTo: wingmanOnboardingCard.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: wingmanOnboardingCard.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: wingmanOnboardingCard.trailingAnchor, constant: -14),
            dismissBtn.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            dismissBtn.trailingAnchor.constraint(equalTo: wingmanOnboardingCard.trailingAnchor, constant: -14),
            dismissBtn.bottomAnchor.constraint(equalTo: wingmanOnboardingCard.bottomAnchor, constant: -12),
            dismissBtn.widthAnchor.constraint(equalToConstant: 60),
            dismissBtn.heightAnchor.constraint(equalToConstant: 30),
        ])
    }

    @objc private func dismissWingmanOnboarding() {
        UIView.animate(withDuration: 0.2) {
            self.wingmanOnboardingCard.alpha = 0
        } completion: { _ in
            self.wingmanOnboardingCard.isHidden = true
            self.wingmanOnboardingCard.alpha = 1
        }
    }

    // MARK: - Wingman Logic

    private func fetchWingmanOptions(situation: String) {
        isLoadingWingman = true
        currentWingmanIndex = 0
        wingmanOptionsStack.isHidden = false

        // Clear existing
        wingmanOptionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Show loading
        let loadingLabel = UILabel()
        loadingLabel.text = "🔥 Finding your moves..."
        loadingLabel.font = UIFont.systemFont(ofSize: 13)
        loadingLabel.textColor = textSecondary
        loadingLabel.textAlignment = .center
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        wingmanOptionsStack.addArrangedSubview(loadingLabel)

        let targetCode = LanguageManager.shared.targetLangRequired

        TalkSwitchAPI.shared.getWingmanOptions(
            situation: situation,
            sourceLang: nativeLang,
            targetLang: targetCode
        ) { [weak self] options in
            guard let self = self else { return }
            self.isLoadingWingman = false
            self.wingmanOptions = options

            // Clear loading
            self.wingmanOptionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

            if options.isEmpty {
                let errorLabel = UILabel()
                errorLabel.text = "Couldn't generate options. Try again?"
                errorLabel.font = UIFont.systemFont(ofSize: 13)
                errorLabel.textColor = self.textSecondary
                errorLabel.textAlignment = .center
                errorLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
                self.wingmanOptionsStack.addArrangedSubview(errorLabel)
                return
            }

            // Show the first card
            self.showWingmanCard(at: 0)

            // Set the output text to the current option so Replace button works
            self.updateOutputForWingman()
        }
    }

    /// Bright vivid orange for Wingman accents
    private let wingmanOrange = UIColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 1.0)

    /// Shows a single Wingman option card — swipe right for next, left for previous.
    /// When the user reaches the last card, fetches 3 more automatically (infinite scroll).
    private func showWingmanCard(at index: Int) {
        guard index >= 0, index < wingmanOptions.count else { return }
        currentWingmanIndex = index
        let option = wingmanOptions[index]

        // Clear previous card
        wingmanOptionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let card = UIView()
        // Same card style as output card — matches the keyboard's design language
        card.backgroundColor = cardBg
        card.layer.cornerRadius = 10
        card.translatesAutoresizingMaskIntoConstraints = false

        // Pan gesture — same as translation output swipe
        let pan = UIPanGestureRecognizer(target: self, action: #selector(wingmanCardPanned(_:)))
        card.addGestureRecognizer(pan)
        card.isUserInteractionEnabled = true

        // Vibe tag — orange accent, distinct from the blue UI
        let vibeLabel = UILabel()
        vibeLabel.text = "🔥 \(option.vibe.uppercased())"
        vibeLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        vibeLabel.textColor = wingmanOrange
        vibeLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(vibeLabel)

        // Swipe hint — same style as translation output card
        let hintLabel = UILabel()
        hintLabel.text = "swipe for another →"
        hintLabel.font = UIFont.systemFont(ofSize: 10)
        hintLabel.textColor = textSecondary.withAlphaComponent(0.4)
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(hintLabel)

        // Target language text — same font as outputTextLabel
        let textLabel = UILabel()
        textLabel.text = option.text
        textLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel.textColor = textPrimary
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(textLabel)

        // English translation — dimmer, below
        let translationLabel = UILabel()
        translationLabel.text = option.translation
        translationLabel.font = UIFont.systemFont(ofSize: 12)
        translationLabel.textColor = textSecondary
        translationLabel.numberOfLines = 0
        translationLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(translationLabel)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),

            vibeLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
            vibeLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),

            hintLabel.centerYAnchor.constraint(equalTo: vibeLabel.centerYAnchor),
            hintLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            textLabel.topAnchor.constraint(equalTo: vibeLabel.bottomAnchor, constant: 6),
            textLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            translationLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 4),
            translationLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            translationLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            translationLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
        ])

        wingmanOptionsStack.addArrangedSubview(card)
        updateOutputForWingman()
    }

    /// Sets the output card text to the current Wingman option so Replace inserts it
    private func updateOutputForWingman() {
        guard currentWingmanIndex < wingmanOptions.count else { return }
        let option = wingmanOptions[currentWingmanIndex]
        outputTextLabel.text = option.text
    }

    /// Pan gesture on Wingman card — same mechanic as translation swipe
    @objc private func wingmanCardPanned(_ gesture: UIPanGestureRecognizer) {
        guard let card = gesture.view else { return }
        let translation = gesture.translation(in: card.superview)

        switch gesture.state {
        case .changed:
            // Drag right → next, drag left → previous
            card.transform = CGAffineTransform(translationX: translation.x, y: 0)
                .rotated(by: translation.x / 800)
            card.alpha = 1.0 - abs(translation.x) / 400

        case .ended:
            let velocity = gesture.velocity(in: card.superview)

            if translation.x > 80 || velocity.x > 500 {
                // Swipe right — go to next (or fetch more)
                UIView.animate(withDuration: 0.22, animations: {
                    card.transform = CGAffineTransform(translationX: 400, y: 0).rotated(by: 0.15)
                    card.alpha = 0
                }) { _ in
                    if self.currentWingmanIndex + 1 < self.wingmanOptions.count {
                        self.showWingmanCard(at: self.currentWingmanIndex + 1)
                    } else {
                        // Fetch more options — infinite scroll
                        self.fetchMoreWingmanOptions()
                    }
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()

            } else if translation.x < -80 || velocity.x < -500 {
                // Swipe left — go back
                if currentWingmanIndex > 0 {
                    UIView.animate(withDuration: 0.22, animations: {
                        card.transform = CGAffineTransform(translationX: -400, y: 0).rotated(by: -0.15)
                        card.alpha = 0
                    }) { _ in
                        self.showWingmanCard(at: self.currentWingmanIndex - 1)
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } else {
                    // Bounce back — at the start
                    UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
                        card.transform = .identity
                        card.alpha = 1
                    }
                }

            } else {
                // Not enough — snap back
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
                    card.transform = .identity
                    card.alpha = 1
                }
            }

        default:
            break
        }
    }

    /// Fetches 3 more Wingman options and appends them (infinite scroll)
    private func fetchMoreWingmanOptions() {
        guard !isLoadingWingman else { return }
        isLoadingWingman = true

        // Show loading in the card area
        wingmanOptionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let loadingLabel = UILabel()
        loadingLabel.text = "🔥 Getting more..."
        loadingLabel.font = UIFont.systemFont(ofSize: 13)
        loadingLabel.textColor = textSecondary
        loadingLabel.textAlignment = .center
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        wingmanOptionsStack.addArrangedSubview(loadingLabel)

        let targetCode = LanguageManager.shared.targetLangRequired

        TalkSwitchAPI.shared.getWingmanOptions(
            situation: inputText,
            sourceLang: nativeLang,
            targetLang: targetCode
        ) { [weak self] options in
            guard let self = self else { return }
            self.isLoadingWingman = false

            if options.isEmpty {
                // Show the last card again
                self.showWingmanCard(at: self.currentWingmanIndex)
                return
            }

            // Append new options
            let startIndex = self.wingmanOptions.count
            self.wingmanOptions.append(contentsOf: options)
            self.showWingmanCard(at: startIndex)
        }
    }

    // MARK: - Show States

    private var autoTranslateTimer: Timer?
    private var dictationPollTimer: Timer?

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        autoTranslateTimer?.invalidate()
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let after  = textDocumentProxy.documentContextAfterInput  ?? ""
        let text   = (before + after).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            previousTextLength = 0
            isPasteTranslationActive = false
            showEmpty()
            return
        }

        // ── Paste detection: text jumped by 8+ chars at once ──
        let currentLen = text.count
        let isPaste = currentLen - previousTextLength >= 8

        // Only clear paste lock when user actually types or deletes (diff 1-3 chars).
        // diff of 0 = re-fire with same text, don't clear.
        let diff = abs(currentLen - previousTextLength)
        if !isPaste && isPasteTranslationActive && diff > 0 && diff <= 3 {
            isPasteTranslationActive = false
        }
        previousTextLength = currentLen

        // If a paste translation is already showing, don't let the debounce overwrite it
        if isPasteTranslationActive { return }

        if isPaste {
            // Use text already in the field — no clipboard read, no iOS privacy prompt.
            let textToTranslate = text

            let detected = detectLanguage(textToTranslate)
            let targetCode = LanguageManager.shared.targetLangRequired

            // Dual language detection for reliability
            let secondOpinion: String = {
                let recognizer = NLLanguageRecognizer()
                recognizer.processString(textToTranslate)
                return recognizer.dominantLanguage?.rawValue.components(separatedBy: "-").first ?? "und"
            }()

            let isTargetLang = detected.code == targetCode || secondOpinion == targetCode
            let isNotNative = (detected.code != nativeLang && detected.code != "und") ||
                              (secondOpinion != nativeLang && secondOpinion != "und")

            NSLog("TSKBD_PASTE: detected=\(detected.code), NL=\(secondOpinion), target=\(targetCode), native=\(nativeLang), len=\(textToTranslate.count)")

            if isTargetLang || isNotNative {
                // Non-native paste — go straight to small keyboard with Translate button.
                NSLog("TSKBD_PASTE: non-native — showing Speak + Translate")
                autoTranslateTimer?.invalidate()
                showEmpty()
                return
            }
        }

        // Debounce: wait 1.8s after last keystroke then auto-translate (or Wingman)
        // CRITICAL: capture the text NOW — don't re-read textDocumentProxy inside the timer.
        // The proxy truncates to ~200-300 chars, and by the time the timer fires 1.8s later,
        // it may return even less. Using the captured `text` ensures we translate everything.
        let capturedText = text
        autoTranslateTimer = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            let t = capturedText
            guard !t.isEmpty else { return }

            // Wingman mode: route to situation handler
            if self.isWingmanMode && self.currentTone == "flirty" {
                self.fetchWingmanOptions(situation: t)
                // Still show the input card so they see what they typed
                self.inputText = t
                self.showPanel()
                self.inputTextLabel.text = t
                self.inputLangLabel.text = "YOUR SITUATION"
                return
            }

            // Auto-detect: if in flirty mode and text looks like a situation,
            // switch to Wingman automatically
            if self.currentTone == "flirty" && !self.isWingmanMode &&
               TalkSwitchAPI.shared.looksLikeSituation(t) {
                self.isWingmanMode = true
                self.updateWingmanToggleUI()
                self.outputCard.isHidden = true
                self.notesCard.isHidden = true
                self.wingmanToggle.isHidden = false
                self.fetchWingmanOptions(situation: t)
                self.inputText = t
                self.showPanel()
                self.inputTextLabel.text = t
                self.inputLangLabel.text = "YOUR SITUATION"
                return
            }

            self.performTranslation(text: t, source: "field")
        }
    }

    // MARK: - Paste Translation (incoming messages)

    /// When user pastes text in a non-native language, translate it to their native language.
    private func performPasteTranslation(text: String, detectedLang: String) {
        inputText = text
        isPasteTranslationActive = true

        let targetCode = LanguageManager.shared.targetLangRequired
        let native = nativeLang
        let inProf = TSProfiles[detectedLang] ?? TSProfiles[targetCode] ?? TSProfiles["es"]!
        let outProf = TSProfiles[native] ?? TSProfiles["en"]!

        directionLabel.text = "\(inProf.flag) → \(outProf.flag)"
        inputLangLabel.text = "📋 PASTED — \(inProf.name.uppercased())"
        outputLangLabel.text = "\(outProf.flag) \(outProf.name)"
        inputTextLabel.text = text
        outputTextLabel.text = "Translating..."

        showPanel()
        inputCard.isHidden = false
        outputCard.isHidden = false
        correctionCard.isHidden = true
        coachCard.isHidden = true
        notesCard.isHidden = true
        loadingSpinner.startAnimating()

        // Paste mode: X on input card (clear the pasted text), speaker on output (existing)
        pastePlayBtn.isHidden = false    // X on input card
        pasteClearBtn.isHidden = true    // no extra button on output — speaker already there
        swipeHintLabel.isHidden = true   // no "swipe for another" on paste translations

        // Translate to native language via DeepL
        TranslationService.shared.translate(
            text: text,
            from: inProf.deepL,
            to: outProf.deepL,
            style: .natural
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.loadingSpinner.stopAnimating()

                switch result {
                case .success(let translation):
                    self.translationHistory = [translation]
                    self.currentHistoryIndex = 0
                    self.outputTextLabel.text = translation

                    // Paste translations: NO notes, NO corrections, NO coaching, NO swipe hint
                    // The user just needs to read the translation — nothing else.
                    self.notesCard.isHidden = true
                    self.correctionCard.isHidden = true
                    self.coachCard.isHidden = true
                    self.swipeHintLabel.isHidden = true

                    NSLog("TSKBD_PASTE_TRANSLATED: \(text.prefix(40)) → \(translation.prefix(40))")

                case .failure:
                    self.outputTextLabel.text = "⚠️ Translation failed"
                    NSLog("TSKBD_PASTE_FAIL: could not translate pasted text")
                }
            }
        }
    }

    /// Shows a hint after the user's first outgoing translation, teaching them about paste-to-translate.
    private func showPasteHint() {
        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        guard !(defaults?.bool(forKey: "ts_paste_hint_shown") ?? false) else { return }
        defaults?.set(true, forKey: "ts_paste_hint_shown")
        defaults?.synchronize()

        // Show in the separate hint card — doesn't touch the notes card
        hintTextLabel.text = "You can also translate incoming messages right here. Just copy the message and tap Translate."
        hintCard.isHidden = false

        NSLog("TSKBD_PASTE_HINT: shown after first translation")
    }

    /// Shows a hint after the 3rd translation, teaching them about saving phrases.
    private func showSaveHint() {
        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        guard !(defaults?.bool(forKey: "ts_save_hint_shown") ?? false) else { return }
        defaults?.set(true, forKey: "ts_save_hint_shown")
        defaults?.synchronize()

        // Show in the separate hint card — doesn't touch the notes card
        hintTextLabel.text = "See a word or phrase worth remembering? Tap Save to add it to your study list."
        hintCard.isHidden = false

        NSLog("TSKBD_SAVE_HINT: shown after 3rd translation")
    }

    private func startDictationPolling() {
        dictationPollTimer?.invalidate()
        // Poll every 0.5s for up to 15 seconds waiting for dictation result
        dictationPollTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForPendingDictation()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self] in
            guard let self = self, self.dictationPollTimer != nil else { return }
            self.stopDictationPolling()
            self.hidePollingState()
            NSLog("TSKBD_SPEAK: polling timed out after 15s")
        }
    }

    private func stopDictationPolling() {
        dictationPollTimer?.invalidate()
        dictationPollTimer = nil
    }

    private func showEmpty() {
        emptyBar.isHidden = false
        panel.isHidden = true
        correctionCard.isHidden = true
        notesCard.isHidden = true
        hintCard.isHidden = true
        heightConstraint.constant = emptyHeight
        hidePollingState()

        // Show Remove + Translate when clipboard has text, otherwise Speak full width
        let clipboardHasText = UIPasteboard.general.hasStrings
        if clipboardHasText {
            removeBtn.isHidden = false
            translateClipboardBtn.isHidden = false
            micLeadingToEdge.isActive = false
            micLeadingToThird.isActive = true
        } else {
            removeBtn.isHidden = true
            translateClipboardBtn.isHidden = true
            micLeadingToThird.isActive = false
            micLeadingToEdge.isActive = true
        }
        emptyBar.layoutIfNeeded()
    }

    private func showPanel() {
        emptyBar.isHidden = true
        panel.isHidden = false
        heightConstraint.constant = expandedHeight
    }

    // MARK: - Colors

    private func applyColors() {
        inputCard.backgroundColor = cardBg
        inputTextLabel.textColor = textPrimary
        inputLangLabel.textColor = textSecondary
        outputTextLabel.textColor = textPrimary
        notesTextLabel.textColor = textPrimary
        correctionTextLabel.textColor = textPrimary
        emptyLabel.textColor = textSecondary
        updateToneSelection()
    }

    private func updateToneSelection() {
        for (i, v) in toneStack.arrangedSubviews.enumerated() {
            guard let btn = v as? UIButton else { continue }
            if tones[i].id == currentTone {
                btn.backgroundColor = UIColor.systemBlue
                btn.setTitleColor(.white, for: .normal)
            } else {
                btn.backgroundColor = cardBg
                btn.setTitleColor(textPrimary, for: .normal)
            }
        }
    }

    // MARK: - Language Detection

    private func detectLanguage(_ text: String) -> (code: String, name: String) {
        // We use our natural language detector backing utility
        let detector = LanguageDetector()
        let detected = detector.detectLanguage(from: text) ?? "en"
        let baseCode = detected.components(separatedBy: "-").first ?? "en"
        let prof = TSProfiles[baseCode] ?? TSProfiles["en"]!
        
        let appGroup = "group.com.jeff.translatehelper"
        let targetCode = LanguageManager.shared.targetLangRequired
        
        // If detector isn't sure and text is short, default to current selected Language
        if text.count < 3 && prof.code != targetCode && prof.code != "en" {
            let backup = TSProfiles[selectedLanguage] ?? TSProfiles["en"]!
            return (backup.code, backup.name)
        }
        
        return (prof.code, prof.name)
    }

    // MARK: - Actions

    // MARK: - Polling State UI

    /// Shows a "waiting for result" state in the empty bar while the keyboard polls
    /// for the dictation result from the main app's App Group UserDefaults.
    private func showPollingState() {
        // Dim the Speak button while waiting — but keep it tappable to cancel
        micButton.setTitle("⏳ Waiting… (tap to cancel)", for: .normal)
        micButton.backgroundColor = UIColor.systemGray.withAlphaComponent(0.12)
        micButton.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.3).cgColor
        micButton.setTitleColor(UIColor.systemGray, for: .normal)
        // Keep enabled so user can tap to cancel
    }

    /// Restores the empty bar to its normal idle state.
    private func hidePollingState() {
        micButton.setTitle("🎤  Speak", for: .normal)
        micButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.18)
        micButton.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.5).cgColor
        micButton.setTitleColor(.white, for: .normal)
        micButton.isEnabled = true
    }

    // MARK: - Mic (Speech-to-Text)
    
    @objc private func removeTextTapped() {
        // Brute force clear the text field
        for _ in 0..<5 {
            if let after = textDocumentProxy.documentContextAfterInput, !after.isEmpty {
                textDocumentProxy.adjustTextPosition(byCharacterOffset: after.count)
            }
        }
        for _ in 0..<2000 {
            textDocumentProxy.deleteBackward()
        }
        previousTextLength = 0
        isPasteTranslationActive = false
        showEmpty()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        NSLog("TSKBD_REMOVE: text field cleared")
    }

    @objc private func translateClipboardTapped() {

        guard let clipboardText = UIPasteboard.general.string,
              !clipboardText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            NSLog("TSKBD_CLIPBOARD: empty or no access")
            return
        }

        let text = clipboardText.trimmingCharacters(in: .whitespacesAndNewlines)
        let detected = detectLanguage(text)
        let targetCode = LanguageManager.shared.targetLangRequired

        let isTargetLang = detected.code == targetCode
        let isNotNative = detected.code != nativeLang && detected.code != "und"

        NSLog("TSKBD_CLIPBOARD: \(text.count) chars, detected=\(detected.code)")

        if isTargetLang || isNotNative {
            performPasteTranslation(text: text, detectedLang: isTargetLang ? targetCode : detected.code)
        } else {
            performTranslation(text: text, source: "clipboard")
        }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    @objc private func micTapped() {
        // If already waiting, tap cancels and resets
        if dictationPollTimer != nil {
            stopDictationPolling()
            hidePollingState()
            NSLog("TSKBD_SPEAK: cancelled by user tap")
            return
        }

        // Clear any existing text (e.g. pasted message) so the audio reply replaces it
        if let existing = textDocumentProxy.documentContextBeforeInput {
            for _ in 0..<existing.count { textDocumentProxy.deleteBackward() }
        }
        if let after = textDocumentProxy.documentContextAfterInput, !after.isEmpty {
            // Move cursor to end, then delete
            textDocumentProxy.adjustTextPosition(byCharacterOffset: after.count)
            for _ in 0..<after.count { textDocumentProxy.deleteBackward() }
        }
        previousTextLength = 0

        // Write a request timestamp so checkForPendingDictation ignores stale results
        // from any previous recording session.
        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        defaults?.set(Date().timeIntervalSince1970, forKey: "dictate_request_timestamp")
        defaults?.synchronize()

        // Pass the currently selected target language to the recording screen.
        let lang = selectedLanguage
        if let url = URL(string: "translatehelper://dictate?lang=\(lang)") {
            openURLViaResponder(url)
        }

        // Immediately show "waiting" state in the empty bar so the user knows
        // the keyboard is listening for the result from the main app.
        showPollingState()

        // Start polling — the main app will write the result to the App Group.
        startDictationPolling()
        NSLog("TSKBD_SPEAK: fired dictate URL, lang=\(lang), polling started")
    }

    private func openURLViaResponder(_ url: URL) {
        var responder: UIResponder? = self
        while let r = responder {
            if let app = r as? UIApplication {
                app.open(url)
                return
            }
            responder = r.next
        }
    }

    // MARK: - Recording Bar

    private func showRecordingBar() {
        // Always collapse the panel first — recording bar lives on the empty bar
        showEmpty()
        micButton.isHidden = true

        recordingSeconds = 0
        recordingTimeLbl.text = "0:00"
        recordingDotLbl.alpha = 1
        trashRecordBtn.isHidden = false
        sendRecordBtn.isHidden = false
        recordingDotLbl.isHidden = false
        recordingTimeLbl.isHidden = false

        // Count up timer
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.recordingSeconds += 1
            let m = self.recordingSeconds / 60
            let s = self.recordingSeconds % 60
            self.recordingTimeLbl.text = String(format: "%d:%02d", m, s)
        }

        // Blinking red dot
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.3) {
                self.recordingDotLbl.alpha = self.recordingDotLbl.alpha > 0.5 ? 0.1 : 1.0
            }
        }
    }

    private func hideRecordingBar() {
        recordingTimer?.invalidate(); recordingTimer = nil
        blinkTimer?.invalidate();     blinkTimer = nil
        trashRecordBtn.isHidden = true
        sendRecordBtn.isHidden = true
        recordingDotLbl.isHidden = true
        recordingTimeLbl.isHidden = true
        micButton.isHidden = false
    }

    @objc private func cancelRecording() {
        isRecording = false
        hideRecordingBar()
        SpeechService.shared.cancelListening()
    }

    @objc private func sendRecording() {
        isRecording = false
        hideRecordingBar()
        showPanel()
        directionLabel.text = "🎤 Processing..."
        inputTextLabel.text = "Sending to recognizer..."
        inputTextLabel.textColor = textSecondary
        outputCard.isHidden = true
        notesCard.isHidden = true

        NSLog("TSKBD_SEND: isListening=\(SpeechService.shared.isListening)")
        // stopListening signals endAudio → recognition fires isFinal callback → didFinishWith → translate
        SpeechService.shared.stopListening()
    }
    
    // MARK: - Speech Coaching
    
    private func performSpeechCoaching(text: String, language: String) {
        let flag = TSProfiles[language]?.flag ?? "🇺🇸"
        let langName = TSProfiles[language]?.name ?? "ENGLISH"
        
        // Input card: what you said
        directionLabel.text = "\(flag) Speech Coach"
        inputLangLabel.text = "\(flag) \(langName) (you said)"
        inputTextLabel.text = text
        
        // Output card: loading
        outputCard.isHidden = false
        outputLangLabel.text = "\(flag) IMPROVED PHRASING"
        outputTextLabel.text = "✨ Coaching..."
        
        notesCard.isHidden = true
        showPanel()
        
        let tone = Tone(rawValue: currentTone) ?? .casual
        
        TalkSwitchAPI.shared.coachSpeech(
            spokenText: text,
            language: language,
            tone: tone
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let coaching):
                    // Output card: native/improved version
                    self.outputTextLabel.text = coaching.nativeVersion
                    
                    // Notes card: mistakes + tips
                    self.notesCard.isHidden = false
                    self.notesTextLabel.text = self.capToTwoSentences(coaching.rawNotes)
                    
                    NSLog("TSKBD_COACHED: \(text) → \(coaching.nativeVersion)")
                    
                case .failure(let error):
                    self.outputTextLabel.text = text // fallback to their own text
                    self.notesCard.isHidden = false
                    self.notesTextLabel.text = "⚠️ Coaching unavailable: \(error.localizedDescription)"
                    NSLog("TSKBD_COACH_ERROR: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - TTS Cache Queue (writes request for main app to process)

    private func queueTTSCache(text: String, language: String) {
        let appGroup = "group.com.jeff.translatehelper"
        guard let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
                .appendingPathComponent("tts_cache", isDirectory: true) else { return }
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let hash = String(abs("\(text)|\(language)".hashValue))
        let cacheFile = dir.appendingPathComponent("\(hash).mp3")
        if FileManager.default.fileExists(atPath: cacheFile.path) { return }

        let requestsFile = dir.appendingPathComponent("_pending.json")
        var requests: [[String: String]] = []
        if let data = try? Data(contentsOf: requestsFile),
           let existing = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] {
            requests = existing
        }
        let entry = ["text": text, "language": language]
        guard !requests.contains(where: { $0["text"] == text && $0["language"] == language }) else { return }
        requests.append(entry)
        if requests.count > 30 { requests = Array(requests.suffix(30)) }
        if let data = try? JSONSerialization.data(withJSONObject: requests) {
            try? data.write(to: requestsFile)
        }
    }

    // MARK: - Mistake Profile Queue

    /// Writes a correction to the App Group queue for the main app to ingest.
    private func queueMistakeForProfile(
        userSaid: String,
        nativeSay: String,
        explanation: String,
        category: String?,
        language: String
    ) {
        let appGroup = "group.com.jeff.translatehelper"
        guard let defaults = UserDefaults(suiteName: appGroup) else { return }

        let queueKey = "ts_mistake_queue"
        var queue = defaults.array(forKey: queueKey) as? [[String: String]] ?? []

        let entry: [String: String] = [
            "userSaid": userSaid,
            "correctForm": nativeSay,
            "explanation": explanation,
            "category": category ?? "grammar",
            "language": language,
            "source": "keyboard",
            "timestamp": ISO8601DateFormatter().string(from: Date()),
        ]

        // Dedup
        let isDuplicate = queue.contains { existing in
            existing["correctForm"]?.lowercased() == nativeSay.lowercased() &&
            existing["language"] == language
        }
        guard !isDuplicate else { return }

        queue.append(entry)
        if queue.count > 50 { queue = Array(queue.suffix(50)) }
        defaults.set(queue, forKey: queueKey)
        defaults.synchronize()
    }

    // MARK: - Play Translation Aloud

    @objc private func playTapped() {
        guard let text = outputTextLabel.text,
              !text.isEmpty,
              text != "Translating...",
              text != "✨ Refining...",
              text != "⚠️ Translation failed" else { return }
        
        // Determine language of the translation output from actual target language setting
        let appGroup = "group.com.jeff.translatehelper"
        let targetCode = LanguageManager.shared.targetLangRequired

        // If the output card is showing the target language, use that locale. Otherwise English.
        let detected = detectLanguage(text)
        let lang: String
        if detected.code == "en" {
            lang = "en-US"
        } else {
            lang = SpeechService.localeString(for: detected.code)
        }
        
        SpeechService.shared.speak(text, language: lang)

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        // Voice quality nudge retired — using Google WaveNet TTS now
    }
    
    @objc private func outputCardTapped() {
        isOutputExpanded.toggle()
        
        if isOutputExpanded {
            // Expand — show all text, grow keyboard
            outputTextLabel.numberOfLines = 0
            inputTextLabel.numberOfLines = 0
            heightConstraint.constant = fullExpandedHeight
        } else {
            // Collapse back
            outputTextLabel.numberOfLines = 4
            inputTextLabel.numberOfLines = 2
            heightConstraint.constant = expandedHeight
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.superview?.layoutIfNeeded()
        }
    }



    @objc private func toneTapped(_ sender: UIButton) {
        currentTone = tones[sender.tag].id
        updateToneSelection()
        NSLog("TSKBD_TONE: \(currentTone)")

        // Show/hide Wingman toggle based on tone
        let isFlirty = currentTone == "flirty"
        wingmanToggle.isHidden = !isFlirty
        if !isFlirty && isWingmanMode {
            // Leaving flirty mode — reset wingman
            isWingmanMode = false
            updateWingmanToggleUI()
            wingmanOptionsStack.isHidden = true
            wingmanOnboardingCard.isHidden = true
            outputCard.isHidden = false
            notesCard.isHidden = false
        }

        // Re-translate with new tone if we have text
        if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if isWingmanMode {
                fetchWingmanOptions(situation: inputText)
            } else {
                performTranslation(text: inputText, source: "tone-change")
            }
        }
    }

    /// Clears all text from the field and resets the keyboard to empty state.
    /// Uses brute force deletion — textDocumentProxy only exposes ~200 chars at a time,
    /// so we just delete 2000 times. Extra calls after text is empty are no-ops.
    private func clearTextField() {
        // Move cursor to the end
        if let after = textDocumentProxy.documentContextAfterInput, !after.isEmpty {
            textDocumentProxy.adjustTextPosition(byCharacterOffset: after.count)
        }

        // Delete only what's actually there
        while let before = textDocumentProxy.documentContextBeforeInput, !before.isEmpty {
            for _ in 0..<before.count {
                textDocumentProxy.deleteBackward()
            }
        }

        previousTextLength = 0
        isPasteTranslationActive = false
        pastePlayBtn.isHidden = true
        pasteClearBtn.isHidden = true
        showEmpty()

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        NSLog("TSKBD_CLEAR: text field cleared")
    }

    /// X button on the input card — clears text field and resets
    @objc private func inputClearTapped() {
        clearTextField()
    }

    /// X button on the output card (paste mode) — also clears everything
    @objc private func pasteClearTapped() {
        clearTextField()
    }

    @objc private func replaceTapped() {
        guard let translated = outputTextLabel.text,
              !translated.isEmpty,
              translated != "Translating...",
              translated != "✨ Refining...",
              translated != "⚠️ Translation failed" else { return }

        // Kill all deferred work — user is done, release the extension immediately
        deferredPostTranslation?.cancel()
        deferredPostTranslation = nil

        // Move cursor to the very end first
        if let after = textDocumentProxy.documentContextAfterInput, !after.isEmpty {
            textDocumentProxy.adjustTextPosition(byCharacterOffset: after.count)
        }

        // Delete only what's actually there — avoids thousands of unnecessary IPC calls
        // documentContextBeforeInput can truncate, so loop until empty
        while let before = textDocumentProxy.documentContextBeforeInput, !before.isEmpty {
            for _ in 0..<before.count {
                textDocumentProxy.deleteBackward()
            }
        }

        // Insert the translation into a clean field
        textDocumentProxy.insertText(translated)

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // Immediately hand control back to the native keyboard (e.g. WhatsApp)
        advanceToNextInputMode()
    }


    @objc private func saveTapped() {
        let source      = inputTextLabel.text ?? ""
        let translation = outputTextLabel.text ?? ""
        guard !source.isEmpty, !translation.isEmpty else { return }

        // Determine languages from current direction
        let appGroup = "group.com.jeff.translatehelper"
        let targetCode = LanguageManager.shared.targetLangRequired
        
        let targetLang = selectedLanguage
        let sourceLang = selectedLanguage == targetCode ? "en" : targetCode

        guard let saveBtn = actionStack.arrangedSubviews[1] as? UIButton else { return }
        let originalTitle = saveBtn.title(for: .normal) ?? "Save 💾"
        saveBtn.setTitle("Extracting…", for: .normal)
        saveBtn.isEnabled = false
        
        let toneValue = Tone(rawValue: currentTone) ?? .casual
        
        TalkSwitchAPI.shared.extractKeyPhraseForSaving(
            original: source,
            translated: translation,
            sourceLang: sourceLang,
            targetLang: targetLang,
            tone: toneValue
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                var finalSource = source
                var finalTrans = translation
                var finalNotes: String? = nil
                
                switch result {
                case .success(let keyPhraseResult):
                    finalSource = keyPhraseResult.sourcePhrase
                    finalTrans = keyPhraseResult.targetPhrase
                    if !keyPhraseResult.notes.isEmpty {
                        finalNotes = keyPhraseResult.notes
                    }
                case .failure(let error):
                    NSLog("TSKBD_EXTRACT_ERROR: \(error.localizedDescription)")
                    // fallback to the original full strings on error
                }

                // Save to App Group shared container
                if let defaults = UserDefaults(suiteName: appGroup) {
                    let key = "talkswitch_saved_phrases"
                    var newEntry: [String: String] = [
                        "id":          UUID().uuidString,
                        "sourceText":  finalSource,
                        "translation": finalTrans,
                        "sourceLang":  sourceLang,
                        "targetLang":  targetLang,
                        "savedAt":     ISO8601DateFormatter().string(from: Date())
                    ]
                    if let notesStr = finalNotes {
                        newEntry["notes"] = notesStr
                    }
                    var existing = defaults.array(forKey: key) as? [[String: String]] ?? []
                    existing.insert(newEntry, at: 0) // Prepend so newest is first
                    defaults.set(existing, forKey: key)
                    defaults.synchronize()
                }

                saveBtn.isEnabled = true
                self.flashActionButton(index: 1, tempTitle: "Saved! ✅", originalTitle: "Save 💾")
            }
        }
    }

    @objc private func replaceTappedFlash() {
        flashActionButton(index: 0, tempTitle: "Replaced! ✅", originalTitle: "Replace ↩️")
    }

    private func flashActionButton(index: Int, tempTitle: String, originalTitle: String) {
        guard let btn = actionStack.arrangedSubviews[index] as? UIButton else { return }

        // Flash blue
        btn.backgroundColor = UIColor.systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle(tempTitle, for: .normal)

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // Revert after 1.2s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self = self else { return }
            btn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            btn.setTitleColor(.white, for: .normal)
            btn.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
            btn.setTitle(originalTitle, for: .normal)
        }
    }
}

// MARK: - Speech Recognition

extension KeyboardViewController: SpeechServiceDelegate {
    
    func speechService(_ service: SpeechService, didRecognize text: String, isFinal: Bool) {
        inputTextLabel.text = text + (isFinal ? "" : "…")
        inputTextLabel.textColor = textPrimary

        // Show live transcript in recording bar so user knows audio is flowing
        if isRecording {
            emptyLabel.isHidden = false
            emptyLabel.text = text.isEmpty ? "Listening…" : text
            emptyLabel.font = UIFont.systemFont(ofSize: 13)
            emptyLabel.textColor = textPrimary
        }

        if isFinal {
            directionLabel.text = "🎤 Processing..."
        }
    }
    
    func speechService(_ service: SpeechService, didFinishWith text: String, language: String, lowConfidenceWords: [String]) {
        if isRecording {
            isRecording = false
            hideRecordingBar()
            showPanel()
        }
        inputText = text
        detectedLanguage = language
        self.lowConfidenceWords = lowConfidenceWords

        // Update pill to reflect detected language
        let baseCode = language.components(separatedBy: "-").first ?? "en"
        let prof = TSProfiles[baseCode] ?? TSProfiles["en"]!
        
        let appGroup = "group.com.jeff.translatehelper"
        let defaults = UserDefaults(suiteName: appGroup)
        let targetCode = LanguageManager.shared.targetLangRequired
        
        // Match baseCode to target exactly or assume 'en'
        selectedLanguage = (prof.code == targetCode) ? targetCode : "en"
        defaults?.set(selectedLanguage, forKey: "talkswitch_lang")
        defaults?.synchronize()
        updateLangPill()

        NSLog("TSKBD_SPEECH_DONE: lang=\(language) text='\(text)'")

        // Translate
        performTranslation(text: text, source: selectedLanguage)
    }
    
    func speechService(_ service: SpeechService, didFailWith error: Error) {
        isRecording = false
        directionLabel.text = "⚠️ Mic error"
        inputTextLabel.text = error.localizedDescription
        NSLog("TSKBD_SPEECH_ERROR: \(error.localizedDescription)")
    }

    // MARK: - Enhanced Voice Banner

    // UserDefaults keys for banner frequency logic
    private static let kVoiceBannerCount     = "natural_voice_prompt_count"
    private static let kVoiceBannerDismissed = "natural_voice_prompt_dismissed"

    /// Returns true when the banner should appear, and increments its counter.
    /// Shows on the 1st, 10th, and 20th speaker tap with no premium voice —
    /// 3 gentle nudges total, then permanently stops unless user reinstalls.
    private func shouldShowNaturalVoiceBanner() -> Bool {
        #if DEBUG
        // Always show in debug builds so the UI is easy to test.
        // Counter is also reset at launch (see viewDidLoad debug block).
        return true
        #else
        if UserDefaults.standard.bool(forKey: Self.kVoiceBannerDismissed) { return false }
        let count = UserDefaults.standard.integer(forKey: Self.kVoiceBannerCount) + 1
        UserDefaults.standard.set(count, forKey: Self.kVoiceBannerCount)
        return count == 1 || count == 10 || count == 20
        #endif
    }

    private func showEnhancedVoiceBanner(language: String) {
        guard enhancedVoiceBanner == nil else { return }

        // ── Outer card: purple/indigo ──────────────────────────────
        let banner = UIView()
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.14)
        banner.layer.cornerRadius = 12
        banner.layer.borderWidth = 1.2
        banner.layer.borderColor = UIColor.systemIndigo.withAlphaComponent(0.45).cgColor
        banner.clipsToBounds = true

        // ── Top row: 🗣️ icon + "Natural Voice" title ───────────────
        let iconLabel = UILabel()
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.text = "🗣️"
        iconLabel.font = UIFont.systemFont(ofSize: 18)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Natural Voice"
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        titleLabel.textColor = UIColor.systemIndigo

        // ── Instruction ────────────────────────────────────────────
        let instructionsLabel = UILabel()
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.text = "In Settings tap TalkSwitch Keyboard → Allow Full Access. Then: Accessibility → Spoken Content → Voices → Spanish → pick a voice with ★."
        instructionsLabel.font = UIFont.systemFont(ofSize: 11.5, weight: .regular)
        instructionsLabel.textColor = UIColor.label.withAlphaComponent(0.72)
        instructionsLabel.numberOfLines = 0

        // ── "Open Keyboard Settings →" button ─────────────────────────
        let goBtn = UIButton(type: .system)
        goBtn.translatesAutoresizingMaskIntoConstraints = false
        goBtn.setTitle("Open Keyboard Settings →", for: .normal)
        goBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        goBtn.tintColor = .white
        goBtn.backgroundColor = UIColor.systemIndigo
        goBtn.layer.cornerRadius = 8
        goBtn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        goBtn.addTarget(self, action: #selector(openSpokenContentSettings), for: .touchUpInside)

        // ── Bottom row: "Don't show again" (left) + "swipe to dismiss →" (right) ──
        let dontShowBtn = UIButton(type: .system)
        dontShowBtn.translatesAutoresizingMaskIntoConstraints = false
        dontShowBtn.setTitle("Don't show again", for: .normal)
        dontShowBtn.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        dontShowBtn.tintColor = UIColor.systemIndigo.withAlphaComponent(0.5)
        dontShowBtn.addTarget(self, action: #selector(dontShowVoiceBannerAgain), for: .touchUpInside)
        dontShowBtn.contentEdgeInsets = .zero

        let swipeLabel = UILabel()
        swipeLabel.translatesAutoresizingMaskIntoConstraints = false
        swipeLabel.text = "swipe to dismiss →"
        swipeLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        swipeLabel.textColor = UIColor.systemIndigo.withAlphaComponent(0.45)
        swipeLabel.textAlignment = .right

        banner.addSubview(iconLabel)
        banner.addSubview(titleLabel)
        banner.addSubview(instructionsLabel)
        banner.addSubview(goBtn)
        banner.addSubview(dontShowBtn)
        banner.addSubview(swipeLabel)

        NSLayoutConstraint.activate([
            // Icon — top-left
            iconLabel.topAnchor.constraint(equalTo: banner.topAnchor, constant: 10),
            iconLabel.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 12),
            iconLabel.widthAnchor.constraint(equalToConstant: 24),

            // Title inline with icon
            titleLabel.centerYAnchor.constraint(equalTo: iconLabel.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -12),

            // Instructions below icon
            instructionsLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 5),
            instructionsLabel.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 12),
            instructionsLabel.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -12),

            // Go to Settings button
            goBtn.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 8),
            goBtn.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 12),

            // Bottom row
            dontShowBtn.topAnchor.constraint(equalTo: goBtn.bottomAnchor, constant: 7),
            dontShowBtn.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 12),
            dontShowBtn.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -8),

            swipeLabel.centerYAnchor.constraint(equalTo: dontShowBtn.centerYAnchor),
            swipeLabel.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -12),
        ])

        // ── Swipe right to dismiss ─────────────────────────────────
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(naturalVoiceBannerPanned(_:)))
        banner.addGestureRecognizer(swipe)
        banner.isUserInteractionEnabled = true

        // Insert after the top bar (index 1), above the input card
        contentStack.insertArrangedSubview(banner, at: 1)
        enhancedVoiceBanner = banner
    }

    /// Opens General → Keyboard settings — where TalkSwitch Keyboard appears
    /// with its two toggles (enable keyboard + Allow Full Access).
    @objc private func openSpokenContentSettings() {
        // Try candidates in order — first one that opens wins.
        // App-Prefs:root= format is required (not App-Prefs:General directly).
        let candidates = [
            "App-Prefs:root=General&path=Keyboard",  // iOS 14+ → General > Keyboard
            "prefs:root=General&path=Keyboard",       // iOS 13 fallback
            "App-Prefs:root=General",                 // worst case: just General page
        ]
        for urlString in candidates {
            if let url = URL(string: urlString) {
                openURLViaResponder(url)
                return
            }
        }
    }

    /// Permanently suppresses the Natural Voice banner ("Don't show again").
    @objc private func dontShowVoiceBannerAgain() {
        UserDefaults.standard.set(true, forKey: Self.kVoiceBannerDismissed)
        dismissEnhancedVoiceBanner()
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        NSLog("TSKBD_VOICE_BANNER: permanently dismissed by user")
    }

    /// Swipe the Natural Voice card right to dismiss it (temporary — will resurface).
    @objc private func naturalVoiceBannerPanned(_ gesture: UIPanGestureRecognizer) {
        guard let banner = enhancedVoiceBanner else { return }
        let tx = gesture.translation(in: banner).x
        switch gesture.state {
        case .changed:
            let clamped = max(0, tx)
            banner.transform = CGAffineTransform(translationX: clamped, y: 0)
            banner.alpha = max(0.3, 1.0 - (clamped / 180))
        case .ended, .cancelled:
            if tx > 80 {
                UIView.animate(withDuration: 0.22, animations: {
                    banner.transform = CGAffineTransform(translationX: 350, y: 0)
                    banner.alpha = 0
                }) { _ in
                    self.dismissEnhancedVoiceBanner()
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    banner.transform = .identity
                    banner.alpha = 1
                }
            }
        default: break
        }
    }

    @objc private func openVoiceSettings() { /* no-op — kept for safety */ }

    @objc private func dismissEnhancedVoiceBanner() {
        enhancedVoiceBanner?.removeFromSuperview()
        enhancedVoiceBanner = nil
    }

}

// MARK: - UIColor blend helper
private extension UIColor {
    func blend(with other: UIColor, ratio: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        other.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return UIColor(red:   r1 + (r2 - r1) * ratio,
                       green: g1 + (g2 - g1) * ratio,
                       blue:  b1 + (b2 - b1) * ratio,
                       alpha: a1 + (a2 - a1) * ratio)
    }
}
