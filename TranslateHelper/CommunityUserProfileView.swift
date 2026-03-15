//  CommunityUserProfileView.swift

import SwiftUI

struct CommunityUserProfileView: View {
    let user: CommunityUser
    @Environment(\..dismiss) var dismiss
    @State private var showMessageRequest = false
    @State private var showUpgrade = false
    @ObservedObject private var sub = SubscriptionManager.shared

    var body: some View {
        NavigationStack {
            ZStack { Color.tsBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 0) {

                        // ── Avatar ────────────────────────────────────────
                        ZStack {
                            if let urlStr = user.avatarURL, let url = URL(string: urlStr) {
                                AsyncImage(url: url) { phase in
                                    if let img = phase.image {
                                        img.resizable().scaledToFill()
                                            .frame(width: 88, height: 88)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.tsCard, lineWidth: 3))
                                    } else {
                                        initialsCircle
                                    }
                                }
                            } else {
                                initialsCircle
                            }
                        }
                        .frame(width: 88, height: 88)
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                        .padding(.top, 28)
                        .padding(.bottom, 14)

                        // ── Name ──────────────────────────────────────────
                        Text(user.displayName)
                            .font(.custom("HelveticaNeue-Bold", size: 24))
                            .foregroundColor(.tsLabel)
                            .padding(.bottom, 10)

                        // ── Badges row ────────────────────────────────────
                        HStack(spacing: 8) {
                            // Trust level — yellow
                            Text(user.trustLevel.label)
                                .font(.custom("HelveticaNeue-Bold", size: 11))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Color(hex: "#FFD60A"))
                                .clipShape(Capsule())

                            // Answer count — teal
                            if user.questionsAnswered > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "text.bubble.fill")
                                        .font(.system(size: 10))
                                    Text("\(user.questionsAnswered) answers")
                                        .font(.custom("HelveticaNeue-Bold", size: 11))
                                }
                                .foregroundColor(Color(hex: "#30D158"))
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Color(hex: "#30D158").opacity(0.12))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.bottom, 10)

                        // ── Location subtitle ─────────────────────────────
                        Text(user.neighbourhood + " · " + user.timeInCityLabel + " · From " + user.fromCity)
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 20)

                        // ── Bio ───────────────────────────────────────────
                        Text(user.bio)
                            .font(.custom("HelveticaNeue", size: 15))
                            .foregroundColor(.tsLabel)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 28)

                        // ── Interests ─────────────────────────────────────
                        if !user.interests.isEmpty {
                            VStack(spacing: 10) {
                                Text("Into")
                                    .font(.custom("HelveticaNeue-Medium", size: 14))
                                    .foregroundColor(.tsSecondary)

                                LazyVGrid(
                                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                                    spacing: 8
                                ) {
                                    ForEach(user.interests, id: \.self) { id in
                                        if let interest = allInterests.first(where: { $0.id == id }) {
                                            HStack(spacing: 4) {
                                                Text(interest.emoji)
                                                Text(interest.label)
                                                    .font(.custom("HelveticaNeue-Medium", size: 12))
                                                    .foregroundColor(.tsLabel)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.8)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.horizontal, 10).padding(.vertical, 6)
                                            .background(Color.tsCard)
                                            .cornerRadius(10)
                                            .overlay(RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            .padding(.bottom, 28)
                        }

                        // ── Social links ──────────────────────────────────
                        if user.instagramHandle != nil || user.linkedinHandle != nil {
                            BlurGate(reason: .socialLinks) {
                                VStack(spacing: 8) {
                                    if let ig = user.instagramHandle {
                                        SocialLinkRow(
                                            iconView: AnyView(InstagramIcon()),
                                            handle: "@\(ig)"
                                        ) {
                                            if sub.isPro, let url = URL(string: "https://instagram.com/\(ig)") {
                                                UIApplication.shared.open(url)
                                            }
                                        }
                                    }
                                    if let li = user.linkedinHandle {
                                        SocialLinkRow(
                                            iconView: AnyView(
                                                Image(systemName: "briefcase.fill")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white)
                                                    .frame(width: 28, height: 28)
                                                    .background(Color(hex: "#0A66C2"))
                                                    .clipShape(RoundedRectangle(cornerRadius: 7))
                                            ),
                                            handle: li
                                        ) {
                                            if sub.isPro, let url = URL(string: "https://linkedin.com/in/\(li)") {
                                                UIApplication.shared.open(url)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        }

                        // ── Message request CTA ───────────────────────────
                        Button {
                            if sub.isPro { showMessageRequest = true }
                            else         { showUpgrade = true }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: sub.isPro ? "paperplane.fill" : "lock.fill")
                                    .font(.system(size: 14))
                                Text(sub.isPro ? "Send a message request" : "Send a message request")
                                    .font(.custom("HelveticaNeue-Bold", size: 16))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                sub.isPro
                                ? AnyShapeStyle(LinearGradient(
                                    colors: [Color(hex: "#3B99FC"), Color(hex: "#007AFF")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                  ))
                                : AnyShapeStyle(Color.tsSecondary.opacity(0.35))
                            )
                            .cornerRadius(16)
                            .overlay(
                                Group {
                                    if !sub.isPro {
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.tsSecondary.opacity(0.2), lineWidth: 1)
                                    }
                                }
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 48)
                        .sheet(isPresented: $showUpgrade) {
                            UpgradeSheet(reason: .messaging).presentationDetents([.large])
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Request sent", isPresented: $showMessageRequest) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("\(user.firstName) will be notified. They can accept or ignore your request.")
            }
        }
    }

    @ViewBuilder private var initialsCircle: some View {
        ZStack {
            Circle().fill(user.initialsColor).frame(width: 88, height: 88)
            Text(user.initials)
                .font(.custom("HelveticaNeue-Bold", size: 32))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Instagram gradient icon
struct InstagramIcon: View {
    var body: some View {
        Image(systemName: "camera.fill")
            .font(.system(size: 14))
            .foregroundColor(.white)
            .frame(width: 28, height: 28)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "#F58529"),
                        Color(hex: "#DD2A7B"),
                        Color(hex: "#8134AF")
                    ],
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

// MARK: - Profile stat / social row
struct ProfileStat: View {
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("HelveticaNeue-Bold", size: 17))
                .foregroundColor(.tsLabel)
            Text(label)
                .font(.custom("HelveticaNeue", size: 12))
                .foregroundColor(.tsSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

struct SocialLinkRow: View {
    let iconView: AnyView
    let handle: String
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                iconView
                Text(handle)
                    .font(.custom("HelveticaNeue", size: 15))
                    .foregroundColor(.tsAccent)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
            }
            .padding(12)
            .background(Color.tsCard)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
    }
}
