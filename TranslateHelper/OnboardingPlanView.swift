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
                            .font(.custom("HelveticaNeue-Medium", size: 22))
                            .foregroundColor(.tsAccent)
                            .frame(width: 40, height: 40)
                            .background(Color.tsLabel.opacity(0.08))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Choose Your Plan")
                        .font(.custom("HelveticaNeue-Bold", size: 18))
                        .foregroundColor(.tsLabel)
                    Spacer()
                    Spacer().frame(width: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Choose your plan")
                                .font(.custom("HelveticaNeue-Bold", size: 24))
                                .foregroundColor(.tsLabel)
                            Text("Try everything free for 7 days. No charge until then.")
                                .font(.custom("HelveticaNeue", size: 15))
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
                                                    .font(.custom("HelveticaNeue-Bold", size: 20))
                                                Text("Pro")
                                                    .font(.custom("HelveticaNeue-Bold", size: 24))
                                                    .foregroundColor(.tsLabel)
                                            }
                                            Text("The full Wandr experience")
                                                .font(.custom("HelveticaNeue", size: 14))
                                                .foregroundColor(.tsSecondary)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("$7.99")
                                                .font(.custom("HelveticaNeue-Bold", size: 30))
                                                .foregroundColor(.tsLabel)
                                            Text("/ month")
                                                .font(.custom("HelveticaNeue", size: 12))
                                                .foregroundColor(.tsSecondary)
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 12) {
                                        PlanFeatureRow(text: "Unlimited keyboard translations")
                                        PlanFeatureRow(text: "Full Community — locals, expats, events")
                                        PlanFeatureRow(text: "All Kit tools — cowork, SIM, currency & more")
                                        PlanFeatureRow(text: "Connect with people — see social profiles")
                                        PlanFeatureRow(text: "Offline mode")
                                    }
                                }
                                .padding(24)
                                .background(Color.tsCard)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.tsAccent, lineWidth: 1.5)
                                )

                                Text("MOST POPULAR")
                                    .font(.custom("HelveticaNeue-Bold", size: 10))
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
                                                    .font(.custom("HelveticaNeue", size: 20))
                                                Text("Basic")
                                                    .font(.custom("HelveticaNeue-Bold", size: 24))
                                                    .foregroundColor(.tsLabel)
                                            }
                                            Text("Explore the basics")
                                                .font(.custom("HelveticaNeue", size: 14))
                                                .foregroundColor(.tsSecondary)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("Free")
                                                .font(.custom("HelveticaNeue-Bold", size: 30))
                                                .foregroundColor(.tsLabel)
                                            Text("FOREVER")
                                                .font(.custom("HelveticaNeue-Medium", size: 12))
                                                .foregroundColor(.tsSecondary)
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 12) {
                                        PlanFeatureRow(text: "15 keyboard translations/day", isBasic: true)
                                        PlanFeatureRow(text: "Scam Radar", isBasic: true)
                                        PlanFeatureRow(text: "Neighbourhood guides", isBasic: true)
                                        PlanFeatureRow(text: "Browse Community (read only)", isBasic: true)
                                    }
                                }
                                .padding(24)
                                .background(Color.tsCard)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.tsAccent.opacity(0.2), lineWidth: 1))
                                .contentShape(RoundedRectangle(cornerRadius: 24))
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
                            .font(.custom("HelveticaNeue-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#3B99FC"), Color(hex: "#007AFF")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 24)

                    Text("After 7 days, your Pro subscription begins at $7.99/mo. Cancel anytime.")
                        .font(.custom("HelveticaNeue", size: 11))
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
                        .font(.custom("HelveticaNeue-Bold", size: 11))
                        .foregroundStyle(isBasic
                            ? AnyShapeStyle(Color.tsAccent)
                            : AnyShapeStyle(LinearGradient(
                                colors: [Color.tsAccent, Color(hex: "#00F0FF")],
                                startPoint: .leading, endPoint: .trailing)))
                )
            Text(text)
                .font(.custom("HelveticaNeue-Medium", size: 14))
                .foregroundColor(.tsLabel)
        }
    }
}
