//
//  RootView.swift
//  TranslateHelper
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthManager
    @AppStorage("onboarding_complete") private var onboardingComplete = false
    @AppStorage("appTheme") private var appTheme: Int = 0 // 0 = Light, 1 = Dark

    /// True until the splash animation completes (~2.3 s). Reset on every cold launch.
    @State private var showSplash = true

    var body: some View {
        ZStack {
            // ── Main app content (rendered underneath during splash) ──────────
            Group {
                if !auth.isSignedIn {
                    SignInView()
                } else if !onboardingComplete {
                    OnboardingView()
                } else {
                    MainTabView()
                }
            }
            .preferredColorScheme(appTheme == 0 ? .light : .dark)

            // ── Splash screen gate ──────────────────────────────────────────
            if showSplash {
                SplashScreenView {
                    showSplash = false
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}

