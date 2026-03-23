//
//  LightningRoundEngine.swift
//  TranslateHelper
//
//  Generates Lightning Round cards from the user's mistake profile.
//  10 card types, SRS-aware selection, never the same pattern twice in a row.
//

import Foundation

// MARK: - Card Types

enum LightningCardType: String, Codable, CaseIterable {
    case speakIt            // Say a sentence containing their mistake pattern (voice)
    case echo               // Listen to native audio, repeat it back (voice)
    case speedConjugation   // Pick the correct verb form (tap, 4 options)
    case whatDidSheSay      // Listen to audio, pick what was said (listen + tap)
    case minimalPairs       // Two similar sounds, pick the right one (listen + tap)
    case quickPick          // Multiple choice on grammar pattern (tap, 4 options)
    case trueOrFalse        // Is this sentence correct? (tap, 2 options)
    case thisOrThat         // Binary choice: a/o, ser/estar, etc. (tap, 2 options)
    case slangInContext     // Slang in a sentence, pick the meaning (tap, 3 options)
    case contextualResponse // Pick the most natural reply (tap, 3 options)

    var isVoiceCard: Bool {
        self == .speakIt || self == .echo
    }

    var isListenCard: Bool {
        self == .whatDidSheSay || self == .minimalPairs || self == .echo
    }

    var displayName: String {
        switch self {
        case .speakIt:            return "Speak It"
        case .echo:               return "Echo"
        case .speedConjugation:   return "Speed Conjugation"
        case .whatDidSheSay:      return "What Did She Say?"
        case .minimalPairs:       return "Minimal Pairs"
        case .quickPick:          return "Quick Pick"
        case .trueOrFalse:        return "True or False"
        case .thisOrThat:         return "This or That"
        case .slangInContext:     return "Slang in Context"
        case .contextualResponse: return "What Would You Say?"
        }
    }

    /// Approximate seconds this card takes
    var estimatedSeconds: Int {
        switch self {
        case .thisOrThat, .trueOrFalse:       return 4
        case .quickPick, .speedConjugation:   return 5
        case .slangInContext, .contextualResponse: return 6
        case .whatDidSheSay, .minimalPairs:    return 7
        case .echo:                           return 9
        case .speakIt:                        return 11
        }
    }
}

// MARK: - Lightning Card

struct LightningCard: Identifiable, Codable {
    let id: UUID
    let type: LightningCardType
    let mistakeId: UUID?          // Links back to MistakeEntry (nil for general cards)
    let language: String

    // Content (populated by GPT or engine)
    let prompt: String            // What the user sees/hears as the question
    let correctAnswer: String     // The right answer
    let options: [String]?        // For tap cards — 2-4 options (includes correct)
    let explanation: String       // Shown when wrong — lightbulb text
    let audioText: String?        // Text to speak via TTS (for listen/echo cards)

    // For Speak It: the sentence containing the target pattern
    let targetWord: String?       // The specific word/pattern being tested within the sentence

    // Result (filled after user responds)
    var userAnswer: String?
    var isCorrect: Bool?
    var answeredAt: Date?

    init(
        type: LightningCardType,
        mistakeId: UUID? = nil,
        language: String,
        prompt: String,
        correctAnswer: String,
        options: [String]? = nil,
        explanation: String,
        audioText: String? = nil,
        targetWord: String? = nil
    ) {
        self.id = UUID()
        self.type = type
        self.mistakeId = mistakeId
        self.language = language
        self.prompt = prompt
        self.correctAnswer = correctAnswer
        self.options = options
        self.explanation = explanation
        self.audioText = audioText
        self.targetWord = targetWord
        self.userAnswer = nil
        self.isCorrect = nil
        self.answeredAt = nil
    }
}

// MARK: - Round Result

struct LightningRoundResult: Codable {
    let date: Date
    let totalCards: Int
    let correctCount: Int
    let cardResults: [CardResult]
    let durationSeconds: Int

    var scorePercent: Int {
        guard totalCards > 0 else { return 0 }
        return Int(Double(correctCount) / Double(totalCards) * 100)
    }

    struct CardResult: Codable {
        let cardType: LightningCardType
        let mistakeId: UUID?
        let isCorrect: Bool
    }
}

// MARK: - Round Engine

final class LightningRoundEngine {
    static let shared = LightningRoundEngine()

    private let profile = MistakeProfileStore.shared

    /// Number of cards per round
    static let cardsPerRound = 6

    /// Maximum voice cards per round (mic latency budget)
    static let maxVoiceCards = 2

    /// Maximum listen cards per round
    static let maxListenCards = 1

    // MARK: - Build a Round

    /// Selects card types for a round, ensuring variety and no back-to-back same type.
    func buildRoundCardTypes() -> [LightningCardType] {
        var selected: [LightningCardType] = []
        var voiceCount = 0
        var listenCount = 0
        var usedTypes: Set<LightningCardType> = []

        // Pool of available types
        let allTypes = LightningCardType.allCases

        // Guarantee at least 1 voice card if we have pronunciation mistakes
        let hasPronunciationMistakes = !profile.active(category: .pronunciation).isEmpty
        if hasPronunciationMistakes {
            let voiceType: LightningCardType = Bool.random() ? .speakIt : .echo
            selected.append(voiceType)
            voiceCount += 1
            usedTypes.insert(voiceType)
        }

        // Fill remaining slots
        while selected.count < Self.cardsPerRound {
            // Filter to types we haven't used (allow reuse only if we've used all types)
            var candidates = allTypes.filter { type in
                // Don't exceed voice/listen caps
                if type.isVoiceCard && voiceCount >= Self.maxVoiceCards { return false }
                if type.isListenCard && listenCount >= Self.maxListenCards { return false }
                // Don't repeat the same type as the last card
                if let last = selected.last, last == type { return false }
                // Prefer diversity — skip if already used (unless we need to reuse)
                if usedTypes.count < allTypes.count && usedTypes.contains(type) { return false }
                return true
            }

            // If no candidates (all types used), relax the uniqueness constraint
            if candidates.isEmpty {
                candidates = allTypes.filter { type in
                    if type.isVoiceCard && voiceCount >= Self.maxVoiceCards { return false }
                    if type.isListenCard && listenCount >= Self.maxListenCards { return false }
                    if let last = selected.last, last == type { return false }
                    return true
                }
            }

            guard let pick = candidates.randomElement() else { break }
            selected.append(pick)
            usedTypes.insert(pick)
            if pick.isVoiceCard { voiceCount += 1 }
            if pick.isListenCard { listenCount += 1 }
        }

        // Shuffle to avoid predictable patterns, but keep voice cards spaced out
        return spaceOutVoiceCards(selected)
    }

    /// Selects mistake entries to test, prioritizing SRS-due items.
    func selectMistakesForRound(count: Int, language: String) -> [MistakeEntry] {
        let due = profile.dueForReview.filter { $0.language == language }
        let active = profile.active(language: language)

        var selected: [MistakeEntry] = []

        // Priority 1: SRS-due mistakes
        for entry in due where selected.count < count {
            selected.append(entry)
        }

        // Priority 2: Fill with active but not-yet-due mistakes (random)
        let remaining = active.filter { entry in
            !selected.contains(where: { $0.id == entry.id })
        }.shuffled()

        for entry in remaining where selected.count < count {
            selected.append(entry)
        }

        return selected
    }

    /// Generates the GPT prompt to create Lightning Round cards from mistake entries.
    func generateCardsPrompt(
        cardTypes: [LightningCardType],
        mistakes: [MistakeEntry],
        language: String
    ) -> String {
        let langName = languageName(for: language)
        let transferBlock = TransferPatterns.patterns(for: language)

        var mistakeDescriptions = ""
        for (i, m) in mistakes.enumerated() {
            mistakeDescriptions += """
            Mistake \(i + 1):
              Category: \(m.category.rawValue)
              User said: "\(m.userSaid)"
              Correct: "\(m.correctForm)"
              Explanation: \(m.explanation)
              Times seen: \(m.seenCount)

            """
        }

        var cardInstructions = ""
        for (i, type) in cardTypes.enumerated() {
            cardInstructions += "Card \(i + 1): type=\"\(type.rawValue)\", test mistake \(min(i, mistakes.count - 1) + 1)\n"

            switch type {
            case .speakIt:
                cardInstructions += "  → Create a natural sentence in English that the user must say in \(langName). The sentence MUST require the grammar pattern from the mistake. Include the target word/pattern.\n"
            case .echo:
                cardInstructions += "  → Create a natural \(langName) sentence containing the word/pattern from the mistake. The user will hear it and repeat.\n"
            case .speedConjugation:
                cardInstructions += "  → Create a verb conjugation question with 4 options. One correct, three plausible wrong forms.\n"
            case .whatDidSheSay:
                cardInstructions += "  → Create a \(langName) sentence to be spoken aloud. Provide 4 written options (1 correct, 3 similar but wrong).\n"
            case .minimalPairs:
                cardInstructions += "  → Pick two similar-sounding \(langName) words. Give a meaning and ask which word matches.\n"
            case .quickPick:
                cardInstructions += "  → Create a fill-in-the-blank or grammar question with 4 options.\n"
            case .trueOrFalse:
                cardInstructions += "  → Create a \(langName) sentence that is either correct or has exactly one mistake. Ask if it's correct.\n"
            case .thisOrThat:
                cardInstructions += "  → Create a binary choice question (e.g., a/o, ser/estar, por/para). The two options must test the specific mistake pattern.\n"
            case .slangInContext:
                cardInstructions += "  → Create a short dialogue with a slang expression. Ask what the slang means with 3 options.\n"
            case .contextualResponse:
                cardInstructions += "  → Create a 2-line conversation. Ask which of 3 responses is most natural.\n"
            }
        }

        return """
        Generate \(cardTypes.count) Lightning Round quiz cards for a \(langName) learner (English native speaker).

        The cards test REAL mistakes this user has made. Here are their recent mistakes:

        \(mistakeDescriptions)

        \(transferBlock)

        Generate these cards:
        \(cardInstructions)

        RULES:
        - All prompts and explanations in English, with \(langName) words inline where relevant
        - Wrong options must be PLAUSIBLE — things an English speaker would actually pick
        - Explanations should be 1 sentence max, warm and helpful, not condescending
        - For voice cards (speakIt, echo), include the full sentence as "audio_text"
        - For speakIt, the "target_word" is the specific word/pattern being tested
        - Options array: always include the correct answer, shuffled randomly among the options
        - Make each card feel different — vary sentence topics, don't repeat the same context

        Respond ONLY with valid JSON array:
        [
          {
            "type": "cardType",
            "prompt": "what the user sees",
            "correct_answer": "the right answer",
            "options": ["opt1", "opt2", "opt3", "opt4"] or null for voice cards,
            "explanation": "1-line explanation shown when wrong",
            "audio_text": "text to speak via TTS" or null,
            "target_word": "specific word tested" or null,
            "mistake_index": 0
          }
        ]
        """
    }

    // MARK: - Process Round Results

    /// Updates the mistake profile based on Lightning Round results.
    func processResults(_ cards: [LightningCard]) {
        for card in cards {
            guard let mistakeId = card.mistakeId, let correct = card.isCorrect else { continue }
            if correct {
                profile.markCorrect(id: mistakeId)
            } else {
                profile.markIncorrect(id: mistakeId)
            }
        }

        // Save round result
        let result = LightningRoundResult(
            date: Date(),
            totalCards: cards.count,
            correctCount: cards.filter { $0.isCorrect == true }.count,
            cardResults: cards.map {
                LightningRoundResult.CardResult(
                    cardType: $0.type,
                    mistakeId: $0.mistakeId,
                    isCorrect: $0.isCorrect ?? false
                )
            },
            durationSeconds: cards.map { $0.type.estimatedSeconds }.reduce(0, +)
        )
        saveRoundResult(result)
    }

    // MARK: - Round History

    private static let historyKey = "ts_lightning_round_history"

    private func saveRoundResult(_ result: LightningRoundResult) {
        guard let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper") else { return }
        var history = loadRoundHistory()
        history.append(result)
        // Keep last 50 rounds
        if history.count > 50 { history = Array(history.suffix(50)) }
        if let data = try? JSONEncoder().encode(history) {
            defaults.set(data, forKey: Self.historyKey)
        }
    }

    func loadRoundHistory() -> [LightningRoundResult] {
        guard let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper"),
              let data = defaults.data(forKey: Self.historyKey),
              let history = try? JSONDecoder().decode([LightningRoundResult].self, from: data)
        else { return [] }
        return history
    }

    // MARK: - Helpers

    private func spaceOutVoiceCards(_ cards: [LightningCardType]) -> [LightningCardType] {
        var voiceIndices: [Int] = []
        var tapIndices: [Int] = []
        for (i, card) in cards.enumerated() {
            if card.isVoiceCard { voiceIndices.append(i) } else { tapIndices.append(i) }
        }

        // If 2 voice cards, put them at positions ~1/3 and ~2/3 through the round
        guard voiceIndices.count >= 2 else { return cards.shuffled() }

        var result = cards
        let pos1 = 1  // Second card
        let pos2 = 4  // Fifth card (of 6)

        // Swap voice cards into spaced positions
        let v1 = voiceIndices[0]
        let v2 = voiceIndices[1]
        if v1 != pos1 {
            result.swapAt(v1, pos1)
        }
        // Recalculate v2 position after first swap
        let newV2 = result.firstIndex(where: { $0 == cards[v2] }) ?? v2
        if newV2 != pos2 {
            result.swapAt(newV2, pos2)
        }

        return result
    }

    private func languageName(for code: String) -> String {
        let map: [String: String] = [
            "es": "Spanish", "pt": "Portuguese", "fr": "French", "de": "German",
            "it": "Italian", "ja": "Japanese", "ko": "Korean", "zh": "Chinese",
            "ar": "Arabic", "nl": "Dutch", "ru": "Russian", "pl": "Polish",
        ]
        return map[code] ?? "Spanish"
    }
}
