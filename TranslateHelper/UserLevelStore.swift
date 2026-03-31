//
//  UserLevelStore.swift
//  TranslateHelper
//
//  Persists the user's assessed language level (CEFR: A1–C2) per skill category.
//  Feeds into the Coach tab score overview + LevelDetailView.
//  Updated by: self-assessment, Sol calibration, Lightning Round performance.
//

import Foundation

enum CEFRLevel: String, Codable, CaseIterable, Comparable {
    case a1 = "A1"
    case a2 = "A2"
    case b1 = "B1"
    case b2 = "B2"
    case c1 = "C1"
    case c2 = "C2"

    var title: String {
        switch self {
        case .a1: return "Beginner"
        case .a2: return "Elementary"
        case .b1: return "Intermediate"
        case .b2: return "Upper Intermediate"
        case .c1: return "Advanced"
        case .c2: return "Mastery"
        }
    }

    var description: String {
        switch self {
        case .a1: return "You can understand and use basic phrases — greetings, introductions, simple questions."
        case .a2: return "You can handle short, routine exchanges — ordering food, asking directions, basic small talk."
        case .b1: return "You can deal with most situations while traveling or living abroad. You can describe experiences and give opinions."
        case .b2: return "You can interact with native speakers fluently enough that it's not a strain for either side."
        case .c1: return "You can express yourself fluently and spontaneously. You use language flexibly for any purpose."
        case .c2: return "You can understand virtually everything heard or read with precision and nuance."
        }
    }

    /// Numeric value for averaging (0–5)
    var numericValue: Int {
        switch self {
        case .a1: return 0
        case .a2: return 1
        case .b1: return 2
        case .b2: return 3
        case .c1: return 4
        case .c2: return 5
        }
    }

    /// Progress within this level (0.0–1.0) — estimated from performance data
    static func < (lhs: CEFRLevel, rhs: CEFRLevel) -> Bool {
        lhs.numericValue < rhs.numericValue
    }

    static func from(numeric: Int) -> CEFRLevel {
        switch numeric {
        case 0: return .a1
        case 1: return .a2
        case 2: return .b1
        case 3: return .b2
        case 4: return .c1
        default: return .c2
        }
    }
}

enum SkillCategory: String, Codable, CaseIterable {
    case pronunciation
    case grammar
    case vocabulary
    case fluency

    var displayName: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .pronunciation: return "🗣"
        case .grammar:       return "📐"
        case .vocabulary:    return "📖"
        case .fluency:       return "💬"
        }
    }
}

struct SkillAssessment: Codable {
    var level: CEFRLevel
    var progress: Double  // 0.0–1.0 within the current level
    var assessedAt: Date
    var source: String    // "self", "sol", "performance"
}

class UserLevelStore {
    static let shared = UserLevelStore()

    private static let appGroup = "group.com.jeff.translatehelper"
    private static let storageKey = "ts_user_levels_v1"
    private static let assessedKey = "ts_level_assessed"

    private(set) var skills: [SkillCategory: SkillAssessment] = [:]

    /// Whether the user has completed their initial self-assessment.
    var hasBeenAssessed: Bool {
        UserDefaults(suiteName: Self.appGroup)?.bool(forKey: Self.assessedKey) ?? false
    }

    /// Overall level — average of all skill levels.
    var overallLevel: CEFRLevel {
        guard !skills.isEmpty else { return .a1 }
        let avg = skills.values.reduce(0) { $0 + $1.level.numericValue } / skills.count
        return CEFRLevel.from(numeric: avg)
    }

    /// Overall progress across all skills (0.0–1.0).
    var overallProgress: Double {
        guard !skills.isEmpty else { return 0 }
        return skills.values.reduce(0.0) { $0 + $1.progress } / Double(skills.count)
    }

    private init() { load() }

    // MARK: - Assessment

    /// Save the user's self-assessed levels.
    func saveAssessment(_ levels: [SkillCategory: CEFRLevel]) {
        for (skill, level) in levels {
            skills[skill] = SkillAssessment(
                level: level,
                progress: 0.3,  // start at 30% — they haven't proven it yet
                assessedAt: Date(),
                source: "self"
            )
        }

        let defaults = UserDefaults(suiteName: Self.appGroup)
        defaults?.set(true, forKey: Self.assessedKey)
        defaults?.synchronize()

        save()
        NSLog("🎯 [Level] assessment saved: \(levels.map { "\($0.key): \($0.value)" })")
    }

    /// Update a skill level based on performance data (Lightning Round, Sol corrections).
    func updateFromPerformance(skill: SkillCategory, accuracy: Double) {
        guard var current = skills[skill] else { return }

        // Adjust progress within the current level
        let delta = (accuracy - 0.6) * 0.1  // 60% = neutral, above = progress, below = regress
        current.progress = max(0, min(1, current.progress + delta))

        // Level up if consistently high progress
        if current.progress >= 0.95 && current.level != .c2 {
            let next = CEFRLevel.from(numeric: current.level.numericValue + 1)
            current.level = next
            current.progress = 0.2  // start near the bottom of the new level
            current.source = "performance"
            current.assessedAt = Date()
        }

        // Level down if consistently struggling
        if current.progress <= 0.05 && current.level != .a1 {
            let prev = CEFRLevel.from(numeric: current.level.numericValue - 1)
            current.level = prev
            current.progress = 0.8  // near the top of the lower level
            current.source = "performance"
            current.assessedAt = Date()
        }

        skills[skill] = current
        save()
    }

    // MARK: - Persistence

    private func save() {
        guard let defaults = UserDefaults(suiteName: Self.appGroup) else { return }
        let flat: [String: [String: Any]] = skills.reduce(into: [:]) { result, pair in
            result[pair.key.rawValue] = [
                "level": pair.value.level.rawValue,
                "progress": pair.value.progress,
                "assessedAt": pair.value.assessedAt.timeIntervalSince1970,
                "source": pair.value.source
            ]
        }
        if let data = try? JSONSerialization.data(withJSONObject: flat) {
            defaults.set(data, forKey: Self.storageKey)
            defaults.synchronize()
        }
    }

    private func load() {
        guard let defaults = UserDefaults(suiteName: Self.appGroup),
              let data = defaults.data(forKey: Self.storageKey),
              let flat = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]]
        else { return }

        for (key, values) in flat {
            guard let skill = SkillCategory(rawValue: key),
                  let levelStr = values["level"] as? String,
                  let level = CEFRLevel(rawValue: levelStr),
                  let progress = values["progress"] as? Double,
                  let timestamp = values["assessedAt"] as? TimeInterval,
                  let source = values["source"] as? String
            else { continue }

            skills[skill] = SkillAssessment(
                level: level,
                progress: progress,
                assessedAt: Date(timeIntervalSince1970: timestamp),
                source: source
            )
        }
    }
}
