import UIKit
import AVFoundation

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
    private var selectedLanguage: String = "pt" // persisted preference
    private var lastSourceWasSpeech: Bool = false

    // MARK: - UI Elements

    private let emptyBar = UIView()
    private let emptyLabel = UILabel()
    private let langPill = UIButton(type: .system)
    private let micButton = UIButton(type: .system)

    private let panel = UIView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

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

    private let globeButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("TSKBD_LOADED ✅")

        // Restore persisted language preference
        let saved = UserDefaults.standard.string(forKey: "talkswitch_lang") ?? "pt"
        selectedLanguage = saved
        updateLangPill()

        heightConstraint = view.heightAnchor.constraint(equalToConstant: emptyHeight)
        heightConstraint.priority = .required
        heightConstraint.isActive = true
        view.backgroundColor = panelBg

        setupEmptyBar()
        setupPanel()
        setupGlobeButton()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.autoDetect()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        let fieldText = textDocumentProxy.documentContextBeforeInput ?? ""

        if !fieldText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            performTranslation(text: fieldText, source: "field")
            return
        }

        if let clipText = UIPasteboard.general.string,
           !clipText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            performTranslation(text: clipText, source: "clipboard")
            return
        }

        showEmpty()
    }

    private func performTranslation(text: String, source: String) {
        inputText = text

        let detected = detectLanguage(text)
        detectedLanguage = detected.code

        let sourceLang: TranslationService.Language
        let targetLang: TranslationService.Language

        // Direction header + language mapping
        if detected.code == "pt" {
            directionLabel.text = "🇧🇷 → 🇺🇸"
            inputLangLabel.text = "🇧🇷 PORTUGUESE"
            outputLangLabel.text = "🇺🇸 ENGLISH"
            sourceLang = .portugueseBR
            targetLang = .english
        } else {
            directionLabel.text = "🇺🇸 → 🇧🇷"
            inputLangLabel.text = "🇺🇸 ENGLISH"
            outputLangLabel.text = "🇧🇷 PORTUGUESE"
            sourceLang = .english
            targetLang = .portugueseBR
        }

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
                    // For slang/flirty: refine with OpenAI
                    let needsRefinement = self.currentTone == "slang" || self.currentTone == "flirty"
                    
                    if needsRefinement {
                        self.outputTextLabel.text = "✨ Refining..."
                        
                        let tone = Tone(rawValue: self.currentTone) ?? .slang
                        let langCode = detected.code
                        
                        TalkSwitchAPI.shared.refineTranslation(
                            original: text,
                            deeplTranslation: translation,
                            sourceLang: langCode,
                            targetLang: langCode == "pt" ? "en" : "pt",
                            tone: tone
                        ) { [weak self] refineResult in
                            DispatchQueue.main.async {
                                guard let self = self else { return }
                                switch refineResult {
                                case .success(let refined):
                                    self.outputTextLabel.text = refined.output
                                    if let notes = refined.notes {
                                        self.notesCard.isHidden = false
                                        let icon = self.currentTone == "flirty" ? "😏" : "🔥"
                                        self.notesTextLabel.text = "\(icon) \(notes)"
                                    } else {
                                        self.notesCard.isHidden = true
                                    }
                                    NSLog("TSKBD_REFINED: \(text) → \(refined.output)")
                                case .failure(let error):
                                    // Fall back to DeepL translation
                                    self.outputTextLabel.text = translation
                                    self.notesCard.isHidden = false
                                    self.notesTextLabel.text = "⚠️ AI refinement unavailable, showing base translation"
                                    NSLog("TSKBD_REFINE_ERROR: \(error.localizedDescription)")
                                }
                            }
                        }
                    } else {
                        self.outputTextLabel.text = translation
                        self.updateNotes(original: text, translated: translation)
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
        let targetLang = sourceLang == "pt" ? "en" : "pt"
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
                       "dar um jeitinho", "ficar de boa", "tá ligado", "mano", "cara",
                       "pô", "beleza", "valeu", "saudade", "falar sério"]
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

        // Coaching language pill — tap to toggle between EN and PT
        // This is NOT a keyboard language switcher (that's Apple's).
        // This controls which language TalkSwitch coaches you in.
        langPill.translatesAutoresizingMaskIntoConstraints = false
        langPill.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        langPill.layer.cornerRadius = 14
        langPill.clipsToBounds = true
        langPill.addTarget(self, action: #selector(langPillTapped), for: .touchUpInside)
        emptyBar.addSubview(langPill)
        updateLangPill()

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "Copy text or tap 🎤"
        emptyLabel.font = UIFont.systemFont(ofSize: 13)
        emptyLabel.textColor = textSecondary
        emptyBar.addSubview(emptyLabel)

        // Mic button
        micButton.translatesAutoresizingMaskIntoConstraints = false
        micButton.setTitle("🎤", for: .normal)
        micButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        micButton.addTarget(self, action: #selector(micTapped), for: .touchUpInside)
        emptyBar.addSubview(micButton)

        NSLayoutConstraint.activate([
            langPill.leadingAnchor.constraint(equalTo: emptyBar.leadingAnchor, constant: 12),
            langPill.centerYAnchor.constraint(equalTo: emptyBar.centerYAnchor),
            langPill.heightAnchor.constraint(equalToConstant: 28),

            emptyLabel.centerXAnchor.constraint(equalTo: emptyBar.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: emptyBar.centerYAnchor),

            micButton.trailingAnchor.constraint(equalTo: emptyBar.trailingAnchor, constant: -12),
            micButton.centerYAnchor.constraint(equalTo: emptyBar.centerYAnchor),
            micButton.widthAnchor.constraint(equalToConstant: 44),
            micButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    // MARK: - Globe (Next Keyboard) Button
    
    private func setupGlobeButton() {
        // Required by iOS for custom keyboards — lets users switch back to other keyboards
        globeButton.translatesAutoresizingMaskIntoConstraints = false
        globeButton.setTitle("🌐", for: .normal)
        globeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        globeButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        view.addSubview(globeButton)
        
        NSLayoutConstraint.activate([
            globeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            globeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -2),
            globeButton.widthAnchor.constraint(equalToConstant: 40),
            globeButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    @objc private func langPillTapped() {
        selectedLanguage = (selectedLanguage == "pt") ? "en" : "pt"
        UserDefaults.standard.set(selectedLanguage, forKey: "talkswitch_lang")
        updateLangPill()
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        NSLog("TSKBD_LANG: \(selectedLanguage)")
    }

    private func updateLangPill() {
        if selectedLanguage == "pt" {
            langPill.setTitle("🎯 Coach: 🇧🇷 PT", for: .normal)
            langPill.backgroundColor = UIColor.systemBlue
            langPill.setTitleColor(.white, for: .normal)
        } else {
            langPill.setTitle("🎯 Coach: 🇺🇸 EN", for: .normal)
            langPill.backgroundColor = UIColor.systemGreen
            langPill.setTitleColor(.white, for: .normal)
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

        let closeBtn = UIButton(type: .system)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.setTitle("✕", for: .normal)
        closeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        closeBtn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        topBar.addSubview(closeBtn)

        NSLayoutConstraint.activate([
            directionLabel.leadingAnchor.constraint(equalTo: topBar.leadingAnchor),
            directionLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            closeBtn.trailingAnchor.constraint(equalTo: topBar.trailingAnchor),
            closeBtn.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
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

        // === Bottom row: globe + re-detect ===
        let bottomRow = UIView()
        bottomRow.translatesAutoresizingMaskIntoConstraints = false
        bottomRow.heightAnchor.constraint(equalToConstant: 30).isActive = true

        // Mic button
        let panelMicBtn = UIButton(type: .system)
        panelMicBtn.translatesAutoresizingMaskIntoConstraints = false
        panelMicBtn.setTitle("🎤", for: .normal)
        panelMicBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        panelMicBtn.addTarget(self, action: #selector(micTapped), for: .touchUpInside)
        bottomRow.addSubview(panelMicBtn)
        
        // Re-detect button
        let redetect = UIButton(type: .system)
        redetect.translatesAutoresizingMaskIntoConstraints = false
        redetect.setTitle("🔄 Re-detect", for: .normal)
        redetect.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        redetect.addTarget(self, action: #selector(redetectTapped), for: .touchUpInside)
        bottomRow.addSubview(redetect)

        NSLayoutConstraint.activate([
            panelMicBtn.leadingAnchor.constraint(equalTo: bottomRow.leadingAnchor),
            panelMicBtn.centerYAnchor.constraint(equalTo: bottomRow.centerYAnchor),
            redetect.trailingAnchor.constraint(equalTo: bottomRow.trailingAnchor),
            redetect.centerYAnchor.constraint(equalTo: bottomRow.centerYAnchor),
        ])
        contentStack.addArrangedSubview(bottomRow)
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

        // Speaker button inside the output card — right-aligned
        let speakerBtn = UIButton(type: .system)
        speakerBtn.translatesAutoresizingMaskIntoConstraints = false
        let speakerConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        speakerBtn.setImage(UIImage(systemName: "speaker.wave.2.fill", withConfiguration: speakerConfig), for: .normal)
        speakerBtn.tintColor = UIColor.systemBlue
        speakerBtn.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        outputCard.addSubview(speakerBtn)

        // Tap to expand/collapse
        let expandTap = UITapGestureRecognizer(target: self, action: #selector(outputCardTapped))
        outputCard.addGestureRecognizer(expandTap)
        outputCard.isUserInteractionEnabled = true

        NSLayoutConstraint.activate([
            outputCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            outputLangLabel.topAnchor.constraint(equalTo: outputCard.topAnchor, constant: 8),
            outputLangLabel.leadingAnchor.constraint(equalTo: outputCard.leadingAnchor, constant: 12),
            speakerBtn.trailingAnchor.constraint(equalTo: outputCard.trailingAnchor, constant: -10),
            speakerBtn.centerYAnchor.constraint(equalTo: outputCard.centerYAnchor),
            speakerBtn.widthAnchor.constraint(equalToConstant: 36),
            speakerBtn.heightAnchor.constraint(equalToConstant: 36),
            outputTextLabel.topAnchor.constraint(equalTo: outputLangLabel.bottomAnchor, constant: 2),
            outputTextLabel.leadingAnchor.constraint(equalTo: outputCard.leadingAnchor, constant: 12),
            outputTextLabel.trailingAnchor.constraint(equalTo: speakerBtn.leadingAnchor, constant: -8),
            outputTextLabel.bottomAnchor.constraint(equalTo: outputCard.bottomAnchor, constant: -8),
        ])
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
        let lower = text.lowercased()
        let ptWords = ["não","sim","você","obrigado","obrigada","como","está","bem",
                        "bom","dia","boa","noite","tarde","por","favor","muito",
                        "aqui","isso","esse","esta","para","uma","com","que",
                        "fazer","quando","onde","quem","porque","também","mais",
                        "agora","ainda","depois","antes","nosso","nossa","seu","sua",
                        "irá","entrar","contato","equipe","corretor","parte","faz",
                        "olá","tudo","conosco","agrademos"]
        let ptChars = ["ã","õ","ç","á","é","í","ó","ú","â","ê","ô"]

        var ptScore = 0
        for word in ptWords where lower.contains(word) { ptScore += 2 }
        for ch in ptChars where lower.contains(ch) { ptScore += 3 }

        return ptScore >= 3 ? ("pt", "Portuguese") : ("en", "English")
    }

    // MARK: - Actions

    // MARK: - Mic (Speech-to-Text)
    
    @objc private func micTapped() {
        if isRecording {
            SpeechService.shared.stopListening()
            isRecording = false
            return
        }
        
        SpeechService.shared.delegate = self
        SpeechService.shared.requestPermissions { [weak self] granted in
            guard let self = self else { return }
            if granted {
                self.isRecording = true
                self.lastSourceWasSpeech = true
                self.showPanel()
                
                let langLabel = self.selectedLanguage == "pt" ? "🇧🇷 PORTUGUESE" : "🇺🇸 ENGLISH"
                self.directionLabel.text = "🎤 Listening..."
                self.inputLangLabel.text = "🎤 \(langLabel)"
                self.inputTextLabel.text = "Speak now..."
                self.inputTextLabel.textColor = self.textPrimary
                self.outputCard.isHidden = true
                self.notesCard.isHidden = true
                
                // Use the user's selected language — no auto-detect, no keyboard switching
                let locale = self.selectedLanguage == "pt" ? "pt-BR" : "en-US"
                SpeechService.shared.startListeningIn(language: locale)
            }
        }
    }
    
    // MARK: - Speech Coaching
    
    private func performSpeechCoaching(text: String, language: String) {
        let flag = language == "pt" ? "🇧🇷" : "🇺🇸"
        let langName = language == "pt" ? "PORTUGUESE" : "ENGLISH"
        
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
        if outputLangLabel.text?.contains("🇧🇷") == true {
            lang = "pt-BR"
        } else {
            lang = "en-US"
        }
        
        SpeechService.shared.speak(text, language: lang)
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
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

    @objc private func closeTapped() { showEmpty() }

    @objc private func redetectTapped() { autoDetect() }

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
        flashActionButton(index: 2, tempTitle: "Saved! ✅", originalTitle: "Save 💾")
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
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
        inputTextLabel.text = text + (isFinal ? "" : " ...")
        inputTextLabel.textColor = textPrimary
        
        if isFinal {
            directionLabel.text = "🎤 Processing..."
        }
    }
    
    func speechService(_ service: SpeechService, didFinishWith text: String, language: String, lowConfidenceWords: [String]) {
        isRecording = false
        inputText = text
        detectedLanguage = language
        self.lowConfidenceWords = lowConfidenceWords
        
        // Speech → coaching mode (not translation)
        performSpeechCoaching(text: text, language: language)
    }
    
    func speechService(_ service: SpeechService, didFailWith error: Error) {
        isRecording = false
        directionLabel.text = "⚠️ Mic error"
        inputTextLabel.text = error.localizedDescription
        NSLog("TSKBD_SPEECH_ERROR: \(error.localizedDescription)")
    }
}
