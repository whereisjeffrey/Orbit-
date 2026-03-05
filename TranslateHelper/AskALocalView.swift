//  AskALocalView.swift

import SwiftUI

struct AskALocalView: View {
    @AppStorage("selected_city_id") private var cityId = "mx_cdmx"
    @State private var selectedUser: CommunityUser? = nil
    @State private var filterInterest: String? = nil

    var locals: [CommunityUser] {
        seedCommunityUsers
            .filter { $0.cityId == cityId && $0.isAvailableForLocal }
            .filter { user in
                guard let f = filterInterest else { return true }
                return user.interests.contains(f)
            }
            .sorted { $0.questionsAnswered > $1.questionsAnswered }
    }

    let filterOptions: [(id: String, label: String, emoji: String)] = [
        ("remote_work", "Work",       "💻"),
        ("food",        "Food",       "🍽️"),
        ("nightlife",   "Nightlife",  "🎉"),
        ("arts",        "Arts",       "🎨"),
        ("outdoors",    "Outdoors",   "🏃"),
    ]

    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                VStack(spacing: 0) {
                    // ── Filter chips ───────────────────────────────
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(label: "All", emoji: "✨", color: .tsAccent, isSelected: filterInterest == nil) {
                                filterInterest = nil
                            }
                            ForEach(filterOptions, id: \.id) { opt in
                                FilterChip(
                                    label: opt.label,
                                    emoji: "•",
                                    color: .tsAccent,
                                    isSelected: filterInterest == opt.id
                                ) { filterInterest = filterInterest == opt.id ? nil : opt.id }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }

                    // ── Local list ─────────────────────────────────
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(locals) { user in
                                LocalCard(user: user) { selectedUser = user }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Ask a Local")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedUser) { user in CommunityUserProfileView(user: user) }
        }
    }
}

struct LocalCard: View {
    let user: CommunityUser
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Avatar
                ZStack {
                    Circle().fill(user.initialsColor).frame(width: 52, height: 52)
                    Text(user.initials)
                        .font(.custom("HelveticaNeue-Bold", size: 18))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Text(user.displayName)
                            .font(.custom("HelveticaNeue-Medium", size: 16))
                            .foregroundColor(.tsLabel)
                        TrustBadge(level: user.trustLevel)
                    }

                    Text(user.neighbourhood + " · " + user.timeInCityLabel)
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(.tsSecondary)

                    Text(user.bio)
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.tsSecondary)
                        .lineLimit(2)

                    // Interest pills
                    HStack(spacing: 6) {
                        ForEach(user.interests.prefix(3), id: \.self) { interest in
                            if let match = allInterests.first(where: { $0.id == interest }) {
                                Text(match.emoji + " " + match.label)
                                    .font(.custom("HelveticaNeue", size: 11))
                                    .foregroundColor(.tsSecondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.tsSecondary.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                Spacer()

                VStack(spacing: 4) {
                    Text("\(user.questionsAnswered)")
                        .font(.custom("HelveticaNeue-Bold", size: 18))
                        .foregroundColor(.tsAccent)
                    Text("answers")
                        .font(.custom("HelveticaNeue", size: 10))
                        .foregroundColor(.tsSecondary)
                }
            }
            .padding(16)
            .background(Color.tsCard)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.07), lineWidth: 0.5))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
