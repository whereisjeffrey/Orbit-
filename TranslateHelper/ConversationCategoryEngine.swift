//
//  ConversationCategoryEngine.swift
//  TranslateHelper
//
//  Manages the 6 conversation categories with 100+ templates.
//  Picks a category (weighted by status), then picks an unused prompt.
//  Replaces {city} and {country} with user's actual location.
//  Tracks usage so nothing repeats.
//

import Foundation

// MARK: - Category Definition

enum ConversationCategory: String, CaseIterable, Codable {
    case placesDiscovery     // 25% — Gemini-powered
    case cultureOpinions     // 20% — curated
    case personalLife        // 20% — curated
    case languageGrowth      // 10% — curated
    case nostalgiaIdentity   // 15% — curated
    case playfulRandom       // 10% — curated

    var label: String {
        switch self {
        case .placesDiscovery:  return "Places & Discovery"
        case .cultureOpinions:  return "Culture & Opinions"
        case .personalLife:     return "Personal Life"
        case .languageGrowth:   return "Language & Growth"
        case .nostalgiaIdentity: return "Nostalgia & Identity"
        case .playfulRandom:    return "Playful & Random"
        }
    }

    /// Whether this category needs a Gemini lookup
    var needsGemini: Bool { self == .placesDiscovery }

    /// Weight by status: (newArrival, settling, local)
    var weights: (new: Int, settling: Int, local: Int) {
        switch self {
        case .placesDiscovery:  return (35, 25, 15)
        case .cultureOpinions:  return (15, 20, 25)
        case .personalLife:     return (20, 20, 20)
        case .languageGrowth:   return (15, 10, 10)
        case .nostalgiaIdentity: return (5, 15, 20)
        case .playfulRandom:    return (10, 10, 10)
        }
    }
}

// MARK: - Opener Style

enum OpenerStyle: String, CaseIterable {
    case recommendation  // "Have you checked out X?"
    case openQuestion    // "What's your go-to for X?"
    case opinion         // "I heard X is overrated — thoughts?"
}

// MARK: - Conversation Template

struct ConversationTemplate: Codable, Identifiable {
    let id: String
    let category: ConversationCategory
    let template: String  // contains {city}, {country}, {neighborhood}
}

// MARK: - Engine

class ConversationCategoryEngine {
    static let shared = ConversationCategoryEngine()

    private static let appGroup = "group.com.jeff.translatehelper"
    private static let usedKey = "ts_used_category_prompts_v1"
    private static let lastCategoryKey = "ts_last_category_picked"

    private var usedPrompts: Set<String> = []
    private var lastCategory: ConversationCategory?

    private init() {
        loadUsed()
    }

    // MARK: - Pick Next

    /// Pick a category and prompt for this session.
    /// Returns (category, direction text with variables replaced, needsGemini).
    func pickForSession(city: String, country: String, neighborhood: String = "") -> (category: ConversationCategory, direction: String, needsGemini: Bool)? {
        let status = UserDefaults.standard.string(forKey: "user_expat_status") ?? "settling"

        // Build weighted pool
        var pool: [ConversationCategory] = []
        for cat in ConversationCategory.allCases {
            let w = cat.weights
            let weight: Int
            switch status {
            case "visiting", "just_arrived", "planning": weight = w.new
            case "settling": weight = w.settling
            default: weight = w.local
            }
            for _ in 0..<weight { pool.append(cat) }
        }

        // Avoid same category as last time
        if let last = lastCategory {
            let filtered = pool.filter { $0 != last }
            if !filtered.isEmpty { pool = filtered }
        }

        // Pick category
        let sessionCount = PracticeStatsStore.shared.totalSessionCount
        let category = pool[sessionCount % pool.count]

        // Pick opener style
        let styles: [OpenerStyle] = [.recommendation, .recommendation, .recommendation, .recommendation,
                                      .openQuestion, .openQuestion, .openQuestion, .openQuestion,
                                      .opinion, .opinion]
        let style = styles[sessionCount % styles.count]

        // For Gemini-powered categories, return the category info
        if category.needsGemini {
            lastCategory = category
            saveUsed()
            NSLog("🎬 [Category] \(category.label) — needs Gemini lookup")
            return (category, "", true)
        }

        // For curated categories, pick an unused template
        let templates = Self.templates.filter { $0.category == category && !usedPrompts.contains($0.id) }
        guard let template = templates.randomElement() else {
            // All used — pick from any unused category
            let anyUnused = Self.templates.filter { !usedPrompts.contains($0.id) && !$0.category.needsGemini }
            guard let fallback = anyUnused.randomElement() else {
                NSLog("🎬 [Category] All templates exhausted!")
                return nil
            }
            usedPrompts.insert(fallback.id)
            lastCategory = fallback.category
            saveUsed()
            let direction = applyVariables(fallback.template, city: city, country: country, neighborhood: neighborhood)
            NSLog("🎬 [Category] \(fallback.category.label) (fallback): \(direction.prefix(50))")
            return (fallback.category, direction, false)
        }

        usedPrompts.insert(template.id)
        lastCategory = category
        saveUsed()

        var direction = applyVariables(template.template, city: city, country: country, neighborhood: neighborhood)

        // Apply opener style framing
        switch style {
        case .recommendation:
            direction = "Frame this as a recommendation or sharing something exciting: \(direction)"
        case .openQuestion:
            direction = "Frame this as an open-ended question — you're curious about THEIR experience: \(direction)"
        case .opinion:
            direction = "Frame this as an opinion or hot take that invites debate: \(direction)"
        }

        NSLog("🎬 [Category] \(category.label) [\(style.rawValue)]: \(direction.prefix(60))")
        return (category, direction, false)
    }

    private func applyVariables(_ text: String, city: String, country: String, neighborhood: String) -> String {
        var result = text
        result = result.replacingOccurrences(of: "{city}", with: city)
        result = result.replacingOccurrences(of: "{country}", with: country)
        if !neighborhood.isEmpty {
            result = result.replacingOccurrences(of: "{neighborhood}", with: neighborhood)
        } else {
            result = result.replacingOccurrences(of: "near {neighborhood} ", with: "")
            result = result.replacingOccurrences(of: "in {neighborhood} ", with: "in ")
            result = result.replacingOccurrences(of: "{neighborhood}", with: city)
        }
        return result
    }

    // MARK: - Persistence

    private func saveUsed() {
        let defaults = UserDefaults(suiteName: Self.appGroup)
        defaults?.set(Array(usedPrompts), forKey: Self.usedKey)
        if let cat = lastCategory {
            defaults?.set(cat.rawValue, forKey: Self.lastCategoryKey)
        }
        defaults?.synchronize()
    }

    private func loadUsed() {
        let defaults = UserDefaults(suiteName: Self.appGroup)
        if let arr = defaults?.stringArray(forKey: Self.usedKey) {
            usedPrompts = Set(arr)
        }
        if let raw = defaults?.string(forKey: Self.lastCategoryKey) {
            lastCategory = ConversationCategory(rawValue: raw)
        }
    }

    func resetAll() {
        usedPrompts.removeAll()
        lastCategory = nil
        saveUsed()
        NSLog("🎬 [Category] All prompts reset")
    }

    var remainingCount: Int {
        Self.templates.count - usedPrompts.count
    }

    // MARK: - Template Database

    static let templates: [ConversationTemplate] = {
        var t: [ConversationTemplate] = []

        // ═══════════════════════════════════════════
        // CULTURE & OPINIONS
        // ═══════════════════════════════════════════
        let culture: [(String, String)] = [
            ("culture_customs_surprise", "What's a custom here in {country} that caught you completely off guard?"),
            ("culture_greetings", "Have you noticed how people greet each other differently here in {city}?"),
            ("culture_wish_home", "What's something people do here in {country} that you wish they did back home?"),
            ("culture_weird_food", "What's the weirdest thing you've eaten here in {country} and did you like it?"),
            ("culture_friendly", "Do you think people in {city} are more or less friendly than where you're from?"),
            ("culture_dont_understand", "What's something about {country} culture that you still don't understand?"),
            ("culture_tipping", "Have you figured out the tipping culture here? It confused me at first."),
            ("culture_picked_up", "What's a local habit you've accidentally picked up since living in {city}?"),
            ("culture_raise_kids", "Do you think {city} is a good place to raise kids? Why or why not?"),
            ("culture_shock", "What's the biggest cultural shock you've had since arriving in {country}?"),
            ("culture_driving", "How do you feel about how people drive here in {city}?"),
            ("culture_holiday", "What's a holiday here in {country} that you really want to experience?"),
            ("culture_work", "Do you think the work culture here is better or worse than back home?"),
            ("culture_dating", "What's something about dating culture here that surprised you?"),
            ("culture_time", "Have you noticed how people here deal with time differently?"),
            ("culture_adopted", "What's a {country} tradition you've adopted as your own?"),
            ("culture_bureaucracy", "How do you feel about the bureaucracy here compared to your home country?"),
            ("culture_misunderstanding", "What's the funniest cultural misunderstanding you've had here?"),
            ("culture_family", "Do people here seem more family-oriented than where you're from?"),
            ("culture_social_rule", "What's a social rule here that nobody explained to you but you had to figure out?"),
        ]
        for (id, text) in culture {
            t.append(ConversationTemplate(id: id, category: .cultureOpinions, template: text))
        }

        // ═══════════════════════════════════════════
        // PERSONAL LIFE
        // ═══════════════════════════════════════════
        let personal: [(String, String)] = [
            ("personal_movies", "Have you seen any good movies or shows lately?"),
            ("personal_work_week", "How's work been going this week?"),
            ("personal_sunday", "What do you usually do on a Sunday when you have nothing planned?"),
            ("personal_cook_eat", "Do you cook more or eat out more since moving to {city}?"),
            ("personal_putting_off", "What's something you've been putting off that you really should do?"),
            ("personal_local_friends", "Have you made any local friends here or mostly hang with other expats?"),
            ("personal_morning", "What's your morning routine like here compared to back home?"),
            ("personal_morning_night", "Are you a morning person or a night person? Has that changed since moving here?"),
            ("personal_laugh", "What's the last thing that made you laugh really hard?"),
            ("personal_workout", "Do you work out here? Found a gym or do something outdoors?"),
            ("personal_stay_touch", "How do you stay in touch with people back home?"),
            ("personal_comfort_food", "What's your go-to comfort food when you're feeling homesick?"),
            ("personal_reading", "Have you read anything good lately? Books, articles, anything?"),
            ("personal_best_decision", "What's the best decision you've made since moving to {city}?"),
            ("personal_small_joy", "What's something small that makes your day better here?"),
            ("personal_trips", "Do you have any trips coming up? Where are you thinking of going?"),
            ("personal_last_weekend", "What did you do last weekend? Anything fun?"),
            ("personal_unwind", "How do you unwind after a long day here?"),
            ("personal_hobbies", "Have you picked up any new hobbies since moving to {country}?"),
            ("personal_routine_surprise", "What's something about your routine here that would surprise your friends back home?"),
        ]
        for (id, text) in personal {
            t.append(ConversationTemplate(id: id, category: .personalLife, template: text))
        }

        // ═══════════════════════════════════════════
        // LANGUAGE & GROWTH
        // ═══════════════════════════════════════════
        let language: [(String, String)] = [
            ("lang_use_all_time", "What's a word or expression you learned here that you use all the time now?"),
            ("lang_no_translate", "Is there a local expression that doesn't translate at all to your language?"),
            ("lang_hard_topic", "What's a conversation topic that's still really hard for you in the language?"),
            ("lang_tv_shows", "Are you watching any local TV shows? What do you think of them?"),
            ("lang_movies", "Have you watched any local movies since you got here? Any favorites?"),
            ("lang_music_like", "What local music have you been listening to? Found anything you love?"),
            ("lang_music_hate", "Is there any local music that you really can't stand? What is it?"),
            ("lang_friends_correct", "Do your local friends correct you or just let mistakes slide?"),
            ("lang_false_friend", "What's a word that sounds like an English word but means something totally different?"),
            ("lang_switch_english", "How do you feel when someone switches to English because they hear your accent?"),
            ("lang_practice_slang", "Do you know any of the local slang from {city}? Let's practice some — I'll teach you a few good ones."),
            ("lang_country_slang", "Have you picked up any {country} slang yet? What expressions do you know?"),
            ("lang_slang_surprise", "There's an expression people use here that sounds really funny when you translate it literally. Want to hear it?"),
            ("lang_fav_expression", "What's your favorite local expression you've learned so far? Why do you like it?"),
            ("lang_bands", "Are you listening to any local bands or artists? Who's your favorite?"),
        ]
        for (id, text) in language {
            t.append(ConversationTemplate(id: id, category: .languageGrowth, template: text))
        }

        // ═══════════════════════════════════════════
        // NOSTALGIA & IDENTITY
        // ═══════════════════════════════════════════
        let nostalgia: [(String, String)] = [
            ("nostalgia_miss_most", "What do you miss most about home that you can't get here?"),
            ("nostalgia_changed_view", "Has living in {city} changed how you see your home country?"),
            ("nostalgia_appreciate_more", "What's something you appreciate about home MORE now that you're away?"),
            ("nostalgia_different_person", "Do you feel like a different person since you moved here?"),
            ("nostalgia_advice", "What would you tell someone who's thinking about moving to {city}?"),
            ("nostalgia_smell_song", "Is there a smell or a song that immediately takes you back home?"),
            ("nostalgia_culture_weird", "What's something from your culture that people here find weird or interesting?"),
            ("nostalgia_stay_long_term", "Do you think you'll stay in {city} long-term or is this temporary?"),
            ("nostalgia_most_wrong", "What's the thing you were most wrong about before you moved here?"),
            ("nostalgia_family_react", "How do your family and friends back home react when you tell them about life here?"),
            ("nostalgia_identity", "What's a part of your identity that's become more important since living abroad?"),
            ("nostalgia_bring_one_thing", "If you could bring one thing from home to {city}, what would it be?"),
            ("nostalgia_belonged", "What's a moment here where you felt like you truly belonged?"),
            ("nostalgia_never_moved", "What would your life look like right now if you'd never moved to {country}?"),
            ("nostalgia_hardest_nobody_talks", "What's the hardest thing about living far from home that nobody talks about?"),
        ]
        for (id, text) in nostalgia {
            t.append(ConversationTemplate(id: id, category: .nostalgiaIdentity, template: text))
        }

        // ═══════════════════════════════════════════
        // PLAYFUL & RANDOM
        // ═══════════════════════════════════════════
        let playful: [(String, String)] = [
            ("playful_one_food", "If you could only eat one {country} food for the rest of your life, what would it be?"),
            ("playful_unpopular", "Unpopular opinion about {city} — go."),
            ("playful_mountain_beach", "Would you rather live in the mountains or by the beach?"),
            ("playful_overrated", "What's the most overrated thing about {city}?"),
            ("playful_three_words", "If you had to describe {city} in three words, what would they be?"),
            ("playful_guilty_pleasure", "What's a guilty pleasure you have here that you'd never admit to people back home?"),
            ("playful_swap_lives", "If you could swap lives with any local for a day, who would it be and why?"),
            ("playful_tourist_trap", "What's the worst tourist trap in {city} that you fell for?"),
            ("playful_city_person", "If {city} was a person, what kind of personality would it have?"),
            ("playful_street_food", "What's the best street food you've ever had here? Describe it."),
            ("playful_accent_choice", "Would you rather speak perfect local language with a textbook accent, or broken with a perfect local accent?"),
            ("playful_most_local", "What's the most {country} thing you've done since arriving?"),
            ("playful_teleport_home", "If you could teleport home for one day and come back, what would you do?"),
            ("playful_slang_friends", "What's a local slang word you use that your friends back home wouldn't understand?"),
            ("playful_open_business", "If you opened a business in {city}, what would it be?"),
        ]
        for (id, text) in playful {
            t.append(ConversationTemplate(id: id, category: .playfulRandom, template: text))
        }

        return t
    }()
}
