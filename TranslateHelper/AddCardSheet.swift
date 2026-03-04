//
//  AddCardSheet.swift
//  TranslateHelper
//
//  Sheet for manually adding a word/phrase card to an existing user deck.
//  Presented from the global FAB → "Add to Deck".
//

import SwiftUI

struct AddCardSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var deckStore = DeckStore.shared

    @State private var english = ""
    @State private var spanish = ""
    @State private var notes = ""
    @State private var selectedDeckId: UUID? = nil
    @State private var didSave = false

    private var canSave: Bool {
        !english.trimmingCharacters(in: .whitespaces).isEmpty &&
        !spanish.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedDeckId != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tsBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // ── English ──────────────────────────────────────
                        InputSection(label: "ENGLISH") {
                            TextField("e.g. How much does this cost?", text: $english)
                                .styledField()
                        }

                        // ── Spanish ──────────────────────────────────────
                        InputSection(label: "SPANISH") {
                            TextField("e.g. ¿Cuánto cuesta esto?", text: $spanish)
                                .styledField()
                        }

                        // ── Notes ─────────────────────────────────────────
                        InputSection(label: "NOTES (OPTIONAL)") {
                            TextField(
                                "e.g. Used when shopping at markets",
                                text: $notes,
                                axis: .vertical
                            )
                            .lineLimit(2...4)
                            .styledField()
                        }

                        // ── Deck Picker ───────────────────────────────────
                        InputSection(label: "ADD TO DECK") {
                            if deckStore.decks.isEmpty {
                                HStack(spacing: 10) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.tsSecondary)
                                    Text("No decks yet — create one first using the + button.")
                                        .font(.system(size: 14))
                                        .foregroundColor(.tsSecondary)
                                }
                                .padding(16)
                                .background(Color.tsCard)
                                .cornerRadius(14)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(deckStore.decks) { deck in
                                        DeckPickerRow(
                                            deck: deck,
                                            isSelected: selectedDeckId == deck.id
                                        ) { selectedDeckId = deck.id }
                                    }
                                }
                            }
                        }

                        Spacer(minLength: 24)

                        // ── Save Button ───────────────────────────────────
                        Button(action: saveCard) {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Add to Deck")
                                    .font(.system(size: 17, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                canSave
                                    ? LinearGradient.tsBluePrimary
                                    : LinearGradient(colors: [Color.tsCard], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(Capsule())
                            .shadow(color: canSave ? Color.tsAccent.opacity(0.35) : .clear, radius: 14, x: 0, y: 4)
                        }
                        .disabled(!canSave)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle("Add to Deck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.tsAccent)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func saveCard() {
        guard let deckId = selectedDeckId, canSave else { return }
        let card = DeckCard(
            english: english.trimmingCharacters(in: .whitespaces),
            spanish: spanish.trimmingCharacters(in: .whitespaces),
            notes: notes.trimmingCharacters(in: .whitespaces)
        )
        DeckStore.shared.addCard(card, toDeckWithId: deckId)
        dismiss()
    }
}

// MARK: - Deck Picker Row

struct DeckPickerRow: View {
    let deck: Deck
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(deck.tintColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Text(deck.emoji).font(.system(size: 16))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(deck.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.tsLabel)
                    Text("\(deck.activeCards.count) active · \(deck.conqueredCards.count) conquered")
                        .font(.system(size: 12))
                        .foregroundColor(.tsSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.tsAccent)
                } else {
                    Circle()
                        .stroke(Color.tsBorder, lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                }
            }
            .padding(14)
            .background(isSelected ? Color.tsAccent.opacity(0.07) : Color.tsCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.tsAccent.opacity(0.45) : Color.tsBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Shared Input Section Helper

struct InputSection<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.tsSecondary)
                .tracking(1.0)
            content()
        }
    }
}

// MARK: - TextField Style Helper

private extension View {
    func styledField() -> some View {
        self
            .font(.system(size: 16))
            .foregroundColor(.tsLabel)
            .padding(14)
            .background(Color.tsCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.tsBorder, lineWidth: 1)
            )
    }
}
