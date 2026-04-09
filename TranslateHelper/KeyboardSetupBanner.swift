//
//  KeyboardSetupBanner.swift
//  TranslateHelper
//
//  Two-state banner at the top of LibraryView:
//  State 1: Keyboard not installed → "Set up your keyboard" (taps to setup page)
//  State 2: Keyboard installed but never opened → "Tap the globe to switch to Orbit"
//  Hidden once the keyboard has actually been opened.

import SwiftUI

struct KeyboardSetupBanner: View {
    // No dismiss — banner stays until keyboard is actually used
    @State private var keyboardActive = false
    @State private var keyboardInstalled = false
    @State private var showSetupSheet = false

    private let appGroup = "group.com.jeff.translatehelper"

    var body: some View {
        if !keyboardActive {
            if keyboardInstalled {
                // State 2: Installed but never used — teach them the globe
                globeCard
            } else {
                // State 1: Not installed — prompt setup
                setupCard
            }
        }
    }

    // MARK: - Card 1: Setup needed

    private var setupCard: some View {
        Button { showSetupSheet = true } label: {
            HStack(spacing: 12) {
                Text("⌨️")
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Set up your keyboard")
                        .font(.custom("HelveticaNeue-Bold", size: 14))
                        .foregroundColor(.tsLabel)
                    Text("Tap here to get started — it only takes a minute.")
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(.tsSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.tsAccent)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "#F3F9FB"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.tsAccent.opacity(0.25), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $showSetupSheet) {
            KeyboardSetupSplashView(onSkip: { showSetupSheet = false })
        }
        .onAppear { checkStatus() }
    }

    // MARK: - Card 2: Installed but not used — globe hint

    private var globeCard: some View {
        HStack(spacing: 12) {
            Text("🌐")
                .font(.system(size: 24))

            VStack(alignment: .leading, spacing: 2) {
                Text("You're all set!")
                    .font(.custom("HelveticaNeue-Bold", size: 14))
                    .foregroundColor(.tsLabel)
                Text("To start translating, tap the 🌐 globe on your WhatsApp keyboard to switch to Orbit.")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "#F3F9FB"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.tsAccent.opacity(0.25), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .onAppear { checkStatus() }
    }

    // MARK: - Status checks

    private func checkStatus() {
        guard let defaults = UserDefaults(suiteName: appGroup) else { return }

        // Has the keyboard extension ever loaded?
        keyboardActive = defaults.bool(forKey: "keyboard_has_launched")

        // Check if Orbit keyboard is actually in the enabled keyboards list.
        // UITextInputMode.activeInputModes lists all enabled keyboards.
        // Our keyboard uses "mul" (multilingual) as its primary language.
        // Only trust keyboard_has_launched if the keyboard is also currently installed.
        let modes = UITextInputMode.activeInputModes
        let orbitInModes = modes.contains { mode in
            mode.primaryLanguage == "mul"
        }
        keyboardInstalled = orbitInModes

        // If keyboard was "launched" before but is no longer installed
        // (e.g. after app reinstall), reset the flag
        if !orbitInModes && keyboardActive {
            keyboardActive = false
            defaults.set(false, forKey: "keyboard_has_launched")
            defaults.synchronize()
        }
    }
}
