import Foundation
import AVFoundation

class TTSService {
    static let shared = TTSService()
    private let synthesizer = AVSpeechSynthesizer()

    /// Maps a 2-letter ISO 639-1 code (as stored in SavedPhrase.targetLang / sourceLang)
    /// to the best BCP-47 locale tag recognised by AVSpeechSynthesizer.
    /// Falls back to the raw code so at least a voice-search attempt is made.
    static func bcp47Locale(for isoCode: String) -> String {
        switch isoCode.lowercased() {
        case "en":  return "en-US"
        case "zh":  return "zh-CN"
        case "es":  return "es-MX"
        case "hi":  return "hi-IN"
        case "ar":  return "ar-SA"
        case "bn":  return "bn-IN"
        case "fr":  return "fr-FR"
        case "pt":  return "pt-BR"
        case "ru":  return "ru-RU"
        case "id":  return "id-ID"
        case "ur":  return "ur-PK"
        case "de":  return "de-DE"
        case "ja":  return "ja-JP"
        case "sw":  return "sw-KE"
        case "ko":  return "ko-KR"
        case "fa":  return "fa-IR"
        case "vi":  return "vi-VN"
        case "cs":  return "cs-CZ"
        case "it":  return "it-IT"
        case "th":  return "th-TH"
        case "pl":  return "pl-PL"
        case "uk":  return "uk-UA"
        case "nl":  return "nl-NL"
        case "tr":  return "tr-TR"
        case "he":  return "he-IL"
        case "el":  return "el-GR"
        case "sv":  return "sv-SE"
        case "da":  return "da-DK"
        case "no":  return "nb-NO"
        case "fi":  return "fi-FI"
        case "hu":  return "hu-HU"
        case "ro":  return "ro-RO"
        case "bg":  return "bg-BG"
        case "hr":  return "hr-HR"
        case "sk":  return "sk-SK"
        case "ca":  return "ca-ES"
        case "ms":  return "ms-MY"
        case "fil": return "fil-PH"
        case "af":  return "af-ZA"
        case "ta":  return "ta-IN"
        default:    return isoCode
        }
    }
    
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
    
    func speak(_ text: String, language: String) {
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
