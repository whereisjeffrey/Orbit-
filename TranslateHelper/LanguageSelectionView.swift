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

struct LanguageSelectionView: View {
    @Binding var selectedLanguage: Language?
    let onContinue: () -> Void

    let languages: [Language] = [
        Language(flag: "🇸🇦", name: "Arabic"),
        Language(flag: "🇧🇷", name: "Portuguese"),
        Language(flag: "🇪🇸", name: "Spanish"),
        Language(flag: "🇫🇷", name: "French"),
        Language(flag: "🇩🇪", name: "German"),
        Language(flag: "🇮🇹", name: "Italian"),
        Language(flag: "🇯🇵", name: "Japanese"),
        Language(flag: "🇰🇷", name: "Korean"),
    ]

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.tsBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What language do you want to learn?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Text("You can add more languages later.")
                            .font(.system(size: 15))
                            .foregroundColor(.tsSecondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 56)
                    .padding(.bottom, 32)

                    // Language grid
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(languages) { language in
                            LanguageCard(
                                language: language,
                                isSelected: selectedLanguage?.name == language.name
                            ) {
                                selectedLanguage = language
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120) // space for CTA
                }
            }

            // Fixed bottom CTA
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color.tsBackground.opacity(0), Color.tsBackground],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 32)

                VStack(spacing: 16) {
                    Button(action: onContinue) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                selectedLanguage != nil
                                    ? AnyShapeStyle(LinearGradient.tsVibrant)
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
                        .font(.system(size: 36))
                    Text(language.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 8)
                .background(Color.tsCard)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.tsAccent : Color.clear, lineWidth: 2)
                )

                // Checkmark badge
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Color.tsAccent)
                            .frame(width: 20, height: 20)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: -8, y: 8)
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
