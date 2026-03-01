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

                VStack(alignment: .leading, spacing: 0) {

                    // ── Top-left logo ──────────────────────────────────
                    Image("TalkSwitchLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .padding(.top, 56)
                        .padding(.leading, 24)

                    Spacer()

                    // ── Main content block (vertically centred) ────────
                    VStack(spacing: 20) {

                        // Title
                        VStack(spacing: 6) {
                            Text("TalkSwitch")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)
                            Text("Welcome back")
                                .font(.system(size: 16))
                                .foregroundColor(.tsSecondary)
                        }
                        .frame(maxWidth: .infinity)

                        Spacer().frame(height: 8)

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

                        // Social buttons
                        VStack(spacing: 12) {
                            // Apple
                            SignInWithAppleButton(.signIn) { request in
                                request.requestedScopes = [.fullName, .email]
                            } onCompletion: { result in
                                // TODO: wire up Apple auth
                            }
                            .signInWithAppleButtonStyle(.white)
                            .frame(height: 52)
                            .cornerRadius(14)

                            // Google (placeholder — needs GoogleSignIn SDK)
                            Button {
                                // TODO: wire up Google Sign-In
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "g.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.tsAccent)
                                    Text("Continue with Google")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.tsCard)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tsBorder, lineWidth: 1))
                                .cornerRadius(14)
                            }
                        }

                        // Sign up link
                        Button(action: { showCreate = true }) {
                            HStack(spacing: 4) {
                                Text("Don't have an account?").foregroundColor(.tsSecondary)
                                Text("Sign up").foregroundColor(.tsAccent).fontWeight(.semibold)
                            }
                            .font(.system(size: 15))
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .navigationDestination(isPresented: $showCreate) { CreateAccountView() }
            .navigationDestination(isPresented: $showForgot) { ForgotPasswordView() }
        }
    }
}
