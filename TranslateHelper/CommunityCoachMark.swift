// CommunityCoachMark.swift
// First-visit coach marks for Community tab.
// Shown once only (community_onboarding_seen AppStorage key).

import SwiftUI

struct CommunityCoachMarkOverlay: View {
    let onDismiss: () -> Void

    @State private var step: Int = 0

    private let steps: [CoachStep] = [
        CoachStep(
            icon: "line.3.horizontal.decrease.circle.fill",
            title: "Filter the feed",
            body: "Tap Questions, Outings, Events and more to focus on what matters to you.",
            color: Color.tsAccent
        ),
        CoachStep(
            icon: "bubble.left.and.bubble.right.fill",
            title: "Find your people",
            body: "Join WhatsApp groups curated for expats in your city — real communities, already active.",
            color: Color(hex: "#34C759")
        ),
        CoachStep(
            icon: "plus.circle.fill",
            title: "Share something",
            body: "Ask a question, drop a rec, or start an outing. Other expats are here for it.",
            color: Color(hex: "#17C2E1")
        ),
    ]

    var isLast: Bool { step == steps.count - 1 }

    var body: some View {
        ZStack {
            // Dim backdrop
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture { advance() }

            VStack(spacing: 0) {
                Spacer()

                // ── Card ─────────────────────────────────────────
                VStack(spacing: 20) {

                    // Step dots
                    HStack(spacing: 6) {
                        ForEach(0..<steps.count, id: \.self) { i in
                            Capsule()
                                .fill(i == step ? steps[step].color : Color.white.opacity(0.25))
                                .frame(width: i == step ? 20 : 6, height: 6)
                                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: step)
                        }
                    }

                    // Icon
                    ZStack {
                        Circle()
                            .fill(steps[step].color.opacity(0.15))
                            .frame(width: 72, height: 72)
                        Image(systemName: steps[step].icon)
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(steps[step].color)
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.65), value: step)

                    // Text
                    VStack(spacing: 8) {
                        Text(steps[step].title)
                            .font(.custom("HelveticaNeue-Bold", size: 20))
                            .foregroundColor(.tsLabel)
                            .multilineTextAlignment(.center)

                        Text(steps[step].body)
                            .font(.custom("HelveticaNeue", size: 15))
                            .foregroundColor(.tsSecondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .animation(.easeInOut(duration: 0.25), value: step)

                    // CTA button
                    Button(action: advance) {
                        Text(isLast ? "Got it 👋" : "Next")
                            .font(.custom("HelveticaNeue-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(steps[step].color)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    // Skip
                    if !isLast {
                        Button(action: onDismiss) {
                            Text("Skip")
                                .font(.custom("HelveticaNeue", size: 14))
                                .foregroundColor(.tsSecondary)
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 28)
                .padding(.bottom, 40)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.tsBackground)
                        .shadow(color: .black.opacity(0.3), radius: 24, x: 0, y: -8)
                )
                .padding(.horizontal, 0)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .animation(.easeInOut(duration: 0.25), value: step)
    }

    private func advance() {
        if isLast {
            onDismiss()
        } else {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                step += 1
            }
        }
    }
}

private struct CoachStep {
    let icon: String
    let title: String
    let body: String
    let color: Color
}
