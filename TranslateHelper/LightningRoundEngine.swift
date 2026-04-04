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

    /// Thread-safe access to cached cards via a serial queue
    private let cacheQueue = DispatchQueue(label: "com.orbit.lightning.cache")
    private var _cachedCards: [LightningCard]?
    private var _isCaching = false

    /// Waiters — closures that get called when pre-gen completes
    private var preGenWaiters: [([LightningCard]) -> Void] = []

    var cachedCards: [LightningCard]? {
        get { cacheQueue.sync { _cachedCards } }
        set { cacheQueue.sync { _cachedCards = newValue } }
    }

    var isCaching: Bool {
        get { cacheQueue.sync { _isCaching } }
        set { cacheQueue.sync { _isCaching = newValue } }
    }

    /// Wait for an in-flight pre-gen to complete. If not caching, calls back immediately with nil.
    func waitForPreGen(completion: @escaping ([LightningCard]?) -> Void) {
        cacheQueue.sync {
            if let cards = _cachedCards, !cards.isEmpty {
                completion(cards)
            } else if _isCaching {
                // Pre-gen is in flight — add to waiters list
                preGenWaiters.append { cards in completion(cards) }
                NSLog("⚡ [LightningRound] waiting for in-flight pre-gen (\(preGenWaiters.count) waiters)")
            } else {
                completion(nil)
            }
        }
    }

    /// Notify all waiters that pre-gen completed
    private func notifyWaiters(cards: [LightningCard]) {
        let waiters: [([LightningCard]) -> Void] = cacheQueue.sync {
            let w = preGenWaiters
            preGenWaiters.removeAll()
            return w
        }
        for waiter in waiters {
            DispatchQueue.main.async { waiter(cards) }
        }
    }

    /// Disk cache key for persisting pre-generated rounds across app sessions
    private static let diskCacheKey = "lightning_round_cache"
    private static let diskCacheLangKey = "lightning_round_cache_lang"
    private static let appGroup = "group.com.jeff.translatehelper"

    /// Save pre-generated cards to disk (App Group) so they survive app close
    func saveCacheToDisk(_ cards: [LightningCard], language: String) {
        do {
            let data = try JSONEncoder().encode(cards)
            guard let defaults = UserDefaults(suiteName: Self.appGroup) else {
                NSLog("⚡ [LightningRound] ERROR: App Group unavailable — can't save to disk")
                return
            }
            defaults.set(data, forKey: Self.diskCacheKey)
            defaults.set(language, forKey: Self.diskCacheLangKey)
            defaults.synchronize()
            NSLog("⚡ [LightningRound] saved \(cards.count) cards to disk for \(language) (\(data.count) bytes)")
        } catch {
            NSLog("⚡ [LightningRound] ERROR: disk save failed — \(error.localizedDescription)")
        }
    }

    /// Load pre-generated cards from disk if they match the current language
    func loadCacheFromDisk(language: String) -> [LightningCard]? {
        guard let defaults = UserDefaults(suiteName: Self.appGroup),
              let cachedLang = defaults.string(forKey: Self.diskCacheLangKey),
              cachedLang == language,
              let data = defaults.data(forKey: Self.diskCacheKey),
              let cards = try? JSONDecoder().decode([LightningCard].self, from: data),
              !cards.isEmpty else { return nil }
        NSLog("⚡ [LightningRound] loaded \(cards.count) cards from disk for \(language)")
        return cards
    }

    /// Clear disk cache (after using it or when language changes)
    func clearDiskCache() {
        guard let defaults = UserDefaults(suiteName: Self.appGroup) else { return }
        defaults.removeObject(forKey: Self.diskCacheKey)
        defaults.removeObject(forKey: Self.diskCacheLangKey)
    }

    // MARK: - Card Validation

    /// Validates and cleans generated cards. Discards any card that:
    /// - Has an empty prompt or correct_answer
    /// - Is a tap card where correct_answer isn't in the options
    /// - Is a voice card with no audio_text
    /// - Contains gibberish (detected by NLLanguageRecognizer)
    func validateCards(_ cards: [LightningCard], language: String) -> [LightningCard] {
        return cards.compactMap { card in
            // 1. Must have a non-empty prompt and answer
            guard !card.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !card.correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                NSLog("⚡ [VALIDATION] Discarded card: empty prompt or answer")
                return nil
            }

            var fixed = card

            // 2. Voice cards: audio_text must exist and be a real sentence
            if card.type.isVoiceCard {
                if card.audioText == nil || card.audioText!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    fixed = LightningCard(
                        type: card.type, mistakeId: card.mistakeId, language: card.language,
                        prompt: card.prompt, correctAnswer: card.correctAnswer,
                        options: card.options, explanation: card.explanation,
                        audioText: card.correctAnswer, targetWord: card.targetWord
                    )
                }
                // Voice card audio_text must be at least 2 words
                let wordCount = (fixed.audioText ?? "").split(separator: " ").count
                if wordCount < 2 {
                    NSLog("⚡ [VALIDATION] Discarded voice card: audio_text too short (\(wordCount) words)")
                    return nil
                }
            }

            // 3. Clean options — remove dashes, blanks, duplicates
            if var options = fixed.options {
                options = options.filter { opt in
                    let trimmed = opt.trimmingCharacters(in: .whitespacesAndNewlines)
                    return trimmed.count >= 2 && trimmed != "-" && trimmed != "—" && trimmed != "–" && trimmed != "..."
                }
                // Remove duplicates (case-insensitive)
                var seen = Set<String>()
                options = options.filter { opt in
                    let key = opt.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if seen.contains(key) { return false }
                    seen.insert(key)
                    return true
                }
                fixed = LightningCard(
                    type: fixed.type, mistakeId: fixed.mistakeId, language: fixed.language,
                    prompt: fixed.prompt, correctAnswer: fixed.correctAnswer,
                    options: options, explanation: fixed.explanation,
                    audioText: fixed.audioText, targetWord: fixed.targetWord
                )
            }

            // 4. Tap cards: correct_answer must be in options
            if let options = fixed.options, !fixed.type.isVoiceCard {
                let normalizedAnswer = fixed.correctAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                let normalizedOptions = options.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
                if !normalizedOptions.contains(normalizedAnswer) {
                    NSLog("⚡ [VALIDATION] Discarded card: correct_answer '\(fixed.correctAnswer)' not in options \(options)")
                    return nil
                }
            }

            // 5. thisOrThat must have exactly 2 options
            if fixed.type == .thisOrThat {
                if let options = fixed.options, options.count != 2 {
                    NSLog("⚡ [VALIDATION] Discarded thisOrThat: expected 2 options, got \(options.count)")
                    return nil
                }
            }

            // 6. trueOrFalse answer must be True or False
            if fixed.type == .trueOrFalse {
                let validAnswers = ["true", "false", "verdadeiro", "falso", "vrai", "faux", "richtig", "falsch", "verdadero"]
                if !validAnswers.contains(fixed.correctAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)) {
                    NSLog("⚡ [VALIDATION] Discarded trueOrFalse: answer '\(fixed.correctAnswer)' is not True/False")
                    return nil
                }
            }

            // 7. Answer too short
            let answer = fixed.correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
            if answer.count < 2 && !["a", "o", "à", "é", "は", "의"].contains(answer) {
                NSLog("⚡ [VALIDATION] Discarded card: answer too short '\(answer)'")
                return nil
            }

            // 8. Tap cards must have at least 2 options
            if !fixed.type.isVoiceCard {
                if let options = fixed.options, options.count < 2 {
                    NSLog("⚡ [VALIDATION] Discarded card: fewer than 2 options")
                    return nil
                }
                if fixed.options == nil {
                    NSLog("⚡ [VALIDATION] Discarded tap card: no options array")
                    return nil
                }
            }

            return fixed
        }
    }

    /// Track recently used prompts to ensure variety across rounds (last 30 prompts)
    private var recentPrompts: [String] = []
    private let maxRecentPrompts = 30

    /// Record prompts from a completed round to avoid repetition
    func recordUsedPrompts(_ cards: [LightningCard]) {
        for card in cards {
            recentPrompts.append(card.prompt)
        }
        // Keep only the last N
        if recentPrompts.count > maxRecentPrompts {
            recentPrompts = Array(recentPrompts.suffix(maxRecentPrompts))
        }
    }

    /// Number of cards per round
    /// First round = 15 cards for calibration, subsequent rounds = 10
    static var cardsPerRound: Int {
        let hasCompletedRound = UserDefaults(suiteName: "group.com.jeff.translatehelper")?.bool(forKey: "ts_first_round_complete") ?? false
        return hasCompletedRound ? 10 : 15
    }

    /// Mark that the user has completed their first Lightning Round (calibration)
    static func markFirstRoundComplete() {
        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        defaults?.set(true, forKey: "ts_first_round_complete")
        defaults?.synchronize()
    }

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
    /// Unified prompt — works with OR without existing mistakes.
    /// If mistakes exist, generates cards targeting those mistakes.
    /// If no mistakes, generates common mistake cards for the user's level.
    func buildUnifiedPrompt(
        cardTypes: [LightningCardType],
        existingMistakes: [MistakeEntry],
        language: String,
        langName: String
    ) -> String {
        let store = UserLevelStore.shared
        let overallLevel = store.hasBeenAssessed ? store.overallLevel.rawValue : (SelfReportedLevel.saved?.initialCEFR.rawValue ?? "B1")
        let transferBlock = TransferPatterns.patterns(for: language)

        let mistakeBlock: String
        if !existingMistakes.isEmpty {
            var desc = "The cards should test REAL mistakes this user has made:\n\n"
            for (i, m) in existingMistakes.enumerated() {
                desc += "Mistake \(i+1): category=\(m.category.rawValue), said=\"\(m.userSaid)\", correct=\"\(m.correctForm)\"\n"
                if !m.usedSentences.isEmpty {
                    desc += "  DO NOT reuse: \(m.usedSentences.suffix(5).joined(separator: ", "))\n"
                }
            }
            mistakeBlock = desc
        } else {
            mistakeBlock = """
            The user has NO recorded mistakes yet. Generate cards testing COMMON mistakes \
            English speakers make when learning \(langName) at \(overallLevel) level. \
            Cover: gender, conjugation, prepositions, vocabulary (false friends), word order, idioms.
            """
        }

        var cardInstructions = ""
        for (i, type) in cardTypes.enumerated() {
            cardInstructions += "Card \(i+1): type=\"\(type.rawValue)\"\n"
            switch type {
            case .speakIt:
                cardInstructions += "  → Natural sentence the user must say in \(langName).\n"
            case .echo:
                cardInstructions += "  → Natural \(langName) sentence to hear and repeat.\n"
            case .speedConjugation:
                cardInstructions += "  → Verb conjugation question, 4 options.\n"
            case .whatDidSheSay:
                cardInstructions += "  → \(langName) sentence spoken aloud, 4 written options.\n"
            case .minimalPairs:
                cardInstructions += "  → Two similar-sounding words, pick which matches the meaning.\n"
            case .quickPick:
                cardInstructions += "  → Fill-in-the-blank or grammar question, 4 options.\n"
            case .trueOrFalse:
                cardInstructions += "  → Sentence that is correct or has one mistake. True/False.\n"
            case .thisOrThat:
                cardInstructions += "  → Binary choice (e.g., a/o, ser/estar). Exactly 2 options.\n"
            case .slangInContext:
                cardInstructions += "  → Short dialogue with slang, pick the meaning (3 options).\n"
            case .contextualResponse:
                cardInstructions += "  → 2-line conversation, pick the most natural reply (3 options).\n"
            }
        }

        return """
        Generate \(cardTypes.count) Lightning Round quiz cards for a \(langName) learner (English native speaker).

        USER LEVEL: \(overallLevel)
        \(Self.difficultyGuidelines(for: overallLevel))

        \(mistakeBlock)

        \(transferBlock)

        \(cardInstructions)

        RULES:
        - All prompts and explanations in English, with \(langName) words quoted inline
        - ACCURACY IS CRITICAL — every word must be 100% correct
        - correct_answer MUST appear in the options array (for tap cards)
        - Voice cards (speakIt, echo): include "audio_text" with the full sentence
        - Vary topics: shopping, sports, cooking, travel, dating, family, weather, etc.
        - Vary sentence length and register
        - For thisOrThat: exactly 2 options

        Respond with JSON: {"cards": [{"type":"...","prompt":"...","correct_answer":"...","options":[...],"explanation":"...","audio_text":"...","target_word":"..."}]}
        """
    }

    /// Legacy prompt — kept for compatibility but buildUnifiedPrompt is preferred
    func generateCardsPrompt(
        cardTypes: [LightningCardType],
        mistakes: [MistakeEntry],
        language: String
    ) -> String {
        let langName = languageName(for: language)
        let transferBlock = TransferPatterns.patterns(for: language)

        var mistakeDescriptions = ""
        for (i, m) in mistakes.enumerated() {
            var desc = """
            Mistake \(i + 1):
              Category: \(m.category.rawValue)
              User said: "\(m.userSaid)"
              Correct: "\(m.correctForm)"
              Explanation: \(m.explanation)
              Times seen: \(m.seenCount)
            """
            // Include previously used sentences so GPT never repeats them
            if !m.usedSentences.isEmpty {
                let recent = m.usedSentences.suffix(15).map { "  - \"\($0)\"" }.joined(separator: "\n")
                desc += "\n  ALREADY USED (do NOT reuse these sentences or similar ones):\n\(recent)"
            }
            mistakeDescriptions += desc + "\n\n"
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

        let store = UserLevelStore.shared
        let overallLevel = store.hasBeenAssessed ? store.overallLevel.rawValue : "B1"
        NSLog("⚡ [LightningRound] generating cards at level \(overallLevel) (assessed: \(store.hasBeenAssessed))")
        let levelContext: String
        if store.hasBeenAssessed {
            levelContext = """
            USER LEVEL: \(overallLevel) (Grammar: \(store.skills[.grammar]?.level.rawValue ?? "B1"), Vocabulary: \(store.skills[.vocabulary]?.level.rawValue ?? "B1"), Pronunciation: \(store.skills[.pronunciation]?.level.rawValue ?? "B1"), Fluency: \(store.skills[.fluency]?.level.rawValue ?? "B1"))

            DIFFICULTY REQUIREMENTS FOR \(overallLevel) — THIS IS MANDATORY:
            \(Self.difficultyGuidelines(for: overallLevel))
            """
        } else {
            levelContext = """
            USER LEVEL: B1 (not yet assessed — assume intermediate)

            DIFFICULTY REQUIREMENTS FOR B1 — THIS IS MANDATORY:
            \(Self.difficultyGuidelines(for: "B1"))
            """
        }

        return """
        Generate \(cardTypes.count) Lightning Round quiz cards for a \(langName) learner (English native speaker).

        \(levelContext)

        The cards test REAL mistakes this user has made. Here are their recent mistakes:

        \(mistakeDescriptions)

        \(transferBlock)

        Generate these cards:
        \(cardInstructions)

        VARIETY RULES — CRITICAL:
        - NEVER reuse sentence structures, topics, or scenarios from previous rounds.
        - Each card must use a COMPLETELY DIFFERENT context: shopping, sports, cooking, travel,
          work, dating, family, weather, health, music, movies, animals, etc.
        - Even when testing the SAME grammar pattern, use wildly different sentences.
          Example: if testing gender of "viagem", don't always say "I'm going on a trip."
          Instead: "That trip changed my life" / "Book the trip for Saturday" / "Her trip was cancelled"
        - Vary sentence length: some short (4-5 words), some medium (8-10 words)
        - Mix registers: some formal, some casual, some slang\(recentPrompts.isEmpty ? "" : "\n\n        DO NOT use any of these recently used prompts or similar sentences:\n        \(recentPrompts.suffix(20).map { "- \"\($0)\"" }.joined(separator: "\n        "))")

        PROMPT FORMAT — CRITICAL:
        - Every prompt MUST use \\n to separate the statement from the question.
        - Line 1 = the \(langName) phrase, dialogue, or sentence being tested.
        - Line 2 = the English question about it.
        - Example: "A mesa é grande\\nWhat does 'grande' mean?"
        - For speakIt: "Say in \(langName):\\nI am going to his house later today"
        - For dialogues: "A: Você vai?\\nB: Sim, eu vou.\\nWhat does 'vou' mean?"
        - NEVER put statement and question on the same line.

        ACCURACY RULES:
        - All prompts and explanations MUST be in English, with \(langName) words quoted inline
        - ACCURACY IS CRITICAL: Every \(langName) word, translation, and grammar explanation must be 100% correct.
          Do NOT guess. If unsure about a word's meaning, use a different word you ARE sure about.
        - Wrong options must be PLAUSIBLE — things an English speaker would actually pick
        - The correct_answer must ACTUALLY be correct. Double-check grammar, gender, and meaning.
        - Options must make sense as answers to the prompt. Don't include random unrelated words.
        - Explanations: 1 sentence max, 15 words max. Just say WHY the answer is correct.
        - For voice cards (speakIt, echo), include the full sentence as "audio_text"
        - For speakIt, the "target_word" is the specific word/pattern being tested
        - Options array: always include the correct answer, shuffled randomly among the options
        - For thisOrThat cards: options must be exactly 2 items
        - NO duplicate options — every option must be different
        - NO dashes, blanks, or placeholder options — every option must be a real answer

        SELF-REVIEW — MANDATORY:
        Before outputting each card, verify:
        1. Does the question make logical sense? Could a human answer it?
        2. Is correct_answer actually in the options array?
        3. Are all options different from each other?
        4. Is the prompt in the right format (statement \\n question)?
        5. For voice cards: does audio_text contain a full speakable sentence?
        6. Would YOU get this card right if you knew \(langName)? If the answer is ambiguous, rewrite it.
        7. Is the correct answer ACTUALLY correct? Not a trick — genuinely right.
        If any check fails, fix the card before including it.

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

    // MARK: - Unified Pre-Generation (Single API Call)

    /// Pre-generates a Lightning Round in ONE API call — no seeding step required.
    /// Works with or without existing mistakes in the profile.
    /// Called from: SceneDelegate (app launch), Coach tab, after each round, background task.
    static func preGenerate(language: String) {
        let engine = LightningRoundEngine.shared

        // Skip if we already have cached cards for this language
        guard engine.cachedCards == nil else {
            NSLog("⚡ [PreGen] skipped — memory cache exists")
            return
        }
        // Check disk cache
        if let diskCards = engine.loadCacheFromDisk(language: language) {
            engine.cachedCards = diskCards
            NSLog("⚡ [PreGen] loaded \(diskCards.count) cards from disk")
            return
        }
        // Skip if already generating
        guard !engine.isCaching else {
            NSLog("⚡ [PreGen] skipped — already in flight")
            return
        }
        engine.isCaching = true
        NSLog("⚡ [PreGen] starting for \(language)")

        let langName = engine.languageName(for: language)
        let cardTypes = engine.buildRoundCardTypes()

        // Build prompt — uses existing mistakes if available, otherwise generates from scratch
        let existingMistakes = engine.selectMistakesForRound(count: 10, language: language)
        let prompt = engine.buildUnifiedPrompt(
            cardTypes: cardTypes,
            existingMistakes: existingMistakes,
            language: language,
            langName: langName
        )

        let apiKey = APIConfig.openAIAPIKey
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            engine.isCaching = false
            return
        }

        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": "You generate quiz cards for language learners. Respond ONLY with valid JSON."],
                ["role": "user", "content": prompt],
            ],
            "temperature": 0.5,
            "max_tokens": 2000,
            "response_format": ["type": "json_object"],
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 30

        URLSession.shared.dataTask(with: request) { data, _, error in
            defer { engine.isCaching = false }

            if let error = error {
                NSLog("⚡ [PreGen] FAILED: \(error.localizedDescription)")
                engine.notifyWaiters(cards: [])
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String,
                  let contentData = content.data(using: .utf8),
                  let parsed = try? JSONSerialization.jsonObject(with: contentData) as? [String: Any]
            else {
                NSLog("⚡ [PreGen] FAILED: couldn't parse response")
                engine.notifyWaiters(cards: [])
                return
            }

            // Parse cards
            let cardsArray: [[String: Any]]
            if let arr = parsed["cards"] as? [[String: Any]] {
                cardsArray = arr
            } else {
                cardsArray = parsed.values.compactMap { $0 as? [[String: Any]] }.first ?? []
            }

            var generatedCards: [LightningCard] = []
            for (i, cardJSON) in cardsArray.enumerated() where i < cardTypes.count {
                let type = cardTypes[i]

                let rawPrompt = cardJSON["prompt"] as? String ?? ""
                let rawCorrectAnswer = cardJSON["correct_answer"] as? String ?? ""
                let rawAudioText = cardJSON["audio_text"] as? String
                let rawOptions = (cardJSON["options"] as? [String])?.filter {
                    $0.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 &&
                    $0 != "—" && $0 != "-" && $0 != "–"
                }

                // Voice card validation
                let audioText = type.isVoiceCard ? (rawAudioText ?? rawCorrectAnswer) : rawAudioText
                let prompt = rawPrompt.isEmpty ? (type.isVoiceCard ? "Say this out loud:" : "What's the correct form?") : rawPrompt

                generatedCards.append(LightningCard(
                    type: type,
                    mistakeId: nil,
                    language: language,
                    prompt: prompt,
                    correctAnswer: rawCorrectAnswer,
                    options: rawOptions,
                    explanation: cardJSON["explanation"] as? String ?? "",
                    audioText: audioText,
                    targetWord: cardJSON["target_word"] as? String
                ))
            }

            if !generatedCards.isEmpty {
                let validated = engine.validateCards(generatedCards, language: language)
                if !validated.isEmpty {
                    engine.cachedCards = validated
                    engine.saveCacheToDisk(validated, language: language)
                    engine.notifyWaiters(cards: validated)
                    NSLog("⚡ [PreGen] SUCCESS: \(validated.count) valid cards cached")

                    // Also seed the mistake profile from the generated cards (if profile is empty)
                    if existingMistakes.isEmpty {
                        engine.seedMistakesFromCards(validated, language: language)
                    }
                } else {
                    engine.notifyWaiters(cards: [])
                    NSLog("⚡ [PreGen] all cards failed validation")
                }
            } else {
                engine.notifyWaiters(cards: [])
                NSLog("⚡ [PreGen] no cards in response")
            }
        }.resume()
    }

    /// Seed the mistake profile from generated cards (reverse: cards → mistakes)
    private func seedMistakesFromCards(_ cards: [LightningCard], language: String) {
        let profile = MistakeProfileStore.shared
        for card in cards {
            guard !card.correctAnswer.isEmpty else { continue }
            let category: MistakeCategory
            switch card.type {
            case .speedConjugation: category = .conjugation
            case .thisOrThat: category = .gender
            case .minimalPairs: category = .pronunciation
            case .slangInContext: category = .vocabulary
            case .speakIt, .echo: category = .pronunciation
            default: category = .grammar
            }
            profile.record(
                category: category,
                language: language,
                userSaid: card.prompt,
                correctForm: card.correctAnswer,
                explanation: card.explanation,
                source: .keyboard
            )
        }
        NSLog("⚡ [PreGen] seeded \(cards.count) mistakes from generated cards")
    }

    // MARK: - Process Round Results

    /// Updates the mistake profile based on Lightning Round results.
    func processResults(_ cards: [LightningCard]) {
        // Mark first round as complete (subsequent rounds will be 10 cards instead of 15)
        Self.markFirstRoundComplete()

        // Map card types to skill categories for level adjustments
        let cardTypeToSkill: [LightningCardType: SkillCategory] = [
            .speakIt: .pronunciation,
            .echo: .pronunciation,
            .speedConjugation: .grammar,
            .quickPick: .grammar,
            .trueOrFalse: .grammar,
            .thisOrThat: .grammar,
            .whatDidSheSay: .fluency,
            .minimalPairs: .pronunciation,
            .slangInContext: .vocabulary,
            .contextualResponse: .fluency,
        ]

        // Track accuracy per skill category this round
        var skillResults: [SkillCategory: (correct: Int, total: Int)] = [:]

        for card in cards {
            guard let mistakeId = card.mistakeId, let correct = card.isCorrect else { continue }
            if correct {
                profile.markCorrect(id: mistakeId)
            } else {
                profile.markIncorrect(id: mistakeId)
            }

            // Record the sentence used so it's never repeated for this mistake
            profile.recordUsedSentence(id: mistakeId, sentence: card.prompt)

            // Accumulate per-skill accuracy
            if let skill = cardTypeToSkill[card.type] {
                var current = skillResults[skill] ?? (0, 0)
                current.total += 1
                if card.isCorrect == true { current.correct += 1 }
                skillResults[skill] = current
            }
        }

        // Update user levels based on this round's per-skill accuracy
        let levelStore = UserLevelStore.shared
        for (skill, result) in skillResults where result.total > 0 {
            let accuracy = Double(result.correct) / Double(result.total)
            levelStore.updateFromPerformance(skill: skill, accuracy: accuracy)
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

    /// Concrete difficulty guidelines for each CEFR level.
    /// Injected into the GPT prompt so card difficulty matches the user's actual level.
    static func difficultyGuidelines(for level: String) -> String {
        switch level {
        case "A1":
            return """
            - Use only present tense and the most basic vocabulary (100 most common words)
            - Sentences must be 3-5 words maximum
            - Test: basic greetings, numbers, colors, days, simple nouns with articles
            - Options should be obviously different — no subtle distinctions
            - Example level: "The house is ___" (big / small)
            """
        case "A2":
            return """
            - Use present and simple past tense, basic adjectives, common prepositions
            - Sentences 5-8 words
            - Test: routine expressions, describing daily activities, simple opinions
            - Wrong options should be plausible but clearly wrong to someone at A2
            - Example level: "Yesterday I ___ to the store" (went / go / going)
            """
        case "B1":
            return """
            - Use past, present, future tenses, conditional mood, common subjunctive
            - Sentences 8-12 words with one subordinate clause
            - Test: expressing opinions, narrating events, hypothetical situations
            - Include some idiomatic expressions and less common vocabulary
            - Example level: "If I had known, I ___ differently" (would have acted)
            """
        case "B2":
            return """
            - Use all tenses including subjunctive, passive voice, complex conditionals
            - Sentences 10-15 words with multiple clauses
            - Test: nuanced word choice, register differences, idiomatic usage, false friends
            - Wrong options should be SUBTLE — plausible even to upper-intermediate learners
            - Include colloquial expressions, slang, and formal register shifts
            - Example level: "She insisted that he ___ the report before leaving" (submit — subjunctive)
            """
        case "C1":
            return """
            - Use sophisticated grammar: subjunctive in all forms, literary tenses, complex passive
            - Sentences 12-20 words with embedded clauses and nuanced connectors
            - Test: precise word choice between near-synonyms, subtle register shifts, rare idioms
            - Wrong options should be VERY subtle — differences only an advanced speaker would catch
            - Include formal/literary vocabulary, professional jargon, culturally-specific expressions
            - Example level: "The nuance between 'lograr' and 'conseguir' in formal writing"
            """
        case "C2":
            return """
            - Use the full range of the language: literary constructions, archaic forms, dialect awareness
            - Test: mastery-level distinctions, stylistic choices, translation of untranslatable concepts
            - Wrong options should trap even advanced speakers — only true masters get these right
            - Include proverb variations, double meanings, culture-specific humor, formal rhetoric
            - Example level: distinguishing subtle connotation shifts between synonyms in context
            """
        default:
            return """
            - Use intermediate-level grammar and vocabulary
            - Sentences 8-12 words
            - Test common grammar patterns and everyday vocabulary
            """
        }
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
