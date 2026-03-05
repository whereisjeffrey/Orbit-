import SwiftUI
import Combine
import CoreLocation

// MARK: - Location Manager
class CoworkLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var authStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authStatus = manager.authorizationStatus
    }

    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways: manager.requestLocation()
        default: break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse { manager.requestLocation() }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}

// MARK: - Sort Option
enum CoworkSort: String, CaseIterable {
    case distance = "Distance"
    case price    = "Price"
}

// MARK: - Main View
struct CoworkView: View {
    @StateObject private var locationMgr = CoworkLocationManager()
    @AppStorage("selected_city_id")        private var cityId           = "mx_cdmx"
    @AppStorage("cowork_location_asked")   private var locationAsked    = false

    @State private var sortBy:          CoworkSort = .distance
    @State private var filterCallRoom:  Bool = false
    @State private var filterCoffee:    Bool = false
    @State private var filterFastWifi:  Bool = false
    @State private var filterLate:      Bool = false
    @State private var selected:        CoworkSpace? = nil
    @State private var showSubmit:      Bool = false
    @State private var showLocationCard: Bool = false

    var allSpaces: [CoworkSpace] { cdmxCoworkSpaces.filter { $0.cityId == cityId } }

    var filtered: [CoworkSpace] {
        var list = allSpaces
        if filterCallRoom { list = list.filter { $0.hasCallRooms } }
        if filterCoffee   { list = list.filter { $0.hasCoffee } }
        if filterFastWifi { list = list.filter { $0.hasFastWifi } }
        if filterLate     { list = list.filter { $0.hasLateHours } }
        switch sortBy {
        case .distance:
            if let loc = locationMgr.userLocation {
                list = list.sorted { ($0.distance(from: loc) ?? 999) < ($1.distance(from: loc) ?? 999) }
            }
        case .price:
            list = list.sorted { ($0.dayRate ?? 9999) < ($1.dayRate ?? 9999) }
        }
        return list
    }

    var activeFilterCount: Int {
        [filterCallRoom, filterCoffee, filterFastWifi, filterLate].filter { $0 }.count
    }

    var hasLocation: Bool {
        locationMgr.authStatus == .authorizedWhenInUse ||
        locationMgr.authStatus == .authorizedAlways
    }

    var body: some View {
        ZStack { TSGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Header ─────────────────────────────────────
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cowork")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.tsLabel)
                            Text("Mexico City")
                                .font(.system(size: 13))
                                .foregroundColor(.tsSecondary)
                        }
                        Spacer()
                        if hasLocation {
                            HStack(spacing: 4) {
                                Circle().fill(Color(hex: "#34C759")).frame(width: 7, height: 7)
                                Text("Nearby")
                                    .font(.system(size: 12))
                                    .foregroundColor(.tsSecondary)
                            }
                            .padding(.top, 6)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 16)

                    // ── One-time location prompt card ───────────────
                    if !locationAsked && !hasLocation {
                        CoworkLocationCard {
                            locationAsked = true
                            locationMgr.requestLocation()
                        } onDismiss: {
                            locationAsked = true
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }

                    // ── Sort pills ──────────────────────────────────
                    HStack(spacing: 8) {
                        Text("Sort:")
                            .font(.system(size: 13))
                            .foregroundColor(.tsSecondary)
                        ForEach(CoworkSort.allCases, id: \.self) { option in
                            Button(action: { sortBy = option }) {
                                Text(option.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(sortBy == option ? .white : .tsLabel)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(sortBy == option ? Color.tsAccent : Color.tsCard)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    // ── Filter chips ────────────────────────────────
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

                    // ── Result count ────────────────────────────────
                    HStack {
                        Text(filtered.count == allSpaces.count
                             ? "\(filtered.count) spaces"
                             : "\(filtered.count) of \(allSpaces.count) match")
                            .font(.system(size: 13))
                            .foregroundColor(.tsSecondary)
                        Spacer()
                        if activeFilterCount > 0 {
                            Button(action: clearFilters) {
                                Text("Clear filters")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.tsAccent)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    // ── Space cards ─────────────────────────────────
                    if filtered.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "laptopcomputer.slash")
                                .font(.system(size: 36))
                                .foregroundColor(.tsSecondary)
                            Text("No spaces match your filters")
                                .font(.system(size: 15))
                                .foregroundColor(.tsSecondary)
                            Button(action: clearFilters) {
                                Text("Clear filters")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.tsAccent)
                                    .clipShape(Capsule())
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 48)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filtered) { space in
                                CoworkCard(space: space, userLocation: locationMgr.userLocation) {
                                    selected = space
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // ── Community data note + add button ────────────
                    VStack(spacing: 4) {
                        Text("Data is community-verified. Prices and amenities change.")
                            .font(.system(size: 12))
                            .foregroundColor(.tsSecondary)
                            .multilineTextAlignment(.center)
                        Button(action: { showSubmit = true }) {
                            HStack(spacing: 5) {
                                Image(systemName: "plus.circle")
                                Text("Add a space or fix outdated info")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.tsAccent)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .padding(.bottom, 32)
                }
            }
        }
        .onAppear {
            if hasLocation { locationMgr.requestLocation() }
        }
        .sheet(item: $selected) { space in
            CoworkDetailView(space: space, userLocation: locationMgr.userLocation)
        }
        .sheet(isPresented: $showSubmit) {
            CoworkSubmitView(type: .newSpace)
        }
    }

    private func clearFilters() {
        filterCallRoom = false; filterCoffee = false
        filterFastWifi = false; filterLate   = false
    }
}

// MARK: - One-time location prompt card
struct CoworkLocationCard: View {
    let onEnable: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.tsAccent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("See what\'s actually walkable")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.tsLabel)
                    Text("Sort by real walking distance from where you are now.")
                        .font(.system(size: 13))
                        .foregroundColor(.tsSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Text("We only use your location to calculate distances. It\'s not stored.")
                .font(.system(size: 12))
                .foregroundColor(.tsSecondary)
            HStack(spacing: 10) {
                Button(action: onEnable) {
                    Text("Enable location")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(Color.tsAccent)
                        .clipShape(Capsule())
                }
                Button(action: onDismiss) {
                    Text("Not now")
                        .font(.system(size: 14))
                        .foregroundColor(.tsSecondary)
                }
            }
        }
        .padding(16)
        .background(Color.tsCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16)
            .stroke(Color.tsAccent.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Filter Chip
struct CoworkFilterChip: View {
    let icon: String
    let label: String
    @Binding var active: Bool
    var body: some View {
        Button(action: { active.toggle() }) {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 11, weight: .semibold))
                Text(label).font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(active ? .white : .tsLabel)
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(active ? Color.tsAccent : Color.tsCard)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Space Card
struct CoworkCard: View {
    let space: CoworkSpace
    let userLocation: CLLocation?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(space.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.tsLabel)
                        Text(space.neighbourhood)
                            .font(.system(size: 13))
                            .foregroundColor(.tsSecondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        if let dist = space.distanceLabel(from: userLocation) {
                            HStack(spacing: 3) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.tsAccent)
                                Text(dist)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.tsAccent)
                            }
                        }
                        if let day = space.dayRate {
                            Text("$\(day) MXN/day")
                                .font(.system(size: 12))
                                .foregroundColor(.tsSecondary)
                        }
                    }
                }
                HStack(spacing: 4) {
                    Image(systemName: "clock").font(.system(size: 11)).foregroundColor(.tsSecondary)
                    Text("\(space.hoursDisplay) · \(space.hoursDays)")
                        .font(.system(size: 12)).foregroundColor(.tsSecondary)
                }
                HStack(spacing: 16) {
                    AmenityBadge(icon: "phone.fill",          label: "Call rooms", active: space.hasCallRooms)
                    AmenityBadge(icon: "cup.and.saucer.fill", label: "Coffee",     active: space.hasCoffee)
                    AmenityBadge(icon: "bolt.fill",           label: "Fast WiFi",  active: space.hasFastWifi)
                    AmenityBadge(icon: "moon.fill",           label: "Late",       active: space.hasLateHours)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12)).foregroundColor(.tsSecondary)
                }
            }
            .padding(16)
            .background(Color.tsCard)
            .cornerRadius(16)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Amenity Badge
struct AmenityBadge: View {
    let icon: String; let label: String; let active: Bool
    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon).font(.system(size: 13))
                .foregroundColor(active ? Color(hex: "#34C759") : Color.tsSecondary.opacity(0.4))
            Text(active ? "✓" : "✗").font(.system(size: 10, weight: .bold))
                .foregroundColor(active ? Color(hex: "#34C759") : Color.tsSecondary.opacity(0.4))
        }
    }
}

// MARK: - Detail View
struct CoworkDetailView: View {
    let space: CoworkSpace
    let userLocation: CLLocation?
    @Environment(\.dismiss) var dismiss
    @State private var showEdit = false

    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(space.name)
                                .font(.system(size: 26, weight: .bold)).foregroundColor(.tsLabel)
                            Text(space.neighbourhood + " · Mexico City")
                                .font(.system(size: 14)).foregroundColor(.tsSecondary)
                            if let dist = space.distanceLabel(from: userLocation) {
                                HStack(spacing: 4) {
                                    Image(systemName: "location.fill").font(.system(size: 12))
                                    Text(dist + " from you").font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(.tsAccent)
                            }
                        }
                        .padding(20)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            DetailAmenityCard(icon: "phone.fill",          label: "Call Rooms",  value: space.hasCallRooms ? "Available"    : "None",         active: space.hasCallRooms,  color: Color(hex: "#34C759"))
                            DetailAmenityCard(icon: "cup.and.saucer.fill", label: "Coffee",      value: space.hasCoffee   ? "Included"     : "Not included", active: space.hasCoffee,    color: Color(hex: "#FF9500"))
                            DetailAmenityCard(icon: "bolt.fill",           label: "WiFi Speed",  value: space.wifiSpeed ?? (space.hasFastWifi ? "Fast" : "Standard"), active: space.hasFastWifi, color: Color(hex: "#007AFF"))
                            DetailAmenityCard(icon: "moon.fill",           label: "Late Hours",  value: space.hasLateHours ? "Open past 9pm" : "Closes early", active: space.hasLateHours, color: Color(hex: "#AF52DE"))
                        }
                        .padding(.horizontal, 16).padding(.bottom, 20)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Pricing").font(.system(size: 17, weight: .bold)).foregroundColor(.tsLabel)
                            HStack(spacing: 12) {
                                if let day = space.dayRate   { PricePill(label: "Day",   value: "$\(day) MXN") }
                                if let mo  = space.monthRate { PricePill(label: "Month", value: "$\(mo) MXN") }
                            }
                        }
                        .padding(.horizontal, 16).padding(.bottom, 20)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hours").font(.system(size: 17, weight: .bold)).foregroundColor(.tsLabel)
                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill").foregroundColor(.tsSecondary)
                                Text(space.hoursDisplay).foregroundColor(.tsLabel)
                                Text("·").foregroundColor(.tsSecondary)
                                Text(space.hoursDays).foregroundColor(.tsSecondary)
                            }
                            .font(.system(size: 15))
                        }
                        .padding(.horizontal, 16).padding(.bottom, 20)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Address").font(.system(size: 17, weight: .bold)).foregroundColor(.tsLabel)
                            Text(space.address).font(.system(size: 15)).foregroundColor(.tsSecondary)
                        }
                        .padding(.horizontal, 16).padding(.bottom, 20)

                        if let notes = space.notes {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("The lowdown").font(.system(size: 17, weight: .bold)).foregroundColor(.tsLabel)
                                Text(notes).font(.system(size: 15)).foregroundColor(.tsSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.horizontal, 16).padding(.bottom, 28)
                        }

                        VStack(spacing: 12) {
                            Button(action: { openMaps(space: space) }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "map.fill")
                                    Text("Get Directions").fontWeight(.bold)
                                }
                                .foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 52)
                                .background(LinearGradient(colors: [Color(hex: "#3B99FC"), Color(hex: "#007AFF")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing))
                                .cornerRadius(14)
                            }
                            if let site = space.website {
                                Button(action: { openWebsite(site) }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "safari")
                                        Text(site)
                                    }
                                    .font(.system(size: 14)).foregroundColor(.tsAccent)
                                }
                            }
                            // ── Suggest edit ────────────────────────
                            Button(action: { showEdit = true }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "pencil")
                                    Text("Suggest an edit")
                                }
                                .font(.system(size: 13)).foregroundColor(.tsSecondary)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, 16).padding(.bottom, 48)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
            .sheet(isPresented: $showEdit) { CoworkSubmitView(type: .editExisting(space)) }
        }
    }

    private func openMaps(space: CoworkSpace) {
        let q = space.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?q=\(q)") { UIApplication.shared.open(url) }
    }
    private func openWebsite(_ site: String) {
        let s = site.hasPrefix("http") ? site : "https://\(site)"
        if let url = URL(string: s) { UIApplication.shared.open(url) }
    }
}

// MARK: - Detail sub-components
struct DetailAmenityCard: View {
    let icon: String; let label: String; let value: String; let active: Bool; let color: Color
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(active ? color.opacity(0.15) : Color.tsSecondary.opacity(0.08))
                    .frame(width: 40, height: 40)
                Image(systemName: icon).font(.system(size: 17))
                    .foregroundColor(active ? color : .tsSecondary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 12)).foregroundColor(.tsSecondary)
                Text(value).font(.system(size: 13, weight: .semibold))
                    .foregroundColor(active ? .tsLabel : .tsSecondary)
            }
            Spacer()
        }
        .padding(12).background(Color.tsCard).cornerRadius(14)
    }
}

struct PricePill: View {
    let label: String; let value: String
    var body: some View {
        VStack(spacing: 4) {
            Text(label).font(.system(size: 11)).foregroundColor(.tsSecondary)
            Text(value).font(.system(size: 15, weight: .bold)).foregroundColor(.tsLabel)
        }
        .padding(.horizontal, 20).padding(.vertical, 12)
        .background(Color.tsCard).cornerRadius(12)
    }
}
