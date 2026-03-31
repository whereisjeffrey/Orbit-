// VoiceKeyboardView.swift
// Presented full-screen when the keyboard taps 🎤 Record and opens the main app via
// the translatehelper://dictate URL scheme (handled in SceneDelegate → presentDictate()).
//
// Flow:
//   1. Screen appears with ambient blob gradient
//   2. Pulsing mic circle starts immediately recording (SFSpeechRecognizer, es-MX)
//   3. Live transcript shown below mic circle
//   4. On isFinal / error → commit result to App Group UserDefaults → dismiss
//      The keyboard polls every 0.5 s and picks it up via checkForPendingDictation().
//
// App Group keys written here (match KeyboardViewController.checkForPendingDictation):
//   "dictate_result"            – transcribed text
//   "dictate_result_language"   – "es" (always, this screen is Spanish-only accent coach)
//   "dictate_mode"              – "accent_coach"
//   "dictate_result_timestamp"  – Unix timestamp of commit

import UIKit
import SwiftUI
import Speech
import AVFoundation

// MARK: - SwiftUI wrapper (presented from SceneDelegate as UIHostingController)

struct VoiceKeyboardView: View {
    var onDismiss: () -> Void = {}

    var body: some View {
        VoiceKeyboardViewController_Representable(onDismiss: onDismiss)
            .ignoresSafeArea()
    }
}

// UIViewControllerRepresentable shim so the UIKit recording VC lives inside SwiftUI
private struct VoiceKeyboardViewController_Representable: UIViewControllerRepresentable {
    var onDismiss: () -> Void
    func makeUIViewController(context: Context) -> DictateViewController {
        DictateViewController()
    }
    func updateUIViewController(_ uiViewController: DictateViewController, context: Context) {}
}

// MARK: - Animated blob gradient background

/// Slow, ambient version of the blob background — same blobs as the splash screen
/// but at 1/3 the frequency so they drift gently during a recording session.
struct VoiceKeyboardBackground: View {

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

    // Very slow drift — blobs barely move so the rich initial arrangement holds.
    // A full cycle takes ~60-90 seconds, so even a long recording stays beautiful.
    private static let configs: [BlobConfig] = [
        BlobConfig(baseX: 0.15, baseY: 0.85, ampX: 0.10, ampY: 0.08, freqX: 0.015, freqY: 0.012, phase: 0.0, radius: 0.90),
        BlobConfig(baseX: 0.80, baseY: 0.85, ampX: 0.08, ampY: 0.10, freqX: 0.012, freqY: 0.016, phase: 1.2, radius: 0.88),
        BlobConfig(baseX: 0.45, baseY: 0.50, ampX: 0.12, ampY: 0.10, freqX: 0.018, freqY: 0.013, phase: 2.4, radius: 0.95),
        BlobConfig(baseX: 0.80, baseY: 0.25, ampX: 0.08, ampY: 0.12, freqX: 0.013, freqY: 0.018, phase: 0.8, radius: 0.88),
        BlobConfig(baseX: 0.20, baseY: 0.22, ampX: 0.10, ampY: 0.08, freqX: 0.016, freqY: 0.014, phase: 3.6, radius: 0.92),
        BlobConfig(baseX: 0.65, baseY: 0.10, ampX: 0.08, ampY: 0.08, freqX: 0.011, freqY: 0.012, phase: 1.8, radius: 0.86),
        BlobConfig(baseX: 0.50, baseY: 0.70, ampX: 0.12, ampY: 0.10, freqX: 0.014, freqY: 0.016, phase: 4.8, radius: 0.90),
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

// MARK: - Container VC: blob gradient + DictateViewController

/// Presented by SceneDelegate when the keyboard opens the app via translatehelper://dictate.
/// Layers the ambient blob gradient behind the recording UI of DictateViewController.
final class VoiceDictateContainerViewController: UIViewController {

    /// Language code ("es", "zh", "fr", etc.) passed from SceneDelegate via the URL param.
    var targetLanguage: String = "es"

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Blob gradient background (SwiftUI, full-screen)
        let bgHost = UIHostingController(rootView: VoiceKeyboardBackground())
        addChild(bgHost)
        bgHost.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgHost.view)
        NSLayoutConstraint.activate([
            bgHost.view.topAnchor.constraint(equalTo: view.topAnchor),
            bgHost.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgHost.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgHost.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        bgHost.didMove(toParent: self)

        // 2. DictateViewController on top — transparent background so gradient shows through
        let dictateVC = DictateViewController()
        dictateVC.targetLanguage = targetLanguage
        dictateVC.view.backgroundColor = .clear
        addChild(dictateVC)
        dictateVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dictateVC.view)
        NSLayoutConstraint.activate([
            dictateVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            dictateVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dictateVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dictateVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        dictateVC.didMove(toParent: self)
    }
}
