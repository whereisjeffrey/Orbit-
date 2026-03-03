import Foundation
import AVFoundation

class TTSService {
    static let shared = TTSService()
    private let synthesizer = AVSpeechSynthesizer()
    
    // Best available voice: Premium > Enhanced > system default
    func bestVoice(for language: String) -> AVSpeechSynthesisVoice? {
        let prefix = String(language.prefix(2))
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix(prefix) }
        if #available(iOS 16, *),
           let p = voices.first(where: { $0.quality == .premium }) { return p }
        if let e = voices.first(where: { $0.quality == .enhanced }) { return e }
        return AVSpeechSynthesisVoice(language: language)
    }
    
    func hasEnhancedVoice(for language: String) -> Bool {
        let prefix = String(language.prefix(2))
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix(prefix) }
        if #available(iOS 16, *), voices.contains(where: { $0.quality == .premium }) { return true }
        return voices.contains { $0.quality == .enhanced }
    }
    
    func speak(_ text: String, language: String = "pt-BR") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = bestVoice(for: language)
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
