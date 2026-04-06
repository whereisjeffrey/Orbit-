//
//  MistakeIngestion.swift
//  TranslateHelper
//
//  Bridges between correction sources and the MistakeProfile.
//  - Keyboard corrections: written to App Group queue, processed by main app
//  - Sol corrections: ingested directly during practice sessions
//

import Foundation

enum MistakeIngestion {

    private static let appGroup = "group.com.jeff.translatehelper"
    private static let queueKey = "ts_mistake_queue"  // Keyboard writes here

    // MARK: - Keyboard Extension Side

    /// Called from keyboard extension after getGentleCorrection returns a result.
    /// Writes to App Group queue for the main app to pick up.
    static func queueFromKeyboard(
        userSaid: String,
        nativeSay: String,
        explanation: String,
        category: String?,
        language: String
    ) {
        guard let defaults = UserDefaults(suiteName: appGroup) else { return }

        var queue = defaults.array(forKey: queueKey) as? [[String: String]] ?? []

        let entry: [String: String] = [
            "userSaid": userSaid,
            "correctForm": nativeSay,
            "explanation": explanation,
            "category": category ?? "grammar",
            "language": language,
            "source": "keyboard",
            "timestamp": ISO8601DateFormatter().string(from: Date()),
        ]

        // Dedup — don't queue the same correction twice
        let isDuplicate = queue.contains { existing in
            existing["correctForm"]?.lowercased() == nativeSay.lowercased() &&
            existing["language"] == language
        }
        guard !isDuplicate else { return }

        queue.append(entry)
        if queue.count > 50 { queue = Array(queue.suffix(50)) }
        defaults.set(queue, forKey: queueKey)
        defaults.synchronize()

        NSLog("⚡ [MistakeIngestion] queued from keyboard: \(userSaid) → \(nativeSay)")
    }

    // MARK: - Main App Side

    /// Called from SceneDelegate (or on app launch) to process queued keyboard corrections.
    static func processKeyboardQueue() {
        guard let defaults = UserDefaults(suiteName: appGroup) else { return }
        guard let queue = defaults.array(forKey: queueKey) as? [[String: String]],
              !queue.isEmpty else { return }

        NSLog("⚡ [MistakeIngestion] processing \(queue.count) queued corrections")

        let profile = MistakeProfileStore.shared

        for entry in queue {
            guard let userSaid = entry["userSaid"],
                  let correctForm = entry["correctForm"],
                  let explanation = entry["explanation"],
                  let language = entry["language"] else { continue }

            let categoryString = entry["category"] ?? "grammar"
            let category = mapCategory(categoryString)

            profile.record(
                category: category,
                language: language,
                userSaid: userSaid,
                correctForm: correctForm,
                explanation: explanation,
                source: .keyboard
            )
        }

        // Record engagement for streak tracking
        PracticeStatsStore.shared.recordEngagement()

        // Clear queue
        defaults.removeObject(forKey: queueKey)
        defaults.synchronize()
    }

    // MARK: - Sol Coaching (Direct Ingestion)

    /// Called from PracticeSessionView when Sol provides a native correction.
    /// This runs in the main app, so we write directly to MistakeProfileStore.
    static func ingestFromSol(
        userSaid: String,
        nativeCorrection: String,
        notes: String?,
        language: String
    ) {
        // Skip if Sol said the user was fine (null correction)
        let trimmed = nativeCorrection.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Try to infer category from the notes
        let category = inferCategory(from: notes ?? "")

        MistakeProfileStore.shared.record(
            category: category,
            language: language,
            userSaid: userSaid,
            correctForm: nativeCorrection,
            explanation: notes ?? "A native speaker would say it differently",
            source: .solCoaching
        )

        // Nudge the relevant skill level down slightly (correction = mistake)
        let skillMap: [MistakeCategory: SkillCategory] = [
            .grammar: .grammar, .conjugation: .grammar, .wordOrder: .grammar,
            .preposition: .grammar, .gender: .grammar,
            .pronunciation: .pronunciation,
            .vocabulary: .vocabulary, .idiom: .vocabulary,
        ]
        if let skill = skillMap[category] {
            UserLevelStore.shared.updateFromPerformance(skill: skill, accuracy: 0.3)
        }
    }

    /// Called from PronunciationScorer when user mispronounces a word.
    static func ingestFromPronunciation(
        word: String,
        heard: String,
        language: String
    ) {
        MistakeProfileStore.shared.record(
            category: .pronunciation,
            language: language,
            userSaid: heard,
            correctForm: word,
            explanation: "Pronunciation didn't match — practice the sounds in '\(word)'",
            source: .pronunciationDrill
        )
    }

    // MARK: - Category Inference

    private static func mapCategory(_ string: String) -> MistakeCategory {
        switch string.lowercased() {
        case "grammar":       return .grammar
        case "pronunciation": return .pronunciation
        case "vocabulary":    return .vocabulary
        case "gender":        return .gender
        case "conjugation":   return .conjugation
        case "word_order":    return .wordOrder
        case "preposition":   return .preposition
        case "idiom", "slang": return .idiom
        default:              return .grammar
        }
    }

    /// Infers mistake category from correction notes using keyword matching.
    private static func inferCategory(from notes: String) -> MistakeCategory {
        let lower = notes.lowercased()

        if lower.contains("gender") || lower.contains("masculine") || lower.contains("feminine")
            || lower.contains(" la ") || lower.contains(" el ") || lower.contains(" o ") || lower.contains(" a ") {
            return .gender
        }
        if lower.contains("conjugat") || lower.contains("verb form") || lower.contains("tense")
            || lower.contains("subjunctive") || lower.contains("imperfect") || lower.contains("preterit") {
            return .conjugation
        }
        if lower.contains("word order") || lower.contains("order of") || lower.contains("position") {
            return .wordOrder
        }
        if lower.contains("preposition") || lower.contains(" por ") || lower.contains(" para ")
            || lower.contains(" en ") || lower.contains(" a ") {
            return .preposition
        }
        if lower.contains("pronounc") || lower.contains("sound") || lower.contains("stress")
            || lower.contains("accent") || lower.contains("intonation") {
            return .pronunciation
        }
        if lower.contains("slang") || lower.contains("idiom") || lower.contains("expression")
            || lower.contains("colloquial") {
            return .idiom
        }
        if lower.contains("vocab") || lower.contains("word choice") || lower.contains("means")
            || lower.contains("instead of") {
            return .vocabulary
        }

        return .grammar  // Default
    }
}
