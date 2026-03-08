//  BadgeSystem.swift — Trust + reputation layer

import SwiftUI

// MARK: - Trust Level
enum TrustLevel: Int, Comparable {
    case newArrival  = 0
    case settling    = 1
    case local       = 2
    case trustedLocal = 3
    case cityExpert  = 4

    static func < (lhs: TrustLevel, rhs: TrustLevel) -> Bool { lhs.rawValue < rhs.rawValue }

    var label: String {
        switch self {
        case .newArrival:   return "New Arrival"
        case .settling:     return "Getting Settled"
        case .local:        return "Local"
        case .trustedLocal: return "Trusted Local"
        case .cityExpert:   return "City Expert"
        }
    }

    var color: Color {
        switch self {
        case .newArrival:   return Color.tsAccent
        case .settling:     return Color(hex: "#FF9500")
        case .local:        return Color(hex: "#34C759")
        case .trustedLocal: return Color(hex: "#30D158")
        case .cityExpert:   return Color(hex: "#FFD60A")
        }
    }

    var icon: String {
        switch self {
        case .newArrival:   return "airplane.arrival"
        case .settling:     return "shippingbox"
        case .local:        return "house.fill"
        case .trustedLocal: return "checkmark.seal.fill"
        case .cityExpert:   return "star.fill"
        }
    }

    // Derive from expat status string + questions answered
    static func from(status: String, questionsAnswered: Int = 0) -> TrustLevel {
        switch status {
        case "just_arrived":            return .newArrival
        case "settling":                return .settling
        case "local", "planning", "visiting":
            if questionsAnswered >= 25   { return .cityExpert }
            else if questionsAnswered >= 10 { return .trustedLocal }
            else                         { return .local }
        default:                        return .newArrival
        }
    }
}

// MARK: - Trust Badge view (inline chip)
struct TrustBadge: View {
    let level: TrustLevel
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 3 : 4) {
            Image(systemName: level.icon)
                .font(.system(size: compact ? 9 : 11, weight: .semibold))
            if !compact {
                Text(level.label)
                    .font(.custom("HelveticaNeue-Bold", size: 11))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, compact ? 6 : 8)
        .padding(.vertical, compact ? 3 : 4)
        .background(level.color)
        .clipShape(Capsule())
    }
}

// MARK: - Community User model (seed data, swap for Firestore later)
struct CommunityUser: Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let cityId: String
    let neighbourhood: String
    let fromCity: String          // "London", "NYC" etc.
    let statusRaw: String         // expat status raw value
    let daysInCity: Int
    let interests: [String]       // interest ids
    let instagramHandle: String?
    let linkedinHandle: String?
    let bio: String
    let questionsAnswered: Int
    var isAvailableForLocal: Bool  // opted in to Ask a Local
    var isVisibleNewInTown: Bool   // opted in to New in Town
    var avatarURL: String? = nil   // remote photo URL (pravatar, etc.)

    var trustLevel: TrustLevel { TrustLevel.from(status: statusRaw, questionsAnswered: questionsAnswered) }

    var initials: String {
        let f = firstName.prefix(1)
        let l = lastName.prefix(1)
        return "\(f)\(l)".uppercased()
    }

    var initialsColor: Color {
        let colors: [Color] = [
            Color.tsAccent, Color(hex: "#34C759"), Color(hex: "#FF9500"),
            Color(hex: "#AF52DE"), Color(hex: "#FF3B30"), Color(hex: "#5856D6")
        ]
        let index = abs(id.hashValue) % colors.count
        return colors[index]
    }

    var displayName: String { "\(firstName) \(lastName.prefix(1))." }

    var timeInCityLabel: String {
        if daysInCity < 7        { return "\(daysInCity)d in city" }
        else if daysInCity < 30  { return "\(daysInCity / 7)w in city" }
        else if daysInCity < 365 { return "\(daysInCity / 30)mo in city" }
        else                     { return "\(daysInCity / 365)yr in city" }
    }
}

// MARK: - Seed data
let seedCommunityUsers: [CommunityUser] = [
    CommunityUser(
        id: "u1", firstName: "Priya", lastName: "Sharma",
        cityId: "mx_cdmx", neighbourhood: "Roma Norte",
        fromCity: "London", statusRaw: "just_arrived", daysInCity: 4,
        interests: ["remote_work", "food", "arts"],
        instagramHandle: "priya.somewhere", linkedinHandle: nil,
        bio: "UX designer. Arrived last week. Looking for good coffee and coworking spots.",
        questionsAnswered: 0, isAvailableForLocal: false, isVisibleNewInTown: true,
        avatarURL: "https://i.pravatar.cc/150?img=47"
    ),
    CommunityUser(
        id: "u2", firstName: "Marco", lastName: "Ruiz",
        cityId: "mx_cdmx", neighbourhood: "Condesa",
        fromCity: "Barcelona", statusRaw: "just_arrived", daysInCity: 11,
        interests: ["nightlife", "food", "music"],
        instagramHandle: "marco.cdmx", linkedinHandle: nil,
        bio: "Remote developer. Here indefinitely. Always down for tacos.",
        questionsAnswered: 0, isAvailableForLocal: false, isVisibleNewInTown: true,
        avatarURL: "https://i.pravatar.cc/150?img=68"
    ),
    CommunityUser(
        id: "u3", firstName: "Sofia", lastName: "Chen",
        cityId: "mx_cdmx", neighbourhood: "Polanco",
        fromCity: "San Francisco", statusRaw: "settling", daysInCity: 78,
        interests: ["wellness", "food", "arts"],
        instagramHandle: "sofiainmexico", linkedinHandle: "sofia-chen",
        bio: "Startup founder. 3 months in, figuring it all out. Ask me about visas.",
        questionsAnswered: 4, isAvailableForLocal: false, isVisibleNewInTown: false,
        avatarURL: "https://i.pravatar.cc/150?img=44"
    ),
    CommunityUser(
        id: "u4", firstName: "James", lastName: "Okafor",
        cityId: "mx_cdmx", neighbourhood: "Roma Norte",
        fromCity: "Lagos", statusRaw: "local", daysInCity: 410,
        interests: ["remote_work", "food", "outdoors"],
        instagramHandle: nil, linkedinHandle: "james-okafor",
        bio: "Been here over a year. Know Roma Norte like the back of my hand. Happy to help newcomers.",
        questionsAnswered: 34, isAvailableForLocal: true, isVisibleNewInTown: false,
        avatarURL: "https://i.pravatar.cc/150?img=15"
    ),
    CommunityUser(
        id: "u5", firstName: "Elena", lastName: "Vasquez",
        cityId: "mx_cdmx", neighbourhood: "Condesa",
        fromCity: "Berlin", statusRaw: "local", daysInCity: 620,
        interests: ["arts", "music", "nightlife", "food"],
        instagramHandle: "elena.cdmx", linkedinHandle: nil,
        bio: "Artist and photographer. Two years in. Best person to ask about galleries, events and hidden bars.",
        questionsAnswered: 51, isAvailableForLocal: true, isVisibleNewInTown: false,
        avatarURL: "https://i.pravatar.cc/150?img=33"
    ),
    CommunityUser(
        id: "u6", firstName: "Tom", lastName: "Walsh",
        cityId: "mx_cdmx", neighbourhood: "Juárez",
        fromCity: "Dublin", statusRaw: "local", daysInCity: 290,
        interests: ["remote_work", "nightlife", "food"],
        instagramHandle: "tomwalshcdmx", linkedinHandle: "tom-walsh-mx",
        bio: "Product manager. 9 months in. Solid on the bar scene and coworking options in the city centre.",
        questionsAnswered: 18, isAvailableForLocal: true, isVisibleNewInTown: false,
        avatarURL: "https://i.pravatar.cc/150?img=59"
    ),
]
