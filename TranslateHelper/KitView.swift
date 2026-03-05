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
}

struct KitView: View {
    @AppStorage("selected_city_id") private var selectedCityId: String = "mx_cdmx"
    var selectedCity: City { CityStore.city(id: selectedCityId) ?? CityStore.defaultCity }

    @State private var activeDestination: KitDestination? = nil

    let tools: [KitTool] = [
        KitTool(icon: "laptopcomputer",              name: "Work",        description: "Find spaces with call rooms & fast WiFi", color: Color(hex: "#007AFF"), destination: .work),
        KitTool(icon: "dollarsign.arrow.circlepath", name: "Currency",      description: "Live rates + quick converter",            color: Color(hex: "#34C759"), destination: .currency),
        KitTool(icon: "simcard",                     name: "SIM Guide",     description: "Best carriers, plans & cost",             color: Color(hex: "#FF9500"), destination: .sim),
        KitTool(icon: "map",                         name: "Neighbourhoods",description: "Find your area by vibe",                  color: Color(hex: "#AF52DE"), destination: .neighbourhoods),
        KitTool(icon: "doc.plaintext",               name: "Bureaucracy",   description: "Banking, visa & healthcare tips",         color: Color(hex: "#5856D6"), destination: .bureaucracy),
        KitTool(icon: "exclamationmark.shield",      name: "Scam Radar",    description: "What to watch out for locally",           color: Color(hex: "#FF3B30"), destination: .scamRadar),
    ]

    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        ZStack { TSGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Kit")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.tsLabel)
                            Text("\(selectedCity.emoji) \(selectedCity.name)")
                                .font(.system(size: 13))
                                .foregroundColor(.tsSecondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

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
        .sheet(isPresented: Binding(
            get: { activeDestination == .work },
            set: { if !$0 { activeDestination = nil } }
        )) { WorkView() }
        .sheet(isPresented: Binding(
            get: { activeDestination != nil && activeDestination != .work },
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
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(tool.color)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(tool.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.tsLabel)
                    Text(tool.description)
                        .font(.system(size: 12))
                        .foregroundColor(.tsSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 148, alignment: .leading)
            .background(Color.tsCard)
            .cornerRadius(20)
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
                        .font(.system(size: 48))
                        .padding(.top, 48)
                    Text(name)
                        .font(.system(size: 24, weight: .bold))
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
