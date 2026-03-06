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
    // Health (extra)
    case acupuncture  = "Acupuncture"
    // Tech
    case phoneRepair  = "Phone Repair"
    case computerRepair = "Computer Repair"
    case dataRecovery = "Data Recovery"
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
        case .acupuncture: return "waveform.path.ecg"
        case .phoneRepair: return "iphone.gen2.slash"
        case .computerRepair: return "laptopcomputer"
        case .dataRecovery: return "externaldrive.fill"
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
        case .acupuncture:  return Color(hex: "#30D158")
        case .phoneRepair:  return Color(hex: "#007AFF")
        case .computerRepair: return Color(hex: "#636366")
        case .dataRecovery: return Color(hex: "#FF9F0A")
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
        case .acupuncture:  return "☯️"
        case .phoneRepair:  return "📱"
        case .computerRepair: return "💻"
        case .dataRecovery: return "💾"
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
    case tech     = "Tech"

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
        case .tech:    return "wrench.and.screwdriver.fill"
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
        case .tech:    return Color(hex: "#636366")
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
        case .tech:    return "🔧"
        }
    }

    var subcategories: [RecSubcategory] {
        switch self {
        case .all:     return []
        case .health:  return [.dentistry, .dermatology, .mentalHealth, .generalDoc, .physio, .nutrition, .acupuncture]
        case .beauty:  return [.hair, .nails, .spa, .botox, .waxing]
        case .fitness: return [.pt, .yoga, .gym, .pilates, .martialArts]
        case .home:    return [.cleaning, .plumbing, .electrician, .acRepair, .gardening]
        case .legal:   return [.immigration, .notary, .bizLaw]
        case .finance: return [.accounting, .tax, .banking]
        case .tech:    return [.phoneRepair, .computerRepair, .dataRecovery]
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

struct RecReview: Identifiable {
    let id           = UUID()
    let text:        String
    let recommender: RecRecommender
}

struct LocalRec: Identifiable {
    let id           = UUID()
    let businessName:  String
    let category:      RecCategory
    let subcategory:   RecSubcategory?
    let description:   String
    var reviews:       [RecReview]
    let price:         PriceTier?
    let neighbourhood: String
    let tags:          [String]
    var endorsements:  Int
    var website:       String?
    var instagram:     String?  = nil    // handle without @
    var englishSpeaking: Bool?   = nil    // nil = not specified
    var photoURL:       String?  = nil    // direct photo URL (overrides OG scrape)
}

// MARK: - Seed Data

private let seedRecs: [LocalRec] = [
    LocalRec(
        businessName: "Dr. Alejandro Reyes",
        category: .health, subcategory: .dentistry,
        description: "General dentistry & implants · Condesa",
        reviews: [
            RecReview(text: "Saved me $2,400 on two implants vs what I was quoted back home. English-speaking, clean, modern clinic. Gets booked up fast — message ahead.", recommender: RecRecommender(name: "Sarah M.", initials: "SM", trustLevel: .trustedLocal, monthsInCity: 18)),
            RecReview(text: "Three years of avoiding the dentist, fixed in two appointments. Clear pricing up front, no surprises. My whole household goes here now.", recommender: RecRecommender(name: "Tom W.", initials: "TW", trustLevel: .settling, monthsInCity: 7)),
        ],
        price: .mid, neighbourhood: "Condesa",
        tags: ["English-friendly", "Implants", "Walk-in OK"],
        endorsements: 14, website: nil,
        photoURL: "https://images.unsplash.com/photo-1606811841689-23dfddce3e95?w=800&q=80"
    ),
    LocalRec(
        businessName: "Fernanda Orozco",
        category: .fitness, subcategory: .pt,
        description: "NASM-certified PT · trains outdoors & at your gym",
        reviews: [RecReview(text: "Best trainer I've had in any city. She speaks English, adapts to your level, and actually shows up on time — which in CDMX is saying something. ~$35/session.", recommender: RecRecommender(name: "Jake T.", initials: "JT", trustLevel: .local, monthsInCity: 9))],
        price: .mid, neighbourhood: "Roma Norte",
        tags: ["English-friendly", "Outdoor sessions", "Nutrition coaching"],
        endorsements: 11, website: nil,
        photoURL: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&q=80"
    ),
    LocalRec(
        businessName: "Limpia Total",
        category: .home, subcategory: .cleaning,
        description: "Weekly & deep-clean service trusted by expats",
        reviews: [RecReview(text: "Maria and her team have been cleaning my apartment for 8 months. Super reliable, thorough, totally fair. About $25 for a 1BR deep clean.", recommender: RecRecommender(name: "Priya K.", initials: "PK", trustLevel: .trustedLocal, monthsInCity: 22))],
        price: .budget, neighbourhood: "Juárez",
        tags: ["Weekly available", "Deep clean", "Key-holder trusted"],
        endorsements: 19, website: nil
    ),
    LocalRec(
        businessName: "Diego Hernández",
        category: .legal, subcategory: .immigration,
        description: "Residency, visas & apostilles · Polanco",
        reviews: [RecReview(text: "Got my temporary residency done in 6 weeks flat. Diego was transparent about costs upfront — no hidden fees. Worth every peso. Fluent in English.", recommender: RecRecommender(name: "Carlos R.", initials: "CR", trustLevel: .cityExpert, monthsInCity: 36))],
        price: .mid, neighbourhood: "Polanco",
        tags: ["English-speaking", "Residency", "Apostilles"],
        endorsements: 23, website: "diegohernandez.mx"
    ),
    LocalRec(
        businessName: "Studio Bloom",
        category: .beauty, subcategory: .hair,
        description: "Balayage, cuts & colour · Roma Norte",
        reviews: [RecReview(text: "Finally found a colorist who gets fine hair. Lucia did exactly what I asked for — and charged me 60% less than I'd pay in NYC. Book online, she fills up.", recommender: RecRecommender(name: "Emma L.", initials: "EL", trustLevel: .settling, monthsInCity: 4))],
        price: .mid, neighbourhood: "Roma Norte",
        tags: ["Colour specialist", "Fine hair", "Online booking"],
        endorsements: 8, website: "studiobloom.mx"
    ),
    LocalRec(
        businessName: "Clínica Derma MX",
        category: .health, subcategory: .dermatology,
        description: "Dermatology, Botox & skincare treatments · Polanco",
        reviews: [RecReview(text: "Botox was $180 USD all-in, same product I get at home for $550. Dr. Vargas is meticulous. Clinic is spotless. Bring a photo of what you want.", recommender: RecRecommender(name: "Tara S.", initials: "TS", trustLevel: .local, monthsInCity: 11))],
        price: .mid, neighbourhood: "Polanco",
        tags: ["Botox", "Fillers", "Skincare"],
        endorsements: 17, website: "clinicadermamx.com"
    ),
    LocalRec(
        businessName: "Roberto Solís",
        category: .home, subcategory: .plumbing,
        description: "Reliable plumber, same-day in most colonias",
        reviews: [RecReview(text: "Fixed a leak my landlord had been ignoring for months. Showed up in 2 hours, charged $400 MXN and was done in 45 min. Saved his number immediately.", recommender: RecRecommender(name: "Ben A.", initials: "BA", trustLevel: .settling, monthsInCity: 5))],
        price: .budget, neighbourhood: "Condesa",
        tags: ["Same-day", "Emergency", "Leak repair"],
        endorsements: 6, website: nil
    ),
    LocalRec(
        businessName: "Paz Contadores",
        category: .finance, subcategory: .accounting,
        description: "Tax, RFC registration & expat finances",
        reviews: [RecReview(text: "Handled my RFC setup and monthly taxes as a freelancer. Everything done remotely, very organised, explains everything in plain English. ~$80/mo.", recommender: RecRecommender(name: "Mia C.", initials: "MC", trustLevel: .trustedLocal, monthsInCity: 14))],
        price: .mid, neighbourhood: "Remote",
        tags: ["RFC setup", "Freelancer taxes", "English speaking"],
        endorsements: 12, website: "pazcontadores.mx"
    ),
    LocalRec(
        businessName: "FlexYoga CDMX",
        category: .fitness, subcategory: .yoga,
        description: "Drop-in yoga, English & Spanish classes",
        reviews: [
            RecReview(text: "Best yoga community in the city. Drop-in is $120 MXN, packs are cheaper. Morning classes fill up — book the night before on their app.", recommender: RecRecommender(name: "Ana P.", initials: "AP", trustLevel: .local, monthsInCity: 8)),
            RecReview(text: "I've tried four yoga studios here. This one has the best English instruction and the most welcoming vibe — locals and expats mixed, which I love.", recommender: RecRecommender(name: "Chris B.", initials: "CB", trustLevel: .newArrival, monthsInCity: 2)),
        ],
        price: .budget, neighbourhood: "Condesa",
        tags: ["Drop-in", "English classes", "Community vibe"],
        endorsements: 9, website: "flexyogacdmx.com",
        photoURL: "https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&q=80"
    ),
    LocalRec(
        businessName: "iRepara CDMX",
        category: .tech, subcategory: .phoneRepair,
        description: "iPhone & Android repairs, Condesa",
        reviews: [RecReview(text: "Cracked my screen on day two. This guy fixed it in 45 minutes for 350 pesos. Legit parts, not knock-offs. Saved me a long trip to the Apple Store.", recommender: RecRecommender(name: "Marcus T.", initials: "MT", trustLevel: .settling, monthsInCity: 8))],
        price: .budget, neighbourhood: "Condesa",
        tags: ["iPhone repair", "Screen replacement", "Fast turnaround"],
        endorsements: 9,
        englishSpeaking: true,
        photoURL: "https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=800&q=80"
    ),
    LocalRec(
        businessName: "Dr. Wei Acupunctura",
        category: .health, subcategory: .acupuncture,
        description: "Traditional Chinese acupuncture, Roma Norte",
        reviews: [RecReview(text: "Three sessions for lower back pain and I felt like a different person. She explains everything in English and the space is beautiful.", recommender: RecRecommender(name: "Priya N.", initials: "PN", trustLevel: .local, monthsInCity: 14))],
        price: .mid, neighbourhood: "Roma Norte",
        tags: ["Traditional Chinese", "Back pain", "English speaking"],
        endorsements: 7,
        englishSpeaking: true,
        photoURL: "https://images.unsplash.com/photo-1512678080530-7760d81faba6?w=800&q=80"
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
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(UIColor.separator).opacity(0.25), lineWidth: 0.5))
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
                            // ── Subcategory insight card ───────────────────────
                            if let sub = selectedSubcategory,
                               let insight = subcategoryInsights[sub] {
                                CategoryInsightCard(insight: insight)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 12)
                            }

                            LazyVStack(spacing: 12) {
                                ForEach(filtered) { rec in
                                    LocalRecCard(rec: rec)
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
    @State private var ogImageURL: String? = nil
    @State private var ogFetchDone = false
    @State private var showAllReviews = false
    @Environment(\.openURL) private var openURL

    private var accentColor: Color { rec.subcategory?.color ?? rec.category.color }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {


            // ── OG image banner ───────────────────────────────────────
            if let imgStr = ogImageURL, let imgURL = URL(string: imgStr) {
                AsyncImage(url: imgURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill().frame(height: 160).clipped()
                    case .empty:
                        Rectangle().fill(Color(UIColor.secondarySystemBackground))
                            .frame(height: 160).overlay(ProgressView().tint(.tsSecondary))
                    default: EmptyView()
                    }
                }
                .frame(maxWidth: .infinity).frame(height: 160).clipped()
            }
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

                VStack(alignment: .leading, spacing: 3) {
                    Text(rec.businessName)
                        .font(.custom("HelveticaNeue-Bold", size: 16))
                        .foregroundColor(.tsLabel)
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 10))
                            .foregroundColor(.tsSecondary)
                        Text(rec.neighbourhood)
                            .font(.custom("HelveticaNeue", size: 12))
                            .foregroundColor(.tsSecondary)
                    }
                    Text(rec.description)
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(.tsSecondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
                Spacer()
                // Price — only shown when set
                if let price = rec.price {
                    Text(price.symbol)
                        .font(.custom("HelveticaNeue-Medium", size: 13))
                        .foregroundColor(.tsSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 10)

            Divider().background(Color.tsBorder).padding(.horizontal, 16)

            // ── Reviews ───────────────────────────────────────────
            if !rec.reviews.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ReviewBlock(review: rec.reviews[0])
                        .padding(.top, 12)

                    if rec.reviews.count > 1 {
                        if showAllReviews {
                            ForEach(Array(rec.reviews.dropFirst())) { review in
                                Divider()
                                    .background(Color.tsBorder)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                ReviewBlock(review: review)
                            }
                            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { showAllReviews = false } }) {
                                HStack(spacing: 4) {
                                    Text("Show less")
                                        .font(.custom("HelveticaNeue", size: 12))
                                    Image(systemName: "chevron.up")
                                        .font(.system(size: 10))
                                }
                                .foregroundColor(.tsSecondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                        } else {
                            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { showAllReviews = true } }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 11))
                                     Text("\(rec.reviews.count - 1) more review" + (rec.reviews.count - 1 == 1 ? "" : "s"))
                                        .font(.custom("HelveticaNeue", size: 12))
                                }
                                .foregroundColor(.tsAccent)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                        }
                    }
                }
                .padding(.bottom, 10)
            }

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


        }
        .padding(.bottom, 14)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18)
            .stroke(Color(UIColor.separator).opacity(0.3), lineWidth: 0.5))
        .task {
            guard !ogFetchDone else { return }
            ogFetchDone = true
            if let direct = rec.photoURL, !direct.isEmpty {
                ogImageURL = direct
                return
            }
            guard let site = rec.website, !site.isEmpty else { return }
            ogImageURL = await OGImageFetcher.shared.imageURL(for: site)
        }
    }
}


// MARK: - Review Block (person first, quote below)

private struct ReviewBlock: View {
    let review: RecReview

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(review.recommender.trustLevel.color.opacity(0.15))
                        .frame(width: 30, height: 30)
                    Text(review.recommender.initials)
                        .font(.custom("HelveticaNeue-Bold", size: 10))
                        .foregroundColor(review.recommender.trustLevel.color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.recommender.name)
                        .font(.custom("HelveticaNeue-Medium", size: 13))
                        .foregroundColor(.tsLabel)
                    HStack(spacing: 4) {
                        TrustBadge(level: review.recommender.trustLevel, compact: true)
                        Text("·")
                            .font(.system(size: 10))
                            .foregroundColor(.tsSecondary)
                        Text(review.recommender.tenure)
                            .font(.custom("HelveticaNeue", size: 11))
                            .foregroundColor(.tsSecondary)
                    }
                }
                Spacer()
            }
            Text("“\(review.text)”")
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.tsLabel)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Tag Options (per subcategory)

private let subcategoryTagOptions: [RecSubcategory: [String]] = [
    // Health
    .dentistry:    ["Walk-ins welcome", "Implants", "Orthodontics", "Cosmetic dentistry", "Root canals", "Children’s dentistry", "Same-day appointments", "X-rays on-site"],
    .dermatology:  ["Cosmetic procedures", "Medical dermatology", "Laser treatments", "Chemical peels", "Mole removal", "Acne treatment", "Anti-aging", "Same-day"],
    .mentalHealth: ["Video sessions", "Sliding scale fees", "CBT", "Trauma-informed", "LGBTQ+ affirming", "Couples therapy", "Anxiety & stress", "Depression"],
    .generalDoc:   ["Same-day appointments", "Blood tests on-site", "Prescriptions", "Physicals & check-ups", "Urgent care", "Vaccinations"],
    .physio:       ["Sports injuries", "Post-surgery rehab", "Dry needling", "Manual therapy", "Back & neck", "Home visits", "Pilates rehab"],
    .nutrition:    ["Weight management", "Sports nutrition", "Plant-based", "Eating disorders", "Meal planning", "Lab analysis"],
    .acupuncture:  ["Traditional Chinese medicine", "Sports injury", "Stress & anxiety", "Fertility", "Chronic pain", "Digestion issues", "Insomnia"],
    // Beauty
    .hair:         ["Cuts", "Color", "Balayage", "Highlights", "Keratin treatment", "Extensions", "Men’s cuts", "Beards", "Natural hair", "Blowouts"],
    .nails:        ["Gel", "Acrylics", "Nail art", "Walk-ins welcome", "Pedicures", "Dip powder"],
    .botox:        ["Licensed MD", "Board-certified surgeon", "Botox", "Fillers", "Threads", "Laser", "Chemical peel", "Microneedling", "PRP"],
    .spa:          ["Swedish massage", "Deep tissue", "Facials", "Body scrubs", "Couples sessions", "Hot stone", "Prenatal massage"],
    .waxing:       ["Brazilian", "Full body", "Men’s waxing", "Eyebrows", "Walk-ins welcome"],
    // Fitness
    .pt:           ["Weight loss", "Muscle building", "Injury rehab", "Outdoor sessions", "Home visits", "Nutrition coaching", "Pre/postnatal", "Seniors"],
    .yoga:         ["Vinyasa", "Hatha", "Yin", "Hot yoga", "Prenatal", "Aerial yoga", "English classes", "Drop-in"],
    .gym:          ["24/7 access", "Personal training", "Pool", "Sauna", "Classes included", "Month-to-month", "Lockers"],
    .pilates:      ["Reformer", "Mat pilates", "Prenatal", "Injury rehab", "Small groups", "Private sessions"],
    .martialArts:  ["Boxing", "MMA", "BJJ", "Muay Thai", "Judo", "Kids classes", "Sparring", "Beginners welcome"],
    // Home
    .cleaning:     ["Deep clean", "Move-in/out clean", "Regular schedule", "Brings supplies", "Eco-friendly products", "Laundry included", "Ironing"],
    .plumbing:     ["Emergency callouts", "Water heaters", "Leak repair", "Drain cleaning", "Pipe installation", "Same-day"],
    .electrician:  ["Emergency callouts", "Panel upgrades", "AC installation", "Smart home", "Rewiring", "Same-day"],
    .acRepair:     ["Daikin", "Carrier", "LG", "Samsung", "Mitsubishi", "All brands", "Installation", "Maintenance contracts", "Emergency"],
    .gardening:    ["Garden design", "Maintenance", "Irrigation", "Planting", "Tree trimming"],
    // Legal
    .immigration:  ["Temporal residency", "Permanente residency", "FMM extensions", "Work permits", "Apostilles", "RFC for foreigners", "Citizenship"],
    .notary:       ["Real estate", "Company formation", "Wills", "Power of attorney", "Apostilles", "Document legalization"],
    .bizLaw:       ["SA de CV formation", "Employment contracts", "IP protection", "Freelance contracts", "Due diligence"],
    // Finance
    .accounting:   ["Freelancers", "Companies", "RFC setup", "Monthly declarations", "Annual declaration", "VAT / IVA", "SAT disputes", "Remote service"],
    .banking:      ["Account opening help", "FX transfers", "Investment advice", "Crypto", "Mortgage", "Retirement planning"],
    // Tech
    .phoneRepair:  ["iPhone", "Android", "Screen repair", "Battery replacement", "Water damage", "Data recovery", "Same-day", "OEM parts"],
    .computerRepair: ["Mac", "PC / Windows", "Screen repair", "Data recovery", "Virus removal", "RAM / SSD upgrades", "Same-day"],
    .dataRecovery: ["External drives", "Phone data", "Laptop recovery", "RAID arrays", "Water damage", "No-fix no-fee"],
]

private let categoryTagOptions: [RecCategory: [String]] = [
    .health:   ["English-speaking", "Same-day", "Walk-ins welcome", "Payment plans", "Home visits"],
    .beauty:   ["Walk-ins welcome", "Appointment required", "English-speaking", "Online booking"],
    .fitness:  ["English-speaking", "Drop-in available", "Online sessions", "Outdoor sessions"],
    .home:     ["Same-day", "Emergency callouts", "References available", "Brings supplies"],
    .legal:    ["English-speaking", "Free consultation", "Fixed fee", "Remote consultations"],
    .finance:  ["English-speaking", "Remote service", "Fixed monthly fee", "First consult free"],
    .tech:     ["Same-day", "Walk-in", "OEM parts", "Pick-up service"],
]

// MARK: - Add Rec Sheet

struct AddRecSheet: View {
    let onSave: (LocalRec) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var businessName  = ""
    @State private var category: RecCategory = .health
    @State private var subcategory: RecSubcategory? = nil
    @State private var description   = ""
    @State private var testimonial   = ""
    @State private var price: PriceTier? = nil
    @State private var neighbourhood = ""
    @State private var selectedTags: Set<String> = []
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
                        RecFormField(label: "Business or person", required: true) {
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
                                                Text(cat.rawValue).font(.custom("HelveticaNeue-Medium", size: 14))
                                            }
                                            .foregroundColor(category == cat ? .white : .tsLabel)
                                            .padding(.horizontal, 14).padding(.vertical, 8)
                                            .background(category == cat ? Color.tsAccent : Color.tsCard)
                                            .clipShape(Capsule())
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
                                                    Text(sub.rawValue).font(.custom("HelveticaNeue-Medium", size: 12))
                                                }
                                                .foregroundColor(subcategory == sub ? .tsAccent : .tsSecondary)
                                                .padding(.horizontal, 12).padding(.vertical, 6)
                                                .background(Color.tsAccent.opacity(0.08))
                                                .clipShape(Capsule())
                                                .overlay(Capsule().stroke(
                                                    subcategory == sub ? Color.tsAccent : Color.clear,
                                                    lineWidth: 1.5
                                                ))
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.vertical, 3)
                                }
                            }
                        }

                        // One-liner
                        RecFormField(label: "One-liner") {
                            TextField("e.g. Dentist in Condesa, English-speaking", text: $description)
                                .font(.custom("HelveticaNeue", size: 16))
                                .foregroundColor(.tsLabel)
                        }

                        // Testimonial
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                RecFieldLabel("Your experience", required: true)
                                Spacer()
                                Text("\(testimonial.count)/280")
                                    .font(.custom("HelveticaNeue", size: 12))
                                    .foregroundColor(testimonial.count > 280 ? .red : .tsSecondary)
                            }
                            TextEditor(text: $testimonial)
                                .font(.custom("HelveticaNeue", size: 15))
                                .foregroundColor(.tsLabel)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 100)
                                .padding(12)
                                .background(Color.tsCard)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12)
                                    .stroke(testimonial.count > 280 ? Color.red.opacity(0.5) : Color.tsBorder.opacity(0.4), lineWidth: 0.5))
                        }

                        // Price
                        VStack(alignment: .leading, spacing: 8) {
                            RecFieldLabel("Price range")
                            HStack(spacing: 8) {
                                ForEach(PriceTier.allCases, id: \.rawValue) { tier in
                                    Button(action: { price = price == tier ? nil : tier }) {
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
                        RecFormField(label: "Website") {
                            TextField("e.g. example.com", text: $website)
                                .font(.custom("HelveticaNeue", size: 16))
                                .foregroundColor(.tsLabel)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }

                        // Instagram
                        RecFormField(label: "Instagram handle") {
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
                            RecFieldLabel("Do they speak English?")
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

                        // Tags — pill picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Tags")
                                .font(.custom("HelveticaNeue-Medium", size: 13))
                                .foregroundColor(.tsSecondary)
                            let opts = subcategory.flatMap { subcategoryTagOptions[$0] }
                                ?? categoryTagOptions[category]
                                ?? []
                            if opts.isEmpty {
                                Text("Select a category above to see tag options")
                                    .font(.custom("HelveticaNeue", size: 13))
                                    .foregroundColor(.tsSecondary.opacity(0.7))
                                    .padding(14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.tsCard)
                                    .cornerRadius(12)
                            } else {
                                LazyVGrid(
                                    columns: [GridItem(.adaptive(minimum: 88, maximum: 180), spacing: 8)],
                                    alignment: .leading, spacing: 8
                                ) {
                                    ForEach(opts, id: \.self) { tag in
                                        let on = selectedTags.contains(tag)
                                        Button(action: {
                                            if on { selectedTags.remove(tag) } else { selectedTags.insert(tag) }
                                        }) {
                                            Text(tag)
                                                .font(.custom("HelveticaNeue", size: 12))
                                                .foregroundColor(on ? .white : .tsLabel)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 7)
                                                .frame(maxWidth: .infinity)
                                                .background(on ? Color.tsAccent : Color.tsCard)
                                                .clipShape(Capsule())
                                                .overlay(Capsule().stroke(
                                                    on ? Color.clear : Color.tsBorder.opacity(0.4),
                                                    lineWidth: 0.5
                                                ))
                                                .animation(.easeInOut(duration: 0.12), value: on)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(12)
                                .background(Color.tsCard)
                                .cornerRadius(12)
                            }
                        }
                        .onChange(of: subcategory) { _, _ in selectedTags = [] }
                        .onChange(of: category)    { _, _ in selectedTags = [] }

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
            .navigationTitle("Add a Recommendation")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func save() {
        let newRec = LocalRec(
            businessName:  businessName.trimmingCharacters(in: .whitespaces),
            category:      category,
            subcategory:   subcategory,
            description:   description.trimmingCharacters(in: .whitespaces),
            reviews:       [RecReview(
                text: testimonial.trimmingCharacters(in: .whitespaces),
                recommender: RecRecommender(name: "You", initials: "ME", trustLevel: .settling, monthsInCity: 0)
            )],
            price:         price,
            neighbourhood: neighbourhood.trimmingCharacters(in: .whitespaces),
            tags:          Array(selectedTags),
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
    var required: Bool = false
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RecFieldLabel(label, required: required)
            content()
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(Color.tsCard)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.tsBorder.opacity(0.4), lineWidth: 0.5))
        }
    }
}

private struct RecFieldLabel: View {
    let text: String
    var required: Bool = false
    init(_ text: String, required: Bool = false) {
        self.text = text
        self.required = required
    }
    var body: some View {
        HStack(spacing: 3) {
            Text(text)
                .font(.custom("HelveticaNeue-Medium", size: 13))
                .foregroundColor(.tsSecondary)
            if required {
                Text("*")
                    .font(.custom("HelveticaNeue-Bold", size: 14))
                    .foregroundColor(Color(hex: "#FF3B30"))
            }
        }
    }
}
// MARK: - Category Insight Data

struct CategoryInsight {
    let headline:  String
    let stat:      String?
    let statColor: String
    let bullets:   [String]
}





private let subcategoryInsights: [RecSubcategory: CategoryInsight] = [

    // ── Health ────────────────────────────────────────────────────────────────
    .dentistry: CategoryInsight(
        headline:  "You could see a dentist tomorrow for less than a copay at home",
        stat:      "Save 60–80% vs. US & Canada",
        statColor: "#0099FF",
        bullets: [
            "A full cleaning + checkup runs $300–600 MXN (~$15–30 USD). Crowns, implants, and root canals are a fraction of US prices.",
            "Most dentists in Roma and Condesa are well-trained — many studied in the US or Europe. Don't equate lower price with lower quality.",
            "Bring recent X-rays if you have them. Dentists appreciate the context and won't charge you to redo work unnecessarily.",
            "Cash pricing is standard. No dental insurance needed — just show up and pay."
        ]
    ),
    .botox: CategoryInsight(
        headline:  "Proceed with knowledge — not all providers are equal",
        stat:      nil,
        statColor: "#FF375F",
        bullets: [
            "Mexico doesn't require the same medical licensure for aesthetic injectables as the US or EU. Ask if your provider is a board-certified dermatologist or plastic surgeon.",
            "Always ask what brand of product they're using. Allergan Botox and Juvederm fillers are available here — legitimate clinics will tell you the brand without hesitation.",
            "Pricing is significantly lower than the US, but avoid walk-in deals at unvetted studios. This is a medical procedure.",
            "A recommendation from someone who's been here a while is worth more than any online review."
        ]
    ),
    .dermatology: CategoryInsight(
        headline:  "Strong scene — verify credentials before you book",
        stat:      nil,
        statColor: "#FF2D55",
        bullets: [
            "Ask if they're a dermatólogo certificado by the Consejo Mexicano de Dermatología — not all practitioners carry equivalent certification.",
            "Consultations run $800–1,500 MXN. Treatments (chemical peels, laser, mole removal) are substantially cheaper than the US.",
            "Sun exposure in CDMX is intense — altitude amplifies UV. Worth seeing a derm if you're staying long-term.",
            "Many CDMX dermatologists speak English. Ask when booking if that's a priority."
        ]
    ),
    .mentalHealth: CategoryInsight(
        headline:  "More options than you'd expect — find one before you need one",
        stat:      nil,
        statColor: "#AF52DE",
        bullets: [
            "English-speaking therapists exist but book up quickly in expat-heavy neighborhoods. Start looking before you urgently need one.",
            "Sessions typically run $800–1,500 MXN ($40–75 USD) — significantly cheaper than US out-of-pocket rates.",
            "Online sessions (video) are widely accepted and often easier to schedule around language preference.",
            "Ask whether your therapist is a psicólogo (psychology degree) or psicoterapeuta — training and licensing requirements differ."
        ]
    ),
    .generalDoc: CategoryInsight(
        headline:  "Private clinics are fast, affordable, and genuinely good",
        stat:      "Consultations from $400–800 MXN (~$20–40 USD)",
        statColor: "#FF3B30",
        bullets: [
            "Private hospitals (ABC Medical Center, Médica Sur, Ángeles) are excellent — same equipment, shorter waits, English-speaking staff available.",
            "Avoid IMSS and ISSSTE — those are the public systems for Mexican citizens, not tourists or expats.",
            "Always ask for the precio de contado (cash price) — saves another 15–20% on top of the already lower rate.",
            "Lab work is dramatically cheaper. A full blood panel with same-day results runs $500–1,200 MXN."
        ]
    ),
    .acupuncture: CategoryInsight(
        headline:  "Traditional Chinese medicine has a genuine presence here",
        stat:      nil,
        statColor: "#30D158",
        bullets: [
            "CDMX has a real TCM community — many practitioners trained in China or Taiwan. It's not just a wellness trend.",
            "Sessions typically run $500–900 MXN. A course of 4–6 sessions is standard for most conditions.",
            "Ask whether your practitioner uses disposable single-use needles — reputable clinics always do.",
            "Particularly effective for back pain, stress, and chronic issues. Give it a few sessions before judging."
        ]
    ),

    // ── Fitness ───────────────────────────────────────────────────────────────
    .pt: CategoryInsight(
        headline:  "No national cert body — so the recommendation really matters",
        stat:      nil,
        statColor: "#FF9500",
        bullets: [
            "There's no Mexican equivalent of NASM or ACE. Ask trainers where they studied and whether they hold international certifications.",
            "1-on-1 sessions typically run $400–800 MXN. Package deals are common and usually significantly discounted.",
            "Many PTs in Roma and Condesa have trained internationally or work primarily with expat clients — English is common.",
            "Nutrition is often included in PT conversations — ask whether your trainer has formal nutrition training."
        ]
    ),
    .gym: CategoryInsight(
        headline:  "Affordable, well-equipped, and everywhere in the right areas",
        stat:      "$300–800 MXN/month for most gyms",
        statColor: "#FF3B30",
        bullets: [
            "Smart Fit has locations everywhere and costs ~$300 MXN/month. More than adequate for most workouts.",
            "Boutique studios (pilates, barre, boxing) run $150–200 MXN/class or $1,500–2,500 MXN/month unlimited.",
            "Ask specifically about month-to-month options — some gyms push annual contracts. You can usually negotiate.",
            "Bring a lock. Most lockers don't include them."
        ]
    ),

    // ── Home ──────────────────────────────────────────────────────────────────
    .cleaning: CategoryInsight(
        headline:  "The standard is high and the price is genuinely right",
        stat:      "2BR cleaning: $350–500 MXN (~$18–25 USD)",
        statColor: "#0099FF",
        bullets: [
            "Weekly arrangements are the norm — $350–500 MXN per session for a 2BR, $500–700 MXN for larger places.",
            "Communicate expectations clearly up front — especially around products, fragile items, or areas that are off-limits.",
            "Many cleaners prefer their own products. If you have preferences, buy them and leave them out.",
            "Tips aren't expected but appreciated. $50–100 MXN extra for recurring help goes a long way."
        ]
    ),
    .plumbing: CategoryInsight(
        headline:  "No licensing required — vetting is entirely on you",
        stat:      nil,
        statColor: "#30B0C7",
        bullets: [
            "Plumbers in CDMX don't require formal licensing. Reputation and word-of-mouth matter more than any credential.",
            "Agree on the total price before work starts. For anything significant, get it in writing.",
            "Get 2–3 quotes for larger jobs — pricing varies wildly. A peer recommendation gives you a fair baseline.",
            "Know someone reliable before a crisis — emergency plumbers charge a premium."
        ]
    ),
    .electrician: CategoryInsight(
        headline:  "Skilled work available — same caveats as plumbing",
        stat:      nil,
        statColor: "#FFD60A",
        bullets: [
            "Electricians in CDMX don't require formal licensing. A trusted referral is your best quality indicator.",
            "CDMX electricity is 127V/60Hz. Most international devices handle this fine — old US appliances rated only for 110V may run warm.",
            "Agree on scope and price before work begins. 'Small job' pricing can escalate quickly.",
            "For major electrical work in a rented apartment, check with your landlord first — it may be their responsibility."
        ]
    ),
    .acRepair: CategoryInsight(
        headline:  "AC techs are usually brand-specific — tell them up front",
        stat:      nil,
        statColor: "#5AC8FA",
        bullets: [
            "Most technicians specialize by brand. Tell them your unit's make and model when booking — a Daikin tech won't carry Carrier parts.",
            "Standard service (filter cleaning, refrigerant check) for a mini-split runs $500–900 MXN.",
            "Service contracts through building management are often cheaper than calling a tech independently.",
            "If your landlord installed the unit, ask them for the original service contact first — they may cover maintenance."
        ]
    ),

    // ── Legal ─────────────────────────────────────────────────────────────────
    .immigration: CategoryInsight(
        headline:  "Don't wing the visa process — get an attorney",
        stat:      nil,
        statColor: "#5E5CE6",
        bullets: [
            "INM (Instituto Nacional de Migración) is notoriously inconsistent between offices. A good attorney knows which office to use and how.",
            "Temporal Resident visa (1–4 years) requires proof of income or savings. Permanente requires 4 years as Temporal first.",
            "You cannot leave Mexico while a change of status is pending. Plan around this.",
            "Attorney fees run $5,000–12,000 MXN ($250–600 USD) — worth every peso for the time and frustration they save."
        ]
    ),
    .notary: CategoryInsight(
        headline:  "A Mexican notary is nothing like a US or UK notary",
        stat:      nil,
        statColor: "#BF5AF2",
        bullets: [
            "A Notario Público is a state-appointed attorney with near-judicial authority. Without one, real estate transactions and company formations are legally void.",
            "You need one for: buying/selling property, forming a company, signing a will, apostilling documents for use abroad.",
            "Fees are regulated by state law — typically 0.5–1.5% of transaction value for real estate. Get a fee estimate upfront.",
            "Verify your notary is licensed via the Colegio de Notarios del Distrito Federal official registry."
        ]
    ),
    .bizLaw: CategoryInsight(
        headline:  "Incorporating in Mexico is more involved than most countries",
        stat:      "SA de CV formation: $8,000–15,000 MXN in notary fees",
        statColor: "#0A84FF",
        bullets: [
            "The most common structures are SA de CV (corp equivalent) and SAPI de CV (for startups seeking investment). Both require a notary.",
            "You'll need an RFC (tax ID), a registered address in Mexico, and at least two shareholders for an SA de CV.",
            "The full process takes 4–8 weeks. Your attorney handles notary coordination and SAT registration.",
            "Verify your attorney with the Barra Mexicana de Abogados — ask for their cédula profesional number."
        ]
    ),

    // ── Finance ───────────────────────────────────────────────────────────────
    .accounting: CategoryInsight(
        headline:  "SAT is not the IRS — treat it accordingly",
        stat:      nil,
        statColor: "#30D158",
        bullets: [
            "SAT uses RFC tax IDs and CFDI electronic invoicing — a completely different system from US or EU tax infrastructure.",
            "If you're receiving Mexican-sourced income, you're required to register with SAT and file monthly declarations.",
            "A good contador costs $1,500–3,000 MXN/month for basic freelancer accounting. Worth it to avoid SAT penalties.",
            "Annual declaration (Declaración Anual) is due in April for the previous calendar year. Don't miss it."
        ]
    ),
    .banking: CategoryInsight(
        headline:  "Traditional banks are painful — there are better options",
        stat:      nil,
        statColor: "#34C759",
        bullets: [
            "Most traditional banks (BBVA, Banamex, Santander) require a CURP + Mexican address. Difficult for new arrivals.",
            "Nubank Mexico and Hey Banco are significantly easier for expats — open via app, fewer documents required.",
            "Wise and Revolut work well day-to-day. Watch the MXN/USD rate — it moves, and timing transfers matters.",
            "ATM fees add up fast. Withdraw larger amounts less often, or use a no-foreign-fee card if you have one."
        ]
    ),

    // ── Tech ──────────────────────────────────────────────────────────────────
    .phoneRepair: CategoryInsight(
        headline:  "No Apple Store — but your warranty can still be protected",
        stat:      "Apple products cost 20–35% more than US prices here",
        statColor: "#007AFF",
        bullets: [
            "There are no official Apple Stores in Mexico City. MacStore and iShop are the main Authorized Service Providers for AppleCare+ repairs.",
            "Using an unauthorized repair shop voids AppleCare+ coverage. If you're covered, always use an authorized provider.",
            "For unlocked Android phones, parts are widely available in Tepito and Centro Histórico — ask if parts are OEM or aftermarket.",
            "If you need a replacement device, ordering from the US will save you 20–35% on most Apple products."
        ]
    ),
    .computerRepair: CategoryInsight(
        headline:  "Know your warranty status before handing anything over",
        stat:      nil,
        statColor: "#636366",
        bullets: [
            "MacStore and iShop are the authorized Apple service centers for Mac computers. Bring your serial number and AppleCare info.",
            "For Windows/PC repairs, ask for a written quote and timeline before work starts.",
            "Always backup before you hand it over — especially important when there's a potential language barrier.",
            "SSD upgrades and RAM replacements are often cheaper here than at Apple-certified US centers."
        ]
    ),
]

// MARK: - Category Insight Card View

struct CategoryInsightCard: View {
    let insight: CategoryInsight

    private var accent: Color { Color(hex: insight.statColor) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // ── Header ────────────────────────────────────────────────
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(accent.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(accent)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(insight.headline)
                        .font(.custom("HelveticaNeue-Bold", size: 14))
                        .foregroundColor(.tsLabel)
                        .fixedSize(horizontal: false, vertical: true)
                    if let stat = insight.stat {
                        Text(stat)
                            .font(.custom("HelveticaNeue-Medium", size: 12))
                            .foregroundColor(accent)
                    }
                }
            }

            Divider().background(Color(UIColor.separator).opacity(0.4))

            // ── Bullets ───────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 10) {
                ForEach(insight.bullets, id: \.self) { bullet in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(accent)
                            .frame(width: 5, height: 5)
                            .padding(.top, 5)
                        Text(bullet)
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsLabel.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(2)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(accent.opacity(0.18), lineWidth: 1)
        )
    }
}
