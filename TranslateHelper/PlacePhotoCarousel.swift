//  PlacePhotoCarousel.swift
//  Reusable scrollable photo strip used by CoworkCard and CafeCard.

import SwiftUI

struct PlacePhotoCarousel: View {
    let placeId:    String
    let seedPhotos: [String]

    @ObservedObject private var store = PlacePhotoStore.shared
    @State private var showAddPhoto = false

    var allURLs: [String] { store.allPhotos(for: placeId, seed: seedPhotos) }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(Array(allURLs.enumerated()), id: \.offset) { _, urlStr in
                    if let url = URL(string: urlStr) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFill()
                                    .frame(width: 260, height: 140).clipped()
                            default:
                                ZStack {
                                    Color.tsInputBg
                                    Image(systemName: "photo")
                                        .foregroundColor(.tsSecondary)
                                }
                                .frame(width: 260, height: 140)
                            }
                        }
                        .frame(width: 260, height: 140).clipped()
                    }
                }

                // ── Add photo tile ─────────────────────────────
                Button(action: { showAddPhoto = true }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.tsAccent.opacity(0.08))
                            .frame(width: 100, height: 140)
                        VStack(spacing: 6) {
                            Image(systemName: "camera.badge.plus")
                                .font(.system(size: 22))
                                .foregroundColor(.tsAccent)
                            Text("Add\nphoto")
                                .font(.custom("HelveticaNeue-Medium", size: 12))
                                .foregroundColor(.tsAccent)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
        }
        .frame(height: 140)
        .clipShape(UnevenRoundedRectangle(
            topLeadingRadius: 16, bottomLeadingRadius: 0,
            bottomTrailingRadius: 0, topTrailingRadius: 16
        ))
        .sheet(isPresented: $showAddPhoto) {
            AddPlacePhotoSheet(placeId: placeId)
        }
    }
}

// MARK: - Add Photo Sheet
struct AddPlacePhotoSheet: View {
    let placeId: String
    @Environment(\.dismiss) var dismiss
    @State private var urlText = ""
    @State private var submitted = false

    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                VStack(spacing: 24) {
                    Spacer()

                    Image(systemName: "camera.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.tsAccent)

                    VStack(spacing: 8) {
                        Text("Add a photo")
                            .font(.custom("HelveticaNeue-Bold", size: 24))
                            .foregroundColor(.tsLabel)
                        Text("Share what this place actually looks like.\nHelps other nomads find it faster.")
                            .font(.custom("HelveticaNeue", size: 15))
                            .foregroundColor(.tsSecondary)
                            .multilineTextAlignment(.center)
                    }

                    // Paste URL — placeholder for real picker when Firebase Storage is ready
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Photo URL")
                            .font(.custom("HelveticaNeue-Medium", size: 13))
                            .foregroundColor(.tsSecondary)
                        TextField("https://...", text: $urlText)
                            .font(.custom("HelveticaNeue", size: 15))
                            .foregroundColor(.tsLabel)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .padding(12)
                            .background(Color.tsCard)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.tsAccent.opacity(0.2), lineWidth: 1))
                        Text("Camera roll upload coming soon — paste a URL for now.")
                            .font(.custom("HelveticaNeue", size: 12))
                            .foregroundColor(.tsSecondary)
                    }
                    .padding(.horizontal, 24)

                    // Submit
                    Button(action: submit) {
                        Text(submitted ? "✓ Added!" : "Submit photo")
                            .font(.custom("HelveticaNeue-Bold", size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(urlText.hasPrefix("http") ? Color.tsAccent : Color.tsSecondary.opacity(0.4))
                            .cornerRadius(14)
                    }
                    .disabled(!urlText.hasPrefix("http") || submitted)
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundColor(.tsAccent)
                }
            }
        }
    }

    private func submit() {
        guard urlText.hasPrefix("http") else { return }
        PlacePhotoStore.shared.addPhoto(placeId: placeId, url: urlText)
        submitted = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { dismiss() }
    }
}
