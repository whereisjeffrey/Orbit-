//
//  KeyboardSetupSplashView.swift
//  TranslateHelper
//

import SwiftUI

struct KeyboardSetupSplashView: View {
    let onSkip: () -> Void

    @State private var cardPulse = false
    @State private var iconBounce = false

    // ── Layout constants ──────────────────────────────────────────────────
    private let cardCorner: CGFloat = 28
    private let stepIconSize: CGFloat = 32

    var body: some View {
        ZStack {
            // Gradient background — same as Lightning Round / voice recording
            VoiceKeyboardBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer(minLength: 48)

                // ── Top: Orbit logo + wordmark ────────────────────────
                VStack(spacing: 4) {
                    Image("OrbitLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .scaleEffect(iconBounce ? 1.03 : 1.0)
                        .animation(
                            .easeInOut(duration: 2.2).repeatForever(autoreverses: true),
                            value: iconBounce
                        )

                    Text("Orbit")
                        .font(.museoModerno(32))
                        .foregroundColor(.white)
                        .kerning(1.2)
                        .padding(.top, -16)
                }
                .onAppear { iconBounce = true }

                Spacer(minLength: 10)

                // ── Frosted glass setup card ────────────────────────────
                VStack(spacing: 0) {

                    // Card header — keyboard icon in a glassy circle (smaller)
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                                )
                                .frame(width: 68, height: 68)

                            Image(systemName: "keyboard.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }

                        Text("Enable Your Keyboard")
                            .font(.custom("HelveticaNeue-Bold", size: 20))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)

                    // Instruction copy
                    Text("Set up the Orbit keyboard to translate\nmessages right inside WhatsApp.")
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)

                    // Steps — no inner container, just glassy number circles
                    VStack(alignment: .leading, spacing: 14) {
                        KBSetupStep(
                            number: 1,
                            icon: "gearshape.fill",
                            text: "Tap the button below to open **Orbit settings**"
                        )
                        KBSetupStep(
                            number: 2,
                            icon: "keyboard.fill",
                            text: "Tap **Keyboards**"
                        )
                        KBSetupStep(
                            number: 3,
                            icon: "hand.tap.fill",
                            text: "Toggle on the **Orbit keyboard**"
                        )
                        KBSetupStep(
                            number: 4,
                            icon: "checkmark.shield.fill",
                            text: "Toggle on **Allow Full Access**"
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                    // CTA button — glassy with white stroke, white text
                    Button(action: openKeyboardSettings) {
                        HStack(spacing: 8) {
                            Image(systemName: "keyboard.badge.ellipsis")
                                .font(.system(size: 15, weight: .medium))
                            Text("Set Up Keyboard")
                                .font(.custom("HelveticaNeue-Bold", size: 16))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.15))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                }
                .background(
                    RoundedRectangle(cornerRadius: cardCorner)
                        .fill(Color.white.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: cardCorner)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)

                Spacer(minLength: 32)

                // Skip link
                Button(action: onSkip) {
                    Text("Skip for now")
                        .font(.custom("HelveticaNeue", size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.bottom, 48)
            }
        }
    }

    // ── Deep-link directly to the Add Keyboard screen ─────────────────────
    // App-Prefs:root=General&path=Keyboard/KEYBOARDS drops the user
    // directly onto the keyboards list — TalkSwitch appears under
    // "Suggested Keyboards" so they just tap it, no digging required.
    private func openKeyboardSettings() {
        let candidates: [String] = [
            "App-Prefs:root=General&path=Keyboard/KEYBOARDS",
            "App-Prefs:root=General&path=Keyboard",
            UIApplication.openSettingsURLString
        ]
        for str in candidates {
            if let url = URL(string: str), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }
        }
    }
}

// MARK: - Pulsing keyboard icon
/// A keyboard SF Symbol centred inside 3 concentric ping rings that
/// expand outward and fade in a staggered loop, like a sonar signal.
private struct PulsingKeyboardIcon: View {

    // Each ring gets its own phase offset so they stagger nicely
    @State private var ring1 = false
    @State private var ring2 = false
    @State private var ring3 = false

    private let baseSize: CGFloat  = 64   // inner circle diameter
    private let maxRingSize: CGFloat = 130 // how far rings expand to

    // Gradient: solid blue matching tsBluePrimary
    private let gradient = LinearGradient(
        colors: [Color.tsAccent, Color(hex: "#004775")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack {
            // ── Ring 3 (outermost, starts last) ──
            Circle()
                .stroke(gradient, lineWidth: ring3 ? 0.5 : 2)
                .frame(
                    width:  ring3 ? maxRingSize : baseSize,
                    height: ring3 ? maxRingSize : baseSize
                )
                .opacity(ring3 ? 0 : 0.55)
                .animation(
                    .easeOut(duration: 1.6).repeatForever(autoreverses: false).delay(0.6),
                    value: ring3
                )

            // ── Ring 2 (middle) ──
            Circle()
                .stroke(gradient, lineWidth: ring2 ? 0.5 : 2)
                .frame(
                    width:  ring2 ? maxRingSize : baseSize,
                    height: ring2 ? maxRingSize : baseSize
                )
                .opacity(ring2 ? 0 : 0.65)
                .animation(
                    .easeOut(duration: 1.6).repeatForever(autoreverses: false).delay(0.3),
                    value: ring2
                )

            // ── Ring 1 (innermost, starts first) ──
            Circle()
                .stroke(gradient, lineWidth: ring1 ? 0.5 : 2)
                .frame(
                    width:  ring1 ? maxRingSize : baseSize,
                    height: ring1 ? maxRingSize : baseSize
                )
                .opacity(ring1 ? 0 : 0.75)
                .animation(
                    .easeOut(duration: 1.6).repeatForever(autoreverses: false),
                    value: ring1
                )

            // ── Icon circle ──
            Circle()
                .fill(gradient.opacity(0.15))
                .frame(width: baseSize, height: baseSize)
                .overlay(
                    Circle()
                        .stroke(gradient, lineWidth: 1.5)
                )

            Image(systemName: "keyboard.fill")
                .font(.custom("HelveticaNeue-Medium", size: 26))
                .foregroundStyle(LinearGradient.tsVibrant)
        }
        .frame(width: maxRingSize, height: maxRingSize) // hold space for largest ring
        .onAppear {
            ring1 = true
            ring2 = true
            ring3 = true
        }
    }
}


// MARK: - Step row
private struct KBSetupStep: View {
    let number: Int
    let icon: String
    let text: LocalizedStringKey

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Number bubble — glassy circle with white stroke
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .frame(width: 30, height: 30)
                Text("\(number)")
                    .font(.custom("HelveticaNeue-Bold", size: 13))
                    .foregroundColor(.white)
            }

            Text(text)
                .font(.custom("HelveticaNeue", size: 13))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    KeyboardSetupSplashView(onSkip: {})
        .preferredColorScheme(.dark)
}
