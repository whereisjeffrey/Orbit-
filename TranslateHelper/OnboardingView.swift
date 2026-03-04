//
//  OnboardingView.swift
//  TranslateHelper
//

import SwiftUI

struct OnboardingView: View {
    @State private var step = 1
    // v1: Spanish is the only available language — pre-select it so onboarding flows immediately.
    @State private var selectedLanguage: Language? = spanishLanguage

    var body: some View {
        switch step {
        case 1:
            LanguageSelectionView(
                step: 1, totalSteps: 3,
                selectedLanguage: $selectedLanguage,
                onBack: {},
                onSkip: { step = 2 },
                onContinue: { step = 2 }
            )
        case 2:
            OnboardingGoalsView(
                step: 2, totalSteps: 3,
                onBack: { step = 1 },
                onSkip: { step = 3 },
                onContinue: { step = 3 }
            )
        case 3:
            OnboardingLocationView(
                step: 3, totalSteps: 3,
                onBack: { step = 2 },
                onSkip: { step = 4 },
                onContinue: { step = 4 }
            )
        case 4:
            OnboardingPlanView(
                onBack: { step = 3 },
                onFreePlan: { step = 6 },
                onProTrial: { step = 5 }
            )
        case 5:
            OnboardingPaywallView(
                onBack: { step = 4 },
                onComplete: { step = 6 }
            )
        case 6:
            KeyboardSetupSplashView(
                onSkip: { completeOnboarding() }
            )
        default:
            EmptyView()
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboarding_complete")
        
        // Save the chosen language to the shared app group so the keyboard can read it
        if let lang = selectedLanguage {
            let appGroup = "group.com.jeff.translatehelper"
            if let defaults = UserDefaults(suiteName: appGroup) {
                // Determine target language code
                let langCode = lang.code
                // Save both the current toggled state AND the base learned language
                defaults.set(langCode, forKey: "talkswitch_lang")
                defaults.set(langCode, forKey: "talkswitch_target_lang")
                defaults.synchronize()
            }
        }
    }
}
