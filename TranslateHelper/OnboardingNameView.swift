//
//  OnboardingNameView.swift
//  TranslateHelper
//
//  First onboarding screen — just captures the user's first name.
//  Used by Sol to occasionally address them by name (sparingly, not every message).
//

import SwiftUI

struct OnboardingNameView: View {
    let onContinue: () -> Void

    @AppStorage("user_first_name") private var savedName = ""
    @State private var name = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            TSGradientBackground().ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Nav bar with progress ──────────────────────────────
                HStack {
                    Color.clear.frame(width: 40, height: 40)
                    Spacer()
                    OnboardingProgressBar(currentStep: 1, totalSteps: 7)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer(minLength: 0)
                    .frame(maxHeight: 60)

                // ── Header ────────────────────────────────────────────
                VStack(spacing: 12) {
                    Text("What's your name?")
                        .font(.custom("HelveticaNeue-Bold", size: 30))
                        .foregroundColor(.tsLabel)
                        .multilineTextAlignment(.center)

                    Text("So we know what to call you.")
                        .font(.custom("HelveticaNeue", size: 16))
                        .foregroundColor(.tsSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 40)

                // ── Name input ────────────────────────────────────────
                TextField("First name", text: $name)
                    .font(.custom("HelveticaNeue-Medium", size: 20))
                    .foregroundColor(.tsLabel)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.tsCard)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isFocused ? Color.tsAccent : Color.tsBorder, lineWidth: isFocused ? 2 : 1)
                    )
                    .focused($isFocused)
                    .textContentType(.givenName)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 40)

                Spacer()

                // ── CTA ───────────────────────────────────────────────
                VStack(spacing: 16) {
                    Button {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            savedName = trimmed
                        }
                        onContinue()
                    } label: {
                        Text("Continue")
                            .font(.custom("HelveticaNeue-Medium", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                Capsule().fill(
                                    name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? Color.tsSecondary.opacity(0.3)
                                    : Color.tsAccent
                                )
                            )
                    }

                    Button {
                        onContinue()
                    } label: {
                        Text("Skip")
                            .font(.custom("HelveticaNeue", size: 15))
                            .foregroundColor(.tsSecondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
}
