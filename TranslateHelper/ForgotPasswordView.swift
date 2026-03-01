//
//  ForgotPasswordView.swift
//  TranslateHelper
//

import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var sent = false

    var body: some View {
        ZStack {
            Color.tsBackground.ignoresSafeArea()
            VStack(spacing: 28) {
                Spacer().frame(height: 20)

                if sent {
                    // Check email state
                    VStack(spacing: 16) {
                        Image(systemName: "envelope.badge.checkmark.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.tsAccent)

                        Text("Check Your Email")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.tsLabel)

                        Text("We sent a reset link to\n\(email)")
                            .font(.system(size: 15))
                            .foregroundColor(.tsSecondary)
                            .multilineTextAlignment(.center)

                        TSButton(title: "Back to Sign In") { dismiss() }
                            .padding(.top, 8)

                        Button("Resend email") {
                            Task {
                                sent = await auth.resetPassword(email: email)
                            }
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.tsAccent)
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("Forgot Password?")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.tsLabel)
                        Text("Enter your email and we'll send a reset link")
                            .font(.system(size: 15))
                            .foregroundColor(.tsSecondary)
                            .multilineTextAlignment(.center)
                    }

                    TSTextField(placeholder: "Email", text: $email)

                    if let err = auth.errorMessage {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    TSButton(title: "Send Reset Link", isLoading: auth.isLoading) {
                        Task { sent = await auth.resetPassword(email: email) }
                    }
                    .disabled(email.isEmpty)
                    .opacity(email.isEmpty ? 0.5 : 1)

                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Text("Back to").foregroundColor(.tsSecondary)
                            Text("Sign In").foregroundColor(.tsAccent).fontWeight(.semibold)
                        }
                        .font(.system(size: 15))
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
