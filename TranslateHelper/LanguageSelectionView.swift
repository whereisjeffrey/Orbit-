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

// v1 Launch: Spanish is the only selectable language.
// All others are shown dimmed with "Coming Soon" and cannot be tapped.
let spanishLanguage = Language(flag: "\u{1F1EA}\u{1F1F8}", name: "Spanish", code: "es")

let allLanguages: [Language] = [
    spanishLanguage,                                                                  // ← Available in v1
    Language(flag: "\u{1F1E7}\u{1F1F7}", name: "Portuguese", code: "pt"),
    Language(flag: "\u{1F1EB}\u{1F1F7}", name: "French", code: "fr"),
    Language(flag: "\u{1F1E9}\u{1F1EA}", name: "German", code: "de"),
    Language(flag: "\u{1F1EE}\u{1F1F9}", name: "Italian", code: "it"),
    Language(flag: "\u{1F1EF}\u{1F1F5}", name: "Japanese", code: "ja"),
    Language(flag: "\u{1F1F0}\u{1F1F7}", name: "Korean", code: "ko"),
]

let nativeLanguages: [Language] = [
    Language(flag: "\u{1F1FA}\u{1F1F8}", name: "English", code: "en"),
    Language(flag: "\u{1F1E7}\u{1F1F7}", name: "Portuguese", code: "pt"),
    Language(flag: "\u{1F1EA}\u{1F1F8}", name: "Spanish", code: "es"),
    Language(flag: "\u{1F1EB}\u{1F1F7}", name: "French", code: "fr"),
    Language(flag: "\u{1F1E9}\u{1F1EA}", name: "German", code: "de"),
    Language(flag: "\u{1F1EE}\u{1F1F9}", name: "Italian", code: "it"),
    Language(flag: "\u{1F1EF}\u{1F1F5}", name: "Japanese", code: "ja"),
    Language(flag: "\u{1F1F0}\u{1F1F7}", name: "Korean", code: "ko"),
]

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

    // nativePickerOpen removed — TSPickerField no longer needs an isOpen binding

    /// Returns true if this language is available in v1 (Spanish only).
    private func isAvailable(_ language: Language) -> Bool {
        language.code == "es"
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
                            .font(.system(size: 22, weight: .semibold))
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
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.tsAccent)
                    }
                    .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        // ── Native language section ────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("My native language")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.tsLabel)
                            Text("Please select your native language")
                                .font(.system(size: 17))
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

                        // ── Learn section ──────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("I want to learn...")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.tsLabel)
                            Text("Select the language you'd like to master. You can add more later.")
                                .font(.system(size: 17))
                                .foregroundColor(.tsSecondary)
                        }
                        .padding(.bottom, 24)

                        // Language grid — 2 columns
                        // v1: Spanish only. Others are dimmed + "Coming Soon".
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(allLanguages) { language in
                                let available = isAvailable(language)
                                LanguageCard(
                                    language: language,
                                    isSelected: selectedLanguage?.name == language.name,
                                    isComingSoon: !available
                                ) {
                                    if available { selectedLanguage = language }
                                }
                            }
                        }

                        // Coming soon note
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 13))
                                .foregroundColor(.tsSecondary)
                            Text("More languages coming soon")
                                .font(.system(size: 13))
                                .foregroundColor(.tsSecondary)
                        }
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 120)
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
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                selectedLanguage != nil
                                    ? AnyShapeStyle(LinearGradient(
                                        colors: [Color(hex: "#3B99FC"), Color(hex: "#007AFF")],
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                                    : AnyShapeStyle(Color.tsCard)
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color.tsAccent.opacity(selectedLanguage != nil ? 0.3 : 0),
                                    radius: 16, x: 0, y: 4)
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
                        .font(.system(size: 40))
                        .opacity(isComingSoon ? 0.45 : 1)
                    Text(language.name)
                        .font(.system(size: 17, weight: .semibold))
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
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.tsLabel)
                    }
                    .padding(8)
                }

                // "Coming Soon" pill overlaid on top-right
                if isComingSoon {
                    Text("Soon")
                        .font(.system(size: 9, weight: .bold))
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


