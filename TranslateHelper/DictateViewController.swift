//
//  DictateViewController.swift
//  TranslateHelper
//
//  Records audio via AVAudioEngine. User selects speaking language via toggle:
//  - English → WhisperKit tiny (on-device, instant)
//  - Target language → Whisper API (cloud, accurate for all languages)
//
//  IMPORTANT: This file is the ONLY place transcription lives.
//  KeyboardViewController.swift is NOT touched — it reads the same
//  App Group keys as before (dictate_result, dictate_result_language, etc.).

import UIKit
import SwiftUI
import AVFoundation
import WhisperKit

class DictateViewController: UIViewController {

    // MARK: - State
    private var audioEngine   = AVAudioEngine()
    private var audioFile:      AVAudioFile?
    private var committed     = false
    private var isRecording   = false
    private var elapsedSeconds = 0
    private var elapsedTimer:  Timer?
    private var bubbleLayers:   [CAShapeLayer] = []
    private var burstTimer:     Timer?
    private var sendBorderGradient: CAGradientLayer?
    private var hasSeenOnboarding = false

    /// WhisperKit pipeline — loaded once at app level, shared across all recordings.
    private static var sharedWhisperPipe: WhisperKit?
    private static var sharedWhisperReady = false
    private static var whisperLoadStarted = false

    /// Target language code set by SceneDelegate from the URL param (e.g. "es", "zh", "fr").
    var targetLanguage: String = "es"

    /// The language the user selected to speak in (persisted globally).
    private var speakingLanguage: String {
        get {
            let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
            return defaults?.string(forKey: "dictate_speaking_language") ?? targetLanguage
        }
        set {
            let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
            defaults?.set(newValue, forKey: "dictate_speaking_language")
            defaults?.synchronize()
        }
    }

    /// Path to the temporary WAV file.
    private var tempAudioURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("dictate_recording.wav")
    }

    // MARK: - Flag lookup
    private static let flags: [String: String] = [
        "en": "🇺🇸", "pt": "🇧🇷", "es": "🇪🇸", "fr": "🇫🇷",
        "de": "🇩🇪", "it": "🇮🇹", "ja": "🇯🇵", "ko": "🇰🇷",
        "ar": "🇦🇪", "zh": "🇨🇳", "ru": "🇷🇺", "nl": "🇳🇱",
    ]

    private func flag(for code: String) -> String {
        Self.flags[code] ?? "🌐"
    }

    // MARK: - UI elements
    private let iconCircle          = UIView()
    private let iconImageView       = UIImageView()
    private let timerLabel          = UILabel()
    private let sendButton          = UIButton(type: .custom)
    private let cancelButton        = UIButton(type: .system)


    // Toggle (SwiftUI hosted)
    private var toggleHost: UIHostingController<DictateLanguagePill>?
    private var isToggleOnTarget = true  // true = speaking target language, false = speaking English

    // Onboarding
    private let onboardingCard  = UIView()
    private let flagLabel       = UILabel()
    private let onboardingLabel = UILabel()
    private let startButton     = UIButton(type: .custom)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hasSeenOnboarding = UserDefaults.standard.bool(forKey: "dictate_onboarding_seen")
        // Default speaking language is always the target language (the one they're learning)
        if speakingLanguage == "en" && !hasSeenOnboarding {
            speakingLanguage = targetLanguage
        }
        isToggleOnTarget = (speakingLanguage != "en")
        setupUI()
        loadWhisperKit()

        // Listen for toggle changes to update the onboarding text in real time
        NotificationCenter.default.addObserver(self, selector: #selector(languageToggleChanged), name: .dictateLanguageToggled, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if hasSeenOnboarding {
            // Returning user — start recording immediately
            startSonarRings()
            timerLabel.alpha = 0
            beginRecording()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAll()
    }

    // MARK: - WhisperKit initialization (shared across all instances)

    static func preloadWhisperKit() {
        guard !whisperLoadStarted else { return }
        whisperLoadStarted = true
        NSLog("🎤 [Dictate] WhisperKit: starting model load...")
        Task {
            do {
                let startTime = CFAbsoluteTimeGetCurrent()
                let config = WhisperKitConfig(model: "openai_whisper-tiny")
                let pipe = try await WhisperKit(config)
                let loadTime = CFAbsoluteTimeGetCurrent() - startTime

                sharedWhisperPipe = pipe
                sharedWhisperReady = true
                NSLog("🎤 [Dictate] WhisperKit ready in %.1fs", loadTime)

                do {
                    let silentSamples = [Float](repeating: 0.0, count: 16000)
                    _ = try await pipe.transcribe(audioArray: silentSamples)
                    NSLog("🎤 [Dictate] WhisperKit warm-up complete")
                } catch {
                    NSLog("🎤 [Dictate] WhisperKit warm-up skipped (non-fatal): \(error.localizedDescription)")
                }
            } catch {
                NSLog("🎤 [Dictate] WhisperKit FAILED to load: \(error)")
                sharedWhisperReady = false
            }
        }
    }

    private func loadWhisperKit() {
        DictateViewController.preloadWhisperKit()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .clear

        // ── Back arrow (top-left) ──────────────────────────────────────
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        let chevronCfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        cancelButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: chevronCfg), for: .normal)
        cancelButton.tintColor = UIColor.white.withAlphaComponent(0.65)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancelButton)

        // ── Language toggle pill ──────────────────────────────────────
        setupToggle()

        // ── Speaker circle ────────────────────────────────────────────
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        iconCircle.layer.cornerRadius = 33.75
        view.addSubview(iconCircle)

        let iconCfg = UIImage.SymbolConfiguration(pointSize: 39, weight: .medium)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: "speaker.wave.2.fill", withConfiguration: iconCfg)
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconCircle.addSubview(iconImageView)

        // ── Elapsed timer ─────────────────────────────────────────────
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.text = "0:00"
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 36, weight: .thin)
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        view.addSubview(timerLabel)



        // ── Send to Keyboard button ───────────────────────────────────
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor.white.withAlphaComponent(0.18)
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "keyboard", withConfiguration:
            UIImage.SymbolConfiguration(pointSize: 18, weight: .medium))
        config.imagePadding = 10
        config.title = "Send to Keyboard"
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            return a
        }
        sendButton.configuration = config
        sendButton.layer.cornerRadius = 29  // half of 58pt height = pill shape
        sendButton.clipsToBounds = true
        sendButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        view.addSubview(sendButton)

        // ── Onboarding elements ───────────────────────────────────────
        setupOnboarding()

        // ── Layout ────────────────────────────────────────────────────
        NSLayoutConstraint.activate([
            cancelButton.centerYAnchor.constraint(equalTo: toggleHost!.view.centerYAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            toggleHost!.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toggleHost!.view.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.height * 0.09),

            iconCircle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconCircle.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            iconCircle.widthAnchor.constraint(equalToConstant: 67.5),
            iconCircle.heightAnchor.constraint(equalToConstant: 67.5),

            iconImageView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 36),
            iconImageView.heightAnchor.constraint(equalToConstant: 36),

            timerLabel.topAnchor.constraint(equalTo: iconCircle.bottomAnchor, constant: 28),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            sendButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sendButton.heightAnchor.constraint(equalToConstant: 58),


        ])

        // Show/hide based on onboarding state
        if !hasSeenOnboarding {
            timerLabel.isHidden = true
            sendButton.isHidden = true
            iconCircle.isHidden = true
        } else {
            onboardingCard.isHidden = true
        }
    }

    // MARK: - Language Toggle (exact same pill as study cards, hosted as SwiftUI)

    private func setupToggle() {
        let pill = DictateLanguagePill(
            sourceLang: targetLanguage,
            targetLang: "en"
        )
        let host = UIHostingController(rootView: pill)
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(host)
        view.addSubview(host.view)
        host.didMove(toParent: self)
        toggleHost = host
    }

    // MARK: - Onboarding (first-time only)

    private func setupOnboarding() {
        // ── Container card ────────────────────────────────────────────
        onboardingCard.translatesAutoresizingMaskIntoConstraints = false
        onboardingCard.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        onboardingCard.layer.cornerRadius = 28
        onboardingCard.layer.masksToBounds = true
        onboardingCard.layer.borderColor = UIColor.white.withAlphaComponent(0.10).cgColor
        onboardingCard.layer.borderWidth = 1
        view.addSubview(onboardingCard)

        // ── Flag haze glow (behind flag) ──────────────────────────────
        let flagHaze = UIView()
        flagHaze.translatesAutoresizingMaskIntoConstraints = false
        flagHaze.isUserInteractionEnabled = false
        let hazeGradient = CAGradientLayer()
        hazeGradient.type       = .radial
        hazeGradient.colors     = [
            UIColor.white.withAlphaComponent(0.28).cgColor,
            UIColor.white.withAlphaComponent(0.00).cgColor,
        ]
        hazeGradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        hazeGradient.endPoint   = CGPoint(x: 1.0, y: 1.0)
        hazeGradient.frame      = CGRect(x: 0, y: 0, width: 153, height: 153)
        flagHaze.layer.addSublayer(hazeGradient)
        onboardingCard.addSubview(flagHaze)  // ← before flagLabel so it renders behind

        // ── Flag emoji (inside card) ──────────────────────────────────
        flagLabel.translatesAutoresizingMaskIntoConstraints = false
        flagLabel.text = flag(for: targetLanguage)
        flagLabel.font = .systemFont(ofSize: 86)   // 20% bigger than 72
        flagLabel.textAlignment = .center
        onboardingCard.addSubview(flagLabel)

        // ── Description text (inside card) ────────────────────────────
        onboardingLabel.translatesAutoresizingMaskIntoConstraints = false
        onboardingLabel.numberOfLines = 0
        onboardingLabel.textAlignment = .center
        updateOnboardingText()
        onboardingCard.addSubview(onboardingLabel)

        // ── Start button (inside card) ────────────────────────────────
        startButton.translatesAutoresizingMaskIntoConstraints = false
        var btnConfig = UIButton.Configuration.filled()
        btnConfig.baseBackgroundColor = UIColor.white.withAlphaComponent(0.2)
        btnConfig.baseForegroundColor = .white
        btnConfig.cornerStyle = .large
        btnConfig.title = "Start Recording"
        btnConfig.image = UIImage(systemName: "mic.fill", withConfiguration:
            UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
        btnConfig.imagePadding = 8
        btnConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            return a
        }
        startButton.configuration = btnConfig
        startButton.layer.cornerRadius = 18
        startButton.clipsToBounds = true
        startButton.addTarget(self, action: #selector(startRecordingTapped), for: .touchUpInside)
        onboardingCard.addSubview(startButton)

        let pad: CGFloat = 28

        NSLayoutConstraint.activate([
            // Card sits 3 units below the toggle pill (1 unit = 32pt)
            onboardingCard.topAnchor.constraint(equalTo: toggleHost!.view.bottomAnchor, constant: 96),
            onboardingCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            onboardingCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Haze glow — 180×180, centered on the flag
            flagHaze.centerXAnchor.constraint(equalTo: onboardingCard.centerXAnchor),
            flagHaze.centerYAnchor.constraint(equalTo: flagLabel.centerYAnchor),
            flagHaze.widthAnchor.constraint(equalToConstant: 153),
            flagHaze.heightAnchor.constraint(equalToConstant: 153),

            // Flag at top of card
            flagLabel.centerXAnchor.constraint(equalTo: onboardingCard.centerXAnchor),
            flagLabel.topAnchor.constraint(equalTo: onboardingCard.topAnchor, constant: pad),

            // Label below flag
            onboardingLabel.centerXAnchor.constraint(equalTo: onboardingCard.centerXAnchor),
            onboardingLabel.topAnchor.constraint(equalTo: flagLabel.bottomAnchor, constant: 16),
            onboardingLabel.leadingAnchor.constraint(equalTo: onboardingCard.leadingAnchor, constant: pad),
            onboardingLabel.trailingAnchor.constraint(equalTo: onboardingCard.trailingAnchor, constant: -pad),

            // Button below label — pins the card's bottom height
            startButton.topAnchor.constraint(equalTo: onboardingLabel.bottomAnchor, constant: 24),
            startButton.centerXAnchor.constraint(equalTo: onboardingCard.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 220),
            startButton.heightAnchor.constraint(equalToConstant: 52),
            startButton.bottomAnchor.constraint(equalTo: onboardingCard.bottomAnchor, constant: -pad),
        ])
    }

    @objc private func languageToggleChanged() {
        // Re-read the speaking language from App Group and update the banner + flag
        isToggleOnTarget = (speakingLanguage != "en")
        updateOnboardingText()

        // Update the big flag emoji to match the selected language
        let langCode = isToggleOnTarget ? targetLanguage : "en"
        UIView.transition(with: flagLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.flagLabel.text = self.flag(for: langCode)
        }
    }

    private func updateOnboardingText() {
        let langCode = isToggleOnTarget ? targetLanguage : "en"
        let langName = languageDisplayName(for: langCode)
        let flag = languageFlag(for: langCode)

        // First line: bold + larger, with flag
        let firstLine = "\(flag) Your voice is set to \(langName)."
        let firstAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor: UIColor.white,
        ]

        // Rest: regular + slightly dimmed
        let rest = "\n\nSpeak naturally — we'll transcribe\nand translate for you.\n\nTo switch languages, tap the toggle above."
        let restAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
            .foregroundColor: UIColor.white,
        ]

        let attributed = NSMutableAttributedString(string: firstLine, attributes: firstAttrs)
        attributed.append(NSAttributedString(string: rest, attributes: restAttrs))
        onboardingLabel.attributedText = attributed
    }

    @objc private func startRecordingTapped() {
        hasSeenOnboarding = true
        UserDefaults.standard.set(true, forKey: "dictate_onboarding_seen")

        // Reveal circle, fade card out as one unit
        iconCircle.isHidden = false
        iconCircle.alpha = 0

        UIView.animate(withDuration: 0.35) {
            self.onboardingCard.alpha = 0
            self.iconCircle.alpha = 1
        } completion: { _ in
            self.onboardingCard.isHidden = true
            self.timerLabel.isHidden = false
            self.sendButton.isHidden = false
            self.timerLabel.alpha = 0
            self.startSonarRings()
            self.beginRecording()
        }
    }

    private func languageDisplayName(for code: String) -> String {
        let map: [String: String] = [
            "en": "English", "pt": "Portuguese", "es": "Spanish", "fr": "French",
            "de": "German", "it": "Italian", "ja": "Japanese", "ko": "Korean",
            "ar": "Arabic", "zh": "Chinese", "ru": "Russian", "nl": "Dutch",
        ]
        return map[code] ?? code.uppercased()
    }

    private func languageFlag(for code: String) -> String {
        let map: [String: String] = [
            "en": "🇺🇸", "pt": "🇧🇷", "es": "🇪🇸", "fr": "🇫🇷",
            "de": "🇩🇪", "it": "🇮🇹", "ja": "🇯🇵", "ko": "🇰🇷",
            "ar": "🇦🇪", "zh": "🇨🇳", "ru": "🇷🇺", "nl": "🇳🇱",
        ]
        return map[code] ?? "🌐"
    }

    // MARK: - Gradient border for send button
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradientBorder()
    }

    private func applyGradientBorder() {
        sendBorderGradient?.removeFromSuperlayer()

        let btn      = sendButton
        let radius   = btn.layer.cornerRadius
        let bounds   = btn.bounds

        let gradient          = CAGradientLayer()
        gradient.frame        = bounds
        gradient.colors       = [
            UIColor.white.withAlphaComponent(0.55).cgColor,
            UIColor.white.withAlphaComponent(0.12).cgColor,
            UIColor.white.withAlphaComponent(0.04).cgColor,
            UIColor.white.withAlphaComponent(0.18).cgColor,
        ]
        gradient.locations    = [0.0, 0.45, 0.78, 1.0]
        gradient.startPoint   = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint     = CGPoint(x: 0.5, y: 1.0)

        let borderWidth: CGFloat = 1.0
        let maskPath = UIBezierPath(roundedRect: bounds.insetBy(dx: borderWidth / 2,
                                                                 dy: borderWidth / 2),
                                    cornerRadius: radius)
        let mask          = CAShapeLayer()
        mask.path         = maskPath.cgPath
        mask.lineWidth    = borderWidth
        mask.strokeColor  = UIColor.black.cgColor
        mask.fillColor    = UIColor.clear.cgColor
        gradient.mask     = mask

        btn.layer.addSublayer(gradient)
        sendBorderGradient = gradient
    }

    // MARK: - Pulse ring animation

    /// Launches two staggered filled-circle pulses that expand from the icon and fade out.
    private func startSonarRings() {
        addPulse(delay: 0.0, tag: 1)
        addPulse(delay: 0.9, tag: 2)
    }

    private func addPulse(delay: Double, tag: Int) {
        let radius: CGFloat = 33.75
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY - 40)
        let diameter = radius * 2

        // Stroke-only ring — no fill so it doesn't blanch the gradient behind it
        let pulse = CAShapeLayer()
        pulse.path        = UIBezierPath(ovalIn: CGRect(x: -radius, y: -radius,
                                                        width: diameter, height: diameter)).cgPath
        pulse.fillColor   = UIColor.clear.cgColor
        pulse.strokeColor = UIColor.white.withAlphaComponent(0.55).cgColor
        pulse.lineWidth   = 1.5
        pulse.opacity     = 0
        pulse.position    = center
        view.layer.insertSublayer(pulse, below: iconCircle.layer)

        if tag == 1 { bubbleLayers.append(pulse) } else { bubbleLayers.append(pulse) }

        // Scale: grow from 1× to 2.5× the circle's size
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue  = 1.0
        scaleAnim.toValue    = 2.5
        scaleAnim.duration   = 1.8
        scaleAnim.beginTime  = CACurrentMediaTime() + delay
        scaleAnim.repeatCount = .greatestFiniteMagnitude
        scaleAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)

        // Opacity: flash in fast, then slowly dissolve
        let fadeAnim = CAKeyframeAnimation(keyPath: "opacity")
        fadeAnim.values    = [0.0, 0.55, 0.0]
        fadeAnim.keyTimes  = [0.0, 0.15, 1.0]
        fadeAnim.duration  = 1.8
        fadeAnim.beginTime = scaleAnim.beginTime
        fadeAnim.repeatCount = .greatestFiniteMagnitude
        fadeAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)

        pulse.add(scaleAnim, forKey: "scale_\(tag)")
        pulse.add(fadeAnim,  forKey: "fade_\(tag)")
    }

    private func stopSonarRings() {
        burstTimer?.invalidate()
        burstTimer = nil
        bubbleLayers.forEach { $0.removeAllAnimations(); $0.removeFromSuperlayer() }
        bubbleLayers.removeAll()
    }

    // MARK: - Processing state
    private func showProcessingState() {
        stopSonarRings()
        stopElapsedTimer()

        let goldYellow = UIColor(red: 1.0, green: 0.843, blue: 0.0, alpha: 1.0) // #FFD700
        let sparkCfg = UIImage.SymbolConfiguration(pointSize: 44, weight: .medium)
            .applying(UIImage.SymbolConfiguration(hierarchicalColor: goldYellow))
        iconImageView.image = UIImage(systemName: "sparkles", withConfiguration: sparkCfg)
        iconImageView.tintColor = goldYellow

        // Hide the timer label — just the stars are enough
        sendButton.isEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.sendButton.alpha = 0
            self.timerLabel.alpha = 0
            self.iconCircle.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        }

        // ── Stars bounce animation ─────────────────────────────────────
        // Phase 1: snap down (like a button press)
        iconImageView.transform = CGAffineTransform(scaleX: 0.82, y: 0.82)
        UIView.animate(
            withDuration: 0.55,
            delay: 0.05,
            usingSpringWithDamping: 0.38,
            initialSpringVelocity: 6.0,
            options: [.allowUserInteraction]
        ) {
            self.iconImageView.transform = .identity
        } completion: { _ in
            // Phase 2: gentle repeating pulse while processing
            UIView.animate(
                withDuration: 0.9,
                delay: 0.1,
                options: [.repeat, .autoreverse, .allowUserInteraction, .curveEaseInOut]
            ) {
                self.iconImageView.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
            }
        }
    }

    // MARK: - Elapsed timer
    private var timerStartDate: Date?

    private func startElapsedTimer() {
        timerStartDate = Date()
        timerLabel.text = "0:00"
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.timerStartDate else { return }
            let elapsed = Int(Date().timeIntervalSince(start))
            if elapsed != self.elapsedSeconds {
                self.elapsedSeconds = elapsed
                let m = elapsed / 60
                let s = elapsed % 60
                self.timerLabel.text = String(format: "%d:%02d", m, s)
            }
        }
    }
    private func stopElapsedTimer() {
        elapsedTimer?.invalidate(); elapsedTimer = nil
        timerStartDate = nil
    }

    // MARK: - Recording (AVAudioEngine → WAV file)

    private func beginRecording() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard let self = self, granted else { return }
                self.startAudioCapture()
            }
        }
    }

    private func startAudioCapture() {
        guard !committed else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default,
                                                            options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            NSLog("🎤 [Dictate] audio session error: \(error)")
            return
        }

        let engine = AVAudioEngine()
        let node   = engine.inputNode
        let hwFmt  = node.outputFormat(forBus: 0)

        guard hwFmt.sampleRate > 0, hwFmt.channelCount > 0 else { return }

        try? FileManager.default.removeItem(at: tempAudioURL)

        do {
            audioFile = try AVAudioFile(forWriting: tempAudioURL, settings: hwFmt.settings)
        } catch {
            NSLog("🎤 [Dictate] could not create audio file: \(error)")
            return
        }

        node.installTap(onBus: 0, bufferSize: 4096, format: nil) { [weak self] buffer, _ in
            guard let self = self, let file = self.audioFile else { return }
            do { try file.write(from: buffer) } catch {}
        }

        engine.prepare()
        do { try engine.start() } catch { return }

        audioEngine = engine
        isRecording = true

        startElapsedTimer()
        UIView.animate(withDuration: 0.5) {
            self.timerLabel.alpha = 1
        }

        NSLog("🎤 [Dictate] recording started — speaking=\(speakingLanguage)")
    }

    // MARK: - Audio teardown

    private func stopRecordingEngine() {
        if audioEngine.isRunning {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
        }
        audioFile = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func stopAll() {
        stopRecordingEngine()
        isRecording = false
        stopElapsedTimer()
        stopSonarRings()
        iconImageView.layer.removeAllAnimations()
        iconImageView.transform = .identity
    }

    // MARK: - Process recording (routes based on toggle)

    private func processRecording() {
        guard !committed else { return }
        committed = true
        stopRecordingEngine()
        isRecording = false
        showProcessingState()

        guard FileManager.default.fileExists(atPath: tempAudioURL.path) else {
            NSLog("🎤 [Dictate] no audio file to process")
            dismiss(animated: true)
            return
        }

        NSLog("🎤 [Dictate] processing — speakingLanguage=\(speakingLanguage)")

        if speakingLanguage == "en" {
            // English → WhisperKit tiny (on-device, fast)
            if Self.sharedWhisperReady, let pipe = Self.sharedWhisperPipe {
                NSLog("🎤 [Dictate] → English path (WhisperKit on-device)")
                transcribeEnglishOnDevice(pipe: pipe)
            } else {
                NSLog("🎤 [Dictate] → English path (API fallback — WhisperKit not ready)")
                transcribeViaAPI()
            }
        } else {
            // Target language → Whisper API (accurate for all languages)
            NSLog("🎤 [Dictate] → \(speakingLanguage) path (Whisper API)")
            transcribeViaAPI()
        }
    }

    // MARK: - English transcription (WhisperKit on-device)

    private func transcribeEnglishOnDevice(pipe: WhisperKit) {
        let audioPath = tempAudioURL.path
        let startTime = CFAbsoluteTimeGetCurrent()

        Task {
            do {
                let options = DecodingOptions(
                    language: "en",
                    temperature: 0.0,
                    usePrefillPrompt: false,
                    skipSpecialTokens: true,
                    clipTimestamps: []
                )

                let results = try await pipe.transcribe(
                    audioPath: audioPath,
                    decodeOptions: options
                )

                let elapsed = CFAbsoluteTimeGetCurrent() - startTime
                NSLog("🎤 [Dictate] WhisperKit English in %.2fs", elapsed)

                try? FileManager.default.removeItem(at: tempAudioURL)

                let fullText = results.map { $0.text }.joined(separator: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                NSLog("🎤 [Dictate] result: lang=en text='\(fullText.prefix(80))'")

                await MainActor.run {
                    guard !fullText.isEmpty else {
                        self.dismiss(animated: true)
                        return
                    }
                    self.commitToKeyboard(text: fullText, lang: "en")
                }
            } catch {
                NSLog("🎤 [Dictate] WhisperKit error: \(error) — falling back to API")
                await MainActor.run {
                    self.committed = false
                    self.transcribeViaAPI()
                }
            }
        }
    }

    // MARK: - Compress WAV → M4A for faster upload

    private var compressedURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("dictate_compressed.m4a")
    }

    private func compressAndUpload() {
        let srcURL = tempAudioURL
        let dstURL = compressedURL
        try? FileManager.default.removeItem(at: dstURL)

        let asset = AVURLAsset(url: srcURL)
        guard let exporter = AVAssetExportSession(asset: asset,
                                                   presetName: AVAssetExportPresetAppleM4A) else {
            NSLog("🎤 [Dictate] compress: export session unavailable — uploading WAV")
            uploadToWhisperAPI(fileURL: srcURL, filename: "recording.wav", mimeType: "audio/wav")
            return
        }

        exporter.outputURL = dstURL
        exporter.outputFileType = .m4a

        exporter.exportAsynchronously { [weak self] in
            guard let self = self else { return }
            switch exporter.status {
            case .completed:
                let srcSize = (try? FileManager.default.attributesOfItem(atPath: srcURL.path)[.size] as? Int) ?? 0
                let dstSize = (try? FileManager.default.attributesOfItem(atPath: dstURL.path)[.size] as? Int) ?? 0
                NSLog("🎤 [Dictate] compressed: \(srcSize) → \(dstSize) bytes")
                try? FileManager.default.removeItem(at: srcURL)
                self.uploadToWhisperAPI(fileURL: dstURL, filename: "recording.m4a", mimeType: "audio/m4a")
            default:
                NSLog("🎤 [Dictate] compress failed: \(exporter.error?.localizedDescription ?? "unknown") — uploading WAV")
                self.uploadToWhisperAPI(fileURL: srcURL, filename: "recording.wav", mimeType: "audio/wav")
            }
        }
    }

    // MARK: - Whisper API (target language + fallback)

    private func transcribeViaAPI() {
        committed = true

        guard FileManager.default.fileExists(atPath: tempAudioURL.path) else {
            dismiss(animated: true)
            return
        }

        // Try to compress first for faster upload; falls back to WAV if compression fails
        compressAndUpload()
    }

    private func uploadToWhisperAPI(fileURL: URL, filename: String, mimeType: String) {
        let apiKey = APIConfig.openAIAPIKey
        guard let url = URL(string: "\(APIConfig.openAIBaseURL)/audio/transcriptions") else { return }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        if let audioData = try? Data(contentsOf: fileURL) {
            body.append(audioData)
            NSLog("🎤 [Dictate] API: uploading \(audioData.count) bytes (\(filename))")
        }
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"response_format\"\r\n\r\n".data(using: .utf8)!)
        body.append("verbose_json\r\n".data(using: .utf8)!)

        // Force language so Whisper doesn't auto-detect per chunk (causes mixed output)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"language\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(self.speakingLanguage)\r\n".data(using: .utf8)!)
        NSLog("🎤 [Dictate] API: forcing language=\(self.speakingLanguage)")

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            try? FileManager.default.removeItem(at: fileURL)

            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    NSLog("🎤 [Dictate] API error: \(error.localizedDescription)")
                    self.dismiss(animated: true)
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.dismiss(animated: true)
                    return
                }

                let transcription = (json["text"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let whisperLang   = json["language"] as? String ?? ""

                NSLog("🎤 [Dictate] API result: lang=\(whisperLang) text='\(transcription.prefix(80))'")

                guard !transcription.isEmpty else {
                    self.dismiss(animated: true)
                    return
                }

                let detectedCode = self.whisperLangToCode(whisperLang)
                let langForKeyboard = detectedCode.isEmpty ? self.speakingLanguage : detectedCode

                self.commitToKeyboard(text: transcription, lang: langForKeyboard)
            }
        }.resume()
    }

    private func whisperLangToCode(_ whisperLang: String) -> String {
        let map: [String: String] = [
            "english": "en", "spanish": "es", "french": "fr",
            "german": "de", "italian": "it", "portuguese": "pt",
            "japanese": "ja", "chinese": "zh", "korean": "ko",
            "arabic": "ar", "russian": "ru", "dutch": "nl",
            "polish": "pl", "turkish": "tr", "swedish": "sv",
            "danish": "da", "norwegian": "no", "finnish": "fi",
            "greek": "el", "czech": "cs", "romanian": "ro",
            "hungarian": "hu", "thai": "th", "hindi": "hi",
            "vietnamese": "vi", "indonesian": "id", "malay": "ms",
            "ukrainian": "uk", "catalan": "ca", "hebrew": "he",
            "croatian": "hr", "slovak": "sk", "bulgarian": "bg",
            "filipino": "fil", "persian": "fa", "afrikaans": "af",
            "bengali": "bn", "urdu": "ur", "swahili": "sw",
            "tamil": "ta",
        ]
        return map[whisperLang.lowercased()] ?? ""
    }

    // MARK: - Commit result to keyboard via App Group

    private func commitToKeyboard(text: String, lang: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        NSLog("🎤 [Dictate] COMMIT lang=\(lang) text='\(trimmed.prefix(80))'")
        guard !trimmed.isEmpty else { dismiss(animated: true); return }

        committed = true
        let mode = (lang == targetLanguage) ? "accent_coach" : "speech"

        // Write result to App Group IMMEDIATELY — keyboard polling picks it up
        // while the star animation plays, so translation is ready before we return.
        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        defaults?.set(trimmed,                     forKey: "dictate_result")
        defaults?.set(lang,                        forKey: "dictate_result_language")
        defaults?.set(mode,                        forKey: "dictate_mode")
        defaults?.set(Date().timeIntervalSince1970, forKey: "dictate_result_timestamp")
        defaults?.synchronize()

        // Play star bounce animation — buys 1 second for keyboard to process
        playStarBounce {
            // After animation → dismiss → return to app
            self.dismiss(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.returnToPreviousApp()
            }
        }
    }

    /// Bounces the center speaker icon as a sparkle, then calls completion.
    private func playStarBounce(completion: @escaping () -> Void) {
        // Fade out everything except the center icon
        UIView.animate(withDuration: 0.2) {
            self.sendButton.alpha = 0
            self.timerLabel.alpha = 0
        }

        // Swap the speaker icon to sparkles
        let starConfig = UIImage.SymbolConfiguration(pointSize: 39, weight: .medium)
        self.iconImageView.image = UIImage(systemName: "sparkles", withConfiguration: starConfig)

        // Bounce the center circle
        UIView.animate(
            withDuration: 0.4,
            delay: 0.1,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.8
        ) {
            self.iconCircle.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        } completion: { _ in
            // Settle back
            UIView.animate(
                withDuration: 0.3,
                delay: 0.05,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0.5
            ) {
                self.iconCircle.transform = .identity
            } completion: { _ in
                // Hold for a beat, then dismiss
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    completion()
                }
            }
        }
    }

    /// Returns the user to the messaging app they came from.
    /// Tries known app URL schemes in priority order — the first installed one opens.
    /// WhatsApp is first since it's the most common use case.
    private func returnToPreviousApp() {
        let schemes = [
            "whatsapp://",
            "instagram://",
            "fb-messenger://",
            "tinder://",
            "bumble://",
            "tg://",
            "signal://",
            "viber://",
        ]

        for scheme in schemes {
            if let url = URL(string: scheme),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                NSLog("🎤 [Dictate] returning via \(scheme)")
                return
            }
        }
        NSLog("🎤 [Dictate] no known messaging app found — user must switch manually")
    }

    // MARK: - Actions
    @objc private func doneTapped() {
        guard !committed else { return }
        if !isRecording {
            stopAll(); dismiss(animated: true)
        } else {
            processRecording()
        }
    }

    @objc private func cancelTapped() {
        stopAll()
        dismiss(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.returnToPreviousApp()
        }
    }
}

// MARK: - Language toggle pill (same layout as LanguageSwitchPill from study cards)

extension Notification.Name {
    static let dictateLanguageToggled = Notification.Name("dictateLanguageToggled")
}

struct DictateLanguagePill: View {
    let sourceLang: String  // target language (e.g. "pt")
    let targetLang: String  // "en"

    @State private var swapped: Bool = {
        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        let saved = defaults?.string(forKey: "dictate_speaking_language") ?? ""
        return saved == "en"  // swapped = true means English is on the left (speaking English)
    }()

    private var leftCode: String { swapped ? targetLang : sourceLang }
    private var rightCode: String { swapped ? sourceLang : targetLang }

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                let leftLang = allLanguages.first(where: { $0.code == leftCode })
                Text(leftLang?.flag ?? "🏴").font(.custom("HelveticaNeue", size: 16))
                Text(leftLang?.name ?? leftCode)
                    .font(.custom("HelveticaNeue-Medium", size: 12)).foregroundColor(.white)
            }

            Image(systemName: "arrow.right")
                .font(.custom("HelveticaNeue-Bold", size: 12))
                .foregroundColor(.white.opacity(0.6))

            HStack(spacing: 4) {
                let rightLang = allLanguages.first(where: { $0.code == rightCode })
                Text(rightLang?.flag ?? "🏴").font(.custom("HelveticaNeue", size: 16))
                Text(rightLang?.name ?? rightCode)
                    .font(.custom("HelveticaNeue-Medium", size: 12)).foregroundColor(.white)
            }

            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                withAnimation(.easeInOut(duration: 0.2)) {
                    swapped.toggle()
                }
                // Persist to App Group so DictateViewController reads the right language
                let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
                let speakingLang = swapped ? targetLang : sourceLang
                defaults?.set(speakingLang, forKey: "dictate_speaking_language")
                defaults?.synchronize()
                // Notify DictateViewController to update the onboarding text
                NotificationCenter.default.post(name: .dictateLanguageToggled, object: nil)
            }) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.custom("HelveticaNeue-Bold", size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.leading, 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.15))
        .clipShape(Capsule())
    }
}
