import SwiftUI

struct OnboardingLanguageView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedLanguage: String? = "English"
    @State private var showGoals = false
    
    let languages = [
        ("🇺🇸", "English"),
        ("🇧🇷", "Portuguese"),
        ("🇪🇸", "Spanish"),
        ("🇫🇷", "French"),
        ("🇩🇪", "German"),
        ("🇮🇹", "Italian"),
        ("🇯🇵", "Japanese"),
        ("🇰🇷", "Korean")
    ]

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
                    // Progress Bar
                    HStack(spacing: 0) {
                        Rectangle().fill(Color.tsAccent).frame(width: 40, height: 6)
                        Rectangle().fill(Color.tsCard).frame(width: 80, height: 6)
                    }
                    .clipShape(Capsule())
                    
                    Spacer()
                    Button(action: { showGoals = true }) {
                        Text("Skip")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.tsAccent)
                    }
                    .frame(width: 44, alignment: .trailing)
                    .padding(.trailing, 8)
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("I want to learn...")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)
                            Text("Select the language you'd like to master. You can add more later.")
                                .font(.system(size: 17))
                                .foregroundColor(.tsSecondary)
                        }
                        .padding(.top, 16)
                        
                        // Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(languages, id: \.1) { flag, name in
                                let isSelected = selectedLanguage == name
                                Button(action: { selectedLanguage = name }) {
                                    VStack(spacing: 12) {
                                        Text(flag).font(.system(size: 40))
                                        Text(name)
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 120)
                                    .background(isSelected ? Color.tsCard : Color.tsCard.opacity(0.5))
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(isSelected ? Color.tsAccent : Color.clear, lineWidth: 2)
                                    )
                                    .overlay(
                                        alignment: .topTrailing
                                    ) {
                                        if isSelected {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.tsAccent)
                                                .background(Circle().fill(Color.white).frame(width: 14, height: 14))
                                                .padding(12)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }
            }
            
            // Footer
            VStack {
                Spacer()
                VStack {
                    Button(action: { showGoals = true }) {
                        Text("Continue")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.tsAccent)
                            .cornerRadius(28)
                            .shadow(color: Color.tsAccent.opacity(0.3), radius: 12, y: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 32)
                .background(
                    LinearGradient(colors: [Color.tsBackground.opacity(0), Color.tsBackground], startPoint: .top, endPoint: .bottom)
                )
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showGoals) {
            OnboardingGoalsView()
        }
    }
}
