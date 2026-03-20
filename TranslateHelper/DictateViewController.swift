//
//  DictateViewController.swift
//  TranslateHelper
//
//  Records audio via AVAudioEngine, sends the WAV file to OpenAI Whisper
//  for transcription + automatic language detection, then hands the result
//  back to the keyboard extension via App Group UserDefaults.
//
//  IMPORTANT: This file is the ONLY place Whisper integration lives.
//  KeyboardViewController.swift is NOT touched — it reads the same
//  App Group keys as before (dictate_result, dictate_result_language, etc.).

import UIKit
import AVFoundation

class DictateViewController: UIViewController {

    // MARK: - State
    private var audioEngine   = AVAudioEngine()
    private var audioFile:      AVAudioFile?
    private var spokenText    = ""
    private var detectedLang  = ""
    private var committed     = false
    private var isRecording   = false
    private var elapsedSeconds = 0
    private var elapsedTimer:  Timer?
    private var ringLayer1:    CAShapeLayer?
    private var ringLayer2:    CAShapeLayer?
    private var sendBorderGradient: CAGradientLayer?

    /// Target language code set by SceneDelegate from the URL param (e.g. "es", "zh", "fr").
    var targetLanguage: String = "es"

    /// Path to the temporary M4A file used for Whisper upload.
    private var tempAudioURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("dictate_recording.m4a")
    }

    // MARK: - UI elements
    private let iconCircle      = UIView()
    private let iconImageView   = UIImageView()
    private let timerLabel      = UILabel()
    private let sendButton      = UIButton(type: .custom)
    private let cancelButton    = UIButton(type: .system)
    private let titleLabel      = UILabel()   // "Voice Translate" centre
    private let titleIcon       = UIImageView()

    // MARK: - Lifecycle
    override func viewDidLoad()    { super.viewDidLoad(); setupUI() }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSonarRings()
        beginRecording()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAll()
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
        // The two sonar rings will be added as sub-layers in viewDidAppear
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        iconCircle.layer.cornerRadius = 67.5   // diameter = 135
        view.addSubview(iconCircle)

        let iconCfg = UIImage.SymbolConfiguration(pointSize: 78, weight: .medium)
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
            iconCircle.widthAnchor.constraint(equalToConstant: 135),
            iconCircle.heightAnchor.constraint(equalToConstant: 135),

            iconImageView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 72),
            iconImageView.heightAnchor.constraint(equalToConstant: 72),

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
        let radius: CGFloat = 67.5
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
    private func startElapsedTimer() {
        elapsedSeconds = 0
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedSeconds += 1
            let m = self.elapsedSeconds / 60
            let s = self.elapsedSeconds % 60
            self.timerLabel.text = String(format: "%d:%02d", m, s)
        }
    }
    private func stopElapsedTimer() {
        elapsedTimer?.invalidate(); elapsedTimer = nil
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

        NSLog("🎤 [Dictate] hardware format: \(hwFmt)")

        guard hwFmt.sampleRate > 0, hwFmt.channelCount > 0 else {
            NSLog("🎤 [Dictate] invalid hardware format — sampleRate=\(hwFmt.sampleRate) channels=\(hwFmt.channelCount)")
            return
        }

        // Remove any leftover temp file
        try? FileManager.default.removeItem(at: tempAudioURL)

        // Write as compressed M4A (AAC) — ~80x smaller than raw WAV for faster upload.
        // 16kHz mono is all Whisper needs for speech recognition.
        let m4aSettings: [String: Any] = [
            AVFormatIDKey:           Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey:         16000.0,
            AVNumberOfChannelsKey:   1,
            AVEncoderBitRateKey:     32000,  // 32kbps — plenty for speech
        ]

        do {
            audioFile = try AVAudioFile(forWriting: tempAudioURL,
                                        settings: m4aSettings,
                                        commonFormat: .pcmFormatFloat32,
                                        interleaved: false)
        } catch {
            NSLog("🎤 [Dictate] could not create audio file: \(error)")
            return
        }

        // Tap with nil format = use hardware's native format (safest, never fails).
        // AVAudioFile handles the conversion from hardware format → 16kHz AAC on write.
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
        startElapsedTimer()
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

    // MARK: - Whisper API transcription

    private func sendToWhisper() {
        guard !committed else { return }
        committed = true
        stopRecordingEngine()
        isRecording = false
        showProcessingState()

        let fileURL = tempAudioURL
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            NSLog("🎤 [Dictate] no audio file to send")
            dismiss(animated: true)
            return
        }

        let apiKey = APIConfig.openAIAPIKey
        guard let url = URL(string: "\(APIConfig.openAIBaseURL)/audio/transcriptions") else { return }

        // Build multipart/form-data request
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        var body = Data()

        // "file" field — the M4A audio
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"recording.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        if let audioData = try? Data(contentsOf: fileURL) {
            body.append(audioData)
        }
        body.append("\r\n".data(using: .utf8)!)

        // "model" field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)

        // "response_format" field — we want verbose_json to get the detected language
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"response_format\"\r\n\r\n".data(using: .utf8)!)
        body.append("verbose_json\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        NSLog("🎤 [Dictate] sending audio to Whisper API...")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                // Clean up temp file
                try? FileManager.default.removeItem(at: fileURL)

                if let error = error {
                    NSLog("🎤 [Dictate] Whisper error: \(error.localizedDescription)")
                    self.dismiss(animated: true)
                    return
                }

                guard let data = data else {
                    NSLog("🎤 [Dictate] Whisper returned no data")
                    self.dismiss(animated: true)
                    return
                }

                // Parse verbose_json response: { "text": "...", "language": "english", ... }
                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    NSLog("🎤 [Dictate] Whisper response not valid JSON: \(String(data: data, encoding: .utf8) ?? "")")
                    self.dismiss(animated: true)
                    return
                }

                let transcription = (json["text"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let whisperLang   = json["language"] as? String ?? ""  // e.g. "english", "spanish", "french"

                NSLog("🎤 [Dictate] Whisper result: lang=\(whisperLang) text='\(transcription)'")

                guard !transcription.isEmpty else {
                    NSLog("🎤 [Dictate] Whisper returned empty transcription")
                    self.dismiss(animated: true)
                    return
                }

                // Map Whisper's full language name to our ISO code
                let detectedCode = self.whisperLangToCode(whisperLang)

                // Determine the language to report to the keyboard:
                // If user spoke in their target language → report target language (triggers correction mode)
                // If user spoke English → report English (triggers translation mode)
                let langForKeyboard = detectedCode.isEmpty ? self.targetLanguage : detectedCode

                self.commitToKeyboard(text: transcription, lang: langForKeyboard)
            }
        }.resume()
    }

    /// Maps Whisper's verbose language name (e.g. "english", "spanish") to ISO code.
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

        // Determine dictate mode based on what language was spoken
        // If user spoke in the target language → accent_coach (triggers correction/coaching)
        // If user spoke English → speech (triggers translation)
        let mode = (lang == targetLanguage) ? "accent_coach" : "speech"

        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        defaults?.set(trimmed,                     forKey: "dictate_result")
        defaults?.set(lang,                        forKey: "dictate_result_language")
        defaults?.set(mode,                        forKey: "dictate_mode")
        defaults?.set(Date().timeIntervalSince1970, forKey: "dictate_result_timestamp")
        defaults?.synchronize()

        showProcessingState()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.dismiss(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let url = URL(string: "whatsapp://") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }

    // MARK: - Actions
    @objc private func doneTapped() {
        guard !committed else { return }
        if !isRecording {
            stopAll(); dismiss(animated: true)
        } else {
            sendToWhisper()
        }
    }

    @objc private func cancelTapped() { stopAll(); dismiss(animated: true) }
}
