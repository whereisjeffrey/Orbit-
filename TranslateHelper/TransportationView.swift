//  TransportationView.swift
//  TalkSwitch

import SwiftUI

// MARK: - Transport Mode

private enum TransportMode: String, CaseIterable {
    case rideshare  = "Ride-Hailing"
    case transit    = "Public Transit"
    case wheels     = "Bikes & Scooters"
    case car        = "Car Rental"
    case intercity  = "Intercity"
}

// MARK: - Main View

struct TransportationView: View {
    @State private var mode: TransportMode = .rideshare
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                ScrollView {
                    VStack(spacing: 0) {

                        // ── Mode picker ───────────────────────────────────
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(TransportMode.allCases, id: \.self) { m in
                                    Button {
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) { mode = m }
                                    } label: {
                                        Text(m.rawValue)
                                            .font(.custom("HelveticaNeue-Medium", size: 13))
                                            .foregroundColor(mode == m ? .tsAccent : .tsSecondary)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 14)
                                            .background(mode == m ? Color(UIColor.systemBackground) : Color.clear)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(3)
                            .background(Color.tsInputBg)
                            .cornerRadius(11)
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 20)

                        // ── Section content ───────────────────────────────
                        Group {
                            switch mode {
                            case .rideshare:  RideshareSection(openURL: openURL)
                            case .transit:    TransitSection()
                            case .wheels:     WheelsSection(openURL: openURL)
                            case .car:        CarRentalSection(openURL: openURL)
                            case .intercity:  IntercitySection(openURL: openURL)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 96)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Transportation")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Ride-Hailing

private struct RideApp: Identifiable {
    let id = UUID()
    let name: String
    let tagline: String
    let detail: String
    let color: Color
    let icon: String
    let badge: String?
    let url: String
}

private struct RideshareSection: View {
    let openURL: OpenURLAction
    @State private var expanded: String? = nil

    let apps: [RideApp] = [
        RideApp(name: "DiDi",    tagline: "Usually 20–30% cheaper than Uber",
                detail: "Chinese-owned app that launched in Mexico in 2018. Works exactly like Uber — request, track, pay in-app. Widely available in CDMX, GDL, MTY and expanding fast. Prices are consistently lower. Worth downloading before Uber.",
                color: Color(hex: "#FF6B00"), icon: "car.fill", badge: "CHEAPEST", url: "https://web.didiglobal.com/mx/"),
        RideApp(name: "Uber",    tagline: "Reliable, familiar, good coverage",
                detail: "Largest network in Mexico. Works in almost every city. Slightly more expensive than DiDi. Good for late nights or unfamiliar areas when you want maximum driver availability.",
                color: Color(hex: "#000000"), icon: "car.fill", badge: nil, url: "https://uber.com"),
        RideApp(name: "inDriver", tagline: "You name your price — driver accepts or counters",
                detail: "Unique model: you propose a fare, nearby drivers accept or make a counter-offer. Often the cheapest for longer rides. Great for airport trips. Less available in smaller areas.",
                color: Color(hex: "#1BC464"), icon: "car.fill", badge: "NEGOTIATE", url: "https://indriver.com"),
        RideApp(name: "Cabify",  tagline: "Professional drivers, slightly premium",
                detail: "Spanish ride-hailing company. Drivers tend to be more formal, cars cleaner. Slightly pricier. Good option if you want a more consistent experience for client meetings or the airport.",
                color: Color(hex: "#7B2D8B"), icon: "car.fill", badge: nil, url: "https://cabify.com/mx"),
    ]

    var body: some View {
        VStack(spacing: 12) {
            // Safety callout
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "#FF3B30"))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Safety first")
                        .font(.custom("HelveticaNeue-Bold", size: 14))
                        .foregroundColor(.tsLabel)
                    Text("Always confirm plate + driver photo before getting in. Never accept rides from drivers who approach you — only use the app. Avoid hailing street taxis.")
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.tsSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .background(Color(hex: "#FF3B30").opacity(0.08))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#FF3B30").opacity(0.15), lineWidth: 0.5))

            // App cards
            ForEach(apps) { app in
                RideAppCard(app: app, isExpanded: expanded == app.name, openURL: openURL) {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        expanded = expanded == app.name ? nil : app.name
                    }
                }
            }
        }
    }
}

private struct RideAppCard: View {
    let app: RideApp
    let isExpanded: Bool
    let openURL: OpenURLAction
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(app.color.opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: app.icon)
                            .font(.system(size: 16))
                            .foregroundColor(app.color)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(app.name)
                                .font(.custom("HelveticaNeue-Bold", size: 16))
                                .foregroundColor(.tsLabel)
                            if let badge = app.badge {
                                Text(badge)
                                    .font(.custom("HelveticaNeue-Bold", size: 9))
                                    .foregroundColor(Color(hex: "#34C759"))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(hex: "#34C759").opacity(0.12))
                                    .cornerRadius(4)
                            }
                        }
                        Text(app.tagline)
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsSecondary)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.tsSecondary.opacity(0.5))
                }
                .padding(14)
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                VStack(spacing: 12) {
                    Divider().background(Color.tsAccent.opacity(0.08))
                    Text(app.detail)
                        .font(.custom("HelveticaNeue", size: 14))
                        .foregroundColor(.tsSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 14)
                    Button {
                        if let url = URL(string: app.url) { openURL(url) }
                    } label: {
                        Text("Open \(app.name)")
                            .font(.custom("HelveticaNeue-Medium", size: 14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(app.color)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
                }
            }
        }
        .background(Color.tsCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
    }
}

// MARK: - Public Transit

private struct TransitSection: View {
    var body: some View {
        VStack(spacing: 12) {
            // Card setup
            TransportInfoCard(
                icon: "creditcard.fill", color: Color.tsAccent,
                title: "Tarjeta MI (Movilidad Integrada)",
                bodyText: "One card for all CDMX transit: Metro, Metrobús, Trolebús, Cablebús, Tren Ligero. Buy at any Metro station for ~$1.50 USD deposit. Load credit at kiosks or the app. No monthly unlimited pass — it's stored value."
            )

            // Lines & prices
            VStack(spacing: 0) {
                TransitRouteRow(icon: "tram.fill", color: Color(hex: "#B5007F"), name: "Metro",
                                detail: "12 lines, ~490 stations", price: "$0.25 USD / ride (5 MXN)")
                Divider().padding(.leading, 48)
                TransitRouteRow(icon: "bus.fill", color: Color(hex: "#E2231A"), name: "Metrobús",
                                detail: "BRT rapid buses, 7 lines", price: "$0.37 USD / ride (7.50 MXN)")
                Divider().padding(.leading, 48)
                TransitRouteRow(icon: "tram.circle.fill", color: Color(hex: "#0055A5"), name: "Trolebús",
                                detail: "Electric trolleybus", price: "Free on some routes, 5 MXN others")
                Divider().padding(.leading, 48)
                TransitRouteRow(icon: "cable.car.fill", color: Color(hex: "#34C759"), name: "Cablebús",
                                detail: "Aerial cable car — Lines 1 & 2", price: "$0.25 USD / ride (5 MXN)")
            }
            .background(Color.tsCard)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))

            // Safety tips
            VStack(spacing: 0) {
                TransTipRow(icon: "person.2.fill",     color: Color(hex: "#AF52DE"), title: "Women-only cars",      detail: "First car of each Metro train is women + children only, especially useful during rush hour.")
                Divider().padding(.leading, 48)
                TransTipRow(icon: "clock.fill",         color: Color(hex: "#FF9500"), title: "Avoid rush hour",     detail: "7–9 AM and 6–9 PM are extremely crowded. Watch your pockets and keep bags in front of you.")
                Divider().padding(.leading, 48)
                TransTipRow(icon: "eye.fill",           color: Color(hex: "#FF3B30"), title: "Pickpockets",         detail: "Common on Metro. Use a money belt or keep phone/wallet in front pocket. Don't use your phone at station doors.")
                Divider().padding(.leading, 48)
                TransTipRow(icon: "moon.stars.fill",    color: Color(hex: "#5856D6"), title: "Late nights",         detail: "Metro closes around midnight. Stick to Uber/DiDi after 11 PM — safer and not expensive.")
            }
            .background(Color.tsCard)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
    }
}

private struct TransitRouteRow: View {
    let icon: String; let color: Color; let name: String; let detail: String; let price: String
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.12)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 14)).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.custom("HelveticaNeue-Bold", size: 15)).foregroundColor(.tsLabel)
                Text(detail).font(.custom("HelveticaNeue", size: 12)).foregroundColor(.tsSecondary)
            }
            Spacer()
            Text(price).font(.custom("HelveticaNeue-Medium", size: 12)).foregroundColor(.tsAccent).multilineTextAlignment(.trailing).frame(maxWidth: 110)
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
    }
}

// MARK: - Bikes & Scooters

private struct WheelsSection: View {
    let openURL: OpenURLAction
    var body: some View {
        VStack(spacing: 12) {
            TransportInfoCard(
                icon: "figure.outdoor.cycle", color: Color(hex: "#34C759"),
                title: "Best for Roma Norte, Condesa & Polanco",
                bodyText: "These neighbourhoods are flat, bike-lane-equipped and very cyclable. Ecobici is the easiest daily option. Lime e-scooters work great for short hops between cafés."
            )

            VStack(spacing: 0) {
                WheelsRow(icon: "bicycle", color: Color(hex: "#FF6B00"), name: "Ecobici",
                          tagline: "CDMX public bike share — 480 stations",
                          plans: "Day pass ~$5 USD · Monthly ~$25 USD · Annual ~$25 USD",
                          url: "https://ecobici.cdmx.gob.mx", openURL: openURL)
                Divider().padding(.leading, 48)
                WheelsRow(icon: "scooter", color: Color(hex: "#00C853"), name: "Lime",
                          tagline: "E-scooters in Roma / Condesa / Polanco",
                          plans: "Unlock $1 + $0.25/min · Day pass available in app",
                          url: "https://li.me", openURL: openURL)
            }
            .background(Color.tsCard)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))

            TransTipRow(icon: "helmet.fill", color: Color(hex: "#FF3B30"), title: "Helmets & traffic",
                      detail: "Helmets not provided with Ecobici — bring your own or buy cheaply at Liverpool/Walmart. CDMX traffic is aggressive; stick to marked ciclovías (bike lanes).")
                .padding(14)
                .background(Color.tsCard)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
    }
}

private struct WheelsRow: View {
    let icon: String; let color: Color; let name: String
    let tagline: String; let plans: String; let url: String
    let openURL: OpenURLAction
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.12)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 14)).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(name).font(.custom("HelveticaNeue-Bold", size: 15)).foregroundColor(.tsLabel)
                Text(tagline).font(.custom("HelveticaNeue", size: 12)).foregroundColor(.tsSecondary)
                Text(plans).font(.custom("HelveticaNeue-Medium", size: 12)).foregroundColor(.tsAccent)
            }
            Spacer()
            Button {
                if let u = URL(string: url) { openURL(u) }
            } label: {
                Text("Open").font(.custom("HelveticaNeue-Medium", size: 12)).foregroundColor(.white)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.tsAccent).cornerRadius(8)
            }.buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
    }
}

// MARK: - Car Rental

private struct CarRentalSection: View {
    let openURL: OpenURLAction
    var body: some View {
        VStack(spacing: 12) {
            // License info
            TransportInfoCard(
                icon: "creditcard.viewfinder", color: Color(hex: "#FF9500"),
                title: "Foreign driver's licence is valid",
                bodyText: "Your home country licence is valid in Mexico for the duration of your tourist visa (up to 180 days). You don't legally need an International Driving Permit (IDP) — though some rental companies may ask. Bring your physical licence, not just a photo."
            )

            // Insurance warning
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 18)).foregroundColor(Color(hex: "#FF9500"))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mexican law requires liability insurance")
                        .font(.custom("HelveticaNeue-Bold", size: 14)).foregroundColor(.tsLabel)
                    Text("Most US/Canadian credit cards do NOT cover Mexico. You must purchase local liability insurance from the rental company — usually $10–20 USD/day. Do not skip this.")
                        .font(.custom("HelveticaNeue", size: 13)).foregroundColor(.tsSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .background(Color(hex: "#FF9500").opacity(0.08))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#FF9500").opacity(0.18), lineWidth: 0.5))

            // Rental options
            VStack(spacing: 0) {
                TransTipRow(icon: "building.2.fill",    color: Color.tsAccent,         title: "Traditional rentals",        detail: "Hertz, Budget, Avis, Enterprise at major airports and city centres. Book via Kayak or Rentalcars.com for best rates.")
                Divider().padding(.leading, 48)
                TransTipRow(icon: "house.fill",         color: Color(hex: "#FF5E3A"),   title: "Turo — peer-to-peer",        detail: "Airbnb for cars. Available in Mexico. Often 30–40% cheaper than traditional rental. Hosts may be more flexible about pickup location.")
                Divider().padding(.leading, 48)
                TransTipRow(icon: "person.2.fill",      color: Color(hex: "#AF52DE"),   title: "Private rentals (smaller cities)", detail: "In Playa del Carmen, Tulum, Oaxaca and smaller towns, locals often rent cars informally via Facebook groups or word of mouth. Ask your Airbnb host.")
                Divider().padding(.leading, 48)
                TransTipRow(icon: "creditcard.fill",    color: Color(hex: "#34C759"),   title: "Credit card required",       detail: "Nearly all rental companies require a credit card for the security hold. Debit cards are usually not accepted.")
            }
            .background(Color.tsCard)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))

            // Turo link
            Button {
                if let u = URL(string: "https://turo.com") { openURL(u) }
            } label: {
                HStack {
                    Image(systemName: "arrow.up.right.square")
                        .font(.system(size: 14)).foregroundColor(.white)
                    Text("Browse Turo in Mexico")
                        .font(.custom("HelveticaNeue-Medium", size: 15)).foregroundColor(.white)
                }
                .frame(maxWidth: .infinity).frame(height: 48)
                .background(Color(hex: "#FF5E3A")).cornerRadius(12)
            }.buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Intercity

private struct IntercitySection: View {
    let openURL: OpenURLAction
    var body: some View {
        VStack(spacing: 12) {
            TransportInfoCard(
                icon: "road.lanes", color: Color(hex: "#5856D6"),
                title: "Getting out of CDMX",
                bodyText: "Mexico has excellent long-distance buses — often better than flying once you factor in airport time. For Oaxaca, Guadalajara, Cancún or the Yucatán, compare bus vs. flight based on your time budget."
            )

            VStack(spacing: 0) {
                IntercityRow(icon: "bus.doubledecker.fill", color: Color(hex: "#E2231A"),
                             name: "ADO", tagline: "Premium coach buses — most routes",
                             detail: "Comfortable, punctual, WiFi + USB ports on some routes. CDMX → Oaxaca ~6h $20–35 USD. CDMX → Cancún ~24h (fly instead). Book online.",
                             url: "https://ado.com.mx", openURL: openURL)
                Divider().padding(.leading, 48)
                IntercityRow(icon: "bus.fill", color: Color(hex: "#0C9B3A"),
                             name: "FlixBus", tagline: "Budget intercity — growing network",
                             detail: "German-owned, expanding in Mexico. Cheaper than ADO on shared routes. Comfortable, easy app. Good for Guadalajara, Monterrey corridor.",
                             url: "https://flixbus.com.mx", openURL: openURL)
                Divider().padding(.leading, 48)
                IntercityRow(icon: "car.2.fill", color: Color(hex: "#004FBE"),
                             name: "BlaBlaCar", tagline: "Rideshare with locals — cheapest option",
                             detail: "Active in Mexico. Drivers going your direction offer seats. Much cheaper than buses for some routes. Great way to meet locals. Book the app in advance — seats fill up.",
                             url: "https://www.blablacar.com.mx", openURL: openURL)
                Divider().padding(.leading, 48)
                IntercityRow(icon: "airplane", color: Color(hex: "#FF9500"),
                             name: "Volaris / Vivaaerobus", tagline: "Budget domestic flights",
                             detail: "For CDMX → Cancún, Los Cabos, Puerto Vallarta — fly. Volaris and Vivaaerobus are ultra-low-cost; book 2–3 weeks out for best fares. Watch baggage fees.",
                             url: "https://www.volaris.com", openURL: openURL)
            }
            .background(Color.tsCard)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
    }
}

private struct IntercityRow: View {
    let icon: String; let color: Color; let name: String
    let tagline: String; let detail: String; let url: String
    let openURL: OpenURLAction
    @State private var expanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button { withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() } } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.12)).frame(width: 36, height: 36)
                        Image(systemName: icon).font(.system(size: 13)).foregroundColor(color)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(name).font(.custom("HelveticaNeue-Bold", size: 15)).foregroundColor(.tsLabel)
                        Text(tagline).font(.custom("HelveticaNeue", size: 13)).foregroundColor(.tsSecondary)
                    }
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .medium)).foregroundColor(.tsSecondary.opacity(0.5))
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
            }.buttonStyle(PlainButtonStyle())

            if expanded {
                VStack(spacing: 10) {
                    Divider().background(Color.tsAccent.opacity(0.08))
                    Text(detail)
                        .font(.custom("HelveticaNeue", size: 13)).foregroundColor(.tsSecondary)
                        .fixedSize(horizontal: false, vertical: true).padding(.horizontal, 14)
                    Button {
                        if let u = URL(string: url) { openURL(u) }
                    } label: {
                        Text("Book \(name)")
                            .font(.custom("HelveticaNeue-Medium", size: 13)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 36)
                            .background(color).cornerRadius(9)
                    }.buttonStyle(PlainButtonStyle()).padding(.horizontal, 14).padding(.bottom, 12)
                }
            }
        }
    }
}

// MARK: - Shared helpers

private struct TransportInfoCard: View {
    let icon: String; let color: Color; let title: String; let bodyText: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.12)).frame(width: 40, height: 40)
                Image(systemName: icon).font(.system(size: 16)).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.custom("HelveticaNeue-Bold", size: 14)).foregroundColor(.tsLabel)
                Text(bodyText).font(.custom("HelveticaNeue", size: 13)).foregroundColor(.tsSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color.tsCard)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
    }
}

private struct TransTipRow: View {
    let icon: String; let color: Color; let title: String; let detail: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 34, height: 34)
                Image(systemName: icon).font(.system(size: 13)).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.custom("HelveticaNeue-Bold", size: 14)).foregroundColor(.tsLabel)
                Text(detail).font(.custom("HelveticaNeue", size: 13)).foregroundColor(.tsSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
    }
}
