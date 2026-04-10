//
//  DeckHomeView.swift
//  TranslateHelper
//
//  Landing screen when tapping a deck — shows stats, Study and Review actions.

import SwiftUI

struct DeckHomeView: View {
    let deckId: UUID
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var deckStore = DeckStore.shared
    @State private var showStudy = false
    @State private var showReview = false

    private var deck: Deck? {
        deckStore.decks.first(where: { $0.id == deckId })
    }

    var body: some View {
        ZStack {
            TSGradientBackground().ignoresSafeArea()

            if let deck = deck {
                VStack(spacing: 24) {
                    Spacer()

                    // ── Deck identity ──────────────────────
                    VStack(spacing: 12) {
                        Text(deck.emoji)
                            .font(.system(size: 56))

                        Text(deck.name)
                            .font(.custom("HelveticaNeue-Bold", size: 28))
                            .foregroundColor(.tsLabel)
                            .multilineTextAlignment(.center)

                        if !deck.deckDescription.isEmpty {
                            Text(deck.deckDescription)
                                .font(.custom("HelveticaNeue", size: 15))
                                .foregroundColor(.tsSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    }

                    // ── Stats row ──────────────────────────
                    HStack(spacing: 24) {
                        deckStat(value: "\(deck.cards.count)", label: "cards")
                        deckStat(value: "\(deck.activeCards.count)", label: "active")
                        deckStat(value: "\(deck.conqueredCards.count)", label: "conquered")
                    }
                    .padding(.vertical, 16)

                    Spacer()

                    // ── Actions ────────────────────────────
                    VStack(spacing: 12) {
                        // Study — primary
                        Button(action: { showStudy = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 16))
                                Text("Study")
                                    .font(.custom("HelveticaNeue-Bold", size: 18))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(deck.activeCards.isEmpty ? Color.tsSecondary.opacity(0.35) : Color.tsAccent)
                            .clipShape(Capsule())
                        }
                        .disabled(deck.activeCards.isEmpty)

                        // Review — secondary
                        Button(action: { showReview = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 16))
                                Text("Review")
                                    .font(.custom("HelveticaNeue-Bold", size: 18))
                            }
                            .foregroundColor(.tsAccent)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.tsAccent.opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            } else {
                // Deck was deleted while viewing
                VStack {
                    Text("Deck not found")
                        .foregroundColor(.tsSecondary)
                    Button("Go Back") { dismiss() }
                        .foregroundColor(.tsAccent)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.tsSecondary)
                        .frame(width: 32, height: 32)
                        .background(Color.tsCard)
                        .clipShape(Circle())
                }
            }
        }
        .fullScreenCover(isPresented: $showStudy) {
            if let deck = deck {
                NavigationView {
                    StudySourceWordView(
                        phrases: deck.activeCards.map { $0.toSavedPhrase() },
                        listName: deck.name
                    )
                }
            }
        }
        .sheet(isPresented: $showReview) {
            if let deck = deck {
                DeckPhraseListView(
                    phrases: deck.cards.map { $0.toSavedPhrase() },
                    deckName: deck.name,
                    deckId: deck.id
                )
            }
        }
    }

    private func deckStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("HelveticaNeue-Bold", size: 22))
                .foregroundColor(.tsLabel)
            Text(label)
                .font(.custom("HelveticaNeue", size: 12))
                .foregroundColor(.tsSecondary)
        }
    }
}
