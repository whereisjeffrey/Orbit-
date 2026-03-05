//  CommunityUserProfileView.swift

import SwiftUI

struct CommunityUserProfileView: View {
    let user: CommunityUser
    @Environment(\.dismiss) var dismiss
    @State private var showMessageRequest = false

    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                ScrollView {
                    VStack(spacing: 0) {

                        // ── Avatar + name block ────────────────────
                        VStack(spacing: 12) {
                            ZStack {
                                Circle().fill(user.initialsColor).frame(width: 88, height: 88)
                                Text(user.initials)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 24)

                            Text(user.displayName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.tsLabel)

                            TrustBadge(level: user.trustLevel)

                            Text(user.neighbourhood + " · " + user.timeInCityLabel + " · From " + user.fromCity)
                                .font(.system(size: 13))
                                .foregroundColor(.tsSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 24)

                        // ── Bio ────────────────────────────────────
                        Text(user.bio)
                            .font(.system(size: 15))
                            .foregroundColor(.tsLabel)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 24)

                        // ── Stats ──────────────────────────────────
                        if user.questionsAnswered > 0 {
                            HStack(spacing: 0) {
                                ProfileStat(value: "\(user.questionsAnswered)", label: "Answers")
                                Divider().frame(height: 36).background(Color.tsBorder)
                                ProfileStat(value: user.trustLevel.label, label: "Status")
                            }
                            .background(Color.tsCard)
                            .cornerRadius(16)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        }

                        // ── Interests ──────────────────────────────
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Into")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.tsSecondary)
                                .padding(.horizontal, 24)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(user.interests, id: \.self) { id in
                                    if let interest = allInterests.first(where: { $0.id == id }) {
                                        HStack(spacing: 4) {
                                            Text(interest.emoji)
                                            Text(interest.label)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.tsLabel)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.tsCard)
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 24)

                        // ── Social links ───────────────────────────
                        if user.instagramHandle != nil || user.linkedinHandle != nil {
                            VStack(spacing: 8) {
                                if let ig = user.instagramHandle {
                                    SocialLinkRow(icon: "camera", color: Color(hex: "#E1306C"), handle: "@\(ig)") {
                                        if let url = URL(string: "https://instagram.com/\(ig)") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                }
                                if let li = user.linkedinHandle {
                                    SocialLinkRow(icon: "briefcase", color: Color(hex: "#0A66C2"), handle: li) {
                                        if let url = URL(string: "https://linkedin.com/in/\(li)") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        }

                        // ── CTA ────────────────────────────────────
                        TSButton(title: "Send a message request") {
                            showMessageRequest = true
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 48)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }}
            .alert("Request sent", isPresented: $showMessageRequest) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("\(user.firstName) will be notified. They can accept or ignore your request.")
            }
        }
    }
}

struct ProfileStat: View {
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.tsLabel)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.tsSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

struct SocialLinkRow: View {
    let icon: String
    let color: Color
    let handle: String
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                Text(handle)
                    .font(.system(size: 15))
                    .foregroundColor(.tsAccent)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundColor(.tsSecondary)
            }
            .padding(12)
            .background(Color.tsCard)
            .cornerRadius(12)
        }
    }
}
