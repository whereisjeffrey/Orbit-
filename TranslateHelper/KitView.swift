//  KitView.swift

import SwiftUI

// MARK: - KitTool model

struct KitTool: Identifiable {
    let id = UUID()
    let icon: String
    let name: String
    let description: String
    let color: Color
    let destination: KitDestination
    var isFree: Bool = false
}

enum KitDestination {
    case localsUse, fitness, work, currency
    case sim, neighbourhoods, bureaucracy, scamRadar, insurance, transportation
}

// MARK: - Currency widget model

struct ExchangeRate {
    let rate: Double
    let date: String
    let change: Double?   // nil until we have two samples
}

// MARK: - KitView

struct KitView: View {
    @AppStorage("selected_city_id")   private var selectedCityId = "mx_cdmx"
    @AppStorage("app_install_date")   private var installDateStr = ""
    // Opened-once tracking for graduatable tools
    @AppStorage("kit_seen_sim")       private var seenSim       = false
    @AppStorage("kit_seen_insurance") private var seenInsurance  = false
    @AppStorage("kit_seen_scamradar") private var seenScamRadar  = false
    @AppStorage("kit_seen_bureaucracy")private var seenBureaucracy = false

    var selectedCity: City { CityStore.city(id: selectedCityId) ?? CityStore.defaultCity }

    @State private var activeDestination: KitDestination? = nil
    @State private var showCityPicker = false
    @State private var rate: ExchangeRate? = nil
    @State private var prevRate: Double? = nil

    // Days since install
    private var daysInstalled: Int {
        guard !installDateStr.isEmpty,
              let d = ISO8601DateFormatter().date(from: installDateStr)
        else { return 0 }
        return Calendar.current.dateComponents([.day], from: d, to: Date()).day ?? 0
    }

    private func hasSeen(_ dest: KitDestination) -> Bool {
        switch dest {
        case .sim:        return seenSim
        case .insurance:  return seenInsurance
        case .scamRadar:  return seenScamRadar
        case .bureaucracy:return seenBureaucracy
        default:          return false
        }
    }

    private func markSeen(_ dest: KitDestination) {
        switch dest {
        case .sim:        seenSim        = true
        case .insurance:  seenInsurance  = true
        case .scamRadar:  seenScamRadar  = true
        case .bureaucracy:seenBureaucracy = true
        default: break
        }
    }

    // Graduatable = moves to compact strip after 21 days + seen
    private let graduatableDestinations: Set<KitDestination> = [.sim, .insurance, .scamRadar, .bureaucracy]

    private func shouldGraduate(_ tool: KitTool) -> Bool {
        guard graduatableDestinations.contains(tool.destination) else { return false }
        return daysInstalled >= 21 && hasSeen(tool.destination)
    }

    static let allTools: [KitTool] = [
        KitTool(icon: "laptopcomputer",               name: "Work",           description: "Find spaces with call rooms & fast WiFi",  color: Color.tsAccent,        destination: .work),
        KitTool(icon: "figure.run",                   name: "Fitness",        description: "Gyms, studios, outdoors & class guide",    color: Color(hex: "#34C759"), destination: .fitness),
        KitTool(icon: "person.2.fill",                name: "Locals Use",     description: "Dentists, trainers, cleaners & more",      color: Color(hex: "#FF9500"), destination: .localsUse),
        KitTool(icon: "map",                          name: "Neighbourhoods", description: "Find your area by vibe",                   color: Color(hex: "#AF52DE"), destination: .neighbourhoods, isFree: true),
        KitTool(icon: "tram.fill",                    name: "Transportation", description: "Ride-hailing, transit, cars & more",       color: Color(hex: "#1B3A6B"), destination: .transportation),
        KitTool(icon: "dollarsign.arrow.circlepath",  name: "Currency",       description: "Live rates + quick converter",             color: Color(hex: "#34C759"), destination: .currency),
        KitTool(icon: "exclamationmark.shield",       name: "Scam Radar",     description: "What to watch out for locally",            color: Color(hex: "#FF3B30"), destination: .scamRadar, isFree: true),
        KitTool(icon: "simcard",                      name: "SIM Guide",      description: "Best carriers, plans & cost",              color: Color(hex: "#17C2E1"), destination: .sim),
        KitTool(icon: "shield.checkered",             name: "Insurance",      description: "Coverage, providers & Mexico tips",        color: Color(hex: "#34C759"), destination: .insurance),
        KitTool(icon: "doc.plaintext",                name: "Bureaucracy",    description: "Banking, visa & healthcare tips",          color: Color(hex: "#5856D6"), destination: .bureaucracy),
    ]

    private var primaryTools: [KitTool]   { KitView.allTools.filter { !shouldGraduate($0) } }
    private var graduatedTools: [KitTool] { KitView.allTools.filter {  shouldGraduate($0) } }

    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        ZStack { TSGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Header ────────────────────────────────────────────
                    TSPageHeader(
                        title: "Kit",
                        selectedCity: selectedCity,
                        bottomPadding: 12
                    ) {
                        showCityPicker = true
                    }

                    // ── Currency widget ───────────────────────────────────
                    CurrencyWidget(rate: rate)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)

                    // ── Primary tool grid ─────────────────────────────────
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(primaryTools) { tool in
                            KitToolCard(tool: tool) {
                                markSeen(tool.destination)
                                activeDestination = tool.destination
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    // ── Graduated compact strip ───────────────────────────
                    if !graduatedTools.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Divider()
                                .background(Color.tsBorder)
                                .padding(.top, 20)
                                .padding(.horizontal, 16)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(graduatedTools) { tool in
                                        CompactKitTile(tool: tool) {
                                            markSeen(tool.destination)
                                            activeDestination = tool.destination
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                            }
                        }
                    }

                    Spacer().frame(height: 96)
                }
            }
        }
        .onAppear {
            // Record install date on first launch
            if installDateStr.isEmpty {
                installDateStr = ISO8601DateFormatter().string(from: Date())
            }
            fetchRate()
        }
        .sheet(isPresented: $showCityPicker) { CityPickerView(selectedId: $selectedCityId) }
        .sheet(isPresented: Binding(get: { activeDestination == .localsUse },    set: { if !$0 { activeDestination = nil } })) { LocalsUseView() }
        .sheet(isPresented: Binding(get: { activeDestination == .fitness },      set: { if !$0 { activeDestination = nil } })) { FitnessView() }
        .sheet(isPresented: Binding(get: { activeDestination == .work },         set: { if !$0 { activeDestination = nil } })) { WorkView() }
        .sheet(isPresented: Binding(get: { activeDestination == .currency },     set: { if !$0 { activeDestination = nil } })) { CurrencyView() }
        .sheet(isPresented: Binding(get: { activeDestination == .insurance },    set: { if !$0 { activeDestination = nil } })) { InsuranceView() }
        .sheet(isPresented: Binding(get: { activeDestination == .sim },          set: { if !$0 { activeDestination = nil } })) { SIMGuideView() }
        .sheet(isPresented: Binding(get: { activeDestination == .scamRadar },    set: { if !$0 { activeDestination = nil } })) { ScamRadarView() }
        .sheet(isPresented: Binding(get: { activeDestination == .bureaucracy },  set: { if !$0 { activeDestination = nil } })) { BureaucracyView() }
        .sheet(isPresented: Binding(get: { activeDestination == .neighbourhoods },set: { if !$0 { activeDestination = nil } })) { NeighbourhoodsView() }
        .sheet(isPresented: Binding(get: { activeDestination == .transportation },set: { if !$0 { activeDestination = nil } })) { TransportationView() }
    }

    // MARK: - Live rate fetch
    private func fetchRate() {
        guard let url = URL(string: "https://api.frankfurter.app/latest?from=USD&to=MXN") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let rates = json["rates"] as? [String: Double],
                  let mxn = rates["MXN"],
                  let date = json["date"] as? String else { return }
            DispatchQueue.main.async {
                self.rate = ExchangeRate(rate: mxn, date: date, change: nil)
            }
        }.resume()
    }
}

// MARK: - Currency Widget

struct CurrencyWidget: View {
    let rate: ExchangeRate?

    var body: some View {
        HStack(spacing: 14) {
            // Flag + label
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("🇲🇽")
                        .font(.system(size: 18))
                    Text("Mexican Peso")
                        .font(.custom("HelveticaNeue-Medium", size: 13))
                        .foregroundColor(.tsSecondary)
                }
                if let r = rate {
                    Text("$1 USD = \(String(format: "%.2f", r.rate)) MXN")
                        .font(.custom("HelveticaNeue-Bold", size: 20))
                        .foregroundColor(.tsLabel)
                } else {
                    Text("Fetching rate…")
                        .font(.custom("HelveticaNeue", size: 16))
                        .foregroundColor(.tsSecondary)
                }
            }

            Spacer()

            // Date badge
            if let d = rate?.date {
                Text(d)
                    .font(.custom("HelveticaNeue", size: 11))
                    .foregroundColor(.tsSecondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.tsCard)
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(Color.tsBorder.opacity(0.5), lineWidth: 0.5))
            }
        }
        .padding(14)
        .background(Color.tsCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
    }
}

// MARK: - Compact Kit Tile (graduated tools)

struct CompactKitTile: View {
    let tool: KitTool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: tool.icon)
                    .font(.system(size: 18))
                    .foregroundColor(tool.color)
                    .frame(width: 40, height: 40)
                    .background(tool.color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text(tool.name)
                    .font(.custom("HelveticaNeue-Medium", size: 11))
                    .foregroundColor(.tsSecondary)
                    .lineLimit(1)
            }
            .frame(width: 72)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - KitToolCard

struct KitToolCard: View {
    @AppStorage("is_pro") private var isPro: Bool = false
    let tool: KitTool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    Image(systemName: tool.icon)
                        .font(.system(size: 20))
                        .foregroundColor(tool.color)
                        .frame(width: 44, height: 44)
                        .background(tool.color.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Spacer()
                    if !isPro && !tool.isFree {
                        Text("PRO")
                            .font(.custom("HelveticaNeue-Bold", size: 9))
                            .foregroundColor(Color.tsAccent)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.tsAccent.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
                
                ZStack(alignment: .topLeading) {
                    // Hidden texts to force uniform max height across all cards
                    ForEach(KitView.allTools, id: \.id) { t in
                        VStack(alignment: .leading, spacing: 3) {
                            Text(t.name)
                                .font(.custom("HelveticaNeue-Bold", size: 15))
                                .fixedSize(horizontal: false, vertical: true)
                            Text(t.description)
                                .font(.custom("HelveticaNeue", size: 12))
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .hidden()
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(tool.name)
                            .font(.custom("HelveticaNeue-Bold", size: 15))
                            .foregroundColor(.tsLabel)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(tool.description)
                            .font(.custom("HelveticaNeue", size: 12))
                            .foregroundColor(.tsSecondary)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.tsCard)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
