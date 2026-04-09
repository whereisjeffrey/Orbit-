//
//  OnboardingPersonalizeIntroView.swift
//  TranslateHelper
//
//  "Let's personalize" breather screen between language/level selection
//  and the personalization questions (location, status, interests).
//  Explains WHY we're about to ask a few questions.

import SwiftUI

struct OnboardingPersonalizeIntroView: View {
    let onContinue: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 80)

            // ── Sol avatar with glow ──────────────────────────
            Image("SolAvaatar")
                .resizable()
                .scaledToFill()
                .frame(width: 128, height: 128)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.tsAccent.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: Color.tsAccent.opacity(0.3), radius: 20, x: 0, y: 0)
                .shadow(color: Color.tsAccent.opacity(0.15), radius: 40, x: 0, y: 0)
                .padding(.bottom, 40)

            // ── Header ────────────────────────────────────────
            VStack(spacing: 8) {
                Text("Let Orbit Coach personalize your experience")
                    .font(.custom("HelveticaNeue-Bold", size: 24))
                    .foregroundColor(.tsLabel)
                    .multilineTextAlignment(.center)

                Text("Three quick questions so Orbit can work better for you.")
                    .font(.custom("HelveticaNeue", size: 15))
                    .foregroundColor(.tsSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)

            // ── Benefit rows ──────────────────────────────────
            VStack(spacing: 24) {
                benefitRow(
                    icon: "globe.americas.fill",
                    color: Color(hex: "#34C759"),
                    title: "Talk like the locals",
                    subtitle: "We'll match slang and expressions to where you are"
                )
                benefitRow(
                    icon: "sparkles",
                    color: Color(hex: "#FF9500"),
                    title: "Focus on what matters",
                    subtitle: "Conversations tailored to your daily life and interests"
                )
                benefitRow(
                    icon: "chart.line.uptrend.xyaxis",
                    color: Color.tsAccent,
                    title: "Match your level",
                    subtitle: "Nothing too easy, nothing overwhelming"
                )
            }
            .padding(.horizontal, 32)

            Spacer()

            // ── CTA ───────────────────────────────────────────
            VStack(spacing: 16) {
                Button(action: onContinue) {
                    Text("Let's Go!")
                        .font(.custom("HelveticaNeue-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.tsAccent)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 24)

                Button(action: onSkip) {
                    Text("Skip for now")
                        .font(.custom("HelveticaNeue", size: 15))
                        .foregroundColor(.tsSecondary)
                }
            }
            .padding(.bottom, 48)
        }
        .background(Color.tsBackground.ignoresSafeArea())
    }

    private func benefitRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("HelveticaNeue-Bold", size: 16))
                    .foregroundColor(.tsLabel)
                Text(subtitle)
                    .font(.custom("HelveticaNeue", size: 13))
                    .foregroundColor(.tsSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }
}
