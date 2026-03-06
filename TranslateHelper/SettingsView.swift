import SwiftUI
import FirebaseAuth
import MapKit

@ViewBuilder
private func initialsCircle(auth: AuthManager) -> some View {
    let initials = String(auth.displayName.prefix(2)).uppercased()
    ZStack {
        Circle()
            .fill(LinearGradient(
                stops: [.init(color: Color(hex: "#69B6C1").opacity(0.10), location: 0.3),
                        .init(color: Color(hex: "#0079C6").opacity(0.10), location: 1.0)],
                startPoint: .top, endPoint: .bottom))
            .frame(width: 64, height: 64)
        Text(initials)
            .font(.custom("HelveticaNeue-Bold", size: 22))
            .foregroundColor(.tsLabel)
    }
}

struct SettingsView: View {
    @EnvironmentObject var auth: AuthManager
    @StateObject private var locStore = UserLocationsStore.shared
    @State private var showLocationSheet = false
    
    @AppStorage("appTheme") private var appTheme: Int = 1 // 0 for Light, 1 for Dark
    @State private var notificationsEnabled: Bool = true
    @AppStorage("instagram_handle") private var instagramHandle = ""
    @AppStorage("linkedin_handle")  private var linkedinHandle  = ""
    @AppStorage("facebook_handle")  private var facebookHandle  = ""

    var body: some View {
        ZStack(alignment: .top) {
            Color.tsBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // ── Page title ─────────────────────────────────
                    Text("Settings")
                        .font(.custom("HelveticaNeue-Bold", size: 30))
                        .foregroundColor(.tsLabel)
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        .padding(.bottom, 24)
                    
                    // Appearance Section
                    SectionHeader(title: "Appearance")
                    VStack(spacing: 0) {
                        HStack {
                            Text("Theme")
                                .font(.custom("HelveticaNeue", size: 17))
                                .foregroundColor(.tsLabel)
                            Spacer()
                            
                            // Custom segment control
                            HStack(spacing: 0) {
                                Button(action: { appTheme = 0 }) {
                                    Text("Light")
                                        .font(.custom("HelveticaNeue-Medium", size: 13))
                                        .foregroundColor(appTheme == 0 ? .tsLabel : Color.tsSecondary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 6)
                                        .background(appTheme == 0 ? Color.tsBackground : Color.clear)
                                        .cornerRadius(6)
                                }
                                Button(action: { appTheme = 1 }) {
                                    Text("Dark")
                                        .font(.custom("HelveticaNeue-Medium", size: 13))
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
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
                    .padding(.horizontal, 16)
                    
                    Text("Choose your preferred interface style for optimal learning.")
                        .font(.custom("HelveticaNeue", size: 12))
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
                                    .font(.custom("HelveticaNeue", size: 17))
                                    .foregroundColor(.tsLabel)
                                Spacer()
                                Text("Spanish")
                                    .font(.custom("HelveticaNeue", size: 17))
                                    .foregroundColor(Color.tsSecondary)
                                Image(systemName: "chevron.right")
                                    .font(.custom("HelveticaNeue-Medium", size: 14))
                                    .foregroundColor(Color.tsSecondary.opacity(0.6))
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 48)
                        }
                        
                        Divider().background(Color.tsBorder).padding(.leading, 16)
                        
                        Button(action: { showLocationSheet = true }) {
                            HStack {
                                Text("Learning Locations")
                                    .font(.custom("HelveticaNeue", size: 17))
                                    .foregroundColor(.tsLabel)
                                Spacer()
                                if locStore.locations.isEmpty {
                                    Text("None set")
                                        .font(.custom("HelveticaNeue", size: 17))
                                        .foregroundColor(.tsSecondary)
                                } else if locStore.locations.count == 1 {
                                    Text(locStore.locations[0].city)
                                        .font(.custom("HelveticaNeue", size: 17))
                                        .foregroundColor(.tsSecondary)
                                        .lineLimit(1)
                                } else {
                                    HStack(spacing: 4) {
                                        Text(locStore.locations[0].city)
                                            .font(.custom("HelveticaNeue", size: 17))
                                            .foregroundColor(.tsSecondary)
                                            .lineLimit(1)
                                        Text("+\(locStore.locations.count - 1)")
                                            .font(.custom("HelveticaNeue-Medium", size: 13))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.tsAccent)
                                            .clipShape(Capsule())
                                    }
                                }
                                Image(systemName: "chevron.right")
                                    .font(.custom("HelveticaNeue-Medium", size: 14))
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
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
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
                                        .font(.custom("HelveticaNeue", size: 17))
                                        .foregroundColor(.tsLabel)
                                    Text(auth.user?.email ?? "sarah.doe@example.com")
                                        .font(.custom("HelveticaNeue", size: 12))
                                        .foregroundColor(Color.tsSecondary)
                                }
                                
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.custom("HelveticaNeue-Medium", size: 14))
                                    .foregroundColor(Color.tsSecondary.opacity(0.6))
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 56)
                        }
                        
                        Divider().background(Color.tsBorder).padding(.leading, 16)
                        
                        Button(action: {}) {
                            HStack {
                                Text("Plan")
                                    .font(.custom("HelveticaNeue", size: 17))
                                    .foregroundColor(.tsLabel)
                                Spacer()
                                Text("Premium")
                                    .font(.custom("HelveticaNeue", size: 17))
                                    .foregroundColor(Color.tsAccent)
                                Image(systemName: "chevron.right")
                                    .font(.custom("HelveticaNeue-Medium", size: 14))
                                    .foregroundColor(Color.tsSecondary.opacity(0.6))
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 48)
                        }
                        
                        Divider().background(Color.tsBorder).padding(.leading, 16)
                        
                        HStack {
                            Text("Notifications")
                                .font(.custom("HelveticaNeue", size: 17))
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
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                    
                    // Social Section
                    SectionHeader(title: "Social")
                    VStack(spacing: 0) {
                        SocialConnectRow(platform: .instagram, handle: $instagramHandle)
                        Divider().background(Color.tsBorder).padding(.leading, 56)
                        SocialConnectRow(platform: .linkedin,  handle: $linkedinHandle)
                        Divider().background(Color.tsBorder).padding(.leading, 56)
                        SocialConnectRow(platform: .facebook,  handle: $facebookHandle)
                    }
                    .background(Color.tsCard)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)

                    // Log Out Button
                    Button(action: {
                        auth.signOut()
                    }) {
                        Text("Log Out")
                            .font(.custom("HelveticaNeue-Medium", size: 17))
                            .foregroundColor(Color(hex: "FF453A"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.tsCard)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
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
                                    .font(.custom("HelveticaNeue", size: 17))
                                    .foregroundColor(.tsLabel)
                                Spacer()
                                Text("Debug")
                                    .font(.custom("HelveticaNeue", size: 12))
                                    .foregroundColor(.tsSecondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                    .background(Color.tsCard)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)

                    // Version info
                    Text("Version 2.4.1 (Build 890)")
                        .font(.custom("HelveticaNeue", size: 12))
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
                                    .font(.custom("HelveticaNeue-Medium", size: 12))
                                    .foregroundColor(.tsSecondary)
                                    .tracking(1.0)

                                ForEach(Array(locStore.locations.enumerated()), id: \.element.id) { index, loc in
                                    HStack(spacing: 12) {
                                        Image(systemName: "line.3.horizontal")
                                            .font(.custom("HelveticaNeue", size: 14))
                                            .foregroundColor(.tsSecondary)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(loc.displayName)
                                                .font(.custom("HelveticaNeue-Medium", size: 16))
                                                .foregroundColor(.tsLabel)
                                            if index == 0 {
                                                Text("Primary — highest slang weight")
                                                    .font(.custom("HelveticaNeue", size: 12))
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
                                                .font(.custom("HelveticaNeue", size: 20))
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
                                            .font(.custom("HelveticaNeue", size: 15))
                                            .foregroundColor(.tsAccent)
                                            .padding(.top, 1)
                                        Text("Drag to reorder — your first location gets the most slang weight. Put where you spend the most time at the top.")
                                            .font(.custom("HelveticaNeue", size: 13))
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
                                    .font(.custom("HelveticaNeue-Medium", size: 12))
                                    .foregroundColor(.tsSecondary)
                                    .tracking(1.0)

                                HStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.custom("HelveticaNeue", size: 15))
                                        .foregroundColor(.tsSecondary)
                                    TextField("Search a city or region…", text: $searchVM.searchQuery)
                                        .font(.custom("HelveticaNeue", size: 16))
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
                                                        .font(.custom("HelveticaNeue-Medium", size: 15))
                                                        .foregroundColor(.tsLabel)
                                                    if !completion.subtitle.isEmpty {
                                                        Text(completion.subtitle)
                                                            .font(.custom("HelveticaNeue", size: 13))
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
                                .font(.custom("HelveticaNeue", size: 14))
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
                        .font(.custom("HelveticaNeue-Medium", size: 16))
                        .foregroundColor(.tsAccent)
                }
            }
        }
        .onTapGesture { isFocused = false }
    }
}


// MARK: - Social Connect Row

enum SocialPlatform {
    case instagram, linkedin, facebook

    var label: String {
        switch self { case .instagram: return "Instagram"
                      case .linkedin:  return "LinkedIn"
                      case .facebook:  return "Facebook" }
    }

    var color: Color {
        switch self { case .instagram: return Color(hex: "#E1306C")
                      case .linkedin:  return Color(hex: "#0A66C2")
                      case .facebook:  return Color(hex: "#1877F2") }
    }

    var profileBase: String {
        switch self { case .instagram: return "https://instagram.com/"
                      case .linkedin:  return "https://linkedin.com/in/"
                      case .facebook:  return "https://facebook.com/" }
    }

    @ViewBuilder var badge: some View {
        switch self {
        case .instagram:
            ZStack {
                LinearGradient(colors: [Color(hex: "#F58529"), Color(hex: "#DD2A7B"), Color(hex: "#8134AF")],
                               startPoint: .bottomLeading, endPoint: .topTrailing)
                Image(systemName: "camera.fill")
                    .font(.system(size: 13, weight: .medium)).foregroundColor(.white)
            }
        case .linkedin:
            ZStack {
                Color(hex: "#0A66C2")
                Text("in").font(.custom("HelveticaNeue-Bold", size: 14)).foregroundColor(.white)
            }
        case .facebook:
            ZStack {
                Color(hex: "#1877F2")
                Text("f").font(.custom("HelveticaNeue-Bold", size: 17)).foregroundColor(.white)
            }
        }
    }
}

struct SocialConnectRow: View {
    let platform: SocialPlatform
    @Binding var handle: String
    @State private var showConnectSheet = false
    @State private var showDisconnectAlert = false
    @Environment(\..openURL) private var openURL

    var isConnected: Bool { !handle.isEmpty }

    var body: some View {
        HStack(spacing: 12) {
            platform.badge
                .frame(width: 28, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 7))

            Text(platform.label)
                .font(.custom("HelveticaNeue", size: 17))
                .foregroundColor(.tsLabel)

            Spacer()

            if isConnected {
                // Connected state — show handle + green dot
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "#34C759"))
                        .frame(width: 7, height: 7)
                    Text("@\(handle)")
                        .font(.custom("HelveticaNeue-Medium", size: 14))
                        .foregroundColor(.tsSecondary)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.tsSecondary.opacity(0.4))
            } else {
                // Disconnected state — Connect button
                Text("Connect")
                    .font(.custom("HelveticaNeue-Medium", size: 14))
                    .foregroundColor(.tsAccent)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.tsAccent.opacity(0.10))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .contentShape(Rectangle())
        .onTapGesture {
            if isConnected { showDisconnectAlert = true }
            else           { showConnectSheet    = true }
        }
        // ── Connect sheet ──────────────────────────────────────────────
        .sheet(isPresented: $showConnectSheet) {
            ConnectHandleSheet(platform: platform, handle: $handle)
        }
        // ── Connected options ──────────────────────────────────────────
        .confirmationDialog("@\(handle)", isPresented: $showDisconnectAlert, titleVisibility: .visible) {
            Button("Open Profile") {
                if let url = URL(string: platform.profileBase + handle) { openURL(url) }
            }
            Button("Change Handle") { showConnectSheet = true }
            Button("Disconnect", role: .destructive) { handle = "" }
            Button("Cancel", role: .cancel) {}
        }
    }
}

// ── Sheet where the user enters their handle ──────────────────────────────────
struct ConnectHandleSheet: View {
    let platform: SocialPlatform
    @Binding var handle: String
    @Environment(\..dismiss) var dismiss
    @State private var draft = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Icon
                platform.badge
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(spacing: 8) {
                    Text("Connect \(platform.label)")
                        .font(.custom("HelveticaNeue-Bold", size: 22))
                        .foregroundColor(.tsLabel)
                    Text("Enter your \(platform.label) handle to link your profile to the community.")
                        .font(.custom("HelveticaNeue", size: 14))
                        .foregroundColor(.tsSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                // Handle field
                HStack(spacing: 6) {
                    Text("@")
                        .font(.custom("HelveticaNeue-Bold", size: 17))
                        .foregroundColor(.tsAccent)
                    TextField("yourhandle", text: $draft)
                        .font(.custom("HelveticaNeue", size: 17))
                        .foregroundColor(.tsLabel)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .focused($focused)
                }
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tsAccent.opacity(0.25), lineWidth: 1))
                .padding(.horizontal, 24)

                // Save button
                Button {
                    let cleaned = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                                       .replacingOccurrences(of: "@", with: "")
                    if !cleaned.isEmpty { handle = cleaned }
                    dismiss()
                } label: {
                    Text("Save")
                        .font(.custom("HelveticaNeue-Bold", size: 17))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(draft.trimmingCharacters(in: .whitespaces).isEmpty
                                    ? Color.tsSecondary.opacity(0.35)
                                    : Color.tsAccent)
                        .cornerRadius(14)
                }
                .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding(.top, 40)
            .background(Color.tsBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.custom("HelveticaNeue", size: 17))
                        .foregroundColor(.tsAccent)
                }
            }
            .onAppear {
                draft = handle
                focused = true
            }
        }
    }
}
