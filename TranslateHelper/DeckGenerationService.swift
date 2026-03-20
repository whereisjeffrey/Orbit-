//
//  DeckGenerationService.swift
//  TranslateHelper
//
//  Calls GPT-4o-mini to generate personalised flashcard decks.
//  Currently used for the Flirting & Banter deck, which tailors grammatical gender
//  based on the user's conversation preferences set in FlirtyContextSheet.
//
//  Architecture note: commonly-generated decks will be cached in Firestore
//  `featured_decks` so repeat users get instant results instead of an API call.
//

import Foundation

// MARK: - Generated Card Model

struct GeneratedCard: Identifiable, Codable {
    let id: String
    let sourceText: String      // English
    let translatedText: String  // Spanish
    let notes: String           // Coaching note (pronunciation, usage, context)

    init(id: String = UUID().uuidString, sourceText: String, translatedText: String, notes: String) {
        self.id = id
        self.sourceText = sourceText
        self.translatedText = translatedText
        self.notes = notes
    }
}

// MARK: - Service

final class DeckGenerationService {
    static let shared = DeckGenerationService()
    private init() {}

    private let appGroup = "group.com.jeff.translatehelper"

    // Keys are stored in App Group so both targets can use them.
    // Falls back to the hardcoded key from Config.swift if not overridden.
    private var openAIAPIKey: String {
        UserDefaults(suiteName: appGroup)?.string(forKey: "talkswitch_openai_key")
            ?? "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"
    }
    private let openAIBaseURL = "https://api.openai.com/v1"

    // MARK: - Flirting Deck

    /// Generates ~25 Spanish–English flirting flashcards personalised to the user's
    /// speaker form and target gender preferences.
    func generateFlirtingDeck(speakerForm: SpeakerForm, targetGender: TargetGender) async throws -> [GeneratedCard] {
        let prompt = buildFlirtingPrompt(speakerForm: speakerForm, targetGender: targetGender)
        let raw = try await callOpenAI(systemPrompt: prompt.system, userPrompt: prompt.user)
        return try parseCards(from: raw)
    }

    // MARK: - Starter Deck Generation (language-aware)

    /// Generates one of the 3 universal starter decks for any target language.
    /// Returns `[DeckCard]` ready to drop straight into DeckStore.
    func generateStarterDeck(type deckType: StarterDeckType,
                             targetLanguage: String,
                             languageCode: String = "es") async throws -> [DeckCard] {
        let raw = try await callOpenAI(
            systemPrompt: deckType.systemPrompt
                .replacingOccurrences(of: "TARGET LANGUAGE", with: targetLanguage),
            userPrompt: deckType.userPrompt(forLanguage: targetLanguage)
        )
        let cards = try parseCards(from: raw)
        return cards.map { c in
            DeckCard(
                english: c.sourceText,
                spanish: c.translatedText,  // stores target-language text regardless of language
                notes: c.notes,
                targetLang: languageCode    // e.g. "zh", "fr", "ja"…
            )
        }
    }

    // MARK: - Generic AI Deck

    /// Generates a deck from a free-form name + description (Create Deck flow).
    func generateCustomDeck(name: String, description: String, cardCount: Int = 25) async throws -> [GeneratedCard] {
        let count = min(max(cardCount, 5), DeckStore.maxCardsPerDeck) // clamp 5–100
        let system = """
        You are a Spanish–English language learning expert. \
        Generate exactly \(count) flashcard pairs based on the user's deck topic. \
        Each card should be a natural, useful phrase or word pair — not overly academic. \
        Return ONLY valid JSON as an array: \
        [{"sourceText": "English phrase", "translatedText": "Spanish phrase", "notes": "brief usage note"}, ...]\
        Do not include any text outside the JSON array.
        """
        let user = """
        Deck topic: \(name)
        Additional context: \(description.isEmpty ? "None provided." : description)
        Generate \(count) Spanish–English flashcard pairs for this topic.
        """
        let raw = try await callOpenAI(systemPrompt: system, userPrompt: user)
        return try parseCards(from: raw)
    }

    // MARK: - Prompt Builder

    private struct Prompt { let system: String; let user: String }

    private func buildFlirtingPrompt(speakerForm: SpeakerForm, targetGender: TargetGender) -> Prompt {

        let speakerInstruction: String
        switch speakerForm {
        case .masculine: speakerInstruction = "The speaker uses masculine grammatical forms when describing themselves (e.g. 'enamorado', 'contento')."
        case .feminine:  speakerInstruction = "The speaker uses feminine grammatical forms when describing themselves (e.g. 'enamorada', 'contenta')."
        case .both:      speakerInstruction = "Include both masculine and feminine forms for the speaker in the 'notes' field."
        }

        let targetInstruction: String
        switch targetGender {
        case .male:   targetInstruction = "They are speaking TO a man — use masculine address forms (e.g. 'eres hermoso', 'mi rey')."
        case .female: targetInstruction = "They are speaking TO a woman — use feminine address forms (e.g. 'eres hermosa', 'mi reina')."
        case .varies: targetInstruction = "The target varies in gender. Favour gender-neutral phrases where possible, or note the male/female variants in the 'notes' field."
        }

        let system = """
        You are a bilingual flirting and romance language expert (Spanish ↔ English). \
        Generate 25 natural, confident flirting flashcards. \
        \(speakerInstruction) \
        \(targetInstruction) \
        Focus on: opening lines, playful banter, genuine compliments, and expressive romantic phrases. \
        These should sound like what real people in Mexico City or Latin America actually say — \
        NOT formal textbook Spanish. Include a mix of: casual/playful (40%), sweet/romantic (35%), \
        bold/confident (25%). \
        Return ONLY valid JSON as an array: \
        [{"sourceText": "English phrase", "translatedText": "Spanish phrase", "notes": "brief note with pronunciation tip or usage context"}, ...]
        Do not include any text outside the JSON array.
        """

        let user = "Generate 25 flirting & romance flashcard pairs in Spanish ↔ English."

        return Prompt(system: system, user: user)
    }

    // MARK: - OpenAI Call

    private func callOpenAI(systemPrompt: String, userPrompt: String) async throws -> String {
        guard let url = URL(string: "\(openAIBaseURL)/chat/completions") else {
            throw GenerationError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user",   "content": userPrompt]
            ],
            "temperature": 0.8,
            "max_tokens": 4000
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw GenerationError.apiError("Non-200 response from OpenAI")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw GenerationError.parsingFailed("Could not extract content from response")
        }

        return content
    }

    // MARK: - Response Parser

    private func parseCards(from raw: String) throws -> [GeneratedCard] {
        // Strip markdown code fences if model included them
        var cleaned = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("```") {
            cleaned = cleaned
                .components(separatedBy: "\n")
                .dropFirst()
                .dropLast()
                .joined(separator: "\n")
        }

        guard let data = cleaned.data(using: .utf8) else {
            throw GenerationError.parsingFailed("Could not encode response as UTF-8")
        }

        let decoded = try JSONDecoder().decode([GeneratedCardDTO].self, from: data)
        return decoded.map {
            GeneratedCard(sourceText: $0.sourceText, translatedText: $0.translatedText, notes: $0.notes)
        }
    }
}

// MARK: - DTO

private struct GeneratedCardDTO: Decodable {
    let sourceText: String
    let translatedText: String
    let notes: String
}

// MARK: - Errors

enum GenerationError: LocalizedError {
    case badURL
    case apiError(String)
    case parsingFailed(String)

    var errorDescription: String? {
        switch self {
        case .badURL:               return "Invalid API URL"
        case .apiError(let msg):    return "API error: \(msg)"
        case .parsingFailed(let m): return "Could not read AI response: \(m)"
        }
    }
}
