//  KitView.swift

import SwiftUI

struct KitTool: Identifiable {
    let id = UUID()
    let icon: String
    let name: String
    let description: String
    let color: Color
    let destination: KitDestination
}

enum KitDestination {
    case work
    case currency
    case sim
    case neighbourhoods
    case bureaucracy
    case scamRadar
    case insurance
    case transportation
}

struct KitView: View {
    @AppStorage("selected_city_id") private var selectedCityId: String = "mx_cdmx"
    var selectedCity: City { CityStore.city(id: selectedCityId) ?? CityStore.defaultCity }

    @State private var activeDestination: KitDestination? = nil
    @State private var showCityPicker = false

    let tools: [KitTool] = [
        KitTool(icon: "laptopcomputer",              name: "Work",        description: "Find spaces with call rooms & fast WiFi", color: Color.tsAccent, destination: .work),
        KitTool(icon: "dollarsign.arrow.circlepath", name: "Currency",      description: "Live rates + quick converter",            color: Color(hex: "#34C759"), destination: .currency),
        KitTool(icon: "simcard",                     name: "SIM Guide",     description: "Best carriers, plans & cost",             color: Color(hex: "#FF9500"), destination: .sim),
        KitTool(icon: "map",                         name: "Neighbourhoods",description: "Find your area by vibe",                  color: Color(hex: "#AF52DE"), destination: .neighbourhoods),
        KitTool(icon: "doc.plaintext",               name: "Bureaucracy",   description: "Banking, visa & healthcare tips",         color: Color(hex: "#5856D6"), destination: .bureaucracy),
        KitTool(icon: "exclamationmark.shield",      name: "Scam Radar",    description: "What to watch out for locally",           color: Color(hex: "#FF3B30"), destination: .scamRadar),
        KitTool(icon: "shield.checkered",             name: "Insurance",     description: "Coverage, providers & Mexico tips",       color: Color(hex: "#34C759"), destination: .insurance),
        KitTool(icon: "tram.fill",                    name: "Transportation",description: "Ride-hailing, transit, cars & more",      color: Color(hex: "#FF6B00"), destination: .transportation),
    ]

    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        ZStack { TSGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center) {
                        Text("Kit")
                            .font(.custom("HelveticaNeue-Bold", size: 28))
                            .foregroundColor(.tsLabel)
                        Spacer()
                        Button(action: { showCityPicker = true }) {
                            HStack(spacing: 6) {
                                Text(selectedCity.emoji)
                                    .font(.custom("HelveticaNeue-Medium", size: 13))
                                Text(selectedCity.name)
                                    .font(.custom("HelveticaNeue-Medium", size: 14))
                                    .foregroundColor(.tsLabel)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.tsAccent)
                            }
                        }
                        .frame(height: 36)
                    }
                    .frame(minHeight: 36)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 16)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(tools) { tool in
                            KitToolCard(tool: tool) { activeDestination = tool.destination }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 96)
                }
            }
        }
        .sheet(isPresented: $showCityPicker) { CityPickerView(selectedId: $selectedCityId) }
        .sheet(isPresented: Binding(
            get: { activeDestination == .work },
            set: { if !$0 { activeDestination = nil } }
        )) { WorkView() }
        .sheet(isPresented: Binding(
            get: { activeDestination == .currency },
            set: { if !$0 { activeDestination = nil } }
        )) { CurrencyView() }
        .sheet(isPresented: Binding(
            get: { activeDestination == .insurance },
            set: { if !$0 { activeDestination = nil } }
        )) { InsuranceView() }
        .sheet(isPresented: Binding(
            get: { activeDestination == .sim },
            set: { if !$0 { activeDestination = nil } }
        )) { SIMGuideView() }
        .sheet(isPresented: Binding(
            get: { activeDestination == .scamRadar },
            set: { if !$0 { activeDestination = nil } }
        )) { ScamRadarView() }
        .sheet(isPresented: Binding(
            get: { activeDestination == .bureaucracy },
            set: { if !$0 { activeDestination = nil } }
        )) { BureaucracyView() }
        .sheet(isPresented: Binding(
            get: { activeDestination == .neighbourhoods },
            set: { if !$0 { activeDestination = nil } }
        )) { NeighbourhoodsView() }
        .sheet(isPresented: Binding(
            get: { activeDestination == .transportation },
            set: { if !$0 { activeDestination = nil } }
        )) { TransportationView() }
        .sheet(isPresented: Binding(
            get: { activeDestination != nil && activeDestination != .work && activeDestination != .currency && activeDestination != .insurance && activeDestination != .sim && activeDestination != .transportation && activeDestination != .neighbourhoods && activeDestination != .bureaucracy && activeDestination != .scamRadar },
            set: { if !$0 { activeDestination = nil } }
        )) {
            if let dest = activeDestination {
                KitPlaceholderView(name: tools.first { $0.destination == dest }?.name ?? "")
            }
        }
    }
}

struct KitToolCard: View {
    let tool: KitTool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(tool.color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: tool.icon)
                        .font(.custom("HelveticaNeue-Medium", size: 22))
                        .foregroundColor(tool.color)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(tool.name)
                        .font(.custom("HelveticaNeue-Bold", size: 16))
                        .foregroundColor(.tsLabel)
                    Text(tool.description)
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(.tsSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(.top, 8).padding(.horizontal, 16).padding(.bottom, 16)
            .frame(maxWidth: .infinity, minHeight: 148, alignment: .leading)
            .background(Color.tsCard)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct KitPlaceholderView: View {
    let name: String
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                VStack(spacing: 12) {
                    Text("⚒️")
                        .font(.custom("HelveticaNeue", size: 48))
                        .padding(.top, 48)
                    Text(name)
                        .font(.custom("HelveticaNeue-Bold", size: 24))
                        .foregroundColor(.tsLabel)
                    Text("Coming soon")
                        .foregroundColor(.tsSecondary)
                    Spacer()
                }
            }
            .navigationTitle(name).navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }}
        }
    }
}
