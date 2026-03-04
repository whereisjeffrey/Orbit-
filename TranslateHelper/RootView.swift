//
//  RootView.swift
//  TranslateHelper
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthManager
    @AppStorage("onboarding_complete")    private var onboardingComplete  = false
    @AppStorage("keyboard_setup_seen")   private var keyboardSetupSeen   = false
    @AppStorage("appTheme")              private var appTheme: Int        = 1 // 0 Light, 1 Dark

    var body: some View {
        Group {
            if !auth.isSignedIn {
                SignInView()
            } else if !onboardingComplete {
                OnboardingView()
            } else if !keyboardSetupSeen {
                // Post-onboarding gate: show full-screen keyboard setup splash
                KeyboardSetupSplashView {
                    keyboardSetupSeen = true
                }
            } else {
                MainTabView()
            }
        }
        .preferredColorScheme(appTheme == 0 ? .light : .dark)
    }
}
