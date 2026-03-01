import SwiftUI

struct OnboardingGoalsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedGoals: Set<String> = []
    @State private var showPlan = false
    
    let goals = [
        ("airplane", "Travel", Color(hex: "007AFF")),
        ("briefcase.fill", "Work", Color(hex: "A2845E")),
        ("face.smiling.fill", "Casual", Color(hex: "FFCC00")),
        ("heart.fill", "Flirty", Color(hex: "FF3B30")),
        ("building.columns.fill", "Culture", Color(hex: "AF52DE")),
        ("person.2.fill", "Family", Color(hex: "34C759"))
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
                        Rectangle().fill(Color.tsAccent).frame(width: 80, height: 6)
                        Rectangle().fill(Color.tsCard).frame(width: 40, height: 6)
                    }
                    .clipShape(Capsule())
                    
                    Spacer()
                    Spacer().frame(width: 44)
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Why are you learning?")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.tsLabel)
                            Text("Select all that apply. This helps us customize your study cards.")
                                .font(.system(size: 17))
                                .foregroundColor(.tsSecondary)
                        }
                        .padding(.top, 16)
                        
                        // Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(goals, id: \.1) { icon, name, color in
                                let isSelected = selectedGoals.contains(name)
                                Button(action: {
                                    if isSelected { selectedGoals.remove(name) }
                                    else { selectedGoals.insert(name) }
                                }) {
                                    VStack(spacing: 16) {
                                        Circle()
                                            .fill(color.opacity(0.2))
                                            .frame(width: 48, height: 48)
                                            .overlay(
                                                Image(systemName: icon)
                                                    .font(.system(size: 24))
                                                    .foregroundColor(color)
                                            )
                                        
                                        Text(name)
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(.tsLabel)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 148)
                                    .background(Color.tsCard)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(isSelected ? Color.tsAccent : Color.clear, lineWidth: 2)
                                    )
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
                    Button(action: { showPlan = true }) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.tsLabel)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(colors: [Color(hex: "2D8BFF"), Color.tsAccent], startPoint: .top, endPoint: .bottom)
                            )
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
        .navigationDestination(isPresented: $showPlan) {
            OnboardingPlanView()
        }
    }
}
