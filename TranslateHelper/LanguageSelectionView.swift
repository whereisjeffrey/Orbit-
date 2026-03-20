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
// All 40 languages are fully selectable — no "coming soon" locks.
// Ordered by approximate global speaker count (native + L2).

let allLanguages: [Language] = [
    Language(flag: "🇺🇸", name: "English",    code: "en"),   // 1.5 B
    Language(flag: "🇨🇳", name: "Chinese",    code: "zh"),   // 1.1 B
    Language(flag: "🇪🇸", name: "Spanish",    code: "es"),   // 550 M
    Language(flag: "🇮🇳", name: "Hindi",      code: "hi"),   // 600 M
    Language(flag: "🇸🇦", name: "Arabic",     code: "ar"),   // 430 M
    Language(flag: "🇧🇩", name: "Bengali",    code: "bn"),   // 270 M
    Language(flag: "🇫🇷", name: "French",     code: "fr"),   // 280 M
    Language(flag: "🇧🇷", name: "Portuguese", code: "pt"),   // 260 M
    Language(flag: "🇷🇺", name: "Russian",    code: "ru"),   // 255 M
    Language(flag: "🇮🇩", name: "Indonesian", code: "id"),   // 200 M
    Language(flag: "🇵🇰", name: "Urdu",       code: "ur"),   // 230 M
    Language(flag: "🇩🇪", name: "German",     code: "de"),   // 130 M
    Language(flag: "🇯🇵", name: "Japanese",   code: "ja"),   // 125 M
    Language(flag: "🇳🇬", name: "Swahili",    code: "sw"),   // 200 M
    Language(flag: "🇰🇷", name: "Korean",     code: "ko"),   // 80 M
    Language(flag: "🇮🇷", name: "Persian",    code: "fa"),   // 110 M
    Language(flag: "🇻🇳", name: "Vietnamese", code: "vi"),   // 95 M
    Language(flag: "🇨🇿", name: "Czech",      code: "cs"),
    Language(flag: "🇮🇹", name: "Italian",    code: "it"),   // 90 M
    Language(flag: "🇹🇭", name: "Thai",       code: "th"),   // 60 M
    Language(flag: "🇵🇱", name: "Polish",     code: "pl"),   // 55 M
    Language(flag: "🇺🇦", name: "Ukrainian",  code: "uk"),   // 45 M
    Language(flag: "🇳🇱", name: "Dutch",      code: "nl"),   // 30 M
    Language(flag: "🇹🇷", name: "Turkish",    code: "tr"),   // 85 M
    Language(flag: "🇮🇱", name: "Hebrew",     code: "he"),   // 10 M
    Language(flag: "🇬🇷", name: "Greek",      code: "el"),   // 13 M
    Language(flag: "🇸🇪", name: "Swedish",    code: "sv"),   // 13 M
    Language(flag: "🇩🇰", name: "Danish",     code: "da"),   // 6 M
    Language(flag: "🇳🇴", name: "Norwegian",  code: "no"),   // 5 M
    Language(flag: "🇫🇮", name: "Finnish",    code: "fi"),   // 5 M
    Language(flag: "🇭🇺", name: "Hungarian",  code: "hu"),   // 13 M
    Language(flag: "🇷🇴", name: "Romanian",   code: "ro"),   // 24 M
    Language(flag: "🇧🇬", name: "Bulgarian",  code: "bg"),   // 8 M
    Language(flag: "🇭🇷", name: "Croatian",   code: "hr"),   // 7 M
    Language(flag: "🇸🇰", name: "Slovak",     code: "sk"),   // 5 M
    Language(flag: "🇵🇹", name: "Catalan",    code: "ca"),   // 10 M
    Language(flag: "🇮🇱", name: "Malay",      code: "ms"),   // 80 M
    Language(flag: "🇵🇭", name: "Filipino",   code: "fil"),  // 90 M
    Language(flag: "🇿🇦", name: "Afrikaans",  code: "af"),   // 17 M
    Language(flag: "🇮🇳", name: "Tamil",      code: "ta"),   // 85 M
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

    @State private var nativeLanguage: Language = {
        let localeCode = Locale.current.language.languageCode?.identifier ?? "en"
        let baseCode = localeCode.components(separatedBy: "-").first ?? "en"
        return nativeLanguages.first(where: { $0.code == baseCode }) ?? nativeLanguages[0]
    }()

    @State private var searchText: String = ""

    var filteredLanguages: [Language] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return allLanguages
        }
        return allLanguages.filter {
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

                // ── Nav bar ────────────────────────────────────────────
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.custom("HelveticaNeue-Medium", size: 22))
                            .foregroundColor(.tsAccent)
                    }
                    .frame(width: 40, height: 40)

                    Spacer()

                    // Progress bar
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.tsLabel.opacity(0.1))
                            .frame(width: 128, height: 6)
                        Capsule()
                            .fill(Color.tsAccent)
                            .frame(width: 128 * (CGFloat(step) / CGFloat(totalSteps)), height: 6)
                    }

                    Spacer()

                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.custom("HelveticaNeue-Medium", size: 16))
                            .foregroundColor(.tsAccent)
                    }
                    .frame(width: 40, height: 40)
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
                            Text("Please select your native language")
                                .font(.custom("HelveticaNeue", size: 17))
                                .foregroundColor(.tsSecondary)
                        }
                        .padding(.bottom, 24)

                        // Native language picker
                        TSPickerField(label: "\(nativeLanguage.flag) \(nativeLanguage.name)") {
                            ForEach(nativeLanguages) { lang in
                                Button {
                                    nativeLanguage = lang
                                } label: {
                                    Label("\(lang.flag) \(lang.name)", systemImage: "")
                                }
                            }
                        }
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
                                .stroke(Color.tsBorder.opacity(0.6), lineWidth: 1)
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
                            .foregroundColor(.tsLabel)
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
