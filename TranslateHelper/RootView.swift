//
//  RootView.swift
//  TranslateHelper
//

import SwiftUI

/// Routes to SignInView or main app based on auth state.
struct RootView: View {
    @EnvironmentObject var auth: AuthManager

    var body: some View {
        if auth.isSignedIn {
            // TODO: swap for LibraryView() once built
            Text("You're in! Main app coming soon.")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.tsBackground.ignoresSafeArea())
        } else {
            SignInView()
        }
    }
}
