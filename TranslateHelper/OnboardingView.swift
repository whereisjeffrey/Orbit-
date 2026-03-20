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
                step: 1, totalSteps: 5,
                selectedLanguage: $selectedLanguage,
                onBack: {},
                onSkip: { step = 2 },
                onContinue: { step = 2 }
            )
        case 2:
            OnboardingGoalsView(
                step: 2, totalSteps: 5,
                onBack: { step = 1 },
                onSkip: { step = 3 },
                onContinue: { step = 3 }
            )
        case 3:
            OnboardingLocationView(
                step: 3, totalSteps: 5,
                onBack: { step = 2 },
                onSkip: { step = 4 },
                onContinue: { step = 4 }
            )
        case 4:
            OnboardingStatusView(
                onBack: { step = 3 },
                onContinue: { step = 5 }
            )
        case 5:
            OnboardingInterestsView(
                onBack: { step = 4 },
                onContinue: { step = 6 }
            )
        case 6:
            OnboardingPlanView(
                onBack: { step = 5 },
                onFreePlan: { step = 8 },
                onProTrial: { step = 8 }  // paywall hidden for now — re-enable by routing to step 7
            )
        case 7:
            OnboardingPaywallView(
                onBack: { step = 6 },
                onComplete: { step = 8 }
            )
        case 8:
            KeyboardSetupSplashView(
                onSkip: { completeOnboarding() }
            )
        default:
            EmptyView()
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboarding_complete")

        if let lang = selectedLanguage {
            let appGroup = "group.com.jeff.translatehelper"
            if let defaults = UserDefaults(suiteName: appGroup) {
                defaults.set(lang.code, forKey: "talkswitch_lang")
                defaults.set(lang.code, forKey: "talkswitch_target_lang")
                defaults.synchronize()
            }
        }
    }
}
