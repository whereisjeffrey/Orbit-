//
//  MistakeProfile.swift
//  TranslateHelper
//
//  Unified mistake tracking across keyboard corrections + Sol coaching.
//  Feeds the Lightning Round with SRS-scheduled cards.
//  Stored in App Group so both keyboard extension and main app can write.
//

import Foundation
import Combine

// MARK: - Mistake Entry

struct MistakeEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let category: MistakeCategory
    let language: String              // ISO 639-1, e.g. "es"
    let createdAt: Date

    // What happened
    let userSaid: String              // What the user produced
    let correctForm: String           // What it should have been
    let explanation: String           // Why (in English, target-lang words inline)
    let pattern: String?              // Transfer pattern tag if applicable, e.g. "ser_estar"

    // Source
    let source: MistakeSource

    // SRS fields
    var seenCount: Int                // Total times surfaced in Lightning Round
    var correctCount: Int             // Times answered correctly
    var lastTested: Date?
    var lastCorrect: Date?
    var intervalDays: Int             // Current SRS interval (1, 3, 7, 14, 30)
    var nextReviewDate: Date

    // Graduation
    var masteredAt: Date?             // Set after 3 consecutive correct at interval >= 14

    // Variety tracking — sentences already used to test this mistake (never repeat)
    var usedSentences: [String]

    var isMastered: Bool { masteredAt != nil }
    var isDueForReview: Bool { nextReviewDate <= Date() && !isMastered }

    init(
        category: MistakeCategory,
        language: String,
        userSaid: String,
        correctForm: String,
        explanation: String,
        pattern: String? = nil,
        source: MistakeSource
    ) {
        self.id = UUID()
        self.category = category
        self.language = language
        self.createdAt = Date()
        self.userSaid = userSaid
        self.correctForm = correctForm
        self.explanation = explanation
        self.pattern = pattern
        self.source = source
        self.seenCount = 0
        self.correctCount = 0
        self.lastTested = nil
        self.lastCorrect = nil
        self.intervalDays = 1
        self.nextReviewDate = Date()  // Immediately eligible
        self.masteredAt = nil
        self.usedSentences = []
    }
}

// MARK: - Enums

enum MistakeCategory: String, Codable, CaseIterable {
    case grammar
    case pronunciation
    case vocabulary
    case gender
    case conjugation
    case wordOrder
    case preposition
    case idiom

    var displayName: String {
        switch self {
        case .grammar:       return "Grammar"
        case .pronunciation: return "Pronunciation"
        case .vocabulary:    return "Vocabulary"
        case .gender:        return "Gender"
        case .conjugation:   return "Conjugation"
        case .wordOrder:     return "Word Order"
        case .preposition:   return "Prepositions"
        case .idiom:         return "Idioms & Slang"
        }
    }

    var icon: String {
        switch self {
        case .grammar:       return "📐"
        case .pronunciation: return "🗣"
        case .vocabulary:    return "📖"
        case .gender:        return "⚥"
        case .conjugation:   return "🔄"
        case .wordOrder:     return "🔀"
        case .preposition:   return "📍"
        case .idiom:         return "💬"
        }
    }
}

enum MistakeSource: String, Codable {
    case keyboard        // From getGentleCorrection in keyboard extension
    case solCoaching     // From Sol's native_correction in practice sessions
    case pronunciationDrill  // From PronunciationScorer
}

// MARK: - Mistake Profile Store

final class MistakeProfileStore: ObservableObject {
    static let shared = MistakeProfileStore()

    @Published private(set) var entries: [MistakeEntry] = []

    private static let appGroup = "group.com.jeff.translatehelper"
    private static let storageKey = "ts_mistake_profile_v1"

    private init() { load() }

    // MARK: - Record a mistake

    /// Adds a new mistake or increments an existing one if the same correction exists.
    func record(
        category: MistakeCategory,
        language: String,
        userSaid: String,
        correctForm: String,
        explanation: String,
        pattern: String? = nil,
        source: MistakeSource
    ) {
        let normalizedUser = userSaid.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedCorrect = correctForm.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // Check for duplicate — same correction, same language
        if let idx = entries.firstIndex(where: {
            $0.correctForm.lowercased() == normalizedCorrect &&
            $0.language == language &&
            !$0.isMastered
        }) {
            // Re-seen: reset SRS, bump seen count
            entries[idx].seenCount += 1
            entries[idx].intervalDays = 1
            entries[idx].nextReviewDate = Date()
            entries[idx].masteredAt = nil
            save()
            NSLog("⚡ [MistakeProfile] re-recorded: \(normalizedCorrect) (seen \(entries[idx].seenCount)x)")
            return
        }

        let entry = MistakeEntry(
            category: category,
            language: language,
            userSaid: normalizedUser,
            correctForm: normalizedCorrect,
            explanation: explanation,
            pattern: pattern,
            source: source
        )
        entries.append(entry)

        // Cap at 200 entries — drop oldest mastered first, then oldest unmastered
        if entries.count > 200 {
            let mastered = entries.filter { $0.isMastered }.sorted { $0.createdAt < $1.createdAt }
            if let oldest = mastered.first {
                entries.removeAll { $0.id == oldest.id }
            } else {
                entries.removeFirst()
            }
        }

        save()
        NSLog("⚡ [MistakeProfile] recorded: \(category.rawValue) — \(normalizedUser) → \(normalizedCorrect)")
    }

    // MARK: - SRS Updates

    /// Called when the user answers a Lightning Round card correctly.
    func markCorrect(id: UUID) {
        guard let idx = entries.firstIndex(where: { $0.id == id }) else { return }
        entries[idx].correctCount += 1
        entries[idx].lastTested = Date()
        entries[idx].lastCorrect = Date()

        // Advance interval: 1 → 3 → 7 → 14 → 30
        let intervals = [1, 3, 7, 14, 30]
        if let currentIdx = intervals.firstIndex(of: entries[idx].intervalDays),
           currentIdx + 1 < intervals.count {
            entries[idx].intervalDays = intervals[currentIdx + 1]
        } else if entries[idx].intervalDays < 30 {
            entries[idx].intervalDays = 30
        }

        entries[idx].nextReviewDate = Calendar.current.date(
            byAdding: .day,
            value: entries[idx].intervalDays,
            to: Date()
        ) ?? Date()

        // Graduate after 3 consecutive correct at interval >= 14
        if entries[idx].correctCount >= 3 && entries[idx].intervalDays >= 14 {
            entries[idx].masteredAt = Date()
            NSLog("⚡ [MistakeProfile] MASTERED: \(entries[idx].correctForm)")
        }

        save()
    }

    /// Called when the user answers a Lightning Round card incorrectly.
    func markIncorrect(id: UUID) {
        guard let idx = entries.firstIndex(where: { $0.id == id }) else { return }
        entries[idx].lastTested = Date()
        entries[idx].intervalDays = 1  // Reset to 1 day
        entries[idx].nextReviewDate = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: Date()
        ) ?? Date()
        entries[idx].masteredAt = nil  // Un-master if they slip
        entries[idx].correctCount = max(0, entries[idx].correctCount - 1)
        save()
    }

    /// Record a sentence used in Lightning Round so it's never repeated for this mistake.
    func recordUsedSentence(id: UUID, sentence: String) {
        guard let idx = entries.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if !entries[idx].usedSentences.contains(trimmed) {
            entries[idx].usedSentences.append(trimmed)
            // Keep max 50 per mistake to prevent unbounded growth
            if entries[idx].usedSentences.count > 50 {
                entries[idx].usedSentences = Array(entries[idx].usedSentences.suffix(50))
            }
            save()
        }
    }

    // MARK: - Queries

    /// Mistakes due for review (not mastered, review date passed). Worst first.
    var dueForReview: [MistakeEntry] {
        entries
            .filter { $0.isDueForReview }
            .sorted { a, b in
                // Priority: more mistakes seen first, then oldest review date
                if a.seenCount != b.seenCount { return a.seenCount > b.seenCount }
                return a.nextReviewDate < b.nextReviewDate
            }
    }

    /// All active (non-mastered) mistakes for a given category.
    func active(category: MistakeCategory) -> [MistakeEntry] {
        entries.filter { $0.category == category && !$0.isMastered }
    }

    /// All active mistakes for a given language.
    func active(language: String) -> [MistakeEntry] {
        entries.filter { $0.language == language && !$0.isMastered }
    }

    /// Count of mastered vs total for progress display.
    var progressSummary: (mastered: Int, total: Int) {
        (entries.filter { $0.isMastered }.count, entries.count)
    }

    /// Category breakdown: how many active mistakes per category.
    var categoryBreakdown: [(category: MistakeCategory, count: Int)] {
        MistakeCategory.allCases.compactMap { cat in
            let count = active(category: cat).count
            return count > 0 ? (cat, count) : nil
        }
    }

    /// Accuracy percentage for a given category (correct / total seen × 100).
    func categoryAccuracy(_ category: MistakeCategory) -> Int {
        let items = entries.filter { $0.category == category && $0.seenCount > 0 }
        guard !items.isEmpty else { return 0 }
        let totalSeen = items.reduce(0) { $0 + $1.seenCount }
        let totalCorrect = items.reduce(0) { $0 + $1.correctCount }
        guard totalSeen > 0 else { return 0 }
        return Int(Double(totalCorrect) / Double(totalSeen) * 100)
    }

    // MARK: - Persistence (App Group)

    private func save() {
        guard let defaults = UserDefaults(suiteName: Self.appGroup) else { return }
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: Self.storageKey)
            defaults.synchronize()
        }
    }

    private func load() {
        guard let defaults = UserDefaults(suiteName: Self.appGroup),
              let data = defaults.data(forKey: Self.storageKey),
              let saved = try? JSONDecoder().decode([MistakeEntry].self, from: data)
        else { return }
        entries = saved
    }

    // MARK: - Dev / Testing

    #if DEBUG
    func seedTestData(language: String) {
        let testMistakes: [(MistakeCategory, String, String, String)]

        if language == "pt" {
            testMistakes = [
                (.gender, "o viagem", "a viagem", "'Viagem' is feminine — use 'a viagem'"),
                (.conjugation, "eu sou 25 anos", "eu tenho 25 anos", "Age uses 'ter', not 'ser'"),
                (.preposition, "pensar sobre", "pensar em", "'Pensar' takes 'em', not 'sobre'"),
                (.grammar, "eu gosto tacos", "eu gosto de tacos", "'Gostar' requires 'de'"),
                (.pronunciation, "coração", "coração", "'ão' needs a nasal diphthong"),
                (.vocabulary, "estou excitado", "estou empolgado", "'Excitado' means aroused — use 'empolgado'"),
                (.wordOrder, "um muito bom lugar", "um lugar muito bom", "Adjectives follow the noun"),
                (.idiom, "pagar o pato", "pagar o pato", "Means 'take the blame' — literally 'pay the duck'"),
                (.conjugation, "eu vai", "eu vou", "'Ir' is irregular — 'eu vou', not 'eu vai'"),
                (.gender, "o cidade", "a cidade", "'Cidade' is feminine — use 'a cidade'"),
            ]
        } else {
            testMistakes = [
                (.gender, "el casa", "la casa", "'Casa' is feminine — use 'la' not 'el'"),
                (.conjugation, "yo soy 25 años", "yo tengo 25 años", "Age uses 'tener', not 'ser'"),
                (.preposition, "pensar sobre", "pensar en", "'Pensar' takes 'en', not 'sobre'"),
                (.grammar, "me gusta los tacos", "me gustan los tacos", "'Gustar' agrees with the liked thing"),
                (.pronunciation, "desarrollar", "desarrollar", "Double 'rr' needs a rolled trill"),
                (.vocabulary, "estoy caliente", "tengo calor", "'Estoy caliente' means aroused — use 'tengo calor'"),
                (.wordOrder, "es muy un buen restaurante", "es un muy buen restaurante", "Adjective order: 'un muy buen'"),
                (.idiom, "hacer sentido", "tener sentido", "'Tener sentido' = 'to make sense'"),
                (.conjugation, "yo sabo", "yo sé", "'Saber' is irregular — 'yo sé'"),
                (.gender, "el leche", "la leche", "'Leche' is feminine — use 'la leche'"),
            ]
        }

        for (cat, userSaid, correct, explanation) in testMistakes {
            record(
                category: cat,
                language: language,
                userSaid: userSaid,
                correctForm: correct,
                explanation: explanation,
                source: .keyboard
            )
        }
    }

    func clearAll() {
        entries = []
        guard let defaults = UserDefaults(suiteName: Self.appGroup) else { return }
        defaults.removeObject(forKey: Self.storageKey)
    }
    #endif

    // MARK: - Starter Mistakes (Production)

    /// Check if we have any mistakes for a specific language
    func hasMistakes(for language: String) -> Bool {
        entries.contains { $0.language == language && !$0.isMastered }
    }

    /// Seed common beginner mistakes for any language using GPT.
    /// Called when user switches to a new language with no mistake history.
    func seedStarterMistakes(language: String, completion: @escaping () -> Void) {
        // Don't seed if we already have mistakes for this language
        guard !hasMistakes(for: language) else {
            completion()
            return
        }

        let langName = LanguageManager.languageName(for: language)
        let userLevel = UserLevelStore.shared.hasBeenAssessed
            ? UserLevelStore.shared.overallLevel.rawValue
            : "B1"
        let levelGuidelines = LightningRoundEngine.difficultyGuidelines(for: userLevel)

        let prompt = """
        Generate 8 common mistakes that an English speaker at CEFR level \(userLevel) would make when learning \(langName).

        THE USER IS LEVEL \(userLevel). This is critical:
        \(levelGuidelines)

        Generate mistakes that match THIS level — not easier, not harder.
        - A1/A2: basic errors like wrong articles, simple verb forms, basic word order
        - B1/B2: subjunctive errors, nuanced preposition choices, false friends, register mistakes
        - C1/C2: subtle stylistic errors, near-synonym confusion, literary vs colloquial misuse

        Cover these categories: gender, conjugation, preposition, grammar, vocabulary, word_order, idiom, pronunciation.

        For each mistake, provide:
        - category: one of [gender, conjugation, preposition, grammar, vocabulary, word_order, idiom, pronunciation]
        - user_said: what the English speaker would incorrectly say in \(langName) (at \(userLevel) complexity)
        - correct: the correct \(langName) form
        - explanation: 1 sentence in English explaining why (15 words max)

        Respond ONLY with a JSON array:
        [{"category":"gender","user_said":"...","correct":"...","explanation":"..."}]
        """

        let apiKey = APIConfig.openAIAPIKey
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion()
            return
        }

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a linguistics expert. Generate realistic language learning mistakes. Respond ONLY with valid JSON."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.8,
            "max_tokens": 800,
            "response_format": ["type": "json_object"]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { data, _, error in
            defer { DispatchQueue.main.async { completion() } }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String,
                  let parsed = try? JSONSerialization.jsonObject(with: Data(content.utf8)) as? [String: Any]
            else { return }

            // Try to find the array — could be at root or nested
            let mistakes: [[String: Any]]
            if let arr = parsed["mistakes"] as? [[String: Any]] {
                mistakes = arr
            } else if let arr = (parsed.values.first as? [[String: Any]]) {
                mistakes = arr
            } else {
                return
            }

            for m in mistakes {
                guard let catStr = m["category"] as? String,
                      let userSaid = m["user_said"] as? String,
                      let correct = m["correct"] as? String,
                      let explanation = m["explanation"] as? String
                else { continue }

                let category: MistakeCategory
                switch catStr {
                case "gender": category = .gender
                case "conjugation": category = .conjugation
                case "preposition": category = .preposition
                case "grammar": category = .grammar
                case "vocabulary": category = .vocabulary
                case "word_order": category = .wordOrder
                case "idiom": category = .idiom
                case "pronunciation": category = .pronunciation
                default: category = .grammar
                }

                self.record(
                    category: category,
                    language: language,
                    userSaid: userSaid,
                    correctForm: correct,
                    explanation: explanation,
                    source: .keyboard
                )
            }
            NSLog("🌍 Seeded \(mistakes.count) starter mistakes for \(langName)")
        }.resume()
    }
}
