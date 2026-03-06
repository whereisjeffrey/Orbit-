//  ProfilePhotoManager.swift
//  Wandr

import SwiftUI
import Combine

/// Manages the user's profile photo with a clear priority chain:
///   1. Custom photo (camera / photo library — always wins)
///   2. Google Sign-In photo (Firebase auth.photoURL — populated on Google login)
///   3. (future) Instagram OAuth photo  — plug in here when IG Basic Display API is wired
///   4. (future) Facebook OAuth photo   — plug in here when FB Login SDK is wired
///   5. (future) LinkedIn OAuth photo   — plug in here when LinkedIn SDK is wired
///   6. Initials fallback

class ProfilePhotoManager: ObservableObject {
    static let shared = ProfilePhotoManager()

    @Published var customPhoto: UIImage? = nil

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("wandr_profile_photo.jpg")
    }

    init() { loadFromDisk() }

    func save(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.85) {
            try? data.write(to: fileURL, options: .atomic)
        }
        customPhoto = image
    }

    func clear() {
        try? FileManager.default.removeItem(at: fileURL)
        customPhoto = nil
    }

    private func loadFromDisk() {
        guard let data = try? Data(contentsOf: fileURL),
              let img = UIImage(data: data) else { return }
        customPhoto = img
    }
}
