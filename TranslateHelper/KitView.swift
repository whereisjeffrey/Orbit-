//  KitView.swift

import SwiftUI

struct KitTool: Identifiable {
    let id = UUID()
    let icon: String
    let name: String
    let description: String
    let color: Color
}

struct KitView: View {
    @AppStorage("selected_city_id") private var selectedCityId: String = "mx_cdmx"
    var selectedCity: City { CityStore.city(id: selectedCityId) ?? CityStore.defaultCity }

    @State private var activeTool: KitTool? = nil

    let tools: [KitTool] = [
        KitTool(icon: "dollarsign.arrow.circlepath", name: "Currency Pulse",  description: "Live rates + quick converter",      color: Color(hex: "#34C759")),
        KitTool(icon: "simcard",                     name: "SIM Guide",        description: "Best carriers, plans & cost",        color: Color(hex: "#007AFF")),
        KitTool(icon: "map",                         name: "Neighbourhoods",   description: "Find your area by vibe",             color: Color(hex: "#FF9500")),
        KitTool(icon: "doc.plaintext",               name: "Bureaucracy",      description: "Banking, visa & healthcare tips",    color: Color(hex: "#AF52DE")),
        KitTool(icon: "exclamationmark.shield",      name: "Scam Radar",       description: "What to watch out for locally",      color: Color(hex: "#FF3B30")),
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
                            KitToolCard(tool: tool) { activeTool = tool }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 96)
                }
            }
        }
        .sheet(item: $activeTool) { tool in KitToolDetailView(tool: tool) }
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

struct KitToolDetailView: View {
    let tool: KitTool
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                VStack {
                    Image(systemName: tool.icon)
                        .font(.system(size: 48))
                        .foregroundColor(tool.color)
                        .padding(.top, 48)
                    Text(tool.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.tsLabel)
                        .padding(.top, 16)
                    Text("Coming soon")
                        .foregroundColor(.tsSecondary)
                        .padding(.top, 8)
                    Spacer()
                }
            }
            .navigationTitle(tool.name).navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }}
        }
    }
}
