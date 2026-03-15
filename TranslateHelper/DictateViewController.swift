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
    private var esText        = ""
    private var committed     = false
    private var isRecording   = false
    private var pulseTimer:   Timer?

    // MARK: - UI
    private let micCircle       = UIView()
    private let micImageView    = UIImageView()
    private let statusLabel     = UILabel()
    private let transcriptLabel = UILabel()
    private let subtitleLabel   = UILabel()
    private let doneButton      = UIButton(type: .system)
    private let cancelButton    = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad()    { super.viewDidLoad(); setupUI() }
    override func viewDidAppear(_ animated: Bool)    { super.viewDidAppear(animated); startRecording() }
    override func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear(animated); stopAll() }

    // MARK: - UI
    private func setupUI() {
        view.backgroundColor = .systemBackground

        // ── Mic circle ─────────────────────────────────────────────────────
        micCircle.translatesAutoresizingMaskIntoConstraints = false
        micCircle.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        micCircle.layer.cornerRadius = 64
        micCircle.layer.borderWidth  = 2
        micCircle.layer.borderColor  = UIColor.systemBlue.cgColor
        view.addSubview(micCircle)

        let cfg = UIImage.SymbolConfiguration(pointSize: 48, weight: .medium)
        micImageView.translatesAutoresizingMaskIntoConstraints = false
        micImageView.image = UIImage(systemName: "mic.fill", withConfiguration: cfg)
        micImageView.tintColor = .systemBlue
        micImageView.contentMode = .scaleAspectFit
        micCircle.addSubview(micImageView)

        // ── Status label ───────────────────────────────────────────────────
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.text = "Habla en Español"
        statusLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        statusLabel.textColor = .label
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)

        // ── Subtitle / coaching hint ───────────────────────────────────────
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Speak in Spanish — we'll critique your accent & phrasing"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        view.addSubview(subtitleLabel)

        // ── Live transcript ────────────────────────────────────────────────
        transcriptLabel.translatesAutoresizingMaskIntoConstraints = false
        transcriptLabel.text = ""
        transcriptLabel.font = .systemFont(ofSize: 18)
        transcriptLabel.textColor = .label
        transcriptLabel.textAlignment = .center
        transcriptLabel.numberOfLines = 0
        view.addSubview(transcriptLabel)

        // ── Done button ────────────────────────────────────────────────────
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        doneButton.backgroundColor = .systemBlue
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 14
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        view.addSubview(doneButton)

        // ── Cancel button ──────────────────────────────────────────────────
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.secondaryLabel, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            micCircle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            micCircle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            micCircle.widthAnchor.constraint(equalToConstant: 128),
            micCircle.heightAnchor.constraint(equalToConstant: 128),

            micImageView.centerXAnchor.constraint(equalTo: micCircle.centerXAnchor),
            micImageView.centerYAnchor.constraint(equalTo: micCircle.centerYAnchor),
            micImageView.widthAnchor.constraint(equalToConstant: 56),
            micImageView.heightAnchor.constraint(equalToConstant: 56),

            statusLabel.topAnchor.constraint(equalTo: micCircle.bottomAnchor, constant: 28),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            transcriptLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            transcriptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            transcriptLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: 220),
            doneButton.heightAnchor.constraint(equalToConstant: 52),

            cancelButton.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -12),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    // MARK: - Pulse
    private func startPulse() {
        pulseTimer = Timer.scheduledTimer(withTimeInterval: 0.9, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.45) {
                self.micCircle.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
                self.micCircle.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.22)
            } completion: { _ in
                UIView.animate(withDuration: 0.45) {
                    self.micCircle.transform = .identity
                    self.micCircle.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
                }
            }
        }
    }
    private func stopPulse() {
        pulseTimer?.invalidate(); pulseTimer = nil
        UIView.animate(withDuration: 0.2) {
            self.micCircle.transform = .identity
            self.micCircle.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        }
    }

    // MARK: - Recording
    private func startRecording() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self, status == .authorized else { return }
                AVAudioApplication.requestRecordPermission { granted in
                    DispatchQueue.main.async { if granted { self.startEsMX() } }
                }
            }
        }
    }

    /// Spanish-only recognition — no English fallback.
    /// The keyboard will route this through accent critique automatically.
    private func startEsMX() {
        guard !committed else { return }
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-MX")) else {
            statusLabel.text = "Spanish recognition unavailable"
            return
        }

        guard let request = bootAudioEngine() else { return }
        isRecording = true
        startPulse()

        NSLog("🎤 [Dictate] es-MX recognizer starting (Spanish-only mode)")
        currentTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self, !self.committed else { return }

                if let r = result {
                    let text = r.bestTranscription.formattedString
                    NSLog("🎤 [Dictate] es-MX partial: '\(text)' isFinal=\(r.isFinal)")
                    if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        self.esText = text
                        self.transcriptLabel.text = text
                        self.transcriptLabel.textColor = .label
                    }
                    if r.isFinal {
                        NSLog("🎤 [Dictate] es-MX final: '\(text)'")
                        if self.esText.isEmpty {
                            self.statusLabel.text = "No escuché nada — inténtalo de nuevo"
                        } else {
                            self.commitWith(text: self.esText, lang: "es")
                        }
                    }
                }

                if let error = error {
                    NSLog("🎤 [Dictate] es-MX error: \(error.localizedDescription) — esText='\(self.esText)'")
                    if !self.esText.isEmpty {
                        self.commitWith(text: self.esText, lang: "es")
                    } else {
                        // Recognition session closed without any result — keep mic alive
                        self.statusLabel.text = "Listening…"
                    }
                }
            }
        }
    }

    // MARK: - Audio engine helpers
    private func bootAudioEngine() -> SFSpeechAudioBufferRecognitionRequest? {
        let engine  = AVAudioEngine()
        let node    = engine.inputNode
        let fmt     = node.outputFormat(forBus: 0)
        guard fmt.sampleRate > 0 else { statusLabel.text = "Mic unavailable"; return nil }

        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch { statusLabel.text = "Audio error"; return nil }

        NSLog("🎤 [Dictate] Audio engine booting — sampleRate=\(fmt.sampleRate)")
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults    = true
        request.requiresOnDeviceRecognition   = false

        node.installTap(onBus: 0, bufferSize: 4096, format: fmt) { [weak request] buf, _ in
            request?.append(buf)
        }
        engine.prepare()
        do { try engine.start() } catch { statusLabel.text = "Engine error"; return nil }

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
        stopPulse()
    }

    // MARK: - Commit
    private func commitWith(text: String, lang: String) {
        guard !committed else { return }
        committed = true
        stopAll()

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        NSLog("🎤 [Dictate] COMMIT lang=\(lang) text='\(trimmed)'")
        guard !trimmed.isEmpty else { return }

        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        defaults?.set(trimmed,                      forKey: "dictate_result")
        defaults?.set(lang,                         forKey: "dictate_result_language")
        defaults?.set("accent_coach",               forKey: "dictate_mode")   // ← tells keyboard to use critique path
        defaults?.set(Date().timeIntervalSince1970,  forKey: "dictate_result_timestamp")
        defaults?.synchronize()

        statusLabel.text = "¡Perfecto! ✓"
        statusLabel.textColor = .systemGreen
        transcriptLabel.text = trimmed
        subtitleLabel.text = "Analyzing your pronunciation…"
        UIView.animate(withDuration: 0.2) { self.doneButton.backgroundColor = .systemGreen }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.dismiss(animated: true)
            // Return to WhatsApp automatically
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let url = URL(string: "whatsapp://") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }

    // MARK: - Button actions
    @objc private func doneTapped() {
        let current = transcriptLabel.text ?? ""
        guard !current.isEmpty else { stopAll(); dismiss(animated: true); return }

        // Always treat manually-confirmed text as Spanish speech
        commitWith(text: esText.isEmpty ? current : esText, lang: "es")
    }

    @objc private func cancelTapped() { stopAll(); dismiss(animated: true) }
}
