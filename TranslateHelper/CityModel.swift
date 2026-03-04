//  CityModel.swift — City infrastructure (Mexico launch → global later)

import Foundation

struct City: Identifiable, Codable, Hashable {
    let id: String          // e.g. "mx_cdmx"
    let name: String        // e.g. "Mexico City"
    let country: String     // e.g. "Mexico"
    let countryCode: String // e.g. "MX"
    let emoji: String       // e.g. "🇲🇽"
    let timezone: String    // e.g. "America/Mexico_City"
}

struct CityStore {
    static let all: [City] = [
        City(id: "mx_cdmx",        name: "Mexico City",  country: "Mexico", countryCode: "MX", emoji: "🇲🇽", timezone: "America/Mexico_City"),
        City(id: "mx_guadalajara", name: "Guadalajara",  country: "Mexico", countryCode: "MX", emoji: "🇲🇽", timezone: "America/Mexico_City"),
        City(id: "mx_monterrey",   name: "Monterrey",    country: "Mexico", countryCode: "MX", emoji: "🇲🇽", timezone: "America/Monterrey"),
        City(id: "mx_oaxaca",      name: "Oaxaca",       country: "Mexico", countryCode: "MX", emoji: "🇲🇽", timezone: "America/Mexico_City"),
        City(id: "mx_cancun",      name: "Cancún",       country: "Mexico", countryCode: "MX", emoji: "🇲🇽", timezone: "America/Cancun"),
        City(id: "mx_tulum",       name: "Tulum",        country: "Mexico", countryCode: "MX", emoji: "🇲🇽", timezone: "America/Cancun"),
        City(id: "mx_playa",       name: "Playa del Carmen", country: "Mexico", countryCode: "MX", emoji: "🇲🇽", timezone: "America/Cancun"),
        City(id: "mx_merida",      name: "Mérida",       country: "Mexico", countryCode: "MX", emoji: "🇲🇽", timezone: "America/Merida"),
    ]

    static func city(id: String) -> City? { all.first { $0.id == id } }
    static var defaultCity: City { all[0] } // Mexico City
}
