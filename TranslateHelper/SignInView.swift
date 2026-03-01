//
//  SignInView.swift
//  TranslateHelper
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var showCreate = false
    @State private var showForgot = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tsBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer().frame(height: 60)

                        // Logo
                        VStack(spacing: 8) {
                            Text("TalkSwitch")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Text("Welcome back")
                                .font(.system(size: 16))
                                .foregroundColor(.tsSecondary)
                        }

                        Spacer().frame(height: 16)

                        // Fields
                        VStack(spacing: 12) {
                            TSTextField(placeholder: "Email", text: $email)
                            TSTextField(placeholder: "Password", text: $password, isSecure: true)
                        }

                        // Forgot password
                        HStack {
                            Spacer()
                            Button("Forgot password?") { showForgot = true }
                                .font(.system(size: 14))
                                .foregroundColor(.tsAccent)
                        }

                        // Error
                        if let err = auth.errorMessage {
                            Text(err)
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Sign In button
                        TSButton(title: "Sign In", isLoading: auth.isLoading) {
                            Task { await auth.signIn(email: email, password: password) }
                        }

                        TSDivider()

                        // Create account
                        Button(action: { showCreate = true }) {
                            HStack(spacing: 4) {
                                Text("Don't have an account?").foregroundColor(.tsSecondary)
                                Text("Sign up").foregroundColor(.tsAccent).fontWeight(.semibold)
                            }
                            .font(.system(size: 15))
                        }

                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationDestination(isPresented: $showCreate) {
                CreateAccountView()
            }
            .navigationDestination(isPresented: $showForgot) {
                ForgotPasswordView()
            }
        }
    }
}
