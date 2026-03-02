import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var auth: AuthManager
    
    @AppStorage("appTheme") private var appTheme: Int = 1 // 0 for Light, 1 for Dark
    @State private var location: String = "Lisbon, Portugal"
    @State private var notificationsEnabled: Bool = true

    var body: some View {
        ZStack(alignment: .top) {
            Color.tsCard.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // Header
                    HStack {
                        Text("Settings")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.tsLabel)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    
                    // Appearance Section
                    SectionHeader(title: "Appearance")
                    VStack(spacing: 0) {
                        HStack {
                            Text("Theme")
                                .font(.system(size: 17))
                                .foregroundColor(.tsLabel)
                            Spacer()
                            
                            // Custom segment control
                            HStack(spacing: 0) {
                                Button(action: { appTheme = 0 }) {
                                    Text("Light")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(appTheme == 0 ? .tsLabel : Color.tsSecondary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 6)
                                        .background(appTheme == 0 ? Color.tsBackground : Color.clear)
                                        .cornerRadius(6)
                                }
                                Button(action: { appTheme = 1 }) {
                                    Text("Dark")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(appTheme == 1 ? .tsLabel : Color.tsSecondary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 6)
                                        .background(appTheme == 1 ? Color.tsBackground : Color.clear)
                                        .cornerRadius(6)
                                }
                            }
                            .padding(2)
                            .background(Color.tsInputBg)
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 48)
                    }
                    .background(Color.tsBackground)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    
                    Text("Choose your preferred interface style for optimal learning.")
                        .font(.system(size: 12))
                        .foregroundColor(Color.tsSecondary)
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                    
                    // Learning Section
                    SectionHeader(title: "Learning")
                    VStack(spacing: 0) {
                        Button(action: {}) {
                            HStack {
                                Text("Language")
                                    .font(.system(size: 17))
                                    .foregroundColor(.tsLabel)
                                Spacer()
                                Text("Portuguese")
                                    .font(.system(size: 17))
                                    .foregroundColor(Color.tsSecondary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.tsSecondary.opacity(0.6))
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 48)
                        }
                        
                        Divider().background(Color.tsBorder).padding(.leading, 16)
                        
                        HStack {
                            Text("Location")
                                .font(.system(size: 17))
                                .foregroundColor(.tsLabel)
                                Spacer()
                            TextField("Location", text: $location)
                                .font(.system(size: 17))
                                .foregroundColor(Color.tsAccent)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 48)
                    }
                    .background(Color.tsBackground)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                    
                    // Account Section
                    SectionHeader(title: "Account")
                    VStack(spacing: 0) {
                        Button(action: {}) {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color(hex: "FFD7BE"))
                                    .frame(width: 32, height: 32)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Profile")
                                        .font(.system(size: 17))
                                        .foregroundColor(.tsLabel)
                                    Text(auth.user?.email ?? "sarah.doe@example.com")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.tsSecondary)
                                }
                                
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.tsSecondary.opacity(0.6))
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 56)
                        }
                        
                        Divider().background(Color.tsBorder).padding(.leading, 16)
                        
                        Button(action: {}) {
                            HStack {
                                Text("Plan")
                                    .font(.system(size: 17))
                                    .foregroundColor(.tsLabel)
                                Spacer()
                                Text("Premium")
                                    .font(.system(size: 17))
                                    .foregroundColor(Color.tsAccent)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.tsSecondary.opacity(0.6))
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 48)
                        }
                        
                        Divider().background(Color.tsBorder).padding(.leading, 16)
                        
                        HStack {
                            Text("Notifications")
                                .font(.system(size: 17))
                                .foregroundColor(.tsLabel)
                            Spacer()
                            Toggle("", isOn: $notificationsEnabled)
                                .labelsHidden()
                                .tint(Color(hex: "34C759"))
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 48)
                    }
                    .background(Color.tsBackground)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                    
                    // Log Out Button
                    Button(action: {
                        auth.signOut()
                    }) {
                        Text("Log Out")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Color(hex: "FF453A"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.tsBackground)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)
                    
                    // Debug
                    VStack(spacing: 0) {
                        Button(action: {
                            UserDefaults.standard.removeObject(forKey: "onboarding_complete")
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundColor(.orange)
                                    .frame(width: 28, height: 28)
                                    .background(Color.orange.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                Text("Reset Onboarding")
                                    .font(.system(size: 17))
                                    .foregroundColor(.tsLabel)
                                Spacer()
                                Text("Debug")
                                    .font(.system(size: 12))
                                    .foregroundColor(.tsSecondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                    .background(Color.tsCard)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)

                    // Version info
                    Text("Version 2.4.1 (Build 890)")
                        .font(.system(size: 12))
                        .foregroundColor(Color.tsSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)
                        .padding(.bottom, 120) // Provide room for bottom tabs
                }
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(Color.tsSecondary)
            .tracking(1.0)
            .padding(.horizontal, 32)
            .padding(.bottom, 8)
    }
}
