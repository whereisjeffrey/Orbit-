//
//  SolMemory.swift
//  TranslateHelper
//
//  Persists key facts Sol learns about the user across practice sessions.
//  Sol can reference these in future conversations ("Last time you mentioned…").
//  Stored in App Group so the main app can read/write.
//

import Foundation

struct SolMemoryFact: Codable, Identifiable {
    let id: UUID
    let fact: String           // e.g., "User is looking for a new apartment in Condesa"
    let category: String       // personal, work, interests, relationships, goals
    let learnedAt: Date
    var lastReferenced: Date?  // last time Sol brought it up
    var relevanceScore: Int    // higher = more interesting to bring up (1-10)

    init(fact: String, category: String, relevanceScore: Int = 5) {
        self.id = UUID()
        self.fact = fact
        self.category = category
        self.learnedAt = Date()
        self.lastReferenced = nil
        self.relevanceScore = relevanceScore
    }
}

class SolMemoryStore {
    static let shared = SolMemoryStore()

    private static let appGroup = "group.com.jeff.translatehelper"
    private static let storageKey = "ts_sol_memory_v1"
    private static let maxFacts = 20  // keep it lean

    private(set) var facts: [SolMemoryFact] = []

    private init() { load() }

    // MARK: - Recording

    /// Add a new fact Sol learned. Deduplicates by checking similarity.
    func remember(_ fact: String, category: String, relevance: Int = 5) {
        // Skip if we already know something very similar
        let lowerFact = fact.lowercased()
        let isDuplicate = facts.contains { existing in
            existing.fact.lowercased() == lowerFact ||
            levenshteinSimilarity(existing.fact.lowercased(), lowerFact) > 0.8
        }
        guard !isDuplicate else { return }

        let entry = SolMemoryFact(fact: fact, category: category, relevanceScore: relevance)
        facts.append(entry)

        // Trim to max — remove oldest, lowest-relevance facts
        if facts.count > Self.maxFacts {
            facts.sort { a, b in
                if a.relevanceScore != b.relevanceScore { return a.relevanceScore > b.relevanceScore }
                return a.learnedAt > b.learnedAt
            }
            facts = Array(facts.prefix(Self.maxFacts))
        }

        save()
        NSLog("🧠 [Sol Memory] remembered: \(fact) [\(category)]")
    }

    /// Mark a fact as referenced (so Sol doesn't repeat it too soon).
    func markReferenced(_ factId: UUID) {
        if let idx = facts.firstIndex(where: { $0.id == factId }) {
            facts[idx].lastReferenced = Date()
            save()
        }
    }

    // MARK: - Retrieval

    /// Facts Sol hasn't referenced recently — good candidates for callbacks.
    var callbackCandidates: [SolMemoryFact] {
        let oneDay: TimeInterval = 86400
        return facts
            .filter { fact in
                // Haven't referenced in the last day
                guard let lastRef = fact.lastReferenced else { return true }
                return Date().timeIntervalSince(lastRef) > oneDay
            }
            .sorted { $0.relevanceScore > $1.relevanceScore }
    }

    /// Build a context block for Sol's system prompt — what Sol knows about this user.
    func buildContextBlock() -> String {
        guard !facts.isEmpty else { return "" }

        let lines = facts
            .sorted { $0.relevanceScore > $1.relevanceScore }
            .prefix(10)
            .map { "- \($0.fact) [\($0.category)]" }
            .joined(separator: "\n")

        return """

        MEMORY — Things you know about this user from previous conversations:
        \(lines)

        Use these naturally — don't list them, but weave them into conversation when relevant. \
        For example: "How's the apartment hunt going?" or "Still working from that café in Condesa?" \
        Don't force it — only reference when it fits the flow. If nothing fits, just have a normal conversation.
        """
    }

    /// Build a callback suggestion for the topic generator.
    func buildCallbackSuggestion() -> String? {
        guard let best = callbackCandidates.first else { return nil }
        return "CALLBACK SUGGESTION: In a previous conversation, the user mentioned: \"\(best.fact)\". " +
               "Consider naturally referencing this to make the conversation feel personal."
    }

    // MARK: - Persistence

    private func save() {
        guard let defaults = UserDefaults(suiteName: Self.appGroup) else { return }
        if let data = try? JSONEncoder().encode(facts) {
            defaults.set(data, forKey: Self.storageKey)
            defaults.synchronize()
        }
    }

    private func load() {
        guard let defaults = UserDefaults(suiteName: Self.appGroup),
              let data = defaults.data(forKey: Self.storageKey),
              let decoded = try? JSONDecoder().decode([SolMemoryFact].self, from: data)
        else { return }
        facts = decoded
    }

    // MARK: - Similarity

    private func levenshteinSimilarity(_ a: String, _ b: String) -> Double {
        let aChars = Array(a)
        let bChars = Array(b)
        let m = aChars.count, n = bChars.count
        guard m > 0, n > 0 else { return 0 }

        var matrix = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        for i in 0...m { matrix[i][0] = i }
        for j in 0...n { matrix[0][j] = j }
        for i in 1...m {
            for j in 1...n {
                let cost = aChars[i-1] == bChars[j-1] ? 0 : 1
                matrix[i][j] = min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
            }
        }
        let maxLen = max(m, n)
        return 1.0 - Double(matrix[m][n]) / Double(maxLen)
    }
}
