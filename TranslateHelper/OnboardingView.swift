//
//  OnboardingView.swift
//  TranslateHelper
//

import SwiftUI

struct OnboardingView: View {
    @State private var step = 1
    @State private var selectedLanguage: Language? = nil
    @State private var preloadStarted = false

    var body: some View {
        switch step {
        case 1:
            LanguageSelectionView(
                step: 1, totalSteps: 5,
                selectedLanguage: $selectedLanguage,
                onBack: {},
                onSkip: { step = 2 },
                onContinue: {
                    // Write language to App Group IMMEDIATELY — before anything else.
                    // This ensures talkswitch_target_lang is set even if onboarding is abandoned.
                    if let lang = selectedLanguage {
                        LanguageManager.shared.setTargetLang(lang.code)
                    }
                    step = 2
                }
            )
        case 2:
            OnboardingGoalsView(
                step: 2, totalSteps: 5,
                onBack: { step = 1 },
                onSkip: { step = 3 },
                onContinue: { step = 3 }
            )
            .onAppear {
                // Start WhisperKit download in background while user continues onboarding.
                // By the time they finish setup + add the keyboard, the model is ready.
                if !preloadStarted {
                    preloadStarted = true
                    DictateViewController.preloadWhisperKit()
                }
            }
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

        // Write language via LanguageManager (may already be set from step 1,
        // but we write again in case they changed it during onboarding)
        if let lang = selectedLanguage {
            LanguageManager.shared.setTargetLang(lang.code)
            // Also write talkswitch_lang for keyboard's active language
            UserDefaults(suiteName: "group.com.jeff.translatehelper")?.set(lang.code, forKey: "talkswitch_lang")
            UserDefaults(suiteName: "group.com.jeff.translatehelper")?.synchronize()
        }
    }
}
