//
//  OnboardingProgressBar.swift
//  TranslateHelper
//
//  Shared progress bar for all onboarding screens.
//  Shows segmented bars — current step extended + dark blue, others short.
//

import SwiftUI

struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...totalSteps, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(i <= currentStep ? Color.tsAccent : Color.tsAccent.opacity(0.25))
                    .frame(width: i == currentStep ? 28 : 12, height: 4)
                    .animation(.easeInOut(duration: 0.2), value: currentStep)
            }
        }
    }
}
