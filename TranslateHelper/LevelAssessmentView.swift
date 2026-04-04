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

    var body: some View {
        ZStack {
            TSGradientBackground().ignoresSafeArea()

            VStack(spacing: 0) {

                // Skip button (only in onboarding)
                if isSkippable {
                    HStack {
                        Spacer()
                        Button {
                            onComplete()
                            dismiss()
                        } label: {
                            Text("Skip")
                                .font(.custom("HelveticaNeue-Medium", size: 16))
                                .foregroundColor(.tsAccent)
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 12)
                    }
                }

                Spacer(minLength: 0)
                    .frame(maxHeight: 40)

                // Header
                VStack(spacing: 10) {
                    Text(LanguageManager.shared.targetLangFlag ?? "🌐")
                        .font(.system(size: 86))

                    Text("How's your \(targetLangName)?")
                        .font(.custom("HelveticaNeue-Bold", size: 26))
                        .foregroundColor(.tsLabel)
                        .multilineTextAlignment(.center)

                    Text(contextMessage ?? "This helps Orbit match your level from the start. You can't get this wrong — we'll fine-tune it as you go.")
                        .font(.custom("HelveticaNeue", size: 14))
                        .foregroundColor(.tsSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
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
                            // Save and dismiss after brief pause
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                level.save()
                                onComplete()
                                dismiss()
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Text(level.icon)
                                    .font(.system(size: 22))
                                    .frame(width: 32)

                                Text(level.label)
                                    .font(.custom("HelveticaNeue-Medium", size: 15))
                                    .foregroundColor(isSelected ? .white : .tsLabel)
                                    .multilineTextAlignment(.leading)

                                Spacer()

                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(isSelected ? Color.tsAccent : Color.tsCard)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(isSelected ? Color.clear : Color.tsBorder, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}
