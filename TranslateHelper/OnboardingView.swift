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
                onBack: {},
                onSkip: { step = 2 },
                onContinue: { step = 2 }
            )
        case 2:
            OnboardingGoalsView(
                step: 2,
                totalSteps: 3,
                onBack: { step = 1 },
                onSkip: { step = 3 },
                onContinue: { step = 3 }
            )
        case 3:
            OnboardingLocationView(
                step: 3,
                totalSteps: 3,
                onBack: { step = 2 },
                onSkip: { completeOnboarding() },
                onContinue: { completeOnboarding() }
            )
        default:
            EmptyView()
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboarding_complete")
    }
}
