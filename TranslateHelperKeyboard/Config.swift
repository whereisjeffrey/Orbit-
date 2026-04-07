import Foundation

enum APIConfig {
    // DeepL API Configuration
    static let deeplAPIKey = SecretKeys.deepl
    static let deeplBaseURL = "https://api-free.deepl.com/v2"

    // OpenAI API Configuration
    static let openAIAPIKey = SecretKeys.openAI
    static let openAIBaseURL = "https://api.openai.com/v1"

    // Google Cloud Text-to-Speech (WaveNet)
    static let googleTTSAPIKey = SecretKeys.googleTTS
    static let googleTTSBaseURL = "https://texttospeech.googleapis.com/v1"
}
