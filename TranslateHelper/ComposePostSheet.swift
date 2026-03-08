//  ComposePostSheet.swift

import SwiftUI
import PhotosUI

// MARK: - Compose Sheet
struct ComposePostSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var auth: AuthManager

    let onPost: (CommunityPost) -> Void

    @State private var bodyText    = ""
    @State private var linkText    = ""
    @State private var postType    = PostType.rec
    @State private var showLinkRow = false
    @State private var photoItem:  PhotosPickerItem? = nil
    @State private var pickedImage: UIImage?         = nil
    @State private var pickedImageURL: String?       = nil   // future: upload URL

    @StateObject private var linkFetcher = LinkPreviewFetcher()
    @FocusState private var bodyFocused: Bool

    var canPost: Bool { !bodyText.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                ScrollView {
                    VStack(spacing: 0) {

                        // ── Author row ──────────────────────────────
                        HStack(spacing: 12) {
                            MiniAvatar(auth: auth, size: 40)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(auth.displayName)
                                    .font(.custom("HelveticaNeue-Bold", size: 15))
                                    .foregroundColor(.tsLabel)
                                // Post type picker
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 6) {
                                        ForEach([PostType.rec, .question, .outing, .event, .warning], id: \.self) { t in
                                            Button(action: { postType = t }) {
                                                HStack(spacing: 4) {
                                                    Text(t.emoji).font(.system(size: 11))
                                                    Text(t.rawValue.dropLast())
                                                        .font(.custom("HelveticaNeue-Medium", size: 11))
                                                }
                                                .foregroundColor(postType == t ? .white : t.color)
                                                .padding(.horizontal, 10).padding(.vertical, 4)
                                                .background(postType == t ? t.color : t.color.opacity(0.1))
                                                .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                        // ── Body text ────────────────────────────────
                        ZStack(alignment: .topLeading) {
                            if bodyText.isEmpty {
                                Text(postType == .outing
                                     ? "Who's up for it? Where and when?"
                                     : "What's happening in \(auth.displayName.isEmpty ? "your city" : "the city")?")
                                    .font(.custom("HelveticaNeue", size: 16))
                                    .foregroundColor(.tsSecondary.opacity(0.6))
                                    .padding(.horizontal, 20)
                                    .padding(.top, 16)
                            }
                            TextEditor(text: $bodyText)
                                .font(.custom("HelveticaNeue", size: 16))
                                .foregroundColor(.tsLabel)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .padding(.horizontal, 14)
                                .frame(minHeight: 120)
                                .focused($bodyFocused)
                        }
                        .background(Color.tsCard)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                        .onAppear { bodyFocused = true }

                        // ── Picked photo preview ─────────────────────
                        if let img = pickedImage {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: img).resizable().scaledToFill()
                                    .frame(maxWidth: .infinity).frame(height: 200).clipped()
                                    .cornerRadius(16)
                                Button(action: { pickedImage = nil }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .shadow(radius: 4)
                                        .padding(8)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                        }

                        // ── Link row ─────────────────────────────────
                        if showLinkRow {
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "link").foregroundColor(.tsAccent).font(.system(size: 14))
                                    TextField("Paste a link...", text: $linkText)
                                        .font(.custom("HelveticaNeue", size: 14))
                                        .foregroundColor(.tsLabel)
                                        .autocorrectionDisabled()
                                        .textInputAutocapitalization(.never)
                                        .onChange(of: linkText) {
                                            Task { await linkFetcher.fetch(urlString: linkText) }
                                        }
                                    if !linkText.isEmpty {
                                        Button(action: { linkText = ""; linkFetcher.reset() }) {
                                            Image(systemName: "xmark.circle.fill").foregroundColor(.tsSecondary)
                                        }
                                    }
                                }
                                .padding(.horizontal, 12).padding(.vertical, 10)
                                .background(Color.tsCard)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tsAccent.opacity(0.15), lineWidth: 1))

                                // Preview card
                                if linkFetcher.isLoading {
                                    HStack { ProgressView(); Text("Loading preview...").font(.custom("HelveticaNeue", size: 13)).foregroundColor(.tsSecondary) }
                                        .padding(12)
                                } else if let p = linkFetcher.preview {
                                    LinkPreviewCard(preview: p)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                        }

                        // ── Action bar ───────────────────────────────
                        HStack(spacing: 20) {
                            // Photo picker
                            PhotosPicker(selection: $photoItem, matching: .images) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 20))
                                    .foregroundColor(.tsAccent)
                            }
                            .onChange(of: photoItem) {
                                Task {
                                    if let d = try? await photoItem?.loadTransferable(type: Data.self),
                                       let img = UIImage(data: d) {
                                        pickedImage = img
                                    }
                                }
                            }

                            // Link button
                            Button(action: { withAnimation { showLinkRow.toggle() } }) {
                                Image(systemName: showLinkRow ? "link.badge.minus" : "link")
                                    .font(.system(size: 20))
                                    .foregroundColor(showLinkRow ? .tsAccent : .tsSecondary)
                            }

                            Spacer()

                            // Character count
                            Text("\(bodyText.count)/300")
                                .font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(bodyText.count > 280 ? Color(hex: "#FF3B30") : .tsSecondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundColor(.tsSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: submitPost) {
                        Text("Post")
                            .font(.custom("HelveticaNeue-Bold", size: 16))
                            .foregroundColor(canPost ? .white : .white.opacity(0.5))
                            .padding(.horizontal, 16).padding(.vertical, 6)
                            .background(canPost ? Color.tsAccent : Color.tsAccent.opacity(0.4))
                            .clipShape(Capsule())
                    }
                    .disabled(!canPost)
                }
            }
        }
    }

    private func submitPost() {
        let imageURL = linkFetcher.preview?.imageURL
        let post = CommunityPost(
            author: auth.displayName,
            neighbourhood: "Your City",
            type: postType,
            body: bodyText.trimmingCharacters(in: .whitespaces),
            likes: 0, comments: 0, timeAgo: "Just now",
            isVerifiedLocal: false,
            avatarInitials: String(auth.displayName.prefix(2)).uppercased(),
            avatarColor: .tsAccent,
            avatarURL: auth.photoURL?.absoluteString,
            imageURL: imageURL,
            linkPreviewTitle: linkFetcher.preview?.title,
            linkPreviewSite: linkFetcher.preview?.siteName,
            linkURL: linkText.isEmpty ? nil : linkText
        )
        onPost(post)
        dismiss()
    }
}

// MARK: - Link Preview Card
struct LinkPreviewCard: View {
    let preview: LinkPreview
    var body: some View {
        HStack(spacing: 12) {
            if let imgURL = preview.imageURL, let url = URL(string: imgURL) {
                AsyncImage(url: url) { phase in
                    if let img = phase.image {
                        img.resizable().scaledToFill()
                            .frame(width: 72, height: 72).clipped().cornerRadius(10)
                    } else {
                        RoundedRectangle(cornerRadius: 10).fill(Color.tsInputBg)
                            .frame(width: 72, height: 72)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                if let site = preview.siteName {
                    Text(site.uppercased())
                        .font(.custom("HelveticaNeue-Bold", size: 10))
                        .foregroundColor(.tsAccent)
                        .tracking(0.8)
                }
                if let title = preview.title {
                    Text(title).font(.custom("HelveticaNeue-Bold", size: 13))
                        .foregroundColor(.tsLabel).lineLimit(2)
                }
                if let desc = preview.description {
                    Text(desc).font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(.tsSecondary).lineLimit(2)
                }
            }
            Spacer()
        }
        .padding(12)
        .background(Color.tsCard)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tsAccent.opacity(0.12), lineWidth: 1))
    }
}

// MARK: - Mini Avatar (shared)
struct MiniAvatar: View {
    let auth: AuthManager
    let size: CGFloat
    var body: some View {
        Group {
            if let url = auth.photoURL {
                AsyncImage(url: url) { phase in
                    if let img = phase.image {
                        img.resizable().scaledToFill()
                            .frame(width: size, height: size).clipShape(Circle())
                    } else { fallback }
                }
            } else { fallback }
        }
        .frame(width: size, height: size)
    }
    var fallback: some View {
        ZStack {
            Circle().fill(Color.tsAccent.opacity(0.15)).frame(width: size, height: size)
            Text(String(auth.displayName.prefix(2)).uppercased())
                .font(.custom("HelveticaNeue-Bold", size: size * 0.35))
                .foregroundColor(.tsAccent)
        }
    }
}
