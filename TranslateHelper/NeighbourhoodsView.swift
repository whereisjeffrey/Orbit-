//  NeighbourhoodsView.swift
//  TalkSwitch

import SwiftUI
import MapKit

// MARK: - Data

struct VibeTag: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let color: Color
}

struct Neighbourhood: Identifiable {
    let id = UUID()
    let number: Int
    let name: String
    let shortName: String
    let color: Color
    let coordinate: CLLocationCoordinate2D
    let tagline: String
    let bestFor: String
    let rentRange: String
    let vibes: [VibeTag]
    let highlights: [String]
    let watchOut: String?
    let sceneNote: String?
}

private let neighbourhoods: [Neighbourhood] = [
    Neighbourhood(
        number: 1, name: "Roma Norte", shortName: "Roma N.",
        color: Color(hex: "#0099FF"),
        coordinate: CLLocationCoordinate2D(latitude: 19.4167, longitude: -99.1606),
        tagline: "The nomad capital of CDMX",
        bestFor: "First-timers, long stays, digital nomads",
        rentRange: "$800–1,400 USD / month",
        vibes: [
            VibeTag(icon: "cup.and.saucer.fill",   label: "Café Culture",   color: Color(hex: "#FF9500")),
            VibeTag(icon: "fork.knife",             label: "Food Scene",     color: Color(hex: "#FF3B30")),
            VibeTag(icon: "paintpalette.fill",      label: "Arts District",  color: Color(hex: "#AF52DE")),
            VibeTag(icon: "figure.walk",            label: "Walkable",       color: Color(hex: "#34C759")),
            VibeTag(icon: "sparkles",               label: "Nightlife",      color: Color(hex: "#FFD60A")),
            VibeTag(icon: "checkmark.shield.fill",  label: "Safe at Night",  color: Color(hex: "#34C759")),
        ],
        highlights: [
            "Highest café and cowork density in the city",
            "Leafy streets with great walking vibes day and night",
            "Mercado Roma — gourmet food hall, great for working lunches",
            "15-min walk to Condesa, Juárez, Doctores Metro",
            "Most expats and nomads land here first — strong community",
        ],
        watchOut: "Priciest neighbourhood for rent. Gets touristy on weekends.",
        sceneNote: nil
    ),
    Neighbourhood(
        number: 2, name: "Condesa", shortName: "Condesa",
        color: Color(hex: "#34C759"),
        coordinate: CLLocationCoordinate2D(latitude: 19.4122, longitude: -99.1736),
        tagline: "Art Deco parks and brunch vibes",
        bestFor: "Couples, longer stays, quieter lifestyle",
        rentRange: "$900–1,600 USD / month",
        vibes: [
            VibeTag(icon: "leaf.fill",              label: "Parks & Green",  color: Color(hex: "#34C759")),
            VibeTag(icon: "fork.knife",             label: "Food Scene",     color: Color(hex: "#FF3B30")),
            VibeTag(icon: "sparkles",               label: "Nightlife",      color: Color(hex: "#FFD60A")),
            VibeTag(icon: "figure.walk",            label: "Walkable",       color: Color(hex: "#34C759")),
            VibeTag(icon: "person.2.fill",          label: "Expat Friendly", color: Color(hex: "#0099FF")),
            VibeTag(icon: "checkmark.shield.fill",  label: "Safe at Night",  color: Color(hex: "#34C759")),
        ],
        highlights: [
            "Parque México and Parque España — incredible green space",
            "Art Deco architecture on every block",
            "Slightly less touristy than Roma Norte",
            "Excellent brunch and café scene",
            "Very walkable, bike-friendly streets",
        ],
        watchOut: "Slightly pricier than Roma Norte. Street parking chaos on weekends.",
        sceneNote: nil
    ),
    Neighbourhood(
        number: 3, name: "Colonia Juárez", shortName: "Juárez",
        color: Color(hex: "#AF52DE"),
        coordinate: CLLocationCoordinate2D(latitude: 19.4271, longitude: -99.1598),
        tagline: "Creative, queer-friendly, up-and-coming",
        bestFor: "Creative types, LGBTQ+ travellers, value seekers",
        rentRange: "$700–1,200 USD / month",
        vibes: [
            VibeTag(icon: "paintpalette.fill",      label: "Arts District",  color: Color(hex: "#AF52DE")),
            VibeTag(icon: "heart.fill",             label: "LGBTQ+ Friendly",color: Color(hex: "#FF2D55")),
            VibeTag(icon: "fork.knife",             label: "Food Scene",     color: Color(hex: "#FF3B30")),
            VibeTag(icon: "sparkles",               label: "Nightlife",      color: Color(hex: "#FFD60A")),
            VibeTag(icon: "cup.and.saucer.fill",    label: "Café Culture",   color: Color(hex: "#FF9500")),
        ],
        highlights: [
            "Zona Rosa — CDMX's LGBTQ+ hub with bars, clubs, restaurants",
            "Gallery scene and independent boutiques",
            "Mercado de Medellín — one of the best food markets in the city",
            "More authentic local feel than Roma or Condesa",
            "Great value now — prices will catch up",
        ],
        watchOut: "Some areas around Zona Rosa can feel sketchy late at night.",
        sceneNote: "This is where CDMX's artists, photographers, and designers are moving. Independent galleries, concept cafés, and underground bars are opening monthly — it has the raw creative energy Roma Norte had five years ago, before the rents followed."
    ),
    Neighbourhood(
        number: 4, name: "Polanco", shortName: "Polanco",
        color: Color(hex: "#FF9500"),
        coordinate: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1963),
        tagline: "CDMX's upscale business district",
        bestFor: "Business travellers, luxury stays, families",
        rentRange: "$1,200–2,500 USD / month",
        vibes: [
            VibeTag(icon: "star.fill",              label: "Upscale",        color: Color(hex: "#FFD60A")),
            VibeTag(icon: "bag.fill",               label: "Shopping",       color: Color(hex: "#FF9500")),
            VibeTag(icon: "briefcase.fill",         label: "Business Hub",   color: Color(hex: "#0099FF")),
            VibeTag(icon: "fork.knife",             label: "Fine Dining",    color: Color(hex: "#FF3B30")),
            VibeTag(icon: "checkmark.shield.fill",  label: "Safe at Night",  color: Color(hex: "#34C759")),
        ],
        highlights: [
            "Presidente Masaryk — Mexico's answer to Fifth Avenue",
            "Highest concentration of top-rated restaurants in CDMX",
            "Closest neighbourhood to Bosque de Chapultepec (city's largest park)",
            "Museo Nacional de Antropología — world-class, right next door",
            "Considered the safest neighbourhood in CDMX",
        ],
        watchOut: "Most expensive in the city. Very corporate — quieter on weekends.",
        sceneNote: nil
    ),
    Neighbourhood(
        number: 5, name: "Coyoacán", shortName: "Coyoacán",
        color: Color(hex: "#FF3B30"),
        coordinate: CLLocationCoordinate2D(latitude: 19.3503, longitude: -99.1617),
        tagline: "Frida Kahlo, markets & colonial charm",
        bestFor: "Culture lovers, longer stays, slower pace",
        rentRange: "$600–1,000 USD / month",
        vibes: [
            VibeTag(icon: "building.columns.fill",  label: "Historic",       color: Color(hex: "#5856D6")),
            VibeTag(icon: "paintpalette.fill",      label: "Arts District",  color: Color(hex: "#AF52DE")),
            VibeTag(icon: "theatermasks.fill",      label: "Culture",        color: Color(hex: "#FF9500")),
            VibeTag(icon: "leaf.fill",              label: "Parks & Green",  color: Color(hex: "#34C759")),
        ],
        highlights: [
            "Casa Azul — Frida Kahlo's iconic blue house and museum",
            "León Trotsky Museum — fascinating Cold War history",
            "Beautiful colonial main square and covered market",
            "Weekly artisan markets on weekends",
            "One of the most atmospheric parts of the city — feels like a different era",
        ],
        watchOut: "40–50 min from Roma Norte. Less connected to the nomad scene.",
        sceneNote: nil
    ),
    Neighbourhood(
        number: 6, name: "Centro Histórico", shortName: "Centro",
        color: Color(hex: "#FF6B00"),
        coordinate: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
        tagline: "The ancient heart of the city",
        bestFor: "Short stays, sightseeing bases, budget travellers",
        rentRange: "$500–900 USD / month",
        vibes: [
            VibeTag(icon: "building.columns.fill",  label: "Historic",       color: Color(hex: "#5856D6")),
            VibeTag(icon: "theatermasks.fill",      label: "Culture",        color: Color(hex: "#FF9500")),
            VibeTag(icon: "dollarsign.circle.fill", label: "Budget Friendly",color: Color(hex: "#34C759")),
        ],
        highlights: [
            "Zócalo — one of the largest city squares in the world",
            "Palacio de Bellas Artes — stunning Art Nouveau architecture",
            "Templo Mayor — Aztec ruins in the middle of the city",
            "Incredible street food — tacos, tlayudas, tamales everywhere",
            "Cheapest rents close to the centre of the city",
        ],
        watchOut: "Chaotic and loud. Less safe at night in some streets. Not ideal for long stays.",
        sceneNote: nil
    ),
    Neighbourhood(
        number: 7, name: "Narvarte", shortName: "Narvarte",
        color: Color(hex: "#FF2D55"),
        coordinate: CLLocationCoordinate2D(latitude: 19.3998, longitude: -99.1583),
        tagline: "Local vibe, great value, up-and-coming",
        bestFor: "Budget-conscious nomads, locals-first experience",
        rentRange: "$500–900 USD / month",
        vibes: [
            VibeTag(icon: "cup.and.saucer.fill",   label: "Café Culture",   color: Color(hex: "#FF9500")),
            VibeTag(icon: "fork.knife",             label: "Food Scene",     color: Color(hex: "#FF3B30")),
            VibeTag(icon: "dollarsign.circle.fill", label: "Budget Friendly",color: Color(hex: "#34C759")),
            VibeTag(icon: "figure.walk",            label: "Walkable",       color: Color(hex: "#34C759")),
            VibeTag(icon: "checkmark.shield.fill",  label: "Safe at Night",  color: Color(hex: "#34C759")),
        ],
        highlights: [
            "15-min walk south of Roma Norte — same quality, lower prices",
            "Growing café and restaurant scene that locals actually use",
            "Parroquia de la Sagrada Familia — neighbourhood anchor",
            "Farmers market on Sundays near Parque Delta",
            "Strong local community — less touristy than Roma",
        ],
        watchOut: nil,
        sceneNote: "Mexican chefs, café owners, and creatives priced out of Roma Norte have been quietly settling here. Less Instagrammed, more real — the new bars and restaurants opening up are the same quality you'd find in Condesa, just without the tourist markup."
    ),
]

// MARK: - Main View

struct NeighbourhoodsView: View {
    @State private var selected: Neighbourhood? = nil
    @State private var mapPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 19.395, longitude: -99.163),
            span: MKCoordinateSpan(latitudeDelta: 0.115, longitudeDelta: 0.115)
        )
    )

    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                ScrollView {
                    VStack(spacing: 0) {

                        // ── Interactive map ───────────────────────────────
                        Map(position: $mapPosition) {
                            ForEach(neighbourhoods) { hood in
                                Annotation("", coordinate: hood.coordinate, anchor: .bottom) {
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                            selected = (selected?.id == hood.id) ? nil : hood
                                        }
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(selected?.id == hood.id ? hood.color : Color.white)
                                                .frame(width: 24, height: 24)
                                                .shadow(color: hood.color.opacity(0.4), radius: selected?.id == hood.id ? 5 : 2)
                                            Text("\(hood.number)")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(selected?.id == hood.id ? .white : hood.color)
                                        }
                                        .overlay(Circle().stroke(hood.color, lineWidth: 1.5))
                                        .scaleEffect(selected?.id == hood.id ? 1.2 : 1.0)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .mapStyle(.standard(elevation: .flat))
                        .frame(height: 280)
                        .cornerRadius(0)

                        // ── Neighbourhood chips ────────────────────────────
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(neighbourhoods) { hood in
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                            selected = (selected?.id == hood.id) ? nil : hood
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(hood.color)
                                                .frame(width: 10, height: 10)
                                            Text("\(hood.number). \(hood.shortName)")
                                                .font(.custom("HelveticaNeue-Medium", size: 13))
                                                .foregroundColor(selected?.id == hood.id ? .white : .tsLabel)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(selected?.id == hood.id ? hood.color : Color.tsCard)
                                        .cornerRadius(20)
                                        .overlay(RoundedRectangle(cornerRadius: 20)
                                            .stroke(selected?.id == hood.id ? hood.color : Color.tsAccent.opacity(0.12), lineWidth: 1))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.vertical, 14)

                        // ── Neighbourhood cards ────────────────────────────
                        VStack(spacing: 12) {
                            ForEach(neighbourhoods) { hood in
                                NeighbourhoodCard(
                                    hood: hood,
                                    isHighlighted: selected?.id == hood.id
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 96)
                    }
                }
            }
            .navigationTitle("Neighbourhoods")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Neighbourhood Card

private struct NeighbourhoodCard: View {
    let hood: Neighbourhood
    let isHighlighted: Bool
    @State private var expanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.easeInOut(duration: 0.22)) { expanded.toggle() }
            } label: {
                HStack(spacing: 12) {
                    // Number badge
                    ZStack {
                        Circle()
                            .fill(isHighlighted ? hood.color : hood.color.opacity(0.15))
                            .frame(width: 25, height: 25)
                        Text("\(hood.number)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(isHighlighted ? .white : hood.color)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(hood.name)
                            .font(.custom("HelveticaNeue-Bold", size: 17))
                            .foregroundColor(.tsLabel)
                        Text(hood.tagline)
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsSecondary)
                    }

                    Spacer()

                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.tsSecondary.opacity(0.5))
                }
                .padding(.top, 8).padding(.horizontal, 16).padding(.bottom, 16)
            }
            .buttonStyle(PlainButtonStyle())

            // Expanded detail
            if expanded {
                VStack(spacing: 0) {
                    Divider().background(Color.tsAccent.opacity(0.08))

                    // Meta row
                    HStack(spacing: 0) {
                        MetaCell(icon: "person.2.fill",          color: Color.tsAccent, label: "Best for",  value: hood.bestFor)
                        Divider().frame(height: 36)
                        MetaCell(icon: "dollarsign.circle.fill", color: Color(hex: "#34C759"), label: "Avg rent", value: hood.rentRange)
                    }
                    .padding(.vertical, 4)

                    Divider().background(Color.tsAccent.opacity(0.08))

                    // Scene note for up-and-coming hoods
                    if let note = hood.sceneNote {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12))
                                .foregroundColor(hood.color)
                                .padding(.top, 1)
                            Text(note)
                                .font(.custom("HelveticaNeue-Medium", size: 13))
                                .foregroundColor(.tsLabel.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(3)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(hood.color.opacity(0.07))

                        Divider().background(Color.tsAccent.opacity(0.08))
                    }

                    // Highlights
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Highlights")
                            .font(.custom("HelveticaNeue-Bold", size: 13))
                            .foregroundColor(.tsSecondary)
                            .padding(.bottom, 2)
                        ForEach(hood.highlights, id: \.self) { h in
                            HStack(alignment: .top, spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(hood.color.opacity(0.15))
                                        .frame(width: 20, height: 20)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(hood.color)
                                }
                                .padding(.top, 1)
                                Text(h)
                                    .font(.custom("HelveticaNeue", size: 14))
                                    .foregroundColor(.tsLabel)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(16)

                    // Watch out — notes-style box
                    if let warn = hood.watchOut {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "#FF9500"))
                                Text("HEADS UP")
                                    .font(.custom("HelveticaNeue-Bold", size: 11))
                                    .foregroundColor(Color(hex: "#FF9500"))
                                    .tracking(1.5)
                            }
                            Text(warn)
                                .font(.custom("HelveticaNeue", size: 13))
                                .foregroundColor(.tsLabel.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(3)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#FF9500").opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#FF9500").opacity(0.22), lineWidth: 1)
                        )
                        .padding(.horizontal, 14)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .background(isHighlighted ? hood.color.opacity(0.07) : Color.tsCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isHighlighted ? hood.color : Color.tsAccent.opacity(0.08),
                        lineWidth: isHighlighted ? 1.5 : 0.5)
        )
        .shadow(color: isHighlighted ? hood.color.opacity(0.15) : .clear, radius: 8, y: 3)
        .onChange(of: isHighlighted) { _, highlighted in
            if highlighted { withAnimation(.easeInOut(duration: 0.22)) { expanded = true } }
        }
    }
}

// MARK: - Meta Cell

private struct MetaCell: View {
    let icon: String; let color: Color; let label: String; let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 10)).foregroundColor(color)
                Text(label.uppercased())
                    .font(.custom("HelveticaNeue-Bold", size: 10))
                    .foregroundColor(.tsSecondary)
                    .tracking(0.5)
            }
            Text(value)
                .font(.custom("HelveticaNeue-Medium", size: 13))
                .foregroundColor(.tsLabel)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
