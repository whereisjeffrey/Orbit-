//
//  SharedPhraseStore.swift
//  TranslateHelper
//
//  Single source of truth for keyboard-saved phrases.
//  Reads/writes via App Group: group.com.jeff.translatehelper
//

import Foundation
import Combine

struct SavedPhrase: Codable, Identifiable {
    let id: UUID
    let sourceText: String
    let translatedText: String
    let sourceLang: String   // "en" or "es"
    let targetLang: String
    let savedAt: Date
    var notes: String?
    /// Geographic/cultural scope of this phrase, e.g. "Used in Buenos Aires",
    /// "Common across Latin America", "Understood in Spain & Latin America".
    /// Populated for slang/flirty/casual modes when location context is available.
    var localityTag: String?
    
    // Spaced Repetition (SM-2) variables
    var repetitions: Int
    var easinessFactor: Double
    var interval: Int // in minutes for now
    var nextReviewDate: Date

    init(id: UUID = UUID(), sourceText: String, translatedText: String, sourceLang: String, targetLang: String, savedAt: Date, notes: String? = nil, localityTag: String? = nil, repetitions: Int = 0, easinessFactor: Double = 2.5, interval: Int = 0, nextReviewDate: Date = Date()) {
        self.id = id
        self.sourceText = sourceText
        self.translatedText = translatedText
        self.sourceLang = sourceLang
        self.targetLang = targetLang
        self.savedAt = savedAt
        self.notes = notes
        self.localityTag = localityTag
        self.repetitions = repetitions
        self.easinessFactor = easinessFactor
        self.interval = interval
        self.nextReviewDate = nextReviewDate
    }

    static let userDefaultsKey = "talkswitch_saved_phrases"
}

class SharedPhraseStore: ObservableObject {
    static let shared = SharedPhraseStore()

    @Published private(set) var phrases: [SavedPhrase] = []

    private let defaults: UserDefaults?

    private init() {
        self.defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        load()
    }

    func load() {
        // Read the flat dict array written by keyboard extension
        let key = SavedPhrase.userDefaultsKey
        if let raw = defaults?.array(forKey: key) as? [[String: String]] {
            let formatter = ISO8601DateFormatter()
            phrases = raw.compactMap { d -> SavedPhrase? in
                guard
                    let idStr   = d["id"],
                    let source  = d["sourceText"],
                    let trans   = d["translation"],
                    let srcLang = d["sourceLang"],
                    let tgtLang = d["targetLang"],
                    let dateStr = d["savedAt"],
                    let date    = formatter.date(from: dateStr)
                else { return nil }
                
                let notes = d["notes"]
                let localityTag = d["localityTag"]
                
                // For existing phrases that don't have these keys, we use defaults.
                let reps = Int(d["repetitions"] ?? "0") ?? 0
                let ef = Double(d["easinessFactor"] ?? "2.5") ?? 2.5
                let interval = Int(d["interval"] ?? "0") ?? 0
                
                let nextReviewStr = d["nextReviewDate"] ?? dateStr
                let nextReview = formatter.date(from: nextReviewStr) ?? date
                
                return SavedPhrase(
                    id:             UUID(uuidString: idStr) ?? UUID(),
                    sourceText:     source,
                    translatedText: trans,
                    sourceLang:     srcLang,
                    targetLang:     tgtLang,
                    savedAt:        date,
                    notes:          notes,
                    localityTag:    localityTag,
                    repetitions:    reps,
                    easinessFactor: ef,
                    interval:       interval,
                    nextReviewDate: nextReview
                )
            }.sorted { $0.savedAt > $1.savedAt }
        } else {
            phrases = []
        }
    }

    func save(source: String, translation: String, sourceLang: String, targetLang: String, notes: String? = nil, localityTag: String? = nil) {
        let phrase = SavedPhrase(
            id: UUID(),
            sourceText: source,
            translatedText: translation,
            sourceLang: sourceLang,
            targetLang: targetLang,
            savedAt: Date(),
            notes: notes,
            localityTag: localityTag
        )
        phrases.insert(phrase, at: 0)
        persist()
    }
    
    // Updates an existing phrase directly and persists the changes
    func updatePhrase(_ phrase: SavedPhrase) {
        if let index = phrases.firstIndex(where: { $0.id == phrase.id }) {
            phrases[index] = phrase
            persist()
        }
    }

    func delete(_ phrase: SavedPhrase) {
        phrases.removeAll { $0.id == phrase.id }
        persist()
    }

    private func persist() {
        let formatter = ISO8601DateFormatter()
        let dicts = phrases.map { p -> [String: String] in
            var d: [String: String] = [
                "id": p.id.uuidString,
                "sourceText": p.sourceText,
                "translation": p.translatedText,
                "sourceLang": p.sourceLang,
                "targetLang": p.targetLang,
                "savedAt": formatter.string(from: p.savedAt),
                "repetitions": "\(p.repetitions)",
                "easinessFactor": "\(p.easinessFactor)",
                "interval": "\(p.interval)",
                "nextReviewDate": formatter.string(from: p.nextReviewDate)
            ]
            if let notes = p.notes {
                d["notes"] = notes
            }
            if let tag = p.localityTag {
                d["localityTag"] = tag
            }
            return d
        }
        defaults?.set(dicts, forKey: SavedPhrase.userDefaultsKey)
    }
}
