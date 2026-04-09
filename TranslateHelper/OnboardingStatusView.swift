//  OnboardingStatusView.swift

import SwiftUI

enum ExpatStatus: String, CaseIterable {
    case newArrival  = "just_arrived"
    case settling    = "settling"
    case local       = "local"
    case planning    = "planning"
    case visiting    = "visiting"

    var emoji: String {
        switch self {
        case .newArrival: return "✈️"
        case .settling:   return "📦"
        case .local:      return "🏠"
        case .planning:   return "🗓️"
        case .visiting:   return "👀"
        }
    }

    var label: String {
        switch self {
        case .newArrival: return "Just arrived"
        case .settling:   return "Getting settled"
        case .local:      return "I live here"
        case .planning:   return "Planning to move"
        case .visiting:   return "Just visiting"
        }
    }

    var sublabel: String {
        switch self {
        case .newArrival: return "Less than a month in"
        case .settling:   return "1 – 6 months in"
        case .local:      return "6+ months, this is home"
        case .planning:   return "Haven\'t moved yet"
        case .visiting:   return "Short trip"
        }
    }
}

struct OnboardingStatusView: View {
    let onBack: () -> Void
    let onContinue: () -> Void

    @AppStorage("user_expat_status") private var savedStatus = ""
    @State private var selected: ExpatStatus? = nil

    var body: some View {
        ZStack { TSGradientBackground()
            VStack(spacing: 0) {

                // ── Nav bar with progress ──────────────────────────────
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.tsLabel)
                    }
                    .frame(width: 40, height: 40)

                    Spacer()

                    OnboardingProgressBar(currentStep: 4, totalSteps: 6)

                    Spacer()

                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {

                        // ── Header ─────────────────────────────────
                        VStack(spacing: 12) {
                            Text("How long have you\nbeen here?")
                                .font(.custom("HelveticaNeue-Bold", size: 30))
                                .foregroundColor(.tsLabel)
                                .multilineTextAlignment(.center)
                            Text("We\'ll show you what\'s actually relevant\nto where you are right now.")
                                .font(.custom("HelveticaNeue", size: 16))
                                .foregroundColor(.tsSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 32)

                        // ── Options ────────────────────────────────
                        VStack(spacing: 12) {
                            ForEach(ExpatStatus.allCases, id: \.self) { status in
                                StatusOptionRow(
                                    status: status,
                                    isSelected: selected == status
                                ) {
                                    selected = status
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 32)
                }

                // ── CTA ────────────────────────────────────────────
                VStack(spacing: 16) {
                    Button(action: {
                        if let s = selected {
                            savedStatus = s.rawValue
                            onContinue()
                        }
                    }) {
                        Text("Continue")
                            .font(.custom("HelveticaNeue-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(selected == nil ? Color.tsSecondary.opacity(0.35) : Color.tsAccent)
                            .clipShape(Capsule())
                    }
                    .disabled(selected == nil)
                    Button(action: {
                        savedStatus = ""
                        onContinue()
                    }) {
                        Text("Skip")
                            .font(.custom("HelveticaNeue", size: 15))
                            .foregroundColor(.tsSecondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}

struct StatusOptionRow: View {
    let status: ExpatStatus
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Text(status.emoji)
                    .font(.custom("HelveticaNeue", size: 28))
                    .frame(width: 44)

                VStack(alignment: .leading, spacing: 3) {
                    Text(status.label)
                        .font(.custom("HelveticaNeue-Medium", size: 16))
                        .foregroundColor(.tsLabel)
                    Text(status.sublabel)
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.tsSecondary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.tsAccent : Color.tsBorder, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Circle()
                            .fill(Color.tsAccent)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.tsAccent.opacity(0.08) : Color.tsCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.tsAccent : Color.tsBorder, lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
