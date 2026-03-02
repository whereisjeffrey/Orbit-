//
//  OnboardingPlanView.swift
//  TranslateHelper
//

import SwiftUI

struct OnboardingPlanView: View {
    let onBack: () -> Void
    let onFreePlan: () -> Void
    let onProTrial: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.tsBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Nav ───────────────────────────────────────────────
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.tsAccent)
                            .frame(width: 40, height: 40)
                            .background(Color.tsLabel.opacity(0.08))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Choose Your Plan")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.tsLabel)
                    Spacer()
                    Spacer().frame(width: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Master Any Language")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.tsLabel)
                            Text("Select the plan that works best for your learning goals.")
                                .font(.system(size: 15))
                                .foregroundColor(.tsSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                        .padding(.top, 24)

                        VStack(spacing: 16) {
                            // ── Pro Card ──────────────────────────────
                            ZStack(alignment: .topTrailing) {
                                VStack(alignment: .leading, spacing: 20) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "sparkles")
                                                    .foregroundStyle(LinearGradient(
                                                        colors: [Color.tsAccent, Color(hex: "#00F0FF")],
                                                        startPoint: .leading, endPoint: .trailing))
                                                    .font(.system(size: 20, weight: .bold))
                                                Text("Pro")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.tsLabel)
                                            }
                                            Text("Unlock your full potential")
                                                .font(.system(size: 14))
                                                .foregroundColor(.tsSecondary)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("$7.99")
                                                .font(.system(size: 30, weight: .bold))
                                                .foregroundColor(.tsLabel)
                                            Text("/ month")
                                                .font(.system(size: 12))
                                                .foregroundColor(.tsSecondary)
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 12) {
                                        PlanFeatureRow(text: "Unlimited Daily Phrases")
                                        PlanFeatureRow(text: "Cultural Context Insights")
                                        PlanFeatureRow(text: "AI Accent Coaching")
                                        PlanFeatureRow(text: "Offline Mode Enabled")
                                    }
                                }
                                .padding(24)
                                .background(Color.tsCard)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(LinearGradient(
                                            colors: [Color.tsAccent, Color.clear, Color(hex: "#00F0FF")],
                                            startPoint: .top, endPoint: .bottom), lineWidth: 1.5)
                                )

                                Text("MOST POPULAR")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(LinearGradient(
                                        colors: [Color.tsAccent, Color(hex: "#00F0FF")],
                                        startPoint: .leading, endPoint: .trailing))
                                    .clipShape(Capsule())
                                    .offset(x: -24, y: -12)
                            }

                            // ── Free Card ─────────────────────────────
                            Button(action: onFreePlan) {
                                VStack(alignment: .leading, spacing: 20) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "graduationcap.fill")
                                                    .foregroundColor(.tsSecondary)
                                                    .font(.system(size: 20))
                                                Text("Basic")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.tsLabel)
                                            }
                                            Text("Getting started")
                                                .font(.system(size: 14))
                                                .foregroundColor(.tsSecondary)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("Free")
                                                .font(.system(size: 30, weight: .bold))
                                                .foregroundColor(.tsLabel)
                                            Text("FOREVER")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.tsSecondary)
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 12) {
                                        PlanFeatureRow(text: "20 Phrases per day", isBasic: true)
                                        PlanFeatureRow(text: "Standard Flashcards", isBasic: true)
                                    }
                                }
                                .padding(24)
                                .background(Color.tsLabel.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.tsBorder, lineWidth: 1))
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 140)
                    }
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

                VStack(spacing: 12) {
                    Button(action: onProTrial) {
                        Text("Start 7-Day Free Trial")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(LinearGradient(
                                colors: [Color(hex: "#3B99FC"), Color(hex: "#007AFF")],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                            .clipShape(Capsule())
                            .shadow(color: Color.tsAccent.opacity(0.3), radius: 16, x: 0, y: 4)
                    }
                    .padding(.horizontal, 24)

                    Text("After 7 days, your Pro subscription begins at $7.99/mo. Cancel anytime.")
                        .font(.system(size: 11))
                        .foregroundColor(.tsSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

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

struct PlanFeatureRow: View {
    let text: String
    var isBasic = false

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(isBasic ? Color.tsCard : Color.tsAccent.opacity(0.15))
                .frame(width: 24, height: 24)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(isBasic
                            ? AnyShapeStyle(Color.tsAccent)
                            : AnyShapeStyle(LinearGradient(
                                colors: [Color.tsAccent, Color(hex: "#00F0FF")],
                                startPoint: .leading, endPoint: .trailing)))
                )
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.tsLabel)
        }
    }
}
