//
//  RootView.swift
//  TranslateHelper
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthManager
    @AppStorage("onboarding_complete") private var onboardingComplete = false
    @AppStorage("appTheme") private var appTheme: Int = 1 // 0 for Light, 1 for Dark

    var body: some View {
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
    }
}
