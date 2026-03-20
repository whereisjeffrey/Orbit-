//
//  DeckStore.swift
//  TranslateHelper
//
//  Single source of truth for user-created decks and their flashcard content.
//  Persists via UserDefaults App Group.
//

import Foundation
import Combine
import SwiftUI

// MARK: - DeckCard

struct DeckCard: Codable, Identifiable, Hashable {
    var id: UUID
    var english: String
    var spanish: String      // stores the target-language text regardless of which language it is
    var notes: String
    var targetLang: String   // ISO 639-1 code of the translated text (e.g. "zh", "es", "fr")
    var isConquered: Bool
    var repetitions: Int
    var easinessFactor: Double
    var interval: Int           // minutes
    var nextReviewDate: Date
    var conqueredAt: Date?

    init(
        id: UUID = UUID(),
        english: String,
        spanish: String,
        notes: String = "",
        targetLang: String = "es",
        isConquered: Bool = false,
        repetitions: Int = 0,
        easinessFactor: Double = 2.5,
        interval: Int = 0,
        nextReviewDate: Date = Date(),
        conqueredAt: Date? = nil
    ) {
        self.id = id
        self.english = english
        self.spanish = spanish
        self.notes = notes
        self.targetLang = targetLang
        self.isConquered = isConquered
        self.repetitions = repetitions
        self.easinessFactor = easinessFactor
        self.interval = interval
        self.nextReviewDate = nextReviewDate
        self.conqueredAt = conqueredAt
    }

    /// Convert to SavedPhrase so existing StudySourceWordView can consume deck cards.
    func toSavedPhrase() -> SavedPhrase {
        SavedPhrase(
            id: id,
            sourceText: english,
            translatedText: spanish,
            sourceLang: "en",
            targetLang: targetLang,   // use the actual language, not a hardcoded "es"
            savedAt: nextReviewDate,
            notes: notes,
            repetitions: repetitions,
            easinessFactor: easinessFactor,
            interval: interval,
            nextReviewDate: nextReviewDate
        )
    }
}

// MARK: - Deck

struct Deck: Codable, Identifiable {
    var id: UUID
    var emoji: String
    var name: String
    var deckDescription: String
    var isAI: Bool
    var tintName: String        // "blue" | "green" | "orange" | "red" | "purple" | "pink" | "yellow" | "mint"
    var cards: [DeckCard]
    var createdAt: Date

    // Computed (not encoded)
    var activeCards: [DeckCard]    { cards.filter { !$0.isConquered } }
    var conqueredCards: [DeckCard] { cards.filter { $0.isConquered } }
    var isFullyConquered: Bool     { !cards.isEmpty && cards.allSatisfy { $0.isConquered } }
    var tintColor: Color           { Color.fromDeckTint(tintName) }

    init(
        id: UUID = UUID(),
        emoji: String = "📚",
        name: String,
        deckDescription: String = "",
        isAI: Bool = false,
        tintName: String = "blue",
        cards: [DeckCard] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.emoji = emoji
        self.name = name
        self.deckDescription = deckDescription
        self.isAI = isAI
        self.tintName = tintName
        self.cards = cards
        self.createdAt = createdAt
    }
}

// MARK: - Color Helper

extension Color {
    static func fromDeckTint(_ name: String) -> Color {
        switch name {
        case "green":  return .green
        case "orange": return .orange
        case "red":    return .red
        case "purple": return .purple
        case "pink":   return .pink
        case "yellow": return .yellow
        case "mint":   return .mint
        case "teal":   return .teal
        case "indigo": return .indigo
        default:       return .blue
        }
    }
}

// MARK: - DeckStore

final class DeckStore: ObservableObject {
    static let shared = DeckStore()

    @Published private(set) var decks: [Deck] = []

    static let maxAIDecks      = 2
    static let maxCardsPerDeck = 100
    static let maxActiveDecks  = 5

    private let storageKey = "talkswitch_user_decks_v2"
    private let defaults   = UserDefaults(suiteName: "group.com.jeff.translatehelper")

    private init() { load() }

    // MARK: - Computed

    var aiDeckCount: Int      { decks.filter(\.isAI).count }
    var canCreateAIDeck: Bool { aiDeckCount < DeckStore.maxAIDecks }
    var canAddDeck: Bool      { decks.count < DeckStore.maxActiveDecks }

    /// All conquered cards across every user deck, newest first.
    var allConqueredDeckCards: [DeckCard] {
        decks
            .flatMap(\.conqueredCards)
            .sorted { ($0.conqueredAt ?? .distantPast) > ($1.conqueredAt ?? .distantPast) }
    }

    // MARK: - Deck Mutations

    func addDeck(_ deck: Deck) {
        guard decks.count < DeckStore.maxActiveDecks else { return }
        decks.insert(deck, at: 0)
        persist()
    }

    func updateDeck(_ deck: Deck) {
        guard let i = decks.firstIndex(where: { $0.id == deck.id }) else { return }
        decks[i] = deck
        persist()
    }

    func deleteDeck(_ deck: Deck) {
        decks.removeAll { $0.id == deck.id }
        persist()
    }

    // MARK: - Card Mutations

    func addCard(_ card: DeckCard, toDeckWithId id: UUID) {
        guard let i = decks.firstIndex(where: { $0.id == id }) else { return }
        guard decks[i].cards.count < DeckStore.maxCardsPerDeck else { return }
        decks[i].cards.append(card)
        persist()
    }

    /// Append a batch of generated cards (respects maxCardsPerDeck ceiling).
    func appendCards(_ cards: [DeckCard], toDeckWithId id: UUID) {
        guard let i = decks.firstIndex(where: { $0.id == id }) else { return }
        let remaining = DeckStore.maxCardsPerDeck - decks[i].cards.count
        let toAdd = Array(cards.prefix(max(remaining, 0)))
        decks[i].cards.append(contentsOf: toAdd)
        persist()
    }

    func markCardConquered(cardId: UUID, inDeckId deckId: UUID) {
        guard
            let di = decks.firstIndex(where: { $0.id == deckId }),
            let ci = decks[di].cards.firstIndex(where: { $0.id == cardId })
        else { return }
        decks[di].cards[ci].isConquered = true
        decks[di].cards[ci].conqueredAt = Date()
        persist()
    }

    // MARK: - Persistence

    private func load() {
        guard
            let data = defaults?.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([Deck].self, from: data)
        else { decks = []; return }
        decks = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(decks) else { return }
        defaults?.set(data, forKey: storageKey)
    }
}
