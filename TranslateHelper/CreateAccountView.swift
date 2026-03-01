//
//  CreateAccountView.swift
//  TranslateHelper
//

import SwiftUI

struct CreateAccountView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var agreedToTerms = false

    var canSubmit: Bool {
        !fullName.isEmpty && !email.isEmpty && password.count >= 6 && agreedToTerms
    }

    var body: some View {
        ZStack {
            Color.tsBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 20)

                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Text("Start learning from real conversations")
                            .font(.system(size: 15))
                            .foregroundColor(.tsSecondary)
                    }

                    Spacer().frame(height: 8)

                    VStack(spacing: 12) {
                        TSTextField(placeholder: "Full Name", text: $fullName)
                        TSTextField(placeholder: "Email", text: $email)
                        TSTextField(placeholder: "Password (6+ characters)", text: $password, isSecure: true)
                    }

                    // Terms
                    Button(action: { agreedToTerms.toggle() }) {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                .foregroundColor(agreedToTerms ? .tsAccent : .tsSecondary)
                                .font(.system(size: 20))
                            Text("I agree to the Terms of Service and Privacy Policy")
                                .font(.system(size: 13))
                                .foregroundColor(.tsSecondary)
                                .multilineTextAlignment(.leading)
                        }
                    }

                    if let err = auth.errorMessage {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    TSButton(title: "Create Account", isLoading: auth.isLoading) {
                        Task { await auth.createAccount(fullName: fullName, email: email, password: password) }
                    }
                    .disabled(!canSubmit)
                    .opacity(canSubmit ? 1 : 0.5)

                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Text("Already have an account?").foregroundColor(.tsSecondary)
                            Text("Sign in").foregroundColor(.tsAccent).fontWeight(.semibold)
                        }
                        .font(.system(size: 15))
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
