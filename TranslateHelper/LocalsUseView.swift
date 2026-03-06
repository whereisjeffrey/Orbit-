//  LocalsUseView.swift
//  Wandr — crowdsourced local service recommendations

import SwiftUI

// MARK: - Models

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
}

enum PriceTier: String, CaseIterable {
    case budget  = "💰"
    case mid     = "💰💰"
    case premium = "💰💰💰"

    var label: String {
        switch self {
        case .budget:  return "Budget-friendly"
        case .mid:     return "Mid-range"
        case .premium: return "Premium"
        }
    }
}

struct RecRecommender {
    let name: String
    let initials: String
    let trustLevel: TrustLevel
    let monthsInCity: Int

    var tenure: String {
        monthsInCity >= 12
            ? "\(monthsInCity / 12)y in CDMX"
            : "\(monthsInCity)mo in CDMX"
    }
}

struct LocalRec: Identifiable {
    let id           = UUID()
    let businessName: String
    let category:     RecCategory
    let description:  String
    let testimonial:  String
    let price:        PriceTier
    let neighbourhood:String
    let tags:         [String]
    let recommender:  RecRecommender
    var endorsements: Int
}

// MARK: - Seed Data

private let seedRecs: [LocalRec] = [
    LocalRec(
        businessName:  "Dr. Alejandro Reyes — Dentist",
        category:      .health,
        description:   "General dentistry & implants in Condesa",
        testimonial:   "Saved me $2,400 on two implants vs. what I was quoted back home. English-speaking, clean, modern clinic. Gets booked up fast — message ahead.",
        price:         .mid,
        neighbourhood: "Condesa",
        tags:          ["English-friendly", "Implants", "Walk-in OK"],
        recommender:   RecRecommender(name: "Sarah M.", initials: "SM", trustLevel: .trustedLocal, monthsInCity: 18),
        endorsements:  14
    ),
    LocalRec(
        businessName:  "Fernanda Orozco — Personal Trainer",
        category:      .fitness,
        description:   "NASM-certified PT, trains outdoors & at your gym",
        testimonial:   "Best trainer I've had in any city. She speaks English, adapts to your level, and actually shows up on time — which in CDMX is saying something. ~$35/session.",
        price:         .mid,
        neighbourhood: "Roma Norte",
        tags:          ["English-friendly", "Outdoor sessions", "Nutrition coaching"],
        recommender:   RecRecommender(name: "Jake T.", initials: "JT", trustLevel: .local, monthsInCity: 9),
        endorsements:  11
    ),
    LocalRec(
        businessName:  "Limpia Total — Cleaning Service",
        category:      .home,
        description:   "Weekly & deep-clean service, trusted by expats",
        testimonial:   "Maria and her team have been cleaning my apartment for 8 months. Super reliable, thorough, and totally fair pricing. About $25 for a 1BR deep clean.",
        price:         .budget,
        neighbourhood: "Juárez",
        tags:          ["Weekly available", "Deep clean", "Key-holder trusted"],
        recommender:   RecRecommender(name: "Priya K.", initials: "PK", trustLevel: .trustedLocal, monthsInCity: 22),
        endorsements:  19
    ),
    LocalRec(
        businessName:  "Diego Hernández — Immigration Attorney",
        category:      .legal,
        description:   "Residency, visas & apostilles",
        testimonial:   "Got my temporary residency done in 6 weeks flat. Diego was transparent about costs upfront — no hidden fees. Worth every peso. Fluent in English.",
        price:         .mid,
        neighbourhood: "Polanco",
        tags:          ["English-speaking", "Residency", "Apostilles", "Business visa"],
        recommender:   RecRecommender(name: "Carlos R.", initials: "CR", trustLevel: .cityExpert, monthsInCity: 36),
        endorsements:  23
    ),
    LocalRec(
        businessName:  "Studio Bloom — Hair & Color",
        category:      .beauty,
        description:   "Balayage, cuts & colour in Roma Norte",
        testimonial:   "Finally found a colorist who gets fine hair. Lucia did exactly what I asked for — and charged me 60% less than I'd pay in NYC. Book online, she fills up.",
        price:         .mid,
        neighbourhood: "Roma Norte",
        tags:          ["Colour specialist", "Fine hair", "Online booking"],
        recommender:   RecRecommender(name: "Emma L.", initials: "EL", trustLevel: .settling, monthsInCity: 4),
        endorsements:  8
    ),
    LocalRec(
        businessName:  "Clínica Derma MX — Dermatology",
        category:      .health,
        description:   "Dermatology, Botox & skincare treatments",
        testimonial:   "Botox was $180 USD all-in, same product I get at home for $550. Dr. Vargas is meticulous. Clinic is spotless. Bring a picture of what you want.",
        price:         .mid,
        neighbourhood: "Polanco",
        tags:          ["Botox", "Fillers", "English-friendly", "Medical-grade"],
        recommender:   RecRecommender(name: "Tara S.", initials: "TS", trustLevel: .local, monthsInCity: 11),
        endorsements:  17
    ),
    LocalRec(
        businessName:  "Roberto Solís — Plumber",
        category:      .home,
        description:   "Reliable plumber, same-day in most colonias",
        testimonial:   "Fixed a leak my landlord had been ignoring for months. Showed up in 2 hours, charged $400 MXN and was done in 45 minutes. Saved his number immediately.",
        price:         .budget,
        neighbourhood: "Narvarte",
        tags:          ["Same-day", "Leak repair", "Water heater"],
        recommender:   RecRecommender(name: "Ben A.", initials: "BA", trustLevel: .settling, monthsInCity: 5),
        endorsements:  6
    ),
    LocalRec(
        businessName:  "Paz Contadores — Accountant",
        category:      .finance,
        description:   "Tax, RFC registration & expat finances",
        testimonial:   "Handled my RFC setup and monthly taxes as a freelancer. Everything is done remotely, very organised, and they explain everything in plain English. ~$80 USD/mo.",
        price:         .mid,
        neighbourhood: "Cuauhtémoc",
        tags:          ["RFC setup", "Freelancer-friendly", "Remote", "English"],
        recommender:   RecRecommender(name: "Mia C.", initials: "MC", trustLevel: .trustedLocal, monthsInCity: 14),
        endorsements:  12
    ),
    LocalRec(
        businessName:  "FlexYoga CDMX — Studio",
        category:      .fitness,
        description:   "Drop-in yoga, english & spanish classes",
        testimonial:   "Best yoga community I've found in the city. Drop-in is $120 MXN, packs are cheaper. Morning classes fill up — book the night before on their app.",
        price:         .budget,
        neighbourhood: "Condesa",
        tags:          ["Drop-in", "English classes", "Community vibe"],
        recommender:   RecRecommender(name: "Ana P.", initials: "AP", trustLevel: .local, monthsInCity: 8),
        endorsements:  9
    ),
]

// MARK: - Main View

struct LocalsUseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: RecCategory = .all
    @State private var searchText = ""
    @State private var showAddRec = false
    @State private var recs = seedRecs

    var filtered: [LocalRec] {
        recs.filter { rec in
            let catMatch = selectedCategory == .all || rec.category == selectedCategory
            let searchMatch = searchText.isEmpty ||
                rec.businessName.localizedCaseInsensitiveContains(searchText) ||
                rec.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                rec.neighbourhood.localizedCaseInsensitiveContains(searchText) ||
                rec.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            return catMatch && searchMatch
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                TSGradientBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        // ── Search bar ────────────────────────────────
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
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(Color.tsInputBg)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 14)

                        // ── Category pills ────────────────────────────
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(RecCategory.allCases) { cat in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                            selectedCategory = cat
                                        }
                                    }) {
                                        HStack(spacing: 5) {
                                            Image(systemName: cat.icon)
                                                .font(.system(size: 11, weight: .medium))
                                            Text(cat.rawValue)
                                                .font(.custom("HelveticaNeue-Medium", size: 13))
                                        }
                                        .foregroundColor(selectedCategory == cat ? .white : .tsSecondary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == cat ? cat.color : Color.tsCard)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule().stroke(
                                                selectedCategory == cat ? Color.clear : Color.tsBorder.opacity(0.5),
                                                lineWidth: 0.5
                                            )
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }

                        // ── Results count ─────────────────────────────
                        if !searchText.isEmpty || selectedCategory != .all {
                            Text("\(filtered.count) rec\(filtered.count == 1 ? "" : "s")")
                                .font(.custom("HelveticaNeue", size: 13))
                                .foregroundColor(.tsSecondary)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 10)
                        }

                        // ── Cards ─────────────────────────────────────
                        if filtered.isEmpty {
                            VStack(spacing: 12) {
                                Text("🔍")
                                    .font(.system(size: 40))
                                Text("Nothing yet in this category")
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

                // ── FAB — Add a rec ───────────────────────────────────
                Button(action: { showAddRec = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Add a rec")
                            .font(.custom("HelveticaNeue-Bold", size: 15))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#3B99FC"), Color(hex: "#007AFF")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.tsAccent.opacity(0.35), radius: 12, x: 0, y: 4)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ────────────────────────────────────────────────
            HStack(alignment: .top, spacing: 10) {
                // Category icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(rec.category.color.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: rec.category.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(rec.category.color)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(rec.businessName)
                        .font(.custom("HelveticaNeue-Bold", size: 15))
                        .foregroundColor(.tsLabel)
                    Text(rec.description)
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(.tsSecondary)
                }
                Spacer()
                Text(rec.price.rawValue)
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // ── Testimonial ───────────────────────────────────────────
            Text(""\(rec.testimonial)"")
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.tsLabel)
                .lineSpacing(3)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

            // ── Tags ──────────────────────────────────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(rec.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.custom("HelveticaNeue", size: 11))
                            .foregroundColor(.tsSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.tsInputBg)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 12)

            Divider().background(Color.tsBorder).padding(.horizontal, 16)

            // ── Footer ────────────────────────────────────────────────
            HStack(spacing: 8) {
                // Recommender avatar
                ZStack {
                    Circle()
                        .fill(rec.recommender.trustLevel.color.opacity(0.15))
                        .frame(width: 28, height: 28)
                    Text(rec.recommender.initials)
                        .font(.custom("HelveticaNeue-Bold", size: 10))
                        .foregroundColor(rec.recommender.trustLevel.color)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(rec.recommender.name)
                        .font(.custom("HelveticaNeue-Medium", size: 12))
                        .foregroundColor(.tsLabel)
                    HStack(spacing: 4) {
                        TrustBadge(level: rec.recommender.trustLevel, compact: true)
                        Text("·")
                            .foregroundColor(.tsSecondary)
                        Text(rec.recommender.tenure)
                            .font(.custom("HelveticaNeue", size: 11))
                            .foregroundColor(.tsSecondary)
                        Text("·")
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

                // Endorse button
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
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(endorsed ? Color.tsAccent.opacity(0.10) : Color.tsInputBg)
                    .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: endorsed)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.tsCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.06), lineWidth: 0.5))
    }
}

// MARK: - Add Rec Sheet

struct AddRecSheet: View {
    let onSave: (LocalRec) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var businessName  = ""
    @State private var category: RecCategory = .health
    @State private var description   = ""
    @State private var testimonial   = ""
    @State private var price: PriceTier = .mid
    @State private var neighbourhood = ""
    @State private var tagsText      = ""

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

                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            RecFieldLabel("Category")
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(RecCategory.allCases.filter { $0 != .all }) { cat in
                                        Button(action: { category = cat }) {
                                            HStack(spacing: 5) {
                                                Image(systemName: cat.icon)
                                                    .font(.system(size: 11))
                                                Text(cat.rawValue)
                                                    .font(.custom("HelveticaNeue-Medium", size: 13))
                                            }
                                            .foregroundColor(category == cat ? .white : .tsSecondary)
                                            .padding(.horizontal, 14).padding(.vertical, 8)
                                            .background(category == cat ? cat.color : Color.tsCard)
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(
                                                category == cat ? Color.clear : Color.tsBorder.opacity(0.5),
                                                lineWidth: 0.5
                                            ))
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }

                        // One-liner description
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

                        // Price range
                        VStack(alignment: .leading, spacing: 8) {
                            RecFieldLabel("Price range")
                            HStack(spacing: 8) {
                                ForEach(PriceTier.allCases, id: \.rawValue) { tier in
                                    Button(action: { price = tier }) {
                                        VStack(spacing: 2) {
                                            Text(tier.rawValue)
                                                .font(.system(size: 16))
                                            Text(tier.label)
                                                .font(.custom("HelveticaNeue", size: 10))
                                                .foregroundColor(price == tier ? .tsAccent : .tsSecondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(price == tier ? Color.tsAccent.opacity(0.08) : Color.tsCard)
                                        .cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10)
                                            .stroke(price == tier ? Color.tsAccent : Color.tsBorder.opacity(0.4), lineWidth: price == tier ? 1.5 : 0.5))
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

                        // Tags
                        RecFormField(label: "Tags (comma separated, optional)") {
                            TextField("e.g. English-friendly, Walk-in OK", text: $tagsText)
                                .font(.custom("HelveticaNeue", size: 16))
                                .foregroundColor(.tsLabel)
                        }

                        // Save
                        Button(action: save) {
                            Text("Share rec")
                                .font(.custom("HelveticaNeue-Bold", size: 17))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
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
        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let newRec = LocalRec(
            businessName:  businessName.trimmingCharacters(in: .whitespaces),
            category:      category,
            description:   description.trimmingCharacters(in: .whitespaces),
            testimonial:   testimonial.trimmingCharacters(in: .whitespaces),
            price:         price,
            neighbourhood: neighbourhood.trimmingCharacters(in: .whitespaces),
            tags:          tags,
            recommender:   RecRecommender(name: "You", initials: "ME", trustLevel: .settling, monthsInCity: 0),
            endorsements:  0
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
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
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
