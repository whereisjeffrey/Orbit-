import SwiftUI
import FirebaseAuth
import MapKit

struct SettingsView: View {
    @EnvironmentObject var auth: AuthManager
    @StateObject private var locStore = UserLocationsStore.shared
    @State private var showLocationSheet = false
    
    @AppStorage("appTheme") private var appTheme: Int = 1 // 0 for Light, 1 for Dark
    @State private var notificationsEnabled: Bool = true

    var body: some View {
        ZStack(alignment: .top) {
            Color.tsBackground.ignoresSafeArea()
            
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
                    .background(Color.tsCard)
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
                                Text("Spanish")
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
                        
                        Button(action: { showLocationSheet = true }) {
                            HStack {
                                Text("Learning Locations")
                                    .font(.system(size: 17))
                                    .foregroundColor(.tsLabel)
                                Spacer()
                                if locStore.locations.isEmpty {
                                    Text("None set")
                                        .font(.system(size: 17))
                                        .foregroundColor(.tsSecondary)
                                } else if locStore.locations.count == 1 {
                                    Text(locStore.locations[0].city)
                                        .font(.system(size: 17))
                                        .foregroundColor(.tsSecondary)
                                        .lineLimit(1)
                                } else {
                                    HStack(spacing: 4) {
                                        Text(locStore.locations[0].city)
                                            .font(.system(size: 17))
                                            .foregroundColor(.tsSecondary)
                                            .lineLimit(1)
                                        Text("+\(locStore.locations.count - 1)")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.tsAccent)
                                            .clipShape(Capsule())
                                    }
                                }
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.tsSecondary.opacity(0.6))
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 48)
                        }
                        .sheet(isPresented: $showLocationSheet) {
                            LocationSettingsSheet()
                        }
                    }
                    .background(Color.tsCard)
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
                    .background(Color.tsCard)
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
                            .background(Color.tsCard)
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



// MARK: - Location Settings Sheet

struct LocationSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locStore = UserLocationsStore.shared
    @StateObject private var searchVM = LocationSearchViewModel()
    @FocusState private var isFocused: Bool

    private let maxLocations = 4

    var body: some View {
        NavigationView {
            ZStack {
                Color.tsBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // Section: current locations
                        if !locStore.locations.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("YOUR LOCATIONS")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.tsSecondary)
                                    .tracking(1.0)

                                ForEach(Array(locStore.locations.enumerated()), id: \.element.id) { index, loc in
                                    HStack(spacing: 12) {
                                        Image(systemName: "line.3.horizontal")
                                            .font(.system(size: 14))
                                            .foregroundColor(.tsSecondary)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(loc.displayName)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.tsLabel)
                                            if index == 0 {
                                                Text("Primary — highest slang weight")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.tsAccent)
                                            }
                                        }

                                        Spacer()

                                        Button(action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                if let i = locStore.locations.firstIndex(where: { $0.id == loc.id }) {
                                                    locStore.locations.remove(at: i)
                                                    locStore.persist()
                                                }
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(Color.tsSecondary.opacity(0.6))
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(index == 0 ? Color.tsAccent.opacity(0.08) : Color.tsInputBg)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(index == 0 ? Color.tsAccent.opacity(0.3) : Color.tsBorder, lineWidth: index == 0 ? 1 : 0.5)
                                    )
                                }

                                // Order tip
                                if locStore.locations.count > 1 {
                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: "info.circle.fill")
                                            .font(.system(size: 15))
                                            .foregroundColor(.tsAccent)
                                            .padding(.top, 1)
                                        Text("Drag to reorder — your first location gets the most slang weight. Put where you spend the most time at the top.")
                                            .font(.system(size: 13))
                                            .foregroundColor(.tsSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .padding(12)
                                    .background(Color.tsAccent.opacity(0.06))
                                    .cornerRadius(10)
                                }
                            }
                        }

                        // Section: Add a location
                        if locStore.locations.count < maxLocations {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ADD LOCATION")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.tsSecondary)
                                    .tracking(1.0)

                                HStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 15))
                                        .foregroundColor(.tsSecondary)
                                    TextField("Search a city or region…", text: $searchVM.searchQuery)
                                        .font(.system(size: 16))
                                        .foregroundColor(.tsLabel)
                                        .focused($isFocused)
                                    if !searchVM.searchQuery.isEmpty {
                                        Button(action: {
                                            searchVM.searchQuery = ""
                                            searchVM.completions = []
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.tsSecondary)
                                        }
                                    }
                                }
                                .padding(14)
                                .background(Color.tsInputBg)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(isFocused ? Color.tsAccent : Color.tsBorder, lineWidth: isFocused ? 1.5 : 0.5))
                                .animation(.easeInOut(duration: 0.15), value: isFocused)

                                if !searchVM.completions.isEmpty {
                                    VStack(alignment: .leading, spacing: 0) {
                                        ForEach(searchVM.completions.prefix(5), id: \.self) { completion in
                                            Button(action: {
                                                let fullLocation = [completion.title, completion.subtitle]
                                                    .filter { !$0.isEmpty }.joined(separator: ", ")
                                                let newLoc = UserLearningLocation(
                                                    displayName: fullLocation,
                                                    city: completion.title,
                                                    country: completion.subtitle
                                                )
                                                withAnimation { locStore.add(newLoc) }
                                                searchVM.searchQuery = ""
                                                searchVM.completions = []
                                                isFocused = false
                                            }) {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(completion.title)
                                                        .font(.system(size: 15, weight: .medium))
                                                        .foregroundColor(.tsLabel)
                                                    if !completion.subtitle.isEmpty {
                                                        Text(completion.subtitle)
                                                            .font(.system(size: 13))
                                                            .foregroundColor(.tsSecondary)
                                                    }
                                                }
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            if completion != searchVM.completions.prefix(5).last {
                                                Divider().background(Color.tsBorder).padding(.horizontal, 16)
                                            }
                                        }
                                    }
                                    .background(Color.tsInputBg)
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tsBorder, lineWidth: 0.5))
                                }
                            }
                        }

                        if locStore.locations.count >= maxLocations {
                            Text("You've reached the maximum of \(maxLocations) locations. Remove one to add another.")
                                .font(.system(size: 14))
                                .foregroundColor(.tsSecondary)
                                .padding(.top, 4)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Learning Locations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.tsAccent)
                }
            }
        }
        .onTapGesture { isFocused = false }
    }
}

