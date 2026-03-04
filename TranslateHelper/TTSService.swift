import Foundation
import AVFoundation

class TTSService {
    static let shared = TTSService()
    private let synthesizer = AVSpeechSynthesizer()
    
    // Best available voice: Premium > Enhanced > any voice for that locale > system default
    func bestVoice(for language: String) -> AVSpeechSynthesisVoice? {
        let prefix = String(language.prefix(2))
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix(prefix) }
        if #available(iOS 16, *),
           let p = voices.first(where: { $0.quality == .premium }) { return p }
        if let e = voices.first(where: { $0.quality == .enhanced }) { return e }
        // Any voice for this locale is better than a wrong-language default
        if let any = voices.first { return any }
        // Explicit locale construction — ensures language is set even without downloaded voices
        return AVSpeechSynthesisVoice(language: language)
    }
    
    func hasEnhancedVoice(for language: String) -> Bool {
        let prefix = String(language.prefix(2))
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix(prefix) }
        if #available(iOS 16, *), voices.contains(where: { $0.quality == .premium }) { return true }
        return voices.contains { $0.quality == .enhanced }
    }
    
    func speak(_ text: String, language: String = "es-MX") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.0

        // Always assign an explicit voice so we never accidentally speak
        // a Spanish string through the system's default English voice.
        // bestVoice now guarantees a non-nil result for any supported locale.
        utterance.voice = bestVoice(for: language)
            ?? AVSpeechSynthesisVoice(language: language)

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
