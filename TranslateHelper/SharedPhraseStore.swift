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

    // Conquered tracking
    /// True once the learner has recalled this phrase 3× in a row.
    /// Conquered clipboard phrases disappear from the active list and graduate
    /// to the Conquered auto-deck.
    var isConquered: Bool
    var conqueredAt: Date?

    init(id: UUID = UUID(), sourceText: String, translatedText: String, sourceLang: String, targetLang: String, savedAt: Date, notes: String? = nil, localityTag: String? = nil, repetitions: Int = 0, easinessFactor: Double = 2.5, interval: Int = 0, nextReviewDate: Date = Date(), isConquered: Bool = false, conqueredAt: Date? = nil) {
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
        self.isConquered = isConquered
        self.conqueredAt = conqueredAt
    }

    static let userDefaultsKey = "talkswitch_saved_phrases"
}

class SharedPhraseStore: ObservableObject {
    static let shared = SharedPhraseStore()

    @Published private(set) var phrases: [SavedPhrase] = []

    /// Clipboard phrases that are still in active study rotation.
    var activePhrases: [SavedPhrase] { phrases.filter { !$0.isConquered } }

    /// Clipboard phrases the learner has conquered (recalled 3×). These are
    /// removed from the clipboard display and shown only in the Conquered auto-deck.
    var conqueredPhrases: [SavedPhrase] { phrases.filter { $0.isConquered } }

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

                let isConquered = d["isConquered"] == "true"
                let conqueredAt = d["conqueredAt"].flatMap { formatter.date(from: $0) }

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
                    nextReviewDate: nextReview,
                    isConquered:    isConquered,
                    conqueredAt:    conqueredAt
                )
            }.sorted { $0.savedAt > $1.savedAt }
        } else {
            phrases = []
        }
    }

    /// Wipe all saved phrases from memory and disk.
    func clearAll() {
        phrases = []
        defaults?.removeObject(forKey: SavedPhrase.userDefaultsKey)
        defaults?.synchronize()
        objectWillChange.send()
        NSLog("📋 [PhraseStore] cleared all phrases")
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

    /// Mark a clipboard phrase as conquered. It will no longer appear in the
    /// active clipboard list and will graduate to the Conquered auto-deck.
    func markConquered(_ phrase: SavedPhrase) {
        guard let index = phrases.firstIndex(where: { $0.id == phrase.id }) else { return }
        phrases[index].isConquered = true
        phrases[index].conqueredAt = Date()
        persist()
    }


    // MARK: - Demo seed (remove before public launch — see MOTIVATION.md)
    func seedDemoPhrasesIfNeeded() {
        // Always re-seed if clipboard is empty (flag only prevents overwriting real phrases)
        guard phrases.isEmpty else { return }
        UserDefaults.standard.set(true, forKey: "library_demo_seeded_v1")
        let demo: [SavedPhrase] = [
        SavedPhrase(id: UUID(), sourceText: "What's up?", translatedText: "¿Qué onda?", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -0, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Dude / Man", translatedText: "Güey", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Cool / Awesome", translatedText: "Chido", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "No way!", translatedText: "¡No manches!", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Alright / Lets go", translatedText: "Órale", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Its amazing", translatedText: "Está de pelos", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Sounds good to me", translatedText: "Me late", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Money / Cash", translatedText: "Feria", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -0, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Working hard", translatedText: "Chambeando", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Whats going on?", translatedText: "¿Qué pedo?", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Work / Job", translatedText: "Chamba", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "For real / Seriously", translatedText: "Neta", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Hell yeah!", translatedText: "¡A huevo!", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Beer", translatedText: "Chela", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "No", translatedText: "Nel", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -0, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Yes / Indeed", translatedText: "Simón", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Close friend", translatedText: "Carnal", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Buddy", translatedText: "Cuate", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Guy", translatedText: "Chavo", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Girl", translatedText: "Chava", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Right now", translatedText: "Ahorita", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Pardon me?", translatedText: "Mande", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -0, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Wow! / Oh my!", translatedText: "Híjole", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Hungover", translatedText: "Crudo", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "To be lazy", translatedText: "Echar la floja", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Excellent / Great", translatedText: "A todo dar", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "OK / Deal", translatedText: "Sale", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "From Mexico City", translatedText: "Chilango", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "How boring!", translatedText: "¡Qué hueva!", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -0, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Do not worry", translatedText: "No te apures", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Beautiful", translatedText: "Qué chula", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        SavedPhrase(id: UUID(), sourceText: "Street food taco", translatedText: "Taco de canasta", sourceLang: "en", targetLang: "es", savedAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), repetitions: 0, easinessFactor: 2.5, interval: 0, nextReviewDate: Date(), isConquered: false),
        ]
        phrases = demo
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
                "nextReviewDate": formatter.string(from: p.nextReviewDate),
                "isConquered": p.isConquered ? "true" : "false"
            ]
            if let notes = p.notes { d["notes"] = notes }
            if let tag = p.localityTag { d["localityTag"] = tag }
            if let ca = p.conqueredAt { d["conqueredAt"] = formatter.string(from: ca) }
            return d
        }
        defaults?.set(dicts, forKey: SavedPhrase.userDefaultsKey)
    }
}
