//  SubscriptionManager.swift
//  TalkSwitch
//
//  Central source of truth for subscription state.
//  Uses @AppStorage so state persists across launches.
//  isPro can be toggled in Settings (debug) for testing.

import SwiftUI
import Combine

class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @AppStorage("is_pro")                    var isPro: Bool = false
    @AppStorage("keyboard_uses_today")       var keyboardUsesToday: Int = 0
    @AppStorage("keyboard_last_reset_date")  var keyboardLastResetDate: String = ""

    // Daily free limit for keyboard translations
    static let dailyFreeKeyboardLimit = 15

    var canUseKeyboard: Bool {
        isPro || keyboardUsesToday < SubscriptionManager.dailyFreeKeyboardLimit
    }

    var keyboardUsesRemaining: Int {
        max(0, SubscriptionManager.dailyFreeKeyboardLimit - keyboardUsesToday)
    }

    func recordKeyboardUse() {
        resetIfNewDay()
        if !isPro {
            keyboardUsesToday += 1
        }
    }

    private func resetIfNewDay() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        if today != keyboardLastResetDate {
            keyboardLastResetDate = today
            keyboardUsesToday = 0
        }
    }
}

// MARK: - Upgrade Reason

enum UpgradeReason {
    case kitTool(name: String)
    case messaging
    case groupJoin
    case socialLinks
    case deckCreation
    case keyboardLimit
    case neighbourhoodDetail

    var icon: String {
        switch self {
        case .kitTool:            return "wrench.and.screwdriver.fill"
        case .messaging:          return "message.fill"
        case .groupJoin:          return "person.3.fill"
        case .socialLinks:        return "link"
        case .deckCreation:       return "rectangle.stack.fill.badge.plus"
        case .keyboardLimit:      return "keyboard.fill"
        case .neighbourhoodDetail: return "map.fill"
        }
    }

    var title: String {
        switch self {
        case .kitTool(let name): return "Unlock \(name)"
        case .messaging:         return "Unlock Messaging"
        case .groupJoin:         return "Join the Group"
        case .socialLinks:       return "See Their Socials"
        case .deckCreation:      return "Create Your Own Decks"
        case .keyboardLimit:     return "Translations Used Up"
        case .neighbourhoodDetail: return "Unlock Full Guide"
        }
    }

    var description: String {
        switch self {
        case .kitTool(let name):
            return "\(name) is part of TalkSwitch Pro — your full expat toolkit for navigating any city."
        case .messaging:
            return "Send and receive messages with locals, nomads, and people you meet in the community."
        case .groupJoin:
            return "Join community groups to find coworking buddies, event partners, and local recommendations."
        case .socialLinks:
            return "See Instagram and LinkedIn profiles to connect with community members beyond the app."
        case .deckCreation:
            return "Build your own vocabulary decks from words you actually use in daily life."
        case .keyboardLimit:
            return "You've used your 15 free daily translations. Go Pro for unlimited keyboard use."
        case .neighbourhoodDetail:
            return "Unlock rent breakdowns, local insights, and the full neighbourhood guide."
        }
    }
}
