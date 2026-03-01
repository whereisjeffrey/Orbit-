//
//  LanguageSelectionView.swift
//  TranslateHelper
//

import SwiftUI

struct Language: Identifiable, Hashable {
    let id = UUID()
    let flag: String
    let name: String
}

let allLanguages: [Language] = [
    Language(flag: "\u{1F1F8}\u{1F1E6}", name: "Arabic"),
    Language(flag: "\u{1F1E7}\u{1F1F7}", name: "Portuguese"),
    Language(flag: "\u{1F1EA}\u{1F1F8}", name: "Spanish"),
    Language(flag: "\u{1F1EB}\u{1F1F7}", name: "French"),
    Language(flag: "\u{1F1E9}\u{1F1EA}", name: "German"),
    Language(flag: "\u{1F1EE}\u{1F1F9}", name: "Italian"),
    Language(flag: "\u{1F1EF}\u{1F1F5}", name: "Japanese"),
    Language(flag: "\u{1F1F0}\u{1F1F7}", name: "Korean"),
]

let nativeLanguages: [Language] = [
    Language(flag: "\u{1F1FA}\u{1F1F8}", name: "English"),
    Language(flag: "\u{1F1E7}\u{1F1F7}", name: "Portuguese"),
    Language(flag: "\u{1F1EA}\u{1F1F8}", name: "Spanish"),
    Language(flag: "\u{1F1EB}\u{1F1F7}", name: "French"),
    Language(flag: "\u{1F1E9}\u{1F1EA}", name: "German"),
    Language(flag: "\u{1F1EE}\u{1F1F9}", name: "Italian"),
    Language(flag: "\u{1F1EF}\u{1F1F5}", name: "Japanese"),
    Language(flag: "\u{1F1F0}\u{1F1F7}", name: "Korean"),
]

struct LanguageSelectionView: View {
    var step: Int = 1
    var totalSteps: Int = 3
    @Binding var selectedLanguage: Language?
    let onBack: () -> Void
    let onSkip: () -> Void
    let onContinue: () -> Void

    @State private var nativeLanguage: Language = nativeLanguages[0] // Default: English
    @State private var showNativePicker = false

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
                            .fill(Color.white.opacity(0.1))
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
                                .foregroundColor(.white)
                            Text("Please select your native language")
                                .font(.system(size: 17))
                                .foregroundColor(.tsSecondary)
                        }
                        .padding(.bottom, 24)

                        // Native language picker
                        Menu {
                            ForEach(nativeLanguages) { lang in
                                Button {
                                    nativeLanguage = lang
                                } label: {
                                    Label("\(lang.flag) \(lang.name)", systemImage: "")
                                }
                            }
                        } label: {
                            HStack {
                                Text("\(nativeLanguage.flag) \(nativeLanguage.name)")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundColor(.tsSecondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.tsCard)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tsBorder, lineWidth: 1))
                        }
                        .padding(.bottom, 32)

                        // ── Learn section ──────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("I want to learn...")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)
                            Text("Select the language you'd like to master. You can add more later.")
                                .font(.system(size: 17))
                                .foregroundColor(.tsSecondary)
                        }
                        .padding(.bottom, 24)

                        // Language grid — 2 columns
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(allLanguages) { language in
                                LanguageCard(
                                    language: language,
                                    isSelected: selectedLanguage?.name == language.name
                                ) {
                                    selectedLanguage = language
                                }
                            }
                        }
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
                        .fill(Color.white.opacity(0.2))
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
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 8) {
                    Text(language.flag)
                        .font(.system(size: 40))
                    Text(language.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, 8)
                .background(Color.tsCard)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.tsAccent : Color.clear, lineWidth: 2)
                )

                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Color.tsAccent)
                            .frame(width: 20, height: 20)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(8)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
