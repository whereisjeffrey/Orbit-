import Foundation
import AVFoundation

class TTSService {
    static let shared = TTSService()
    private let synthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?

    /// Maps a 2-letter ISO 639-1 code to BCP-47 locale tag.
    static func bcp47Locale(for isoCode: String) -> String {
        LanguageManager.ttsLocale(for: isoCode.lowercased())
    }

    // Best available Apple voice: Premium > Enhanced > any voice for that locale
    func bestVoice(for language: String) -> AVSpeechSynthesisVoice? {
        let prefix = String(language.prefix(2))
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix(prefix) }
        if #available(iOS 16, *),
           let p = voices.first(where: { $0.quality == .premium }) { return p }
        if let e = voices.first(where: { $0.quality == .enhanced }) { return e }
        if let any = voices.first { return any }
        return AVSpeechSynthesisVoice(language: language)
    }

    func hasEnhancedVoice(for language: String) -> Bool {
        let prefix = String(language.prefix(2))
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix(prefix) }
        if #available(iOS 16, *), voices.contains(where: { $0.quality == .premium }) { return true }
        return voices.contains { $0.quality == .enhanced }
    }

    /// Speak using Google Neural2 (high quality) with Apple fallback.
    func speak(_ text: String, language: String) {
        synthesizer.stopSpeaking(at: .immediate)
        audioPlayer?.stop()

        // Try Google Neural2 first
        speakWithNeural2(text: text, locale: language) { [weak self] success in
            if !success {
                // Fallback to Apple TTS
                NSLog("🔊 [TTSService] Neural2 failed — falling back to Apple")
                DispatchQueue.main.async {
                    self?.speakWithApple(text: text, language: language)
                }
            }
        }
    }

    /// Google Neural2 TTS — same quality as keyboard and Coach sessions
    private func speakWithNeural2(text: String, locale: String, completion: @escaping (Bool) -> Void) {
        let apiKey = APIConfig.googleTTSAPIKey
        guard !apiKey.isEmpty,
              let url = URL(string: "\(APIConfig.googleTTSBaseURL)/text:synthesize?key=\(apiKey)")
        else {
            completion(false)
            return
        }

        let body: [String: Any] = [
            "input": ["text": text],
            "voice": ["languageCode": locale, "name": "\(locale)-Neural2-A", "ssmlGender": "FEMALE"],
            "audioConfig": ["audioEncoding": "MP3", "speakingRate": 0.95]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 8

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let audioContent = json["audioContent"] as? String,
                  let audioData = Data(base64Encoded: audioContent)
            else {
                completion(false)
                return
            }

            DispatchQueue.main.async {
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                    try AVAudioSession.sharedInstance().setActive(true)
                    self?.audioPlayer = try AVAudioPlayer(data: audioData)
                    self?.audioPlayer?.play()
                    completion(true)
                } catch {
                    NSLog("🔊 [TTSService] Neural2 playback error: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }.resume()
    }

    /// Apple TTS fallback
    private func speakWithApple(text: String, language: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.0
        utterance.voice = bestVoice(for: language)
            ?? AVSpeechSynthesisVoice(language: language)

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        audioPlayer?.stop()
    }
}
