//
//  RootView.swift
//  TranslateHelper
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthManager

    var body: some View {
        if auth.isSignedIn {
            MainTabView()
        } else {
            SignInView()
        }
    }
}
