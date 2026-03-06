//  LocalsUseView.swift
//  Wandr — crowdsourced local service recs

import SwiftUI

// MARK: - Subcategories

enum RecSubcategory: String, Hashable, Identifiable {
    // Health
    case dentistry    = "Dentistry"
    case dermatology  = "Dermatology"
    case mentalHealth = "Mental Health"
    case generalDoc   = "General Doctor"
    case physio       = "Physiotherapy"
    case nutrition    = "Nutrition"
    // Beauty
    case hair         = "Hair & Color"
    case nails        = "Nails"
    case spa          = "Spa & Massage"
    case botox        = "Botox & Fillers"
    case waxing       = "Waxing"
    // Fitness
    case pt           = "Personal Training"
    case yoga         = "Yoga"
    case gym          = "Gym"
    case pilates      = "Pilates"
    case martialArts  = "Martial Arts"
    // Home
    case cleaning     = "Cleaning"
    case plumbing     = "Plumbing"
    case electrician  = "Electrician"
    case acRepair     = "AC & Heating"
    case gardening    = "Gardening"
    // Legal
    case immigration  = "Immigration"
    case notary       = "Notary"
    case bizLaw       = "Business Law"
    // Finance
    case accounting   = "Accounting"
    case tax          = "Tax"
    case banking      = "Banking"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dentistry:   return "mouth.fill"
        case .dermatology: return "face.smiling"
        case .mentalHealth:return "brain.head.profile"
        case .generalDoc:  return "stethoscope"
        case .physio:      return "figure.walk"
        case .nutrition:   return "leaf.fill"
        case .hair:        return "scissors"
        case .nails:       return "paintbrush.pointed.fill"
        case .spa:         return "sparkles"
        case .botox:       return "syringe.fill"
        case .waxing:      return "wind"
        case .pt:          return "figure.strengthtraining.traditional"
        case .yoga:        return "figure.mind.and.body"
        case .gym:         return "dumbbell.fill"
        case .pilates:     return "figure.core.training"
        case .martialArts: return "figure.martial.arts"
        case .cleaning:    return "bubbles.and.sparkles.fill"
        case .plumbing:    return "drop.fill"
        case .electrician: return "bolt.fill"
        case .acRepair:    return "thermometer.medium"
        case .gardening:   return "leaf"
        case .immigration: return "doc.text.fill"
        case .notary:      return "signature"
        case .bizLaw:      return "building.columns.fill"
        case .accounting:  return "chart.bar.fill"
        case .tax:         return "percent"
        case .banking:     return "banknote.fill"
        }
    }

    var color: Color {
        switch self {
        case .dentistry:    return Color(hex: "#0099FF")
        case .dermatology:  return Color(hex: "#FF2D55")
        case .mentalHealth: return Color(hex: "#AF52DE")
        case .generalDoc:   return Color(hex: "#FF3B30")
        case .physio:       return Color(hex: "#FF9500")
        case .nutrition:    return Color(hex: "#34C759")
        case .hair:         return Color(hex: "#FF2D55")
        case .nails:        return Color(hex: "#BF5AF2")
        case .spa:          return Color(hex: "#5AC8FA")
        case .botox:        return Color(hex: "#FF375F")
        case .waxing:       return Color(hex: "#FF9F0A")
        case .pt:           return Color(hex: "#FF9500")
        case .yoga:         return Color(hex: "#5AC8FA")
        case .gym:          return Color(hex: "#FF3B30")
        case .pilates:      return Color(hex: "#BF5AF2")
        case .martialArts:  return Color(hex: "#FF453A")
        case .cleaning:     return Color(hex: "#0099FF")
        case .plumbing:     return Color(hex: "#30B0C7")
        case .electrician:  return Color(hex: "#FFD60A")
        case .acRepair:     return Color(hex: "#5AC8FA")
        case .gardening:    return Color(hex: "#30D158")
        case .immigration:  return Color(hex: "#5E5CE6")
        case .notary:       return Color(hex: "#BF5AF2")
        case .bizLaw:       return Color(hex: "#0A84FF")
        case .accounting:   return Color(hex: "#30D158")
        case .tax:          return Color(hex: "#FF9F0A")
        case .banking:      return Color(hex: "#34C759")
        }
    }

    var emoji: String {
        switch self {
        case .dentistry:    return "🦷"
        case .dermatology:  return "✨"
        case .mentalHealth: return "🧠"
        case .generalDoc:   return "🩺"
        case .physio:       return "🦵"
        case .nutrition:    return "🥗"
        case .hair:         return "✂️"
        case .nails:        return "💅"
        case .spa:          return "💆"
        case .botox:        return "💉"
        case .waxing:       return "🪒"
        case .pt:           return "💪"
        case .yoga:         return "🧘"
        case .gym:          return "🏋️"
        case .pilates:      return "🤸"
        case .martialArts:  return "🥋"
        case .cleaning:     return "🧹"
        case .plumbing:     return "🔧"
        case .electrician:  return "⚡️"
        case .acRepair:     return "❄️"
        case .gardening:    return "🌿"
        case .immigration:  return "🛂"
        case .notary:       return "📝"
        case .bizLaw:       return "⚖️"
        case .accounting:   return "📊"
        case .tax:          return "🧾"
        case .banking:      return "🏦"
        }
    }
}

// MARK: - Category

enum RecCategory: String, CaseIterable, Identifiable {
    case all      = "All"
    case health   = "Health"
    case beauty   = "Beauty"
    case fitness  = "Fitness"
    case home     = "Home"
    case legal    = "Legal"
    case finance  = "Finance"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all:     return "square.grid.2x2"
        case .health:  return "cross.case.fill"
        case .beauty:  return "sparkles"
        case .fitness: return "figure.run"
        case .home:    return "house.fill"
        case .legal:   return "building.columns.fill"
        case .finance: return "chart.line.uptrend.xyaxis"
        }
    }

    var color: Color {
        switch self {
        case .all:     return .tsAccent
        case .health:  return Color(hex: "#FF3B30")
        case .beauty:  return Color(hex: "#FF2D55")
        case .fitness: return Color(hex: "#34C759")
        case .home:    return Color(hex: "#FF9500")
        case .legal:   return Color(hex: "#5856D6")
        case .finance: return Color(hex: "#30B0C7")
        }
    }

    var emoji: String {
        switch self {
        case .all:     return "⭐️"
        case .health:  return "🏥"
        case .beauty:  return "💄"
        case .fitness: return "🏃"
        case .home:    return "🏠"
        case .legal:   return "⚖️"
        case .finance: return "💰"
        }
    }

    var subcategories: [RecSubcategory] {
        switch self {
        case .all:     return []
        case .health:  return [.dentistry, .dermatology, .mentalHealth, .generalDoc, .physio, .nutrition]
        case .beauty:  return [.hair, .nails, .spa, .botox, .waxing]
        case .fitness: return [.pt, .yoga, .gym, .pilates, .martialArts]
        case .home:    return [.cleaning, .plumbing, .electrician, .acRepair, .gardening]
        case .legal:   return [.immigration, .notary, .bizLaw]
        case .finance: return [.accounting, .tax, .banking]
        }
    }
}

// MARK: - Price

enum PriceTier: String, CaseIterable {
    case budget  = "budget"
    case mid     = "mid"
    case premium = "premium"

    var symbol: String {
        switch self { case .budget: return "$"; case .mid: return "$$"; case .premium: return "$$$" }
    }
    var label: String {
        switch self { case .budget: return "Budget"; case .mid: return "Mid-range"; case .premium: return "Premium" }
    }
}

// MARK: - Models

struct RecRecommender {
    let name: String
    let initials: String
    let trustLevel: TrustLevel
    let monthsInCity: Int

    var tenure: String {
        monthsInCity >= 12 ? "\(monthsInCity / 12)y in CDMX" : "\(monthsInCity)mo in CDMX"
    }
}

struct LocalRec: Identifiable {
    let id           = UUID()
    let businessName:  String
    let category:      RecCategory
    let subcategory:   RecSubcategory?
    let description:   String
    let testimonial:   String
    let price:         PriceTier
    let neighbourhood: String
    let tags:          [String]
    let recommender:   RecRecommender
    var endorsements:  Int
    var website:       String?
    var instagram:     String?  = nil    // handle without @
    var englishSpeaking: Bool?   = nil    // nil = not specified
}

// MARK: - Seed Data

private let seedRecs: [LocalRec] = [
    LocalRec(
        businessName: "Dr. Alejandro Reyes",
        category: .health, subcategory: .dentistry,
        description: "General dentistry & implants · Condesa",
        testimonial: "Saved me $2,400 on two implants vs what I was quoted back home. English-speaking, clean, modern clinic. Gets booked up fast — message ahead.",
        price: .mid, neighbourhood: "Condesa",
        tags: ["English-friendly", "Implants", "Walk-in OK"],
        recommender: RecRecommender(name: "Sarah M.", initials: "SM", trustLevel: .trustedLocal, monthsInCity: 18),
        endorsements: 14, website: nil
    ),
    LocalRec(
        businessName: "Fernanda Orozco",
        category: .fitness, subcategory: .pt,
        description: "NASM-certified PT · trains outdoors & at your gym",
        testimonial: "Best trainer I've had in any city. She speaks English, adapts to your level, and actually shows up on time — which in CDMX is saying something. ~$35/session.",
        price: .mid, neighbourhood: "Roma Norte",
        tags: ["English-friendly", "Outdoor sessions", "Nutrition coaching"],
        recommender: RecRecommender(name: "Jake T.", initials: "JT", trustLevel: .local, monthsInCity: 9),
        endorsements: 11, website: nil
    ),
    LocalRec(
        businessName: "Limpia Total",
        category: .home, subcategory: .cleaning,
        description: "Weekly & deep-clean service trusted by expats",
        testimonial: "Maria and her team have been cleaning my apartment for 8 months. Super reliable, thorough, totally fair. About $25 for a 1BR deep clean.",
        price: .budget, neighbourhood: "Juárez",
        tags: ["Weekly available", "Deep clean", "Key-holder trusted"],
        recommender: RecRecommender(name: "Priya K.", initials: "PK", trustLevel: .trustedLocal, monthsInCity: 22),
        endorsements: 19, website: nil
    ),
    LocalRec(
        businessName: "Diego Hernández",
        category: .legal, subcategory: .immigration,
        description: "Residency, visas & apostilles · Polanco",
        testimonial: "Got my temporary residency done in 6 weeks flat. Diego was transparent about costs upfront — no hidden fees. Worth every peso. Fluent in English.",
        price: .mid, neighbourhood: "Polanco",
        tags: ["English-speaking", "Residency", "Apostilles"],
        recommender: RecRecommender(name: "Carlos R.", initials: "CR", trustLevel: .cityExpert, monthsInCity: 36),
        endorsements: 23, website: "diegohernandez.mx"
    ),
    LocalRec(
        businessName: "Studio Bloom",
        category: .beauty, subcategory: .hair,
        description: "Balayage, cuts & colour · Roma Norte",
        testimonial: "Finally found a colorist who gets fine hair. Lucia did exactly what I asked for — and charged me 60% less than I'd pay in NYC. Book online, she fills up.",
        price: .mid, neighbourhood: "Roma Norte",
        tags: ["Colour specialist", "Fine hair", "Online booking"],
        recommender: RecRecommender(name: "Emma L.", initials: "EL", trustLevel: .settling, monthsInCity: 4),
        endorsements: 8, website: "studiobloom.mx"
    ),
    LocalRec(
        businessName: "Clínica Derma MX",
        category: .health, subcategory: .dermatology,
        description: "Dermatology, Botox & skincare treatments · Polanco",
        testimonial: "Botox was $180 USD all-in, same product I get at home for $550. Dr. Vargas is meticulous. Clinic is spotless. Bring a photo of what you want.",
        price: .mid, neighbourhood: "Polanco",
        tags: ["Botox", "Fillers", "English-friendly"],
        recommender: RecRecommender(name: "Tara S.", initials: "TS", trustLevel: .local, monthsInCity: 11),
        endorsements: 17, website: "clinicadermamx.com"
    ),
    LocalRec(
        businessName: "Roberto Solís",
        category: .home, subcategory: .plumbing,
        description: "Reliable plumber, same-day in most colonias",
        testimonial: "Fixed a leak my landlord had been ignoring for months. Showed up in 2 hours, charged $400 MXN and was done in 45 min. Saved his number immediately.",
        price: .budget, neighbourhood: "Narvarte",
        tags: ["Same-day", "Leak repair", "Water heater"],
        recommender: RecRecommender(name: "Ben A.", initials: "BA", trustLevel: .settling, monthsInCity: 5),
        endorsements: 6, website: nil
    ),
    LocalRec(
        businessName: "Paz Contadores",
        category: .finance, subcategory: .accounting,
        description: "Tax, RFC registration & expat finances",
        testimonial: "Handled my RFC setup and monthly taxes as a freelancer. Everything done remotely, very organised, explains everything in plain English. ~$80/mo.",
        price: .mid, neighbourhood: "Cuauhtémoc",
        tags: ["RFC setup", "Freelancer-friendly", "Remote"],
        recommender: RecRecommender(name: "Mia C.", initials: "MC", trustLevel: .trustedLocal, monthsInCity: 14),
        endorsements: 12, website: "pazcontadores.mx"
    ),
    LocalRec(
        businessName: "FlexYoga CDMX",
        category: .fitness, subcategory: .yoga,
        description: "Drop-in yoga, English & Spanish classes",
        testimonial: "Best yoga community in the city. Drop-in is $120 MXN, packs are cheaper. Morning classes fill up — book the night before on their app.",
        price: .budget, neighbourhood: "Condesa",
        tags: ["Drop-in", "English classes", "Community vibe"],
        recommender: RecRecommender(name: "Ana P.", initials: "AP", trustLevel: .local, monthsInCity: 8),
        endorsements: 9, website: "flexyogacdmx.com"
    ),
]

// MARK: - Main View

struct LocalsUseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory:    RecCategory    = .all
    @State private var selectedSubcategory: RecSubcategory? = nil
    @State private var searchText  = ""
    @State private var showAddRec  = false
    @State private var recs        = seedRecs

    var filtered: [LocalRec] {
        recs.filter { rec in
            let catMatch  = selectedCategory == .all || rec.category == selectedCategory
            let subMatch  = selectedSubcategory == nil || rec.subcategory == selectedSubcategory
            let txtMatch  = searchText.isEmpty
                || rec.businessName.localizedCaseInsensitiveContains(searchText)
                || rec.description.localizedCaseInsensitiveContains(searchText)
                || rec.neighbourhood.localizedCaseInsensitiveContains(searchText)
                || rec.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            return catMatch && subMatch && txtMatch
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                TSGradientBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        // ── Search ────────────────────────────────────
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14))
                                .foregroundColor(.tsSecondary)
                            TextField("Search by name, type or area…", text: $searchText)
                                .font(.custom("HelveticaNeue", size: 15))
                                .foregroundColor(.tsLabel)
                            if !searchText.isEmpty {
                                Button { searchText = "" } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.tsSecondary)
                                }
                            }
                        }
                        .padding(.horizontal, 14).padding(.vertical, 11)
                        .background(Color.tsInputBg)
                        .cornerRadius(12)
                        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 12)

                        // ── Category pills (simple stroke style) ──────
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(RecCategory.allCases) { cat in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                            selectedCategory    = cat
                                            selectedSubcategory = nil
                                        }
                                    }) {
                                        HStack(spacing: 5) {
                                            Image(systemName: cat.icon)
                                                .font(.system(size: 11, weight: .medium))
                                            Text(cat.rawValue)
                                                .font(.custom("HelveticaNeue-Medium", size: 14))
                                        }
                                        .foregroundColor(selectedCategory == cat ? .white : .tsLabel)
                                        .padding(.horizontal, 14).padding(.vertical, 8)
                                        .background(selectedCategory == cat ? Color.tsAccent : Color.tsCard)
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 8)

                        // ── Subcategory pills (appear when category selected) ─
                        if selectedCategory != .all && !selectedCategory.subcategories.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    // "All [Category]" reset pill
                                    Button(action: {
                                        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                            selectedSubcategory = nil
                                        }
                                    }) {
                                        Text("All \(selectedCategory.rawValue)")
                                            .font(.custom("HelveticaNeue-Medium", size: 12))
                                            .foregroundColor(selectedSubcategory == nil ? .tsAccent : .tsSecondary)
                                            .padding(.horizontal, 12).padding(.vertical, 6)
                                            .background(Color.tsAccent.opacity(0.08))
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(
                                                selectedSubcategory == nil ? Color.tsAccent : Color.clear,
                                                lineWidth: 1.5
                                            ))
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    ForEach(selectedCategory.subcategories) { sub in
                                        Button(action: {
                                            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                                selectedSubcategory = selectedSubcategory == sub ? nil : sub
                                            }
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: sub.icon)
                                                    .font(.system(size: 10, weight: .medium))
                                                Text(sub.rawValue)
                                                .font(.custom("HelveticaNeue-Medium", size: 12))
                                            }
                                            .foregroundColor(selectedSubcategory == sub ? .tsAccent : .tsSecondary)
                                            .padding(.horizontal, 12).padding(.vertical, 6)
                                            .background(Color.tsAccent.opacity(0.08))
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(
                                                selectedSubcategory == sub ? Color.tsAccent : Color.clear,
                                                lineWidth: 1.5
                                            ))
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 16).padding(.vertical, 3)
                            }
                            .padding(.bottom, 12)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // ── Count ─────────────────────────────────────
                        if !searchText.isEmpty || selectedCategory != .all {
                            Text("\(filtered.count) rec\(filtered.count == 1 ? "" : "s")")
                                .font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(.tsSecondary)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 8)
                        }

                        // ── Cards ─────────────────────────────────────
                        if filtered.isEmpty {
                            VStack(spacing: 12) {
                                Text("🔍").font(.system(size: 40))
                                Text("Nothing here yet")
                                    .font(.custom("HelveticaNeue-Medium", size: 16))
                                    .foregroundColor(.tsLabel)
                                Text("Be the first to add a rec.")
                                    .font(.custom("HelveticaNeue", size: 14))
                                    .foregroundColor(.tsSecondary)
                                Button(action: { showAddRec = true }) {
                                    Text("Add a rec")
                                        .font(.custom("HelveticaNeue-Medium", size: 15))
                                        .foregroundColor(.tsAccent)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filtered) { rec in
                                    LocalRecCard(rec: rec) { id in
                                        if let i = recs.firstIndex(where: { $0.id == id }) {
                                            recs[i].endorsements += 1
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        Spacer(minLength: 100)
                    }
                }

                // ── FAB — circle plus only ────────────────────────────
                Button(action: { showAddRec = true }) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color(hex: "#3B99FC"), Color(hex: "#007AFF")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.tsAccent.opacity(0.4), radius: 12, x: 0, y: 4)
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 24)
            }
            .navigationTitle("Locals Use")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .font(.custom("HelveticaNeue-Medium", size: 16))
                        .foregroundColor(.tsAccent)
                }
            }
        }
        .sheet(isPresented: $showAddRec) {
            AddRecSheet { newRec in
                withAnimation { recs.insert(newRec, at: 0) }
            }
        }
    }
}

// MARK: - Rec Card

struct LocalRecCard: View {
    let rec: LocalRec
    let onEndorse: (UUID) -> Void
    @State private var endorsed = false
    @Environment(\.openURL) private var openURL

    private var accentColor: Color { rec.subcategory?.color ?? rec.category.color }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ────────────────────────────────────────────────
            HStack(alignment: .top, spacing: 14) {
                // Icon — My Decks style: colored SF symbol in rounded rect
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(accentColor.opacity(0.12))
                        .frame(width: 52, height: 52)
                    Text(rec.subcategory?.emoji ?? rec.category.emoji)
                        .font(.system(size: 26))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(rec.businessName)
                        .font(.custom("HelveticaNeue-Bold", size: 16))
                        .foregroundColor(.tsLabel)
                    Text(rec.description)
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(.tsSecondary)
                        .lineLimit(2)
                }
                Spacer()
                // Price — dollar signs, not emoji
                VStack(alignment: .trailing, spacing: 2) {
                    Text(rec.price.symbol)
                        .font(.custom("HelveticaNeue-Medium", size: 13))
                        .foregroundColor(accentColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 14)

            // ── Testimonial ───────────────────────────────────────────
            Text("\u{201C}\(rec.testimonial)\u{201D}")
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.tsLabel)
                .lineSpacing(4)
                .padding(.horizontal, 16)
                .padding(.bottom, 14)

            // ── Website + Instagram ───────────────────────────────────
            let hasLinks = (rec.website != nil && !rec.website!.isEmpty) || (rec.instagram != nil && !rec.instagram!.isEmpty)
            if hasLinks {
                HStack(spacing: 14) {
                    if let site = rec.website, !site.isEmpty {
                        Button(action: { if let url = URL(string: "https://\(site)") { openURL(url) } }) {
                            HStack(spacing: 4) {
                                Image(systemName: "globe").font(.system(size: 11))
                                Text(site).font(.custom("HelveticaNeue", size: 12))
                            }
                            .foregroundColor(.tsAccent)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    if let ig = rec.instagram, !ig.isEmpty {
                        Button(action: {
                            if let url = URL(string: "https://instagram.com/\(ig)") { openURL(url) }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "camera").font(.system(size: 11))
                                Text("@\(ig)").font(.custom("HelveticaNeue", size: 12))
                            }
                            .foregroundColor(Color(hex: "#E1306C"))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }

            // ── English badge ─────────────────────────────────────────
            if rec.englishSpeaking == true {
                HStack(spacing: 4) {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 10))
                    Text("Speaks English")
                        .font(.custom("HelveticaNeue-Medium", size: 11))
                }
                .foregroundColor(Color(hex: "#34C759"))
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Color(hex: "#34C759").opacity(0.10))
                .clipShape(Capsule())
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }

            // ── Tags — white background ───────────────────────────────
            if !rec.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(rec.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.custom("HelveticaNeue", size: 11))
                                .foregroundColor(.tsSecondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color(UIColor.systemBackground))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.tsBorder.opacity(0.6), lineWidth: 0.5))
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 14)
            }

            Divider().background(Color.tsBorder).padding(.horizontal, 16)

            // ── Footer ────────────────────────────────────────────────
            HStack(spacing: 10) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(rec.recommender.trustLevel.color.opacity(0.15))
                        .frame(width: 30, height: 30)
                    Text(rec.recommender.initials)
                        .font(.custom("HelveticaNeue-Bold", size: 10))
                        .foregroundColor(rec.recommender.trustLevel.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(rec.recommender.name)
                        .font(.custom("HelveticaNeue-Medium", size: 12))
                        .foregroundColor(.tsLabel)
                    HStack(spacing: 4) {
                        TrustBadge(level: rec.recommender.trustLevel, compact: true)
                        Text("·")
                            .font(.system(size: 10))
                            .foregroundColor(.tsSecondary)
                        Text(rec.recommender.tenure)
                            .font(.custom("HelveticaNeue", size: 11))
                            .foregroundColor(.tsSecondary)
                        Text("·")
                            .font(.system(size: 10))
                            .foregroundColor(.tsSecondary)
                        Image(systemName: "mappin")
                            .font(.system(size: 10))
                            .foregroundColor(.tsSecondary)
                        Text(rec.neighbourhood)
                            .font(.custom("HelveticaNeue", size: 11))
                            .foregroundColor(.tsSecondary)
                    }
                }

                Spacer()

                // Endorse
                Button(action: {
                    guard !endorsed else { return }
                    endorsed = true
                    onEndorse(rec.id)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: endorsed ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .font(.system(size: 12))
                        Text("\(rec.endorsements + (endorsed ? 1 : 0))")
                            .font(.custom("HelveticaNeue-Medium", size: 12))
                    }
                    .foregroundColor(endorsed ? .tsAccent : .tsSecondary)
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(endorsed ? Color.tsAccent.opacity(0.10) : Color(UIColor.systemBackground))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(
                        endorsed ? Color.tsAccent.opacity(0.3) : Color.tsBorder.opacity(0.5),
                        lineWidth: 0.5
                    ))
                }
                .buttonStyle(PlainButtonStyle())
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: endorsed)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18)
            .stroke(Color(UIColor.separator).opacity(0.3), lineWidth: 0.5))
    }
}

// MARK: - Add Rec Sheet

struct AddRecSheet: View {
    let onSave: (LocalRec) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var businessName  = ""
    @State private var category: RecCategory = .health
    @State private var subcategory: RecSubcategory? = nil
    @State private var description   = ""
    @State private var testimonial   = ""
    @State private var price: PriceTier = .mid
    @State private var neighbourhood = ""
    @State private var tagsText      = ""
    @State private var website       = ""
    @State private var instagram     = ""
    @State private var englishAnswer = ""   // "Yes" / "No" / "Not sure" / ""

    private var isValid: Bool {
        !businessName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !testimonial.trimmingCharacters(in: .whitespaces).isEmpty &&
        testimonial.count <= 280
    }

    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // Business name
                        RecFormField(label: "Business or person") {
                            TextField("e.g. Dr. Martinez, Studio Bloom…", text: $businessName)
                                .font(.custom("HelveticaNeue", size: 16))
                                .foregroundColor(.tsLabel)
                        }

                        // Category — simple pill style
                        VStack(alignment: .leading, spacing: 8) {
                            RecFieldLabel("Category")
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(RecCategory.allCases.filter { $0 != .all }) { cat in
                                        Button(action: {
                                            category    = cat
                                            subcategory = nil
                                        }) {
                                            HStack(spacing: 5) {
                                                Image(systemName: cat.icon).font(.system(size: 11))
                                                Text(cat.rawValue).font(.custom("HelveticaNeue-Medium", size: 13))
                                            }
                                            .foregroundColor(category == cat ? Color(hex: "#0099FF") : .tsSecondary)
                                            .padding(.horizontal, 14).padding(.vertical, 8)
                                            .background(category == cat ? Color.tsAccent.opacity(0.08) : Color.tsCard)
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(
                                                category == cat ? Color.tsAccent : Color.tsBorder.opacity(0.5),
                                                lineWidth: category == cat ? 1.5 : 0.5
                                            ))
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }

                            // Subcategory row
                            if !category.subcategories.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 6) {
                                        ForEach(category.subcategories) { sub in
                                            Button(action: {
                                                subcategory = subcategory == sub ? nil : sub
                                            }) {
                                                HStack(spacing: 4) {
                                                    Image(systemName: sub.icon).font(.system(size: 10))
                                                    Text(sub.rawValue).font(.custom("HelveticaNeue", size: 12))
                                                }
                                                .foregroundColor(subcategory == sub ? category.color : .tsSecondary)
                                                .padding(.horizontal, 12).padding(.vertical, 6)
                                                .background(subcategory == sub ? category.color.opacity(0.10) : Color.tsCard)
                                                .clipShape(Capsule())
                                                .overlay(Capsule().stroke(
                                                    subcategory == sub ? category.color.opacity(0.5) : Color.tsBorder.opacity(0.4),
                                                    lineWidth: 0.5
                                                ))
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                        }

                        // One-liner
                        RecFormField(label: "One-liner (optional)") {
                            TextField("e.g. Dentist in Condesa, English-speaking", text: $description)
                                .font(.custom("HelveticaNeue", size: 16))
                                .foregroundColor(.tsLabel)
                        }

                        // Testimonial
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                RecFieldLabel("Your experience")
                                Spacer()
                                Text("\(testimonial.count)/280")
                                    .font(.custom("HelveticaNeue", size: 12))
                                    .foregroundColor(testimonial.count > 280 ? .red : .tsSecondary)
                            }
                            TextEditor(text: $testimonial)
                                .font(.custom("HelveticaNeue", size: 15))
                                .foregroundColor(.tsLabel)
                                .frame(minHeight: 100)
                                .padding(12)
                                .background(Color.tsInputBg)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12)
                                    .stroke(testimonial.count > 280 ? Color.red.opacity(0.5) : Color.tsBorder.opacity(0.5), lineWidth: 0.5))
                        }

                        // Price
                        VStack(alignment: .leading, spacing: 8) {
                            RecFieldLabel("Price range")
                            HStack(spacing: 8) {
                                ForEach(PriceTier.allCases, id: \.rawValue) { tier in
                                    Button(action: { price = tier }) {
                                        VStack(spacing: 2) {
                                            Text(tier.symbol)
                                                .font(.custom("HelveticaNeue-Bold", size: 15))
                                                .foregroundColor(price == tier ? .tsAccent : .tsLabel)
                                            Text(tier.label)
                                                .font(.custom("HelveticaNeue", size: 10))
                                                .foregroundColor(price == tier ? .tsAccent : .tsSecondary)
                                        }
                                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                                        .background(price == tier ? Color.tsAccent.opacity(0.08) : Color.tsCard)
                                        .cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10)
                                            .stroke(price == tier ? Color.tsAccent : Color.tsBorder.opacity(0.4),
                                                    lineWidth: price == tier ? 1.5 : 0.5))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }

                        // Neighbourhood
                        RecFormField(label: "Neighbourhood") {
                            TextField("e.g. Roma Norte, Polanco…", text: $neighbourhood)
                                .font(.custom("HelveticaNeue", size: 16))
                                .foregroundColor(.tsLabel)
                        }

                        // Website
                        RecFormField(label: "Website (optional)") {
                            TextField("e.g. example.com", text: $website)
                                .font(.custom("HelveticaNeue", size: 16))
                                .foregroundColor(.tsLabel)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }

                        // Instagram
                        RecFormField(label: "Instagram handle (optional)") {
                            HStack(spacing: 8) {
                                Text("@")
                                    .font(.custom("HelveticaNeue-Medium", size: 16))
                                    .foregroundColor(.tsSecondary)
                                TextField("their_handle", text: $instagram)
                                    .font(.custom("HelveticaNeue", size: 16))
                                    .foregroundColor(.tsLabel)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            }
                        }

                        // English speaking
                        VStack(alignment: .leading, spacing: 10) {
                            RecFieldLabel("Do they speak English? (optional)")
                            HStack(spacing: 10) {
                                ForEach(["Yes", "No", "Not sure"], id: \.self) { opt in
                                    Button(action: {
                                        if englishAnswer == opt { englishAnswer = "" }
                                        else { englishAnswer = opt }
                                    }) {
                                        Text(opt)
                                                .font(.custom("HelveticaNeue-Medium", size: 14))
                                            .foregroundColor(englishAnswer == opt ? .white : .tsLabel)
                                            .frame(maxWidth: .infinity).padding(.vertical, 10)
                                            .background(englishAnswer == opt ? Color.tsAccent : Color.tsCard)
                                            .cornerRadius(10)
                                            .overlay(RoundedRectangle(cornerRadius: 10)
                                                .stroke(englishAnswer == opt ? Color.tsAccent : Color.tsBorder.opacity(0.4),
                                                        lineWidth: englishAnswer == opt ? 0 : 0.5))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }

                        // Tags
                        RecFormField(label: "Tags, comma separated (optional)") {
                            TextField("e.g. English-friendly, Walk-in OK", text: $tagsText)
                                .font(.custom("HelveticaNeue", size: 16))
                                .foregroundColor(.tsLabel)
                        }

                        // Save
                        Button(action: save) {
                            Text("Share rec")
                                .font(.custom("HelveticaNeue-Bold", size: 17))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity).frame(height: 52)
                                .background(
                                    isValid
                                        ? AnyShapeStyle(LinearGradient(
                                            colors: [Color(hex: "#3B99FC"), Color(hex: "#007AFF")],
                                            startPoint: .topLeading, endPoint: .bottomTrailing))
                                        : AnyShapeStyle(Color.tsSecondary.opacity(0.3))
                                )
                                .clipShape(Capsule())
                        }
                        .disabled(!isValid)
                        .padding(.top, 8)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Add a rec")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.custom("HelveticaNeue", size: 16))
                        .foregroundColor(.tsAccent)
                }
            }
        }
    }

    private func save() {
        let tags = tagsText.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let newRec = LocalRec(
            businessName:  businessName.trimmingCharacters(in: .whitespaces),
            category:      category,
            subcategory:   subcategory,
            description:   description.trimmingCharacters(in: .whitespaces),
            testimonial:   testimonial.trimmingCharacters(in: .whitespaces),
            price:         price,
            neighbourhood: neighbourhood.trimmingCharacters(in: .whitespaces),
            tags:          tags,
            recommender:   RecRecommender(name: "You", initials: "ME", trustLevel: .settling, monthsInCity: 0),
            endorsements:  0,
            website:       website.trimmingCharacters(in: .whitespaces).isEmpty ? nil : website.trimmingCharacters(in: .whitespaces),
            instagram:     instagram.trimmingCharacters(in: .whitespaces).isEmpty ? nil : instagram.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "@", with: ""),
            englishSpeaking: englishAnswer == "Yes" ? true : (englishAnswer == "No" ? false : nil)
        )
        onSave(newRec)
        dismiss()
    }
}

// MARK: - Helpers

private struct RecFormField<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RecFieldLabel(label)
            content()
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(Color.tsInputBg)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.tsBorder.opacity(0.5), lineWidth: 0.5))
        }
    }
}

private struct RecFieldLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.custom("HelveticaNeue-Medium", size: 13))
            .foregroundColor(.tsSecondary)
    }
}
