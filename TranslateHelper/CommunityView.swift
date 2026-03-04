//  CommunityView.swift

import SwiftUI

enum PostType: String, CaseIterable {
    case all       = "All"
    case question  = "Questions"
    case rec       = "Recs"
    case warning   = "Warnings"
    case event     = "Events"

    var icon: String {
        switch self {
        case .all:      return "square.grid.2x2"
        case .question: return "questionmark.bubble"
        case .rec:      return "hand.thumbsup"
        case .warning:  return "exclamationmark.triangle"
        case .event:    return "calendar"
        }
    }
    var color: Color {
        switch self {
        case .all:      return .tsAccent
        case .question: return Color(hex: "#007AFF")
        case .rec:      return Color(hex: "#34C759")
        case .warning:  return Color(hex: "#FF9500")
        case .event:    return Color(hex: "#AF52DE")
        }
    }
}

struct CommunityPost: Identifiable {
    let id = UUID()
    let author: String
    let neighbourhood: String
    let type: PostType
    let body: String
    let likes: Int
    let comments: Int
    let timeAgo: String
    var isVerifiedLocal: Bool = false
}

struct CommunityView: View {
    @AppStorage("selected_city_id") private var selectedCityId: String = "mx_cdmx"
    @State private var selectedFilter: PostType = .all
    @State private var showGroupDirectory = false
    @State private var showAskALocal = false
    @State private var showCityPicker = false
    @State private var showNewPost = false

    var selectedCity: City { CityStore.city(id: selectedCityId) ?? CityStore.defaultCity }

    // Sample posts for skeleton
    let samplePosts: [CommunityPost] = [
        CommunityPost(author: "Marco R.", neighbourhood: "Condesa", type: .question,
                      body: "Anyone know a good English-speaking dentist in Roma Norte?",
                      likes: 7, comments: 3, timeAgo: "2h", isVerifiedLocal: false),
        CommunityPost(author: "Sarah K.", neighbourhood: "Polanco", type: .rec,
                      body: "Highly recommend Café Toscano for remote work — fast wifi, great coffee, never too crowded before noon.",
                      likes: 24, comments: 6, timeAgo: "5h", isVerifiedLocal: true),
        CommunityPost(author: "Diego M.", neighbourhood: "Roma Norte", type: .warning,
                      body: "Watch out for fake taxi overcharges outside Benito Juárez airport. Always use DIDI or Uber from inside.",
                      likes: 89, comments: 12, timeAgo: "1d", isVerifiedLocal: true),
        CommunityPost(author: "Lena W.", neighbourhood: "Coyoacán", type: .event,
                      body: "Expat meetup Friday night at Jardín Pushkin — 7pm. DM me if you\'re coming!",
                      likes: 31, comments: 8, timeAgo: "3h", isVerifiedLocal: false),
    ]

    var filteredPosts: [CommunityPost] {
        selectedFilter == .all ? samplePosts : samplePosts.filter { $0.type == selectedFilter }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TSGradientBackground()

            ScrollView {
                VStack(spacing: 0) {

                    // ── Header ─────────────────────────────────────────
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Community")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.tsLabel)
                            Button(action: { showCityPicker = true }) {
                                HStack(spacing: 4) {
                                    Text(selectedCity.emoji)
                                        .font(.system(size: 13))
                                    Text(selectedCity.name)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.tsAccent)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 11))
                                        .foregroundColor(.tsAccent)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 16)

                    // ── Quick access pills ─────────────────────────────
                    HStack(spacing: 12) {
                        QuickAccessPill(icon: "person.2.fill", label: "Groups") {
                            showGroupDirectory = true
                        }
                        QuickAccessPill(icon: "bubble.left.and.bubble.right.fill", label: "Ask a Local") {
                            showAskALocal = true
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    // ── Post type filter ───────────────────────────────
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(PostType.allCases, id: \.self) { type in
                                FilterChip(
                                    label: type.rawValue,
                                    icon: type.icon,
                                    color: type.color,
                                    isSelected: selectedFilter == type
                                ) { selectedFilter = type }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 16)

                    // ── Feed ───────────────────────────────────────────
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPosts) { post in
                            CommunityPostCard(post: post)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 96)
                }
            }

            // ── FAB ────────────────────────────────────────────────────
            Button(action: { showNewPost = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#3B99FC"), Color(hex: "#007AFF")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: Color.tsAccent.opacity(0.4), radius: 12, x: 0, y: 4)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 88)
        }
        .sheet(isPresented: $showGroupDirectory) { GroupDirectoryView() }
        .sheet(isPresented: $showAskALocal)     { AskALocalView() }
        .sheet(isPresented: $showCityPicker)    { CityPickerView(selectedId: $selectedCityId) }
        .sheet(isPresented: $showNewPost)       { NewPostView() }
    }
}

// MARK: - Sub-components

struct QuickAccessPill: View {
    let icon: String
    let label: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.tsAccent)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.tsAccent.opacity(0.1))
            .clipShape(Capsule())
        }
    }
}

struct FilterChip: View {
    let label: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 11))
                Text(label).font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .tsLabel)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? color : Color.tsCard)
            .clipShape(Capsule())
        }
    }
}

struct CommunityPostCard: View {
    let post: CommunityPost
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(post.type.color.opacity(0.15))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: post.type.icon)
                            .font(.system(size: 14))
                            .foregroundColor(post.type.color)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(post.author)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.tsLabel)
                        if post.isVerifiedLocal {
                            Text("Local")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: "#34C759"))
                                .clipShape(Capsule())
                        }
                    }
                    Text("\(post.neighbourhood) · \(post.timeAgo)")
                        .font(.system(size: 12))
                        .foregroundColor(.tsSecondary)
                }
                Spacer()
                Text(post.type.rawValue.dropLast())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(post.type.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(post.type.color.opacity(0.1))
                    .clipShape(Capsule())
            }
            Text(post.body)
                .font(.system(size: 15))
                .foregroundColor(.tsLabel)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 16) {
                Label("\(post.likes)", systemImage: "heart")
                    .font(.system(size: 13))
                    .foregroundColor(.tsSecondary)
                Label("\(post.comments)", systemImage: "bubble.left")
                    .font(.system(size: 13))
                    .foregroundColor(.tsSecondary)
                Spacer()
            }
        }
        .padding(16)
        .background(Color.tsCard)
        .cornerRadius(16)
    }
}

// MARK: - Placeholder sheets
struct GroupDirectoryView: View {
    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                Text("Group Directory coming soon").foregroundColor(.tsSecondary)
            }
            .navigationTitle("Groups").navigationBarTitleDisplayMode(.inline)
        }
    }
}
struct AskALocalView: View {
    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                Text("Ask a Local coming soon").foregroundColor(.tsSecondary)
            }
            .navigationTitle("Ask a Local").navigationBarTitleDisplayMode(.inline)
        }
    }
}
struct CityPickerView: View {
    @Binding var selectedId: String
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            List(CityStore.all) { city in
                Button(action: { selectedId = city.id; dismiss() }) {
                    HStack {
                        Text(city.emoji + " " + city.name).foregroundColor(.tsLabel)
                        Spacer()
                        if city.id == selectedId {
                            Image(systemName: "checkmark").foregroundColor(.tsAccent)
                        }
                    }
                }
            }
            .navigationTitle("Choose City").navigationBarTitleDisplayMode(.inline)
        }
    }
}
struct NewPostView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                Text("New post coming soon").foregroundColor(.tsSecondary)
            }
            .navigationTitle("New Post").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }}
        }
    }
}
