//
//  KeyboardSetupBanner.swift
//  TranslateHelper
//

import SwiftUI

/// Compact persistent banner shown at the top of LibraryView until the
/// TalkSwitch keyboard has been activated. Tapping "Set Up →" deep-links
/// directly to the iOS keyboard list (Add New Keyboard).
///
/// Dismissal: the X button sets `keyboard_banner_dismissed = true` in
/// UserDefaults so it stays dismissed for the rest of the session.
/// The banner auto-hides permanently once the keyboard extension writes
/// `keyboard_has_launched = true` to the shared app group on its first run.
struct KeyboardSetupBanner: View {
    @AppStorage("keyboard_banner_dismissed") private var dismissed = false
    @State private var keyboardActive = false

    private let appGroup = "group.com.jeff.translatehelper"

    var body: some View {
        // Resolve visibility: hidden if dismissed OR keyboard already launched
        if !dismissed && !keyboardActive {
            HStack(spacing: 10) {

                // Mini logo + name
                HStack(spacing: 6) {
                    Image("TalkSwitchLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .colorMultiply(Color.tsAccent)

                    Text("TalkSwitch")
                        .font(.sono(13))
                        .foregroundColor(.tsAccent)
                }

                // Divider
                Rectangle()
                    .fill(Color.tsAccent.opacity(0.25))
                    .frame(width: 1, height: 20)

                // Message
                Text("Keyboard not set up")
                    .font(.custom("HelveticaNeue-Medium", size: 13))
                    .foregroundColor(.tsLabel)
                    .lineLimit(1)

                Spacer()

                // CTA
                Button(action: openKeyboardSettings) {
                    HStack(spacing: 4) {
                        Text("Set Up")
                            .font(.custom("HelveticaNeue-Medium", size: 13))
                        Image(systemName: "chevron.right")
                            .font(.custom("HelveticaNeue-Medium", size: 11))
                    }
                    .foregroundColor(.tsAccent)
                }

                // Dismiss X
                Button(action: { dismissed = true }) {
                    Image(systemName: "xmark")
                        .font(.custom("HelveticaNeue-Medium", size: 11))
                        .foregroundColor(.tsSecondary)
                        .frame(width: 24, height: 24)
                        .background(Color.tsSecondary.opacity(0.12))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.tsAccent.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.tsAccent.opacity(0.20), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
            .onAppear { checkKeyboardActive() }
        }
    }

    // MARK: - Keyboard detection
    /// Auto-hides the banner once the keyboard extension has run at least once.
    private func checkKeyboardActive() {
        guard let defaults = UserDefaults(suiteName: appGroup) else { return }
        keyboardActive = defaults.bool(forKey: "keyboard_has_launched")
    }

    // MARK: - Deep-link
    private func openKeyboardSettings() {
        let candidates: [String] = [
            "App-Prefs:root=General&path=Keyboard/KEYBOARDS",
            "App-Prefs:root=General&path=Keyboard",
            UIApplication.openSettingsURLString
        ]
        for str in candidates {
            if let url = URL(string: str), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }
        }
    }
}
