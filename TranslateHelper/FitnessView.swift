//  FitnessView.swift
//  TalkSwitch

import SwiftUI

// MARK: - Modes

private enum FitnessMode: String, CaseIterable {
    case gyms     = "Gyms"
    case studios  = "Studios"
    case outdoors = "Outdoors"
    case classes  = "Classes"
}

// MARK: - Main View

struct FitnessView: View {
    @State private var mode: FitnessMode = .gyms
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                ScrollView {
                    VStack(spacing: 0) {

                        KitSegmentedPicker(items: Array(FitnessMode.allCases), selection: $mode, scrollable: false) { $0.rawValue }
                            .padding(.bottom, 20)

                        Group {
                            switch mode {
                            case .gyms:     GymsSection(openURL: openURL)
                            case .studios:  StudiosSection(openURL: openURL)
                            case .outdoors: OutdoorsSection()
                            case .classes:  ClassesSection(openURL: openURL)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 96)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Fitness")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Gyms

private struct GymOption: Identifiable {
    let id = UUID()
    let name: String
    let tagline: String
    let detail: String
    let color: Color
    let badge: String?
    let price: String
    let url: String
}

private struct GymsSection: View {
    let openURL: OpenURLAction
    @State private var expanded: String? = nil

    let gyms: [GymOption] = [
        GymOption(
            name: "SmartFit",
            tagline: "Best value chain in LATAM — one membership, every country",
            detail: "Brazilian-founded gym chain with 1,000+ locations across Latin America — Mexico, Brazil, Chile, Colombia, Argentina, Peru and more. Your CDMX membership works at every one of them. No annual lock-in, month-to-month. Equipment is modern and well-maintained. No-frills, no spa, no fluff — just gym. Most locations open 5AM–11PM, some 24/7. Find locations and book classes in the SmartFit app.",
            color: Color(hex: "#FFD700"),
            badge: "BEST VALUE",
            price: "$599–799 MXN/mo (~$30–40 USD)",
            url: "https://apps.apple.com/mx/app/smartfit/id1163458465"
        ),
        GymOption(
            name: "Sport City",
            tagline: "Premium chain — pools, classes, squash courts",
            detail: "Mexico's premium gym chain. Full amenities: Olympic pool, sauna, squash courts, group classes included, towel service. Higher price point but significantly more than a bare gym. Multiple locations in Polanco, Santa Fe, Insurgentes. Popular with local professionals. Memberships require a contract — read the fine print on cancellation.",
            color: Color(hex: "#0055A5"),
            badge: "PREMIUM",
            price: "$1,200–1,800 MXN/mo (~$60–90 USD)",
            url: "https://www.sportcity.com.mx"
        ),
        GymOption(
            name: "Gimnasio Azteca",
            tagline: "Old-school Mexican gym — cheap, no-frills, effective",
            detail: "Traditional Mexican gym with locations throughout the city. Cash memberships, no apps, no booking, no fuss. Showing up before 8AM means you'll have it mostly to yourself. Equipment is older but functional. Great for anyone who just wants barbells and benches without the crowd of the bigger chains. Look for local branches in your colonia.",
            color: Color(hex: "#CC0000"),
            badge: nil,
            price: "$250–400 MXN/mo (~$13–20 USD)",
            url: "https://www.google.com/search?q=Gimnasio+Azteca+CDMX"
        ),
        GymOption(
            name: "Gold's Gym",
            tagline: "International brand, familiar equipment",
            detail: "Several locations in CDMX — most prominently in Perisur and Interlomas. Same equipment standard as the US. Slightly more expensive than SmartFit but well-run. Group classes included. Good option if you want consistency and have a car — branches tend to be in commercial areas rather than walkable colonias.",
            color: Color(hex: "#1C1C1E"),
            badge: nil,
            price: "$900–1,200 MXN/mo (~$45–60 USD)",
            url: "https://www.goldsgym.com.mx"
        ),
    ]

    var body: some View {
        VStack(spacing: 12) {

            // SmartFit spotlight card
            FitnessInfoCard(
                icon: "dumbbell.fill",
                color: Color(hex: "#FFD700"),
                title: "SmartFit is the move for most nomads",
                bodyText: "Month-to-month, $30–40 USD, and your membership works at every SmartFit across Latin America. If you move between cities or countries, this is the only gym membership that moves with you."
            )

            FitnessSectionLabel(title: "GYM CHAINS IN CDMX")
            VStack(spacing: 0) {
                ForEach(gyms) { gym in
                    GymCard(gym: gym, isExpanded: expanded == gym.name, openURL: openURL) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            expanded = expanded == gym.name ? nil : gym.name
                        }
                    }
                    if gym.id != gyms.last?.id {
                        Divider().padding(.leading, 16)
                    }
                }
            }
            .background(Color.tsCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))

            FitnessInfoCard(
                icon: "info.circle.fill",
                color: Color.tsAccent,
                title: "Day passes",
                bodyText: "Most chains sell single-day passes at the front desk — SmartFit ~$80 MXN, Sport City ~$200 MXN. Useful before you commit to a membership or on travel days when you just need to move."
            )
        }
    }
}

private struct GymCard: View {
    let gym: GymOption
    let isExpanded: Bool
    let openURL: OpenURLAction
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(gym.color.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 18))
                            .foregroundColor(gym.color)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(gym.name)
                                .font(.custom("HelveticaNeue-Bold", size: 15))
                                .foregroundColor(.tsLabel)
                            if let badge = gym.badge {
                                Text(badge)
                                    .font(.custom("HelveticaNeue-Bold", size: 9))
                                    .foregroundColor(Color(hex: "#34C759"))
                                    .padding(.horizontal, 5).padding(.vertical, 2)
                                    .background(Color(hex: "#34C759").opacity(0.12))
                                    .cornerRadius(4)
                            }
                        }
                        Text(gym.tagline)
                            .font(.custom("HelveticaNeue", size: 12))
                            .foregroundColor(.tsSecondary)
                        Text(gym.price)
                            .font(.custom("HelveticaNeue-Medium", size: 11))
                            .foregroundColor(.tsAccent)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.tsSecondary.opacity(0.5))
                }
                .padding(14)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider().background(Color.tsAccent.opacity(0.08))
                    Text(gym.detail)
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.tsSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Button(action: { if let url = URL(string: gym.url) { openURL(url) } }) {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 12))
                            Text(gym.url.contains("apps.apple") ? "Download app" : "Visit website")
                                .font(.custom("HelveticaNeue-Medium", size: 13))
                        }
                        .foregroundColor(.tsAccent)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 14).padding(.bottom, 14)
            }
        }
    }
}

// MARK: - Studios

private struct StudiosSection: View {
    let openURL: OpenURLAction

    var body: some View {
        VStack(spacing: 12) {

            FitnessInfoCard(
                icon: "figure.yoga",
                color: Color(hex: "#AF52DE"),
                title: "Boutique studios are everywhere in Roma & Condesa",
                bodyText: "Drop-in culture is strong. Most studios sell class packs rather than monthly memberships — 10-class packs are the norm. Expect $120–250 MXN per class at boutique studios; cheaper at independent gyms."
            )

            FitnessSectionLabel(title: "WHAT'S AVAILABLE")
            VStack(spacing: 0) {
                FitnessTipRow(icon: "figure.yoga", color: Color(hex: "#AF52DE"),
                    title: "Yoga",
                    detail: "Strong presence across the city. Studios like FlexYoga (Condesa), Yoga Loft (Polanco), and Namasté (Roma Norte) offer English classes. Drop-in $120–180 MXN. 10-class packs bring it under $100 MXN/class.")
                Divider().padding(.leading, 50)
                FitnessTipRow(icon: "figure.pilates", color: Color(hex: "#FF2D55"),
                    title: "Pilates",
                    detail: "Reformer pilates is expensive everywhere — CDMX is no exception. Expect $350–600 MXN per reformer session. Mat pilates is significantly cheaper at $150–200 MXN. Several dedicated Pilates studios in Polanco and Lomas.")
                Divider().padding(.leading, 50)
                FitnessTipRow(icon: "figure.highintensity.intervaltraining", color: Color(hex: "#FF6B00"),
                    title: "CrossFit & Functional",
                    detail: "CDMX has a large CrossFit community. Most boxes charge $900–1,200 MXN/month with unlimited classes. Quality varies significantly — visit and do a free trial class before committing. Many boxes post WODs on Instagram.")
                Divider().padding(.leading, 50)
                FitnessTipRow(icon: "figure.martial.arts", color: Color(hex: "#FFD700"),
                    title: "Martial Arts & Boxing",
                    detail: "Traditional gyms for boxing, Muay Thai, BJJ, and MMA are scattered across the city. Often excellent value — $400–700 MXN/month for unlimited classes. Mexican boxing culture is strong; the coaches are often world-class.")
                Divider().padding(.leading, 50)
                FitnessTipRow(icon: "figure.dance", color: Color(hex: "#34C759"),
                    title: "Dance & Barre",
                    detail: "Salsa, cumbia, and bachata classes are easy to find, cheap, and genuinely useful for socialising. Bachata classes run $80–150 MXN/drop-in. Barre studios have grown fast in Roma Norte — similar pricing to Pilates mat classes.")
            }
            .background(Color.tsCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))

            FitnessInfoCard(
                icon: "lightbulb.fill",
                color: Color(hex: "#FFD700"),
                title: "How to find the right studio",
                bodyText: "Search the studio name on Instagram — CDMX studios post their schedule, pricing, and vibe there. Most are responsive to DMs. For yoga, the Wandr Locals Use section has community-vetted recommendations."
            )
        }
    }
}

// MARK: - Outdoors

private struct OutdoorsSection: View {
    var body: some View {
        VStack(spacing: 12) {

            FitnessInfoCard(
                icon: "tree.fill",
                color: Color(hex: "#34C759"),
                title: "CDMX has world-class outdoor workout infrastructure",
                bodyText: "The city has invested heavily in public parks and free outdoor fitness equipment. Most large parks have a designated workout area with pull-up bars, parallel bars, and cardio machines — and they're genuinely well-maintained."
            )

            FitnessSectionLabel(title: "BEST SPOTS")
            VStack(spacing: 0) {
                FitnessTipRow(icon: "figure.run", color: Color(hex: "#34C759"),
                    title: "Bosque de Chapultepec",
                    detail: "The city's lungs — 686 hectares of forest 5 minutes from Roma Norte. Main circuit is ~4km, lakeside paths extend further. Packed on weekend mornings, quieter on weekdays. Free outdoor gym equipment in Section 1. Street vendors selling fresh juice and fruit at every 500m. One of the best places to run in any city, anywhere.")
                Divider().padding(.leading, 50)
                FitnessTipRow(icon: "figure.walk", color: Color(hex: "#30B0C7"),
                    title: "Parque México (Hipódromo Condesa)",
                    detail: "Beautiful art deco park in the heart of Condesa. Oval walking/running track around the perimeter, outdoor pull-up bars and parallel bars in the fitness area. More social than Chapultepec — runners, dog walkers, people reading on benches. Good for morning runs before the humidity peaks.")
                Divider().padding(.leading, 50)
                FitnessTipRow(icon: "bicycle", color: Color(hex: "#FF9500"),
                    title: "Ecobici — city bike share",
                    detail: "350+ stations across the city. Annual pass ~$500 MXN (~$25 USD) — unlimited 45-minute rides. First 30 minutes free per trip. Best cycling: Paseo de la Reforma has a dedicated bike lane all the way to Chapultepec. Parque Hundido loop is popular with weekend cyclists. Download the Ecobici app.")
                Divider().padding(.leading, 50)
                FitnessTipRow(icon: "sportscourt.fill", color: Color(hex: "#5856D6"),
                    title: "Deportivos (public sports centres)",
                    detail: "Every delegación (borough) has at least one Deportivo — public sports centres with basketball courts, football pitches, athletics tracks, and often a pool. Open to anyone, often free or under $30 MXN entry. Look up 'Deportivo + your colonia name' for your nearest one.")
                Divider().padding(.leading, 50)
                FitnessTipRow(icon: "sun.max.fill", color: Color(hex: "#FF6B00"),
                    title: "Parque Hundido",
                    detail: "Large park in Narvarte with a running circuit and outdoor gym. Popular with the local expat community on weekend mornings. Less touristy than Parque México, more neighborhood feel. Easy Metrobús access from Insurgentes.")
            }
            .background(Color.tsCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))

            FitnessInfoCard(
                icon: "cloud.drizzle.fill",
                color: Color.tsAccent,
                title: "Weather note",
                bodyText: "CDMX sits at 2,240m altitude. If you're coming from sea level, expect to feel winded for the first 1–2 weeks — totally normal. Rainy season (May–October) means daily afternoon showers, so plan outdoor workouts for mornings. Air quality varies — check AIRE CDMX app before long outdoor runs."
            )
        }
    }
}

// MARK: - Classes & Apps

private struct ClassesSection: View {
    let openURL: OpenURLAction

    var body: some View {
        VStack(spacing: 12) {

            FitnessInfoCard(
                icon: "calendar",
                color: Color(hex: "#AF52DE"),
                title: "Drop-in culture, not membership culture",
                bodyText: "Most CDMX studios prefer selling class packs over monthly memberships. This works in your favour — no lock-in, try multiple studios, and stop paying when you travel. 10-class packs typically have a 2–3 month expiry."
            )

            FitnessSectionLabel(title: "BOOKING APPS & PLATFORMS")
            VStack(spacing: 0) {
                FitnessTipRow(icon: "apps.iphone", color: Color(hex: "#FF6B00"),
                    title: "Fitmapp",
                    detail: "Mexico's most popular fitness class booking platform — equivalent to Mindbody but local. Lists classes for yoga, pilates, CrossFit, boxing, dance, barre across CDMX. You can buy class packs directly. Filter by colonia, studio, or instructor. Most mid-range studios are on here.")
                Divider().padding(.leading, 50)
                FitnessTipRow(icon: "star.fill", color: Color(hex: "#FFD700"),
                    title: "SmartFit App",
                    detail: "Essential if you have a SmartFit membership. Find the nearest location, book group classes (spinning, functional training, kickboxing), check opening hours. Class booking spots go fast for popular time slots — book the night before.")
                Divider().padding(.leading, 50)
                FitnessTipRow(icon: "person.2.fill", color: Color(hex: "#17C2E1"),
                    title: "Locals Use — Personal Trainers",
                    detail: "The Wandr community recommends personal trainers directly. Community-vetted, first-person reviews, WhatsApp contact built in. If you want a trainer rather than a class, that's where to look — community recs are far more reliable than Google Reviews in this context.")
                Divider().padding(.leading, 50)
                FitnessTipRow(icon: "globe", color: Color.tsAccent,
                    title: "Instagram",
                    detail: "Genuinely the best discovery tool for boutique studios in CDMX. Studios post their schedule, instructor bios, and pricing in Stories. Search your colonia + yoga/pilates/CrossFit. Most will respond to DMs with a trial class offer.")
            }
            .background(Color.tsCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))

            FitnessSectionLabel(title: "PRICING REFERENCE")
            VStack(spacing: 0) {
                FitnessPriceRow(category: "SmartFit membership",   price: "$599–799 MXN/mo")
                Divider().padding(.leading, 16)
                FitnessPriceRow(category: "Sport City membership",  price: "$1,200–1,800 MXN/mo")
                Divider().padding(.leading, 16)
                FitnessPriceRow(category: "Boutique yoga / drop-in",price: "$120–200 MXN/class")
                Divider().padding(.leading, 16)
                FitnessPriceRow(category: "Personal trainer / hour", price: "$350–700 MXN/hr")
                Divider().padding(.leading, 16)
                FitnessPriceRow(category: "Reformer pilates",        price: "$350–600 MXN/session")
                Divider().padding(.leading, 16)
                FitnessPriceRow(category: "CrossFit box monthly",    price: "$900–1,200 MXN/mo")
                Divider().padding(.leading, 16)
                FitnessPriceRow(category: "Ecobici annual pass",     price: "~$500 MXN/yr")
                Divider().padding(.leading, 16)
                FitnessPriceRow(category: "Public Deportivo entry",  price: "Free – $30 MXN")
            }
            .background(Color.tsCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
    }
}

// MARK: - Shared subviews

private struct FitnessInfoCard: View {
    let icon: String
    let color: Color
    let title: String
    let bodyText: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.custom("HelveticaNeue-Bold", size: 15))
                    .foregroundColor(.tsLabel)
                Text(bodyText)
                    .font(.custom("HelveticaNeue", size: 13))
                    .foregroundColor(.tsSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tsCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
    }
}

private struct FitnessSectionLabel: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.custom("HelveticaNeue-Bold", size: 11))
            .foregroundColor(.tsSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
    }
}

private struct FitnessTipRow: View {
    let icon: String
    let color: Color
    let title: String
    let detail: String
    @State private var expanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() } }) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: icon)
                            .font(.system(size: 14))
                            .foregroundColor(color)
                    }
                    Text(title)
                        .font(.custom("HelveticaNeue-Medium", size: 14))
                        .foregroundColor(.tsLabel)
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.tsSecondary.opacity(0.5))
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            if expanded {
                Text(detail)
                    .font(.custom("HelveticaNeue", size: 13))
                    .foregroundColor(.tsSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 64).padding(.trailing, 14).padding(.bottom, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private struct FitnessPriceRow: View {
    let category: String
    let price: String

    var body: some View {
        HStack {
            Text(category)
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.tsLabel)
            Spacer()
            Text(price)
                .font(.custom("HelveticaNeue-Medium", size: 13))
                .foregroundColor(.tsSecondary)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }
}
