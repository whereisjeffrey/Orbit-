//
//  LevelAssessmentView.swift
//  TranslateHelper
//
//  Single-screen self-assessment: 5 descriptive options, one tap.
//  Appears during onboarding (skippable) and before first Coach feature (mandatory).
//  Sets initial difficulty for Lightning Round + Sol's conversation style.
//  Replaced by real performance data within days of use.
//

import SwiftUI

// MARK: - Self-Reported Level

enum SelfReportedLevel: String, CaseIterable, Codable {
    case beginner     = "beginner"       // A1-A2
    case basic        = "basic"          // A2-B1
    case intermediate = "intermediate"   // B1-B2
    case comfortable  = "comfortable"    // B2-C1
    case fluent       = "fluent"         // C1-C2

    var label: String {
        switch self {
        case .beginner:     return "I know a few words but struggle with conversations"
        case .basic:        return "I can handle basic conversations"
        case .intermediate: return "I can talk about most things but still make mistakes"
        case .comfortable:  return "I'm comfortable and just want to sharpen up"
        case .fluent:       return "I'm fluent but still slip up occasionally"
        }
    }

    var icon: String {
        switch self {
        case .beginner:     return "🌱"
        case .basic:        return "💬"
        case .intermediate: return "🗣"
        case .comfortable:  return "💪"
        case .fluent:       return "⭐"
        }
    }

    /// Maps to initial CEFR level for Lightning Round + Sol
    var initialCEFR: CEFRLevel {
        switch self {
        case .beginner:     return .a1
        case .basic:        return .a2
        case .intermediate: return .b1
        case .comfortable:  return .b2
        case .fluent:       return .c1
        }
    }

    /// Maps to starting difficulty for Lightning Round adaptive calibration
    var startingDifficulty: String {
        initialCEFR.rawValue
    }

    // MARK: - Persistence

    private static let storageKey = "ts_self_reported_level"
    private static let appGroup = "group.com.jeff.translatehelper"

    static var saved: SelfReportedLevel? {
        guard let raw = UserDefaults(suiteName: appGroup)?.string(forKey: storageKey) else { return nil }
        return SelfReportedLevel(rawValue: raw)
    }

    static var hasCompleted: Bool {
        saved != nil
    }

    func save() {
        let defaults = UserDefaults(suiteName: Self.appGroup)
        defaults?.set(rawValue, forKey: Self.storageKey)
        defaults?.synchronize()

        // Also set initial CEFR levels so Lightning Round + Sol have something to work with
        let levels: [SkillCategory: CEFRLevel] = [
            .grammar: initialCEFR,
            .vocabulary: initialCEFR,
            .pronunciation: initialCEFR,
            .fluency: initialCEFR,
        ]
        UserLevelStore.shared.saveAssessment(levels)

        NSLog("🎯 Self-reported level: \(rawValue) → initial CEFR \(initialCEFR.rawValue)")
    }
}

// MARK: - Assessment View

struct LevelAssessmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    /// If true, shows a "Skip" button (onboarding context). If false, mandatory (Coach gate).
    var isSkippable: Bool = true

    /// Called after selection or skip
    var onComplete: () -> Void = {}

    /// Optional context message (e.g., "Just a quick question to help us get started")
    var contextMessage: String? = nil

    @State private var selectedLevel: SelfReportedLevel? = nil
    @State private var showConfirmation = false

    private var targetLangName: String {
        LanguageManager.shared.targetLangName ?? "your target language"
    }

    /// Primary colour of the target language's flag — used for subtle glow behind emoji
    private var flagGlowColor: Color {
        let code = LanguageManager.shared.targetLangRequired
        let colors: [String: String] = [
            "es": "#C60B1E",  // red
            "pt": "#009739",  // green
            "fr": "#002395",  // blue
            "de": "#DD0000",  // red
            "it": "#008C45",  // green
            "ja": "#BC002D",  // red
            "ko": "#003478",  // blue
            "zh": "#DE2910",  // red
            "ar": "#007A3D",  // green
            "nl": "#FF4F00",  // orange
            "en": "#B22234",  // red
            "ru": "#0039A6",  // blue
            "pl": "#DC143C",  // red
            "tr": "#E30A17",  // red
            "sv": "#006AA7",  // blue
            "da": "#C60C30",  // red
            "fi": "#003580",  // blue
            "el": "#0D5EAF",  // blue
            "cs": "#D7141A",  // red
            "ro": "#002B7F",  // blue
            "hu": "#436F4D",  // green
            "uk": "#005BBB",  // blue
            "id": "#FF0000",  // red
            "vi": "#DA251D",  // red
            "hi": "#FF9933",  // saffron
            "he": "#0038B8",  // blue
            "th": "#A51931",  // red
        ]
        return Color(hex: colors[code] ?? "#007AFF")
    }

    var body: some View {
        ZStack {
            TSGradientBackground().ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Nav bar with progress ──────────────────────────────
                HStack {
                    Color.clear.frame(width: 40, height: 40)
                    Spacer()
                    OnboardingProgressBar(currentStep: 2, totalSteps: 6)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer(minLength: 0)
                    .frame(maxHeight: 24)

                // Header
                VStack(spacing: 10) {
                    Text(LanguageManager.shared.targetLangFlag ?? "🌐")
                        .font(.system(size: 86))
                        .shadow(color: flagGlowColor.opacity(0.4), radius: 24, x: 0, y: 0)
                        .shadow(color: flagGlowColor.opacity(0.2), radius: 48, x: 0, y: 0)

                    Text("How's your \(targetLangName)?")
                        .font(.custom("HelveticaNeue-Bold", size: 26))
                        .foregroundColor(.tsLabel)
                        .multilineTextAlignment(.center)

                    Text(contextMessage ?? "This helps Orbit match your level from the start.\nYou can't get this wrong — we'll fine-tune it as you go.")
                        .font(.custom("HelveticaNeue", size: 14))
                        .foregroundColor(.tsSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 28)

                // 5 level options
                VStack(spacing: 10) {
                    ForEach(SelfReportedLevel.allCases, id: \.self) { level in
                        let isSelected = selectedLevel == level

                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedLevel = level
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Text(level.icon)
                                    .font(.system(size: 22))
                                    .frame(width: 32)

                                Text(level.label)
                                    .font(.custom("HelveticaNeue-Medium", size: 15))
                                    .foregroundColor(.tsLabel)
                                    .multilineTextAlignment(.leading)

                                Spacer(minLength: 32)

                                // Always reserve space for the checkmark so text doesn't shift
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.tsAccent)
                                    .opacity(isSelected ? 1 : 0)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.tsCard)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(isSelected ? Color.tsAccent : Color.tsBorder, lineWidth: isSelected ? 2 : 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // ── CTA ────────────────────────────────────────────
                VStack(spacing: 16) {
                    Button {
                        selectedLevel?.save()
                        onComplete()
                        dismiss()
                    } label: {
                        Text("Continue")
                            .font(.custom("HelveticaNeue-Medium", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Capsule().fill(selectedLevel != nil ? Color.tsAccent : Color.tsSecondary.opacity(0.3)))
                    }
                    .disabled(selectedLevel == nil)

                    if isSkippable {
                        Button {
                            onComplete()
                            dismiss()
                        } label: {
                            Text("Skip")
                                .font(.custom("HelveticaNeue", size: 15))
                                .foregroundColor(.tsSecondary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}
