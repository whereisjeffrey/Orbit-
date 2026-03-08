//  CommunityView.swift

import SwiftUI

enum PostType: String, CaseIterable {
    case all       = "All"
    case question  = "Questions"
    case rec       = "Recs"
    case warning   = "Warnings"
    case event     = "Events"

    var emoji: String {
        switch self {
        case .all:      return "✨"
        case .question: return "💬"
        case .rec:      return "👍"
        case .warning:  return "⚠️"
        case .event:    return "📅"
        }
    }
    var color: Color {
        switch self {
        case .all:      return .tsAccent
        case .question: return .tsAccent
        case .rec:      return Color(hex: "#34C759")
        case .warning:  return Color(hex: "#FF9500")
        case .event:    return Color(hex: "#AF52DE")
        }
    }
    var icon: String {
        switch self {
        case .all:      return "sparkles"
        case .question: return "questionmark.circle.fill"
        case .rec:      return "star.fill"
        case .warning:  return "exclamationmark.triangle.fill"
        case .event:    return "calendar"
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
    var avatarInitials: String = ""
    var avatarColor: Color = .tsAccent
    var avatarURL: String? = nil
    var imageURL: String? = nil
    var linkPreviewTitle: String? = nil
    var linkPreviewSite: String? = nil
    var linkURL: String? = nil
    var instagramHandle: String? = nil
    var isPreset: Bool = false
}

struct CommunityView: View {
    @EnvironmentObject var auth: AuthManager
    @AppStorage("selected_city_id") private var selectedCityId: String = "mx_cdmx"
    @State private var selectedFilter: PostType = .all
    @State private var showGroupDirectory = false
    @State private var showAskALocal = false
    @State private var showCityPicker = false
    @State private var showCompose = false
    @State private var posts: [CommunityPost] = []

    var selectedCity: City { CityStore.city(id: selectedCityId) ?? CityStore.defaultCity }

    // Sample posts for skeleton
    let samplePosts: [CommunityPost] = [
        CommunityPost(author: "Marco R.", neighbourhood: "Condesa", type: .question,
                      body: "Anyone know a good English-speaking dentist in Roma Norte?",
                      likes: 7, comments: 3, timeAgo: "2h", isVerifiedLocal: false,
                      avatarInitials: "MR", avatarColor: Color(hex: "#FF9500"), avatarURL: "https://i.pravatar.cc/150?img=68", isPreset: true),
        CommunityPost(author: "Sarah K.", neighbourhood: "Polanco", type: .rec,
                      body: "Highly recommend Café Toscano for remote work — fast wifi, great coffee, never too crowded before noon.",
                      likes: 24, comments: 6, timeAgo: "5h", isVerifiedLocal: true,
                      avatarInitials: "SK", avatarColor: Color(hex: "#AF52DE"), avatarURL: "https://i.pravatar.cc/150?img=44",
                      imageURL: "https://picsum.photos/id/431/700/520", isPreset: true),
        CommunityPost(author: "Diego M.", neighbourhood: "Roma Norte", type: .warning,
                      body: "Watch out for fake taxi overcharges outside Benito Juárez airport. Always use DIDI or Uber from inside.",
                      likes: 89, comments: 12, timeAgo: "1d", isVerifiedLocal: true,
                      avatarInitials: "DM", avatarColor: Color(hex: "#34C759"), avatarURL: "https://i.pravatar.cc/150?img=12",
                      instagramHandle: "diego.nomad", isPreset: true),
        CommunityPost(author: "Lena W.", neighbourhood: "Coyoacán", type: .event,
                      body: "Expat meetup Friday night at Jardín Pushkin — 7pm. DM me if you\'re coming!",
                      likes: 31, comments: 8, timeAgo: "3h", isVerifiedLocal: false,
                      avatarInitials: "LW", avatarColor: Color(hex: "#FF2D55"),
                      imageURL: "https://picsum.photos/id/718/700/520", isPreset: true),
    ]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TSGradientBackground()

            ScrollView {
                VStack(spacing: 0) {

                    // ── Header ─────────────────────────────────────────
                    TSPageHeader(
                        title: "Community",
                        selectedCity: selectedCity,
                        bottomPadding: 16
                    ) {
                        showCityPicker = true
                    }

                    // ── Composer bar ────────────────────────────────────
                    PostComposerBar(onTap: { showCompose = true })
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)

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

                    // ── New in town ─────────────────────────────────────
                    NewInTownSection()
                        .padding(.bottom, 8)

                    // ── Post type filter ───────────────────────────────
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(PostType.allCases, id: \.self) { type in
                                FilterChip(
                                    label: type.rawValue,
                                    emoji: type.emoji,
                                    color: type.color,
                                    isSelected: selectedFilter == type
                                ) { selectedFilter = type }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 12)

                    // ── Feed ───────────────────────────────────────────
                    LazyVStack(spacing: 16) {
                        ForEach(posts.filter { p in
                        selectedFilter == .all || p.type == selectedFilter
                    }) { post in
                            CommunityPostCard(post: post)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 96)
                }
            }

            // ── FAB ────────────────────────────────────────────────────
            Button(action: { showCompose = true }) {
                Image(systemName: "plus")
                    .font(.custom("HelveticaNeue-Bold", size: 20))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.tsAccent)
                    .clipShape(Circle())
                    .shadow(color: Color.tsAccent.opacity(0.4), radius: 12, x: 0, y: 4)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 104)
        }
        .onAppear { if posts.isEmpty { posts = samplePosts } }
        .sheet(isPresented: $showGroupDirectory) { GroupDirectoryView() }
        .sheet(isPresented: $showAskALocal)     { AskALocalView() }
        .sheet(isPresented: $showCityPicker)    { CityPickerView(selectedId: $selectedCityId) }
        .sheet(isPresented: $showCompose) {
            ComposePostSheet { newPost in posts.insert(newPost, at: 0) }
                .environmentObject(auth)
        }
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
                    .font(.custom("HelveticaNeue-Medium", size: 13))
                Text(label)
                    .font(.custom("HelveticaNeue-Medium", size: 14))
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
    let emoji: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(emoji).font(.custom("HelveticaNeue", size: 13))
                Text(label).font(.custom("HelveticaNeue-Medium", size: 14))
            }
            .foregroundColor(isSelected ? .white : .tsLabel)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color.tsCard)
            .clipShape(Capsule())
        }
    }
}

struct CommunityPostCard: View {
    let post: CommunityPost
    @Environment(\.colorScheme) var colorScheme
    @State private var showProfile = false
    @State private var isLiked = false
    @State private var likeCount: Int
    @State private var showComments = false

    init(post: CommunityPost) {
        self.post = post
        _likeCount = State(initialValue: post.likes)
    }

    // Synthesise a CommunityUser from this post so the profile sheet has something to show
    private var postUser: CommunityUser {
        let parts = post.author.split(separator: " ")
        let first = parts.first.map(String.init) ?? post.author
        let last  = parts.dropFirst().first.map(String.init) ?? ""
        return CommunityUser(
            id: post.id.uuidString,
            firstName: first,
            lastName: last,
            cityId: "mx_cdmx",
            neighbourhood: post.neighbourhood,
            fromCity: "–",
            statusRaw: post.isVerifiedLocal ? "settling_in" : "new_arrival",
            daysInCity: 90,
            interests: [],
            instagramHandle: post.instagramHandle,
            linkedinHandle: nil,
            bio: "Community member in \(post.neighbourhood).",
            questionsAnswered: 0,
            isAvailableForLocal: false,
            isVisibleNewInTown: false,
            avatarURL: post.avatarURL
        )
    }

    // True if this is a standalone photo post (not a link preview)
    var hasPhoto: Bool {
        post.imageURL != nil && post.linkPreviewTitle == nil
    }

    @ViewBuilder var avatarView: some View {
        ZStack {
            Circle().fill(post.avatarColor).frame(width: 40, height: 40)
            if post.avatarInitials.isEmpty {
                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            } else {
                Text(post.avatarInitials)
                    .font(.custom("HelveticaNeue-Bold", size: 14))
                    .foregroundColor(.white)
            }
        }
    }

    @ViewBuilder var authorRow: some View {
        HStack(alignment: .top, spacing: 10) {
            // Avatar — tappable → opens profile sheet
            Button(action: { showProfile = true }) {
                Group {
                    if let urlStr = post.avatarURL, let url = URL(string: urlStr) {
                        AsyncImage(url: url) { phase in
                            if let img = phase.image {
                                img.resizable().scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else { avatarView }
                        }
                    } else { avatarView }
                }
                .frame(width: 40, height: 40)
            }
            .buttonStyle(PlainButtonStyle())

            VStack(alignment: .leading, spacing: 2) {
                // Author name — also tappable → opens profile
                Button(action: { showProfile = true }) {
                    HStack(spacing: 5) {
                        Text(post.author)
                            .font(.custom("HelveticaNeue-Bold", size: 14))
                            .foregroundColor(.tsLabel)
                        if post.isVerifiedLocal {
                            Text("Local")
                                .font(.custom("HelveticaNeue-Bold", size: 10))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color(hex: "#34C759"))
                                .clipShape(Capsule())
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Text("\(post.neighbourhood) · \(post.timeAgo)")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
            }
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: post.type.icon)
                    .font(.system(size: 9))
                Text(post.type.rawValue.dropLast())
                    .font(.custom("HelveticaNeue-Medium", size: 11))
            }
            .foregroundColor(post.type.color)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(post.type.color.opacity(0.1))
            .clipShape(Capsule())
        }
        // Single sheet bound to showProfile — placed on the outermost container
        .sheet(isPresented: $showProfile) { CommunityUserProfileView(user: postUser) }
    }

    @ViewBuilder var engagementRow: some View {
        HStack(spacing: 20) {
            // ── Like ────────────────────────────────────────────────────
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    isLiked.toggle()
                    likeCount += isLiked ? 1 : -1
                }
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 15))
                        .foregroundColor(isLiked ? Color(hex: "#FF3B30") : .tsSecondary)
                        .scaleEffect(isLiked ? 1.2 : 1.0)
                    Text("\(likeCount)")
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(isLiked ? Color(hex: "#FF3B30") : .tsSecondary)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isLiked)

            // ── Comment ─────────────────────────────────────────────────
            Button { showComments = true } label: {
                HStack(spacing: 5) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 15))
                        .foregroundColor(.tsSecondary)
                    Text("\(post.comments)")
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.tsSecondary)
                }
            }
            .sheet(isPresented: $showComments) {
                CommentsSheet(post: post)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }

            Spacer()

            // ── Message / DM ────────────────────────────────────────────
            Button { showProfile = true } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.tsAccent)
                    .padding(8)
                    .background(Color.tsAccent.opacity(0.1))
                    .clipShape(Circle())
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Photo at top (full bleed, square-ish) ────────────────
            if hasPhoto, let imgURL = post.imageURL, let url = URL(string: imgURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 260)
                            .clipped()
                            .clipShape(
                                UnevenRoundedRectangle(
                                    topLeadingRadius: 16,
                                    bottomLeadingRadius: 0,
                                    bottomTrailingRadius: 0,
                                    topTrailingRadius: 16
                                )
                            )
                    case .failure(_):
                        Rectangle()
                            .fill(Color.tsInputBg)
                            .frame(height: 260)
                    default:
                        Rectangle()
                            .fill(Color.tsInputBg.opacity(0.6))
                            .frame(height: 260)
                            .overlay(ProgressView().tint(.tsSecondary))
                    }
                }
            }

            // ── Card body ─────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 12) {

                // If photo post — author row floats over the seam
                if hasPhoto {
                    authorRow
                        .padding(.top, 4)
                } else {
                    authorRow
                }

                Text(post.body)
                    .font(.custom("HelveticaNeue", size: 15))
                    .foregroundColor(.tsLabel)
                    .fixedSize(horizontal: false, vertical: true)

                // Link preview (non-photo posts only)
                if !hasPhoto, let title = post.linkPreviewTitle {
                    LinkPreviewCard(preview: LinkPreview(
                        url: post.linkURL ?? "",
                        imageURL: post.imageURL,
                        title: title,
                        description: nil,
                        siteName: post.linkPreviewSite
                    ))
                }

                Divider().opacity(0.5)

                engagementRow
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 14)
        }
        .background(post.isPreset ? (colorScheme == .dark ? Color.tsCard : Color(UIColor.systemGray6).opacity(0.65)) : Color.tsCard)
        .cornerRadius(16)
        .overlay(
            Group {
                if !post.isPreset {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5)
                }
            }
        )
        .shadow(color: Color.black.opacity(post.isPreset ? 0 : 0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Comments Sheet

private struct SeedComment: Identifiable {
    let id = UUID()
    let author: String
    let avatarURL: String?
    let avatarColor: Color
    let timeAgo: String
    let body: String
    var isLiked: Bool = false
}

struct CommentsSheet: View {
    let post: CommunityPost
    @Environment(\.dismiss) var dismiss
    @State private var replyText: String = ""
    @State private var comments: [SeedComment]
    @FocusState private var inputFocused: Bool

    init(post: CommunityPost) {
        self.post = post
        // Seed a couple of plausible comments per post
        _comments = State(initialValue: [
            SeedComment(author: "Elena V.", avatarURL: "https://i.pravatar.cc/150?img=33",
                        avatarColor: Color(hex: "#AF52DE"), timeAgo: "45m",
                        body: "Thanks for the heads-up! Almost got caught doing exactly this last month 😩"),
            SeedComment(author: "Tom W.", avatarURL: "https://i.pravatar.cc/150?img=59",
                        avatarColor: Color(hex: "#007AFF"), timeAgo: "2h",
                        body: "DIDI is way better anyway — the Siempre Plus category is basically a taxi but cheaper."),
            SeedComment(author: "Priya S.", avatarURL: "https://i.pravatar.cc/150?img=47",
                        avatarColor: Color(hex: "#FF9500"), timeAgo: "3h",
                        body: "Can confirm — the official booth inside the terminal is the only safe option."),
        ])
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                TSGradientBackground()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {

                            // ── Original post excerpt ──────────────────────
                            HStack(alignment: .top, spacing: 10) {
                                Group {
                                    if let urlStr = post.avatarURL, let url = URL(string: urlStr) {
                                        AsyncImage(url: url) { phase in
                                            if let img = phase.image {
                                                img.resizable().scaledToFill()
                                                    .frame(width: 36, height: 36).clipShape(Circle())
                                            } else { fallbackAvatar }
                                        }
                                    } else { fallbackAvatar }
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(post.author)
                                        .font(.custom("HelveticaNeue-Bold", size: 14))
                                        .foregroundColor(.tsLabel)
                                    Text(post.body)
                                        .font(.custom("HelveticaNeue", size: 14))
                                        .foregroundColor(.tsLabel)
                                        .lineLimit(3)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)

                            Divider().opacity(0.4)

                            // ── Comments list ──────────────────────────────
                            ForEach($comments) { $comment in
                                CommentRow(comment: $comment)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                Divider().opacity(0.3).padding(.leading, 62)
                            }

                            // Bottom padding so content clears the input bar
                            Color.clear.frame(height: 80)
                        }
                    }

                    // ── Reply input ────────────────────────────────────────
                    HStack(spacing: 10) {
                        TextField("Add a comment…", text: $replyText)
                            .font(.custom("HelveticaNeue", size: 15))
                            .foregroundColor(.tsLabel)
                            .focused($inputFocused)
                            .submitLabel(.send)
                            .onSubmit { sendComment() }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.tsCard)
                            .cornerRadius(22)
                            .overlay(RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.tsSecondary.opacity(0.15), lineWidth: 0.5))

                        if !replyText.isEmpty {
                            Button(action: sendComment) {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .frame(width: 38, height: 38)
                                    .background(Color.tsAccent)
                                    .clipShape(Circle())
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .animation(.spring(response: 0.3), value: replyText.isEmpty)
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }.foregroundColor(.tsAccent)
                }
            }
        }
    }

    private var fallbackAvatar: some View {
        ZStack {
            Circle().fill(post.avatarColor).frame(width: 36, height: 36)
            Text(post.avatarInitials.prefix(2))
                .font(.custom("HelveticaNeue-Bold", size: 13))
                .foregroundColor(.white)
        }
    }

    private func sendComment() {
        guard !replyText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let new = SeedComment(author: "You", avatarURL: nil,
                              avatarColor: .tsAccent, timeAgo: "just now",
                              body: replyText)
        withAnimation { comments.insert(new, at: 0) }
        replyText = ""
        let g = UIImpactFeedbackGenerator(style: .light)
        g.impactOccurred()
    }
}

private struct CommentRow: View {
    @Binding var comment: SeedComment

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Group {
                if let urlStr = comment.avatarURL, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        if let img = phase.image {
                            img.resizable().scaledToFill()
                                .frame(width: 36, height: 36).clipShape(Circle())
                        } else { fallback }
                    }
                } else { fallback }
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(comment.author)
                        .font(.custom("HelveticaNeue-Bold", size: 13))
                        .foregroundColor(.tsLabel)
                    Text("·")
                        .foregroundColor(.tsSecondary)
                    Text(comment.timeAgo)
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(.tsSecondary)
                }
                Text(comment.body)
                    .font(.custom("HelveticaNeue", size: 14))
                    .foregroundColor(.tsLabel)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    comment.isLiked.toggle()
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: comment.isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 14))
                    .foregroundColor(comment.isLiked ? Color(hex: "#FF3B30") : .tsSecondary)
                    .scaleEffect(comment.isLiked ? 1.2 : 1.0)
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: comment.isLiked)
        }
    }

    private var fallback: some View {
        ZStack {
            Circle().fill(comment.avatarColor).frame(width: 36, height: 36)
            Text(String(comment.author.prefix(1)))
                .font(.custom("HelveticaNeue-Bold", size: 14))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Placeholder sheets


struct CityPickerView: View {
    @Binding var selectedId: String
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            List(CityStore.all) { city in
                Button(action: { selectedId = city.id; dismiss() }) {
                    HStack {
                        Text(city.emoji + " " + city.name)
                            .font(.custom("HelveticaNeue", size: 16))
                            .foregroundColor(.tsLabel)
                        Spacer()
                        if city.id == selectedId {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.tsAccent)
                        }
                    }
                }
                .listRowBackground(Color.tsCard)
            }
            .scrollContentBackground(.hidden)
            .background(Color.tsBackground)
            .navigationTitle("Choose City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.tsAccent)
                }
            }
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

// GroupDirectoryView is in GroupDirectory.swift


// MARK: - Post Composer Bar
struct PostComposerBar: View {
    @EnvironmentObject var auth: AuthManager
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                MiniAvatar(auth: auth, size: 36)
                Rectangle()
                    .fill(Color.tsSecondary.opacity(0.12))
                    .frame(width: 1, height: 24)
                Text("What's on your mind?")
                    .font(.custom("HelveticaNeue", size: 15))
                    .foregroundColor(.tsSecondary.opacity(0.6))
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.tsAccent.opacity(0.15))
                        .frame(width: 34, height: 34)
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 15))
                        .foregroundColor(.tsAccent)
                }
            }
            .padding(.leading, 14)
            .padding(.trailing, 10)
            .padding(.vertical, 10)
            .background(colorScheme == .dark ? Color.tsCard : Color.white)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(
                Color.tsSecondary.opacity(0.15),
                lineWidth: 0.5))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
