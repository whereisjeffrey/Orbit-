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
    let sourceLang: String   // "en" or "pt"
    let targetLang: String
    let savedAt: Date

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
                return SavedPhrase(
                    id:             UUID(uuidString: idStr) ?? UUID(),
                    sourceText:     source,
                    translatedText: trans,
                    sourceLang:     srcLang,
                    targetLang:     tgtLang,
                    savedAt:        date
                )
            }.sorted { $0.savedAt > $1.savedAt }
        } else {
            phrases = []
        }
    }

    func save(source: String, translation: String, sourceLang: String, targetLang: String) {
        let phrase = SavedPhrase(
            id: UUID(),
            sourceText: source,
            translatedText: translation,
            sourceLang: sourceLang,
            targetLang: targetLang,
            savedAt: Date()
        )
        phrases.insert(phrase, at: 0)
        persist()
    }

    func delete(_ phrase: SavedPhrase) {
        phrases.removeAll { $0.id == phrase.id }
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(phrases) else { return }
        defaults?.set(data, forKey: SavedPhrase.userDefaultsKey)
    }
}
