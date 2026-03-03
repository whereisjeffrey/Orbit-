
//
//  UserLocationsStore.swift
//  TranslateHelper
//
//  Shared model for the user's ordered list of learning locations.
//  Stored in App Group UserDefaults so both the main app and keyboard
//  extension can read location context for slang distribution.
//

import Foundation
import Combine
import SwiftUI

struct UserLearningLocation: Codable, Identifiable, Equatable {
    var id: UUID
    var displayName: String // e.g. "Buenos Aires, Argentina"
    var city: String        // e.g. "Buenos Aires"
    var country: String     // e.g. "Argentina"

    init(id: UUID = UUID(), displayName: String, city: String = "", country: String = "") {
        self.id = id
        self.displayName = displayName
        // Parse city/country from displayName if not explicitly provided
        if city.isEmpty || country.isEmpty {
            let parts = displayName.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            self.city = city.isEmpty ? (parts.first ?? displayName) : city
            self.country = country.isEmpty ? (parts.last ?? "") : country
        } else {
            self.city = city
            self.country = country
        }
    }
}

class UserLocationsStore: ObservableObject {
    static let shared = UserLocationsStore()

    private static let appGroup = "group.com.jeff.translatehelper"
    private static let defaultsKey = "talkswitch_learning_locations"

    @Published var locations: [UserLearningLocation] = []

    private let defaults: UserDefaults?

    private init() {
        self.defaults = UserDefaults(suiteName: Self.appGroup)
        load()
    }

    // MARK: - Load / Save

    func load() {
        guard let data = defaults?.data(forKey: Self.defaultsKey),
              let decoded = try? JSONDecoder().decode([UserLearningLocation].self, from: data)
        else {
            // Legacy migration: if there's an old single-string location, import it
            if let legacyLocation = defaults?.string(forKey: "talkswitch_location"),
               !legacyLocation.isEmpty {
                let loc = UserLearningLocation(displayName: legacyLocation)
                locations = [loc]
                persist()
            }
            return
        }
        locations = decoded
    }

    func persist() {
        if let data = try? JSONEncoder().encode(locations) {
            defaults?.set(data, forKey: Self.defaultsKey)
            defaults?.synchronize()
        }
    }

    // MARK: - Mutations

    func add(_ location: UserLearningLocation) {
        guard locations.count < 4 else { return }
        guard !locations.contains(where: { $0.displayName.lowercased() == location.displayName.lowercased() }) else { return }
        locations.append(location)
        persist()
    }

    func remove(at offsets: IndexSet) {
        locations.remove(atOffsets: offsets)
        persist()
    }

    func move(from source: IndexSet, to destination: Int) {
        locations.move(fromOffsets: source, toOffset: destination)
        persist()
    }

    func update(_ location: UserLearningLocation) {
        if let idx = locations.firstIndex(where: { $0.id == location.id }) {
            locations[idx] = location
            persist()
        }
    }

    // MARK: - Prompt Context

    /// Returns a compact string for injection into LLM prompts.
    /// Primary location has highest weight, subsequent ones are secondary.
    var promptContext: String? {
        guard !locations.isEmpty else { return nil }
        if locations.count == 1 {
            let loc = locations[0]
            return "The user is currently learning in \(loc.displayName) (primary location: \(loc.city), \(loc.country))."
        } else {
            let primary = locations[0]
            let others = locations.dropFirst().map { $0.displayName }.joined(separator: ", ")
            return "The user spends time learning in multiple locations. Primary: \(primary.displayName). Also: \(others). The primary location carries the highest relevance for slang."
        }
    }
}
