//
//  OnboardingPaywallView.swift
//  TranslateHelper
//

import SwiftUI

// MARK: - Plan Model

enum WandrPlan: Identifiable, CaseIterable {
    case free, founder, standard, coach

    var id: String { title }

    var title: String {
        switch self {
        case .free:     return "Free"
        case .founder:  return "Founder"
        case .standard: return "Standard"
        case .coach:    return "Coach"
        }
    }

    var price: String {
        switch self {
        case .free:     return "$0"
        case .founder:  return "$1.99"
        case .standard: return "$4.99"
        case .coach:    return "$14.99"
        }
    }

    var period: String {
        switch self {
        case .free:     return "forever"
        case .founder:  return "/ mo — locked"
        case .standard: return "/ mo"
        case .coach:    return "/ mo"
        }
    }

    var badge: String? {
        switch self {
        case .founder:  return "Founder's Pick"
        case .coach:    return "Best for Fluency"
        default:        return nil
        }
    }

    var features: [PlanFeature] {
        switch self {
        case .free:
            return [
                PlanFeature(icon: "keyboard",            text: "15 keyboard translations/day",  included: true),
                PlanFeature(icon: "rectangle.stack",     text: "3 starter decks",               included: true),
                PlanFeature(icon: "infinity",            text: "Unlimited translations",         included: false),
                PlanFeature(icon: "rectangle.stack.badge.plus", text: "Create custom decks",    included: false),
                PlanFeature(icon: "waveform",            text: "Voice translate",               included: false),
            ]
        case .founder:
            return [
                PlanFeature(icon: "keyboard",            text: "Unlimited keyboard translations", included: true),
                PlanFeature(icon: "rectangle.stack",     text: "Unlimited decks",               included: true),
                PlanFeature(icon: "waveform",            text: "Voice translate",               included: true),
                PlanFeature(icon: "lock.rotation",       text: "Price locked forever",          included: true),
                PlanFeature(icon: "person.2",            text: "Share with 3 friends (honor system)", included: true),
            ]
        case .standard:
            return [
                PlanFeature(icon: "keyboard",            text: "Unlimited keyboard translations", included: true),
                PlanFeature(icon: "rectangle.stack",     text: "Unlimited decks",               included: true),
                PlanFeature(icon: "waveform",            text: "Voice translate",               included: true),
                PlanFeature(icon: "lock.rotation",       text: "Price locked forever",          included: false),
                PlanFeature(icon: "person.2",            text: "No action required",            included: true),
            ]
        case .coach:
            return [
                PlanFeature(icon: "keyboard",            text: "Everything in Standard",               included: true),
                PlanFeature(icon: "waveform.and.person.filled", text: "AI coaching on every audio",    included: true),
                PlanFeature(icon: "chart.line.uptrend.xyaxis", text: "Mistake inventory + progress",   included: true),
                PlanFeature(icon: "sparkles",            text: "Pattern recognition across sessions",  included: true),
                PlanFeature(icon: "battery.100",         text: "500 coaching analyses / month",        included: true),
            ]
        }
    }
}

struct PlanFeature: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
    let included: Bool
}

// MARK: - Main Paywall View

struct OnboardingPaywallView: View {
    let onBack: () -> Void
    let onComplete: () -> Void

    @State private var selectedPlan: WandrPlan = .founder
    @State private var showFounderConfirm = false
    @State private var showSuccess = false
    @State private var appearAnimation = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TSGradientBackground().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Nav bar ───────────────────────────────────────
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.tsAccent)
                                .frame(width: 40, height: 40)
                        }
                        Spacer()
                        Button("Skip") { onComplete() }
                            .font(.custom("HelveticaNeue", size: 15))
                            .foregroundColor(.tsSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // ── Header ────────────────────────────────────────
                    VStack(spacing: 8) {
                        Text("Choose your plan")
                            .font(.custom("HelveticaNeue-Bold", size: 30))
                            .foregroundColor(.tsLabel)
                            .multilineTextAlignment(.center)

                        Text("Start free. Upgrade whenever you're ready.")
                            .font(.custom("HelveticaNeue", size: 15))
                            .foregroundColor(.tsSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 10)

                    // ── Plan cards ────────────────────────────────────
                    VStack(spacing: 14) {
                        ForEach(WandrPlan.allCases) { plan in
                            PlanCard(
                                plan: plan,
                                isSelected: selectedPlan == plan
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    selectedPlan = plan
                                }
                                let gen = UIImpactFeedbackGenerator(style: .light)
                                gen.impactOccurred()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 16)

                    // ── Founder callout (only shown when selected) ────
                    if selectedPlan == .founder {
                        FounderCallout()
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Spacer().frame(height: 160)
                }
            }

            // ── Sticky bottom CTA ──────────────────────────────────────
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color.tsBackground.opacity(0), Color.tsBackground],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 32)
                .allowsHitTesting(false)

                VStack(spacing: 10) {
                    Button(action: handleCTA) {
                        Text(ctaLabel)
                            .font(.custom("HelveticaNeue-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "3B99FC"), Color(hex: "007AFF")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color.tsAccent.opacity(0.3), radius: 16, x: 0, y: 4)
                    }
                    .padding(.horizontal, 24)

                    Text(ctaSubtext)
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
        .onAppear {
            withAnimation(.easeOut(duration: 0.45).delay(0.1)) {
                appearAnimation = true
            }
        }
        .sheet(isPresented: $showFounderConfirm) {
            FounderPriceConfirmView {
                showFounderConfirm = false
                showSuccess = true
            }
        }
        .fullScreenCover(isPresented: $showSuccess) {
            PlanSuccessView(plan: selectedPlan, onDone: onComplete)
        }
    }

    // MARK: - Helpers

    var ctaLabel: String {
        switch selectedPlan {
        case .free:     return "Continue for Free"
        case .founder:  return "Claim Founding Price ✨"
        case .standard: return "Get Standard — $4.99/mo"
        case .coach:    return "Try Coach Free for 30 Days"
        }
    }

    var ctaSubtext: String {
        switch selectedPlan {
        case .free:     return "15 keyboard translations per day. Upgrade anytime."
        case .founder:  return "Locked in forever. No proof required — we trust you."
        case .standard: return "Full access. No strings attached."
        case .coach:    return "Billed $149.99 after 30 days (2 months free vs. monthly). Cancel anytime."
        }
    }

    func handleCTA() {
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.impactOccurred()
        switch selectedPlan {
        case .free:
            onComplete()
        case .founder:
            showFounderConfirm = true
        case .standard:
            showSuccess = true
        case .coach:
            // TODO: wire to StoreKit introductory 30-day free period on $149.99/yr subscription
            showSuccess = true
        }
    }
}

// MARK: - Plan Card

struct PlanCard: View {
    let plan: WandrPlan
    let isSelected: Bool
    let onTap: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {

                // ── Badge row ─────────────────────────────────────
                if let badge = plan.badge {
                    HStack {
                        Spacer()
                        Text(badge.uppercased())
                            .font(.custom("HelveticaNeue-Bold", size: 10))
                            .foregroundColor(.white)
                            .kerning(0.8)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "3B99FC"), Color(hex: "007AFF")],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                    }
                    .padding(.bottom, 10)
                } else if plan == .free {
                    // Spacer to align cards that have no badge
                    Color.clear.frame(height: 0)
                        .padding(.bottom, 0)
                }

                // ── Price row ─────────────────────────────────────
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(plan.price)
                        .font(.custom("HelveticaNeue-Bold", size: plan == .free ? 26 : 32))
                        .foregroundColor(isSelected ? .tsAccent : .tsLabel)
                    Text(plan.period)
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.tsSecondary)
                        .padding(.leading, 4)
                    Spacer()

                    // Selection indicator
                    ZStack {
                        Circle()
                            .strokeBorder(isSelected ? Color.tsAccent : Color.tsSecondary.opacity(0.3), lineWidth: 2)
                            .frame(width: 22, height: 22)
                        if isSelected {
                            Circle()
                                .fill(Color.tsAccent)
                                .frame(width: 13, height: 13)
                        }
                    }
                }
                .padding(.bottom, 14)

                // ── Feature list ──────────────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(plan.features) { feature in
                        HStack(spacing: 9) {
                            Image(systemName: feature.included ? "checkmark" : "xmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(feature.included
                                    ? (isSelected ? .tsAccent : Color(hex: "34C759"))
                                    : .tsSecondary.opacity(0.4))
                                .frame(width: 16)
                            Text(feature.text)
                                .font(.custom("HelveticaNeue", size: 13))
                                .foregroundColor(feature.included ? .tsLabel : .tsSecondary.opacity(0.5))
                        }
                    }
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected
                        ? Color.tsAccent.opacity(colorScheme == .dark ? 0.10 : 0.06)
                        : Color.tsCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        isSelected ? Color.tsAccent : Color.tsAccent.opacity(0.08),
                        lineWidth: isSelected ? 1.5 : 0.5
                    )
            )
            .shadow(
                color: isSelected ? Color.tsAccent.opacity(0.12) : Color.clear,
                radius: 12, x: 0, y: 4
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

// MARK: - Founder Callout

struct FounderCallout: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("✨")
                .font(.system(size: 20))
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: 4) {
                Text("Honor system — no proof needed.")
                    .font(.custom("HelveticaNeue-Bold", size: 13))
                    .foregroundColor(.tsLabel)
                Text("Share wandr with 3 friends and post about it on social. We trust you — and your $1.99 rate is yours forever.")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                    .lineSpacing(2)
            }
        }
        .padding(14)
        .background(Color.tsAccent.opacity(0.08))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.tsAccent.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Founder Confirm Sheet

struct FounderPriceConfirmView: View {
    let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            TSGradientBackground().ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.tsSecondary.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 32)

                // Icon
                Text("✨")
                    .font(.system(size: 52))
                    .padding(.bottom, 20)

                VStack(spacing: 10) {
                    Text("You're in.\nWelcome, founder.")
                        .font(.custom("HelveticaNeue-Bold", size: 26))
                        .foregroundColor(.tsLabel)
                        .multilineTextAlignment(.center)

                    Text("Your $1.99/month rate is locked in — for life. No matter what wandr becomes, this is your price. Always.")
                        .font(.custom("HelveticaNeue", size: 15))
                        .foregroundColor(.tsSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 8)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 28)

                // What we ask
                VStack(alignment: .leading, spacing: 12) {
                    FounderAskRow(icon: "person.2.fill", text: "Share wandr with 3 friends")
                    FounderAskRow(icon: "square.and.arrow.up", text: "Post about it on social media")
                }
                .padding(18)
                .background(Color.tsCard)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                Text("We're early, we're scrappy, and we're building something we genuinely believe in. If you feel like telling someone about it, we'd love that. But no pressure — we're just glad you're here.")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)

                // CTA
                Button(action: onConfirm) {
                    Text("Lock in my founding price")
                        .font(.custom("HelveticaNeue-Bold", size: 17))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "3B99FC"), Color(hex: "007AFF")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.tsAccent.opacity(0.3), radius: 12, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)

                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .font(.custom("HelveticaNeue", size: 15))
                        .foregroundColor(.tsSecondary)
                }
                .padding(.bottom, 32)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}

private struct FounderAskRow: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.tsAccent)
                .frame(width: 20)
            Text(text)
                .font(.custom("HelveticaNeue-Medium", size: 14))
                .foregroundColor(.tsLabel)
        }
    }
}

// MARK: - Plan Success View

struct PlanSuccessView: View {
    let plan: WandrPlan
    let onDone: () -> Void

    @State private var showContent = false
    @State private var checkScale: CGFloat = 0.3
    @State private var checkOpacity: Double = 0

    var headline: String {
        switch plan {
        case .free:     return "You're all set 🎉"
        case .founder:  return "Welcome, founder 🌎"
        case .standard: return "Welcome to wandr 🌎"
        case .coach:    return "Your coach is ready 🤖"
        }
    }

    var subheadline: String {
        switch plan {
        case .free:     return "You've got 15 translations a day to get started. Upgrade anytime from Settings."
        case .founder:  return "Your $1.99/month founding rate is locked in forever. Thanks for believing early."
        case .standard: return "Unlimited translations, voice, decks — everything you need."
        case .coach:    return "30 days free, then $149.99/year. Your first 300 coaching analyses are on us."
        }
    }

    var body: some View {
        ZStack {
            TSGradientBackground().ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Animated check
                ZStack {
                    Circle()
                        .fill(Color(hex: "34C759").opacity(0.12))
                        .frame(width: 120, height: 120)
                    Circle()
                        .fill(Color(hex: "34C759").opacity(0.08))
                        .frame(width: 96, height: 96)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(Color(hex: "34C759"))
                        .scaleEffect(checkScale)
                        .opacity(checkOpacity)
                }
                .padding(.bottom, 32)

                VStack(spacing: 8) {
                    Text(headline)
                        .font(.custom("HelveticaNeue-Bold", size: 28))
                        .foregroundColor(.tsLabel)
                        .multilineTextAlignment(.center)
                    Text(subheadline)
                        .font(.custom("HelveticaNeue", size: 15))
                        .foregroundColor(.tsSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 12)

                Spacer()

                Button(action: onDone) {
                    Text("Let's go 🚀")
                        .font(.custom("HelveticaNeue-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "3B99FC"), Color(hex: "007AFF")],
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
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.success)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                checkScale = 1.0
                checkOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.4)) {
                showContent = true
            }
        }
    }
}
