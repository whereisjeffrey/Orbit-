//
//  LanguageSelectionView.swift
//  TranslateHelper
//

import SwiftUI

struct Language: Identifiable, Hashable, Codable {
    let id: UUID
    let flag: String
    let name: String
    let code: String

    init(id: UUID = UUID(), flag: String, name: String, code: String) {
        self.id = id
        self.flag = flag
        self.name = name
        self.code = code
    }
}

// MARK: - Language Catalogue
// All languages fully selectable — no "coming soon" locks.
// Ordered by most studied/popular among English speakers
// (based on MLA, Duolingo, and university enrollment data).

// MVP: 10 languages — the most studied by English speakers with the best AI support.
// All 39 remain in LanguageManager/keyboard for future expansion.
let allLanguages: [Language] = [
    Language(flag: "🇺🇸", name: "English",    code: "en"),
    Language(flag: "🇪🇸", name: "Spanish",    code: "es"),
    Language(flag: "🇫🇷", name: "French",     code: "fr"),
    Language(flag: "🇮🇹", name: "Italian",    code: "it"),
    Language(flag: "🇧🇷", name: "Portuguese", code: "pt"),
    Language(flag: "🇩🇪", name: "German",     code: "de"),
    Language(flag: "🇯🇵", name: "Japanese",   code: "ja"),
    Language(flag: "🇨🇳", name: "Chinese",    code: "zh"),
    Language(flag: "🇰🇷", name: "Korean",     code: "ko"),
    Language(flag: "🇸🇦", name: "Arabic",     code: "ar"),
    Language(flag: "🇳🇱", name: "Dutch",      code: "nl"),
]

// Native language picker — same full catalogue so anyone can pick their mother tongue
let nativeLanguages: [Language] = allLanguages

// MARK: - Language Selection View

struct LanguageSelectionView: View {
    var step: Int = 1
    var totalSteps: Int = 3
    @Binding var selectedLanguage: Language?
    let onBack: () -> Void
    let onSkip: () -> Void
    let onContinue: () -> Void

    private let nativeLanguage: Language = Language(flag: "🇺🇸", name: "English", code: "en")

    @State private var searchText: String = ""

    /// Languages available to learn — excludes English (the user's native language)
    private var selectableLanguages: [Language] {
        allLanguages.filter { $0.code != "en" }
    }

    var filteredLanguages: [Language] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return selectableLanguages
        }
        return selectableLanguages.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.tsBackground.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Nav bar with progress ──────────────────────────────
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.tsLabel)
                    }
                    .frame(width: 40, height: 40)

                    Spacer()

                    OnboardingProgressBar(currentStep: 1, totalSteps: 6)

                    Spacer()

                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        // ── Native language section ───────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("My native language")
                                .font(.custom("HelveticaNeue-Bold", size: 34))
                                .foregroundColor(.tsLabel)
                            Text("Your native language is set to English.")
                                .font(.custom("HelveticaNeue", size: 17))
                                .foregroundColor(.tsSecondary)
                        }
                        .padding(.bottom, 24)

                        // Native language — static English chip
                        HStack(spacing: 10) {
                            Text(nativeLanguage.flag)
                                .font(.system(size: 22))
                            Text(nativeLanguage.name)
                                .font(.custom("HelveticaNeue-Medium", size: 17))
                                .foregroundColor(.tsLabel)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.tsAccent)
                                .font(.system(size: 18))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.tsCard)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.tsAccent.opacity(0.5), lineWidth: 1)
                        )
                        .padding(.bottom, 32)

                        // ── Learn section ─────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("I want to learn...")
                                .font(.custom("HelveticaNeue-Bold", size: 34))
                                .foregroundColor(.tsLabel)
                            Text("Select the language you'd like to master. You can add more later.")
                                .font(.custom("HelveticaNeue", size: 17))
                                .foregroundColor(.tsSecondary)
                        }
                        .padding(.bottom, 16)

                        // ── Search bar ────────────────────────────────
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.tsSecondary)
                            TextField("Search language...", text: $searchText)
                                .font(.custom("HelveticaNeue", size: 16))
                                .foregroundColor(.tsLabel)
                                .autocorrectionDisabled()
                            if !searchText.isEmpty {
                                Button {
                                    withAnimation(.easeOut(duration: 0.15)) {
                                        searchText = ""
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 15))
                                        .foregroundColor(.tsSecondary)
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.tsCard)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.tsBorder, lineWidth: 1)
                        )
                        .padding(.bottom, 20)

                        // ── Language grid — 2 columns, all selectable ─
                        if filteredLanguages.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 32))
                                    .foregroundColor(.tsSecondary.opacity(0.5))
                                Text("No languages match \"\(searchText)\"")
                                    .font(.custom("HelveticaNeue", size: 15))
                                    .foregroundColor(.tsSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 48)
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(filteredLanguages) { language in
                                    LanguageCard(
                                        language: language,
                                        isSelected: selectedLanguage?.code == language.code,
                                        isComingSoon: false
                                    ) {
                                        selectedLanguage = language
                                    }
                                }
                            }
                        }

                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
            }

            // ── Fixed bottom CTA ───────────────────────────────────────
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color.tsBackground.opacity(0), Color.tsBackground],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 32)
                .allowsHitTesting(false)

                VStack(spacing: 16) {
                    Button(action: onContinue) {
                        Text("Continue")
                            .font(.custom("HelveticaNeue-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(selectedLanguage != nil ? Color.tsAccent : Color.tsSecondary.opacity(0.35))
                            .clipShape(Capsule())
                    }
                    .disabled(selectedLanguage == nil)
                    .animation(.easeInOut(duration: 0.2), value: selectedLanguage != nil)
                    .padding(.horizontal, 24)

                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.custom("HelveticaNeue", size: 15))
                            .foregroundColor(.tsSecondary)
                    }

                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.tsLabel.opacity(0.2))
                        .frame(width: 128, height: 5)
                        .padding(.bottom, 8)
                }
                .background(Color.tsBackground)
            }
        }
    }
}

// MARK: - Language Card
struct LanguageCard: View {
    let language: Language
    let isSelected: Bool
    var isComingSoon: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 8) {
                    Text(language.flag)
                        .font(.custom("HelveticaNeue", size: 40))
                        .opacity(isComingSoon ? 0.45 : 1)
                    Text(language.name)
                        .font(.custom("HelveticaNeue-Medium", size: 17))
                        .foregroundColor(isComingSoon ? .tsSecondary : .tsLabel)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, 8)
                .background(Color.tsCard.opacity(isComingSoon ? 0.5 : 1))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? Color.tsAccent : Color.tsBorder.opacity(isComingSoon ? 0.4 : 1),
                            lineWidth: isSelected ? 2 : 1
                        )
                )

                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Color.tsAccent)
                            .frame(width: 20, height: 20)
                        Image(systemName: "checkmark")
                            .font(.custom("HelveticaNeue-Bold", size: 10))
                            .foregroundColor(.white)
                    }
                    .padding(8)
                }

                if isComingSoon {
                    Text("Soon")
                        .font(.custom("HelveticaNeue-Bold", size: 9))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.tsSecondary.opacity(0.7))
                        .clipShape(Capsule())
                        .padding(8)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isComingSoon)
    }
}
