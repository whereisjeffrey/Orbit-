//  WorkTipStore.swift

import Foundation
import Combine

// MARK: - Models

struct WorkTip: Identifiable, Codable {
    let id:        String
    let placeId:   String
    let placeType: WorkPlaceType   // .cowork | .cafe
    let wifi:      WifiRating
    let noise:     NoiseLevel
    let outlets:   OutletAvailability
    let note:      String?         // optional free text
    let submittedAt: Date

    var timeAgoLabel: String {
        let secs = Date().timeIntervalSince(submittedAt)
        if secs < 3600   { return "just now" }
        if secs < 86400  { return "\(Int(secs/3600))h ago" }
        if secs < 604800 { return "\(Int(secs/86400))d ago" }
        return "\(Int(secs/604800))w ago"
    }
}

enum WorkPlaceType: String, Codable { case cowork, cafe }

enum WifiRating: String, Codable, CaseIterable {
    case fast   = "Fast"
    case ok     = "OK"
    case slow   = "Slow"
    case none   = "None"

    var icon: String {
        switch self {
        case .fast: return "wifi"
        case .ok:   return "wifi"
        case .slow: return "wifi.exclamationmark"
        case .none: return "wifi.slash"
        }
    }
    var color: String {
        switch self {
        case .fast: return "#007AFF"
        case .ok:   return "#FF9500"
        case .slow: return "#FF3B30"
        case .none: return "#8E8E93"
        }
    }
}

// Pending nudge — recorded when user taps Get Directions
struct WorkDirectionsIntent: Codable {
    let placeId:   String
    let placeType: WorkPlaceType
    let placeName: String
    let tappedAt:  Date
    var nudgeSent: Bool = false
}

// MARK: - Store

class WorkTipStore: ObservableObject {
    static let shared = WorkTipStore()

    @Published var tips:    [WorkTip]               = []
    @Published var intents: [WorkDirectionsIntent]  = []
    @Published var pendingNudge: WorkDirectionsIntent? = nil

    private let tipsKey    = "work_tips_v1"
    private let intentsKey = "work_intents_v1"

    init() { load(); checkNudge() }

    // MARK: - Tips

    func tips(for placeId: String) -> [WorkTip] {
        tips.filter { $0.placeId == placeId }
            .sorted { $0.submittedAt > $1.submittedAt }
    }

    func submitTip(placeId: String, placeType: WorkPlaceType,
                   wifi: WifiRating, noise: NoiseLevel,
                   outlets: OutletAvailability, note: String?) {
        let tip = WorkTip(
            id: UUID().uuidString,
            placeId: placeId, placeType: placeType,
            wifi: wifi, noise: noise, outlets: outlets,
            note: note.flatMap { $0.trimmingCharacters(in: .whitespaces).isEmpty ? nil : $0 },
            submittedAt: Date()
        )
        tips.append(tip)
        save()
        // Clear the matching nudge
        intents.removeAll { $0.placeId == placeId }
        pendingNudge = nil
        saveIntents()
    }

    // MARK: - Directions intent

    func recordDirectionsTapped(placeId: String, placeType: WorkPlaceType, placeName: String) {
        guard !intents.contains(where: { $0.placeId == placeId }) else { return }
        intents.append(WorkDirectionsIntent(
            placeId: placeId, placeType: placeType,
            placeName: placeName, tappedAt: Date()
        ))
        saveIntents()
    }

    func dismissNudge(placeId: String) {
        intents.removeAll { $0.placeId == placeId }
        pendingNudge = nil
        saveIntents()
    }

    func checkNudge() {
        let cutoff = Date().addingTimeInterval(-86400) // 24h
        pendingNudge = intents.first {
            !$0.nudgeSent && $0.tappedAt < cutoff
        }
    }

    // MARK: - Persistence

    private func load() {
        if let d = UserDefaults.standard.data(forKey: tipsKey),
           let t = try? JSONDecoder().decode([WorkTip].self, from: d) { tips = t }
        if let d = UserDefaults.standard.data(forKey: intentsKey),
           let i = try? JSONDecoder().decode([WorkDirectionsIntent].self, from: d) { intents = i }
    }
    private func save() {
        if let d = try? JSONEncoder().encode(tips) { UserDefaults.standard.set(d, forKey: tipsKey) }
    }
    private func saveIntents() {
        if let d = try? JSONEncoder().encode(intents) { UserDefaults.standard.set(d, forKey: intentsKey) }
    }
}
