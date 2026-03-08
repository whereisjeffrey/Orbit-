//  UpgradeSheet.swift
//  TalkSwitch
//
//  Reusable paywall sheet. Pass an UpgradeReason and it self-configures.

import SwiftUI

struct UpgradeSheet: View {
    let reason: UpgradeReason
    @Environment(\.dismiss) var dismiss
    @ObservedObject var sub = SubscriptionManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                TSGradientBackground()

                VStack(spacing: 0) {
                    Spacer()

                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.tsAccent.opacity(0.12))
                            .frame(width: 96, height: 96)
                        Image(systemName: reason.icon)
                            .font(.system(size: 38))
                            .foregroundColor(.tsAccent)
                    }
                    .padding(.bottom, 24)

                    // Title
                    Text(reason.title)
                        .font(.custom("HelveticaNeue-Bold", size: 26))
                        .foregroundColor(.tsLabel)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 12)

                    // Description
                    Text(reason.description)
                        .font(.custom("HelveticaNeue", size: 16))
                        .foregroundColor(.tsSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)

                    // Pro perks list
                    VStack(alignment: .leading, spacing: 14) {
                        PerkRow(icon: "keyboard.fill",              text: "Unlimited keyboard translations")
                        PerkRow(icon: "wrench.and.screwdriver.fill",text: "Full Kit — cowork, SIM, currency & more")
                        PerkRow(icon: "message.fill",               text: "Community messaging & group access")
                        PerkRow(icon: "map.fill",                   text: "Full neighbourhood guides & rent data")
                        PerkRow(icon: "link",                       text: "See social profiles of community members")
                        PerkRow(icon: "rectangle.stack.fill.badge.plus", text: "Create unlimited study decks")
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 40)

                    Spacer()

                    // CTA
                    VStack(spacing: 12) {
                        Button {
                            // TODO: wire StoreKit purchase
                            sub.isPro = true
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 14))
                                Text("Go Pro — $7.99 / month")
                                    .font(.custom("HelveticaNeue-Bold", size: 17))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#3B99FC"), Color(hex: "#007AFF")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 24)

                        Button("Maybe later") { dismiss() }
                            .font(.custom("HelveticaNeue-Medium", size: 15))
                            .foregroundColor(.tsSecondary)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Perk Row

private struct PerkRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.tsAccent)
                .frame(width: 22)
            Text(text)
                .font(.custom("HelveticaNeue-Medium", size: 15))
                .foregroundColor(.tsLabel)
        }
    }
}

// MARK: - Pro Gate Modifier

/// Wraps any view in a tap-to-upgrade overlay when the user isn't Pro.
struct ProGate<Content: View>: View {
    let reason: UpgradeReason
    let content: Content
    @ObservedObject var sub = SubscriptionManager.shared
    @State private var showUpgrade = false

    init(reason: UpgradeReason, @ViewBuilder content: () -> Content) {
        self.reason = reason
        self.content = content()
    }

    var body: some View {
        if sub.isPro {
            content
        } else {
            content
                .overlay(
                    ZStack {
                        Color.tsCard.opacity(0.85)
                            .cornerRadius(12)
                        VStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.tsAccent)
                            Text("Pro")
                                .font(.custom("HelveticaNeue-Bold", size: 12))
                                .foregroundColor(.tsAccent)
                        }
                    }
                )
                .onTapGesture { showUpgrade = true }
                .sheet(isPresented: $showUpgrade) {
                    UpgradeSheet(reason: reason)
                        .presentationDetents([.large])
                }
                .allowsHitTesting(true)
        }
    }
}

// MARK: - Blur Gate (for social links etc)

/// Shows blurred content with a lock overlay — for things like Instagram handles.
struct BlurGate<Content: View>: View {
    let reason: UpgradeReason
    let content: Content
    @ObservedObject var sub = SubscriptionManager.shared
    @State private var showUpgrade = false

    init(reason: UpgradeReason, @ViewBuilder content: () -> Content) {
        self.reason = reason
        self.content = content()
    }

    var body: some View {
        if sub.isPro {
            content
        } else {
            ZStack {
                content
                    .blur(radius: 8)
                    .allowsHitTesting(false)
                VStack(spacing: 6) {
                    HStack(spacing: 5) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                        Text("Pro · Tap to unlock")
                            .font(.custom("HelveticaNeue-Bold", size: 12))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#3B99FC"), Color(hex: "#007AFF")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.tsAccent.opacity(0.3), radius: 6, x: 0, y: 3)
                }
            }
            .onTapGesture { showUpgrade = true }
            .sheet(isPresented: $showUpgrade) {
                UpgradeSheet(reason: reason)
                    .presentationDetents([.large])
            }
        }
    }
}
