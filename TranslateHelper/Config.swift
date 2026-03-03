//
//  Config.swift
//  TranslateHelper
//
//  API keys and base URLs for the main app target.
//  Keep this file in the TranslateHelper group so DeckGenerationService
//  and any future main-app services can reference APIConfig.
//
//  The keyboard extension has its own copy at
//  TranslateHelperKeyboard/Config.swift — update both when rotating keys.
//

import Foundation

enum APIConfig {
    // DeepL API Configuration
    static let deeplAPIKey  = "4a976929-2bc0-4009-b401-d397a3c5c730:fx"
    static let deeplBaseURL = "https://api-free.deepl.com/v2"

    // OpenAI API Configuration
    static let openAIAPIKey  = "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"
    static let openAIBaseURL = "https://api.openai.com/v1"
}
