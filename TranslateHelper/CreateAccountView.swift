import SwiftUI

struct CreateAccountView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var auth: AuthManager
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showLanguageSelection = false

    var body: some View {
        ZStack {
            Color.tsBackground.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.tsAccent)
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                    Text("Create Account")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.tsLabel)
                    Spacer()
                    Spacer().frame(width: 44) // Balance
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Join the journey")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.tsLabel)
                            Text("Start mastering new languages today.")
                                .font(.system(size: 17))
                                .foregroundColor(.tsSecondary)
                        }
                        .padding(.top, 16)
                        
                        VStack(spacing: 20) {
                            OnboardingField(title: "FULL NAME", placeholder: "John Doe", text: $fullName)
                            OnboardingField(title: "EMAIL ADDRESS", placeholder: "example@email.com", text: $email)
                            OnboardingField(title: "PASSWORD", placeholder: "••••••••", text: $password, isSecure: true)
                        }
                        
                        Text("By creating an account, you agree to our Terms of Service and Privacy Policy.")
                            .font(.system(size: 13))
                            .foregroundColor(.tsSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 12)
                            .padding(.horizontal, 8)
                    }
                    .padding(.horizontal, 24)
                }
                
                // Footer
                VStack(spacing: 16) {
                    Button(action: {
                        Task {
                            await auth.createAccount(fullName: fullName, email: email, password: password)
                            if auth.errorMessage == nil {
                                showLanguageSelection = true
                            }
                        }
                    }) {
                        ZStack {
                            Text("Create Account")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.tsLabel)
                                .opacity(auth.isLoading ? 0 : 1)
                            
                            if auth.isLoading {
                                ProgressView().tint(.tsLabel)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(colors: [Color(hex: "2E92FF"), Color(hex: "1877F2")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(28)
                        .shadow(color: Color(hex: "1877F2").opacity(0.3), radius: 12, y: 4)
                    }
                    .disabled(auth.isLoading)
                    
                    Button(action: { dismiss() }) {
                        Text("Already have an account? Log in")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.tsAccent)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .padding(.top, 16)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showLanguageSelection) {
            OnboardingLanguageView()
        }
    }
}

struct OnboardingField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.tsSecondary)
                .tracking(1.0)
                .padding(.leading, 4)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.system(size: 17))
            .foregroundColor(.tsLabel)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.tsInputBg)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.tsBorder, lineWidth: 1)
            )
        }
    }
}
