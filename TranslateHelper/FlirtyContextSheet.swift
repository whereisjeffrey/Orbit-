//
//  FlirtyContextSheet.swift
//  TranslateHelper
//
//  One-time preference flow triggered when user taps "Flirting & Banter" deck.
//  Two soft questions → AI generates a personalised deck → locked state becomes populated.
//
//  Stores to shared UserDefaults (app group) so the keyboard extension can also
//  read these when building the flirty system prompt.
//
//  Keys written:
//    ts_speaker_form         → "masculine" | "feminine" | "both"
//    ts_target_gender        → "male" | "female" | "varies"
//    ts_flirty_context_set   → Bool
//

import SwiftUI

// MARK: - Enums

enum SpeakerForm: String, CaseIterable {
    case masculine = "masculine"
    case feminine  = "feminine"
    case both      = "both"

    var label: String {
        switch self {
        case .masculine: return "He / Him forms"
        case .feminine:  return "She / Her forms"
        case .both:      return "Show me both"
        }
    }
    var emoji: String {
        switch self {
        case .masculine: return "🧔"
        case .feminine:  return "👩"
        case .both:      return "🔀"
        }
    }
    var description: String {
        switch self {
        case .masculine: return "\"Estoy contento\""
        case .feminine:  return "\"Estoy contenta\""
        case .both:      return "Both forms in notes"
        }
    }
}

enum TargetGender: String, CaseIterable {
    case male   = "male"
    case female = "female"
    case varies = "varies"

    var label: String {
        switch self {
        case .male:   return "Men"
        case .female: return "Women"
        case .varies: return "Both / It changes"
        }
    }
    var emoji: String {
        switch self {
        case .male:   return "👨"
        case .female: return "👩"
        case .varies: return "💫"
        }
    }
    var description: String {
        switch self {
        case .male:   return "\"Eres hermoso\""
        case .female: return "\"Eres hermosa\""
        case .varies: return "Context-aware"
        }
    }
}

// MARK: - Sheet States

private enum FlirtySheetStep {
    case targetGender     // Step 1: who are you talking to?
    case speakerForm      // Step 2: how do you refer to yourself?
    case generating       // Step 3: AI building the deck
    case done             // Step 4: success
}

// MARK: - FlirtyContextSheet

struct FlirtyContextSheet: View {
    @Environment(\.dismiss) var dismiss

    /// Called with the generated cards when done — parent adds to deck store
    var onComplete: ([GeneratedCard]) -> Void

    @State private var step: FlirtySheetStep = .targetGender
    @State private var selectedTarget: TargetGender? = nil
    @State private var selectedSpeaker: SpeakerForm? = nil
    @State private var generationError: String? = nil
    @State private var generatedCards: [GeneratedCard] = []

    private let appGroup = "group.com.jeff.translatehelper"

    var body: some View {
        ZStack {
            Color.tsBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<2) { i in
                        let active = (i == 0 && (step == .targetGender)) ||
                                     (i == 1 && (step == .speakerForm))
                        Capsule()
                            .fill(active ? Color.tsAccent : Color.tsCard)
                            .frame(width: active ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: step)
                    }
                }
                .padding(.top, 24)
                .opacity(step == .generating || step == .done ? 0 : 1)

                Spacer()

                switch step {
                case .targetGender:
                    stepView(
                        icon: "❤️",
                        headline: "Who do you usually talk to?",
                        subtext: "This helps us get the grammar right — no labels, just better translations.",
                        options: TargetGender.allCases.map {
                            SelectionOption(id: $0.rawValue, emoji: $0.emoji,
                                            label: $0.label, detail: $0.description)
                        },
                        selectedId: selectedTarget?.rawValue,
                        onSelect: { id in
                            withAnimation(.spring(response: 0.28)) {
                                selectedTarget = TargetGender(rawValue: id)
                            }
                        },
                        ctaLabel: "Next",
                        ctaEnabled: selectedTarget != nil,
                        onCTA: {
                            withAnimation(.easeInOut(duration: 0.25)) { step = .speakerForm }
                        }
                    )

                case .speakerForm:
                    stepView(
                        icon: "💬",
                        headline: "How do you speak about yourself?",
                        subtext: "Spanish grammar changes based on who's speaking. Pick what feels right.",
                        options: SpeakerForm.allCases.map {
                            SelectionOption(id: $0.rawValue, emoji: $0.emoji,
                                            label: $0.label, detail: $0.description)
                        },
                        selectedId: selectedSpeaker?.rawValue,
                        onSelect: { id in
                            withAnimation(.spring(response: 0.28)) {
                                selectedSpeaker = SpeakerForm(rawValue: id)
                            }
                        },
                        ctaLabel: "Build My Deck",
                        ctaEnabled: selectedSpeaker != nil,
                        onCTA: {
                            savePreferences()
                            withAnimation { step = .generating }
                            Task { await generateDeck() }
                        },
                        showBack: true,
                        onBack: {
                            withAnimation(.easeInOut(duration: 0.25)) { step = .targetGender }
                        }
                    )

                case .generating:
                    GeneratingView(error: generationError) {
                        // Retry
                        generationError = nil
                        Task { await generateDeck() }
                    }

                case .done:
                    DoneView {
                        onComplete(generatedCards)
                        dismiss()
                    }
                }

                Spacer()
            }
        }
    }

    // MARK: - Helpers

    private func savePreferences() {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let target = selectedTarget,
              let speaker = selectedSpeaker else { return }

        defaults.set(speaker.rawValue, forKey: "ts_speaker_form")
        defaults.set(target.rawValue,  forKey: "ts_target_gender")
        defaults.set(true,             forKey: "ts_flirty_context_set")
        defaults.synchronize()
    }

    private func generateDeck() async {
        guard let target = selectedTarget, let speaker = selectedSpeaker else { return }

        do {
            let cards = try await DeckGenerationService.shared
                .generateFlirtingDeck(speakerForm: speaker, targetGender: target)
            await MainActor.run {
                generatedCards = cards
                withAnimation(.spring(response: 0.5)) { step = .done }
            }
        } catch {
            await MainActor.run {
                generationError = error.localizedDescription
            }
        }
    }
}

// MARK: - Step View Builder

private struct SelectionOption: Identifiable {
    let id: String
    let emoji: String
    let label: String
    let detail: String
}

private func stepView(
    icon: String,
    headline: String,
    subtext: String,
    options: [SelectionOption],
    selectedId: String?,
    onSelect: @escaping (String) -> Void,
    ctaLabel: String,
    ctaEnabled: Bool,
    onCTA: @escaping () -> Void,
    showBack: Bool = false,
    onBack: (() -> Void)? = nil
) -> some View {
    VStack(spacing: 0) {
        Text(icon).font(.system(size: 56)).padding(.bottom, 16)

        Text(headline)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.tsLabel)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .padding(.bottom, 8)

        Text(subtext)
            .font(.system(size: 14))
            .foregroundColor(.tsSecondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .padding(.bottom, 32)

        VStack(spacing: 12) {
            ForEach(options) { option in
                Button(action: { onSelect(option.id) }) {
                    HStack(spacing: 16) {
                        Text(option.emoji)
                            .font(.system(size: 28))
                            .frame(width: 44)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.label)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.tsLabel)
                            Text(option.detail)
                                .font(.system(size: 13))
                                .foregroundColor(.tsSecondary)
                        }
                        Spacer()
                        Image(systemName: selectedId == option.id
                              ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 22))
                            .foregroundColor(selectedId == option.id ? .tsAccent : Color.tsCard)
                    }
                    .padding(16)
                    .background(selectedId == option.id
                                ? Color.tsAccent.opacity(0.08) : Color.tsCard)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedId == option.id
                                    ? Color.tsAccent.opacity(0.5) : Color.tsBorder,
                                    lineWidth: 1.5)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)

        // CTA
        Button(action: onCTA) {
            Text(ctaLabel)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(ctaEnabled
                    ? LinearGradient.tsBluePrimary
                    : LinearGradient(colors: [Color.tsCard],
                                     startPoint: .leading, endPoint: .trailing))
                .clipShape(Capsule())
                .shadow(color: ctaEnabled ? Color.tsAccent.opacity(0.35) : .clear,
                        radius: 14, x: 0, y: 4)
        }
        .disabled(!ctaEnabled)
        .padding(.horizontal, 24)

        if showBack, let onBack {
            Button("Back", action: onBack)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.tsSecondary)
                .padding(.top, 16)
        }
    }
}

// MARK: - Generating View

private struct GeneratingView: View {
    let error: String?
    let onRetry: () -> Void

    @State private var angle: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            if let error {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                Text("Something went wrong")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.tsLabel)
                Text(error)
                    .font(.system(size: 13))
                    .foregroundColor(.tsSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                Button("Try Again", action: onRetry)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.tsAccent)
            } else {
                ZStack {
                    Circle()
                        .stroke(Color.tsCard, lineWidth: 4)
                        .frame(width: 80, height: 80)
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient.tsBluePrimary,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(angle))
                        .onAppear {
                            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                angle = 360
                            }
                        }
                    Text("✨").font(.system(size: 28))
                }

                Text("Building your deck...")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.tsLabel)

                Text("GPT-4o mini is crafting phrases tailored to your preferences")
                    .font(.system(size: 14))
                    .foregroundColor(.tsSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 48)
            }
        }
    }
}

// MARK: - Done View

private struct DoneView: View {
    let onContinue: () -> Void
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            Text("😏")
                .font(.system(size: 72))
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        scale = 1.0; opacity = 1
                    }
                }

            Text("Your deck is ready")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.tsLabel)

            Text("25 personalised phrases — gendered perfectly for how you actually talk.")
                .font(.system(size: 15))
                .foregroundColor(.tsSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: onContinue) {
                Text("Let's Go")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(LinearGradient.tsBluePrimary)
                    .clipShape(Capsule())
                    .shadow(color: Color.tsAccent.opacity(0.35), radius: 14, x: 0, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
    }
}

// MARK: - Scale Button Style (if not already in DesignSystem)

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
