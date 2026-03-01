//
//  OnboardingView.swift
//  TranslateHelper
//

import SwiftUI

struct OnboardingView: View {
    @State private var step = 0
    @State private var selectedLanguage: Language? = nil

    var body: some View {
        switch step {
        case 0:
            LanguageSelectionView(selectedLanguage: $selectedLanguage) {
                step = 1
            }
        default:
            // TODO: GoalSelectionView, PlanView
            // For now, complete onboarding
            Color.tsBackground.ignoresSafeArea()
                .onAppear {
                    UserDefaults.standard.set(true, forKey: "onboarding_complete")
                }
        }
    }
}
