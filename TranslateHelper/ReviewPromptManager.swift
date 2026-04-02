//
//  ReviewPromptManager.swift
//  TranslateHelper
//
//  Handles the "Are you enjoying Orbit?" prompt.
//  Yes → Apple's native SKStoreReviewController
//  Not yet → Feedback email
//
//  Behavioral triggers: 50+ translations AND 2+ weeks active.
//  Shows max once every 90 days.
//

import StoreKit
import SwiftUI

enum ReviewPromptManager {

    private static let appGroup = "group.com.jeff.translatehelper"
    private static let lastPromptKey = "ts_review_last_prompt_date"
    private static let installDateKey = "ts_app_install_date"
    private static let supportEmail = "support@orbitlanguage.com"

    /// Check if we should show the review prompt based on behavioral triggers.
    static func shouldPrompt() -> Bool {
        let defaults = UserDefaults(suiteName: appGroup)

        // Track install date (set once)
        if defaults?.object(forKey: installDateKey) == nil {
            defaults?.set(Date().timeIntervalSince1970, forKey: installDateKey)
            defaults?.synchronize()
        }

        // Must have been installed for 14+ days
        let installTimestamp = defaults?.double(forKey: installDateKey) ?? Date().timeIntervalSince1970
        let installDate = Date(timeIntervalSince1970: installTimestamp)
        let daysSinceInstall = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
        guard daysSinceInstall >= 14 else { return false }

        // Must have done 50+ keyboard translations
        let stats = PracticeStatsStore.shared
        let totalMessages = stats.totalSessionCount * 5 // rough estimate: 5 messages per session
        let keyboardTranslations = UserDefaults.standard.integer(forKey: "phrases_reviewed_today") // lifetime proxy
        guard totalMessages + keyboardTranslations >= 20 else { return false }

        // Don't show more than once every 90 days
        let lastPrompt = defaults?.double(forKey: lastPromptKey) ?? 0
        if lastPrompt > 0 {
            let lastDate = Date(timeIntervalSince1970: lastPrompt)
            let daysSinceLast = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            guard daysSinceLast >= 90 else { return false }
        }

        return true
    }

    /// Mark that we showed the prompt (don't show again for 90 days).
    static func markPromptShown() {
        let defaults = UserDefaults(suiteName: appGroup)
        defaults?.set(Date().timeIntervalSince1970, forKey: lastPromptKey)
        defaults?.synchronize()
    }

    /// Request Apple's native review dialog.
    static func requestReview() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
        markPromptShown()
    }

    /// Open feedback email for users who aren't enjoying it yet.
    static func openFeedback() {
        let subject = "Orbit Feedback"
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject
        if let url = URL(string: "mailto:\(supportEmail)?subject=\(encodedSubject)") {
            UIApplication.shared.open(url)
        }
        markPromptShown()
    }
}
