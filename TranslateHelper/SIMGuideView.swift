//  SIMGuideView.swift — SIM & carrier guide for nomads in Mexico

import SwiftUI

// MARK: - Models

enum StayLength { case short, monthly, longStay }

struct SIMCarrier: Identifiable {
    let id           = UUID()
    let name:        String
    let tagline:     String
    let badgeIcon:   String
    let badgeColor:  String
    let logoURL:     String          // Clearbit logo — fetched & cached at runtime
    let residency:   String
    let plans:       [String]
    let postpaid:    String
    let bestFor:     String
    let whereToBuy:  String
    let watchOut:    String
}

private let simCarriers: [SIMCarrier] = [
    SIMCarrier(
        name:       "Telcel",
        logoURL:    "https://logo.clearbit.com/telcel.com",
        tagline:    "Best coverage — 65% market share",
        badgeIcon:  "antenna.radiowaves.left.and.right",
        badgeColor: "#FF3B30",
        residency:  "No residency needed for prepaid",
        plans: [
            "Amigo PAYG ~$0.50 USD/day for 1GB + calls",
            "Weekly ~$4–5 USD",
            "Monthly ~$10–15 USD for 5–15GB"
        ],
        postpaid:   "Requires CURP (Mexican ID) — monthly contracts from $15 USD",
        bestFor:    "Anyone — has coverage everywhere including rural areas",
        whereToBuy: "Oxxo, Telcel stores, airports, Walmart",
        watchOut:   "Postpaid contracts require CURP — prepaid is fine for most nomads"
    ),
    SIMCarrier(
        name:       "AT&T Mexico",
        logoURL:    "https://logo.clearbit.com/att.com.mx",
        tagline:    "Strong in cities — good data speeds",
        badgeIcon:  "wifi",
        badgeColor: "#0099FF",
        residency:  "No residency for prepaid",
        plans: [
            "Weekly ~$4–6 USD",
            "Monthly ~$12–18 USD for 8–20GB"
        ],
        postpaid:   "Requires Mexican address + ID",
        bestFor:    "City-based nomads, good LTE speeds",
        whereToBuy: "Oxxo, AT&T stores, airports",
        watchOut:   "Weaker rural coverage than Telcel. Note: separate company from AT&T US"
    ),
    SIMCarrier(
        name:       "Movistar",
        logoURL:    "https://logo.clearbit.com/movistar.com",
        tagline:    "Budget option — major cities only",
        badgeIcon:  "cellularbars",
        badgeColor: "#34C759",
        residency:  "No residency for prepaid",
        plans: [
            "Monthly ~$8–12 USD for 5–10GB"
        ],
        postpaid:   "N/A for most nomads",
        bestFor:    "Budget-conscious, staying in major cities only",
        whereToBuy: "Oxxo, Movistar stores",
        watchOut:   "Coverage drops significantly outside CDMX, GDL, MTY"
    ),
]

// MARK: - Main View

struct SIMGuideView: View {
    @Environment(\.openURL) private var openURL
    @State private var selectedStay:     StayLength = .monthly
    @State private var expandedCarrier:  UUID?      = nil

    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                ScrollView {
                    VStack(spacing: 16) {

                        // ── Stay duration picker ─────────────────────
                        StayDurationPicker(selected: $selectedStay)

                        // ── Recommendation card ──────────────────────
                        StayRecommendationCard(stay: selectedStay)

                        // ── Mexican Carriers ─────────────────────────
                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel("MEXICAN CARRIERS")
                            VStack(spacing: 10) {
                                ForEach(simCarriers) { carrier in
                                    SIMCarrierCard(
                                        carrier:    carrier,
                                        isExpanded: expandedCarrier == carrier.id
                                    ) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            expandedCarrier = expandedCarrier == carrier.id ? nil : carrier.id
                                        }
                                    }
                                }
                            }
                        }

                        // ── eSIM Options ─────────────────────────────
                        SIMESIMSection(openURL: openURL)

                        // ── US Carriers in Mexico ────────────────────
                        USCarrierSection()

                        // ── Where to Buy ─────────────────────────────
                        SIMWhereToBuySection()

                        Spacer().frame(height: 32)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("SIM Guide")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Stay Duration Picker

struct StayDurationPicker: View {
    @Binding var selected: StayLength

    private struct Option: Identifiable {
        let id:    StayLength
        let label: String
    }

    private let options: [Option] = [
        Option(id: .short,    label: "Short Trip"),
        Option(id: .monthly,  label: "Monthly"),
        Option(id: .longStay, label: "Long Stay"),
    ]

    var body: some View {
        KitSegmentedPicker(items: options.map(\.id), selection: $selected) { id in
            options.first { $0.id == id }?.label ?? ""
        }
    }
}

// MARK: - Stay Recommendation Card

struct StayRecommendationCard: View {
    let stay: StayLength

    private var info: (icon: String, color: String, headline: String, detail: String) {
        switch stay {
        case .short:
            return (
                "esim",
                "#1B4DFF",
                "eSIM is easiest",
                "Buy before you land — works immediately. No need to find a store on arrival."
            )
        case .monthly:
            return (
                "simcard",
                "#FF9500",
                "Telcel or AT&T MX prepaid monthly",
                "~$10–18 USD, no residency needed. Easy to find at any Oxxo or airport."
            )
        case .longStay:
            return (
                "arrow.triangle.2.circlepath",
                "#34C759",
                "Telcel monthly prepaid stacked",
                "Stack monthly plans — or get a CURP for postpaid contracts with better rates."
            )
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: info.color).opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: info.icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: info.color))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(info.headline)
                    .font(.custom("HelveticaNeue-Bold", size: 15))
                    .foregroundColor(.tsLabel)
                Text(info.detail)
                    .font(.custom("HelveticaNeue", size: 13))
                    .foregroundColor(.tsSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.tsCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: info.color).opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Carrier Logo View
// Fetches brand logo from Clearbit at runtime, cached by URLCache.
// Falls back to SF Symbol if unavailable (offline / rate limit).

struct CarrierLogoView: View {
    let logoURL:  String
    let sfSymbol: String
    let color:    String
    var size:     CGFloat = 44

    var body: some View {
        AsyncImage(url: URL(string: logoURL)) { phase in
            switch phase {
            case .success(let img):
                img.resizable()
                    .scaledToFit()
                    .padding(size * 0.12)
                    .background(Color(UIColor.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.27))
                    .frame(width: size, height: size)
            default:
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.27)
                        .fill(Color(hex: color).opacity(0.12))
                        .frame(width: size, height: size)
                    Image(systemName: sfSymbol)
                        .font(.system(size: size * 0.40))
                        .foregroundColor(Color(hex: color))
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Carrier Card (accordion)

struct SIMCarrierCard: View {
    let carrier:    SIMCarrier
    let isExpanded: Bool
    let onTap:      () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            Button(action: onTap) {
                HStack(spacing: 12) {
                    CarrierLogoView(
                        logoURL:   carrier.logoURL,
                        sfSymbol:  carrier.badgeIcon,
                        color:     carrier.badgeColor
                    )
                    VStack(alignment: .leading, spacing: 2) {
                        Text(carrier.name)
                            .font(.custom("HelveticaNeue-Bold", size: 16))
                            .foregroundColor(.tsLabel)
                        Text(carrier.tagline)
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsSecondary)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.tsSecondary)
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())

            // Expanded detail
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider().background(Color.tsAccent.opacity(0.06))

                    // Residency note
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(hex: "#34C759"))
                            .font(.system(size: 13))
                        Text(carrier.residency)
                            .font(.custom("HelveticaNeue-Medium", size: 13))
                            .foregroundColor(.tsLabel)
                    }

                    // Prepaid plans
                    VStack(alignment: .leading, spacing: 5) {
                        Text("PREPAID PLANS")
                            .font(.custom("HelveticaNeue-Bold", size: 11))
                            .foregroundColor(.tsSecondary)
                            .tracking(1.1)
                        ForEach(carrier.plans, id: \.self) { plan in
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(hex: "#34C759"))
                                    .padding(.top, 2)
                                Text(plan)
                                    .font(.custom("HelveticaNeue", size: 13))
                                    .foregroundColor(.tsLabel)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }

                    // Postpaid
                    VStack(alignment: .leading, spacing: 4) {
                        Text("POSTPAID (CONTRACT)")
                            .font(.custom("HelveticaNeue-Bold", size: 11))
                            .foregroundColor(.tsSecondary)
                            .tracking(1.1)
                        Text(carrier.postpaid)
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsLabel)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Best for
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: "#FF9500"))
                            .font(.system(size: 12))
                        Text("Best for: \(carrier.bestFor)")
                            .font(.custom("HelveticaNeue-Medium", size: 13))
                            .foregroundColor(.tsLabel)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Where to buy
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "cart.fill")
                            .foregroundColor(.tsAccent)
                            .font(.system(size: 12))
                        Text("Buy at: \(carrier.whereToBuy)")
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Watch out
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color(hex: "#FF9500"))
                            .font(.system(size: 13))
                        Text(carrier.watchOut)
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(Color.tsCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
    }
}

// MARK: - eSIM Section

struct SIMESIMSection: View {
    let openURL: OpenURLAction

    private struct ESIMProvider: Identifiable {
        let id      = UUID()
        let name:    String
        let tagline: String
        let detail:  String
        let color:   String
        let url:     String
        let initial: String
        let logoURL: String
    }

    private let providers: [ESIMProvider] = [
        ESIMProvider(
            name:    "Airalo",
            logoURL: "https://logo.clearbit.com/airalo.com",
            tagline: "Buy before you land",
            detail:  "From $5 USD / 1GB",
            color:   "#1B4DFF",
            url:     "https://airalo.com",
            initial: "A"
        ),
        ESIMProvider(
            name:    "Holafly",
            logoURL: "https://logo.clearbit.com/holafly.com",
            tagline: "Unlimited data, easiest setup",
            detail:  "From $27 USD / 7 days unlimited",
            color:   "#FF6B35",
            url:     "https://holafly.com",
            initial: "H"
        ),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("eSIM OPTIONS")

            VStack(spacing: 0) {
                ForEach(Array(providers.enumerated()), id: \.offset) { i, provider in
                    Button {
                        if let url = URL(string: provider.url) { openURL(url) }
                    } label: {
                        HStack(spacing: 12) {
                            CarrierLogoView(
                                logoURL:   provider.logoURL,
                                sfSymbol:  "esim",
                                color:     provider.color,
                                size:      40
                            )

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(provider.name)
                                        .font(.custom("HelveticaNeue-Bold", size: 14))
                                        .foregroundColor(.tsLabel)
                                    Text(provider.detail)
                                        .font(.custom("HelveticaNeue-Medium", size: 11))
                                        .foregroundColor(Color(hex: provider.color))
                                        .padding(.horizontal, 6).padding(.vertical, 2)
                                        .background(Color(hex: provider.color).opacity(0.1))
                                        .clipShape(Capsule())
                                }
                                Text(provider.tagline)
                                    .font(.custom("HelveticaNeue", size: 12))
                                    .foregroundColor(.tsSecondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.tsAccent)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(PlainButtonStyle())

                    if i < providers.count - 1 {
                        Divider().background(Color.tsAccent.opacity(0.06)).padding(.leading, 68)
                    }
                }
            }
            .background(Color.tsCard)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))

            // Compatibility note
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.tsSecondary)
                Text("eSIMs require a compatible unlocked iPhone (XS or newer). Check Settings → General → About → Available SIMs.")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - US Carriers Section

struct USCarrierSection: View {
    private struct USCarrier: Identifiable {
        let id      = UUID()
        let name:    String
        let badge:   String
        let color:   String
        let detail:  String
        let logoURL: String
    }

    private let carriers: [USCarrier] = [
        USCarrier(
            name:   "T-Mobile",
            logoURL: "https://logo.clearbit.com/t-mobile.com",
            badge:  "Best for US users",
            color:  "#E20074",
            detail: "Free unlimited calls, texts + data (reduced speeds) included on most plans. Full LTE on Magenta Plus / Go5G. Uses Telcel network."
        ),
        USCarrier(
            name:   "AT&T US",
            logoURL: "https://logo.clearbit.com/att.com",
            badge:  "Day Pass or add-on",
            color:  "#00A8E0",
            detail: "International Day Pass $10/day for full speeds. Some plans include basic Mexico coverage. Check your plan."
        ),
        USCarrier(
            name:   "Verizon",
            logoURL: "https://logo.clearbit.com/verizon.com",
            badge:  "Most expensive option",
            color:  "#CD040B",
            detail: "TravelPass $10/day. No free Mexico roaming. Roams on Telcel. Fine if you need it but pricey."
        ),
        USCarrier(
            name:   "Sprint / T-Mobile",
            logoURL: "https://logo.clearbit.com/sprint.com",
            badge:  "Merged → same as T-Mobile",
            color:  "#6B2D8B",
            detail: "Sprint is now T-Mobile — same coverage applies. If you have an old Sprint plan, check your T-Mobile benefits."
        ),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("YOUR US CARRIER IN MEXICO")

            VStack(spacing: 0) {
                ForEach(Array(carriers.enumerated()), id: \.offset) { i, carrier in
                    HStack(alignment: .top, spacing: 12) {
                        CarrierLogoView(
                            logoURL:   carrier.logoURL,
                            sfSymbol:  "antenna.radiowaves.left.and.right",
                            color:     carrier.color,
                            size:      36
                        )

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(carrier.name)
                                    .font(.custom("HelveticaNeue-Bold", size: 14))
                                    .foregroundColor(.tsLabel)
                                Text(carrier.badge)
                                    .font(.custom("HelveticaNeue-Medium", size: 11))
                                    .foregroundColor(Color(hex: carrier.color))
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Color(hex: carrier.color).opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            Text(carrier.detail)
                                .font(.custom("HelveticaNeue", size: 13))
                                .foregroundColor(.tsSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    if i < carriers.count - 1 {
                        Divider().background(Color.tsAccent.opacity(0.06)).padding(.leading, 64)
                    }
                }
            }
            .background(Color.tsCard)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
    }
}

// MARK: - Where to Buy Section

struct SIMWhereToBuySection: View {
    private let tips: [(icon: String, color: String, title: String, detail: String)] = [
        ("cart.fill",               "#34C759", "Oxxo convenience stores",  "Everywhere in Mexico — easiest option. Ask for a SIM Telcel or SIM AT&T."),
        ("airplane.arrival",        "#0099FF", "Airport on arrival",        "Available at all major airports. Slightly pricier but fast to get started."),
        ("building.2.fill",         "#AF52DE", "Carrier stores",            "Telcel and AT&T MX stores in most malls. Staff can help with setup."),
        ("dollarsign.circle.fill",  "#FF9500", "Top up (recargas)",         "Recharge at any Oxxo, 7-Eleven, or via the Telcel/AT&T app. Super easy."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("WHERE TO BUY")

            VStack(spacing: 0) {
                ForEach(Array(tips.enumerated()), id: \.offset) { i, tip in
                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: tip.color).opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: tip.icon)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: tip.color))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(tip.title)
                                .font(.custom("HelveticaNeue-Bold", size: 14))
                                .foregroundColor(.tsLabel)
                            Text(tip.detail)
                                .font(.custom("HelveticaNeue", size: 13))
                                .foregroundColor(.tsSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    if i < tips.count - 1 {
                        Divider().background(Color.tsAccent.opacity(0.06)).padding(.leading, 66)
                    }
                }
            }
            .background(Color.tsCard)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
    }
}
