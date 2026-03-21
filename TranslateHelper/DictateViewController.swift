//
//  DictateViewController.swift
//  TranslateHelper
//
//  Records audio via AVAudioEngine, transcribes using WhisperKit (on-device)
//  for iPhone 13+ or falls back to Whisper API for older devices.
//  Hands the result back to the keyboard extension via App Group UserDefaults.
//
//  IMPORTANT: This file is the ONLY place Whisper integration lives.
//  KeyboardViewController.swift is NOT touched — it reads the same
//  App Group keys as before (dictate_result, dictate_result_language, etc.).

import UIKit
import AVFoundation
import NaturalLanguage
import WhisperKit

class DictateViewController: UIViewController {

    // MARK: - State
    private var audioEngine   = AVAudioEngine()
    private var audioFile:      AVAudioFile?
    private var committed     = false
    private var isRecording   = false
    private var elapsedSeconds = 0
    private var elapsedTimer:  Timer?
    private var ringLayer1:    CAShapeLayer?
    private var ringLayer2:    CAShapeLayer?
    private var sendBorderGradient: CAGradientLayer?

    /// WhisperKit pipeline — loaded once at app level, shared across all recordings.
    private static var sharedWhisperPipe: WhisperKit?
    private static var sharedWhisperReady = false
    private static var whisperLoadStarted = false

    /// Target language code set by SceneDelegate from the URL param (e.g. "es", "zh", "fr").
    var targetLanguage: String = "es"

    /// Path to the temporary WAV file.
    private var tempAudioURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("dictate_recording.wav")
    }

    // MARK: - UI elements
    private let iconCircle      = UIView()
    private let iconImageView   = UIImageView()
    private let timerLabel      = UILabel()
    private let sendButton      = UIButton(type: .custom)
    private let cancelButton    = UIButton(type: .system)
    private let titleLabel      = UILabel()
    private let titleIcon       = UIImageView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadWhisperKit()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSonarRings()
        // Timer stays hidden until audio engine is actually running
        timerLabel.alpha = 0
        beginRecording()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAll()
    }

    // MARK: - WhisperKit initialization (shared across all instances)

    /// Call this early (e.g. from AppDelegate/SceneDelegate) to pre-warm the model.
    /// Safe to call multiple times — only loads once.
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

                // Mark as ready IMMEDIATELY after init — don't wait for warm-up
                sharedWhisperPipe = pipe
                sharedWhisperReady = true
                NSLog("🎤 [Dictate] WhisperKit ready in %.1fs", loadTime)

                // Optional warm-up: run a tiny transcription to pre-load encoder/decoder.
                // If this fails, the model is still usable — first real transcription will just be slightly slower.
                do {
                    let silentSamples = [Float](repeating: 0.0, count: 16000)
                    _ = try await pipe.transcribe(audioArray: silentSamples)
                    NSLog("🎤 [Dictate] WhisperKit warm-up complete")
                } catch {
                    NSLog("🎤 [Dictate] WhisperKit warm-up skipped (non-fatal): \(error.localizedDescription)")
                }
            } catch {
                NSLog("🎤 [Dictate] WhisperKit FAILED to load: \(error)")
                NSLog("🎤 [Dictate] Will use Whisper API fallback instead")
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

        // ── Cancel (top-left plain text) ───────────────────────────────────
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cancelButton.setTitleColor(UIColor.white.withAlphaComponent(0.65), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancelButton)

        // ── Title "🔊 Voice Translate" (top-centre) ────────────────────────
        let titleStack = UIStackView()
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.axis = .horizontal
        titleStack.spacing = 6
        titleStack.alignment = .center

        let iconCfgSmall = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        titleIcon.translatesAutoresizingMaskIntoConstraints = false
        titleIcon.image = UIImage(systemName: "speaker.wave.2.fill", withConfiguration: iconCfgSmall)
        titleIcon.tintColor = .white

        titleLabel.text = "Voice Translate"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .white

        titleStack.addArrangedSubview(titleIcon)
        titleStack.addArrangedSubview(titleLabel)
        view.addSubview(titleStack)

        // ── Speaker circle ─────────────────────────────────────────────────
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        iconCircle.layer.cornerRadius = 33.75   // diameter = 67.5
        view.addSubview(iconCircle)

        let iconCfg = UIImage.SymbolConfiguration(pointSize: 39, weight: .medium)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: "speaker.wave.2.fill", withConfiguration: iconCfg)
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconCircle.addSubview(iconImageView)

        // ── Elapsed timer ──────────────────────────────────────────────────
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.text = "0:00"
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 36, weight: .thin)
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        view.addSubview(timerLabel)

        // ── "Send to Keyboard" wide bottom pill ───────────────────────────
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor.white.withAlphaComponent(0.18)
        config.baseForegroundColor = .white
        config.cornerStyle = .large
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
        sendButton.layer.cornerRadius = 18
        sendButton.clipsToBounds = true
        sendButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        view.addSubview(sendButton)

        // ── Layout ─────────────────────────────────────────────────────────
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            titleStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleStack.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),

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

            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sendButton.heightAnchor.constraint(equalToConstant: 58),
        ])
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
            UIColor.white.withAlphaComponent(0.00).cgColor,
        ]
        gradient.locations    = [0.0, 0.45, 1.0]
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

    // MARK: - Sonar ring animation (two expanding rings)
    private func startSonarRings() {
        addRing(delay: 0.0, tag: 1)
        addRing(delay: 0.7, tag: 2)
    }

    private func addRing(delay: Double, tag: Int) {
        let radius: CGFloat = 33.75
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY - 40)
        let path = UIBezierPath(arcCenter: center, radius: radius,
                                startAngle: 0, endAngle: .pi * 2, clockwise: true)

        let ring = CAShapeLayer()
        ring.path = path.cgPath
        ring.fillColor = UIColor.clear.cgColor
        ring.strokeColor = UIColor.white.withAlphaComponent(0.5).cgColor
        ring.lineWidth = 2
        ring.opacity = 0
        view.layer.insertSublayer(ring, below: iconCircle.layer)

        if tag == 1 { ringLayer1 = ring } else { ringLayer2 = ring }

        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 1.0
        scaleAnim.toValue   = 2.2
        scaleAnim.duration  = 1.8
        scaleAnim.beginTime = CACurrentMediaTime() + delay
        scaleAnim.repeatCount = .greatestFiniteMagnitude
        scaleAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.fromValue = 0.5
        fadeAnim.toValue   = 0
        fadeAnim.duration  = 1.8
        fadeAnim.beginTime = scaleAnim.beginTime
        fadeAnim.repeatCount = .greatestFiniteMagnitude
        fadeAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)

        ring.add(scaleAnim, forKey: "scale_\(tag)")
        ring.add(fadeAnim, forKey: "fade_\(tag)")
    }

    private func stopSonarRings() {
        ringLayer1?.removeAllAnimations(); ringLayer1?.removeFromSuperlayer(); ringLayer1 = nil
        ringLayer2?.removeAllAnimations(); ringLayer2?.removeFromSuperlayer(); ringLayer2 = nil
    }

    // MARK: - Processing state (sparkles + "Processing" text)
    private func showProcessingState() {
        stopSonarRings()
        stopElapsedTimer()

        let sparkCfg = UIImage.SymbolConfiguration(pointSize: 44, weight: .medium)
            .applying(UIImage.SymbolConfiguration(paletteColors: [.systemYellow, .systemOrange]))
        iconImageView.image = UIImage(systemName: "sparkles", withConfiguration: sparkCfg)

        timerLabel.font = .systemFont(ofSize: 18, weight: .medium)
        timerLabel.text = "Processing"

        sendButton.isEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.sendButton.alpha = 0
            self.iconCircle.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        }
    }

    // MARK: - Elapsed timer
    private var timerStartDate: Date?

    private func startElapsedTimer() {
        timerStartDate = Date()
        timerLabel.text = "0:00"
        // Update every 0.25s for snappy display, but only change text on whole seconds
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

        guard hwFmt.sampleRate > 0, hwFmt.channelCount > 0 else {
            NSLog("🎤 [Dictate] invalid hardware format — sampleRate=\(hwFmt.sampleRate) channels=\(hwFmt.channelCount)")
            return
        }

        // Remove any leftover temp file
        try? FileManager.default.removeItem(at: tempAudioURL)

        // Write WAV in the hardware's native format — reliable, no conversion.
        do {
            audioFile = try AVAudioFile(forWriting: tempAudioURL,
                                        settings: hwFmt.settings)
        } catch {
            NSLog("🎤 [Dictate] could not create audio file: \(error)")
            return
        }

        // Tap with nil format = use hardware's native format (safest, never fails).
        node.installTap(onBus: 0, bufferSize: 4096, format: nil) { [weak self] buffer, _ in
            guard let self = self, let file = self.audioFile else { return }
            do {
                try file.write(from: buffer)
            } catch {
                NSLog("🎤 [Dictate] write error: \(error)")
            }
        }

        engine.prepare()
        do { try engine.start() } catch {
            NSLog("🎤 [Dictate] engine start error: \(error)")
            return
        }

        audioEngine = engine
        isRecording = true

        // Engine is running — NOW start the timer and fade it in
        startElapsedTimer()
        UIView.animate(withDuration: 0.3) {
            self.timerLabel.alpha = 1
        }

        NSLog("🎤 [Dictate] recording started — rate=\(hwFmt.sampleRate) ch=\(hwFmt.channelCount)")
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
    }

    // MARK: - Transcription (WhisperKit on-device → fallback to Whisper API)

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

        NSLog("🎤 [Dictate] whisperReady=\(Self.sharedWhisperReady) pipe=\(Self.sharedWhisperPipe != nil ? "loaded" : "nil")")
        if Self.sharedWhisperReady, let pipe = Self.sharedWhisperPipe {
            NSLog("🎤 [Dictate] → Using WhisperKit (on-device)")
            transcribeOnDevice(pipe: pipe)
        } else {
            NSLog("🎤 [Dictate] WhisperKit not available — falling back to API")
            transcribeViaAPI()
        }
    }

    // MARK: - WhisperKit on-device transcription

    private func transcribeOnDevice(pipe: WhisperKit) {
        let audioPath = tempAudioURL.path
        let startTime = CFAbsoluteTimeGetCurrent()

        Task {
            do {
                // Hybrid approach:
                // 1. Try WhisperKit tiny (English, fast, on-device)
                // 2. Check if the result is real English
                // 3. If not → user spoke target language → send to Whisper API (reliable for all languages)

                NSLog("🎤 [Dictate] Step 1: trying WhisperKit tiny (English)")
                let enOptions = DecodingOptions(
                    language: "en",
                    temperature: 0.0,
                    usePrefillPrompt: false,
                    skipSpecialTokens: true,
                    clipTimestamps: []
                )

                let enResults = try await pipe.transcribe(
                    audioPath: audioPath,
                    decodeOptions: enOptions
                )

                let enText = enResults.map { $0.text }.joined(separator: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                let step1Time = CFAbsoluteTimeGetCurrent() - startTime
                NSLog("🎤 [Dictate] WhisperKit English in %.2fs: '\(enText.prefix(60))'", step1Time)

                // Check if the result is actually English
                let recognizer = NLLanguageRecognizer()
                recognizer.processString(enText)
                let textLang = recognizer.dominantLanguage?.rawValue
                    .components(separatedBy: "-").first ?? ""

                NSLog("🎤 [Dictate] NLLanguageRecognizer says text is: \(textLang)")

                let fullText: String
                let detectedLang: String

                if textLang == "en" && !enText.isEmpty {
                    // Real English text — use it
                    fullText = enText
                    detectedLang = "en"
                    // Clean up temp file
                    try? FileManager.default.removeItem(at: self.tempAudioURL)
                    NSLog("🎤 [Dictate] → confirmed English (on-device, fast)")
                } else {
                    // Not English — user spoke target language
                    // Send to Whisper API for reliable multilingual transcription
                    NSLog("🎤 [Dictate] → not English, sending to Whisper API for \(self.targetLanguage)...")

                    // Don't clean up temp file yet — API needs it
                    await MainActor.run {
                        self.commitViaAPI()
                    }
                    return
                }

                NSLog("🎤 [Dictate] result: lang=\(detectedLang) text='\(fullText.prefix(80))'")


                await MainActor.run {
                    guard !fullText.isEmpty else {
                        NSLog("🎤 [Dictate] WhisperKit returned empty transcription")
                        self.dismiss(animated: true)
                        return
                    }

                    // WhisperKit returns ISO codes directly (e.g. "en", "es", "fr")
                    let langForKeyboard = detectedLang.isEmpty ? self.targetLanguage : detectedLang

                    self.commitToKeyboard(text: fullText, lang: langForKeyboard)
                }
            } catch {
                NSLog("🎤 [Dictate] WhisperKit error: \(error) — falling back to API")
                await MainActor.run {
                    self.committed = false  // Reset so fallback can commit
                    self.transcribeViaAPI()
                }
            }
        }
    }

    // MARK: - Whisper API (used for target language transcription + older device fallback)

    /// Called from hybrid path when WhisperKit detects non-English speech
    private func commitViaAPI() {
        transcribeViaAPI()
    }

    private func transcribeViaAPI() {
        committed = true

        let fileURL = tempAudioURL
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            dismiss(animated: true)
            return
        }

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
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"recording.wav\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        if let audioData = try? Data(contentsOf: fileURL) {
            body.append(audioData)
            NSLog("🎤 [Dictate] API fallback: uploading \(audioData.count) bytes")
        }
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"response_format\"\r\n\r\n".data(using: .utf8)!)
        body.append("verbose_json\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        NSLog("🎤 [Dictate] sending to Whisper API (fallback)...")

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
                    NSLog("🎤 [Dictate] API response invalid")
                    self.dismiss(animated: true)
                    return
                }

                let transcription = (json["text"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let whisperLang   = json["language"] as? String ?? ""

                NSLog("🎤 [Dictate] API result: lang=\(whisperLang) text='\(transcription)'")

                guard !transcription.isEmpty else {
                    self.dismiss(animated: true)
                    return
                }

                let detectedCode = self.whisperLangToCode(whisperLang)
                let langForKeyboard = detectedCode.isEmpty ? self.targetLanguage : detectedCode

                self.commitToKeyboard(text: transcription, lang: langForKeyboard)
            }
        }.resume()
    }

    /// Maps Whisper API's verbose language name to ISO code (only needed for API fallback).
    private func whisperLangToCode(_ whisperLang: String) -> String {
        let lower = whisperLang.lowercased()
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
        return map[lower] ?? ""
    }

    // MARK: - Commit result to keyboard via App Group

    private func commitToKeyboard(text: String, lang: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        NSLog("🎤 [Dictate] COMMIT lang=\(lang) text='\(trimmed)'")
        guard !trimmed.isEmpty else { dismiss(animated: true); return }

        // If user spoke in the target language → accent_coach (correction/coaching)
        // If user spoke English → speech (translation)
        let mode = (lang == targetLanguage) ? "accent_coach" : "speech"

        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        defaults?.set(trimmed,                     forKey: "dictate_result")
        defaults?.set(lang,                        forKey: "dictate_result_language")
        defaults?.set(mode,                        forKey: "dictate_mode")
        defaults?.set(Date().timeIntervalSince1970, forKey: "dictate_result_timestamp")
        defaults?.synchronize()

        // Dismiss immediately — no artificial delay
        dismiss(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let url = URL(string: "whatsapp://") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
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

    @objc private func cancelTapped() { stopAll(); dismiss(animated: true) }
}
