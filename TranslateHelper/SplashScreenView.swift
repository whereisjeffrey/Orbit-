// SplashScreenView.swift
// Timeline: entrance pop-in → 1.4 s → logo spins 360° (0.5 s) → 1.9 s → fade-out (0.4 s) → done.
// Background: SplashFinisherBackground — same liquid blobs as Voice Translate,
//             but with faster frequencies so the movement is clearly visible
//             within the short splash window.
// Logo: OrbitLogo image asset (white-on-transparent PNG processed from original).

import SwiftUI

struct SplashScreenView: View {
    /// Called once the splash timer fires and the fade-out completes.
    var onFinished: () -> Void

    // ── Content entrance ──────────────────────────────────────────
    @State private var contentOpacity: Double  = 0
    @State private var contentScale:   CGFloat = 0.92

    // ── Logo spin ─────────────────────────────────────────────────
    @State private var logoRotation:   Double  = 0

    // ── Exit ──────────────────────────────────────────────────────
    @State private var exitOpacity:    Double  = 1

    var body: some View {
        ZStack {
            // The same liquid-gradient background as the Voice Translate screen
            VoiceKeyboardBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // ── Logo ────────────────────────────────────────────────
                Image("OrbitLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 165, height: 165)
                    .rotationEffect(.degrees(logoRotation))

                // ── "Orbit" wordmark ─────────────────────────────────────
                Text("Orbit")
                    .font(.museoModerno(46))
                    .foregroundColor(.white)
                    .kerning(1.5)
                    .padding(.top, 14)

                // ── Tagline ──────────────────────────────────────────────
                Text("Language in the Wild.")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(.white.opacity(0.72))
                    .kerning(0.3)
                    .padding(.top, 2)

                Spacer()
            }
            .scaleEffect(contentScale)
            .opacity(contentOpacity)
        }
        .opacity(exitOpacity)
        .onAppear {
            // 1. Entrance — gentle spring pop-in
            withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) {
                contentOpacity = 1
                contentScale   = 1
            }

            // 2. Spin — one full 2D rotation at 1.4 s, completes in 0.5 s
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.linear(duration: 0.5)) {
                    logoRotation = 360
                }
            }

            // 3. Fade-out — starts at 1.9 s, completes in 0.4 s  (total ≈ 2.3 s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    exitOpacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onFinished()
                }
            }
        }
    }
}


// MARK: - Animated gradient background (mirrors VoiceKeyboardView exactly)

struct SplashFinisherBackground: View {

    private static let blobColors: [Color] = [
        Color(red: 1.000, green: 0.420, blue: 0.000),
        Color(red: 0.984, green: 0.000, blue: 0.376),
        Color(red: 0.820, green: 0.000, blue: 0.820),
        Color(red: 0.420, green: 0.000, blue: 0.900),
        Color(red: 0.000, green: 0.780, blue: 0.820),
        Color(red: 0.050, green: 0.300, blue: 0.980),
        Color(red: 1.000, green: 0.000, blue: 0.290),
    ]

    private struct BlobConfig {
        let baseX, baseY: Double
        let ampX,  ampY:  Double
        let freqX, freqY: Double
        let phase:        Double
        let radius:       Double
    }

    // Frequencies are 3× the VoiceKeyboard values so the blobs move visibly
    // within the 2.2 s splash window. The slow version is still used in VoiceKeyboard
    // for its longer, ambient feel.
    private static let configs: [BlobConfig] = [
        BlobConfig(baseX: 0.15, baseY: 0.85, ampX: 0.20, ampY: 0.18, freqX: 0.33, freqY: 0.27, phase: 0.0, radius: 0.90),
        BlobConfig(baseX: 0.80, baseY: 0.85, ampX: 0.18, ampY: 0.20, freqX: 0.27, freqY: 0.36, phase: 1.2, radius: 0.88),
        BlobConfig(baseX: 0.45, baseY: 0.50, ampX: 0.22, ampY: 0.20, freqX: 0.39, freqY: 0.30, phase: 2.4, radius: 0.95),
        BlobConfig(baseX: 0.80, baseY: 0.25, ampX: 0.18, ampY: 0.22, freqX: 0.30, freqY: 0.39, phase: 0.8, radius: 0.88),
        BlobConfig(baseX: 0.20, baseY: 0.22, ampX: 0.20, ampY: 0.18, freqX: 0.36, freqY: 0.33, phase: 3.6, radius: 0.92),
        BlobConfig(baseX: 0.65, baseY: 0.10, ampX: 0.16, ampY: 0.16, freqX: 0.24, freqY: 0.27, phase: 1.8, radius: 0.86),
        BlobConfig(baseX: 0.50, baseY: 0.70, ampX: 0.22, ampY: 0.20, freqX: 0.33, freqY: 0.36, phase: 4.8, radius: 0.90),
    ]

    @State private var startDate = Date()

    var body: some View {
        Color(red: 0.38, green: 0.00, blue: 0.55)
            .overlay(
                TimelineView(.animation) { timeline in
                    Canvas { ctx, size in
                        let t = timeline.date.timeIntervalSince(startDate)
                        for i in Self.configs.indices {
                            let cfg   = Self.configs[i]
                            let color = Self.blobColors[i % Self.blobColors.count]
                            let cx = (cfg.baseX + cfg.ampX * sin(2 * .pi * cfg.freqX * t + cfg.phase)) * size.width
                            let cy = (cfg.baseY + cfg.ampY * cos(2 * .pi * cfg.freqY * t + cfg.phase)) * size.height
                            let r  = cfg.radius * min(size.width, size.height)
                            let gradient = Gradient(stops: [
                                .init(color: color.opacity(0.68), location: 0.0),
                                .init(color: color.opacity(0.0),  location: 1.0),
                            ])
                            let shading = GraphicsContext.Shading.radialGradient(
                                gradient,
                                center: CGPoint(x: cx, y: cy),
                                startRadius: 0,
                                endRadius: r
                            )
                            var innerCtx = ctx
                            innerCtx.blendMode = .lighten
                            innerCtx.fill(
                                Path(ellipseIn: CGRect(x: cx - r, y: cy - r,
                                                       width: r * 2, height: r * 2)),
                                with: shading
                            )
                        }
                    }
                }
            )
            .onAppear { startDate = Date() }
    }
}
