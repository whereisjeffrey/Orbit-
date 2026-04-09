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
                    if let lang = selectedLanguage {
                        LanguageManager.shared.setTargetLang(lang.code)
                    }
                    step = 2
                }
            )
        case 2:
            LevelAssessmentView(
                isSkippable: true,
                onComplete: { step = 3 }
            )
        case 3:
            OnboardingPersonalizeIntroView(
                onContinue: { step = 4 },
                onSkip: { step = 7 }  // skip all personalization → keyboard setup
            )
        case 4:
            OnboardingLocationView(
                step: 4, totalSteps: 7,
                onBack: { step = 3 },
                onSkip: { step = 5 },
                onContinue: { step = 5 }
            )
            .background(
                KeyboardPreWarmer(triggered: $keyboardPreWarmed)
                    .frame(width: 0, height: 0)
                    .opacity(0)
            )
            .onAppear {
                if !keyboardPreWarmed {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        keyboardPreWarmed = true
                    }
                }
                if !preloadStarted {
                    preloadStarted = true
                    DictateViewController.preloadWhisperKit()
                }
            }
        case 5:
            OnboardingStatusView(
                onBack: { step = 4 },
                onContinue: { step = 6 }
            )
        case 6:
            OnboardingInterestsView(
                onBack: { step = 5 },
                onContinue: {
                    seedConversationPool()
                    step = 7
                }
            )
        case 7:
            KeyboardSetupSplashView(
                onSkip: { completeOnboarding() }
            )
        default:
            EmptyView()
        }
    }

    private func seedConversationPool() {
        let interestsRaw = UserDefaults.standard.string(forKey: "user_interests") ?? ""
        let interests = interestsRaw.split(separator: ",").map(String.init)
        guard !interests.isEmpty else { return }

        let cityName = UserLocationsStore.shared.locations.first?.displayName ?? "their city"

        DispatchQueue.global(qos: .utility).async {
            ConversationPoolManager.shared.seedPool(city: cityName, interests: interests) { success in
                NSLog("🌐 [Onboarding] Conversation pool seed: \(success ? "success" : "failed")")
            }
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboarding_complete")

        // Reset conversation scripts so party opener fires on first Sol session
        ConversationScriptEngine.shared.resetAll()

        if let lang = selectedLanguage {
            LanguageManager.shared.setTargetLang(lang.code)
            UserDefaults(suiteName: "group.com.jeff.translatehelper")?.set(lang.code, forKey: "talkswitch_lang")
            UserDefaults(suiteName: "group.com.jeff.translatehelper")?.synchronize()
        }
    }
}

// MARK: - Keyboard Pre-Warmer

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
            uiView.becomeFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                uiView.resignFirstResponder()
            }
        }
    }
}
