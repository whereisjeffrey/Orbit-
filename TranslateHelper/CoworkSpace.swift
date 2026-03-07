//  CoworkSpace.swift

import Foundation
import CoreLocation

struct CoworkSpace: Identifiable {
    let id: String
    let name: String
    let neighbourhood: String
    let cityId: String
    let address: String
    let dayRate: Int?          // MXN
    let monthRate: Int?        // MXN
    let hoursDisplay: String   // e.g. "8am – 10pm"
    let hoursDays: String      // e.g. "Mon – Sat"
    let hasCallRooms: Bool
    let hasCoffee: Bool
    let hasFastWifi: Bool      // 50 Mbps+
    let hasLateHours: Bool     // open past 9 pm
    let wifiSpeed: String?     // e.g. "~80 Mbps"
    let website: String?
    let notes: String?
    var photoURLs: [String] = []
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocation { CLLocation(latitude: latitude, longitude: longitude) }

    func distance(from location: CLLocation?) -> Double? {
        guard let location else { return nil }
        return location.distance(from: coordinate) / 1000.0  // km
    }

    func distanceLabel(from location: CLLocation?) -> String? {
        guard let km = distance(from: location) else { return nil }
        return km < 1.0 ? String(format: "%.0fm", km * 1000) : String(format: "%.1fkm", km)
    }
}

// MARK: - CDMX seed data
let cdmxCoworkSpaces: [CoworkSpace] = [
    CoworkSpace(
        id: "homework_condesa",
        name: "Coworker Condesa",
        neighbourhood: "Condesa",
        cityId: "mx_cdmx",
        address: "Tamaulipas 66, Condesa, CDMX",
        dayRate: 200, monthRate: 2800,
        hoursDisplay: "8am – 10pm", hoursDays: "Mon – Sat",
        hasCallRooms: true, hasCoffee: true, hasFastWifi: true, hasLateHours: true,
        wifiSpeed: "~80 Mbps", website: "homework.com.mx",
        notes: "2 soundproof call booths, great natural light, lively crowd.",
        photoURLs: ["https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=80","https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=800&q=80","https://images.unsplash.com/photo-1497366754035-f200581695c4?w=800&q=80"],
        latitude: 19.4133, longitude: -99.1707
    ),
    CoworkSpace(
        id: "homework_polanco",
        name: "Coworker Polanco",
        neighbourhood: "Polanco",
        cityId: "mx_cdmx",
        address: "Virgilio 10, Polanco, CDMX",
        dayRate: 220, monthRate: 3200,
        hoursDisplay: "8am – 9pm", hoursDays: "Mon – Sat",
        hasCallRooms: true, hasCoffee: true, hasFastWifi: true, hasLateHours: false,
        wifiSpeed: "~100 Mbps", website: "homework.com.mx",
        notes: "Upscale crowd, quieter than Condesa location, 3 call rooms.",
        photoURLs: ["https://images.unsplash.com/photo-1497215842964-222b430dc094?w=800&q=80","https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=800&q=80","https://images.unsplash.com/photo-1564069114553-7215e1ff1890?w=800&q=80"],
        latitude: 19.4322, longitude: -99.1952
    ),
    CoworkSpace(
        id: "wework_reforma",
        name: "WeWork Reforma",
        neighbourhood: "Juárez",
        cityId: "mx_cdmx",
        address: "Paseo de la Reforma 296, Juárez, CDMX",
        dayRate: 400, monthRate: 5500,
        hoursDisplay: "7am – 11pm", hoursDays: "Mon – Fri",
        hasCallRooms: true, hasCoffee: true, hasFastWifi: true, hasLateHours: true,
        wifiSpeed: "~150 Mbps", website: "wework.com",
        notes: "Multiple private offices and phone booths. Premium price, premium kit.",
        photoURLs: ["https://images.unsplash.com/photo-1568992687947-868a62a9f521?w=800&q=80","https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=800&q=80","https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=800&q=80"],
        latitude: 19.4284, longitude: -99.1709
    ),
    CoworkSpace(
        id: "selina_roma",
        name: "Selina Roma Norte",
        neighbourhood: "Roma Norte",
        cityId: "mx_cdmx",
        address: "Orizaba 87, Roma Norte, CDMX",
        dayRate: 250, monthRate: 3500,
        hoursDisplay: "9am – 9pm", hoursDays: "Mon – Sun",
        hasCallRooms: false, hasCoffee: true, hasFastWifi: true, hasLateHours: false,
        wifiSpeed: "~60 Mbps", website: "selina.com",
        notes: "Open plan only — no private rooms. Good vibe, international crowd, rooftop.",
        photoURLs: ["https://images.unsplash.com/photo-1553877522-43269d4ea984?w=800&q=80","https://images.unsplash.com/photo-1571624436279-b272aff752b5?w=800&q=80","https://images.unsplash.com/photo-1606857521015-7f9fcf423740?w=800&q=80"],
        latitude: 19.4163, longitude: -99.1594
    ),
    CoworkSpace(
        id: "impact_hub",
        name: "Impact Hub CDMX",
        neighbourhood: "Roma Norte",
        cityId: "mx_cdmx",
        address: "Medellín 33, Roma Norte, CDMX",
        dayRate: 180, monthRate: 2500,
        hoursDisplay: "9am – 8pm", hoursDays: "Mon – Fri",
        hasCallRooms: true, hasCoffee: false, hasFastWifi: true, hasLateHours: false,
        wifiSpeed: "~70 Mbps", website: "mexico.impacthub.net",
        notes: "Startup / NGO crowd. 1 phone booth. Coffee nearby but not included.",
        photoURLs: ["https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=80","https://images.unsplash.com/photo-1497215842964-222b430dc094?w=800&q=80","https://images.unsplash.com/photo-1568992687947-868a62a9f521?w=800&q=80"],
        latitude: 19.4168, longitude: -99.1631
    ),
    CoworkSpace(
        id: "zentro_condesa",
        name: "Zentro",
        neighbourhood: "Condesa",
        cityId: "mx_cdmx",
        address: "Insurgentes Sur 416, Condesa, CDMX",
        dayRate: 150, monthRate: 2200,
        hoursDisplay: "8am – 9pm", hoursDays: "Mon – Sat",
        hasCallRooms: false, hasCoffee: true, hasFastWifi: true, hasLateHours: false,
        wifiSpeed: "~55 Mbps", website: nil,
        notes: "Budget-friendly. Open plan, good WiFi, coffee bar on-site.",
        photoURLs: ["https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=800&q=80","https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=800&q=80","https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=800&q=80"],
        latitude: 19.4078, longitude: -99.1712
    ),
    CoworkSpace(
        id: "maquinaria_roma",
        name: "La Maquinaria",
        neighbourhood: "Roma Norte",
        cityId: "mx_cdmx",
        address: "Tonalá 10, Roma Norte, CDMX",
        dayRate: 160, monthRate: 2400,
        hoursDisplay: "9am – 8pm", hoursDays: "Mon – Fri",
        hasCallRooms: true, hasCoffee: true, hasFastWifi: false, hasLateHours: false,
        wifiSpeed: "~30 Mbps", website: nil,
        notes: "Cozy, design-forward space. WiFi can be slow at peak hours — not ideal for video.",
        photoURLs: ["https://images.unsplash.com/photo-1497366754035-f200581695c4?w=800&q=80","https://images.unsplash.com/photo-1564069114553-7215e1ff1890?w=800&q=80","https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=800&q=80"],
        latitude: 19.4155, longitude: -99.1601
    ),
    CoworkSpace(
        id: "bordo_juarez",
        name: "Bordo Coworking",
        neighbourhood: "Juárez",
        cityId: "mx_cdmx",
        address: "Londres 66, Juárez, CDMX",
        dayRate: 190, monthRate: 2600,
        hoursDisplay: "8am – 10pm", hoursDays: "Mon – Sat",
        hasCallRooms: true, hasCoffee: true, hasFastWifi: true, hasLateHours: true,
        wifiSpeed: "~90 Mbps", website: "bordocoworking.com",
        notes: "Two dedicated call pods. Late hours great for US East Coast timezones.",
        photoURLs: ["https://images.unsplash.com/photo-1553877522-43269d4ea984?w=800&q=80","https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=800&q=80","https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=800&q=80"],
        latitude: 19.4271, longitude: -99.1658
    ),
    CoworkSpace(
        id: "crew_polanco",
        name: "Crew Polanco",
        neighbourhood: "Polanco",
        cityId: "mx_cdmx",
        address: "Horacio 900, Polanco, CDMX",
        dayRate: 280, monthRate: 3800,
        hoursDisplay: "8am – 8pm", hoursDays: "Mon – Fri",
        hasCallRooms: true, hasCoffee: true, hasFastWifi: true, hasLateHours: false,
        wifiSpeed: "~120 Mbps", website: nil,
        notes: "Corporate feel. Quiet, fast, reliable. Closes early — not for night owls.",
        photoURLs: ["https://images.unsplash.com/photo-1571624436279-b272aff752b5?w=800&q=80","https://images.unsplash.com/photo-1497215842964-222b430dc094?w=800&q=80","https://images.unsplash.com/photo-1568992687947-868a62a9f521?w=800&q=80"],
        latitude: 19.4340, longitude: -99.1984
    ),
    CoworkSpace(
        id: "latitud_condesa",
        name: "Latitud Condesa",
        neighbourhood: "Condesa",
        cityId: "mx_cdmx",
        address: "Ámsterdam 238, Condesa, CDMX",
        dayRate: 170, monthRate: 2300,
        hoursDisplay: "8am – 9pm", hoursDays: "Mon – Sat",
        hasCallRooms: false, hasCoffee: true, hasFastWifi: true, hasLateHours: false,
        wifiSpeed: "~65 Mbps", website: nil,
        notes: "Bright, plant-filled, chill. No call rooms but tucked corners exist for quick calls.",
        photoURLs: ["https://picsum.photos/id/225/400/220","https://picsum.photos/id/366/400/220","https://picsum.photos/id/3183/400/220"],
        latitude: 19.4121, longitude: -99.1732
    ),
]
