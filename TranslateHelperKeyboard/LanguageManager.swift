//
//  LanguageManager.swift
//  TranslateHelperKeyboard
//
//  Keyboard extension copy — mirrors TranslateHelper/LanguageManager.swift.
//  Both read from the same App Group keys.
//  Contains the SupportedLanguage enum for type safety.
//

import Foundation

// MARK: - Supported Language Enum

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
    // Tier 2 — GPT-only
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

    var code: String { rawValue }

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

    // MARK: - Typed Access

    var target: SupportedLanguage? {
        guard let code = defaults?.string(forKey: targetLangKey) else { return nil }
        return SupportedLanguage(rawValue: code)
    }

    var targetRequired: SupportedLanguage {
        target ?? nativeLanguage
    }

    var nativeLanguage: SupportedLanguage {
        guard let code = defaults?.string(forKey: nativeLangKey) else { return .english }
        return SupportedLanguage(rawValue: code) ?? .english
    }

    // MARK: - String Access (backward compatible)

    var targetLang: String? {
        defaults?.string(forKey: targetLangKey)
    }

    var targetLangRequired: String {
        defaults?.string(forKey: targetLangKey) ?? nativeLang
    }

    var nativeLang: String {
        defaults?.string(forKey: nativeLangKey) ?? "en"
    }

    var hasTargetLanguage: Bool {
        targetLang != nil
    }
}
