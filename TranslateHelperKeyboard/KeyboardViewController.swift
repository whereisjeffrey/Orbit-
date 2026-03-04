import UIKit
import AVFoundation

struct TSLangProfile {
    let code: String
    let deepL: TranslationService.Language
    let flag: String
    let name: String
    let emojiFont: Bool // some generic flag fallback
}

let TSProfiles: [String: TSLangProfile] = [
    "en": TSLangProfile(code: "en", deepL: .english,     flag: "🇺🇸", name: "ENGLISH",    emojiFont: true),
    "pt": TSLangProfile(code: "pt", deepL: .portugueseBR, flag: "🇧🇷", name: "PORTUGUESE", emojiFont: true),
    "es": TSLangProfile(code: "es", deepL: .spanish,  flag: "🇪🇸", name: "SPANISH",  emojiFont: true),
    "fr": TSLangProfile(code: "fr", deepL: .french,   flag: "🇫🇷", name: "FRENCH",   emojiFont: true),
    "de": TSLangProfile(code: "de", deepL: .german,   flag: "🇩🇪", name: "GERMAN",   emojiFont: true),
    "it": TSLangProfile(code: "it", deepL: .italian,  flag: "🇮🇹", name: "ITALIAN",  emojiFont: true),
    "ja": TSLangProfile(code: "ja", deepL: .japanese, flag: "🇯🇵", name: "JAPANESE", emojiFont: true),
    "ko": TSLangProfile(code: "ko", deepL: .korean,   flag: "🇰🇷", name: "KOREAN",   emojiFont: true),
    "ar": TSLangProfile(code: "ar", deepL: .arabic,   flag: "🇦🇪", name: "ARABIC",   emojiFont: true),
    "zh": TSLangProfile(code: "zh", deepL: .chinese,  flag: "🇨🇳", name: "CHINESE",  emojiFont: true)
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
    private var selectedLanguage: String = "es" // persisted preference (default: Spanish)
    private var lastSourceWasSpeech: Bool = false

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
    private var translationHistory: [String] = []
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
    private let toneStack = UIStackView()
    private let actionStack = UIStackView()

    private let tones: [(id: String, label: String, icon: String)] = [
        ("casual",  "Casual",  "😊"),
        ("slang",   "Slang",   "🗣️"),
        ("work",    "Work",    "💼"),
        ("flirty",  "Flirty",  "🔥")
    ]

    // MARK: - Colors

    private var panelBg: UIColor {
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.13, green: 0.13, blue: 0.14, alpha: 1.0)
            : UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0)
    }
    private var cardBg: UIColor {
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 0.18, alpha: 1.0) : .white
    }
    private var textPrimary: UIColor {
        traitCollection.userInterfaceStyle == .dark ? .white : .black
    }
    private var textSecondary: UIColor {
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 0.6, alpha: 1.0) : UIColor(white: 0.4, alpha: 1.0)
    }


    // MARK: - Lifecycle

    private func checkForPendingDictation() {
        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        let requestTs = defaults?.double(forKey: "dictate_request_timestamp") ?? 0
        let resultTs  = defaults?.double(forKey: "dictate_result_timestamp")  ?? 0
        guard resultTs > requestTs,
              let dictated = defaults?.string(forKey: "dictate_result"),
              !dictated.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Read auto-detected language written by DictateViewController
        let detectedLang = defaults?.string(forKey: "dictate_result_language") ?? selectedLanguage

        defaults?.removeObject(forKey: "dictate_result")
        defaults?.removeObject(forKey: "dictate_result_language")
        defaults?.removeObject(forKey: "dictate_result_timestamp")
        defaults?.synchronize()

        stopDictationPolling()
        // Append dictated text to whatever is already in the field (cumulative)
        let existingBefore = textDocumentProxy.documentContextBeforeInput ?? ""
        let existingAfter  = textDocumentProxy.documentContextAfterInput  ?? ""
        let existingText   = (existingBefore + existingAfter).trimmingCharacters(in: .whitespacesAndNewlines)
        let separator      = existingText.isEmpty ? "" : " "
        textDocumentProxy.insertText(separator + dictated)

        // Brief delay so the proxy updates, then read full combined text and translate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            guard let self = self else { return }
            let before = self.textDocumentProxy.documentContextBeforeInput ?? ""
            let after  = self.textDocumentProxy.documentContextAfterInput  ?? ""
            let fullText = (before + after).trimmingCharacters(in: .whitespacesAndNewlines)
            let textToTranslate = fullText.isEmpty ? dictated : fullText

            self.lastSourceWasSpeech = true
            self.performTranslation(text: textToTranslate, source: "speech")
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

        // Restore persisted language preference
        let appGroup = "group.com.jeff.translatehelper"
        let defaults = UserDefaults(suiteName: appGroup)
        let saved = defaults?.string(forKey: "talkswitch_lang") ?? "es"
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForPendingDictation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.autoDetect()
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

        if !fieldText.isEmpty {
            performTranslation(text: fieldText, source: "field")
        } else {
            showEmpty()
        }
    }

    private func performTranslation(text: String, source: String) {
        inputText = text

        let detected = detectLanguage(text)
        detectedLanguage = detected.code

        let appGroup = "group.com.jeff.translatehelper"
        let defaults = UserDefaults(suiteName: appGroup)
        let targetCode = defaults?.string(forKey: "talkswitch_target_lang") ?? "es"
        
        let isSourceTarget = (detected.code == targetCode)
        let inProf = isSourceTarget ? (TSProfiles[targetCode] ?? TSProfiles["es"]!) : TSProfiles["en"]!
        let outProf = isSourceTarget ? TSProfiles["en"]! : (TSProfiles[targetCode] ?? TSProfiles["es"]!)

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

        // Map tone to DeepL style
        let style: TranslationService.TranslationStyle
        switch currentTone {
        case "casual", "slang", "flirty": style = .casual
        case "work": style = .formal
        default: style = .natural
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
                    self.translationHistory = []
                    self.currentHistoryIndex = -1
                    // Slang/Flirty/Casual all get OpenAI refinement so location-aware
                    // slang distribution is active for every conversational tone.
                    let needsRefinement = self.currentTone == "slang"
                        || self.currentTone == "flirty"
                        || self.currentTone == "casual"
                    
                    if needsRefinement {
                        self.outputTextLabel.text = "✨ Refining..."
                        
                        let tone = Tone(rawValue: self.currentTone) ?? .slang
                        let langCode = detected.code
                        
                        TalkSwitchAPI.shared.refineTranslation(
                            original: text,
                            deeplTranslation: translation,
                            sourceLang: langCode,
                            targetLang: langCode == "es" ? "en" : "es",
                            tone: tone
                        ) { [weak self] refineResult in
                            DispatchQueue.main.async {
                                guard let self = self else { return }
                                switch refineResult {
                                case .success(let refined):
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
                                        default:       icon = "💬"  // casual / work
                                        }
                                        self.notesTextLabel.text = "\(icon) \(notes)"
                                    } else {
                                        self.notesCard.isHidden = true
                                    }
                                    TalkSwitchAPI.shared.recordTranslationForPersona(original: text, translated: refined.output, tone: tone)
                                    NSLog("TSKBD_REFINED: \(text) → \(refined.output)")
                                case .failure(let error):
                                    // Fall back to DeepL translation
                                    self.outputTextLabel.text = translation
                                    self.notesCard.isHidden = false
                                    self.notesTextLabel.text = "⚠️ AI refinement unavailable, showing base translation"
                                    TalkSwitchAPI.shared.recordTranslationForPersona(original: text, translated: translation, tone: tone)
                                    NSLog("TSKBD_REFINE_ERROR: \(error.localizedDescription)")
                                }
                            }
                        }
                    } else {
                        self.translationHistory = [translation]
                        self.currentHistoryIndex = 0
                        self.outputTextLabel.text = translation
                        self.updateSwipeHint()
                        self.updateNotes(original: text, translated: translation)
                        TalkSwitchAPI.shared.recordTranslationForPersona(original: text, translated: translation, tone: Tone(rawValue: self.currentTone) ?? .casual)
                        NSLog("TSKBD_TRANSLATED: \(text) → \(translation)")
                    }
                    
                case .failure(let error):
                    self.outputTextLabel.text = "⚠️ Translation failed"
                    self.notesCard.isHidden = false
                    self.notesTextLabel.text = "Error: \(error.localizedDescription)"
                    NSLog("TSKBD_ERROR: \(error.localizedDescription)")
                }
            }
        }
    }

    private func updateNotes(original: String, translated: String) {
        // Always show notes with smart coaching from OpenAI
        notesCard.isHidden = false
        notesTextLabel.text = "💭 Loading tips..."
        
        let detected = detectLanguage(original)
        let sourceLang = detected.code
        let targetLang = sourceLang == "es" ? "en" : "es"
        let tone = Tone(rawValue: currentTone) ?? .casual
        
        // Add pronunciation context if we have low-confidence words from speech
        let pronunciationContext: String?
        if !lowConfidenceWords.isEmpty {
            pronunciationContext = "The user SPOKE this (not typed). These words had low recognition confidence (possible mispronunciation): \(lowConfidenceWords.joined(separator: ", ")). Include pronunciation tips for these words."
            lowConfidenceWords = [] // Reset for next use
        } else {
            pronunciationContext = nil
        }
        
        TalkSwitchAPI.shared.getSmartNotes(
            original: original,
            translated: translated,
            sourceLang: sourceLang,
            targetLang: targetLang,
            tone: tone,
            pronunciationContext: pronunciationContext
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let notes):
                    self.notesTextLabel.text = notes
                case .failure:
                    // Fallback to basic notes
                    self.showBasicNotes(original: original)
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
            notesCard.isHidden = true
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

        // ── Clean empty bar: icon + label centred, mic button right ──────
        // Icon view (blue mic circle)
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        // Try keyboard bundle first, then containing app bundle
        var logoImage: UIImage? = UIImage(named: "TalkSwitchLogo")
        if logoImage == nil {
            let appBundleURL = Bundle.main.bundleURL
                .deletingLastPathComponent()
                .deletingLastPathComponent()
            if let appBundle = Bundle(url: appBundleURL) {
                logoImage = UIImage(named: "AppIcon", in: appBundle, compatibleWith: nil)
            }
        }
        if let logo = logoImage {
            iconView.image = logo.withRenderingMode(.alwaysOriginal)
        } else {
            let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
            iconView.image = UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: cfg)
            iconView.tintColor = UIColor.systemBlue
        }
        iconView.contentMode = .scaleAspectFit
        emptyBar.addSubview(iconView)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "Tap the microphone below to translate"
        emptyLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        emptyLabel.textColor = textSecondary
        emptyBar.addSubview(emptyLabel)

        // Mic button — kept in view hierarchy but hidden (tap-anywhere handles it)
        micButton.translatesAutoresizingMaskIntoConstraints = false
        micButton.isHidden = true
        micButton.addTarget(self, action: #selector(micTapped), for: .touchUpInside)
        emptyBar.addSubview(micButton)

        // Language pill — small, right side, tap to toggle
        langPill.translatesAutoresizingMaskIntoConstraints = false
        langPill.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        langPill.layer.cornerRadius = 12
        langPill.clipsToBounds = true
        langPill.addTarget(self, action: #selector(langPillTapped), for: .touchUpInside)
        emptyBar.addSubview(langPill)
        updateLangPill()

        // Tap anywhere on empty bar opens DictateVC
        let barTap = UITapGestureRecognizer(target: self, action: #selector(micTapped))
        emptyBar.addGestureRecognizer(barTap)

        let centerStack = UIStackView(arrangedSubviews: [iconView, emptyLabel])
        centerStack.translatesAutoresizingMaskIntoConstraints = false
        centerStack.axis = .horizontal
        centerStack.spacing = 6
        centerStack.alignment = .center
        emptyBar.addSubview(centerStack)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 45),
            iconView.heightAnchor.constraint(equalToConstant: 45),

            centerStack.centerXAnchor.constraint(equalTo: emptyBar.centerXAnchor),
            centerStack.centerYAnchor.constraint(equalTo: emptyBar.centerYAnchor),

            langPill.trailingAnchor.constraint(equalTo: emptyBar.trailingAnchor, constant: -12),
            langPill.centerYAnchor.constraint(equalTo: emptyBar.centerYAnchor),
            langPill.heightAnchor.constraint(equalToConstant: 26),

            micButton.trailingAnchor.constraint(equalTo: emptyBar.trailingAnchor, constant: -14),
            micButton.centerYAnchor.constraint(equalTo: emptyBar.centerYAnchor),
            micButton.widthAnchor.constraint(equalToConstant: 44),
            micButton.heightAnchor.constraint(equalToConstant: 44),
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
        let targetCode = defaults?.string(forKey: "talkswitch_target_lang") ?? "es"
        
        let newLang = lang.hasPrefix(targetCode) ? targetCode : "en"
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
        let targetCode = defaults?.string(forKey: "talkswitch_target_lang") ?? "es"
        
        selectedLanguage = (selectedLanguage == targetCode) ? "en" : targetCode
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
        if selectedLanguage == "en" {
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

        // === Notes card ===
        setupNotesCard()
        contentStack.addArrangedSubview(notesCard)

        // === Tone selector ===
        setupToneStack()
        contentStack.addArrangedSubview(toneStack)

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

        NSLayoutConstraint.activate([
            inputCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            inputLangLabel.topAnchor.constraint(equalTo: inputCard.topAnchor, constant: 8),
            inputLangLabel.leadingAnchor.constraint(equalTo: inputCard.leadingAnchor, constant: 12),
            inputTextLabel.topAnchor.constraint(equalTo: inputLangLabel.bottomAnchor, constant: 2),
            inputTextLabel.leadingAnchor.constraint(equalTo: inputCard.leadingAnchor, constant: 12),
            inputTextLabel.trailingAnchor.constraint(equalTo: inputCard.trailingAnchor, constant: -12),
            inputTextLabel.bottomAnchor.constraint(equalTo: inputCard.bottomAnchor, constant: -8),
        ])
    }

    private func setupOutputCard() {
        outputCard.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        outputCard.layer.cornerRadius = 10
        outputCard.layer.borderWidth = 1
        outputCard.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        outputCard.translatesAutoresizingMaskIntoConstraints = false

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

        NSLayoutConstraint.activate([
            outputCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            outputLangLabel.topAnchor.constraint(equalTo: outputCard.topAnchor, constant: 8),
            outputLangLabel.leadingAnchor.constraint(equalTo: outputCard.leadingAnchor, constant: 12),
            speakerBtn.trailingAnchor.constraint(equalTo: outputCard.trailingAnchor, constant: -10),
            speakerBtn.centerYAnchor.constraint(equalTo: outputCard.centerYAnchor),
            speakerBtn.widthAnchor.constraint(equalToConstant: 32),
            speakerBtn.heightAnchor.constraint(equalToConstant: 32),
            outputTextLabel.topAnchor.constraint(equalTo: outputLangLabel.bottomAnchor, constant: 2),
            outputTextLabel.leadingAnchor.constraint(equalTo: outputCard.leadingAnchor, constant: 12),
            outputTextLabel.trailingAnchor.constraint(equalTo: speakerBtn.leadingAnchor, constant: -8),
            outputTextLabel.bottomAnchor.constraint(equalTo: outputCard.bottomAnchor, constant: -10),
            swipeHintLabel.bottomAnchor.constraint(equalTo: outputCard.bottomAnchor, constant: -4),
            swipeHintLabel.trailingAnchor.constraint(equalTo: speakerBtn.leadingAnchor, constant: -6),
        ])
    }

    // MARK: - Swipe for alternative translation

    @objc private func outputCardPanned(_ gesture: UIPanGestureRecognizer) {
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

        let tone = Tone(rawValue: currentTone) ?? .casual
        TalkSwitchAPI.shared.alternativeTranslation(
            original: inputText,
            currentTranslation: previousTranslation,
            sourceLang: detectedLanguage,
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

        notesTextLabel.font = UIFont.systemFont(ofSize: 13)
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
            ("Copy 📋", #selector(copyTapped)),
            ("Save 💾", #selector(saveTapped)),
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

    // MARK: - Show States

    private var autoTranslateTimer: Timer?
    private var dictationPollTimer: Timer?

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        autoTranslateTimer?.invalidate()
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let after  = textDocumentProxy.documentContextAfterInput  ?? ""
        let text   = (before + after).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { showEmpty(); return }
        // Debounce: wait 1.8s after last keystroke then auto-translate
        autoTranslateTimer = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            let b = self.textDocumentProxy.documentContextBeforeInput ?? ""
            let a = self.textDocumentProxy.documentContextAfterInput  ?? ""
            let t = (b + a).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !t.isEmpty else { return }
            self.performTranslation(text: t, source: "field")
        }
    }

    private func startDictationPolling() {
        dictationPollTimer?.invalidate()
        // Poll every 0.5s for up to 3 minutes waiting for dictation result
        dictationPollTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForPendingDictation()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 180) { [weak self] in
            self?.dictationPollTimer?.invalidate()
        }
    }

    private func stopDictationPolling() {
        dictationPollTimer?.invalidate()
        dictationPollTimer = nil
    }

    private func showEmpty() {
        emptyBar.isHidden = false
        panel.isHidden = true
        heightConstraint.constant = emptyHeight
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
        let targetCode = UserDefaults(suiteName: appGroup)?.string(forKey: "talkswitch_target_lang") ?? "es"
        
        // If detector isn't sure and text is short, default to current selected Language
        if text.count < 3 && prof.code != targetCode && prof.code != "en" {
            let backup = TSProfiles[selectedLanguage] ?? TSProfiles["en"]!
            return (backup.code, backup.name)
        }
        
        return (prof.code, prof.name)
    }

    // MARK: - Actions

    // MARK: - Mic (Speech-to-Text)
    
    @objc private func micTapped() {
        // MVP: native iOS mic handles recording. Show one-time guidance tip only.
        let key = "talkswitch_mic_tip_shown"
        guard UserDefaults.standard.bool(forKey: key) == false else { return }
        UserDefaults.standard.set(true, forKey: key)
        // showMicTip() // Removed as it was missing from this scope
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
        emptyLabel.isHidden = true
        micButton.isHidden = true
        langPill.isHidden = true

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
        emptyLabel.isHidden = false
        micButton.isHidden = false
        langPill.isHidden = false
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
                    self.notesTextLabel.text = coaching.rawNotes
                    
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
    
    // MARK: - Play Translation Aloud
    
    @objc private func playTapped() {
        guard let text = outputTextLabel.text,
              !text.isEmpty,
              text != "Translating...",
              text != "✨ Refining...",
              text != "⚠️ Translation failed" else { return }
        
        // Determine language of the translation output
        let lang: String
        // Detect output language from the flag in the label
        if outputLangLabel.text?.contains("🇲🇽") == true || outputLangLabel.text?.contains("🇪🇸") == true {
            lang = "es-MX"
        } else {
            lang = "en-US"
        }
        
        SpeechService.shared.speak(text, language: lang)

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        // Show voice quality nudge with smart frequency logic
        let langPrefix = lang.hasPrefix("es") ? "es" : "en"
        if !SpeechService.hasEnhancedVoice(for: langPrefix) && shouldShowNaturalVoiceBanner() {
            showEnhancedVoiceBanner(language: langPrefix)
        }
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

        // Re-translate with new tone if we have text
        if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            performTranslation(text: inputText, source: "tone-change")
        }
    }

    @objc private func replaceTapped() {
        guard let translated = outputTextLabel.text,
              !translated.isEmpty,
              translated != "Translating...",
              translated != "⚠️ Translation failed" else { return }

        if let before = textDocumentProxy.documentContextBeforeInput {
            for _ in 0..<before.count { textDocumentProxy.deleteBackward() }
        }
        textDocumentProxy.insertText(translated)
        flashActionButton(index: 0, tempTitle: "Replaced! ✅", originalTitle: "Replace ↩️")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.showEmpty()
        }
    }

    @objc private func copyTapped() {
        UIPasteboard.general.string = outputTextLabel.text
        flashActionButton(index: 1, tempTitle: "Copied! ✅", originalTitle: "Copy 📋")
    }

    @objc private func saveTapped() {
        let source      = inputTextLabel.text ?? ""
        let translation = outputTextLabel.text ?? ""
        guard !source.isEmpty, !translation.isEmpty else { return }

        // Determine languages from current direction
        let appGroup = "group.com.jeff.translatehelper"
        let targetCode = UserDefaults(suiteName: appGroup)?.string(forKey: "talkswitch_target_lang") ?? "es"
        
        let targetLang = selectedLanguage
        let sourceLang = selectedLanguage == targetCode ? "en" : targetCode

        guard let saveBtn = actionStack.arrangedSubviews[2] as? UIButton else { return }
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
                    defaults.synchronize() // Force write to shared container
                }

                saveBtn.isEnabled = true
                self.flashActionButton(index: 2, tempTitle: "Saved! ✅", originalTitle: "Save 💾")
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
        let targetCode = defaults?.string(forKey: "talkswitch_target_lang") ?? "es"
        
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

    private func showEnhancedVoiceBanner(language: String = "es") {
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
