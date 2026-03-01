//
//  RootView.swift
//  TranslateHelper
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthManager
    @AppStorage("onboarding_complete") private var onboardingComplete = false

    var body: some View {
        if !auth.isSignedIn {
            SignInView()
        } else if !onboardingComplete {
            OnboardingView()
        } else {
            MainTabView()
        }
    }
}
