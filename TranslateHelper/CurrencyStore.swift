//  CurrencyStore.swift
//  Live exchange rates via open.er-api.com — free, no API key required.

import Foundation
import Combine

@MainActor
class CurrencyStore: ObservableObject {
    static let shared = CurrencyStore()

    @Published var rates:       [String: Double] = [:]
    @Published var lastUpdated: String           = ""
    @Published var isLoading:   Bool             = false
    @Published var error:       String?          = nil

    private let base    = "USD"
    private let apiURL  = "https://open.er-api.com/v6/latest/USD"
    private let cacheKey = "currency_rates_cache_v1"
    private let cacheTimeKey = "currency_rates_time_v1"

    init() { loadCache() }

    // MARK: - Fetch
    func fetchRates() async {
        // Skip if fetched within last 30 minutes
        if let last = UserDefaults.standard.object(forKey: cacheTimeKey) as? Date,
           Date().timeIntervalSince(last) < 1800, !rates.isEmpty { return }

        isLoading = true; error = nil
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: apiURL)!)
            let decoded = try JSONDecoder().decode(ExchangeResponse.self, from: data)
            rates = decoded.rates
            lastUpdated = decoded.time_last_update_utc
            saveCache(data)
            UserDefaults.standard.set(Date(), forKey: cacheTimeKey)
        } catch {
            self.error = "Could not load rates. Showing cached data."
        }
        isLoading = false
    }

    // MARK: - Helpers
    func rate(for code: String) -> Double? { rates[code] }

    func convert(_ amount: Double, from: String, to: String) -> Double? {
        guard from != to else { return amount }
        if from == base, let r = rates[to]   { return amount * r }
        if to   == base, let r = rates[from] { return amount / r }
        guard let fromRate = rates[from], let toRate = rates[to] else { return nil }
        return (amount / fromRate) * toRate
    }

    var updatedLabel: String {
        guard !lastUpdated.isEmpty else { return "—" }
        let f = DateFormatter()
        f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZZ"
        if let d = f.date(from: lastUpdated) {
            let diff = Int(Date().timeIntervalSince(d) / 60)
            if diff < 2  { return "Just updated" }
            if diff < 60 { return "Updated \(diff)m ago" }
            return "Updated \(diff / 60)h ago"
        }
        return "Updated recently"
    }

    // MARK: - Cache
    private func loadCache() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let decoded = try? JSONDecoder().decode(ExchangeResponse.self, from: data) else { return }
        rates = decoded.rates
        lastUpdated = decoded.time_last_update_utc
    }
    private func saveCache(_ data: Data) {
        UserDefaults.standard.set(data, forKey: cacheKey)
    }
}

private struct ExchangeResponse: Codable {
    let rates: [String: Double]
    let time_last_update_utc: String
}
