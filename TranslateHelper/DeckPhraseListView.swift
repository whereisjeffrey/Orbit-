//
//  DeckPhraseListView.swift
//  TranslateHelper
//
//  Shown when the user taps "Review" on the deck home screen.
//  Checkboxes always visible — tap to select, bottom toolbar appears for delete/remix.

import SwiftUI

struct DeckPhraseListView: View {
    @Environment(\.dismiss) var dismiss
    let phrases: [SavedPhrase]
    let deckName: String
    var deckId: UUID?  // nil = clipboard, set = deck

    @State private var searchText = ""
    @State private var selected: Set<UUID> = []
    @State private var isRemixing = false
    @AppStorage("studyModeSwapLanguage") private var swapLanguage: Bool = false
    @ObservedObject private var deckStore = DeckStore.shared
    @ObservedObject private var phraseStore = SharedPhraseStore.shared

    // Language metadata
    private var sourceLang: Language? {
        guard let code = phrases.first?.sourceLang else { return nil }
        return allLanguages.first(where: { $0.code == code })
    }
    private var targetLang: Language? {
        guard let code = phrases.first?.targetLang else { return nil }
        return allLanguages.first(where: { $0.code == code })
    }
    private var leftLang: Language?  { swapLanguage ? targetLang : sourceLang }
    private var rightLang: Language? { swapLanguage ? sourceLang : targetLang }

    private var livePhrases: [SavedPhrase] {
        if let did = deckId, let deck = deckStore.decks.first(where: { $0.id == did }) {
            return deck.cards.map { $0.toSavedPhrase() }
        }
        return phraseStore.activePhrases
    }

    var filtered: [SavedPhrase] {
        let source = livePhrases
        guard !searchText.isEmpty else { return source }
        return source.filter {
            $0.sourceText.localizedCaseInsensitiveContains(searchText) ||
            $0.translatedText.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var selectionRatio: Double {
        guard !livePhrases.isEmpty else { return 0 }
        return Double(selected.count) / Double(livePhrases.count)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tsBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // ── Search bar ─────────────────────────────────────
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.tsSecondary)
                            .font(.custom("HelveticaNeue", size: 15))
                        TextField("Search phrases…", text: $searchText)
                            .foregroundColor(.tsLabel)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 42)
                    .background(Color.tsCard)
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    // ── Selection banner ────────────────────────────────
                    if !selected.isEmpty {
                        HStack {
                            Text("\(selected.count) selected")
                                .font(.custom("HelveticaNeue-Medium", size: 14))
                                .foregroundColor(.tsLabel)
                            Spacer()
                            Button(action: selectAll) {
                                Text(selected.count == filtered.count ? "Deselect All" : "Select All")
                                    .font(.custom("HelveticaNeue-Medium", size: 13))
                                    .foregroundColor(.tsAccent)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.tsAccent.opacity(0.06))
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Divider().background(Color.tsBorder)

                    // ── Phrase list ─────────────────────────────────────
                    if filtered.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "text.badge.xmark")
                                .font(.custom("HelveticaNeue", size: 40))
                                .foregroundColor(.tsSecondary.opacity(0.4))
                            Text("No phrases found")
                                .font(.custom("HelveticaNeue-Medium", size: 17))
                                .foregroundColor(.tsSecondary)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(Array(filtered.enumerated()), id: \.element.id) { index, phrase in
                                    Button(action: { toggleSelection(phrase.id) }) {
                                        HStack(spacing: 12) {
                                            // Checkbox — always visible
                                            Image(systemName: selected.contains(phrase.id) ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 22))
                                                .foregroundColor(selected.contains(phrase.id) ? .tsAccent : .tsSecondary.opacity(0.3))

                                            // Phrase content
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(swapLanguage ? phrase.translatedText : phrase.sourceText)
                                                    .font(.custom("HelveticaNeue-Medium", size: 16))
                                                    .foregroundColor(.tsLabel)
                                                    .fixedSize(horizontal: false, vertical: true)

                                                Text(swapLanguage ? phrase.sourceText : phrase.translatedText)
                                                    .font(.custom("HelveticaNeue", size: 14))
                                                    .foregroundColor(.tsSecondary)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }

                                            Spacer()
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(selected.contains(phrase.id) ? Color.tsAccent.opacity(0.04) : Color.clear)

                                    if index < filtered.count - 1 {
                                        Divider()
                                            .background(Color.tsBorder.opacity(0.5))
                                            .padding(.leading, 50)
                                    }
                                }
                            }
                            .padding(.bottom, selected.isEmpty ? 40 : 100)
                        }
                    }
                }

                // ── Bottom toolbar ─────────────────────────────────
                if !selected.isEmpty {
                    VStack {
                        Spacer()
                        VStack(spacing: 0) {
                            HStack(spacing: 16) {
                                // Delete — soft red
                                Button(action: deleteSelected) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 14))
                                        Text("Delete")
                                            .font(.custom("HelveticaNeue-Bold", size: 14))
                                    }
                                    .foregroundColor(Color(hex: "#FF3B30"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(Color(hex: "#FF3B30").opacity(0.12))
                                    .clipShape(Capsule())
                                }

                                // Remix (deck only) — soft blue
                                if deckId != nil {
                                    Button(action: remixSelected) {
                                        HStack(spacing: 6) {
                                            if isRemixing {
                                                ProgressView().tint(.tsAccent)
                                            } else {
                                                Image(systemName: "shuffle")
                                                    .font(.system(size: 14))
                                            }
                                            Text("Remix")
                                                .font(.custom("HelveticaNeue-Bold", size: 14))
                                        }
                                        .foregroundColor(.tsAccent)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(Color.tsAccent.opacity(0.12))
                                        .clipShape(Capsule())
                                    }
                                    .disabled(isRemixing)
                                }
                            }
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                        }
                        .padding(.bottom, 12)
                        .background(
                            Color.tsBackground
                                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: -4)
                                .ignoresSafeArea(edges: .bottom)
                        )
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .navigationBarHidden(true)
            .safeAreaInset(edge: .top) {
                HStack {
                    Text(deckName)
                        .font(.custom("HelveticaNeue-Bold", size: 18))
                        .foregroundColor(.tsLabel)
                    Spacer()
                    TSDismissButton(action: { dismiss() })
                }
                .padding(.horizontal, 20)
                .padding(.top, 36)
                .padding(.bottom, 24)
                .background(Color.tsBackground)
            }
            .animation(.easeInOut(duration: 0.25), value: selected.isEmpty)
        }
    }

    // MARK: - Actions

    private func toggleSelection(_ id: UUID) {
        if selected.contains(id) {
            selected.remove(id)
        } else {
            selected.insert(id)
        }
    }

    private func selectAll() {
        if selected.count == filtered.count {
            selected.removeAll()
        } else {
            selected = Set(filtered.map(\.id))
        }
    }

    private func deleteSelected() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        if let did = deckId {
            deckStore.removeCards(selected, fromDeckWithId: did)
        } else {
            for id in selected {
                if let phrase = phraseStore.phrases.first(where: { $0.id == id }) {
                    phraseStore.delete(phrase)
                }
            }
        }
        selected.removeAll()
    }

    private func remixSelected() {
        guard let did = deckId,
              let deck = deckStore.decks.first(where: { $0.id == did }) else { return }

        isRemixing = true
        let selectedCards = deck.cards.filter { selected.contains($0.id) }
        let knownPhrases = selectedCards.map { "\($0.english) = \($0.spanish)" }.joined(separator: "\n")
        let ratio = selectionRatio

        let difficultyInstruction: String
        if ratio >= 0.6 {
            difficultyInstruction = "The user knows most of these — they're advanced. Generate RARE, impressive expressions: double meanings, regional deep cuts, idioms that would surprise even native speakers."
        } else if ratio >= 0.3 {
            difficultyInstruction = "The user knows a good portion — generate more colloquial, nuanced expressions. Go beyond the basics."
        } else {
            difficultyInstruction = "The user only knows a few — generate same-level alternatives. Keep it accessible but fresh."
        }

        let langName = LanguageManager.languageName(for: LanguageManager.shared.targetLangRequired)
        let level = UserDefaults(suiteName: "group.com.jeff.translatehelper")?.string(forKey: "ts_self_reported_level") ?? "intermediate"
        let city = UserLocationsStore.shared.locations.first?.displayName ?? "their city"

        // Collect all known phrases for exclusion
        let deckPhrases = DeckStore.shared.allKnownPhrases
        let clipPhrases = SharedPhraseStore.shared.phrases.map { "\($0.sourceText) = \($0.translatedText)" }
        let allKnown = deckPhrases + clipPhrases
        let exclusionBlock = allKnown.isEmpty ? "" : """
        EXCLUSION LIST — NEVER include any of these:
        \(allKnown.prefix(200).joined(separator: "\n"))
        """

        Task {
            do {
                let generated = try await DeckGenerationService.shared.generateCustomDeck(
                    name: deck.name,
                    description: """
                    The user already knows these (NEVER repeat them):
                    \(knownPhrases)

                    \(difficultyInstruction)
                    User level: \(level). Language: \(langName). User is in \(city).
                    Generate \(selectedCards.count) NEW replacement cards.
                    \(exclusionBlock)
                    """,
                    cardCount: selectedCards.count
                )

                await MainActor.run {
                    deckStore.removeCards(selected, fromDeckWithId: did)
                    let newCards = generated.map {
                        DeckCard(english: $0.sourceText, spanish: $0.translatedText,
                                 notes: $0.notes, targetLang: LanguageManager.shared.targetLangRequired)
                    }
                    deckStore.appendCards(newCards, toDeckWithId: did)

                    selected.removeAll()
                    isRemixing = false
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    NSLog("🔄 [Remix] replaced \(selectedCards.count) cards (\(Int(ratio * 100))% ratio)")
                }
            } catch {
                await MainActor.run {
                    isRemixing = false
                    NSLog("🔄 [Remix] failed: \(error)")
                }
            }
        }
    }
}
