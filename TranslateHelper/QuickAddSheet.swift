//
//  QuickAddSheet.swift
//  TranslateHelper
//
//  Global FAB sheet. Two modes toggled at the top:
//    • Add Word/Phrase — enter text, auto-translate via DeepL, pick a deck, save.
//    • Create Deck     — emoji / tint / name / AI-generate or create empty.
//

import SwiftUI

// MARK: - QuickAddSheet

struct QuickAddSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var deckStore = DeckStore.shared

    /// 0 = Add Word/Phrase, 1 = Create Deck
    @State private var mode: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tsBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // ── Mode Picker ──────────────────────────────────────
                    ModePicker(selected: $mode)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 16)

                    Divider().background(Color.tsBorder)

                    // ── Content ──────────────────────────────────────────
                    if mode == 0 {
                        AddWordPane()
                    } else {
                        CreateDeckPane()
                    }
                }
            }
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
}

// MARK: - Mode Picker (two-segment pill toggle with icons)

private struct ModePicker: View {
    @Binding var selected: Int

    private let options: [(icon: String, label: String)] = [
        ("text.badge.plus",          "Add Word"),
        ("rectangle.stack.badge.plus", "Create Deck")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { i in
                let isOn = selected == i
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                        selected = i
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: options[i].icon)
                            .font(.custom("HelveticaNeue-Medium", size: 14))
                        Text(options[i].label)
                            .font(.custom("HelveticaNeue-Medium", size: 14))
                    }
                    .foregroundColor(isOn ? .white : .tsSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(isOn ? AnyShapeStyle(LinearGradient.tsBluePrimary) : AnyShapeStyle(Color.clear))
                    )
                }
            }
        }
        .padding(4)
        .background(Color.tsCard)
        .clipShape(Capsule())
    }
}

// MARK: - Add Word / Phrase Pane

private struct AddWordPane: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var deckStore = DeckStore.shared

    @State private var wordText      = ""
    @State private var translation   = ""
    @State private var isTranslating = false
    @State private var translateError: String? = nil
    @State private var selectedDeckId: UUID?   = nil
    @State private var showCreateDeckInline    = false
    @State private var didSave                 = false

    private var canSave: Bool {
        !wordText.trimmingCharacters(in: .whitespaces).isEmpty &&
        !translation.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedDeckId != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // ── Word / Phrase input ───────────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    Label("WORD OR PHRASE", systemImage: "character.cursor.ibeam")
                        .font(.custom("HelveticaNeue-Medium", size: 12))
                        .foregroundColor(.tsSecondary)
                        .tracking(0.8)

                    TextField("e.g. buenos días, ¿cómo estás?", text: $wordText)
                        .font(.custom("HelveticaNeue", size: 17))
                        .foregroundColor(.tsLabel)
                        .submitLabel(.done)
                        .padding(14)
                        .background(Color.tsCard)
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tsBorder, lineWidth: 1))
                        .onChange(of: wordText) { newVal in
                            // Debounce-style: clear old translation; translate after brief pause
                            translateError = nil
                            guard !newVal.trimmingCharacters(in: .whitespaces).isEmpty else {
                                translation = ""
                                return
                            }
                        }
                        .onSubmit { triggerTranslate() }

                    // Translate trigger button
                    HStack {
                        Spacer()
                        Button {
                            triggerTranslate()
                        } label: {
                            HStack(spacing: 5) {
                                if isTranslating {
                                    ProgressView()
                                        .scaleEffect(0.75)
                                        .tint(.tsAccent)
                                } else {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.custom("HelveticaNeue-Medium", size: 12))
                                }
                                Text(isTranslating ? "Translating…" : "Auto-translate")
                                    .font(.custom("HelveticaNeue-Medium", size: 13))
                            }
                            .foregroundColor(.tsAccent)
                        }
                        .disabled(wordText.trimmingCharacters(in: .whitespaces).isEmpty || isTranslating)
                    }
                }

                // ── Translation (editable) ────────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("TRANSLATION", systemImage: "globe")
                            .font(.custom("HelveticaNeue-Medium", size: 12))
                            .foregroundColor(.tsSecondary)
                            .tracking(0.8)
                        Spacer()
                        if !translation.isEmpty {
                            Text("Editable")
                                .font(.custom("HelveticaNeue", size: 11))
                                .foregroundColor(.tsSecondary.opacity(0.6))
                        }
                    }

                    ZStack(alignment: .topLeading) {
                        if translation.isEmpty && !isTranslating {
                            Text("Translation will appear here…")
                                .font(.custom("HelveticaNeue", size: 16))
                                .foregroundColor(.tsSecondary.opacity(0.45))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: $translation)
                            .font(.custom("HelveticaNeue", size: 16))
                            .foregroundColor(.tsLabel)
                            .frame(minHeight: 80)
                            .padding(10)
                            .scrollContentBackground(.hidden)
                    }
                    .background(Color.tsCard)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                translation.isEmpty ? Color.tsBorder : Color.tsAccent.opacity(0.35),
                                lineWidth: 1
                            )
                    )

                    if let err = translateError {
                        Label(err, systemImage: "exclamationmark.circle")
                            .font(.custom("HelveticaNeue", size: 12))
                            .foregroundColor(.orange)
                    }
                }

                // ── Deck Picker ───────────────────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    Label("SAVE TO DECK", systemImage: "rectangle.stack")
                        .font(.custom("HelveticaNeue-Medium", size: 12))
                        .foregroundColor(.tsSecondary)
                        .tracking(0.8)

                    if deckStore.decks.isEmpty {
                        EmptyDeckHint()
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

                    // Subtle create-deck shortcut
                    Button {
                        showCreateDeckInline = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle")
                                .font(.custom("HelveticaNeue", size: 13))
                            Text("Create a new deck")
                                .font(.custom("HelveticaNeue-Medium", size: 13))
                        }
                        .foregroundColor(.tsAccent.opacity(0.75))
                    }
                    .padding(.top, 4)
                }

                // ── Save button ───────────────────────────────────────
                Button(action: saveCard) {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.custom("HelveticaNeue-Medium", size: 16))
                        Text("Add to Deck")
                            .font(.custom("HelveticaNeue-Bold", size: 17))
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

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 48)
        }
        .sheet(isPresented: $showCreateDeckInline) {
            CreateDeckSheet()
        }
    }

    // MARK: - Translate

    private func triggerTranslate() {
        let trimmed = wordText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        isTranslating   = true
        translateError  = nil
        translation     = ""

        // Auto-detect source: if the text looks like it has Spanish characters translate ES→EN, else EN→ES
        // Simple heuristic: if any character is ñ, accented vowel, ¿, ¡ → assume Spanish input
        let spanishChars = CharacterSet(charactersIn: "áéíóúüñÁÉÍÓÚÜÑ¿¡")
        let isSpanish = trimmed.unicodeScalars.contains { spanishChars.contains($0) }

        let url = URL(string: "\(APIConfig.deeplBaseURL)/translate")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("DeepL-Auth-Key \(APIConfig.deeplAPIKey)", forHTTPHeaderField: "Authorization")

        let srcLang = isSpanish ? "ES" : "EN"
        let tgtLang = isSpanish ? "EN" : "ES"
        let body = "text=\(trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmed)&source_lang=\(srcLang)&target_lang=\(tgtLang)"
        req.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: req) { data, _, error in
            DispatchQueue.main.async {
                isTranslating = false
                if let error {
                    translateError = error.localizedDescription
                    return
                }
                guard let data else { translateError = "No data from server"; return }
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let translations = json["translations"] as? [[String: Any]],
                   let first = translations.first,
                   let text = first["text"] as? String {
                    translation = text
                } else {
                    translateError = "Could not read translation. Try editing manually."
                }
            }
        }.resume()
    }

    // MARK: - Save

    private func saveCard() {
        guard canSave, let deckId = selectedDeckId else { return }
        let card = DeckCard(
            english: wordText.trimmingCharacters(in: .whitespaces),
            spanish: translation.trimmingCharacters(in: .whitespaces)
        )
        DeckStore.shared.addCard(card, toDeckWithId: deckId)
        dismiss()
    }
}

// MARK: - Empty Deck Hint

private struct EmptyDeckHint: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle")
                .foregroundColor(.tsSecondary)
            Text("No decks yet — use the **Create Deck** tab to make one first.")
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.tsSecondary)
        }
        .padding(16)
        .background(Color.tsCard)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tsBorder, lineWidth: 1))
    }
}

// MARK: - Create Deck Pane
// Embeds the exact same form as CreateDeckSheet but without a NavigationStack wrapper
// (the parent QuickAddSheet already provides one).

private struct CreateDeckPane: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var deckStore = DeckStore.shared

    @State private var deckName        = ""
    @State private var deckDescription = ""
    @State private var useAI           = false      // default manual so word-adders land on add-word
    @State private var isGenerating    = false
    @State private var errorMessage: String? = nil
    @State private var selectedEmoji   = "📚"
    @State private var selectedTint    = "blue"

    let emojiOptions = ["📚","🎯","💼","🏥","🍽️","✈️","💬","🎵","⚽","🌆","💡","🛒","🎭","🏋️","🌍","🔬"]
    let tintOptions: [(name: String, color: Color)] = [
        ("blue", .blue), ("green", .green), ("orange", .orange),
        ("purple", .purple), ("pink", .pink), ("red", .red),
        ("yellow", .yellow), ("mint", .mint)
    ]

    var canCreate:     Bool { !deckName.trimmingCharacters(in: .whitespaces).isEmpty }
    var aiLimitReached: Bool { useAI && !deckStore.canCreateAIDeck }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // ── AI Limit Warning ─────────────────────────────────
                if aiLimitReached {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange).font(.custom("HelveticaNeue", size: 16))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("AI deck limit reached (\(deckStore.aiDeckCount)/\(DeckStore.maxAIDecks))")
                                .font(.custom("HelveticaNeue-Bold", size: 14)).foregroundColor(.tsLabel)
                            Text("Switch to Manual to create another, or delete an AI deck first.")
                                .font(.custom("HelveticaNeue", size: 12)).foregroundColor(.tsSecondary)
                        }
                    }
                    .padding(16).background(Color.orange.opacity(0.08)).cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.orange.opacity(0.25), lineWidth: 1))
                }

                // ── Emoji Picker ─────────────────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    Text("CHOOSE AN EMOJI")
                        .font(.custom("HelveticaNeue-Medium", size: 12)).foregroundColor(.tsSecondary).tracking(1.0)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(emojiOptions, id: \.self) { emoji in
                                Button { selectedEmoji = emoji } label: {
                                    Text(emoji).font(.custom("HelveticaNeue", size: 22))
                                        .frame(width: 44, height: 44)
                                        .background(selectedEmoji == emoji ? Color.tsAccent.opacity(0.15) : Color.tsCard)
                                        .cornerRadius(12)
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(
                                            selectedEmoji == emoji ? Color.tsAccent.opacity(0.6) : Color.clear, lineWidth: 1.5))
                                }
                            }
                        }
                    }
                }

                // ── Tint Picker ──────────────────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    Text("COLOUR")
                        .font(.custom("HelveticaNeue-Medium", size: 12)).foregroundColor(.tsSecondary).tracking(1.0)
                    HStack(spacing: 10) {
                        ForEach(tintOptions, id: \.name) { opt in
                            Button { selectedTint = opt.name } label: {
                                Circle().fill(opt.color).frame(width: 30, height: 30)
                                    .overlay(Circle().stroke(Color.white.opacity(0.9), lineWidth: 2)
                                        .scaleEffect(selectedTint == opt.name ? 1 : 0))
                                    .scaleEffect(selectedTint == opt.name ? 1.15 : 1.0)
                                    .animation(.spring(response: 0.2), value: selectedTint)
                            }
                        }
                        Spacer()
                    }
                }

                // ── Deck Name ────────────────────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    Text("DECK NAME")
                        .font(.custom("HelveticaNeue-Medium", size: 12)).foregroundColor(.tsSecondary).tracking(1.0)
                    TextField("e.g. Medical Radiology, Sports Slang…", text: $deckName)
                        .font(.custom("HelveticaNeue", size: 17)).foregroundColor(.tsLabel)
                        .padding(16).background(Color.tsCard).cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tsBorder, lineWidth: 1))
                }

                // ── Description ──────────────────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    Text("DESCRIBE WHAT YOU WANT TO LEARN")
                        .font(.custom("HelveticaNeue-Medium", size: 12)).foregroundColor(.tsSecondary).tracking(1.0)
                    TextField(
                        "e.g. Vocabulary for a radiology resident — anatomy terms and imaging procedures",
                        text: $deckDescription, axis: .vertical
                    )
                    .lineLimit(3...6).font(.custom("HelveticaNeue", size: 15)).foregroundColor(.tsLabel)
                    .padding(16).background(Color.tsCard).cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tsBorder, lineWidth: 1))
                    Text("The more detail you give, the better your AI cards will be.")
                        .font(.custom("HelveticaNeue", size: 12)).foregroundColor(.tsSecondary.opacity(0.7))
                }

                // ── AI vs Manual ─────────────────────────────────────
                VStack(alignment: .leading, spacing: 12) {
                    Text("HOW DO YOU WANT TO ADD CARDS?")
                        .font(.custom("HelveticaNeue-Medium", size: 12)).foregroundColor(.tsSecondary).tracking(1.0)
                    HStack(spacing: 12) {
                        ModeToggleCard(icon: "sparkles",   title: "Generate with AI",
                                       subtitle: "~50 cards created instantly",
                                       isSelected: useAI,    action: { useAI = true  })
                        ModeToggleCard(icon: "pencil",    title: "Add Manually",
                                       subtitle: "Build your own card by card",
                                       isSelected: !useAI,   action: { useAI = false })
                    }
                }

                // ── Info banner ──────────────────────────────────────
                if useAI && !aiLimitReached {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill").foregroundColor(.tsAccent).font(.custom("HelveticaNeue", size: 16))
                        Text("AI will generate up to 50 Spanish–English flashcard pairs.")
                            .font(.custom("HelveticaNeue", size: 13)).foregroundColor(.tsSecondary)
                    }
                    .padding(16).background(Color.tsAccent.opacity(0.06)).cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tsAccent.opacity(0.15), lineWidth: 1))
                }

                if let err = errorMessage {
                    HStack(spacing: 10) {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                        Text(err).font(.custom("HelveticaNeue", size: 13)).foregroundColor(.red)
                    }
                    .padding(14).background(Color.red.opacity(0.07)).cornerRadius(12)
                }

                Spacer(minLength: 32)

                // ── CTA button ───────────────────────────────────────
                Button(action: handleCreate) {
                    ZStack {
                        HStack(spacing: 10) {
                            Image(systemName: useAI ? "sparkles" : "rectangle.stack.badge.plus")
                                .font(.custom("HelveticaNeue-Medium", size: 16))
                            Text(useAI ? "Generate My Deck" : "Create Deck")
                                .font(.custom("HelveticaNeue-Bold", size: 17))
                        }
                        .foregroundColor(.white).opacity(isGenerating ? 0 : 1)
                        if isGenerating { ProgressView().tint(.white) }
                    }
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(canCreate && !aiLimitReached
                        ? LinearGradient.tsBluePrimary
                        : LinearGradient(colors: [Color.tsCard], startPoint: .leading, endPoint: .trailing))
                    .clipShape(Capsule())
                    .shadow(color: canCreate && !aiLimitReached ? Color.tsAccent.opacity(0.35) : .clear,
                            radius: 14, x: 0, y: 4)
                }
                .disabled(!canCreate || isGenerating || aiLimitReached)
            }
            .padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 48)
        }
    }

    // MARK: - handleCreate

    private func handleCreate() {
        guard canCreate else { return }
        errorMessage = nil
        if useAI {
            isGenerating = true
            Task {
                do {
                    let generated = try await DeckGenerationService.shared.generateCustomDeck(
                        name: deckName, description: deckDescription, cardCount: 50
                    )
                    let deckCards = generated.map {
                        DeckCard(english: $0.sourceText, spanish: $0.translatedText, notes: $0.notes)
                    }
                    let deck = Deck(emoji: selectedEmoji,
                                   name: deckName.trimmingCharacters(in: .whitespaces),
                                   deckDescription: deckDescription,
                                   isAI: true, tintName: selectedTint, cards: deckCards)
                    await MainActor.run { DeckStore.shared.addDeck(deck); isGenerating = false; dismiss() }
                } catch {
                    await MainActor.run { isGenerating = false; errorMessage = error.localizedDescription }
                }
            }
        } else {
            let deck = Deck(emoji: selectedEmoji,
                            name: deckName.trimmingCharacters(in: .whitespaces),
                            deckDescription: deckDescription,
                            isAI: false, tintName: selectedTint, cards: [])
            DeckStore.shared.addDeck(deck)
            dismiss()
        }
    }
}
