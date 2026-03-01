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

                ScrollView {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 60)

                        // ── Logo + Title ───────────────────────────────
                        VStack(spacing: 14) {
                            Image("TalkSwitchLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 52, height: 52)

                            VStack(spacing: 6) {
                                Text("Sign In")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Welcome back to your language journey.")
                                    .font(.system(size: 15))
                                    .foregroundColor(.tsSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        Spacer().frame(height: 32)

                        // ── Fields ─────────────────────────────────────
                        VStack(spacing: 12) {
                            TSTextField(placeholder: "Email", text: $email)
                            TSTextField(placeholder: "Password", text: $password, isSecure: true)
                        }

                        Spacer().frame(height: 16)

                        // Error
                        if let err = auth.errorMessage {
                            Text(err)
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 8)
                        }

                        // ── Sign In button ─────────────────────────────
                        TSButton(title: "Sign In", isLoading: auth.isLoading) {
                            Task { await auth.signIn(email: email, password: password) }
                        }

                        // ── Forgot password ────────────────────────────
                        Button("Forgot Password?") { showForgot = true }
                            .font(.system(size: 14))
                            .foregroundColor(.tsAccent)
                            .padding(.top, 14)

                        // ── Divider ────────────────────────────────────
                        HStack {
                            Rectangle().frame(height: 1).foregroundColor(Color.tsBorder)
                            Text("OR CONTINUE WITH")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.tsSecondary)
                                .fixedSize()
                                .padding(.horizontal, 10)
                            Rectangle().frame(height: 1).foregroundColor(Color.tsBorder)
                        }
                        .padding(.vertical, 24)

                        // ── Social buttons: Apple LEFT, Google RIGHT ───
                        HStack(spacing: 12) {

                            // Apple
                            Button {
                                // TODO: wire Apple Sign-In
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "apple.logo")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.white)
                                    Text("Apple")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.tsCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.tsAccent.opacity(0.4), lineWidth: 1.5)
                                )
                                .cornerRadius(14)
                            }

                            // Google
                            Button {
                                // TODO: wire Google Sign-In
                            } label: {
                                HStack(spacing: 8) {
                                    GoogleGIcon()
                                    Text("Google")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.tsCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.tsAccent.opacity(0.4), lineWidth: 1.5)
                                )
                                .cornerRadius(14)
                            }
                        }

                        Spacer().frame(height: 32)

                        // ── Sign up link ───────────────────────────────
                        Button(action: { showCreate = true }) {
                            HStack(spacing: 4) {
                                Text("Don't have an account?").foregroundColor(.tsSecondary)
                                Text("Create Account").foregroundColor(.tsAccent).fontWeight(.semibold)
                            }
                            .font(.system(size: 15))
                        }

                        Spacer().frame(height: 48)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationDestination(isPresented: $showCreate) { CreateAccountView() }
            .navigationDestination(isPresented: $showForgot) { ForgotPasswordView() }
        }
    }
}

// ── Google "G" icon using brand colours ───────────────────────────────────
struct GoogleGIcon: View {
    var body: some View {
        ZStack {
            Text("G")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.26, green: 0.52, blue: 0.96), // Google blue
                            Color(red: 0.92, green: 0.26, blue: 0.21), // Google red
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .frame(width: 22, height: 22)
    }
}
