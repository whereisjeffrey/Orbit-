//
//  SignInView.swift
//  TranslateHelper
//

import SwiftUI
import AuthenticationServices

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

                VStack(spacing: 0) {

                    // ── Top-left wordmark ──────────────────────────────
                    HStack(spacing: 8) {
                        Image("TalkSwitchLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                        Text("TalkSwitch")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 56)

                    Spacer()

                    // ── Main content block (vertically centred) ────────
                    VStack(alignment: .leading, spacing: 0) {

                        // Left-aligned title
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Sign In")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Text("Welcome back to your language journey.")
                                .font(.system(size: 15))
                                .foregroundColor(.tsSecondary)
                        }
                        .padding(.bottom, 28)

                        // Fields
                        VStack(spacing: 12) {
                            TSTextField(placeholder: "Email", text: $email)
                            TSTextField(placeholder: "Password", text: $password, isSecure: true)
                        }
                        .padding(.bottom, 16)

                        // Error
                        if let err = auth.errorMessage {
                            Text(err)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.bottom, 8)
                        }

                        // Sign In button
                        TSButton(title: "Sign In", isLoading: auth.isLoading) {
                            Task { await auth.signIn(email: email, password: password) }
                        }
                        .padding(.bottom, 16)

                        // Forgot password
                        Button("Forgot Password?") { showForgot = true }
                            .font(.system(size: 14))
                            .foregroundColor(.tsAccent)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.bottom, 28)

                        // OR CONTINUE WITH
                        HStack(spacing: 12) {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.tsCard)
                            Text("OR CONTINUE WITH")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.tsSecondary)
                                .tracking(1.5)
                                .fixedSize()
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.tsCard)
                        }
                        .padding(.bottom, 20)

                        // Social buttons — icon only
                        HStack(spacing: 16) {
                            Button {
                            } label: {
                                Image(systemName: "apple.logo")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.tsCard)
                                    .cornerRadius(16)
                            }

                            Button {
                            } label: {
                                GoogleGIcon(size: 24)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.tsCard)
                                    .cornerRadius(16)
                            }
                        }
                        .padding(.bottom, 24)

                        // Don't have an account — below social buttons
                        Button(action: { showCreate = true }) {
                            HStack(spacing: 4) {
                                Text("Don't have an account?")
                                    .foregroundColor(.tsSecondary)
                                Text("Create Account")
                                    .foregroundColor(.tsAccent)
                                    .fontWeight(.semibold)
                            }
                            .font(.system(size: 15))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    // Home indicator
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 128, height: 5)
                        .padding(.bottom, 12)
                }
            }
            .navigationDestination(isPresented: $showCreate) { CreateAccountView() }
            .navigationDestination(isPresented: $showForgot) { ForgotPasswordView() }
        }
    }
}

struct GoogleGIcon: View {
    var size: CGFloat = 20
    var body: some View {
        Text("G")
            .font(.system(size: size, weight: .bold))
            .foregroundStyle(
                LinearGradient(
                    colors: [Color(hex: "#4285F4"), Color(hex: "#EA4335")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}
