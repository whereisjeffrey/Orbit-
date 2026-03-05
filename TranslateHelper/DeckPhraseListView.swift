//
//  DeckPhraseListView.swift
//  TranslateHelper
//
//  Shown when the user taps "See My List" in the StudyOptionsCard (⋯ menu).
//  Displays all phrases in the current deck / clipboard list as readable rows.
//

import SwiftUI

struct DeckPhraseListView: View {
    @Environment(\.dismiss) var dismiss
    let phrases: [SavedPhrase]
    let deckName: String

    @State private var searchText = ""
    @AppStorage("studyModeSwapLanguage") private var swapLanguage: Bool = false

    var filtered: [SavedPhrase] {
        guard !searchText.isEmpty else { return phrases }
        return phrases.filter {
            $0.sourceText.localizedCaseInsensitiveContains(searchText) ||
            $0.translatedText.localizedCaseInsensitiveContains(searchText)
        }
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    // ── Language toggle pill ────────────────────────────
                    Button(action: {
                        let g = UIImpactFeedbackGenerator(style: .light)
                        g.impactOccurred()
                        withAnimation(.easeInOut(duration: 0.18)) {
                            swapLanguage.toggle()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Text(swapLanguage ? "🇲🇽 Spanish" : "🇺🇸 English")
                                .font(.custom("HelveticaNeue-Medium", size: 12))
                                .foregroundColor(.tsLabel)
                            Image(systemName: "arrow.right")
                                .font(.custom("HelveticaNeue-Bold", size: 11))
                                .foregroundColor(.tsSecondary)
                            Text(swapLanguage ? "🇺🇸 English" : "🇲🇽 Spanish")
                                .font(.custom("HelveticaNeue-Medium", size: 12))
                                .foregroundColor(.tsLabel)
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.custom("HelveticaNeue-Bold", size: 12))
                                .foregroundColor(.tsAccent)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.tsCard)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.tsBorder, lineWidth: 1))
                    }
                    .padding(.bottom, 12)

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
                                    PhraseListRow(phrase: phrase, index: index + 1, swapLanguage: swapLanguage)

                                    if index < filtered.count - 1 {
                                        Divider()
                                            .background(Color.tsBorder.opacity(0.5))
                                            .padding(.leading, 16)
                                    }
                                }
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationTitle(deckName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.tsAccent)
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .primaryAction) {
                    Text("\(phrases.count) cards")
                        .font(.custom("HelveticaNeue-Medium", size: 13))
                        .foregroundColor(.tsSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.tsCard)
                        .clipShape(Capsule())
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// MARK: - Phrase Row

private struct PhraseListRow: View {
    let phrase: SavedPhrase
    let index: Int
    let swapLanguage: Bool

    var primaryText: String   { swapLanguage ? phrase.translatedText : phrase.sourceText }
    var secondaryText: String { swapLanguage ? phrase.sourceText     : phrase.translatedText }
    var speakText: String     { swapLanguage ? phrase.sourceText     : phrase.translatedText }
    var speakLang: String     {
        let code = swapLanguage ? phrase.sourceLang : phrase.targetLang
        return code == "en" ? "en-US" : "es-MX"
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // Index badge
            Text("\(index)")
                .font(.custom("HelveticaNeue-Bold", size: 11))
                .foregroundColor(.tsSecondary)
                .frame(width: 24, alignment: .center)

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

            // Speaker button
            Button(action: {
                let g = UIImpactFeedbackGenerator(style: .light)
                g.impactOccurred()
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
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    DeckPhraseListView(
        phrases: [
            SavedPhrase(sourceText: "I love you", translatedText: "Te quiero",
                        sourceLang: "en", targetLang: "es", savedAt: Date(),
                        notes: "Heartfelt, everyday use", localityTag: "Universal"),
            SavedPhrase(sourceText: "What's up?", translatedText: "¿Qué onda?",
                        sourceLang: "en", targetLang: "es", savedAt: Date(),
                        notes: "Super casual Mexican slang", localityTag: "Mexico City")
        ],
        deckName: "Clipboard List"
    )
}
