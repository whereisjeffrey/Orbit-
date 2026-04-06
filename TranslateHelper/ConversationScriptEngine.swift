//
//  ConversationScriptEngine.swift
//  TranslateHelper
//
//  Smart conversation openers for Sol based on the user's onboarding data.
//  Scripts fire once each, never repeat, and branch dynamically.
//
//  Layer 1: Status-based openers (relationship to the city)
//  Layer 2: Interest sub-branches (follow-up after status opener)
//  Layer 3: City transition scripts (digital nomad detection)
//
//  Scripts are DIRECTIONS, not rigid dialogue. Sol generates the actual
//  message in the target language. Gemini live enrichment handles depth.
//

import Foundation

// MARK: - Script Model

struct ConversationScript: Codable, Identifiable {
    let id: String                  // unique key: "visiting_been_before"
    let layer: ScriptLayer
    let status: String?             // which ExpatStatus this applies to (nil = any)
    let interest: String?           // which interest this targets (nil = any)
    let direction: String           // what Sol should ask/talk about — injected into system prompt
    let requiresCity: Bool          // whether to include city name in the direction
    let priority: Int               // higher = picked first (1-10)

    enum ScriptLayer: String, Codable {
        case status       // Layer 1: based on how long they've been there
        case interest     // Layer 2: based on their interests
        case cityTransition // Layer 3: new city added
    }
}

// MARK: - Engine

class ConversationScriptEngine {
    static let shared = ConversationScriptEngine()

    private static let appGroup = "group.com.jeff.translatehelper"
    private static let usedKey = "ts_used_scripts_v1"
    private static let lastCategoryKey = "ts_last_script_category"

    /// IDs of scripts that have already been used — never fire again
    private var usedScripts: Set<String> = []

    /// Last script category used — prevents back-to-back same category
    private var lastCategory: String = ""

    private init() {
        loadUsed()
    }

    // MARK: - Pick Next Script

    /// Pick the best unused script for this user's current context.
    /// Returns a direction string to inject into Sol's system prompt, or nil if exhausted.
    func pickScript() -> String? {
        let status = UserDefaults.standard.string(forKey: "user_expat_status") ?? ""
        let interestsRaw = UserDefaults.standard.string(forKey: "user_interests") ?? ""
        let interests = Set(interestsRaw.split(separator: ",").map(String.init))
        let cityName = UserLocationsStore.shared.locations.first?.displayName ?? ""

        // Gather all eligible scripts
        var candidates: [ConversationScript] = []

        // Layer 1: Status scripts
        let statusScripts = Self.allScripts.filter { script in
            script.layer == .status &&
            !usedScripts.contains(script.id) &&
            (script.status == nil || script.status == status)
        }
        candidates.append(contentsOf: statusScripts)

        // Layer 2: Interest scripts (only for interests the user selected)
        let interestScripts = Self.allScripts.filter { script in
            script.layer == .interest &&
            !usedScripts.contains(script.id) &&
            (script.interest == nil || interests.contains(script.interest ?? ""))
        }
        candidates.append(contentsOf: interestScripts)

        // Layer 3: City transition (only if multiple locations)
        if UserLocationsStore.shared.locations.count > 1 {
            let cityScripts = Self.allScripts.filter { script in
                script.layer == .cityTransition &&
                !usedScripts.contains(script.id)
            }
            candidates.append(contentsOf: cityScripts)
        }

        // Filter out same category as last time (prevent back-to-back)
        let varied = candidates.filter { categoryKey($0) != lastCategory }
        let pool = varied.isEmpty ? candidates : varied

        guard !pool.isEmpty else { return nil }

        // Sort by priority (highest first), then pick from top tier with some randomness
        let sorted = pool.sorted { $0.priority > $1.priority }
        let topPriority = sorted[0].priority
        let topTier = sorted.filter { $0.priority >= topPriority - 1 }
        let picked = topTier.randomElement()!

        // Mark as used
        usedScripts.insert(picked.id)
        lastCategory = categoryKey(picked)
        saveUsed()

        // Build the direction with city name
        var direction = picked.direction
        if !cityName.isEmpty {
            direction = direction.replacingOccurrences(of: "{city}", with: cityName)
        }

        NSLog("🎬 [Script] picked: \(picked.id) (layer: \(picked.layer.rawValue))")
        return direction
    }

    /// Build a system prompt block with the script direction.
    func buildScriptBlock() -> String {
        guard let direction = pickScript() else { return "" }

        return """

        CONVERSATION OPENER — USE THIS FOR YOUR FIRST MESSAGE:
        \(direction)

        This is a DIRECTION, not a script. Generate your message naturally in the target \
        language based on this direction. Make it feel like a real question from a friend, \
        not a survey. After the user responds, follow THEIR lead — the direction is just \
        for the opening.
        """
    }

    private func categoryKey(_ script: ConversationScript) -> String {
        if let status = script.status { return "status_\(status)" }
        if let interest = script.interest { return "interest_\(interest)" }
        return script.layer.rawValue
    }

    // MARK: - Persistence

    private func saveUsed() {
        let defaults = UserDefaults(suiteName: Self.appGroup)
        defaults?.set(Array(usedScripts), forKey: Self.usedKey)
        defaults?.set(lastCategory, forKey: Self.lastCategoryKey)
        defaults?.synchronize()
    }

    private func loadUsed() {
        let defaults = UserDefaults(suiteName: Self.appGroup)
        if let arr = defaults?.stringArray(forKey: Self.usedKey) {
            usedScripts = Set(arr)
        }
        lastCategory = defaults?.string(forKey: Self.lastCategoryKey) ?? ""
    }

    /// Reset all scripts (for testing / new city)
    func resetAll() {
        usedScripts.removeAll()
        lastCategory = ""
        saveUsed()
        NSLog("🎬 [Script] all scripts reset")
    }

    /// How many scripts are left unused
    var remainingCount: Int {
        Self.allScripts.count - usedScripts.count
    }

    // MARK: - Script Database

    static let allScripts: [ConversationScript] = {
        var scripts: [ConversationScript] = []

        // ═══════════════════════════════════════════════════════
        // LAYER 1: STATUS-BASED OPENERS
        // ═══════════════════════════════════════════════════════

        // ── JUST VISITING ─────────────────────────────────────
        scripts.append(contentsOf: [
            ConversationScript(
                id: "visiting_party_opener",
                layer: .status, status: "visiting", interest: nil,
                direction: "First ever conversation. Use their city. Think of it like meeting them at a party: 'So, what brings you to {city}? How are you liking it so far?' Keep it exactly this open-ended — one natural question that lets them take it anywhere. Don't ask about specific topics yet.",
                requiresCity: true, priority: 10
            ),
            ConversationScript(
                id: "visiting_been_before",
                layer: .status, status: "visiting", interest: nil,
                direction: "Ask if they've been to {city} before. If yes, ask what they did last time and what was their favourite part. If no, ask what made them pick this city.",
                requiresCity: true, priority: 9
            ),
            ConversationScript(
                id: "visiting_how_long",
                layer: .status, status: "visiting", interest: nil,
                direction: "Ask how long they're in {city} for. If it's short (under a week), ask what they absolutely need to see before they leave. If longer, ask if they're planning to explore outside the city too.",
                requiresCity: true, priority: 9
            ),
            ConversationScript(
                id: "visiting_solo_or_group",
                layer: .status, status: "visiting", interest: nil,
                direction: "Ask if they're travelling solo or with people. If solo, ask if they've met anyone cool. If with a group, ask what the group vibe is — adventure or chill.",
                requiresCity: false, priority: 8
            ),
            ConversationScript(
                id: "visiting_where_staying",
                layer: .status, status: "visiting", interest: nil,
                direction: "Ask what part of {city} they're staying in. React to their answer with something specific about that neighbourhood — a tip, a spot, a vibe description.",
                requiresCity: true, priority: 8
            ),
            ConversationScript(
                id: "visiting_favourite_so_far",
                layer: .status, status: "visiting", interest: nil,
                direction: "Ask what's been their favourite thing about {city} so far. Dig into their answer — ask for details, share a related recommendation.",
                requiresCity: true, priority: 7
            ),
            ConversationScript(
                id: "visiting_tried_ordering",
                layer: .status, status: "visiting", interest: nil,
                direction: "Ask if they've tried ordering food or drinks in the local language yet. Share a useful phrase for ordering — something that makes you sound like a local, not a tourist.",
                requiresCity: false, priority: 7
            ),
            ConversationScript(
                id: "visiting_excited_about",
                layer: .status, status: "visiting", interest: nil,
                direction: "Ask what they're most excited about for this trip. Whatever they say, build on it with enthusiasm and a specific suggestion related to it.",
                requiresCity: false, priority: 6
            ),
            ConversationScript(
                id: "visiting_know_anyone",
                layer: .status, status: "visiting", interest: nil,
                direction: "Ask if they know anyone in {city} or if they're meeting all new people. If they don't know anyone, suggest great social spots or activities where travellers meet locals.",
                requiresCity: true, priority: 6
            ),
        ])

        // ── JUST ARRIVED (< 1 month) ─────────────────────────
        scripts.append(contentsOf: [
            ConversationScript(
                id: "arrived_party_opener",
                layer: .status, status: "just_arrived", interest: nil,
                direction: "First ever conversation. Use their city. Like meeting them at a party: 'So, you just got to {city} — how's it been? What made you come here?' One open-ended question. Let them tell their story. Don't ask about specific topics yet.",
                requiresCity: true, priority: 10
            ),
            ConversationScript(
                id: "arrived_how_going",
                layer: .status, status: "just_arrived", interest: nil,
                direction: "Welcome them to {city}! Ask how the first days/weeks have been treating them. Be warm — moving somewhere new is exciting but overwhelming.",
                requiresCity: true, priority: 9
            ),
            ConversationScript(
                id: "arrived_surprised",
                layer: .status, status: "just_arrived", interest: nil,
                direction: "Ask what's surprised them most about {city} so far — something they didn't expect. People love sharing their first impressions.",
                requiresCity: true, priority: 9
            ),
            ConversationScript(
                id: "arrived_neighbourhood",
                layer: .status, status: "just_arrived", interest: nil,
                direction: "Ask if they've found their go-to neighbourhood yet — the one they keep going back to. If yes, ask what they love about it. If not, suggest exploring a few and ask what vibe they're looking for.",
                requiresCity: false, priority: 8
            ),
            ConversationScript(
                id: "arrived_food_situation",
                layer: .status, status: "just_arrived", interest: nil,
                direction: "Ask how the food situation is going — are they cooking or eating out? Have they found any go-to spots? What do they miss from home food-wise?",
                requiresCity: false, priority: 8
            ),
            ConversationScript(
                id: "arrived_friends",
                layer: .status, status: "just_arrived", interest: nil,
                direction: "Ask if they've made any local friends yet or if they're still mostly around other expats. No judgment either way — just curious about their social circle.",
                requiresCity: false, priority: 7
            ),
            ConversationScript(
                id: "arrived_hardest_thing",
                layer: .status, status: "just_arrived", interest: nil,
                direction: "Ask what's been the hardest thing to figure out since arriving. Could be practical (transport, banking) or cultural (customs, social norms). Be empathetic.",
                requiresCity: false, priority: 7
            ),
            ConversationScript(
                id: "arrived_transport",
                layer: .status, status: "just_arrived", interest: nil,
                direction: "Ask how they're getting around — metro, Uber, bike, walking? Share a local transport tip they might not know.",
                requiresCity: false, priority: 6
            ),
            ConversationScript(
                id: "arrived_language_barrier",
                layer: .status, status: "just_arrived", interest: nil,
                direction: "Ask how the language barrier has been — are they managing or is it tough? This is a perfect coaching moment. Share an expression that helps in everyday situations.",
                requiresCity: false, priority: 6
            ),
            ConversationScript(
                id: "arrived_sim_phone",
                layer: .status, status: "just_arrived", interest: nil,
                direction: "Ask if they got a local SIM card sorted out or if they're still on roaming. Small practical question that shows you care about their actual life.",
                requiresCity: false, priority: 5
            ),
        ])

        // ── GETTING SETTLED (1-6 months) ──────────────────────
        scripts.append(contentsOf: [
            ConversationScript(
                id: "settling_party_opener",
                layer: .status, status: "settling", interest: nil,
                direction: "First ever conversation. Use their city. Like meeting them at a party: 'So, what brings you to {city}? How are you liking it so far?' Same open-ended energy as meeting someone new. Let them take it wherever they want — work, lifestyle, adventure. Don't ask about specific topics yet.",
                requiresCity: true, priority: 10
            ),
            ConversationScript(
                id: "settling_feels_like_home",
                layer: .status, status: "settling", interest: nil,
                direction: "Ask if {city} is starting to feel like home yet or if they still feel like a visitor. This is a deep question — let them reflect.",
                requiresCity: true, priority: 9
            ),
            ConversationScript(
                id: "settling_housing",
                layer: .status, status: "settling", interest: nil,
                direction: "Ask about their living situation — did they get their own apartment or still in an Airbnb? If Airbnb, mention that renting your own place saves a lot. If apartment, ask how the hunt was.",
                requiresCity: false, priority: 9
            ),
            ConversationScript(
                id: "settling_routine",
                layer: .status, status: "settling", interest: nil,
                direction: "Ask if they've got a daily routine going yet — morning café, favourite lunch spot, evening walk. Routines are how a place becomes home.",
                requiresCity: false, priority: 8
            ),
            ConversationScript(
                id: "settling_miss_home",
                layer: .status, status: "settling", interest: nil,
                direction: "Ask what they miss most about home. Be genuine — everyone misses something. It's a way to learn about where they're from too.",
                requiresCity: false, priority: 8
            ),
            ConversationScript(
                id: "settling_like_better",
                layer: .status, status: "settling", interest: nil,
                direction: "Ask what they like better about {city} compared to where they're from. People light up talking about what they love about their new home.",
                requiresCity: true, priority: 7
            ),
            ConversationScript(
                id: "settling_language_progress",
                layer: .status, status: "settling", interest: nil,
                direction: "Ask how their language skills are coming along — feeling more confident than when they arrived? Share encouragement and a useful expression for their level.",
                requiresCity: false, priority: 7
            ),
            ConversationScript(
                id: "settling_friend_group",
                layer: .status, status: "settling", interest: nil,
                direction: "Ask if they've built a friend group — local friends, other expats, or a mix? How did they meet people?",
                requiresCity: false, priority: 6
            ),
            ConversationScript(
                id: "settling_bureaucracy",
                layer: .status, status: "settling", interest: nil,
                direction: "Ask if they've had any bureaucracy adventures — visa, banking, paperwork. These stories are always entertaining and relatable for expats.",
                requiresCity: false, priority: 6
            ),
            ConversationScript(
                id: "settling_hidden_gem",
                layer: .status, status: "settling", interest: nil,
                direction: "Ask if they've discovered any neighbourhood or spot they didn't expect to love — a hidden gem they stumbled into.",
                requiresCity: false, priority: 5
            ),
            ConversationScript(
                id: "settling_advice_newbie",
                layer: .status, status: "settling", interest: nil,
                direction: "Ask what advice they'd give someone who just arrived in {city} today. People love being the expert.",
                requiresCity: true, priority: 5
            ),
        ])

        // ── I LIVE HERE (6+ months) ───────────────────────────
        scripts.append(contentsOf: [
            ConversationScript(
                id: "local_party_opener",
                layer: .status, status: "local", interest: nil,
                direction: "First ever conversation. Use their city. Like meeting them at a party: 'So, you're living in {city} — what's the story? What brought you here originally?' Open-ended — let them share their journey. Don't ask about specific topics yet.",
                requiresCity: true, priority: 10
            ),
            ConversationScript(
                id: "local_how_long_total",
                layer: .status, status: "local", interest: nil,
                direction: "Ask how long they've been in {city} total. Then react — whether it's 6 months or 5 years, acknowledge it and ask how the city has changed for them over time.",
                requiresCity: true, priority: 9
            ),
            ConversationScript(
                id: "local_still_love_it",
                layer: .status, status: "local", interest: nil,
                direction: "Ask if they still love {city} or if they're getting the itch to try somewhere new. No judgment — just genuine curiosity about their trajectory.",
                requiresCity: true, priority: 9
            ),
            ConversationScript(
                id: "local_originally_from",
                layer: .status, status: "local", interest: nil,
                direction: "Ask where they're originally from and how they'd compare it to {city}. What's better, what's worse, what's just different?",
                requiresCity: true, priority: 8
            ),
            ConversationScript(
                id: "local_still_frustrates",
                layer: .status, status: "local", interest: nil,
                direction: "Ask what's the one thing that STILL frustrates them about living in {city}, even after all this time. Everyone has that one thing.",
                requiresCity: true, priority: 8
            ),
            ConversationScript(
                id: "local_adopted_habits",
                layer: .status, status: "local", interest: nil,
                direction: "Ask what local habits or customs they've fully adopted — things they never did back home but now can't imagine not doing.",
                requiresCity: false, priority: 7
            ),
            ConversationScript(
                id: "local_dream_in_language",
                layer: .status, status: "local", interest: nil,
                direction: "Ask if they dream in the local language yet. It's a fun milestone question. If yes, ask when it first happened. If no, tell them it's coming.",
                requiresCity: false, priority: 7
            ),
            ConversationScript(
                id: "local_explored_country",
                layer: .status, status: "local", interest: nil,
                direction: "Ask if they've explored other cities in the country or if they mostly stick to {city}. If they've travelled around, ask for their favourite spot.",
                requiresCity: true, priority: 6
            ),
            ConversationScript(
                id: "local_long_term",
                layer: .status, status: "local", interest: nil,
                direction: "Ask if they think they'll stay long-term or if there's a next destination on the horizon. Where would they go next and why?",
                requiresCity: false, priority: 6
            ),
            ConversationScript(
                id: "local_unpopular_opinion",
                layer: .status, status: "local", interest: nil,
                direction: "Ask for their unpopular opinion about {city} — something they think but most people disagree with. This always sparks a fun conversation.",
                requiresCity: true, priority: 5
            ),
            ConversationScript(
                id: "local_tell_past_self",
                layer: .status, status: "local", interest: nil,
                direction: "Ask what they would tell their past self from when they first arrived. What do they wish they'd known?",
                requiresCity: false, priority: 5
            ),
        ])

        // ── PLANNING TO MOVE ──────────────────────────────────
        scripts.append(contentsOf: [
            ConversationScript(
                id: "planning_party_opener",
                layer: .status, status: "planning", interest: nil,
                direction: "First ever conversation. Use their city. Like meeting them at a party: 'So, you're thinking about moving to {city} — what's pulling you there?' Open-ended — could be work, love, adventure, a fresh start. Let them tell you. Don't ask about specific topics yet.",
                requiresCity: true, priority: 10
            ),
            ConversationScript(
                id: "planning_why_this_city",
                layer: .status, status: "planning", interest: nil,
                direction: "Ask what made them pick {city} — what drew them there specifically? Was it a recommendation, a visit, work, or just a feeling?",
                requiresCity: true, priority: 9
            ),
            ConversationScript(
                id: "planning_visited_before",
                layer: .status, status: "planning", interest: nil,
                direction: "Ask if they've visited {city} before or if they're going in blind. If visited, ask what neighbourhood they're eyeing. If blind, ask what they've heard about it.",
                requiresCity: true, priority: 9
            ),
            ConversationScript(
                id: "planning_housing",
                layer: .status, status: "planning", interest: nil,
                direction: "Ask if they've started looking at housing — Airbnb first or jumping straight to an apartment? Do they have a neighbourhood in mind?",
                requiresCity: false, priority: 8
            ),
            ConversationScript(
                id: "planning_know_anyone",
                layer: .status, status: "planning", interest: nil,
                direction: "Ask if they know anyone in {city} already. If yes, ask how they connected. If no, reassure them — fresh starts are exciting. Suggest expat communities.",
                requiresCity: true, priority: 8
            ),
            ConversationScript(
                id: "planning_excited_about",
                layer: .status, status: "planning", interest: nil,
                direction: "Ask what they're most excited about. Whatever it is, match their energy and add something they might not have thought of.",
                requiresCity: false, priority: 7
            ),
            ConversationScript(
                id: "planning_nervous_about",
                layer: .status, status: "planning", interest: nil,
                direction: "Ask what they're most nervous about. Be reassuring — share that it's normal and that most things work out easier than you expect.",
                requiresCity: false, priority: 7
            ),
            ConversationScript(
                id: "planning_learning_language",
                layer: .status, status: "planning", interest: nil,
                direction: "Ask if they've started learning any of the language yet or if they're planning to pick it up when they arrive. Great coaching moment — teach them a greeting locals actually use.",
                requiresCity: false, priority: 6
            ),
            ConversationScript(
                id: "planning_visa",
                layer: .status, status: "planning", interest: nil,
                direction: "Ask if they're sorting out visa stuff. Don't get too into the weeds — just ask if they know what they need. It's a practical question that shows you care.",
                requiresCity: false, priority: 6
            ),
            ConversationScript(
                id: "planning_work_or_off",
                layer: .status, status: "planning", interest: nil,
                direction: "Ask if they plan to work there (remote or local) or if they're taking time off. This tells you a lot about their lifestyle and what they'll need.",
                requiresCity: false, priority: 5
            ),
            ConversationScript(
                id: "planning_how_long",
                layer: .status, status: "planning", interest: nil,
                direction: "Ask how long they think they'll stay. Open-ended — could be 3 months, could be forever. Their answer shapes everything.",
                requiresCity: false, priority: 5
            ),
            ConversationScript(
                id: "planning_lived_abroad",
                layer: .status, status: "planning", interest: nil,
                direction: "Ask if they've lived abroad before. If yes, ask where and how it was — great for comparison. If no, acknowledge it's a big step and ask what pushed them to do it.",
                requiresCity: false, priority: 5
            ),
        ])

        // ═══════════════════════════════════════════════════════
        // LAYER 2: INTEREST SUB-BRANCHES
        // ═══════════════════════════════════════════════════════

        scripts.append(contentsOf: [
            // Outdoors
            ConversationScript(
                id: "interest_outdoors_what_kind",
                layer: .interest, status: nil, interest: "outdoors",
                direction: "Ask what kind of outdoor activities they're into — gym, CrossFit, climbing, surfing, hiking, running, cycling? Get specific. Whatever they say, you'll have more info next turn.",
                requiresCity: false, priority: 7
            ),
            ConversationScript(
                id: "interest_outdoors_found_spot",
                layer: .interest, status: nil, interest: "outdoors",
                direction: "Ask if they've found good spots for outdoor activities in {city} yet. If yes, ask for details. If no, show curiosity about what they're looking for.",
                requiresCity: true, priority: 6
            ),

            // Food
            ConversationScript(
                id: "interest_food_favourite",
                layer: .interest, status: nil, interest: "food",
                direction: "Ask what their favourite kind of food is — are they into local cuisine, or do they crave specific things from home? What's the best meal they've had in {city}?",
                requiresCity: true, priority: 7
            ),
            ConversationScript(
                id: "interest_food_cooking",
                layer: .interest, status: nil, interest: "food",
                direction: "Ask if they cook or mostly eat out. If they cook, ask if they've tried making any local dishes. If they eat out, ask for their go-to spot.",
                requiresCity: false, priority: 6
            ),

            // Nightlife
            ConversationScript(
                id: "interest_nightlife_scene",
                layer: .interest, status: nil, interest: "nightlife",
                direction: "Ask what their scene is — bars, clubs, live music, rooftops, house parties? What kind of night out do they love?",
                requiresCity: false, priority: 7
            ),
            ConversationScript(
                id: "interest_nightlife_found_spots",
                layer: .interest, status: nil, interest: "nightlife",
                direction: "Ask if they've found the good nightlife spots in {city} or if they're still figuring out where to go. Any favourite bars yet?",
                requiresCity: true, priority: 6
            ),

            // Wellness
            ConversationScript(
                id: "interest_wellness_practice",
                layer: .interest, status: nil, interest: "wellness",
                direction: "Ask what their wellness practice looks like — yoga, Pilates, breathwork, meditation, spa days, martial arts? Get specific about what they actually do.",
                requiresCity: false, priority: 7
            ),

            // Remote work
            ConversationScript(
                id: "interest_remote_setup",
                layer: .interest, status: nil, interest: "remote_work",
                direction: "Ask about their remote work setup — cowork space, café life, or working from home? What's their ideal work environment? Have they found good WiFi spots in {city}?",
                requiresCity: true, priority: 7
            ),

            // Music
            ConversationScript(
                id: "interest_music_taste",
                layer: .interest, status: nil, interest: "music",
                direction: "Ask what kind of music they're into. Have they discovered any local music they love? Been to any live shows in {city}? Do they play an instrument?",
                requiresCity: true, priority: 7
            ),

            // Arts & Culture
            ConversationScript(
                id: "interest_arts_what_kind",
                layer: .interest, status: nil, interest: "arts",
                direction: "Ask what kind of art they're into — galleries, street art, pottery, theater, film? Have they found the local art scene in {city} yet?",
                requiresCity: true, priority: 7
            ),

            // Photography
            ConversationScript(
                id: "interest_photography_shoot",
                layer: .interest, status: nil, interest: "photography",
                direction: "Ask what they like to shoot — street photography, landscapes, architecture, portraits? Have they found good spots in {city}? What gear do they use?",
                requiresCity: true, priority: 7
            ),

            // History
            ConversationScript(
                id: "interest_history_period",
                layer: .interest, status: nil, interest: "history",
                direction: "Ask what kind of history fascinates them — colonial, indigenous, architectural, political, food history? Have they visited any historical sites in {city}?",
                requiresCity: true, priority: 7
            ),

            // Family
            ConversationScript(
                id: "interest_family_kids",
                layer: .interest, status: nil, interest: "family",
                direction: "Ask about their family situation — kids? How old? How are they adjusting? Have they found good activities, parks, or schools in {city}?",
                requiresCity: true, priority: 7
            ),

            // Markets
            ConversationScript(
                id: "interest_markets_what_for",
                layer: .interest, status: nil, interest: "markets",
                direction: "Ask what they look for at markets — food, crafts, vintage, antiques? Have they found any good markets in {city}? What was the best find?",
                requiresCity: true, priority: 7
            ),

            // Language learning
            ConversationScript(
                id: "interest_language_approach",
                layer: .interest, status: nil, interest: "language",
                direction: "Ask about their approach to learning the language — conversation practice, apps, reading, podcasts, tandem partners? What's working best for them so far?",
                requiresCity: false, priority: 7
            ),

            // News & Events
            ConversationScript(
                id: "interest_news_following",
                layer: .interest, status: nil, interest: "news",
                direction: "Ask if they follow local news in {city} — do they know what's going on, or do they mostly hear about things through friends? Have any local holidays or events caught them off guard? Ask about upcoming holidays they might not know about.",
                requiresCity: true, priority: 7
            ),
            ConversationScript(
                id: "interest_news_neighbourhoods",
                layer: .interest, status: nil, interest: "news",
                direction: "Ask if they've noticed any neighbourhoods in {city} that are changing fast — gentrification, new restaurants popping up, areas getting more expensive. What do they think about it? Have they explored any up-and-coming areas?",
                requiresCity: true, priority: 6
            ),
        ])

        // ═══════════════════════════════════════════════════════
        // LAYER 3: CITY TRANSITION SCRIPTS
        // ═══════════════════════════════════════════════════════

        scripts.append(contentsOf: [
            ConversationScript(
                id: "city_new_been_before",
                layer: .cityTransition, status: nil, interest: nil,
                direction: "The user has added a new city to their locations. Ask if they've been there before. If yes, ask what they remember. If no, ask what made them choose it.",
                requiresCity: false, priority: 9
            ),
            ConversationScript(
                id: "city_new_vibe_different",
                layer: .cityTransition, status: nil, interest: nil,
                direction: "The user is heading to a new city. Mention that the vibe and slang might be different from where they are now. Ask if they want you to start switching to that region's expressions.",
                requiresCity: false, priority: 8
            ),
            ConversationScript(
                id: "city_new_housing",
                layer: .cityTransition, status: nil, interest: nil,
                direction: "The user is adding a new city. Ask if they've sorted out where they'll stay — Airbnb, hostel, apartment? Do they have a neighbourhood in mind?",
                requiresCity: false, priority: 7
            ),
            ConversationScript(
                id: "city_new_tips",
                layer: .cityTransition, status: nil, interest: nil,
                direction: "The user is heading somewhere new. Ask if they want some insider tips before they arrive — things that aren't in the guidebooks.",
                requiresCity: false, priority: 7
            ),
        ])

        // ═══════════════════════════════════════════════════════
        // SLANG DISCOVERY SCRIPTS (status-aware)
        // ═══════════════════════════════════════════════════════
        // These open conversations specifically around local slang,
        // tailored to how long the user has been in the city.

        scripts.append(contentsOf: [
            // Just visiting — tourist survival slang
            ConversationScript(
                id: "slang_visiting_basics",
                layer: .status, status: "visiting", interest: nil,
                direction: "Ask if they've picked up any local slang yet in {city}. Teach them one essential expression that tourists never learn but locals use constantly — something for ordering, greeting, or reacting. Make it fun, not a lecture. Use the expression naturally in your message so they see it in context.",
                requiresCity: true, priority: 8
            ),
            ConversationScript(
                id: "slang_visiting_surprise",
                layer: .status, status: "visiting", interest: nil,
                direction: "Tell them about an expression in {city} that sounds weird or funny when translated literally. Ask if they've heard anyone say it. These are the ones that make people laugh and stick in memory.",
                requiresCity: true, priority: 6
            ),

            // Just arrived — getting oriented with slang
            ConversationScript(
                id: "slang_arrived_heard",
                layer: .status, status: "just_arrived", interest: nil,
                direction: "Ask if they've heard any local expressions in {city} that confused them or they couldn't understand. Everyone has that moment in the first month. If they share one, explain it. If they can't think of one, teach them the most common street greeting locals use.",
                requiresCity: true, priority: 8
            ),
            ConversationScript(
                id: "slang_arrived_ordering",
                layer: .status, status: "just_arrived", interest: nil,
                direction: "Teach them how locals actually order food and drinks in {city} — the shorthand, the casual way, the expressions that make you sound like you belong. Use it in a natural sentence and ask if they've tried ordering like that.",
                requiresCity: true, priority: 7
            ),
            ConversationScript(
                id: "slang_arrived_reactions",
                layer: .status, status: "just_arrived", interest: nil,
                direction: "Teach them 2-3 local reaction expressions from {city} — how locals say 'wow', 'no way', 'that's awesome', 'come on'. These are the expressions that make you sound natural in casual conversation. Use one naturally in your opening message.",
                requiresCity: true, priority: 6
            ),

            // Getting settled — deeper slang
            ConversationScript(
                id: "slang_settling_neighbourhood",
                layer: .status, status: "settling", interest: nil,
                direction: "Ask which neighbourhood they spend the most time in. Then teach them slang or expressions specific to that area or the type of people there — baristas, market vendors, neighbours. The hyper-local stuff that textbooks never cover.",
                requiresCity: false, priority: 7
            ),
            ConversationScript(
                id: "slang_settling_work",
                layer: .status, status: "settling", interest: nil,
                direction: "Ask if they've had to use the language in any professional or practical situations — at the bank, with a landlord, at the doctor. Teach them the key expressions for that context that make you sound competent, not like a confused foreigner.",
                requiresCity: false, priority: 6
            ),
            ConversationScript(
                id: "slang_settling_friends",
                layer: .status, status: "settling", interest: nil,
                direction: "Ask if their local friends have taught them any slang that isn't in any dictionary. The best expressions come from friends, not apps. If they don't have local friends yet, teach them the expressions that help you MAKE local friends — casual greetings, invitations, compliments.",
                requiresCity: false, priority: 6
            ),

            // I live here — advanced / nuanced slang
            ConversationScript(
                id: "slang_local_regional",
                layer: .status, status: "local", interest: nil,
                direction: "Ask if they've noticed how slang differs between {city} and other cities in the country. Teach them an expression that's ONLY used in {city} — something that would confuse someone from another region. These regional gems are what mark you as truly local.",
                requiresCity: true, priority: 7
            ),
            ConversationScript(
                id: "slang_local_generational",
                layer: .status, status: "local", interest: nil,
                direction: "Ask what age group they hang out with most. Teach them slang specific to that generation — younger locals use completely different expressions than older ones. The expressions your 25-year-old friend uses vs your 50-year-old neighbour.",
                requiresCity: false, priority: 6
            ),
            ConversationScript(
                id: "slang_local_humour",
                layer: .status, status: "local", interest: nil,
                direction: "Ask if they understand local humour yet — sarcasm, wordplay, double meanings. Teach them an expression or joke that only works in the local language. Humour is the final frontier of fluency.",
                requiresCity: false, priority: 6
            ),

            // Planning to move — pre-arrival slang prep
            ConversationScript(
                id: "slang_planning_survival",
                layer: .status, status: "planning", interest: nil,
                direction: "Tell them you're going to teach them the 3 most important expressions they need to know before landing in {city}. Not textbook phrases — the real ones locals use every day. A greeting, a reaction, and a way to ask for help. Use each one naturally in a sentence.",
                requiresCity: true, priority: 8
            ),
            ConversationScript(
                id: "slang_planning_avoid",
                layer: .status, status: "planning", interest: nil,
                direction: "Teach them an expression or word that means something different in {city} than they might expect — a false friend or a word that's innocent in textbooks but has a different meaning on the street. These mistakes are funny but good to know before you arrive.",
                requiresCity: true, priority: 6
            ),

            // City transition — slang differences
            ConversationScript(
                id: "slang_city_switch",
                layer: .cityTransition, status: nil, interest: nil,
                direction: "The user is moving to a new city. Warn them that some expressions they learned in their current city might mean something different (or not exist) in the new one. Teach them 1-2 expressions that are specific to the new city and different from what they know.",
                requiresCity: false, priority: 8
            ),
        ])

        return scripts
    }()
}
