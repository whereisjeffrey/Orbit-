//  GroupDirectory.swift — WhatsApp Group Directory

import SwiftUI

// MARK: - Model
enum GroupCategory: String, CaseIterable, Identifiable {
    case all              = "All"
    case languageExchange = "Language Exchange"
    case expats           = "Expats & Nomads"
    case nightlife        = "Nightlife"
    case housing          = "Housing"
    case work             = "Work & Coworking"
    case events           = "Events"
    case sports           = "Sports & Outdoors"
    case general          = "General"

    var id: String { rawValue }
    var emoji: String {
        switch self {
        case .all:              return "✨"
        case .languageExchange: return "🗣️"
        case .expats:           return "🌍"
        case .nightlife:        return "🌙"
        case .housing:          return "🏠"
        case .work:             return "💻"
        case .events:           return "📅"
        case .sports:           return "⚽"
        case .general:          return "💬"
        }
    }
    var color: Color {
        switch self {
        case .all:              return .tsAccent
        case .languageExchange: return Color(hex: "#0099FF")
        case .expats:           return Color(hex: "#34C759")
        case .nightlife:        return Color(hex: "#AF52DE")
        case .housing:          return Color(hex: "#FF9500")
        case .work:             return Color(hex: "#5856D6")
        case .events:           return Color(hex: "#FF2D55")
        case .sports:           return Color(hex: "#34C759")
        case .general:          return Color(hex: "#8E8E93")
        }
    }
}

struct CommunityGroup: Identifiable {
    let id:          String
    let name:        String
    let description: String
    let category:    GroupCategory
    let cityId:      String
    let language:    String
    let memberCount: Int?
    let whatsappLink: String
    let addedBy:     String
    let isVerified:  Bool
    let tags:        [String]
    var expiredReports: Int = 0

    var isLinkExpired: Bool { expiredReports >= 3 }

    var formattedMembers: String {
        guard let m = memberCount else { return "" }
        return m >= 1000 ? String(format: "%.1fk", Double(m) / 1000) : "\(m)"
    }
}

// MARK: - Seed data (CDMX)
let cdmxGroups: [CommunityGroup] = [
    CommunityGroup(
        id: "g1", name: "CDMX Language Exchange",
        description: "Weekly meetups + daily vocab drops. EN/ES speakers swap lessons and make friends.",
        category: .languageExchange, cityId: "mx_cdmx", language: "EN · ES",
        memberCount: 847, whatsappLink: "https://chat.whatsapp.com/example1",
        addedBy: "Marco R.", isVerified: true,
        tags: ["Weekly meetups", "Beginners welcome", "Active daily"]
    ),
    CommunityGroup(
        id: "g2", name: "Nomads CDMX 🌮",
        description: "The main nomad hub for Mexico City. Jobs, housing, events, recommendations — everything.",
        category: .expats, cityId: "mx_cdmx", language: "EN",
        memberCount: 2341, whatsappLink: "https://chat.whatsapp.com/example2",
        addedBy: "Sarah K.", isVerified: true,
        tags: ["Very active", "Housing leads", "Job board"]
    ),
    CommunityGroup(
        id: "g3", name: "Roma Norte Nights",
        description: "Best bars, clubs, pop-ups and rooftop events in Roma Norte and Condesa every weekend.",
        category: .nightlife, cityId: "mx_cdmx", language: "EN · ES",
        memberCount: 412, whatsappLink: "https://chat.whatsapp.com/example3",
        addedBy: "Diego M.", isVerified: false,
        tags: ["Weekends", "Bar crawls", "Events"]
    ),
    CommunityGroup(
        id: "g4", name: "CDMX Housing & Rooms",
        description: "Sublets, roommates, short-term rentals. Post what you need or what you have — no agents.",
        category: .housing, cityId: "mx_cdmx", language: "EN · ES",
        memberCount: 1203, whatsappLink: "https://chat.whatsapp.com/example4",
        addedBy: "Lena W.", isVerified: true,
        tags: ["No agents", "Short-term", "Rooms & studios"]
    ),
    CommunityGroup(
        id: "g5", name: "Remote Workers MX",
        description: "Coworking spots, internet tips, café reviews, power outage alerts. For people who work online.",
        category: .work, cityId: "mx_cdmx", language: "EN",
        memberCount: 678, whatsappLink: "https://chat.whatsapp.com/example5",
        addedBy: "Marco R.", isVerified: true,
        tags: ["Café tips", "Coworking", "WiFi alerts"]
    ),
    CommunityGroup(
        id: "g6", name: "CDMX Expat Events",
        description: "Curated list of expat-friendly events, concerts, art shows, markets and pop-ups.",
        category: .events, cityId: "mx_cdmx", language: "EN",
        memberCount: 523, whatsappLink: "https://chat.whatsapp.com/example6",
        addedBy: "Sarah K.", isVerified: false,
        tags: ["Weekly events", "Art & culture", "Markets"]
    ),
    CommunityGroup(
        id: "g7", name: "Fútbol & Sports CDMX",
        description: "Pick-up football, running clubs, padel, cycling — find people to play with.",
        category: .sports, cityId: "mx_cdmx", language: "EN · ES",
        memberCount: 289, whatsappLink: "https://chat.whatsapp.com/example7",
        addedBy: "Diego M.", isVerified: false,
        tags: ["Pick-up games", "Running", "Padel"]
    ),
]

// MARK: - Group Directory View
struct GroupDirectoryView: View {
    @AppStorage("selected_city_id") private var cityId = "mx_cdmx"
    @State private var selectedCategory: GroupCategory = .all
    @State private var showAddGroup = false
    @State private var groups: [CommunityGroup] = cdmxGroups
    @State private var reportedGroupId: String? = nil

    var filtered: [CommunityGroup] {
        groups.filter { g in
            g.cityId == cityId &&
            !g.isLinkExpired &&
            (selectedCategory == .all || g.category == selectedCategory)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.tsBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {

                        // ── Category filter ──────────────────────────
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(GroupCategory.allCases) { cat in
                                    Button(action: { selectedCategory = cat }) {
                                        HStack(spacing: 5) {
                                            Text(cat.emoji).font(.system(size: 13))
                                            Text(cat == .all ? "All" : String(cat.rawValue.split(separator: " ").first ?? Substring(cat.rawValue)))
                                                .font(.custom("HelveticaNeue-Medium", size: 13))
                                        }
                                        .foregroundColor(selectedCategory == cat ? .white : cat.color)
                                        .padding(.horizontal, 12).padding(.vertical, 7)
                                        .background(selectedCategory == cat ? cat.color : cat.color.opacity(0.1))
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // ── Group cards ──────────────────────────────
                        if filtered.isEmpty {
                            VStack(spacing: 12) {
                                Text("💬").font(.system(size: 40))
                                Text("No groups here yet")
                                    .font(.custom("HelveticaNeue-Bold", size: 17))
                                    .foregroundColor(.tsLabel)
                                Text("Be the first to add one for \(selectedCategory.rawValue.lowercased()) in this city.")
                                    .font(.custom("HelveticaNeue", size: 14))
                                    .foregroundColor(.tsSecondary)
                                    .multilineTextAlignment(.center)
                                Button(action: { showAddGroup = true }) {
                                    Text("Add a group")
                                        .font(.custom("HelveticaNeue-Bold", size: 15))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24).padding(.vertical, 10)
                                        .background(Color.tsAccent)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.top, 48).padding(.horizontal, 32)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filtered) { group in
                                    GroupCard(group: group) {
                                        // Report expired
                                        if let idx = groups.firstIndex(where: { $0.id == group.id }) {
                                            groups[idx].expiredReports += 1
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // ── Footer note ──────────────────────────────
                        VStack(spacing: 4) {
                            Text("Groups are community-submitted. TalkSwitch doesn't moderate content.")
                                .font(.custom("HelveticaNeue", size: 11))
                                .foregroundColor(.tsSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 80)
                    }
                    .padding(.top, 12)
                }

                // ── FAB ──────────────────────────────────────────────
                Button(action: { showAddGroup = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                        Text("Add Group")
                            .font(.custom("HelveticaNeue-Bold", size: 15))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20).padding(.vertical, 14)
                    .background(Color.tsAccent)
                    .clipShape(Capsule())
                    .shadow(color: Color.tsAccent.opacity(0.4), radius: 12, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 32)
            }
            .navigationTitle("WhatsApp Groups")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showAddGroup) {
            AddGroupSheet { newGroup in groups.insert(newGroup, at: 0) }
        }
    }
}

// MARK: - Group Card
struct GroupCard: View {
    let group:    CommunityGroup
    let onReport: () -> Void

    @State private var showReportAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(group.category.color.opacity(0.12))
                        .frame(width: 46, height: 46)
                    Text(group.category.emoji).font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(group.name)
                            .font(.custom("HelveticaNeue-Bold", size: 16))
                            .foregroundColor(.tsLabel)
                        if group.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.tsAccent)
                        }
                    }
                    HStack(spacing: 8) {
                        Text(group.category.rawValue)
                            .font(.custom("HelveticaNeue-Medium", size: 11))
                            .foregroundColor(group.category.color)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(group.category.color.opacity(0.1))
                            .clipShape(Capsule())
                        Text(group.language)
                            .font(.custom("HelveticaNeue", size: 11))
                            .foregroundColor(.tsSecondary)
                        if let members = group.formattedMembers as String?, !members.isEmpty {
                            HStack(spacing: 3) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 10))
                                Text(members)
                                    .font(.custom("HelveticaNeue-Medium", size: 11))
                            }
                            .foregroundColor(.tsSecondary)
                        }
                    }
                }
                Spacer()
            }

            // Description
            Text(group.description)
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.tsSecondary)
                .fixedSize(horizontal: false, vertical: true)

            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(group.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.custom("HelveticaNeue", size: 11))
                            .foregroundColor(.tsSecondary)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.tsInputBg)
                            .cornerRadius(6)
                    }
                }
            }

            // Action row
            HStack(spacing: 10) {
                // Join button
                Button(action: { joinGroup() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 13))
                        Text("Join on WhatsApp")
                            .font(.custom("HelveticaNeue-Bold", size: 14))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(Color(hex: "#25D366"))  // WhatsApp green
                    .cornerRadius(12)
                }

                // Report expired
                Button(action: { showReportAlert = true }) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 18))
                        .foregroundColor(.tsSecondary)
                        .frame(width: 42, height: 42)
                        .background(Color.tsInputBg)
                        .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .background(Color.tsCard)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        .alert("Report expired link?", isPresented: $showReportAlert) {
            Button("Report", role: .destructive) { onReport() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Flag this group's invite link as expired or broken.")
        }
    }

    private func joinGroup() {
        guard let url = URL(string: group.whatsappLink) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Add Group Sheet
struct AddGroupSheet: View {
    @Environment(\.dismiss) var dismiss
    let onAdd: (CommunityGroup) -> Void

    @State private var name        = ""
    @State private var description = ""
    @State private var link        = ""
    @State private var memberCount = ""
    @State private var language    = "EN"
    @State private var category: GroupCategory = .general
    @AppStorage("selected_city_id") private var cityId = "mx_cdmx"

    var linkValid: Bool {
        link.hasPrefix("https://chat.whatsapp.com/") && link.count > 30
    }
    var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        linkValid
    }

    private let languages = ["EN", "ES", "EN · ES", "PT", "FR", "DE", "Other"]

    var body: some View {
        NavigationStack {
            ZStack { Color.tsBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {

                        // ── How to get the link ────────────────────────
                        HStack(spacing: 12) {
                            Text("💡").font(.system(size: 22))
                            VStack(alignment: .leading, spacing: 3) {
                                Text("How to get your invite link")
                                    .font(.custom("HelveticaNeue-Bold", size: 13))
                                    .foregroundColor(.tsLabel)
                                Text("WhatsApp → Group → Group Info → Invite via Link → Copy Link")
                                    .font(.custom("HelveticaNeue", size: 12))
                                    .foregroundColor(.tsSecondary)
                            }
                        }
                        .padding(14)
                        .background(Color.tsAccent.opacity(0.06))
                        .cornerRadius(14)

                        // ── Fields ─────────────────────────────────────
                        VStack(spacing: 14) {
                            AddGroupField(label: "Group name", placeholder: "e.g. CDMX Nomads", text: $name)
                            AddGroupField(label: "Description", placeholder: "What's this group about? Who should join?", text: $description, multiline: true)

                            // WhatsApp link
                            VStack(alignment: .leading, spacing: 6) {
                                Text("WhatsApp invite link")
                                    .font(.custom("HelveticaNeue-Bold", size: 13))
                                    .foregroundColor(.tsSecondary)
                                HStack(spacing: 8) {
                                    Image(systemName: "link")
                                        .foregroundColor(linkValid ? Color(hex: "#25D366") : .tsSecondary)
                                        .font(.system(size: 14))
                                    TextField("https://chat.whatsapp.com/...", text: $link)
                                        .font(.custom("HelveticaNeue", size: 14))
                                        .foregroundColor(.tsLabel)
                                        .autocorrectionDisabled()
                                        .textInputAutocapitalization(.never)
                                }
                                .padding(12)
                                .background(Color.tsCard)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12)
                                    .stroke(linkValid ? Color(hex: "#25D366").opacity(0.4) : Color.tsAccent.opacity(0.08), lineWidth: 1))
                                if !link.isEmpty && !linkValid {
                                    Text("Must start with https://chat.whatsapp.com/")
                                        .font(.custom("HelveticaNeue", size: 12))
                                        .foregroundColor(Color(hex: "#FF3B30"))
                                }
                            }

                            // Category
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Category")
                                    .font(.custom("HelveticaNeue-Bold", size: 13))
                                    .foregroundColor(.tsSecondary)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(GroupCategory.allCases.filter { $0 != .all }) { cat in
                                            Button(action: { category = cat }) {
                                                HStack(spacing: 4) {
                                                    Text(cat.emoji).font(.system(size: 12))
                                                    Text(String(cat.rawValue.split(separator: " ").first ?? Substring(cat.rawValue)))
                                                        .font(.custom("HelveticaNeue-Medium", size: 12))
                                                }
                                                .foregroundColor(category == cat ? .white : cat.color)
                                                .padding(.horizontal, 12).padding(.vertical, 7)
                                                .background(category == cat ? cat.color : cat.color.opacity(0.1))
                                                .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }
                            }

                            // Language + Member count
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Language")
                                        .font(.custom("HelveticaNeue-Bold", size: 13))
                                        .foregroundColor(.tsSecondary)
                                    Menu {
                                        ForEach(languages, id: \.self) { l in
                                            Button(l) { language = l }
                                        }
                                    } label: {
                                        HStack {
                                            Text(language)
                                                .font(.custom("HelveticaNeue-Medium", size: 14))
                                                .foregroundColor(.tsLabel)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 11))
                                                .foregroundColor(.tsSecondary)
                                        }
                                        .padding(12)
                                        .background(Color.tsCard)
                                        .cornerRadius(12)
                                        .overlay(RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
                                    }
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Members (optional)")
                                        .font(.custom("HelveticaNeue-Bold", size: 13))
                                        .foregroundColor(.tsSecondary)
                                    TextField("~200", text: $memberCount)
                                        .font(.custom("HelveticaNeue", size: 14))
                                        .foregroundColor(.tsLabel)
                                        .keyboardType(.numberPad)
                                        .padding(12)
                                        .background(Color.tsCard)
                                        .cornerRadius(12)
                                        .overlay(RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
                                }
                            }
                        }

                        // ── Disclaimer ─────────────────────────────────
                        Text("By submitting you confirm this is a real group and you have permission to share the invite link.")
                            .font(.custom("HelveticaNeue", size: 12))
                            .foregroundColor(.tsSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Add a Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundColor(.tsSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: submit) {
                        Text("Submit")
                            .font(.custom("HelveticaNeue-Bold", size: 15))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16).padding(.vertical, 6)
                            .background(canSubmit ? Color(hex: "#25D366") : Color.tsSecondary.opacity(0.3))
                            .clipShape(Capsule())
                    }
                    .disabled(!canSubmit)
                }
            }
        }
    }

    private func submit() {
        let group = CommunityGroup(
            id: UUID().uuidString,
            name: name.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            category: category,
            cityId: cityId,
            language: language,
            memberCount: Int(memberCount),
            whatsappLink: link,
            addedBy: "You",
            isVerified: false,
            tags: []
        )
        onAdd(group)
        dismiss()
    }
}

// MARK: - Helper input field
struct AddGroupField: View {
    let label:       String
    let placeholder: String
    @Binding var text: String
    var multiline = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.custom("HelveticaNeue-Bold", size: 13))
                .foregroundColor(.tsSecondary)
            if multiline {
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .font(.custom("HelveticaNeue", size: 14))
                            .foregroundColor(.tsSecondary.opacity(0.5))
                            .padding(.horizontal, 14).padding(.top, 14)
                    }
                    TextEditor(text: $text)
                        .font(.custom("HelveticaNeue", size: 14))
                        .foregroundColor(.tsLabel)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 80)
                        .padding(10)
                }
                .background(Color.tsCard)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
            } else {
                TextField(placeholder, text: $text)
                    .font(.custom("HelveticaNeue", size: 14))
                    .foregroundColor(.tsLabel)
                    .padding(12)
                    .background(Color.tsCard)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
            }
        }
    }
}
