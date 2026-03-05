//  InsuranceView.swift — Traveller Insurance guide for nomads

import SwiftUI

// MARK: - Data
struct InsuranceProvider: Identifiable {
    let id = UUID()
    let name:        String
    let tagline:     String
    let priceLabel:  String
    let badge:       String          // emoji badge
    let badgeColor:  String
    let covers:      [String]
    let watchOut:    String
    let website:     String
    let isBestFor:   String
}

let providers: [InsuranceProvider] = [
    InsuranceProvider(
        name: "SafetyWing", tagline: "The nomad default",
        priceLabel: "~$45/mo", badge: "🏆", badgeColor: "#FF9500",
        covers: ["Emergency medical", "Hospital stays", "Evacuation", "Trip interruption"],
        watchOut: "No gear coverage. Pre-existing conditions excluded. Limited dental.",
        website: "safetywing.com",
        isBestFor: "Budget-conscious nomads who are generally healthy"
    ),
    InsuranceProvider(
        name: "World Nomads", tagline: "Better gear + adventure coverage",
        priceLabel: "~$90–140/mo", badge: "🎒", badgeColor: "#0099FF",
        covers: ["Medical + evacuation", "Laptop & camera gear", "Trip cancellation", "200+ adventure sports"],
        watchOut: "More expensive. Claims process can be slow. Age limits apply.",
        website: "worldnomads.com",
        isBestFor: "Travellers with expensive gear or doing adventure activities"
    ),
    InsuranceProvider(
        name: "Genki", tagline: "European-grade coverage",
        priceLabel: "~$35–80/mo", badge: "🌍", badgeColor: "#34C759",
        covers: ["Comprehensive medical", "Mental health", "Dental included", "No home country exclusion"],
        watchOut: "Based in Germany — claims/support in EU timezone. No gear.",
        website: "genki.world",
        isBestFor: "EU nomads or anyone wanting solid mental health coverage"
    ),
    InsuranceProvider(
        name: "IMG Global", tagline: "Serious expat-grade cover",
        priceLabel: "~$80–200/mo", badge: "🏥", badgeColor: "#AF52DE",
        covers: ["Full medical + dental", "Pre-existing (some plans)", "Prescription drugs", "Maternity (select plans)"],
        watchOut: "Complex plans — read the fine print carefully before buying.",
        website: "imglobal.com",
        isBestFor: "Long-term expats or those needing comprehensive health coverage"
    ),
]

let coverageTypes: [(icon: String, color: String, title: String, desc: String)] = [
    ("cross.fill",            "#FF3B30", "Medical Emergency",     "Hospital, surgery, ambulance. The non-negotiable."),
    ("airplane.departure",    "#0099FF", "Medical Evacuation",    "Airlifted home if local care isn't good enough."),
    ("laptopcomputer",        "#FF9500", "Gear & Electronics",    "Laptop, camera, phone — often excluded by default."),
    ("calendar.badge.minus",  "#AF52DE", "Trip Cancellation",     "Flight missed, trip cut short, airline went bust."),
    ("person.fill.questionmark","#34C759","Personal Liability",  "If you accidentally injure someone or damage property."),
    ("stethoscope",           "#5856D6", "Dental & Vision",       "Usually add-on. Often worth it for long stays."),
]

let exclusions: [(icon: String, text: String)] = [
    ("exclamationmark.triangle.fill", "Pre-existing conditions (most plans)"),
    ("sportscourt.fill",              "Extreme sports unless specifically added"),
    ("bag.fill",                      "Unattended gear theft"),
    ("wineglass.fill",                "Incidents while under the influence"),
    ("clock.arrow.circlepath",        "Treatment sought > 30 days after incident"),
]

// MARK: - Main View
struct InsuranceView: View {
    @State private var expandedProvider: UUID? = nil

    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                ScrollView {
                    VStack(spacing: 16) {

                        // ── Why you need it ──────────────────────────
                        WhyInsuranceCard()

                        // ── Coverage types ───────────────────────────
                        CoverageTypesSection()

                        // ── Providers ────────────────────────────────
                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel("POPULAR WITH NOMADS")
                            VStack(spacing: 10) {
                                ForEach(providers) { p in
                                    ProviderCard(provider: p, isExpanded: expandedProvider == p.id) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            expandedProvider = expandedProvider == p.id ? nil : p.id
                                        }
                                    }
                                }
                            }
                        }

                        // ── What's NOT covered ───────────────────────
                        ExclusionsCard()

                        // ── Mexico-specific tips ─────────────────────
                        MexicoTipsCard()

                        Spacer().frame(height: 32)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Insurance")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Why card
struct WhyInsuranceCard: View {
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#FF3B30").opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: "cross.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(hex: "#FF3B30"))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Don't skip this one")
                    .font(.custom("HelveticaNeue-Bold", size: 17))
                    .foregroundColor(.tsLabel)
                Text("A single hospital night in Mexico can run $300–$2,000 USD. A medical evacuation can top $50,000. Most plans cost less than your daily coffee habit.")
                    .font(.custom("HelveticaNeue", size: 13))
                    .foregroundColor(.tsSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#FF3B30").opacity(0.15), lineWidth: 1))
    }
}

// MARK: - Coverage types grid
// Captures the tallest tile height so all tiles can match it
private struct TileHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct CoverageTypesSection: View {
    let cols = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    @State private var tileH: CGFloat = 110

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("WHAT TO LOOK FOR")
            LazyVGrid(columns: cols, spacing: 10) {
                ForEach(coverageTypes, id: \.title) { c in
                    VStack(alignment: .leading, spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: c.color).opacity(0.12))
                                .frame(width: 38, height: 38)
                            Image(systemName: c.icon)
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: c.color))
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(c.title)
                                .font(.custom("HelveticaNeue-Bold", size: 13))
                                .foregroundColor(.tsLabel)
                            Text(c.desc)
                                .font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(.tsSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, minHeight: tileH, alignment: .topLeading)
                    .background(
                        // Measure natural height of each tile
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: TileHeightKey.self, value: geo.size.height)
                        }
                    )
                    .background(Color.tsCard)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5)
                    )
                }
            }
            // Only ever grow — prevents layout loops
            .onPreferenceChange(TileHeightKey.self) { h in
                if h > tileH { tileH = h }
            }
        }
    }
}

// MARK: - Provider card
struct ProviderCard: View {
    let provider:   InsuranceProvider
    let isExpanded: Bool
    let onTap:      () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            Button(action: onTap) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: provider.badgeColor).opacity(0.12))
                            .frame(width: 44, height: 44)
                        Text(provider.badge).font(.system(size: 22))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(provider.name)
                                .font(.custom("HelveticaNeue-Bold", size: 16))
                                .foregroundColor(.tsLabel)
                            Text(provider.priceLabel)
                                .font(.custom("HelveticaNeue-Medium", size: 12))
                                .foregroundColor(Color(hex: provider.badgeColor))
                                .padding(.horizontal, 7).padding(.vertical, 3)
                                .background(Color(hex: provider.badgeColor).opacity(0.12))
                                .clipShape(Capsule())
                        }
                        Text(provider.tagline)
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

            // Expanded detail
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider().background(Color.tsAccent.opacity(0.06))

                    // Best for
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(hex: provider.badgeColor))
                            .font(.system(size: 13))
                        Text("Best for: \(provider.isBestFor)")
                            .font(.custom("HelveticaNeue-Medium", size: 13))
                            .foregroundColor(.tsLabel)
                    }

                    // Covers
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Covers")
                            .font(.custom("HelveticaNeue-Bold", size: 12))
                            .foregroundColor(.tsSecondary)
                        ForEach(provider.covers, id: \.self) { c in
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark").font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(hex: "#34C759"))
                                Text(c).font(.custom("HelveticaNeue", size: 13)).foregroundColor(.tsLabel)
                            }
                        }
                    }

                    // Watch out
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color(hex: "#FF9500"))
                            .font(.system(size: 13))
                        Text(provider.watchOut)
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Website button
                    Button(action: { openURL(provider.website) }) {
                        HStack(spacing: 6) {
                            Image(systemName: "safari")
                            Text("Visit \(provider.website)")
                        }
                        .font(.custom("HelveticaNeue-Medium", size: 14))
                        .foregroundColor(.tsAccent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.tsAccent.opacity(0.08))
                        .cornerRadius(12)
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

    private func openURL(_ site: String) {
        let s = site.hasPrefix("http") ? site : "https://\(site)"
        if let url = URL(string: s) { UIApplication.shared.open(url) }
    }
}

// MARK: - Exclusions
struct ExclusionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("USUALLY NOT COVERED")
            VStack(spacing: 0) {
                ForEach(Array(exclusions.enumerated()), id: \.offset) { i, e in
                    HStack(spacing: 12) {
                        Image(systemName: e.icon)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#FF9500"))
                            .frame(width: 20)
                        Text(e.text)
                            .font(.custom("HelveticaNeue", size: 14))
                            .foregroundColor(.tsLabel)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    if i < exclusions.count - 1 {
                        Divider().background(Color.tsAccent.opacity(0.06)).padding(.leading, 48)
                    }
                }
            }
            .background(Color.tsCard)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
    }
}

// MARK: - Mexico tips
struct MexicoTipsCard: View {
    let tips: [(icon: String, color: String, text: String)] = [
        ("building.2.fill",           "#0099FF", "Hospital Ángeles and ABC Hospital are the top private picks in CDMX — consistently expat-recommended."),
        ("icloud.and.arrow.down.fill", "#34C759", "Keep digital copies of your policy in Notes, email, and iCloud — somewhere you can reach even without data."),
        ("clock.badge.exclamationmark.fill", "#FF9500", "File the claim the same day if possible. Waiting even 24 hours can seriously hurt your case."),
        ("doc.text.fill",             "#AF52DE", "Many clinics ask you to pay upfront and reimburse later — always get an itemised receipt (factura)."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("FOR MEXICO SPECIFICALLY")
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
                        Text(tip.text)
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsLabel)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
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

// MARK: - Helpers
struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.custom("HelveticaNeue-Bold", size: 11))
            .foregroundColor(.tsSecondary)
            .tracking(1.2)
    }
}
