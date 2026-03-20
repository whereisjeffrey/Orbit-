//
//  SpeechService.swift
//  TalkSwitch
//

import Foundation
import Speech
import AVFoundation

protocol SpeechServiceDelegate: AnyObject {
    func speechService(_ service: SpeechService, didRecognize text: String, isFinal: Bool)
    func speechService(_ service: SpeechService, didFinishWith text: String, language: String, lowConfidenceWords: [String])
    func speechService(_ service: SpeechService, didFailWith error: Error)
}

class SpeechService {

    static let shared = SpeechService()
    weak var delegate: SpeechServiceDelegate?

    // AVAudioEngine → SFSpeechAudioBufferRecognitionRequest (streaming)
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionTimeout: DispatchWorkItem?
    private var currentLanguage: String = "en-US"  // Will be set dynamically before recording

    private(set) var isListening = false
    private(set) var detectedLanguage: String = "en"

    private init() {}

    // MARK: - Permissions

    func requestPermissions(completion: @escaping (Bool) -> Void) {
        var speechOK = false
        var micOK = false
        let group = DispatchGroup()

        group.enter()
        SFSpeechRecognizer.requestAuthorization { status in
            speechOK = (status == .authorized)
            group.leave()
        }

        group.enter()
        AVAudioApplication.requestRecordPermission { granted in
            micOK = granted
            group.leave()
        }

        group.notify(queue: .main) {
            completion(speechOK && micOK)
        }
    }

    // MARK: - Start

    func startListening() {
        if isListening { stopListening() }
        // Use en-US for initial test — avoids es-MX fallback restart timing issues
        startRecording(language: "en-US")
    }

    func startListeningIn(language: String) {
        if isListening { stopListening() }
        startRecording(language: language)
    }

    private func startRecording(language: String) {
        currentLanguage = language

        // Step 1: activate audio session first
        do {
            let session = AVAudioSession.sharedInstance()
            // playAndRecord + mixWithOthers: coexists with WhatsApp audio instead of competing
            try session.setCategory(.record, mode: .measurement, options: [])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            // Route to built-in mic
            if let builtInMic = session.availableInputs?.first(where: { $0.portType == .builtInMic }) {
                try? session.setPreferredInput(builtInMic)
            }
            let perm = AVAudioApplication.shared.recordPermission
            NSLog("TSKBD_AUDIO: session activated — sampleRate=\(session.sampleRate) micPerm=\(perm.rawValue)")
        } catch {
            NSLog("TSKBD_AUDIO: session failed — \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.delegate?.speechService(self, didFailWith: NSError(
                    domain: "SpeechService", code: -7,
                    userInfo: [NSLocalizedDescriptionKey: "Session activate failed: \(error.localizedDescription)"]))
            }
            return
        }

        // Step 2: brief delay so session fully settles before engine taps it
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.startAudioEngine(language: language)
        }
    }

    private func startAudioEngine(language: String) {
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: language)),
              recognizer.isAvailable else {
            if language != "en-US" {
                startAudioEngine(language: "en-US")
                return
            }
            DispatchQueue.main.async {
                self.delegate?.speechService(self, didFailWith: NSError(
                    domain: "SpeechService", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Speech recognition unavailable"]))
            }
            return
        }

        let engine = AVAudioEngine()
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true

        let inputNode = engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        guard recordingFormat.sampleRate > 0 else {
            DispatchQueue.main.async {
                self.delegate?.speechService(self, didFailWith: NSError(
                    domain: "SpeechService", code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "sampleRate=0 — hardware audio access blocked in this extension process"]))
            }
            return
        }

        var tapCount = 0
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) { buffer, _ in
            tapCount += 1
            // Log energy every 10 buffers to confirm mic data flows
            if tapCount % 10 == 1 {
                let frames = Int(buffer.frameLength)
                var energy: Float = 0
                if let data = buffer.floatChannelData?[0] {
                    for i in 0..<frames { energy += abs(data[i]) }
                    energy /= Float(max(frames, 1))
                }
                NSLog("TSKBD_TAP: tap#\(tapCount) frames=\(frames) energy=\(String(format: "%.5f", energy))")
            }
            request.append(buffer)
        }

        engine.prepare()

        do {
            try engine.start()
        } catch {
            inputNode.removeTap(onBus: 0)
            DispatchQueue.main.async {
                self.delegate?.speechService(self, didFailWith: NSError(
                    domain: "SpeechService", code: -3,
                    userInfo: [NSLocalizedDescriptionKey: "Engine start failed: \(error.localizedDescription)"]))
            }
            return
        }

        audioEngine = engine
        recognitionRequest = request
        isListening = true

        var lastRecognizedText = ""
        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                let text = result.bestTranscription.formattedString
                NSLog("TSKBD_SPEECH: partial='\(text)' isFinal=\(result.isFinal)")

                // Stream partial results to UI
                if !text.isEmpty {
                    lastRecognizedText = text
                    DispatchQueue.main.async {
                        self.delegate?.speechService(self, didRecognize: text, isFinal: result.isFinal)
                    }
                }

                if result.isFinal {
                    self.recognitionTimeout?.cancel()
                    self.recognitionTimeout = nil
                    // Extract 2-letter ISO code from the locale (e.g., "es-MX" → "es", "pt-BR" → "pt")
                    let lang = String(language.prefix(2))
                    self.detectedLanguage = lang
                    var lowConfidence: [String] = []
                    for segment in result.bestTranscription.segments {
                        if segment.confidence > 0 && segment.confidence < 0.5 {
                            lowConfidence.append(segment.substring)
                        }
                    }
                    self.deactivateSession()
                    DispatchQueue.main.async {
                        self.delegate?.speechService(self, didFinishWith: text,
                                                     language: lang,
                                                     lowConfidenceWords: lowConfidence)
                    }
                }
            }

            if let error = error {
                let nsError = error as NSError
                NSLog("TSKBD_SPEECH_ERR: code=\(nsError.code) \(nsError.localizedDescription)")
                self.recognitionTimeout?.cancel()
                self.recognitionTimeout = nil
                // Only surface error if we have no text yet
                let hasText = !lastRecognizedText.isEmpty
                if !hasText {
                    self.deactivateSession()
                    DispatchQueue.main.async {
                        self.delegate?.speechService(self, didFailWith: NSError(
                            domain: nsError.domain, code: nsError.code,
                            userInfo: [NSLocalizedDescriptionKey: nsError.localizedDescription]))
                    }
                }
            }
        }
    }

    // MARK: - Stop

    func stopListening() {
        guard isListening else { return }
        isListening = false
        NSLog("TSKBD_STOP: signalling endAudio to recognizer")

        // Signal end-of-audio — keep session ACTIVE so recognizer can reach Apple servers
        recognitionRequest?.endAudio()
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        // NOTE: do NOT deactivate audio session here — recognizer needs network/session alive
        // Session is deactivated in deactivateSession() called from didFinish/didFail

        // 8s timeout — if recognizer never responds, surface error
        let timeout = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            NSLog("TSKBD_STOP: timeout fired — no response from recognizer")
            self.recognitionTask?.cancel()
            self.recognitionTask = nil
            self.deactivateSession()
            DispatchQueue.main.async {
                self.delegate?.speechService(self, didFailWith: NSError(
                    domain: "SpeechService", code: -10,
                    userInfo: [NSLocalizedDescriptionKey: "No response from speech server — check network"]))
            }
        }
        recognitionTimeout = timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 8, execute: timeout)
    }

    private func deactivateSession() {
        try? AVAudioSession.sharedInstance().setActive(false,
                                                       options: .notifyOthersOnDeactivation)
    }

    /// Cancel recording without transcribing (trash button)
    func cancelListening() {
        guard isListening else { return }
        isListening = false
        recognitionTimeout?.cancel()
        recognitionTimeout = nil

        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil

        try? AVAudioSession.sharedInstance().setActive(false,
                                                       options: .notifyOthersOnDeactivation)
    }

    // MARK: - Voice Quality Helpers

    /// Best available voice: Premium > Enhanced > system default
    static func bestVoice(for language: String) -> AVSpeechSynthesisVoice? {
        let prefix = String(language.prefix(2))
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix(prefix) }
        if #available(iOS 16, *),
           let p = voices.first(where: { $0.quality == .premium }) { return p }
        if let e = voices.first(where: { $0.quality == .enhanced }) { return e }
        return AVSpeechSynthesisVoice(language: language)
    }

    /// True if a downloaded Enhanced or Premium voice exists for this language
    static func hasEnhancedVoice(for language: String) -> Bool {
        let prefix = String(language.prefix(2))
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix(prefix) }
        if #available(iOS 16, *), voices.contains(where: { $0.quality == .premium }) { return true }
        return voices.contains { $0.quality == .enhanced }
    }

    // MARK: - Text to Speech

    private let synthesizer = AVSpeechSynthesizer()

    // MARK: - Locale Mapping

    /// Maps a 2-letter ISO code to the best iOS locale string for speech synthesis.
    /// Called by the keyboard's playTapped to support all 40 languages, not just Spanish.
    static func localeString(for code: String) -> String {
        switch code {
        case "es": return "es-MX"
        case "pt": return "pt-BR"
        case "zh": return "zh-Hans-CN"
        case "fr": return "fr-FR"
        case "de": return "de-DE"
        case "it": return "it-IT"
        case "ja": return "ja-JP"
        case "ko": return "ko-KR"
        case "ar": return "ar-SA"
        case "ru": return "ru-RU"
        case "nl": return "nl-NL"
        case "pl": return "pl-PL"
        case "tr": return "tr-TR"
        case "uk": return "uk-UA"
        case "sv": return "sv-SE"
        case "da": return "da-DK"
        case "no": return "nb-NO"
        case "fi": return "fi-FI"
        case "hi": return "hi-IN"
        case "id": return "id-ID"
        case "vi": return "vi-VN"
        case "he": return "he-IL"
        case "th": return "th-TH"
        default:   return "\(code)-\(code.uppercased())"
        }
    }

    func speak(_ text: String, language: String = "es-MX") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = SpeechService.bestVoice(for: language)
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.0

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
