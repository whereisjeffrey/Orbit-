//
//  OnboardingGoalsView.swift
//  TranslateHelper
//

import SwiftUI

struct OnboardingGoalsView: View {
    var step: Int = 2
    var totalSteps: Int = 3
    let onBack: () -> Void
    let onSkip: () -> Void
    let onContinue: () -> Void

    @State private var selectedGoals: Set<String> = []

    let goals: [(String, String, Color)] = [
        ("airplane",           "Travel",  Color.tsAccent),
        ("briefcase.fill",     "Work",    Color(hex: "#A2845E")),
        ("face.smiling.fill",  "Casual",  Color(hex: "#FFCC00")),
        ("heart.fill",         "Flirty",  Color(hex: "#FF3B30")),
        ("building.columns.fill", "Culture", Color(hex: "#AF52DE")),
        ("person.2.fill",      "Family",  Color(hex: "#34C759")),
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
                            .font(.custom("HelveticaNeue-Medium", size: 16))
                            .foregroundColor(.tsAccent)
                    }
                    .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Why are you learning?")
                                .font(.custom("HelveticaNeue-Bold", size: 34))
                                .foregroundColor(.tsLabel)
                            Text("Select all that apply. This helps us customize your study cards.")
                                .font(.custom("HelveticaNeue", size: 17))
                                .foregroundColor(.tsSecondary)
                        }
                        .padding(.top, 16)

                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
                            spacing: 16
                        ) {
                            ForEach(goals, id: \.1) { icon, name, color in
                                let isSelected = selectedGoals.contains(name)
                                Button(action: {
                                    if isSelected { selectedGoals.remove(name) }
                                    else { selectedGoals.insert(name) }
                                }) {
                                    VStack(spacing: 16) {
                                        Circle()
                                            .fill(color.opacity(0.2))
                                            .frame(width: 48, height: 48)
                                            .overlay(
                                                Image(systemName: icon)
                                                    .font(.custom("HelveticaNeue", size: 22))
                                                    .foregroundColor(color)
                                            )
                                        Text(name)
                                            .font(.custom("HelveticaNeue-Medium", size: 17))
                                            .foregroundColor(.tsLabel)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 148)
                                    .background(Color.tsCard)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(isSelected ? Color.tsAccent : Color.clear, lineWidth: 2)
                                    )
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
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
                            .background(
                                LinearGradient(
                                    colors: [Color.tsAccent, Color(hex: "#004775")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color.tsAccent.opacity(0.3), radius: 16, x: 0, y: 4)
                    }
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
