//
//  LevelAssessmentView.swift
//  TranslateHelper
//
//  Self-assessment flow before the first practice session.
//  User picks their level for each skill category.
//  Quick, 4 taps, then they're into practice.
//

import SwiftUI

struct LevelAssessmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var currentStep = 0
    @State private var selections: [SkillCategory: CEFRLevel] = [:]
    @State private var showingPractice = false

    private let steps: [(skill: SkillCategory, question: String, hint: String)] = [
        (.pronunciation, "How's your pronunciation?", "Can people understand you when you speak?"),
        (.grammar, "How's your grammar?", "Verb conjugations, gender, sentence structure"),
        (.vocabulary, "How's your vocabulary?", "How many words and expressions do you know?"),
        (.fluency, "How's your fluency?", "Can you hold a conversation without long pauses?"),
    ]

    private let levelOptions: [(level: CEFRLevel, label: String, description: String)] = [
        (.a1, "Just starting", "I know a few words and phrases"),
        (.a2, "Basic", "I can order food and ask simple questions"),
        (.b1, "Getting there", "I can have a real conversation, with effort"),
        (.b2, "Solid", "I can talk about most topics pretty comfortably"),
        (.c1, "Advanced", "I rarely struggle — mostly polishing at this point"),
    ]

    var body: some View {
        ZStack {
            TSGradientBackground().ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(i <= currentStep ? Color.tsAccent : Color.tsSecondary.opacity(0.3))
                            .frame(width: i == currentStep ? 24 : 8, height: 4)
                            .animation(.easeInOut(duration: 0.2), value: currentStep)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 32)

                if currentStep < steps.count {
                    let step = steps[currentStep]

                    // Question
                    VStack(spacing: 8) {
                        Text(step.skill.icon)
                            .font(.system(size: 32))
                        Text(step.question)
                            .font(.custom("HelveticaNeue-Bold", size: 22))
                            .foregroundColor(.tsLabel)
                            .multilineTextAlignment(.center)
                        Text(step.hint)
                            .font(.custom("HelveticaNeue", size: 14))
                            .foregroundColor(.tsSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)

                    // Level options
                    VStack(spacing: 10) {
                        ForEach(levelOptions, id: \.level) { option in
                            let isSelected = selections[step.skill] == option.level

                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selections[step.skill] = option.level
                                }
                                // Auto-advance after a brief pause
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    advance()
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Text(option.level.rawValue)
                                        .font(.custom("HelveticaNeue-Bold", size: 14))
                                        .foregroundColor(isSelected ? .white : .tsAccent)
                                        .frame(width: 30)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(option.label)
                                            .font(.custom("HelveticaNeue-Medium", size: 14))
                                            .foregroundColor(isSelected ? .white : .tsLabel)
                                        Text(option.description)
                                            .font(.custom("HelveticaNeue", size: 12))
                                            .foregroundColor(isSelected ? .white.opacity(0.7) : .tsSecondary)
                                    }

                                    Spacer()

                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(isSelected ? Color.tsAccent : Color.tsCard)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isSelected ? Color.clear : Color.tsBorder, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                } else {
                    // Done — summary
                    VStack(spacing: 16) {
                        Text("✅")
                            .font(.system(size: 40))
                        Text("You're all set")
                            .font(.custom("HelveticaNeue-Bold", size: 22))
                            .foregroundColor(.tsLabel)
                        Text("Sol will calibrate to your level and adjust as you improve.")
                            .font(.custom("HelveticaNeue", size: 14))
                            .foregroundColor(.tsSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        // Show their levels
                        VStack(spacing: 8) {
                            ForEach(SkillCategory.allCases, id: \.self) { skill in
                                if let level = selections[skill] {
                                    HStack {
                                        Text(skill.icon)
                                        Text(skill.displayName)
                                            .font(.custom("HelveticaNeue-Medium", size: 14))
                                            .foregroundColor(.tsLabel)
                                        Spacer()
                                        Text(level.rawValue)
                                            .font(.custom("HelveticaNeue-Bold", size: 16))
                                            .foregroundColor(.tsAccent)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.tsCard)
                        )
                        .padding(.horizontal, 20)

                        Button {
                            UserLevelStore.shared.saveAssessment(selections)
                            dismiss()
                        } label: {
                            Text("Start Practicing")
                                .font(.custom("HelveticaNeue-Medium", size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.tsAccent)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                }

                Spacer()
            }
        }
    }

    private func advance() {
        guard currentStep < steps.count else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep += 1
        }
    }
}
