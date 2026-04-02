//
//  LanguageManager.swift
//  TranslateHelper
//
//  Single source of truth for the user's target language.
//  Every file reads from here — never directly from UserDefaults.
//  Uses SupportedLanguage enum internally for type safety.
//

import Foundation

// MARK: - Supported Language Enum

/// All 39 languages Orbit supports. The raw value is the ISO 639-1 code
/// stored in App Group UserDefaults — this is the string that crosses
/// the boundary between main app, keyboard extension, and storage.
enum SupportedLanguage: String, CaseIterable, Codable {
    // Tier 1 — DeepL supported
    case english    = "en"
    case spanish    = "es"
    case portuguese = "pt"
    case french     = "fr"
    case german     = "de"
    case italian    = "it"
    case japanese   = "ja"
    case korean     = "ko"
    case arabic     = "ar"
    case chinese    = "zh"
    case russian    = "ru"
    case dutch      = "nl"
    case polish     = "pl"
    case turkish    = "tr"
    case ukrainian  = "uk"
    case czech      = "cs"
    case romanian   = "ro"
    case bulgarian  = "bg"
    case greek      = "el"
    case swedish    = "sv"
    case danish     = "da"
    case norwegian  = "no"
    case finnish    = "fi"
    case hungarian  = "hu"
    case slovak     = "sk"
    case indonesian = "id"
    case vietnamese = "vi"
    case hebrew     = "he"
    case croatian   = "hr"
    // Tier 2 — GPT-only (DeepL not supported)
    case hindi      = "hi"
    case bengali    = "bn"
    case urdu       = "ur"
    case swahili    = "sw"
    case thai       = "th"
    case persian    = "fa"
    case malay      = "ms"
    case filipino   = "tl"
    case afrikaans  = "af"
    case tamil      = "ta"
    case catalan    = "ca"

    /// ISO code (same as rawValue, for clarity)
    var code: String { rawValue }

    /// Human-readable display name
    var displayName: String {
        switch self {
        case .english:    return "English"
        case .spanish:    return "Spanish"
        case .portuguese: return "Portuguese"
        case .french:     return "French"
        case .german:     return "German"
        case .italian:    return "Italian"
        case .japanese:   return "Japanese"
        case .korean:     return "Korean"
        case .arabic:     return "Arabic"
        case .chinese:    return "Chinese"
        case .russian:    return "Russian"
        case .dutch:      return "Dutch"
        case .polish:     return "Polish"
        case .turkish:    return "Turkish"
        case .ukrainian:  return "Ukrainian"
        case .czech:      return "Czech"
        case .romanian:   return "Romanian"
        case .bulgarian:  return "Bulgarian"
        case .greek:      return "Greek"
        case .swedish:    return "Swedish"
        case .danish:     return "Danish"
        case .norwegian:  return "Norwegian"
        case .finnish:    return "Finnish"
        case .hungarian:  return "Hungarian"
        case .slovak:     return "Slovak"
        case .indonesian: return "Indonesian"
        case .vietnamese: return "Vietnamese"
        case .hebrew:     return "Hebrew"
        case .croatian:   return "Croatian"
        case .hindi:      return "Hindi"
        case .bengali:    return "Bengali"
        case .urdu:       return "Urdu"
        case .swahili:    return "Swahili"
        case .thai:       return "Thai"
        case .persian:    return "Persian"
        case .malay:      return "Malay"
        case .filipino:   return "Filipino"
        case .afrikaans:  return "Afrikaans"
        case .tamil:      return "Tamil"
        case .catalan:    return "Catalan"
        }
    }

    /// Flag emoji
    var flag: String {
        switch self {
        case .english:    return "🇺🇸"
        case .spanish:    return "🇪🇸"
        case .portuguese: return "🇧🇷"
        case .french:     return "🇫🇷"
        case .german:     return "🇩🇪"
        case .italian:    return "🇮🇹"
        case .japanese:   return "🇯🇵"
        case .korean:     return "🇰🇷"
        case .arabic:     return "🇦🇪"
        case .chinese:    return "🇨🇳"
        case .russian:    return "🇷🇺"
        case .dutch:      return "🇳🇱"
        case .polish:     return "🇵🇱"
        case .turkish:    return "🇹🇷"
        case .ukrainian:  return "🇺🇦"
        case .czech:      return "🇨🇿"
        case .romanian:   return "🇷🇴"
        case .bulgarian:  return "🇧🇬"
        case .greek:      return "🇬🇷"
        case .swedish:    return "🇸🇪"
        case .danish:     return "🇩🇰"
        case .norwegian:  return "🇳🇴"
        case .finnish:    return "🇫🇮"
        case .hungarian:  return "🇭🇺"
        case .slovak:     return "🇸🇰"
        case .indonesian: return "🇮🇩"
        case .vietnamese: return "🇻🇳"
        case .hebrew:     return "🇮🇱"
        case .croatian:   return "🇭🇷"
        case .hindi:      return "🇮🇳"
        case .bengali:    return "🇧🇩"
        case .urdu:       return "🇵🇰"
        case .swahili:    return "🇰🇪"
        case .thai:       return "🇹🇭"
        case .persian:    return "🇮🇷"
        case .malay:      return "🇲🇾"
        case .filipino:   return "🇵🇭"
        case .afrikaans:  return "🇿🇦"
        case .tamil:      return "🇮🇳"
        case .catalan:    return "🇪🇸"
        }
    }

    /// TTS locale code for Google Neural2 / Apple TTS
    var ttsLocale: String {
        switch self {
        case .english:    return "en-US"
        case .spanish:    return "es-MX"
        case .portuguese: return "pt-BR"
        case .french:     return "fr-FR"
        case .german:     return "de-DE"
        case .italian:    return "it-IT"
        case .japanese:   return "ja-JP"
        case .korean:     return "ko-KR"
        case .arabic:     return "ar-XA"
        case .chinese:    return "cmn-CN"
        case .russian:    return "ru-RU"
        case .dutch:      return "nl-NL"
        case .polish:     return "pl-PL"
        case .turkish:    return "tr-TR"
        case .ukrainian:  return "uk-UA"
        case .swedish:    return "sv-SE"
        case .danish:     return "da-DK"
        case .norwegian:  return "nb-NO"
        case .finnish:    return "fi-FI"
        case .hungarian:  return "hu-HU"
        case .slovak:     return "sk-SK"
        case .czech:      return "cs-CZ"
        case .romanian:   return "ro-RO"
        case .bulgarian:  return "bg-BG"
        case .greek:      return "el-GR"
        case .indonesian: return "id-ID"
        case .vietnamese: return "vi-VN"
        case .hebrew:     return "he-IL"
        case .croatian:   return "hr-HR"
        case .hindi:      return "hi-IN"
        case .bengali:    return "bn-IN"
        case .urdu:       return "ur-PK"
        case .swahili:    return "sw-KE"
        case .thai:       return "th-TH"
        case .persian:    return "fa-IR"
        case .malay:      return "ms-MY"
        case .filipino:   return "fil-PH"
        case .afrikaans:  return "af-ZA"
        case .tamil:      return "ta-IN"
        case .catalan:    return "ca-ES"
        }
    }

    /// Whether this language requires GPT-only translation (not supported by DeepL)
    var isGPTOnly: Bool {
        switch self {
        case .hindi, .bengali, .urdu, .swahili, .thai, .persian,
             .malay, .filipino, .afrikaans, .tamil, .catalan:
            return true
        default:
            return false
        }
    }
}

// MARK: - Language Manager

final class LanguageManager {
    static let shared = LanguageManager()

    private let appGroupID = "group.com.jeff.translatehelper"
    private let targetLangKey = "talkswitch_target_lang"
    private let nativeLangKey = "talkswitch_native_lang"

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    // MARK: - Target Language (Typed)

    /// The user's target language as a typed enum. Nil if not set.
    var target: SupportedLanguage? {
        guard let code = defaults?.string(forKey: targetLangKey) else { return nil }
        return SupportedLanguage(rawValue: code)
    }

    /// Non-optional typed version. Falls back to .english if not set.
    var targetRequired: SupportedLanguage {
        target ?? nativeLanguage
    }

    // MARK: - Target Language (String — backward compatible)

    /// String code for the target language. Nil if not set.
    var targetLang: String? {
        defaults?.string(forKey: targetLangKey)
    }

    /// Non-optional string code. Use when you need a String for API calls.
    var targetLangRequired: String {
        defaults?.string(forKey: targetLangKey) ?? nativeLang
    }

    /// Set the target language from a string code.
    func setTargetLang(_ code: String) {
        defaults?.set(code, forKey: targetLangKey)
        defaults?.synchronize()
        NSLog("🌍 LanguageManager: target language set to \(code)")
    }

    /// Set the target language from an enum value.
    func setTarget(_ language: SupportedLanguage) {
        setTargetLang(language.rawValue)
    }

    // MARK: - Native Language

    /// The user's native language as enum (defaults to English).
    var nativeLanguage: SupportedLanguage {
        guard let code = defaults?.string(forKey: nativeLangKey) else { return .english }
        return SupportedLanguage(rawValue: code) ?? .english
    }

    /// The user's native language as string code.
    var nativeLang: String {
        defaults?.string(forKey: nativeLangKey) ?? "en"
    }

    /// Set the native language.
    func setNativeLang(_ code: String) {
        defaults?.set(code, forKey: nativeLangKey)
        defaults?.synchronize()
        NSLog("🌍 LanguageManager: native language set to \(code)")
    }

    // MARK: - Validation

    var hasTargetLanguage: Bool {
        targetLang != nil
    }

    /// The target language's display name.
    var targetLangName: String? {
        target?.displayName
    }

    /// The target language's flag emoji.
    var targetLangFlag: String? {
        target?.flag
    }

    // MARK: - Static Helpers (String-based, for backward compatibility)

    static func languageName(for code: String) -> String {
        SupportedLanguage(rawValue: code)?.displayName ?? code.uppercased()
    }

    static func flagEmoji(for code: String) -> String {
        SupportedLanguage(rawValue: code)?.flag ?? "🌐"
    }

    static func ttsLocale(for code: String) -> String {
        SupportedLanguage(rawValue: code)?.ttsLocale ?? "\(code)-\(code.uppercased())"
    }
}
