//
//  OnboardingView.swift
//  TranslateHelper
//

import SwiftUI

struct OnboardingView: View {
    @State private var step = 1
    @State private var selectedLanguage: Language? = nil
    @State private var preloadStarted = false
    @State private var keyboardPreWarmed = false

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
            // Self-assessment — skippable, one tap
            LevelAssessmentView(
                isSkippable: true,
                onComplete: { step = 3 }
            )
        case 3:
            OnboardingGoalsView(
                step: 3, totalSteps: 6,
                onBack: { step = 2 },
                onSkip: { step = 4 },
                onContinue: { step = 4 }
            )
            .background(
                // Hidden text field to pre-warm the iOS keyboard process.
                // First keyboard appearance takes 0.5-1.5s — doing it here means
                // the city search field on step 3 opens instantly.
                KeyboardPreWarmer(triggered: $keyboardPreWarmed)
                    .frame(width: 0, height: 0)
                    .opacity(0)
            )
            .onAppear {
                // Pre-warm keyboard on this step so step 3's search field is instant
                if !keyboardPreWarmed {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        keyboardPreWarmed = true
                    }
                }

                // Start WhisperKit download in background while user continues onboarding.
                // By the time they finish setup + add the keyboard, the model is ready.
                if !preloadStarted {
                    preloadStarted = true
                    DictateViewController.preloadWhisperKit()
                }
            }
        case 4:
            OnboardingLocationView(
                step: 4, totalSteps: 6,
                onBack: { step = 3 },
                onSkip: { step = 5 },
                onContinue: { step = 5 }
            )
        case 5:
            OnboardingStatusView(
                onBack: { step = 4 },
                onContinue: { step = 6 }
            )
        case 6:
            OnboardingInterestsView(
                onBack: { step = 5 },
                onContinue: { step = 7 }
            )
        case 7:
            OnboardingPlanView(
                onBack: { step = 6 },
                onFreePlan: { step = 9 },
                onProTrial: { step = 9 }  // paywall hidden for now — re-enable by routing to step 8
            )
        case 8:
            OnboardingPaywallView(
                onBack: { step = 7 },
                onComplete: { step = 9 }
            )
        case 9:
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

// MARK: - Keyboard Pre-Warmer
// A hidden UITextField that briefly becomes first responder to force iOS
// to load the keyboard process. This eliminates the 1-1.5s delay when the
// user first taps a text field (like the city search on step 3).

struct KeyboardPreWarmer: UIViewRepresentable {
    @Binding var triggered: Bool

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.alpha = 0
        field.isUserInteractionEnabled = false
        return field
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if triggered && !uiView.isFirstResponder {
            // Briefly grab focus to warm the keyboard, then resign
            uiView.becomeFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                uiView.resignFirstResponder()
            }
        }
    }
}
