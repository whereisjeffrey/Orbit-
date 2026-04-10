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
    @State private var showDeleteConfirmation = false

    private var deck: Deck? {
        deckStore.decks.first(where: { $0.id == deckId })
    }

    var body: some View {
        ZStack {
            TSGradientBackground().ignoresSafeArea()

            if let deck = deck {
                VStack(spacing: 20) {
                    Spacer().frame(height: 60)

                    // ── Deck identity ──────────────────────
                    VStack(spacing: 12) {
                        // Emoji with subtle blue glow
                        Text(deck.emoji)
                            .font(.system(size: 48))
                            .shadow(color: Color.tsAccent.opacity(0.3), radius: 16, x: 0, y: 0)
                            .shadow(color: Color.tsAccent.opacity(0.15), radius: 32, x: 0, y: 0)

                        Text(deck.name)
                            .font(.custom("HelveticaNeue-Bold", size: 22))
                            .foregroundColor(.tsLabel)
                            .multilineTextAlignment(.center)

                        if !deck.deckDescription.isEmpty {
                            Text(deck.deckDescription)
                                .font(.custom("HelveticaNeue", size: 14))
                                .foregroundColor(.tsSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }

                        // Card count — simple subline
                        Text("\(deck.cards.count) cards")
                            .font(.custom("HelveticaNeue-Medium", size: 13))
                            .foregroundColor(.tsSecondary)
                            .padding(.top, 4)
                    }

                    Spacer()

                    // ── Actions ────────────────────────────
                    VStack(spacing: 12) {
                        // Study — primary
                        Button(action: { showStudy = true }) {
                            Text("Study")
                                .font(.custom("HelveticaNeue-Bold", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(deck.activeCards.isEmpty ? Color.tsSecondary.opacity(0.35) : Color.tsAccent)
                                .clipShape(Capsule())
                        }
                        .disabled(deck.activeCards.isEmpty)

                        // Review — secondary
                        Button(action: { showReview = true }) {
                            Text("Review")
                                .font(.custom("HelveticaNeue-Bold", size: 18))
                                .foregroundColor(.tsAccent)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.tsAccent.opacity(0.1))
                                .clipShape(Capsule())
                        }

                        // Remove deck
                        Button(action: { showDeleteConfirmation = true }) {
                            Text("Remove Deck")
                                .font(.custom("HelveticaNeue-Medium", size: 15))
                                .foregroundColor(.tsSecondary)
                        }
                        .padding(.top, 8)
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
        .alert("Remove Deck?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                if let deck = deck {
                    deckStore.deleteDeck(deck)
                    dismiss()
                }
            }
        } message: {
            Text("This will permanently remove this deck and all its cards.")
        }
    }

}
