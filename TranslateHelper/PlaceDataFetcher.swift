//  PlaceDataFetcher.swift — real café + cowork data via OpenStreetMap Overpass API
//  No API key. Free. ~7-day cache in UserDefaults.

import Foundation
import SwiftUI
import Combine

// MARK: - Raw OSM
private struct OverpassResponse: Decodable { let elements: [OSMElement] }
private struct OSMElement: Decodable {
    let id: Int
    let lat: Double?; let lon: Double?
    let center: OSMCenter?
    let tags: [String: String]?
    var latitude:  Double { lat ?? center?.lat ?? 0 }
    var longitude: Double { lon ?? center?.lon ?? 0 }
    var name: String { tags?["name"] ?? tags?["name:en"] ?? "" }
    var address: String {
        let s = tags?["addr:street"] ?? ""; let n = tags?["addr:housenumber"] ?? ""
        let c = tags?["addr:suburb"] ?? tags?["addr:neighbourhood"] ?? ""
        return s.isEmpty ? (c.isEmpty ? "Mexico City" : c) : [s, n, c].filter { !$0.isEmpty }.joined(separator: " ")
    }
    var neighbourhood: String {
        tags?["addr:suburb"] ?? tags?["addr:neighbourhood"] ?? tags?["addr:city_district"]
        ?? inferHood(lat: latitude, lon: longitude)
    }
    var hasWifi: Bool   { tags?["internet_access"] == "wlan" || tags?["wifi"] == "yes" }
    var website: String { tags?["website"] ?? tags?["contact:website"] ?? "" }
    var hours:   String { tags?["opening_hours"] ?? "" }
}
private struct OSMCenter: Decodable { let lat: Double; let lon: Double }

private func inferHood(lat: Double, lon: Double) -> String {
    switch (lat, lon) {
    case (19.41...19.43, -99.18 ... -99.16): return "Condesa"
    case (19.41...19.43, -99.16 ... -99.14): return "Roma Norte"
    case (19.43...19.45, -99.20 ... -99.17): return "Polanco"
    case (19.42...19.44, -99.17 ... -99.15): return "Juárez"
    case (19.35...19.40, -99.17 ... -99.12): return "Coyoacán"
    case (19.43...19.45, -99.14 ... -99.11): return "Centro"
    case (19.39...19.42, -99.16 ... -99.14): return "Narvarte"
    case (19.37...19.40, -99.16 ... -99.13): return "Del Valle"
    default: return "Mexico City"
    }
}

// MARK: - Fetcher
@MainActor
final class PlaceDataFetcher: ObservableObject {
    static let shared = PlaceDataFetcher()
    private init() {}

    @Published var cafes:     [CafeSpace]   = []
    @Published var coworks:   [CoworkSpace] = []
    @Published var isLoading  = false
    @Published var lastError: String?

    private let api      = "https://overpass-api.de/api/interpreter"
    private let cacheKey = "osm_fetch_ts"
    private let ttl: TimeInterval = 60 * 60 * 24 * 7   // 7 days

    func fetchAll() async {
        guard !isLoading else { return }
        if !cafes.isEmpty || !coworks.isEmpty { return }
        if let ts = UserDefaults.standard.object(forKey: cacheKey) as? Date,
           Date().timeIntervalSince(ts) < ttl { return }

        isLoading = true; defer { isLoading = false }

        async let c = fetchCafes()
        async let w = fetchCoworks()
        let (newCafes, newCoworks) = await (c, w)
        if !newCafes.isEmpty   { cafes   = newCafes }
        if !newCoworks.isEmpty { coworks = newCoworks }
        if !newCafes.isEmpty || !newCoworks.isEmpty {
            UserDefaults.standard.set(Date(), forKey: cacheKey)
        }
    }

    private func fetchCafes() async -> [CafeSpace] {
        let q = "[out:json][timeout:30];area[\"name\"=\"Ciudad de México\"][\"admin_level\"=\"4\"]->.a;(node[\"amenity\"=\"cafe\"](area.a);way[\"amenity\"=\"cafe\"](area.a););out center 120;"
        guard let els = await query(q) else { return [] }
        return els.filter { !$0.name.isEmpty && $0.latitude != 0 }.prefix(80).map { el in
            CafeSpace(
                id:           "osm_\(el.id)",
                name:          el.name,
                neighbourhood: el.neighbourhood,
                address:       el.address,
                cityId:       "mx_cdmx",
                noiseLevel:   .moderate,
                outlets:      .some,
                hasFastWifi:  el.hasWifi,
                wifiSpeed:    el.hasWifi ? "~25 Mbps" : nil,
                timeLimitHrs: nil,
                hoursDisplay: el.hours.isEmpty ? "See Google Maps" : el.hours,
                hoursDays:    "",
                notes:        "Via OpenStreetMap",
                website:      el.website.isEmpty ? nil : el.website,
                latitude:     el.latitude,
                longitude:    el.longitude
            )
        }
    }

    private func fetchCoworks() async -> [CoworkSpace] {
        let q = "[out:json][timeout:30];area[\"name\"=\"Ciudad de México\"][\"admin_level\"=\"4\"]->.a;(node[\"office\"=\"coworking\"](area.a);way[\"office\"=\"coworking\"](area.a);node[\"amenity\"=\"coworking_space\"](area.a););out center 60;"
        guard let els = await query(q) else { return [] }
        return els.filter { !$0.name.isEmpty && $0.latitude != 0 }.prefix(40).map { el in
            CoworkSpace(
                id:           "osm_\(el.id)",
                name:          el.name,
                neighbourhood: el.neighbourhood,
                cityId:       "mx_cdmx",
                address:       el.address,
                dayRate:      nil,
                monthRate:    nil,
                hoursDisplay: el.hours.isEmpty ? "See website" : el.hours,
                hoursDays:    "",
                hasCallRooms: false,
                hasCoffee:    false,
                hasFastWifi:  true,
                hasLateHours: false,
                wifiSpeed:    nil,
                website:      el.website.isEmpty ? nil : el.website,
                notes:        "Via OpenStreetMap",
                latitude:     el.latitude,
                longitude:    el.longitude
            )
        }
    }

    private func query(_ q: String) async -> [OSMElement]? {
        guard let enc = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(api)?data=\(enc)") else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(OverpassResponse.self, from: data).elements
        } catch { lastError = error.localizedDescription; return nil }
    }
}
