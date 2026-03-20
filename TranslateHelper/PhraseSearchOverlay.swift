//
//  PhraseSearchOverlay.swift
//  TranslateHelper
//
//  A floating results panel that appears below the search bar in LibraryView
//  whenever the user types. Tapping any row opens PhraseDetailSheet — a
//  compact card overlay showing the phrase in both languages with TTS support.
//

import SwiftUI

// MARK: - Search Results Overlay

/// Drop this inside the LibraryView ZStack, positioned below the search bar.
/// Pass `searchText` as a Binding and `phrases` as the searchable corpus.
struct PhraseSearchOverlay: View {
    @Binding var searchText: String
    let allPhrases: [SavedPhrase]
    @Binding var selectedPhrase: SavedPhrase?

    @Environment(\.colorScheme) var colorScheme

    // Both source- and target-language matches, deduplicated
    var results: [SavedPhrase] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
        return allPhrases.filter {
            $0.sourceText.localizedCaseInsensitiveContains(searchText) ||
            $0.translatedText.localizedCaseInsensitiveContains(searchText) ||
            ($0.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var body: some View {
        if !searchText.isEmpty {
            VStack(spacing: 0) {
                if results.isEmpty {
                    // Empty state
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15))
                            .foregroundColor(.tsSecondary)
                        Text("No phrases match \"\(searchText)\"")
                            .font(.custom("HelveticaNeue", size: 14))
                            .foregroundColor(.tsSecondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.tsCard)
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.10),
                                    radius: 12, x: 0, y: 6)
                    )
                    .padding(.horizontal, 16)
                } else {
                    // Result rows
                    VStack(spacing: 0) {
                        ForEach(Array(results.enumerated()), id: \.element.id) { idx, phrase in
                            Button {
                                let g = UIImpactFeedbackGenerator(style: .light)
                                g.impactOccurred()
                                selectedPhrase = phrase
                            } label: {
                                SearchResultRow(phrase: phrase, query: searchText)
                            }
                            .buttonStyle(PlainButtonStyle())

                            if idx < results.count - 1 {
                                Divider()
                                    .background(Color.tsBorder.opacity(0.5))
                                    .padding(.leading, 16)
                            }
                        }

                        // Footer count
                        HStack {
                            Spacer()
                            Text("\(results.count) phrase\(results.count == 1 ? "" : "s") found")
                                .font(.custom("HelveticaNeue-Medium", size: 11))
                                .foregroundColor(.tsSecondary)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .background(Color.tsCard)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.tsCard)
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.10),
                                    radius: 12, x: 0, y: 6)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                }
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Single Result Row

private struct SearchResultRow: View {
    let phrase: SavedPhrase
    let query: String

    private var sourceLang: Language? { allLanguages.first(where: { $0.code == phrase.sourceLang }) }
    private var targetLang: Language? { allLanguages.first(where: { $0.code == phrase.targetLang }) }

    var body: some View {
        HStack(spacing: 12) {
            // Language indicator
            VStack(spacing: 2) {
                Text(sourceLang?.flag ?? "🏴")
                    .font(.system(size: 13))
                Image(systemName: "arrow.down")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(.tsSecondary)
                Text(targetLang?.flag ?? "🏴")
                    .font(.system(size: 13))
            }

            // Text content
            VStack(alignment: .leading, spacing: 3) {
                HighlightedText(phrase.sourceText, highlight: query, baseFont: .custom("HelveticaNeue-Medium", size: 15))
                HighlightedText(phrase.translatedText, highlight: query, baseFont: .custom("HelveticaNeue", size: 13), baseColor: .tsSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.tsSecondary.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Highlighted Text helper
// Wraps the query match in a bold, accent-coloured span.

struct HighlightedText: View {
    let text: String
    let highlight: String
    var baseFont: Font = .body
    var baseColor: Color = .tsLabel

    init(_ text: String, highlight: String, baseFont: Font = .body, baseColor: Color = .tsLabel) {
        self.text = text
        self.highlight = highlight
        self.baseFont = baseFont
        self.baseColor = baseColor
    }

    var body: some View {
        if highlight.isEmpty {
            Text(text)
                .font(baseFont)
                .foregroundColor(baseColor)
        } else {
            build()
        }
    }

    @ViewBuilder
    private func build() -> some View {
        if let range = text.range(of: highlight, options: [.caseInsensitive, .diacriticInsensitive]) {
            let before = String(text[text.startIndex..<range.lowerBound])
            let match  = String(text[range])
            let after  = String(text[range.upperBound...])

            (Text(before).font(baseFont).foregroundColor(baseColor) +
             Text(match).font(baseFont).bold().foregroundColor(.tsAccent) +
             Text(after).font(baseFont).foregroundColor(baseColor))
            .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(text).font(baseFont).foregroundColor(baseColor)
        }
    }
}

// MARK: - Phrase Detail Sheet
//
// A compact mini‑card modal. Opens when the user taps a result row.
// Shows both languages, orientation swap, TTS, and a "Study this card" CTA.

struct PhraseDetailSheet: View {
    let phrase: SavedPhrase
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var isFlipped: Bool = false
    @AppStorage("studyModeSwapLanguage") private var swapLanguage: Bool = false

    private var sourceLang: Language? { allLanguages.first(where: { $0.code == phrase.sourceLang }) }
    private var targetLang: Language? { allLanguages.first(where: { $0.code == phrase.targetLang }) }

    // Orientation-aware display values
    private var frontText: String  { swapLanguage ? phrase.translatedText : phrase.sourceText }
    private var backText: String   { swapLanguage ? phrase.sourceText     : phrase.translatedText }
    private var frontLang: Language? { swapLanguage ? targetLang : sourceLang }
    private var backLang: Language?  { swapLanguage ? sourceLang : targetLang }

    private var ttsLangCode: String {
        TTSService.bcp47Locale(for: phrase.targetLang)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(Color.tsSecondary.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 16)

            // ── Language swap pill ─────────────────────────────────────
            Button {
                let g = UIImpactFeedbackGenerator(style: .light)
                g.impactOccurred()
                withAnimation(.easeInOut(duration: 0.2)) {
                    swapLanguage.toggle()
                    isFlipped = false // reset flip when orientation changes
                }
            } label: {
                HStack(spacing: 6) {
                    Text(frontLang?.flag ?? "🏴").font(.system(size: 15))
                    Text(frontLang?.name ?? phrase.sourceLang)
                        .font(.custom("HelveticaNeue-Medium", size: 12))
                        .foregroundColor(.tsLabel)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.tsSecondary)
                    Text(backLang?.flag ?? "🏴").font(.system(size: 15))
                    Text(backLang?.name ?? phrase.targetLang)
                        .font(.custom("HelveticaNeue-Medium", size: 12))
                        .foregroundColor(.tsLabel)
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.tsAccent)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color.tsGrayCard)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.tsBorder, lineWidth: 1))
            }
            .padding(.bottom, 20)

            // ── Mini card ─────────────────────────────────────────────
            ZStack {
                // Front face
                MiniCardFace(
                    text: frontText,
                    isQuestion: true,
                    hint: "Tap to reveal"
                )
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? -180 : 0), axis: (x: 0, y: 1, z: 0))
                .zIndex(isFlipped ? 0 : 1)

                // Back face
                MiniCardBack(
                    frontText: frontText,
                    backText: backText,
                    phrase: phrase,
                    ttsLangCode: ttsLangCode
                )
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (x: 0, y: 1, z: 0))
                .zIndex(isFlipped ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .background(Color.tsGrayCard)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.tsAccent.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.06), radius: 16, x: 0, y: 6)
            .padding(.horizontal, 24)
            .onTapGesture {
                if !isFlipped {
                    let g = UIImpactFeedbackGenerator(style: .medium)
                    g.impactOccurred()
                    SoundEngine.shared.play(.flip)
                    withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                        isFlipped = true
                    }
                }
            }

            // ── Notes / cultural context ───────────────────────────────
            if let notes = phrase.notes, !notes.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "F5A623"))
                    Text(notes)
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.tsLabel.opacity(0.85))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(14)
                .background(Color(hex: "F5A623").opacity(colorScheme == .dark ? 0.08 : 0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: "F5A623").opacity(0.15), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }

            // ── Locality tag ──────────────────────────────────────────
            if let tag = phrase.localityTag, !tag.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 11))
                    Text(tag)
                        .font(.custom("HelveticaNeue-Medium", size: 12))
                }
                .foregroundColor(.tsAccent.opacity(0.8))
                .padding(.top, 8)
            }

            Spacer()
        }
        .background(
            colorScheme == .dark
                ? Color.tsBackground
                : Color(UIColor.systemGroupedBackground)
        )
        .presentationDetents([.height(440)])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(28)
    }
}

// MARK: - Mini card faces

private struct MiniCardFace: View {
    let text: String
    let isQuestion: Bool
    let hint: String

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Text(text)
                .font(.custom("HelveticaNeue-Bold", size: 26))
                .foregroundColor(.tsLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.tsAccent)
                Text(hint)
                    .font(.custom("HelveticaNeue-Medium", size: 13))
                    .foregroundColor(.tsSecondary.opacity(0.6))
            }
            .padding(.bottom, 20)
        }
    }
}

private struct MiniCardBack: View {
    let frontText: String
    let backText: String
    let phrase: SavedPhrase
    let ttsLangCode: String

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 14) {
                // Source side (dimmer)
                Text(frontText)
                    .font(.custom("HelveticaNeue-Medium", size: 17))
                    .foregroundColor(.tsLabel.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Rectangle()
                    .fill(Color.tsSecondary.opacity(0.12))
                    .frame(height: 1)
                    .padding(.horizontal, 20)

                // Translation (bold)
                Text(backText)
                    .font(.custom("HelveticaNeue-Bold", size: 22))
                    .foregroundColor(.tsLabel)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            Spacer()

            // TTS button
            Button {
                let g = UIImpactFeedbackGenerator(style: .medium)
                g.impactOccurred()
                TTSService.shared.speak(phrase.translatedText, language: ttsLangCode)
            } label: {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.tsAccent)
                    .frame(width: 48, height: 48)
                    .background(Color.tsAccent.opacity(0.12))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.tsAccent, lineWidth: 1.5))
            }
            .padding(.bottom, 20)
        }
    }
}
