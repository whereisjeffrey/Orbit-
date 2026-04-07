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
    static let deeplAPIKey  = SecretKeys.deepl
    static let deeplBaseURL = "https://api-free.deepl.com/v2"

    // OpenAI API Configuration
    static let openAIAPIKey  = SecretKeys.openAI
    static let openAIBaseURL = "https://api.openai.com/v1"

    // Google Cloud Text-to-Speech (WaveNet)
    static let googleTTSAPIKey = SecretKeys.googleTTS
    static let googleTTSBaseURL = "https://texttospeech.googleapis.com/v1"

    // Anthropic (Claude) API
    static let anthropicAPIKey = SecretKeys.anthropic
    static let anthropicBaseURL = "https://api.anthropic.com/v1"

    // Google Gemini Flash — conversation pool seeding
    static let geminiAPIKey = SecretKeys.gemini
    static let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
}
