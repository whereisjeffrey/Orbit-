//
//  DictateViewController.swift
//  TranslateHelper
//

import UIKit
import Speech
import AVFoundation

class DictateViewController: UIViewController {

    // MARK: - State
    private var audioEngine   = AVAudioEngine()
    private var currentRequest: SFSpeechAudioBufferRecognitionRequest?
    private var currentTask:    SFSpeechRecognitionTask?
    private var spokenText    = ""
    private var committed     = false
    private var isRecording   = false
    private var elapsedSeconds = 0
    private var elapsedTimer:  Timer?
    private var ringLayer1:    CAShapeLayer?
    private var ringLayer2:    CAShapeLayer?

    /// Target language code set by SceneDelegate from the URL param (e.g. "es", "zh", "fr").
    var targetLanguage: String = "es"

    // MARK: - Locale helpers

    private var recognizerLocale: Locale {
        let map: [String: String] = [
            "es": "es-MX", "zh": "zh-CN", "fr": "fr-FR", "pt": "pt-BR",
            "de": "de-DE", "it": "it-IT", "ja": "ja-JP",
            "ko": "ko-KR", "ar": "ar-SA", "en": "en-US"
        ]
        return Locale(identifier: map[targetLanguage] ?? "es-MX")
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
        startRecording()
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
        iconCircle.layer.cornerRadius = 22   // diameter = 45
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
        sendButton.layer.borderWidth = 1.0
        sendButton.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
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
            iconCircle.widthAnchor.constraint(equalToConstant: 45),
            iconCircle.heightAnchor.constraint(equalToConstant: 45),

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

    // MARK: - Sonar ring animation (two expanding rings)
    private func startSonarRings() {
        addRing(delay: 0.0, tag: 1)
        addRing(delay: 0.7, tag: 2)
    }

    private func addRing(delay: Double, tag: Int) {
        let radius: CGFloat = 22          // matches iconCircle corner radius
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

        // Scale up + fade out, looping
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

    // MARK: - Recording
    private func startRecording() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self, status == .authorized else { return }
                AVAudioApplication.requestRecordPermission { granted in
                    DispatchQueue.main.async { if granted { self.startRecognition() } }
                }
            }
        }
    }

    private func startRecognition() {
        guard !committed else { return }
        guard let recognizer = SFSpeechRecognizer(locale: recognizerLocale) else { return }

        guard let request = bootAudioEngine() else { return }
        isRecording = true
        startElapsedTimer()

        NSLog("🎤 [Dictate] recognizer starting locale=\(recognizerLocale.identifier)")
        currentTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self, !self.committed else { return }

                if let r = result {
                    let text = r.bestTranscription.formattedString
                    if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        self.spokenText = text
                    }
                    if r.isFinal && !self.spokenText.isEmpty {
                        self.commitWith(text: self.spokenText, lang: self.targetLanguage)
                    }
                }

                if let error = error {
                    NSLog("🎤 [Dictate] error: \(error.localizedDescription) — text='\(self.spokenText)'")
                    if !self.spokenText.isEmpty {
                        self.commitWith(text: self.spokenText, lang: self.targetLanguage)
                    }
                }
            }
        }
    }

    // MARK: - Audio engine helpers
    private func bootAudioEngine() -> SFSpeechAudioBufferRecognitionRequest? {
        let engine = AVAudioEngine()
        let node   = engine.inputNode
        let fmt    = node.outputFormat(forBus: 0)
        guard fmt.sampleRate > 0 else { return nil }

        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch { return nil }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults  = true
        request.requiresOnDeviceRecognition = false

        node.installTap(onBus: 0, bufferSize: 4096, format: fmt) { [weak request] buf, _ in
            request?.append(buf)
        }
        engine.prepare()
        do { try engine.start() } catch { return nil }

        audioEngine    = engine
        currentRequest = request
        return request
    }

    private func teardownAudio() {
        currentTask?.cancel()
        currentRequest?.endAudio()
        if audioEngine.isRunning {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
        }
        currentTask    = nil
        currentRequest = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func stopAll() {
        teardownAudio()
        isRecording = false
        stopElapsedTimer()
        stopSonarRings()
    }

    // MARK: - Commit
    private func commitWith(text: String, lang: String) {
        guard !committed else { return }
        committed = true
        stopAll()

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        NSLog("🎤 [Dictate] COMMIT lang=\(lang) text='\(trimmed)'")
        guard !trimmed.isEmpty else { dismiss(animated: true); return }

        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        defaults?.set(trimmed,                     forKey: "dictate_result")
        defaults?.set(lang,                        forKey: "dictate_result_language")
        defaults?.set("accent_coach",              forKey: "dictate_mode")
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
        if spokenText.isEmpty {
            // Nothing heard yet — commit what we have OR just dismiss silently
            stopAll(); dismiss(animated: true)
        } else {
            commitWith(text: spokenText, lang: targetLanguage)
        }
    }

    @objc private func cancelTapped() { stopAll(); dismiss(animated: true) }
}
