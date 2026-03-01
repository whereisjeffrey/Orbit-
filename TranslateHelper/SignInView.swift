//
//  SignInView.swift
//  TranslateHelper
//

import SwiftUI
import AuthenticationServices

struct SocialButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isPressed ? Color.tsCard.opacity(0.6) : Color.tsCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.tsAccent.opacity(configuration.isPressed ? 1.0 : 0.4), lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SignInView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var showCreate = false
    @State private var showForgot = false

    private let appleHelper = AppleSignInHelper()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tsBackground.ignoresSafeArea()

                VStack(spacing: 0) {

                    // Wordmark
                    HStack {
                        TSWordmark(iconSize: 42, fontSize: 27)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 52)

                    Spacer()

                    // Sign In block
                    VStack(alignment: .leading, spacing: 0) {

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Sign In")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Text("Find your voice in any language.")
                                .font(.system(size: 15))
                                .foregroundColor(.tsSecondary)
                        }
                        .padding(.bottom, 28)

                        VStack(spacing: 12) {
                            TSTextField(placeholder: "Email", text: $email)
                            TSTextField(placeholder: "Password", text: $password, isSecure: true)
                        }
                        .padding(.bottom, 16)

                        if let err = auth.errorMessage {
                            Text(err).font(.caption).foregroundColor(.red).padding(.bottom, 8)
                        }

                        TSButton(title: "Sign In", isLoading: auth.isLoading) {
                            Task { await auth.signIn(email: email, password: password) }
                        }
                        .padding(.bottom, 16)

                        Button("Forgot Password?") { showForgot = true }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.tsAccent)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.bottom, 28)

                        // Divider
                        HStack(spacing: 12) {
                            Rectangle().frame(height: 1).foregroundColor(Color.tsCard)
                            Text("OR CONTINUE WITH")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.tsSecondary)
                                .tracking(1.5).fixedSize()
                            Rectangle().frame(height: 1).foregroundColor(Color.tsCard)
                        }
                        .padding(.bottom, 20)

                        // Social buttons
                        HStack(spacing: 16) {

                            // Apple — custom, no text
                            Button {
                                let request = auth.appleSignInRequest()
                                let scene = UIApplication.shared.connectedScenes
                                    .first as? UIWindowScene
                                appleHelper.signIn(from: scene, request: request) { result in
                                    Task { await auth.handleAppleSignIn(result: result) }
                                }
                            } label: {
                                Image(systemName: "apple.logo")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                            }
                            .buttonStyle(SocialButtonStyle())

                            // Google — real logo, no text
                            Button {
                                // TODO: wire Google Sign-In after SDK added
                            } label: {
                                Image("GoogleLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                            }
                            .buttonStyle(SocialButtonStyle())
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    // Create account
                    Button(action: { showCreate = true }) {
                        HStack(spacing: 4) {
                            Text("Don't have an account?").foregroundColor(.tsSecondary)
                            Text("Create Account").foregroundColor(.tsAccent).fontWeight(.semibold)
                        }
                        .font(.system(size: 15))
                    }
                    .padding(.bottom, 16)

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
