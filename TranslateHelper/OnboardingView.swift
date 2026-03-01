//
//  OnboardingView.swift
//  TranslateHelper
//

import SwiftUI

struct OnboardingView: View {
    @State private var step = 1
    @State private var selectedLanguage: Language? = nil

    var body: some View {
        switch step {
        case 1:
            LanguageSelectionView(
                step: 1,
                totalSteps: 3,
                selectedLanguage: $selectedLanguage,
                onBack: {},           // no back on step 1
                onSkip: { completeOnboarding() },
                onContinue: { step = 2 }
            )
        default:
            // TODO: GoalSelectionView (step 2), PlanView (step 3)
            Color.tsBackground.ignoresSafeArea()
                .onAppear { completeOnboarding() }
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboarding_complete")
    }
}
