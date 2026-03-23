
//
//  PronunciationMistakeStore.swift
//  TranslateHelper
//
//  Tracks words/phrases the user repeatedly mispronounces.
//  Coach reads this store to surface the Pronunciation Clinic.
//

import Foundation
import Combine

// MARK: - Model

struct PronunciationMistake: Codable, Identifiable, Equatable {
    let id: UUID
    let word: String            // The target-language word or phrase
    let language: String        // ISO 639-1 code, e.g. "es", "fr"
    var missCount: Int          // How many times this has been flagged
    var lastSeen: Date
    var masteredAt: Date?       // Set when user nails it in the clinic

    var isMastered: Bool { masteredAt != nil }

    init(word: String, language: String) {
        self.id        = UUID()
        self.word      = word
        self.language  = language
        self.missCount = 1
        self.lastSeen  = Date()
        self.masteredAt = nil
    }
}

// MARK: - Store

final class PronunciationMistakeStore: ObservableObject {
    static let shared = PronunciationMistakeStore()

    @Published private(set) var mistakes: [PronunciationMistake] = []

    // Threshold: how many misses before the clinic surfaces this word
    static let clinicThreshold = 2

    private let key = "ts_pronunciation_mistakes_v1"

    private init() { load() }

    // MARK: - Public API

    /// Record a mispronunciation. If the word already exists, increments its count.
    func record(word: String, language: String) {
        let normalised = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalised.isEmpty else { return }

        if let idx = mistakes.firstIndex(where: {
            $0.word.lowercased() == normalised && $0.language == language
        }) {
            mistakes[idx].missCount += 1
            mistakes[idx].lastSeen  = Date()
            mistakes[idx].masteredAt = nil  // reset mastery if they slip back
        } else {
            mistakes.append(PronunciationMistake(word: normalised, language: language))
        }
        save()
    }

    /// Mark a word as mastered after successful clinic session.
    func markMastered(id: UUID) {
        if let idx = mistakes.firstIndex(where: { $0.id == id }) {
            mistakes[idx].masteredAt = Date()
            save()
        }
    }

    /// Reset mastery (e.g., if user mispronounces it again days later).
    func resetMastery(id: UUID) {
        if let idx = mistakes.firstIndex(where: { $0.id == id }) {
            mistakes[idx].masteredAt = nil
            mistakes[idx].missCount += 1
            save()
        }
    }

    /// Words that have crossed the threshold and should be offered in the clinic.
    /// Excludes mastered words. Sorted by miss count descending (worst first).
    var clinicQueue: [PronunciationMistake] {
        mistakes
            .filter { !$0.isMastered && $0.missCount >= Self.clinicThreshold }
            .sorted { $0.missCount > $1.missCount }
    }

    /// All mastered words — for encouragement / progress display.
    var mastered: [PronunciationMistake] {
        mistakes.filter { $0.isMastered }
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(mistakes) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data  = UserDefaults.standard.data(forKey: key),
              let saved = try? JSONDecoder().decode([PronunciationMistake].self, from: data)
        else { return }
        mistakes = saved
    }

    // MARK: - Dev / Testing helpers

    #if DEBUG
    func seedTestData(language: String = "es") {
        let words = language == "pt"
            ? ["desenvolvimento", "coração", "trabalho", "consciência", "comunicação"]
            : ["desarrollar", "murciélago", "ferrocarril", "extraordinario", "pronunciación"]
        for (i, w) in words.enumerated() {
            var m = PronunciationMistake(word: w, language: language)
            m.missCount = i + 2   // 2–6 misses
            mistakes.append(m)
        }
        save()
    }

    func clearAll() {
        mistakes = []
        UserDefaults.standard.removeObject(forKey: key)
    }
    #endif
}
