//
//  DeckPhraseListView.swift
//  TranslateHelper
//
//  Shown when the user taps "See My List" in the StudyOptionsCard (⋯ menu).
//  Supports multi-select for bulk delete and remix.

import SwiftUI

struct DeckPhraseListView: View {
    @Environment(\.dismiss) var dismiss
    let phrases: [SavedPhrase]
    let deckName: String
    var deckId: UUID?  // nil = clipboard, set = deck

    @State private var searchText = ""
    @State private var isSelectMode = false
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

                    // ── Language toggle pill ────────────────────────────
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.easeInOut(duration: 0.18)) { swapLanguage.toggle() }
                    }) {
                        HStack(spacing: 6) {
                            Text(leftLang?.flag ?? "🏴").font(.custom("HelveticaNeue-Medium", size: 13))
                            Text(leftLang?.name ?? "Source").font(.custom("HelveticaNeue-Medium", size: 12)).foregroundColor(.tsLabel)
                            Image(systemName: "arrow.right").font(.custom("HelveticaNeue-Bold", size: 11)).foregroundColor(.tsSecondary)
                            Text(rightLang?.flag ?? "🏴").font(.custom("HelveticaNeue-Medium", size: 13))
                            Text(rightLang?.name ?? "Target").font(.custom("HelveticaNeue-Medium", size: 12)).foregroundColor(.tsLabel)
                            Image(systemName: "arrow.triangle.2.circlepath").font(.custom("HelveticaNeue-Bold", size: 12)).foregroundColor(.tsAccent)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .background(Color.tsCard)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.tsBorder, lineWidth: 1))
                    }
                    .padding(.bottom, 12)

                    // ── Select mode banner ──────────────────────────────
                    if isSelectMode && !selected.isEmpty {
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
                                    HStack(spacing: 0) {
                                        // Checkbox in select mode
                                        if isSelectMode {
                                            Button(action: { toggleSelection(phrase.id) }) {
                                                Image(systemName: selected.contains(phrase.id) ? "checkmark.circle.fill" : "circle")
                                                    .font(.system(size: 22))
                                                    .foregroundColor(selected.contains(phrase.id) ? .tsAccent : .tsSecondary.opacity(0.4))
                                            }
                                            .padding(.leading, 16)
                                            .transition(.move(edge: .leading).combined(with: .opacity))
                                        }

                                        PhraseListRow(
                                            phrase: phrase,
                                            index: index + 1,
                                            swapLanguage: swapLanguage,
                                            showIndex: !isSelectMode
                                        )
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            if isSelectMode { toggleSelection(phrase.id) }
                                        }
                                    }

                                    if index < filtered.count - 1 {
                                        Divider()
                                            .background(Color.tsBorder.opacity(0.5))
                                            .padding(.leading, isSelectMode ? 54 : 16)
                                    }
                                }
                            }
                            .padding(.bottom, isSelectMode ? 100 : 40)  // room for toolbar
                        }
                    }
                }

                // ── Bottom toolbar (select mode) ───────────────────
                if isSelectMode && !selected.isEmpty {
                    VStack {
                        Spacer()
                        HStack(spacing: 16) {
                            // Delete button
                            Button(action: deleteSelected) {
                                HStack(spacing: 6) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 14))
                                    Text("Remove (\(selected.count))")
                                        .font(.custom("HelveticaNeue-Bold", size: 14))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color(hex: "#FF3B30"))
                                .clipShape(Capsule())
                            }

                            // Remix button (deck only)
                            if deckId != nil {
                                Button(action: remixSelected) {
                                    HStack(spacing: 6) {
                                        if isRemixing {
                                            ProgressView().tint(.white)
                                        } else {
                                            Image(systemName: "shuffle")
                                                .font(.system(size: 14))
                                        }
                                        Text("Remix")
                                            .font(.custom("HelveticaNeue-Bold", size: 14))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.tsAccent)
                                    .clipShape(Capsule())
                                }
                                .disabled(isRemixing)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            Color.tsBackground
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -4)
                        )
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .navigationTitle(deckName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isSelectMode ? "Cancel" : "Done") {
                        if isSelectMode {
                            withAnimation { isSelectMode = false; selected.removeAll() }
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundColor(.tsAccent)
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .primaryAction) {
                    if isSelectMode {
                        Text("\(livePhrases.count) cards")
                            .font(.custom("HelveticaNeue-Medium", size: 13))
                            .foregroundColor(.tsSecondary)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Color.tsCard)
                            .clipShape(Capsule())
                    } else {
                        Button("Select") {
                            withAnimation { isSelectMode = true }
                        }
                        .foregroundColor(.tsAccent)
                        .font(.custom("HelveticaNeue-Medium", size: 15))
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .animation(.easeInOut(duration: 0.25), value: isSelectMode)
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
            // Deck cards
            deckStore.removeCards(selected, fromDeckWithId: did)
        } else {
            // Clipboard phrases
            for id in selected {
                if let phrase = phraseStore.phrases.first(where: { $0.id == id }) {
                    phraseStore.delete(phrase)
                }
            }
        }
        selected.removeAll()

        // Exit select mode if no cards left
        if livePhrases.isEmpty {
            isSelectMode = false
        }
    }

    private func remixSelected() {
        guard let did = deckId,
              let deck = deckStore.decks.first(where: { $0.id == did }) else { return }

        isRemixing = true
        let selectedCards = deck.cards.filter { selected.contains($0.id) }
        let knownPhrases = selectedCards.map { "\($0.english) = \($0.spanish)" }.joined(separator: "\n")
        let total = deck.cards.count
        let ratio = selectionRatio

        // Determine difficulty based on how many they know
        let difficultyInstruction: String
        if ratio >= 0.6 {
            difficultyInstruction = "The user knows most of these — they're advanced. Generate RARE, impressive expressions: double meanings, regional deep cuts, idioms that would surprise even native speakers. Push the difficulty significantly."
        } else if ratio >= 0.3 {
            difficultyInstruction = "The user knows a good portion — they're intermediate to advanced. Generate more colloquial, nuanced expressions. Go beyond the basics."
        } else {
            difficultyInstruction = "The user only knows a few — generate same-level alternatives. Keep it accessible but fresh."
        }

        let langName = LanguageManager.languageName(for: LanguageManager.shared.targetLangRequired)
        let level = UserDefaults(suiteName: "group.com.jeff.translatehelper")?.string(forKey: "ts_self_reported_level") ?? "intermediate"

        Task {
            do {
                let generated = try await DeckGenerationService.shared.generateCustomDeck(
                    name: deck.name,
                    description: """
                    The user already knows these phrases (NEVER repeat them):
                    \(knownPhrases)

                    \(difficultyInstruction)
                    User's level: \(level). Language: \(langName).
                    Generate \(selectedCards.count) NEW replacement cards that are different from what they already know.
                    """,
                    cardCount: selectedCards.count
                )

                await MainActor.run {
                    // Remove the known cards
                    deckStore.removeCards(selected, fromDeckWithId: did)
                    // Add the new ones
                    let newCards = generated.map {
                        DeckCard(english: $0.sourceText, spanish: $0.translatedText,
                                 notes: $0.notes, targetLang: LanguageManager.shared.targetLangRequired)
                    }
                    deckStore.appendCards(newCards, toDeckWithId: did)

                    selected.removeAll()
                    isRemixing = false
                    isSelectMode = false
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    NSLog("🔄 [Remix] replaced \(selectedCards.count) cards (\(Int(ratio * 100))% ratio, difficulty: \(ratio >= 0.6 ? "advanced" : ratio >= 0.3 ? "intermediate" : "same-level"))")
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

// MARK: - Phrase Row

private struct PhraseListRow: View {
    let phrase: SavedPhrase
    let index: Int
    let swapLanguage: Bool
    var showIndex: Bool = true

    var primaryText: String   { swapLanguage ? phrase.translatedText : phrase.sourceText }
    var secondaryText: String { swapLanguage ? phrase.sourceText     : phrase.translatedText }
    var speakText: String     { swapLanguage ? phrase.sourceText     : phrase.translatedText }
    var speakLang: String     {
        let code = swapLanguage ? phrase.sourceLang : phrase.targetLang
        return TTSService.bcp47Locale(for: code)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            if showIndex {
                Text("\(index)")
                    .font(.custom("HelveticaNeue-Bold", size: 11))
                    .foregroundColor(.tsSecondary)
                    .frame(width: 24, alignment: .center)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(primaryText)
                    .font(.custom("HelveticaNeue-Medium", size: 16))
                    .foregroundColor(.tsLabel)
                    .fixedSize(horizontal: false, vertical: true)

                Text(secondaryText)
                    .font(.custom("HelveticaNeue", size: 14))
                    .foregroundColor(.tsSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let tag = phrase.localityTag, !tag.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.custom("HelveticaNeue", size: 9))
                        Text(tag)
                            .font(.custom("HelveticaNeue-Medium", size: 11))
                    }
                    .foregroundColor(.tsAccent.opacity(0.7))
                    .padding(.top, 2)
                }
            }

            Spacer()

            // Speaker button (hidden in select mode)
            if showIndex {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    TTSService.shared.speak(speakText, language: speakLang)
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.custom("HelveticaNeue", size: 16))
                        .foregroundColor(.tsAccent)
                        .frame(width: 40, height: 40)
                        .background(Color.tsAccent.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
