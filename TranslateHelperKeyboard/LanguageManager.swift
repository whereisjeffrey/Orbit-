//
//  LanguageManager.swift
//  TranslateHelperKeyboard
//
//  Keyboard extension copy — single source of truth for language.
//  Mirrors TranslateHelper/LanguageManager.swift.
//  Both read from the same App Group keys.
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
    /// Returns nil if the user hasn't completed language selection.
    var targetLang: String? {
        defaults?.string(forKey: targetLangKey)
    }

    /// Non-optional — returns target language or native language as safe fallback.
    /// Use only when you absolutely need a non-optional value.
    var targetLangRequired: String {
        defaults?.string(forKey: targetLangKey) ?? nativeLang
    }

    // MARK: - Native Language

    /// The user's native language (defaults to English).
    var nativeLang: String {
        defaults?.string(forKey: nativeLangKey) ?? "en"
    }

    // MARK: - Validation

    var hasTargetLanguage: Bool {
        targetLang != nil
    }
}
