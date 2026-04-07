//
//  PracticeStatsStore.swift
//  TranslateHelper
//
//  Persists practice session stats to App Group for weekly reports.
//  Tracks: session count, total duration, message count, dates practiced, keyboard corrections.
//

import Foundation

struct PracticeSessionRecord: Codable {
    let date: Date
    let durationSeconds: Int
    let messageCount: Int
    let tone: String  // casual, slang, flirty, work
}

class PracticeStatsStore {
    static let shared = PracticeStatsStore()

    private static let appGroup = "group.com.jeff.translatehelper"
    private static let sessionsKey = "ts_practice_sessions_v1"
    private static let keyboardCorrectionsKey = "ts_keyboard_corrections_count"
    private static let practiceStreakKey = "ts_practice_dates"

    private var sessions: [PracticeSessionRecord] = []
    private var practiceDates: Set<String> = []  // "yyyy-MM-dd" strings

    private init() {
        load()
    }

    // MARK: - Recording

    /// Call when a practice session ends.
    func recordSession(durationSeconds: Int, messageCount: Int, tone: String) {
        let record = PracticeSessionRecord(
            date: Date(),
            durationSeconds: durationSeconds,
            messageCount: messageCount,
            tone: tone
        )
        sessions.append(record)

        // Track the date for streak calculation
        let dateStr = Self.dateFormatter.string(from: Date())
        practiceDates.insert(dateStr)

        save()
    }

    /// Record any meaningful engagement — marks today as active for streak.
    /// Call from: study card session, keyboard translation, or Sol conversation.
    /// Updates BOTH the PracticeStatsStore dates AND the WeeklyStreakCard widget keys.
    func recordEngagement() {
        let dateStr = Self.dateFormatter.string(from: Date())
        if !practiceDates.contains(dateStr) {
            practiceDates.insert(dateStr)
            save()
            NSLog("🔥 [Streak] day recorded: \(dateStr)")
        }

        // Also update the WeeklyStreakCard's AppStorage keys
        let cal = Calendar.current
        let y = cal.component(.yearForWeekOfYear, from: Date())
        let w = cal.component(.weekOfYear, from: Date())
        let currentWeek = "\(y)-\(w)"
        let storedWeek = UserDefaults.standard.string(forKey: "study_week_id") ?? ""
        if storedWeek != currentWeek {
            UserDefaults.standard.set(currentWeek, forKey: "study_week_id")
            UserDefaults.standard.set("", forKey: "study_days_this_week")
        }
        let dayOfWeek = cal.component(.weekday, from: Date())
        let existingDays = UserDefaults.standard.string(forKey: "study_days_this_week") ?? ""
        var daySet = Set(existingDays.split(separator: ",").compactMap { Int($0) })
        if !daySet.contains(dayOfWeek) {
            daySet.insert(dayOfWeek)
            UserDefaults.standard.set(daySet.map { "\($0)" }.joined(separator: ","), forKey: "study_days_this_week")
        }
    }

    /// Increment keyboard correction count (called from App Group queue processing).
    func incrementKeyboardCorrections(count: Int = 1) {
        guard let defaults = UserDefaults(suiteName: Self.appGroup) else { return }
        let current = defaults.integer(forKey: Self.keyboardCorrectionsKey)
        defaults.set(current + count, forKey: Self.keyboardCorrectionsKey)
        defaults.synchronize()
    }

    // MARK: - Weekly Queries

    /// Sessions from the current week (Monday–Sunday).
    var thisWeekSessions: [PracticeSessionRecord] {
        let range = Self.currentWeekRange()
        return sessions.filter { $0.date >= range.start && $0.date <= range.end }
    }

    /// Total messages sent this week across all practice sessions.
    var weeklyMessageCount: Int {
        thisWeekSessions.reduce(0) { $0 + $1.messageCount }
    }

    /// Total practice minutes this week.
    var weeklyPracticeMinutes: Int {
        let totalSeconds = thisWeekSessions.reduce(0) { $0 + $1.durationSeconds }
        return totalSeconds / 60
    }

    /// Number of practice sessions this week.
    var weeklySessionCount: Int {
        thisWeekSessions.count
    }

    /// Total audio/practice minutes across all sessions (lifetime).
    var totalPracticeMinutes: Int {
        sessions.reduce(0) { $0 + $1.durationSeconds } / 60
    }

    /// Total sessions (lifetime).
    var totalSessionCount: Int {
        sessions.count
    }

    /// Current streak — consecutive days with at least one practice session.
    var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var checkDate = today

        while true {
            let dateStr = Self.dateFormatter.string(from: checkDate)
            if practiceDates.contains(dateStr) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else if checkDate == today {
                // Today hasn't been practiced yet — check if yesterday continues the streak
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        return streak
    }

    /// Week date range string for display (e.g., "Mar 24–30").
    var weekRangeString: String {
        let range = Self.currentWeekRange()
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        let start = fmt.string(from: range.start)
        fmt.dateFormat = "d"
        let end = fmt.string(from: range.end)
        return "\(start)–\(end)"
    }

    // MARK: - Persistence

    private func save() {
        guard let defaults = UserDefaults(suiteName: Self.appGroup) else { return }

        if let data = try? JSONEncoder().encode(sessions) {
            defaults.set(data, forKey: Self.sessionsKey)
        }

        // Save practice dates as array of strings
        defaults.set(Array(practiceDates), forKey: Self.practiceStreakKey)
        defaults.synchronize()
    }

    private func load() {
        guard let defaults = UserDefaults(suiteName: Self.appGroup) else { return }

        if let data = defaults.data(forKey: Self.sessionsKey),
           let decoded = try? JSONDecoder().decode([PracticeSessionRecord].self, from: data) {
            sessions = decoded

            // Trim old sessions (keep last 90 days)
            let cutoff = Calendar.current.date(byAdding: .day, value: -90, to: Date())!
            sessions = sessions.filter { $0.date >= cutoff }
        }

        if let dates = defaults.stringArray(forKey: Self.practiceStreakKey) {
            practiceDates = Set(dates)

            // Trim old dates (keep last 90 days)
            let cutoff = Calendar.current.date(byAdding: .day, value: -90, to: Date())!
            let cutoffStr = Self.dateFormatter.string(from: cutoff)
            practiceDates = practiceDates.filter { $0 >= cutoffStr }
        }
    }

    // MARK: - Helpers

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    /// Returns the start (Monday) and end (Sunday) of the current week.
    private static func currentWeekRange() -> (start: Date, end: Date) {
        let calendar = Calendar(identifier: .iso8601)  // Monday = first day
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        return (startOfWeek, endOfWeek)
    }
}
