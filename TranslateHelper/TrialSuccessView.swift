//  TrialSuccessView.swift
//  Wandr (formerly TalkSwitch)

import SwiftUI

struct TrialSuccessView: View {
    let onDone: () -> Void
    let chargeDate: String
    let cardLastFour: String

    @State private var showContent = false
    @State private var checkScale: CGFloat = 0.3
    @State private var checkOpacity: Double = 0

    var reminderDate: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM d, yyyy"
        guard let d = f.date(from: chargeDate),
              let r = Calendar.current.date(byAdding: .day, value: -2, to: d) else { return "" }
        return f.string(from: d)
    }

    var body: some View {
        ZStack {
            Color.tsBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // ── Animated check ─────────────────────────────────
                ZStack {
                    Circle()
                        .fill(Color(hex: "#34C759").opacity(0.12))
                        .frame(width: 120, height: 120)
                    Circle()
                        .fill(Color(hex: "#34C759").opacity(0.08))
                        .frame(width: 96, height: 96)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(Color(hex: "#34C759"))
                        .scaleEffect(checkScale)
                        .opacity(checkOpacity)
                }
                .padding(.bottom, 32)

                // ── Headline ───────────────────────────────────────
                VStack(spacing: 8) {
                    Text("Welcome to Wandr 🌎")
                        .font(.custom("HelveticaNeue-Bold", size: 28))
                        .foregroundColor(.tsLabel)
                        .multilineTextAlignment(.center)

                    Text("Your 7-day free trial has started.\nNo charge until \(chargeDate).")
                        .font(.custom("HelveticaNeue", size: 16))
                        .foregroundColor(.tsSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 12)

                // ── Detail card ────────────────────────────────────
                VStack(spacing: 0) {
                    DetailRow(
                        icon: "calendar",
                        color: Color.tsAccent,
                        label: "First charge",
                        value: chargeDate
                    )
                    Divider().padding(.leading, 48)
                    DetailRow(
                        icon: "creditcard.fill",
                        color: Color.tsAccent,
                        label: "Payment method",
                        value: cardLastFour.isEmpty ? "Card on file" : "Card ending in \(cardLastFour)"
                    )
                    Divider().padding(.leading, 48)
                    DetailRow(
                        icon: "bell.fill",
                        color: Color(hex: "#FF9500"),
                        label: "Reminder",
                        value: "2 days before your trial ends"
                    )
                    Divider().padding(.leading, 48)
                    DetailRow(
                        icon: "gearshape.fill",
                        color: .tsSecondary,
                        label: "To cancel",
                        value: "Settings → Subscription, anytime"
                    )
                }
                .background(Color.tsCard)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 16)

                // ── Fine print ─────────────────────────────────────
                Text("We'll send you a reminder before your trial ends.\nNo surprises. No funny business.")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .opacity(showContent ? 1 : 0)

                Spacer()

                // ── CTA ────────────────────────────────────────────
                Button(action: onDone) {
                    Text("Let's go 🚀")
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
                        .shadow(color: Color.tsAccent.opacity(0.3), radius: 16, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            // Success haptic
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.success)

            // Animate check
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                checkScale = 1.0
                checkOpacity = 1.0
            }
            // Fade in content
            withAnimation(.easeOut(duration: 0.4).delay(0.4)) {
                showContent = true
            }
        }
    }
}

// MARK: - Detail Row

private struct DetailRow: View {
    let icon: String
    let color: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(color)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                Text(value)
                    .font(.custom("HelveticaNeue-Medium", size: 14))
                    .foregroundColor(.tsLabel)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
