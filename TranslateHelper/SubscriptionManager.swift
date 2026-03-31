//  SubscriptionManager.swift
//  TranslateHelper (Orbit)
//
//  Central source of truth for subscription state.
//  StoreKit 2 integration: product fetching, purchasing, transaction listening.
//  Falls back to @AppStorage for keyboard extension (can't run StoreKit there).

import SwiftUI
import StoreKit
import Combine

// MARK: - Product IDs (must match App Store Connect + .storekit file)

enum OrbitProductID: String, CaseIterable {
    case founderMonthly = "com.jeffrey.orbit.founder.monthly"    // $1.99/mo locked
    case standardMonthly = "com.jeffrey.orbit.standard.monthly"  // $4.99/mo
    case coachMonthly = "com.jeffrey.orbit.coach.monthly"        // $14.99/mo
    case coachAnnual = "com.jeffrey.orbit.coach.annual"          // $149.99/yr

    var tier: OrbitTier {
        switch self {
        case .founderMonthly:  return .founder
        case .standardMonthly: return .standard
        case .coachMonthly:    return .coach
        case .coachAnnual:     return .coach
        }
    }
}

enum OrbitTier: String, Comparable {
    case free
    case founder
    case standard
    case coach

    static func < (lhs: OrbitTier, rhs: OrbitTier) -> Bool {
        let order: [OrbitTier] = [.free, .founder, .standard, .coach]
        return (order.firstIndex(of: lhs) ?? 0) < (order.firstIndex(of: rhs) ?? 0)
    }
}

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    // MARK: - Published State

    @Published var isPro: Bool = false {
        didSet { syncToAppGroup() }
    }
    @Published var currentTier: OrbitTier = .free
    @Published var products: [Product] = []
    @Published var purchaseInProgress: Bool = false

    // AppStorage for keyboard extension (can't access StoreKit from extension)
    @AppStorage("keyboard_uses_today")       var keyboardUsesToday: Int = 0
    @AppStorage("keyboard_last_reset_date")  var keyboardLastResetDate: String = ""

    // Daily free limit for keyboard translations
    static let dailyFreeKeyboardLimit = 15

    private var transactionListener: Task<Void, Error>?

    // MARK: - Init

    init() {
        // Start listening for transactions immediately
        transactionListener = listenForTransactions()

        // Check current entitlements on launch
        Task {
            await refreshSubscriptionStatus()
            await fetchProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Product Fetching

    func fetchProducts() async {
        do {
            let ids = OrbitProductID.allCases.map(\.rawValue)
            let storeProducts = try await Product.products(for: Set(ids))
            products = storeProducts.sorted { a, b in
                (a.price as Decimal) < (b.price as Decimal)
            }
            NSLog("💰 [Store] fetched \(products.count) products")
        } catch {
            NSLog("💰 [Store] failed to fetch products: \(error)")
        }
    }

    // MARK: - Purchasing

    func purchase(_ productID: OrbitProductID) async -> Bool {
        guard let product = products.first(where: { $0.id == productID.rawValue }) else {
            NSLog("💰 [Store] product not found: \(productID.rawValue)")
            return false
        }

        purchaseInProgress = true
        defer { purchaseInProgress = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshSubscriptionStatus()
                NSLog("💰 [Store] purchase success: \(productID.rawValue)")
                return true

            case .userCancelled:
                NSLog("💰 [Store] purchase cancelled by user")
                return false

            case .pending:
                NSLog("💰 [Store] purchase pending (ask to buy / SCA)")
                return false

            @unknown default:
                return false
            }
        } catch {
            NSLog("💰 [Store] purchase failed: \(error)")
            return false
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        try? await AppStore.sync()
        await refreshSubscriptionStatus()
        NSLog("💰 [Store] restore completed — tier: \(currentTier)")
    }

    // MARK: - Subscription Status

    func refreshSubscriptionStatus() async {
        var highestTier: OrbitTier = .free

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                if let productID = OrbitProductID(rawValue: transaction.productID) {
                    let tier = productID.tier
                    if tier > highestTier {
                        highestTier = tier
                    }
                }
            } catch {
                NSLog("💰 [Store] unverified transaction: \(error)")
            }
        }

        currentTier = highestTier
        isPro = highestTier >= .founder
        NSLog("💰 [Store] subscription status: tier=\(currentTier), isPro=\(isPro)")
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.refreshSubscriptionStatus()
                    await transaction.finish()
                    NSLog("💰 [Store] transaction update: \(transaction.productID)")
                } catch {
                    NSLog("💰 [Store] transaction update failed verification")
                }
            }
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let item):
            return item
        }
    }

    // MARK: - Keyboard Usage

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

    // MARK: - App Group Sync

    /// Syncs isPro status to App Group so the keyboard extension can read it.
    private func syncToAppGroup() {
        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        defaults?.set(isPro, forKey: "is_pro")
        defaults?.set(currentTier.rawValue, forKey: "subscription_tier")
        defaults?.synchronize()
    }

    // MARK: - Helpers

    func product(for id: OrbitProductID) -> Product? {
        products.first { $0.id == id.rawValue }
    }

    /// Formatted price string for a product (e.g., "$4.99/month")
    func priceString(for id: OrbitProductID) -> String {
        guard let product = product(for: id) else { return "—" }
        return product.displayPrice
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
