import SwiftUI

struct OnboardingPlanView: View {
    @Environment(\.dismiss) var dismiss
    // We bind to a state to force navigate to the Library
    @State private var navigateToLibrary = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.tsLabel)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Choose Your Plan")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.tsLabel)
                    Spacer()
                    Spacer().frame(width: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Master Any Language")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.tsLabel)
                            Text("Select the plan that works best for your learning goals.")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(hex: "A1A1AA"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                        .padding(.top, 24)
                        
                        VStack(spacing: 16) {
                            // Pro Card
                            ZStack(alignment: .topTrailing) {
                                VStack(alignment: .leading, spacing: 20) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "sparkles")
                                                    .foregroundStyle(LinearGradient(colors: [Color.tsAccent, Color(hex: "00F0FF")], startPoint: .leading, endPoint: .trailing))
                                                    .font(.system(size: 20, weight: .bold))
                                                Text("Pro")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.tsLabel)
                                            }
                                            Text("Unlock your full potential")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(Color(hex: "A1A1AA"))
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("$9.99")
                                                .font(.system(size: 30, weight: .bold))
                                                .foregroundColor(.tsLabel)
                                            Text("/ month")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(Color(hex: "A1A1AA"))
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        PlanFeatureRow(text: "Unlimited Daily Phrases")
                                        PlanFeatureRow(text: "Cultural Context Insights")
                                        PlanFeatureRow(text: "AI Accent Coaching")
                                        PlanFeatureRow(text: "Offline Mode Enabled")
                                    }
                                }
                                .padding(24)
                                .background(Color(hex: "121517"))
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(LinearGradient(colors: [Color.tsAccent, Color.clear, Color(hex: "00F0FF")], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                                )
                                
                                // Badge
                                Text("MOST POPULAR")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.tsLabel)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(LinearGradient(colors: [Color.tsAccent, Color(hex: "00F0FF")], startPoint: .leading, endPoint: .trailing))
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color.black, lineWidth: 2))
                                    .offset(x: -24, y: -12)
                            }
                            
                            // Basic Card
                            VStack(alignment: .leading, spacing: 20) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "graduationcap.fill")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 20))
                                            Text("Basic")
                                                .font(.system(size: 24, weight: .bold))
                                                .foregroundColor(.white.opacity(0.9))
                                        }
                                        Text("Getting started")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("Free")
                                            .font(.system(size: 30, weight: .bold))
                                            .foregroundColor(.white.opacity(0.9))
                                        Text("FOREVER")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    PlanFeatureRow(text: "20 Phrases per day", isBasic: true)
                                    PlanFeatureRow(text: "Standard Flashcards", isBasic: true)
                                }
                            }
                            .padding(24)
                            .background(Color.white.opacity(0.03))
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.05), lineWidth: 1))
                            .onTapGesture {
                                // Tapping free goes to library
                                navigateToLibrary = true
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 140)
                }
            }
            
            // Footer
            VStack {
                Spacer()
                VStack(spacing: 16) {
                    Button(action: { navigateToLibrary = true }) {
                        Text("Start 7-Day Free Trial")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.tsLabel)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.tsAccent)
                            .clipShape(Capsule())
                            .shadow(color: Color.tsAccent.opacity(0.3), radius: 20, y: 4)
                    }
                    
                    Text("After 7 days, your Pro subscription begins at $9.99/mo. Cancel anytime in the App Store settings.")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "71717A"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .padding(.top, 24)
                .background(
                    LinearGradient(colors: [Color.black.opacity(0), Color.black], startPoint: .top, endPoint: .bottom)
                )
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToLibrary) {
            MainTabView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

struct PlanFeatureRow: View {
    let text: String
    var isBasic = false
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(isBasic ? AnyShapeStyle(Color.tsAccent) : AnyShapeStyle(LinearGradient(colors: [Color.tsAccent, Color(hex: "00F0FF")], startPoint: .leading, endPoint: .trailing)))
                )
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}
