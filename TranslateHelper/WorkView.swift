//  WorkView.swift — replaces KitView's CoworkView sheet
//  Tab: Coworking | Cafés

import SwiftUI
import CoreLocation

enum WorkTab: String, CaseIterable {
    case coworking = "Coworking"
    case cafes     = "Cafés"
}

struct WorkView: View {
    @StateObject private var locationMgr = CoworkLocationManager()
    @AppStorage("selected_city_id")      private var cityId        = "mx_cdmx"
    @AppStorage("cowork_location_asked") private var locationAsked = false

    @State private var activeTab: WorkTab = .coworking

    // Cowork filters
    @State private var filterCallRoom = false
    @State private var filterCoffee   = false
    @State private var filterFastWifi = false
    @State private var filterLate     = false

    // Café filters
    @State private var filterQuiet    = false
    @State private var filterOutlets  = false
    @State private var filterCafeWifi = false
    @State private var filterNoLimit  = false

    @State private var selectedHood:   String       = "All"
    @State private var selectedSpace:  CoworkSpace? = nil
    @State private var selectedCafe:   CafeSpace?   = nil
    @State private var showSubmit:     Bool          = false

    // MARK: - Cowork list
    var filteredSpaces: [CoworkSpace] {
        var list = cdmxCoworkSpaces.filter { $0.cityId == cityId }
        if selectedHood != "All" { list = list.filter { $0.neighbourhood == selectedHood } }
        if filterCallRoom { list = list.filter { $0.hasCallRooms } }
        if filterCoffee   { list = list.filter { $0.hasCoffee } }
        if filterFastWifi { list = list.filter { $0.hasFastWifi } }
        if filterLate     { list = list.filter { $0.hasLateHours } }
        if let loc = locationMgr.userLocation {
            list = list.sorted { ($0.distance(from: loc) ?? 999999) < ($1.distance(from: loc) ?? 999999) }
        }
        return list
    }

    // MARK: - Café list
    var filteredCafes: [CafeSpace] {
        var list = cdmxCafeSpaces.filter { $0.cityId == cityId }
        if selectedHood != "All" { list = list.filter { $0.neighbourhood == selectedHood } }
        if filterQuiet   { list = list.filter { $0.noiseLevel == .quiet } }
        if filterOutlets { list = list.filter { $0.outlets != .none } }
        if filterCafeWifi { list = list.filter { $0.hasFastWifi } }
        if filterNoLimit { list = list.filter { $0.hasNoTimeLimit } }
        if let loc = locationMgr.userLocation {
            list = list.sorted { ($0.distance(from: loc) ?? 999999) < ($1.distance(from: loc) ?? 999999) }
        }
        return list
    }

    var hasLocation: Bool {
        locationMgr.authStatus == .authorizedWhenInUse ||
        locationMgr.authStatus == .authorizedAlways
    }

    var body: some View {
        ZStack { TSGradientBackground()
            VStack(spacing: 0) {

                // ── Header ─────────────────────────────────────────
                HStack(alignment: .center) {
                    Text("Work")
                        .font(.custom("HelveticaNeue-Bold", size: 28))
                        .foregroundColor(.tsLabel)
                    Spacer()
                    Menu {
                        ForEach(["All", "Condesa", "Roma Norte", "Polanco", "Juárez", "Coyoacán", "Centro", "Narvarte", "Del Valle"], id: \.self) { hood in
                            Button(hood) { selectedHood = hood }
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Text(selectedHood == "All" ? "All areas" : selectedHood)
                                .font(.custom("HelveticaNeue-Medium", size: 13))
                                .foregroundColor(.tsAccent)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.tsAccent)
                        }
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Color.tsAccent.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    if hasLocation {
                        HStack(spacing: 4) {
                            Circle().fill(Color(hex: "#34C759")).frame(width: 7, height: 7)
                            Text("Nearby").font(.custom("HelveticaNeue", size: 12)).foregroundColor(.tsSecondary)
                        }
                        .padding(.top, 6)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 32)
                .padding(.bottom, 12)

                // ── Segmented control (matches Settings theme slider) ────
                HStack(spacing: 2) {
                    ForEach(WorkTab.allCases, id: \.self) { tab in
                        Button(action: { withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) { activeTab = tab } }) {
                            Text(tab.rawValue)
                                .font(.custom("HelveticaNeue-Medium", size: 14))
                                .foregroundColor(activeTab == tab ? .tsAccent : .tsSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(activeTab == tab ? Color(UIColor.systemBackground) : Color.clear)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(3)
                .background(Color.tsInputBg)
                .cornerRadius(11)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

                // ── One-time location card ──────────────────────────
                if !locationAsked && !hasLocation {
                    CoworkLocationCard {
                        locationAsked = true
                        locationMgr.requestLocation()
                    } onDismiss: {
                        locationAsked = true
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }

                // ── Community tip nudge card ─────────────────────────
                if let nudge = WorkTipStore.shared.pendingNudge {
                    WorkTipNudgeCard(intent: nudge)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                        .onAppear { WorkTipStore.shared.checkNudge() }
                }

                // ── Tab content ─────────────────────────────────────
                if activeTab == .coworking {
                    CoworkingTabContent(
                        spaces: filteredSpaces,
                        userLocation: locationMgr.userLocation,
                        filterCallRoom: $filterCallRoom,
                        filterCoffee:   $filterCoffee,
                        filterFastWifi: $filterFastWifi,
                        filterLate:     $filterLate,
                        onSelect: { selectedSpace = $0 },
                        onSubmit: { showSubmit = true }
                    )
                } else {
                    CafeTabContent(
                        cafes: filteredCafes,
                        userLocation: locationMgr.userLocation,
                        filterQuiet:   $filterQuiet,
                        filterOutlets: $filterOutlets,
                        filterFastWifi: $filterCafeWifi,
                        filterNoLimit: $filterNoLimit,
                        onSelect: { selectedCafe = $0 },
                        onSubmit: { showSubmit = true }
                    )
                }
            }
        }
        .onAppear { if hasLocation { locationMgr.requestLocation() }; WorkTipStore.shared.checkNudge() }
        .sheet(item: $selectedSpace) { CoworkDetailView(space: $0, userLocation: locationMgr.userLocation) }
        .sheet(item: $selectedCafe)  { CafeDetailView(cafe: $0, userLocation: locationMgr.userLocation) }
        .sheet(isPresented: $showSubmit) {
            CoworkSubmitView(type: .newSpace)
        }
    }
}

// MARK: - Coworking tab
struct CoworkingTabContent: View {
    let spaces: [CoworkSpace]
    let userLocation: CLLocation?
    @Binding var filterCallRoom: Bool
    @Binding var filterCoffee:   Bool
    @Binding var filterFastWifi: Bool
    @Binding var filterLate:     Bool
    let onSelect: (CoworkSpace) -> Void
    let onSubmit: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CoworkFilterChip(icon: "phone.fill",          label: "Call rooms", active: $filterCallRoom)
                        CoworkFilterChip(icon: "cup.and.saucer.fill", label: "Coffee",     active: $filterCoffee)
                        CoworkFilterChip(icon: "bolt.fill",           label: "Fast WiFi",  active: $filterFastWifi)
                        CoworkFilterChip(icon: "moon.fill",           label: "Late hours", active: $filterLate)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 12)

                LazyVStack(spacing: 12) {
                    ForEach(spaces) { space in
                        CoworkCard(space: space, userLocation: userLocation) { onSelect(space) }
                    }
                }
                .padding(.horizontal, 16)

                WorkFooterNote(onSubmit: onSubmit)
            }
        }
    }
}

// MARK: - Cafés tab
struct CafeTabContent: View {
    let cafes: [CafeSpace]
    let userLocation: CLLocation?
    @Binding var filterQuiet:    Bool
    @Binding var filterOutlets:  Bool
    @Binding var filterFastWifi: Bool
    @Binding var filterNoLimit:  Bool
    let onSelect: (CafeSpace) -> Void
    let onSubmit: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CoworkFilterChip(icon: "speaker.slash.fill", label: "Quiet",          active: $filterQuiet)
                        CoworkFilterChip(icon: "bolt.fill",          label: "Power outlets",  active: $filterOutlets)
                        CoworkFilterChip(icon: "wifi",               label: "Fast WiFi",      active: $filterFastWifi)
                        CoworkFilterChip(icon: "timer",              label: "No time limit",  active: $filterNoLimit)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 12)

                if cafes.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "cup.and.saucer").font(.custom("HelveticaNeue", size: 36)).foregroundColor(.tsSecondary)
                        Text("No cafés match those filters").font(.custom("HelveticaNeue", size: 15)).foregroundColor(.tsSecondary)
                    }
                    .frame(maxWidth: .infinity).padding(.top, 48)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(cafes) { cafe in
                            CafeCard(cafe: cafe, userLocation: userLocation) { onSelect(cafe) }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                WorkFooterNote(onSubmit: onSubmit)
            }
        }
    }
}

// MARK: - Café card
struct CafeCard: View {
    @Environment(\.colorScheme) var colorScheme
    let cafe: CafeSpace
    let userLocation: CLLocation?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                PlacePhotoCarousel(placeId: cafe.id, seedPhotos: cafe.photoURLs)
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(cafe.name)
                                .font(.custom("HelveticaNeue-Bold", size: 16))
                                .foregroundColor(.tsLabel)
                            Text(cafe.neighbourhood)
                                .font(.custom("HelveticaNeue", size: 13))
                                .foregroundColor(.tsSecondary)
                        }
                        Spacer()
                        if let dist = cafe.distanceLabel(from: userLocation) {
                            HStack(spacing: 3) {
                                Image(systemName: "location.fill").font(.custom("HelveticaNeue", size: 10)).foregroundColor(.tsAccent)
                                Text(dist).font(.custom("HelveticaNeue-Medium", size: 13)).foregroundColor(.tsAccent)
                            }
                        }
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "clock").font(.custom("HelveticaNeue", size: 11)).foregroundColor(.tsSecondary)
                        Text("\(cafe.hoursDisplay) · \(cafe.hoursDays)")
                            .font(.custom("HelveticaNeue", size: 12)).foregroundColor(.tsSecondary)
                    }
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: cafe.noiseLevel.icon).font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(Color(hex: cafe.noiseLevel.color))
                            Text(cafe.noiseLevel.rawValue).font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(.tsSecondary)
                        }
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill").font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(cafe.outlets != .none ? Color(hex: "#FF9500") : Color.tsSecondary.opacity(0.4))
                            Text(cafe.outlets.rawValue).font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(.tsSecondary)
                        }
                        HStack(spacing: 4) {
                            Image(systemName: "wifi").font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(cafe.hasFastWifi ? Color.tsAccent : Color.tsSecondary.opacity(0.4))
                            Text(cafe.wifiSpeed ?? (cafe.hasFastWifi ? "Fast" : "Slow")).font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(.tsSecondary)
                        }
                        Spacer()
                        Text(cafe.timeLimitLabel)
                            .font(.custom("HelveticaNeue-Medium", size: 11))
                            .foregroundColor(cafe.hasNoTimeLimit ? Color(hex: "#34C759") : Color(hex: "#FF9500"))
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background((cafe.hasNoTimeLimit ? Color(hex: "#34C759") : Color(hex: "#FF9500")).opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
                .padding(16)
            }
            .background(colorScheme == .dark ? Color.tsCard : Color(UIColor.systemGray6).opacity(0.65))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Café detail view
struct CafeDetailView: View {
    let cafe: CafeSpace
    let userLocation: CLLocation?
    @Environment(\.dismiss) var dismiss
    @State private var showEdit = false

    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(cafe.name)
                                .font(.custom("HelveticaNeue-Bold", size: 26)).foregroundColor(.tsLabel)
                            Text(cafe.neighbourhood + " · Mexico City")
                                .font(.custom("HelveticaNeue", size: 14)).foregroundColor(.tsSecondary)
                            if let dist = cafe.distanceLabel(from: userLocation) {
                                HStack(spacing: 4) {
                                    Image(systemName: "location.fill").font(.custom("HelveticaNeue", size: 12))
                                    Text(dist + " from you").font(.custom("HelveticaNeue-Medium", size: 13))
                                }
                                .foregroundColor(.tsAccent)
                            }
                        }
                        .padding(20)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            DetailAmenityCard(
                                icon: cafe.noiseLevel.icon,
                                label: "Noise level",
                                value: cafe.noiseLevel.rawValue,
                                active: cafe.noiseLevel == .quiet,
                                color: Color(hex: cafe.noiseLevel.color)
                            )
                            DetailAmenityCard(
                                icon: "bolt.fill",
                                label: "Power outlets",
                                value: cafe.outlets.rawValue,
                                active: cafe.outlets != .none,
                                color: Color(hex: "#FF9500")
                            )
                            DetailAmenityCard(
                                icon: "wifi",
                                label: "WiFi",
                                value: cafe.wifiSpeed ?? (cafe.hasFastWifi ? "Fast" : "Standard"),
                                active: cafe.hasFastWifi,
                                color: Color.tsAccent
                            )
                            DetailAmenityCard(
                                icon: "timer",
                                label: "Time limit",
                                value: cafe.timeLimitLabel,
                                active: cafe.hasNoTimeLimit,
                                color: Color(hex: "#34C759")
                            )
                        }
                        .padding(.horizontal, 16).padding(.bottom, 20)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hours").font(.custom("HelveticaNeue-Bold", size: 17)).foregroundColor(.tsLabel)
                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill").foregroundColor(.tsSecondary)
                                Text(cafe.hoursDisplay).foregroundColor(.tsLabel)
                                Text("·").foregroundColor(.tsSecondary)
                                Text(cafe.hoursDays).foregroundColor(.tsSecondary)
                            }
                            .font(.custom("HelveticaNeue", size: 15))
                        }
                        .padding(.horizontal, 16).padding(.bottom, 20)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Address").font(.custom("HelveticaNeue-Bold", size: 17)).foregroundColor(.tsLabel)
                            Text(cafe.address).font(.custom("HelveticaNeue", size: 15)).foregroundColor(.tsSecondary)
                        }
                        .padding(.horizontal, 16).padding(.bottom, 20)

                        if let notes = cafe.notes {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("The lowdown").font(.custom("HelveticaNeue-Bold", size: 17)).foregroundColor(.tsLabel)
                                Text(notes).font(.custom("HelveticaNeue", size: 15)).foregroundColor(.tsSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.horizontal, 16).padding(.bottom, 28)
                        }

                        // Community tips
                        CommunityTipsSection(placeId: cafe.id)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)

                        VStack(spacing: 12) {
                            Button(action: { openMaps() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "map.fill")
                                    Text("Get Directions").fontWeight(.bold)
                                }
                                .foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 52)
                                .background(Color.tsAccent)
                                .cornerRadius(14)
                            }
                            if let site = cafe.website {
                                Button(action: { openWebsite(site) }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "safari")
                                        Text(site)
                                    }
                                    .font(.custom("HelveticaNeue", size: 14)).foregroundColor(.tsAccent)
                                }
                            }
                            Button(action: { showEdit = true }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "pencil")
                                    Text("Suggest an edit")
                                }
                                .font(.custom("HelveticaNeue", size: 13)).foregroundColor(.tsSecondary)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, 16).padding(.bottom, 48)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
            .sheet(isPresented: $showEdit) { CoworkSubmitView(type: .newSpace) }
        }
    }

    private func openMaps() {
        WorkTipStore.shared.recordDirectionsTapped(
            placeId: cafe.id, placeType: .cafe, placeName: cafe.name)
        let q = cafe.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?q=\(q)") { UIApplication.shared.open(url) }
    }
    private func openWebsite(_ site: String) {
        let s = site.hasPrefix("http") ? site : "https://\(site)"
        if let url = URL(string: s) { UIApplication.shared.open(url) }
    }
}

// MARK: - Shared footer
struct WorkFooterNote: View {
    let onSubmit: () -> Void
    var body: some View {
        VStack(spacing: 4) {
            Text("Data is community-verified. Hours and amenities change.")
                .font(.custom("HelveticaNeue", size: 12)).foregroundColor(.tsSecondary).multilineTextAlignment(.center)
            Button(action: onSubmit) {
                HStack(spacing: 5) {
                    Image(systemName: "plus.circle")
                    Text("Add a place or fix outdated info")
                }
                .font(.custom("HelveticaNeue-Medium", size: 14)).foregroundColor(.tsAccent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.bottom, 32)
    }
}
