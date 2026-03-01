//
//  PhraseStore.swift
//  TranslateHelperKeyboard
//
//  Created by TalkSwitch on 15/02/26.
//

import Foundation

struct SavedPhrase: Codable {
    let id: UUID
    let originalText: String
    let translatedText: String
    let sourceLang: String
    let targetLang: String
    let tone: String
    let timestamp: Date
    
    init(originalText: String, translatedText: String, sourceLang: String, targetLang: String, tone: Tone) {
        self.id = UUID()
        self.originalText = originalText
        self.translatedText = translatedText
        self.sourceLang = sourceLang
        self.targetLang = targetLang
        self.tone = tone.rawValue
        self.timestamp = Date()
    }
}

class PhraseStore {
    
    static let shared = PhraseStore()
    
    private let userDefaults: UserDefaults
    private let phrasesKey = "com.talkswitch.savedPhrases"
    
    private init() {
        // Use app group if available for sharing between keyboard and main app
        if let appGroupDefaults = UserDefaults(suiteName: "group.com.translatehelper") {
            self.userDefaults = appGroupDefaults
        } else {
            self.userDefaults = UserDefaults.standard
        }
    }
    
    /// Saves a phrase to local storage
    func savePhrase(_ phrase: SavedPhrase) {
        var phrases = loadPhrases()
        phrases.append(phrase)
        
        // Keep only last 100 phrases to avoid memory issues
        if phrases.count > 100 {
            phrases = Array(phrases.suffix(100))
        }
        
        if let encoded = try? JSONEncoder().encode(phrases) {
            userDefaults.set(encoded, forKey: phrasesKey)
        }
    }
    
    /// Loads all saved phrases
    func loadPhrases() -> [SavedPhrase] {
        guard let data = userDefaults.data(forKey: phrasesKey),
              let phrases = try? JSONDecoder().decode([SavedPhrase].self, from: data) else {
            return []
        }
        return phrases
    }
    
    /// Deletes a specific phrase
    func deletePhrase(id: UUID) {
        var phrases = loadPhrases()
        phrases.removeAll { $0.id == id }
        
        if let encoded = try? JSONEncoder().encode(phrases) {
            userDefaults.set(encoded, forKey: phrasesKey)
        }
    }
    
    /// Clears all saved phrases
    func clearAllPhrases() {
        userDefaults.removeObject(forKey: phrasesKey)
    }
}
