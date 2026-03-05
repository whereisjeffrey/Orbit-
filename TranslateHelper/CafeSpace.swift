//  CafeSpace.swift

import Foundation
import CoreLocation

enum NoiseLevel: String, Codable {
    case quiet    = "Quiet"
    case moderate = "Moderate"
    case lively   = "Lively"

    var icon: String {
        switch self {
        case .quiet:    return "speaker.slash.fill"
        case .moderate: return "speaker.wave.1.fill"
        case .lively:   return "speaker.wave.3.fill"
        }
    }

    var color: String {
        switch self {
        case .quiet:    return "#34C759"
        case .moderate: return "#FF9500"
        case .lively:   return "#FF3B30"
        }
    }
}

enum OutletAvailability: String, Codable {
    case plenty = "Plenty"
    case some   = "Some"
    case none   = "Scarce"

    var icon: String { "bolt.fill" }
}

struct CafeSpace: Identifiable, Codable {
    let id:           String
    let name:         String
    let neighbourhood: String
    let address:      String
    let cityId:       String
    let noiseLevel:   NoiseLevel
    let outlets:      OutletAvailability
    let hasFastWifi:  Bool
    let wifiSpeed:    String?        // e.g. "~60 Mbps"
    let timeLimitHrs: Int?           // nil = no limit; 2 = 2hr limit
    let hoursDisplay: String         // e.g. "7am – 10pm"
    let hoursDays:    String         // e.g. "Mon–Sun"
    let notes:        String?
    let website:      String?
    let latitude:     Double
    let longitude:    Double

    var hasNoTimeLimit: Bool { timeLimitHrs == nil }

    var timeLimitLabel: String {
        guard let h = timeLimitHrs else { return "No time limit" }
        return "\(h)hr limit"
    }

    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    func distance(from userLocation: CLLocation?) -> Double? {
        guard let u = userLocation else { return nil }
        return location.distance(from: u)
    }

    func distanceLabel(from userLocation: CLLocation?) -> String? {
        guard let d = distance(from: userLocation) else { return nil }
        if d < 1000 { return String(format: "%.0fm · %dmin", d, Int(d / 80)) }
        return String(format: "%.1fkm · %dmin", d / 1000, Int(d / 80))
    }
}

// MARK: - Seed data — CDMX work-friendly cafés
let cdmxCafeSpaces: [CafeSpace] = [
    CafeSpace(
        id: "cafe_jarocho", name: "Café El Jarocho", neighbourhood: "Coyoacán",
        address: "Cuauhtémoc 134, Coyoacán", cityId: "mx_cdmx",
        noiseLevel: .moderate, outlets: .some, hasFastWifi: false, wifiSpeed: nil,
        timeLimitHrs: nil, hoursDisplay: "7am – 11pm", hoursDays: "Mon–Sun",
        notes: "CDMX institution. Cash only, famously cheap espresso. No WiFi but the vibe makes up for it. Go early.",
        website: nil, latitude: 19.3507, longitude: -99.1618
    ),
    CafeSpace(
        id: "cafe_avellaneda", name: "Café Avellaneda", neighbourhood: "Coyoacán",
        address: "Higuera 40, Coyoacán", cityId: "mx_cdmx",
        noiseLevel: .quiet, outlets: .some, hasFastWifi: true, wifiSpeed: "~45 Mbps",
        timeLimitHrs: nil, hoursDisplay: "8am – 10pm", hoursDays: "Mon–Sun",
        notes: "Specialty coffee, single origin, relaxed about laptops. Two outlet strips near the back wall.",
        website: nil, latitude: 19.3512, longitude: -99.1625
    ),
    CafeSpace(
        id: "cafe_once", name: "Once Café", neighbourhood: "Roma Norte",
        address: "Orizaba 101, Roma Norte", cityId: "mx_cdmx",
        noiseLevel: .quiet, outlets: .plenty, hasFastWifi: true, wifiSpeed: "~80 Mbps",
        timeLimitHrs: nil, hoursDisplay: "8am – 9pm", hoursDays: "Mon–Fri",
        notes: "Nomad favourite. Plenty of outlets, reliably fast WiFi, staff don't rush you. Gets busy 10am–1pm.",
        website: "oncecafe.mx", latitude: 19.4167, longitude: -99.1612
    ),
    CafeSpace(
        id: "cafe_negro", name: "Café Negro", neighbourhood: "Roma Norte",
        address: "Álvaro Obregón 96, Roma Norte", cityId: "mx_cdmx",
        noiseLevel: .moderate, outlets: .some, hasFastWifi: true, wifiSpeed: "~55 Mbps",
        timeLimitHrs: nil, hoursDisplay: "8am – 10pm", hoursDays: "Mon–Sun",
        notes: "Bright, airy corner spot. Good espresso, laptop crowd is normal here. Ask for WiFi password.",
        website: nil, latitude: 19.4178, longitude: -99.1598
    ),
    CafeSpace(
        id: "cafe_quentin", name: "Café Quentin", neighbourhood: "Condesa",
        address: "Ámsterdam 317, Condesa", cityId: "mx_cdmx",
        noiseLevel: .quiet, outlets: .plenty, hasFastWifi: true, wifiSpeed: "~70 Mbps",
        timeLimitHrs: nil, hoursDisplay: "8am – 9pm", hoursDays: "Mon–Sat",
        notes: "Tree-lined Ámsterdam street, massive windows, very quiet on weekday mornings. Nomad-friendly default.",
        website: nil, latitude: 19.4135, longitude: -99.1712
    ),
    CafeSpace(
        id: "cafe_buna", name: "Buna 42", neighbourhood: "Polanco",
        address: "Emilio Castelar 149, Polanco", cityId: "mx_cdmx",
        noiseLevel: .moderate, outlets: .some, hasFastWifi: true, wifiSpeed: "~90 Mbps",
        timeLimitHrs: nil, hoursDisplay: "7am – 8pm", hoursDays: "Mon–Fri",
        notes: "Best WiFi speeds we've tested in Polanco. Specialty roasts, business crowd. Gets louder at lunch.",
        website: "buna.coffee", latitude: 19.4322, longitude: -99.1942
    ),
    CafeSpace(
        id: "cafe_almanegra", name: "Almanegra Café", neighbourhood: "Juárez",
        address: "Havre 73, Juárez", cityId: "mx_cdmx",
        noiseLevel: .quiet, outlets: .plenty, hasFastWifi: true, wifiSpeed: "~65 Mbps",
        timeLimitHrs: nil, hoursDisplay: "8am – 9pm", hoursDays: "Mon–Sun",
        notes: "Low-key, long tables with built-in outlets, ambient music. Regulars are mostly remote workers.",
        website: "almanegra.mx", latitude: 19.4268, longitude: -99.1632
    ),
    CafeSpace(
        id: "cafe_paramo", name: "Páramo", neighbourhood: "Roma Sur",
        address: "Tonalá 128, Roma Sur", cityId: "mx_cdmx",
        noiseLevel: .lively, outlets: .none, hasFastWifi: true, wifiSpeed: "~40 Mbps",
        timeLimitHrs: 2, hoursDisplay: "8am – 11pm", hoursDays: "Mon–Sun",
        notes: "Great coffee and cocktails, excellent vibe. Better for afternoons than deep work. Weekends get very loud.",
        website: nil, latitude: 19.4121, longitude: -99.1573
    ),
]
