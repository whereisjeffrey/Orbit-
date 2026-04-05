//
//  ProfileBackupManager.swift
//  TranslateHelper
//
//  Backs up and restores all user profile data so it survives app deletion.
//  Saves to the app's Documents directory (NOT App Group — Documents survives
//  app updates but not deletion, so we also save to a shared location).
//

import Foundation

class ProfileBackupManager {
    static let shared = ProfileBackupManager()
    private init() {}

    private let appGroup = "group.com.jeff.translatehelper"

    // Keys to back up from App Group UserDefaults
    private let appGroupKeys = [
        "talkswitch_target_lang",
        "talkswitch_native_lang",
        "talkswitch_lang",
        "talkswitch_saved_phrases",
        // "ts_mistake_profile_v1",  // Removed — target areas rebuild organically
        "ts_practice_sessions_v1",
        "ts_practice_dates",
        "ts_self_reported_level",
        "ts_user_level_store",
        "ts_sol_memory",
        "ts_persona_summary",
        "ts_total_rounds_completed",
        "lightning_round_recent_prompts",
        "selected_city_id",
        "keyboard_has_launched",
    ]

    // Keys from standard UserDefaults
    private let standardKeys = [
        "onboarding_complete",
        "daily_goal",
        "phrases_reviewed_today",
        "study_week_id",
        "study_days_this_week",
        "completed_weeks",
        "starter_decks_seeded_lang",
    ]

    /// Backup file location — saved to shared container so it survives app deletion
    private var backupURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
            .appendingPathComponent("profile_backup.json")
    }

    /// Secondary backup to Documents (survives app updates, not deletion)
    private var documentsBackupURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("orbit_profile_backup.json")
    }

    // MARK: - Backup

    /// Saves all user profile data to a JSON file
    func backup() {
        var data: [String: Any] = [:]
        data["backup_date"] = ISO8601DateFormatter().string(from: Date())
        data["backup_version"] = 1

        // Back up App Group data
        if let defaults = UserDefaults(suiteName: appGroup) {
            var appGroupData: [String: Any] = [:]
            for key in appGroupKeys {
                if let value = defaults.object(forKey: key) {
                    // Convert Data to base64 string for JSON compatibility
                    if let dataValue = value as? Data {
                        appGroupData[key] = dataValue.base64EncodedString()
                        appGroupData["\(key)_isData"] = true
                    } else {
                        appGroupData[key] = value
                    }
                }
            }
            data["appGroup"] = appGroupData
        }

        // Back up standard UserDefaults
        var standardData: [String: Any] = [:]
        for key in standardKeys {
            if let value = UserDefaults.standard.object(forKey: key) {
                standardData[key] = value
            }
        }
        data["standard"] = standardData

        // Save to both locations
        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) {
            if let url = backupURL {
                try? jsonData.write(to: url)
                NSLog("💾 Profile backed up to App Group (\(jsonData.count) bytes)")
            }
            if let url = documentsBackupURL {
                try? jsonData.write(to: url)
                NSLog("💾 Profile backed up to Documents (\(jsonData.count) bytes)")
            }
        }
    }

    // MARK: - Restore

    /// Restores profile data from backup. Returns true if restored successfully.
    @discardableResult
    func restore() -> Bool {
        // Try App Group backup first (survives app deletion)
        var jsonData: Data?
        if let url = backupURL {
            jsonData = try? Data(contentsOf: url)
        }
        // Fall back to Documents backup
        if jsonData == nil, let url = documentsBackupURL {
            jsonData = try? Data(contentsOf: url)
        }

        guard let data = jsonData,
              let backup = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            NSLog("💾 No backup found to restore")
            return false
        }

        // Restore App Group data
        if let appGroupData = backup["appGroup"] as? [String: Any],
           let defaults = UserDefaults(suiteName: appGroup) {
            for (key, value) in appGroupData {
                if key.hasSuffix("_isData") { continue }
                if appGroupData["\(key)_isData"] as? Bool == true,
                   let base64 = value as? String,
                   let decoded = Data(base64Encoded: base64) {
                    defaults.set(decoded, forKey: key)
                } else {
                    defaults.set(value, forKey: key)
                }
            }
            defaults.synchronize()
        }

        // Restore standard UserDefaults
        if let standardData = backup["standard"] as? [String: Any] {
            for (key, value) in standardData {
                UserDefaults.standard.set(value, forKey: key)
            }
        }

        let backupDate = backup["backup_date"] as? String ?? "unknown"
        NSLog("💾 Profile restored from backup (date: \(backupDate))")
        return true
    }

    // MARK: - Auto-backup

    /// Call on app launch — backs up every time the app opens (lightweight)
    func autoBackupIfNeeded() {
        // Only back up if there's actual data worth saving
        let defaults = UserDefaults(suiteName: appGroup)
        guard defaults?.string(forKey: "talkswitch_target_lang") != nil else { return }
        backup()
    }

    /// Check if a backup exists
    var hasBackup: Bool {
        if let url = backupURL, FileManager.default.fileExists(atPath: url.path) { return true }
        if let url = documentsBackupURL, FileManager.default.fileExists(atPath: url.path) { return true }
        return false
    }
}
