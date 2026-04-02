//
//  LanguageManager.swift
//  TranslateHelper
//
//  Single source of truth for the user's target language.
//  Every file reads from here — never directly from UserDefaults.
//  This eliminates scattered ?? "es" fallbacks across the codebase.
//

import Foundation

final class LanguageManager {
    static let shared = LanguageManager()

    private let appGroupID = "group.com.jeff.translatehelper"
    private let targetLangKey = "talkswitch_target_lang"
    private let nativeLangKey = "talkswitch_native_lang"

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    // MARK: - Target Language

    /// The user's target language (what they're learning).
    /// Returns nil ONLY if the user has never completed language selection.
    /// All callers should handle nil by showing a "set your language" prompt — never by defaulting to Spanish.
    var targetLang: String? {
        defaults?.string(forKey: targetLangKey)
    }

    /// Non-optional version — returns the target language or "en" as a safe neutral fallback.
    /// Use this ONLY when you absolutely need a non-optional value (e.g., API calls that can't skip).
    /// Prefer targetLang (optional) and handle the nil case explicitly.
    var targetLangRequired: String {
        defaults?.string(forKey: targetLangKey) ?? nativeLang
    }

    /// Set the target language. Called from onboarding + settings.
    func setTargetLang(_ code: String) {
        defaults?.set(code, forKey: targetLangKey)
        defaults?.synchronize()
        NSLog("🌍 LanguageManager: target language set to \(code)")
    }

    // MARK: - Native Language

    /// The user's native language (defaults to English).
    var nativeLang: String {
        defaults?.string(forKey: nativeLangKey) ?? "en"
    }

    /// Set the native language. Called from onboarding + settings.
    func setNativeLang(_ code: String) {
        defaults?.set(code, forKey: nativeLangKey)
        defaults?.synchronize()
        NSLog("🌍 LanguageManager: native language set to \(code)")
    }

    // MARK: - Validation

    /// True if the user has selected a target language (onboarding completed language step).
    var hasTargetLanguage: Bool {
        targetLang != nil
    }

    /// The target language's display name (e.g., "Portuguese", "Hindi").
    var targetLangName: String? {
        guard let code = targetLang else { return nil }
        return Self.languageName(for: code)
    }

    /// The target language's flag emoji.
    var targetLangFlag: String? {
        guard let code = targetLang else { return nil }
        return Self.flagEmoji(for: code)
    }

    // MARK: - Language Metadata

    static func languageName(for code: String) -> String {
        let map: [String: String] = [
            "en": "English", "es": "Spanish", "pt": "Portuguese", "fr": "French",
            "de": "German", "it": "Italian", "ja": "Japanese", "ko": "Korean",
            "ar": "Arabic", "zh": "Chinese", "ru": "Russian", "nl": "Dutch",
            "pl": "Polish", "tr": "Turkish", "uk": "Ukrainian", "cs": "Czech",
            "ro": "Romanian", "bg": "Bulgarian", "el": "Greek", "sv": "Swedish",
            "da": "Danish", "no": "Norwegian", "fi": "Finnish", "hu": "Hungarian",
            "sk": "Slovak", "id": "Indonesian", "vi": "Vietnamese", "he": "Hebrew",
            "hr": "Croatian", "hi": "Hindi", "bn": "Bengali", "ur": "Urdu",
            "sw": "Swahili", "th": "Thai", "fa": "Persian", "ms": "Malay",
            "tl": "Filipino", "af": "Afrikaans", "ta": "Tamil", "ca": "Catalan",
        ]
        return map[code] ?? code.uppercased()
    }

    static func flagEmoji(for code: String) -> String {
        let map: [String: String] = [
            "en": "🇺🇸", "es": "🇪🇸", "pt": "🇧🇷", "fr": "🇫🇷",
            "de": "🇩🇪", "it": "🇮🇹", "ja": "🇯🇵", "ko": "🇰🇷",
            "ar": "🇦🇪", "zh": "🇨🇳", "ru": "🇷🇺", "nl": "🇳🇱",
            "pl": "🇵🇱", "tr": "🇹🇷", "uk": "🇺🇦", "cs": "🇨🇿",
            "ro": "🇷🇴", "bg": "🇧🇬", "el": "🇬🇷", "sv": "🇸🇪",
            "da": "🇩🇰", "no": "🇳🇴", "fi": "🇫🇮", "hu": "🇭🇺",
            "sk": "🇸🇰", "id": "🇮🇩", "vi": "🇻🇳", "he": "🇮🇱",
            "hr": "🇭🇷", "hi": "🇮🇳", "bn": "🇧🇩", "ur": "🇵🇰",
            "sw": "🇰🇪", "th": "🇹🇭", "fa": "🇮🇷", "ms": "🇲🇾",
            "tl": "🇵🇭", "af": "🇿🇦", "ta": "🇮🇳", "ca": "🇪🇸",
        ]
        return map[code] ?? "🌐"
    }

    /// TTS locale code (e.g., "pt-BR", "hi-IN") for Google Neural2 / Apple TTS.
    static func ttsLocale(for code: String) -> String {
        let map: [String: String] = [
            "en": "en-US", "es": "es-MX", "pt": "pt-BR", "fr": "fr-FR",
            "de": "de-DE", "it": "it-IT", "ja": "ja-JP", "ko": "ko-KR",
            "ar": "ar-XA", "zh": "cmn-CN", "ru": "ru-RU", "nl": "nl-NL",
            "pl": "pl-PL", "tr": "tr-TR", "uk": "uk-UA", "sv": "sv-SE",
            "da": "da-DK", "no": "nb-NO", "fi": "fi-FI", "hi": "hi-IN",
            "id": "id-ID", "vi": "vi-VN", "he": "he-IL", "th": "th-TH",
            "cs": "cs-CZ", "ro": "ro-RO", "bg": "bg-BG", "el": "el-GR",
            "hu": "hu-HU", "sk": "sk-SK", "hr": "hr-HR", "bn": "bn-IN",
            "ur": "ur-PK", "sw": "sw-KE", "fa": "fa-IR", "ms": "ms-MY",
            "tl": "fil-PH", "af": "af-ZA", "ta": "ta-IN", "ca": "ca-ES",
        ]
        return map[code] ?? "\(code)-\(code.uppercased())"
    }
}
