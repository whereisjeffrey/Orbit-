//  PlacePhotoStore.swift
//  Central store for community-submitted place photos.
//
//  Architecture:
//  ┌─────────────────────────────────────────────────────┐
//  │  Seed photos    — baked into CoworkSpace / CafeSpace │
//  │  Community photos — stored here, keyed by place ID   │
//  │  allPhotos(for:seed:) — merges both for display      │
//  └─────────────────────────────────────────────────────┘
//
//  Future upgrade path:
//    1. Upload image → Firebase Storage  → get download URL
//    2. Save URL     → Firestore collection "place_photos/{placeId}"
//    3. Replace UserDefaults persistence with Firestore listener
//    4. submitPhoto(placeId:imageData:) already has the right signature

import Foundation
import Combine

struct PlacePhoto: Identifiable, Codable {
    let id:          String          // UUID
    let placeId:     String
    let url:         String          // remote download URL
    let submittedBy: String?         // Firebase UID (nil = anonymous)
    let submittedAt: Date
    var isApproved:  Bool = true     // set false when moderation is needed
}

@MainActor
class PlacePhotoStore: ObservableObject {
    static let shared = PlacePhotoStore()
    private init() { load() }

    @Published private(set) var photos: [PlacePhoto] = []

    private let key = "place_photos_v1"

    // MARK: - Query

    /// All URLs for a place — seed photos first, community on top.
    func allPhotos(for placeId: String, seed: [String] = []) -> [String] {
        let community = photos
            .filter { $0.placeId == placeId && $0.isApproved }
            .sorted { $0.submittedAt > $1.submittedAt }
            .map { $0.url }
        return seed + community
    }

    func communityCount(for placeId: String) -> Int {
        photos.filter { $0.placeId == placeId && $0.isApproved }.count
    }

    // MARK: - Submit
    //
    // Current: saves URL directly (caller must have already uploaded elsewhere).
    // Future:  accept Data + upload to Firebase Storage, then save the download URL.

    func addPhoto(placeId: String, url: String, submittedBy uid: String? = nil) {
        let p = PlacePhoto(
            id: UUID().uuidString,
            placeId: placeId,
            url: url,
            submittedBy: uid,
            submittedAt: Date()
        )
        photos.append(p)
        save()
    }

    // Stub for future Firebase Storage upload
    // func submitPhoto(placeId: String, imageData: Data, submittedBy uid: String?) async throws -> PlacePhoto {
    //     let storageRef = Storage.storage().reference().child("place_photos/\(placeId)/\(UUID().uuidString).jpg")
    //     _ = try await storageRef.putDataAsync(imageData)
    //     let url = try await storageRef.downloadURL()
    //     let photo = PlacePhoto(id: UUID().uuidString, placeId: placeId, url: url.absoluteString,
    //                            submittedBy: uid, submittedAt: Date())
    //     try await Firestore.firestore()
    //         .collection("place_photos").document(photo.id).setData(from: photo)
    //     photos.append(photo)
    //     return photo
    // }

    // MARK: - Persistence
    private func load() {
        guard let d = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([PlacePhoto].self, from: d) else { return }
        photos = decoded
    }

    private func save() {
        guard let d = try? JSONEncoder().encode(photos) else { return }
        UserDefaults.standard.set(d, forKey: key)
    }
}
