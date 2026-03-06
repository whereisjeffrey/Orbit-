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

struct SoulCard {
    let icon: String
    let title: String
    let body: String
}

struct RentTiers {
    let studio: String
    let oneBR: String
    let twoBR: String
    let airbnb: String
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
    let rents: RentTiers
    let vibes: [VibeTag]
    let highlights: [String]
    let watchOut: String?
    let soul: SoulCard
}

private let neighbourhoods: [Neighbourhood] = [
    Neighbourhood(
        number: 1, name: "Roma Norte", shortName: "Roma N.",
        color: Color(hex: "#0099FF"),
        coordinate: CLLocationCoordinate2D(latitude: 19.4167, longitude: -99.1606),
        tagline: "The nomad capital of CDMX",
        bestFor: "First-timers, long stays, digital nomads",
        rents: RentTiers(
            studio:  "$800–1,000 USD / mo",
            oneBR:   "$1,000–1,400 USD / mo",
            twoBR:   "$1,400–2,000 USD / mo",
            airbnb:  "$60–120 USD / night"
        ),
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
        soul: SoulCard(
            icon: "laptopcomputer",
            title: "Where Everyone Lands First",
            body: "Roma Norte has an almost unfair advantage — great restaurants on every block, reliable WiFi everywhere, enough other nomads around that you'll have dinner plans by Tuesday. You come for two weeks and leave after two months. It's the neighbourhood with the least friction and the most going on, which makes it both the obvious first choice and, eventually, the thing you graduate from."
        )
    ),
    Neighbourhood(
        number: 2, name: "Condesa", shortName: "Condesa",
        color: Color(hex: "#34C759"),
        coordinate: CLLocationCoordinate2D(latitude: 19.4122, longitude: -99.1736),
        tagline: "Art Deco parks and brunch vibes",
        bestFor: "Couples, longer stays, quieter lifestyle",
        rents: RentTiers(
            studio:  "$900–1,100 USD / mo",
            oneBR:   "$1,100–1,600 USD / mo",
            twoBR:   "$1,600–2,200 USD / mo",
            airbnb:  "$70–130 USD / night"
        ),
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
        soul: SoulCard(
            icon: "leaf.fill",
            title: "CDMX's Living Room",
            body: "Condesa is what happens when a city gets everything right. Two perfect parks, Art Deco buildings on every block, restaurant terraces that spill onto the street on a Sunday morning. It's quieter than Roma, more settled, the kind of place you choose when you actually want to feel like you live somewhere — not just like you're passing through."
        )
    ),
    Neighbourhood(
        number: 3, name: "Colonia Juárez", shortName: "Juárez",
        color: Color(hex: "#AF52DE"),
        coordinate: CLLocationCoordinate2D(latitude: 19.4271, longitude: -99.1598),
        tagline: "Creative, queer-friendly, up-and-coming",
        bestFor: "Creative types, LGBTQ+ travellers, value seekers",
        rents: RentTiers(
            studio:  "$700–900 USD / mo",
            oneBR:   "$900–1,200 USD / mo",
            twoBR:   "$1,200–1,600 USD / mo",
            airbnb:  "$45–90 USD / night"
        ),
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
        soul: SoulCard(
            icon: "paintpalette.fill",
            title: "New Artist District",
            body: "Galleries are opening where dry cleaners used to be. The bar that looks like nothing from the outside has a line around the block by midnight. Juárez is in that specific, electric moment a neighbourhood only gets once — when the artists are in and the prices haven't caught up yet. If you're queer, creative, or just tired of the well-trodden Roma circuit, this is where the city is actually happening right now."
        )
    ),
    Neighbourhood(
        number: 4, name: "Polanco", shortName: "Polanco",
        color: Color(hex: "#FF9500"),
        coordinate: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1963),
        tagline: "CDMX's upscale business district",
        bestFor: "Business travellers, luxury stays, families",
        rents: RentTiers(
            studio:  "$1,200–1,600 USD / mo",
            oneBR:   "$1,600–2,200 USD / mo",
            twoBR:   "$2,200–3,500 USD / mo",
            airbnb:  "$100–200 USD / night"
        ),
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
        soul: SoulCard(
            icon: "star.fill",
            title: "The City's Best Address",
            body: "Polanco is CDMX on its best behaviour — the highest concentration of world-class restaurants in the city, the safest streets, architecture that makes you want to slow down and actually look up. It's where the business meetings happen and where they continue after dinner. The most expensive neighbourhood by some margin, and for the right person, worth every peso."
        )
    ),
    Neighbourhood(
        number: 5, name: "Coyoacán", shortName: "Coyoacán",
        color: Color(hex: "#FF3B30"),
        coordinate: CLLocationCoordinate2D(latitude: 19.3503, longitude: -99.1617),
        tagline: "Frida Kahlo, markets & colonial charm",
        bestFor: "Culture lovers, longer stays, slower pace",
        rents: RentTiers(
            studio:  "$600–800 USD / mo",
            oneBR:   "$800–1,000 USD / mo",
            twoBR:   "$1,000–1,400 USD / mo",
            airbnb:  "$40–80 USD / night"
        ),
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
        soul: SoulCard(
            icon: "building.columns.fill",
            title: "A City Within the City",
            body: "Coyoacán doesn't feel like the rest of CDMX — it feels older, quieter, more itself. Colonial plazas, cobblestone streets, Frida Kahlo's blue house, markets that have been running since before your grandparents were born. If you want to understand Mexico City rather than just visit it, spend some time here. It asks more of you in terms of commute, and gives more back in terms of soul."
        )
    ),
    Neighbourhood(
        number: 6, name: "Centro Histórico", shortName: "Centro",
        color: Color(hex: "#FF6B00"),
        coordinate: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
        tagline: "The ancient heart of the city",
        bestFor: "Short stays, sightseeing bases, budget travellers",
        rents: RentTiers(
            studio:  "$500–700 USD / mo",
            oneBR:   "$700–900 USD / mo",
            twoBR:   "$900–1,200 USD / mo",
            airbnb:  "$30–65 USD / night"
        ),
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
        soul: SoulCard(
            icon: "map.fill",
            title: "5,000 Years on Your Doorstep",
            body: "Underneath Centro's streets are actual Aztec ruins. A few blocks away is the biggest cathedral in the Americas. Around the corner is some of the best street food you'll eat in your life. It is loud, chaotic, overwhelming, and completely irreplaceable — there is nowhere else on earth quite like it. Stay here to be in the thick of it. Leave it for a quiet dinner in Roma when you need to breathe."
        )
    ),
    Neighbourhood(
        number: 7, name: "Narvarte", shortName: "Narvarte",
        color: Color(hex: "#FF2D55"),
        coordinate: CLLocationCoordinate2D(latitude: 19.3998, longitude: -99.1583),
        tagline: "Local vibe, great value, up-and-coming",
        bestFor: "Budget-conscious nomads, locals-first experience",
        rents: RentTiers(
            studio:  "$500–700 USD / mo",
            oneBR:   "$700–900 USD / mo",
            twoBR:   "$900–1,200 USD / mo",
            airbnb:  "$35–70 USD / night"
        ),
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
        soul: SoulCard(
            icon: "sparkles",
            title: "Roma's Cooler Little Sibling",
            body: "The chefs and café owners priced out of Roma Norte came here first. The artists followed. The result is a neighbourhood that has all the quality of Condesa at a fraction of the price, with zero pretension and a local-to-tourist ratio that will make you feel like you actually live somewhere. Give it six months — everyone will know about Narvarte. Right now, it's still yours."
        )
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
                        .padding(.vertical, 5)

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
            .navigationBarTitleDisplayMode(.inline)
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

                    // ── Soul card ──────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: hood.soul.icon)
                                .font(.system(size: 12))
                                .foregroundColor(hood.color)
                            Text(hood.soul.title.uppercased())
                                .font(.custom("HelveticaNeue-Bold", size: 11))
                                .foregroundColor(hood.color)
                                .tracking(0.8)
                        }
                        Text(hood.soul.body)
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsLabel.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(3)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(hood.color.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(hood.color.opacity(0.15), lineWidth: 0)
                    )

                    Divider().background(Color.tsAccent.opacity(0.08))

                    // ── Meta row ───────────────────────────────────────────
                    HStack(spacing: 0) {
                        MetaCell(icon: "person.2.fill", color: Color.tsAccent,
                                 label: "Best for", value: hood.bestFor)
                    }
                    .padding(.vertical, 4)

                    Divider().background(Color.tsAccent.opacity(0.08))

                    // ── Rent tiers ─────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "#34C759"))
                            Text("AVG RENT")
                                .font(.custom("HelveticaNeue-Bold", size: 10))
                                .foregroundColor(.tsSecondary)
                                .tracking(0.5)
                        }
                        VStack(spacing: 6) {
                            RentRow(label: "Studio",    value: hood.rents.studio)
                            RentRow(label: "1 Bedroom", value: hood.rents.oneBR)
                            RentRow(label: "2 Bedroom", value: hood.rents.twoBR)
                            RentRow(label: "Airbnb",    value: hood.rents.airbnb)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    Divider().background(Color.tsAccent.opacity(0.08))

                    // ── Highlights ─────────────────────────────────────────
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

                    // ── Watch out ─────────────────────────────────────────
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

// MARK: - Rent Row

private struct RentRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .font(.custom("HelveticaNeue", size: 13))
                .foregroundColor(.tsSecondary)
            Spacer()
            Text(value)
                .font(.custom("HelveticaNeue-Medium", size: 13))
                .foregroundColor(.tsLabel)
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
