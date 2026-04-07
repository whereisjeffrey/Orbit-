//
//  ConversationPoolManager.swift
//  TranslateHelper
//
//  Manages Sol's conversation pool — deep local references seeded by Gemini Flash
//  and refined over time based on user engagement.
//
//  Phase 1: Gemini seeds 6-10 deep references matched to city + interests.
//  Phase 2: Engagement scoring tags what works / what doesn't.
//  Phase 3: Community intelligence pools references across users.
//
//  Each reference has 4-5 layers of depth — enough for 3-4 exchanges before
//  Sol needs to move on. This is NOT a list of facts; it's conversation fuel.
//

import Foundation

// MARK: - Models

/// A single deep reference in Sol's conversation pool.
struct ConversationReference: Codable, Identifiable {
    let id: UUID
    var topic: String              // parent interest (e.g. "wellness") or "universal"
    var subtopic: String           // specific thing (e.g. "pilates_studio_condesa")
    var title: String              // human name: "Body Barre Condesa"
    var whatItIs: String           // 2-3 sentences: what this place/thing/experience is
    var whyInteresting: String     // why it connects to their interest
    var interestConnection: String // how it ties to what they told us
    var whatsNearby: String        // surrounding context (neighbourhood, other spots)
    var conversationHooks: [String] // 3 layered questions Sol can ask, each going deeper
    var deepFacts: [String]        // 2-3 surprising/specific facts (history, quirks, insider tips)
    var source: ReferenceSource
    var engagement: EngagementLevel?
    var refinements: [String]      // accumulated user preferences: "dislikes_yoga", "prefers_pilates"
    let createdAt: Date
    var lastServed: Date?          // when this reference was last served to Sol

    init(topic: String, subtopic: String, title: String, whatItIs: String,
         whyInteresting: String, interestConnection: String, whatsNearby: String,
         conversationHooks: [String], deepFacts: [String], source: ReferenceSource) {
        self.id = UUID()
        self.topic = topic
        self.subtopic = subtopic
        self.title = title
        self.whatItIs = whatItIs
        self.whyInteresting = whyInteresting
        self.interestConnection = interestConnection
        self.whatsNearby = whatsNearby
        self.conversationHooks = conversationHooks
        self.deepFacts = deepFacts
        self.source = source
        self.engagement = nil
        self.refinements = []
        self.createdAt = Date()
    }
}

enum ReferenceSource: String, Codable {
    case userSelected     // generated from an interest they explicitly picked
    case universal        // crowd-pleaser Gemini filled in (restaurants, neighbourhoods, etc.)
    case geminiInferred   // Gemini inferred from conversation history (they talked about it)
}

enum EngagementLevel: String, Codable {
    case high     // 3+ exchanges on this topic
    case medium   // 1-2 exchanges
    case low      // mentioned but user changed topic
    case rejected // user explicitly said no / showed disinterest
}

/// Tracks refined understanding of what the user actually likes within each interest.
struct InterestRefinement: Codable {
    var interest: String          // e.g. "wellness"
    var likes: [String]           // e.g. ["pilates", "breathwork"]
    var dislikes: [String]        // e.g. ["yoga", "meditation"]
    var specificPlaces: [String]  // places they've mentioned positively
    var updatedAt: Date
}

// MARK: - Manager

class ConversationPoolManager {
    static let shared = ConversationPoolManager()

    private static let appGroup = "group.com.jeff.translatehelper"
    private static let poolKey = "ts_conversation_pool_v1"
    private static let refinementsKey = "ts_interest_refinements_v1"
    private static let sessionCountKey = "ts_sol_session_count"
    private static let lastRefreshKey = "ts_pool_last_refresh"

    /// How many Sol sessions between Gemini refresh calls
    static let refreshInterval = 5

    private(set) var pool: [ConversationReference] = []
    private(set) var refinements: [InterestRefinement] = []

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: Self.appGroup)
    }

    private init() {
        loadPool()
        loadRefinements()
    }

    // MARK: - Pool Access for Sol

    /// Get 1-2 references for Sol to use in the current session.
    /// Prioritizes: high engagement > user_selected > universal > unused.
    /// Avoids recently-used references.
    func referencesForSession(count: Int = 2) -> [ConversationReference] {
        guard !pool.isEmpty else { return [] }

        // Filter out rejected references
        let available = pool.filter { $0.engagement != .rejected }
        guard !available.isEmpty else { return [] }

        // Sort: prefer unserved, then least recently served, then by engagement
        let sorted = available.sorted { a, b in
            // Never-served references come first
            let aServed = a.lastServed != nil
            let bServed = b.lastServed != nil
            if aServed != bServed { return !aServed }  // unserved first

            // Both served — prefer the one served longest ago
            if let aDate = a.lastServed, let bDate = b.lastServed {
                if abs(aDate.timeIntervalSince(bDate)) > 3600 {
                    return aDate < bDate  // older = higher priority
                }
            }

            // Tiebreak by engagement score
            let aScore = engagementScore(a)
            let bScore = engagementScore(b)
            return aScore > bScore
        }

        // Take top N, but ensure topic variety
        var selected: [ConversationReference] = []
        var usedTopics: Set<String> = []
        for ref in sorted {
            if !usedTopics.contains(ref.topic) || selected.count < count {
                selected.append(ref)
                usedTopics.insert(ref.topic)
                if selected.count >= count { break }
            }
        }

        // Mark as served
        for ref in selected {
            if let idx = pool.firstIndex(where: { $0.id == ref.id }) {
                pool[idx].lastServed = Date()
            }
        }
        savePool()

        return selected
    }

    /// Build a context block for Sol's system prompt with conversation pool references.
    func buildPoolContextBlock() -> String {
        let refs = referencesForSession(count: 2)
        guard !refs.isEmpty else { return "" }

        var block = "\nLOCAL KNOWLEDGE — Deep references matched to this user's interests:\n"
        block += "Use 1-2 of these naturally in conversation. Don't dump all info at once — "
        block += "reveal layers over multiple exchanges. Ask questions that lead deeper.\n\n"

        for ref in refs {
            block += "[\(ref.topic.uppercased())] \(ref.title)\n"
            block += "What: \(ref.whatItIs)\n"
            block += "Why interesting: \(ref.whyInteresting)\n"
            block += "Connection to user: \(ref.interestConnection)\n"
            block += "Nearby: \(ref.whatsNearby)\n"
            block += "Conversation hooks (use these to go deeper, one per exchange):\n"
            for (i, hook) in ref.conversationHooks.enumerated() {
                block += "  \(i + 1). \(hook)\n"
            }
            block += "Deep facts (reveal as conversation progresses):\n"
            for fact in ref.deepFacts {
                block += "  - \(fact)\n"
            }
            block += "\n"
        }

        // Add refinement context so Sol knows what to avoid
        let activeRefinements = refinements.filter { !$0.dislikes.isEmpty || !$0.likes.isEmpty }
        if !activeRefinements.isEmpty {
            block += "USER PREFERENCES (from past conversations):\n"
            for r in activeRefinements {
                if !r.likes.isEmpty {
                    block += "  \(r.interest): likes \(r.likes.joined(separator: ", "))\n"
                }
                if !r.dislikes.isEmpty {
                    block += "  \(r.interest): AVOID \(r.dislikes.joined(separator: ", "))\n"
                }
            }
            block += "\n"
        }

        return block
    }

    private func engagementScore(_ ref: ConversationReference) -> Int {
        switch ref.engagement {
        case .high: return 4
        case .medium: return 3
        case nil: return 2  // unused — try it
        case .low: return 1
        case .rejected: return 0
        }
    }

    // MARK: - Engagement Tracking

    /// Mark a reference's engagement level after a Sol session.
    func updateEngagement(referenceId: UUID, level: EngagementLevel) {
        if let idx = pool.firstIndex(where: { $0.id == referenceId }) {
            pool[idx].engagement = level
            savePool()
        }
    }

    /// Add a refinement from conversation (e.g., user said they hate yoga)
    func addRefinement(interest: String, likes: [String] = [], dislikes: [String] = []) {
        if let idx = refinements.firstIndex(where: { $0.interest == interest }) {
            for like in likes where !refinements[idx].likes.contains(like) {
                refinements[idx].likes.append(like)
            }
            for dislike in dislikes where !refinements[idx].dislikes.contains(dislike) {
                refinements[idx].dislikes.append(dislike)
            }
            refinements[idx].updatedAt = Date()
        } else {
            refinements.append(InterestRefinement(
                interest: interest,
                likes: likes,
                dislikes: dislikes,
                specificPlaces: [],
                updatedAt: Date()
            ))
        }
        saveRefinements()
    }

    // MARK: - Session Counter

    /// Increment Sol session count. Returns true if it's time for a Gemini refresh.
    func incrementSessionCount() -> Bool {
        let count = (defaults?.integer(forKey: Self.sessionCountKey) ?? 0) + 1
        defaults?.set(count, forKey: Self.sessionCountKey)
        return count % Self.refreshInterval == 0
    }

    // MARK: - Gemini API — Initial Seed

    /// Generate the initial conversation pool after onboarding.
    /// Called once after the user completes the interests step.
    func seedPool(city: String, interests: [String], goals: [String] = [], completion: @escaping (Bool) -> Void) {
        let prompt = buildSeedPrompt(city: city, interests: interests, goals: goals)
        callGemini(prompt: prompt) { [weak self] references in
            guard let self = self, let references = references else {
                NSLog("🌐 [ConvPool] Seed failed — Gemini returned nil")
                completion(false)
                return
            }
            self.pool = references
            self.savePool()
            NSLog("🌐 [ConvPool] Seeded \(references.count) references for \(city)")
            completion(true)
        }
    }

    /// Refresh the pool after N Sol sessions. Sends conversation history
    /// so Gemini can infer new interests and update refinements.
    func refreshPool(
        city: String,
        interests: [String],
        recentConversationSummary: String,
        completion: @escaping (Bool) -> Void
    ) {
        let prompt = buildRefreshPrompt(
            city: city,
            interests: interests,
            conversationSummary: recentConversationSummary,
            currentRefinements: refinements,
            existingTopics: pool.map { $0.title }
        )

        callGemini(prompt: prompt) { [weak self] references in
            guard let self = self, let references = references else {
                NSLog("🌐 [ConvPool] Refresh failed")
                completion(false)
                return
            }

            // Merge: keep high-engagement references, replace low/unused ones
            var kept = self.pool.filter { $0.engagement == .high || $0.engagement == .medium }
            kept.append(contentsOf: references)

            // Cap at 15 references total
            if kept.count > 15 {
                kept = Array(kept.prefix(15))
            }

            self.pool = kept
            self.savePool()
            self.defaults?.set(Date().timeIntervalSince1970, forKey: Self.lastRefreshKey)
            NSLog("🌐 [ConvPool] Refreshed: kept \(kept.count - references.count) old, added \(references.count) new")
            completion(true)
        }
    }

    // MARK: - Prompt Building

    private func buildSeedPrompt(city: String, interests: [String], goals: [String] = []) -> String {
        let interestCount = interests.count
        let langName = LanguageManager.shared.targetLangName ?? "the local language"

        // Dynamic rules based on how many interests the user gave us
        let distributionRule: String
        let totalReferences: Int

        if interestCount <= 2 {
            // Few interests — fill with universals so Sol isn't monotonous
            totalReferences = 8
            distributionRule = """
            The user only selected \(interestCount) interest(s): \(interests.joined(separator: ", ")).
            Generate 3 references specifically about their interest(s).
            Generate 5 UNIVERSAL references — things almost everyone enjoys:
            great neighbourhoods to explore, beloved local restaurants, surprising local customs,
            hidden spots tourists discover, iconic local experiences.
            Tag interest-specific references as "user_selected" and universals as "universal".
            """
        } else if interestCount <= 4 {
            // Moderate — mostly their interests, a couple universals
            totalReferences = 8
            distributionRule = """
            The user selected \(interestCount) interests: \(interests.joined(separator: ", ")).
            Generate 2 references per interest (\(interestCount * 2) total from interests).
            Generate \(max(8 - interestCount * 2, 2)) UNIVERSAL references — beloved local spots,
            surprising customs, iconic experiences that anyone would enjoy.
            Tag interest references as "user_selected" and universals as "universal".
            """
        } else {
            // Many interests — no universals needed, just rotate across interests
            totalReferences = min(interestCount * 2, 12)
            distributionRule = """
            The user selected \(interestCount) interests: \(interests.joined(separator: ", ")).
            Generate 1-2 references per interest. You have enough variety from their interests alone —
            no universal filler needed. All references are "user_selected".
            """
        }

        // Goals framing — changes the ANGLE of references, not the topics
        let goalsBlock: String
        if goals.isEmpty {
            goalsBlock = "No specific goals provided — frame references for casual everyday use."
        } else {
            let goalDescriptions = goals.map { goal -> String in
                switch goal {
                case "Work": return "Work/Professional — include business-relevant spots, networking locations, professional dining etiquette, formal register situations"
                case "Flirty": return "Dating/Flirty — include date-night spots, romantic locations, charming ways to use the language, social nightlife"
                case "Family": return "Family — include kid-friendly spots, family activities, local parenting culture, family-oriented neighbourhoods"
                case "Travel": return "Travel — include must-see landmarks, day trips, transportation tips, tourist-to-local transitions"
                case "Casual": return "Casual socializing — include hangout spots, bars, cafés, casual friend-making situations"
                case "Culture": return "Culture — include museums, galleries, performances, local traditions, cultural etiquette"
                default: return goal
                }
            }
            goalsBlock = """
            WHY THEY'RE LEARNING (frame references through this lens):
            \(goalDescriptions.joined(separator: "\n"))

            This changes the ANGLE, not the topics. A taco stand framed for "Flirty" = great date spot, \
            how to charm the vendor. The same taco stand framed for "Family" = kids love it, \
            what to order for picky eaters. Match the framing to their goals.
            """
        }

        return """
        You are a local knowledge expert for \(city). Generate exactly \(totalReferences) deep \
        conversation references for a language coach (Sol) to use with an English-speaking expat \
        learning \(langName) in \(city).

        \(distributionRule)

        \(goalsBlock)

        CRITICAL — DEPTH REQUIREMENT:
        Each reference must have enough depth for 3-4 back-and-forth exchanges.
        Do NOT just name a place. For each reference, provide:
        1. what_it_is: 2-3 sentences describing what this place/experience/thing is.
           Include specific details — when it was built, what makes it unique, what you see/feel there.
        2. why_interesting: Why would someone with this interest care? Connect it emotionally.
        3. interest_connection: How does this specifically tie to what they told us they like?
        4. whats_nearby: What's in the surrounding area? Other spots, the neighbourhood vibe,
           what locals do in that area.
        5. conversation_hooks: 5 questions Sol can ask, each going ONE LAYER DEEPER:
           - Hook 1: Surface-level opener ("Have you checked out X?")
           - Hook 2: Goes deeper ("The interesting thing about X is... did you know...?")
           - Hook 3: Personal connection ("What's your favourite part of...?" / "Does it remind you of...?")
           - Hook 4: Tangent/related ("That reminds me, have you tried...?" / "The guy who built that also...")
           - Hook 5: Story/anecdote ("There's a crazy story about this place..." / cultural context)
        6. deep_facts: 5-8 surprising, specific facts — history, insider tips, local quirks,
           behind-the-scenes stories, what regulars know, seasonal changes, funny local opinions.
           Things you'd only know if you lived there. NOT generic tourist info.
           The more facts, the more exchanges Sol can sustain before running dry.

        CONCISENESS: Keep each field tight — 1-2 sentences for what_it_is, why_interesting,
        interest_connection, whats_nearby. Hooks and facts can be one line each.
        Depth comes from QUANTITY of hooks and facts, not length of prose.

        ACCURACY RULE:
        ONLY include places, experiences, and facts that ACTUALLY exist in \(city).
        Do NOT invent places. Do NOT reference things from other cities.
        If you're unsure something exists, skip it — trust is everything.

        Respond ONLY with valid JSON — no markdown, no code fences, no explanation:
        [
          {
            "topic": "the parent interest or 'universal'",
            "subtopic": "specific_thing_snake_case",
            "title": "Human-Readable Name",
            "what_it_is": "...",
            "why_interesting": "...",
            "interest_connection": "...",
            "whats_nearby": "...",
            "conversation_hooks": ["hook 1", "hook 2", "hook 3", "hook 4", "hook 5"],
            "deep_facts": ["fact 1", "fact 2", "fact 3", "fact 4", "fact 5"],
            "source": "user_selected" or "universal"
          }
        ]
        """
    }

    private func buildRefreshPrompt(
        city: String,
        interests: [String],
        conversationSummary: String,
        currentRefinements: [InterestRefinement],
        existingTopics: [String]
    ) -> String {
        let langName = LanguageManager.shared.targetLangName ?? "the local language"

        var refinementBlock = ""
        for r in currentRefinements where !r.likes.isEmpty || !r.dislikes.isEmpty {
            refinementBlock += "- \(r.interest): "
            if !r.likes.isEmpty { refinementBlock += "LIKES \(r.likes.joined(separator: ", ")). " }
            if !r.dislikes.isEmpty { refinementBlock += "DISLIKES \(r.dislikes.joined(separator: ", ")). " }
            refinementBlock += "\n"
        }

        return """
        You are a local knowledge expert for \(city). An English-speaking expat learning \(langName) \
        has been having conversations with their language coach (Sol).

        Their interests: \(interests.joined(separator: ", "))

        WHAT WE'VE LEARNED ABOUT THEIR PREFERENCES:
        \(refinementBlock.isEmpty ? "No refinements yet." : refinementBlock)

        RECENT CONVERSATION SUMMARY:
        \(conversationSummary)

        EXISTING REFERENCES (don't duplicate these):
        \(existingTopics.joined(separator: ", "))

        Generate 4-6 NEW deep references based on:
        1. What they actually engaged with in conversations (infer interests from the summary)
        2. Their refined preferences (avoid things they've rejected)
        3. New angles on interests they haven't explored yet

        Tag any reference inferred from conversation as "gemini_inferred".
        Tag any reference from their explicit interests as "user_selected".

        DEPTH REQUIREMENT — same as initial seed:
        Each reference needs: what_it_is (2-3 sentences), why_interesting, interest_connection,
        whats_nearby, conversation_hooks (5 layered questions), deep_facts (5-8 surprising facts).

        ACCURACY: Only real places/experiences in \(city). Never invent.

        Respond ONLY with valid JSON array — no markdown, no fences:
        [
          {
            "topic": "interest or 'inferred'",
            "subtopic": "specific_thing_snake_case",
            "title": "Name",
            "what_it_is": "...",
            "why_interesting": "...",
            "interest_connection": "...",
            "whats_nearby": "...",
            "conversation_hooks": ["...", "...", "..."],
            "deep_facts": ["...", "..."],
            "source": "user_selected" or "gemini_inferred"
          }
        ]
        """
    }

    // MARK: - Live Reference Generation (per-session, on demand)

    /// Generate a single specific reference for TODAY's opener.
    /// Uses the user's full profile + a specific topic from the rotation.
    func generateLiveReference(
        city: String,
        topic: String,
        userProfile: String,
        interests: [String],
        completion: @escaping (ConversationReference?) -> Void
    ) {
        let langName = LanguageManager.shared.targetLangName ?? "the local language"

        // Rotate which interest to research this session
        let sessionCount = defaults?.integer(forKey: Self.sessionCountKey) ?? 0
        let targetInterest = interests.isEmpty ? "general" : interests[sessionCount % interests.count]

        let prompt = """
        You are a local expert for \(city). Generate exactly 1 deep, SPECIFIC reference \
        for a language coach to use with an English-speaking expat learning \(langName).

        TODAY'S TOPIC CATEGORY: \(topic)
        INTEREST TO FOCUS ON: \(targetInterest)

        USER PROFILE (for context — frame the reference through their life):
        \(userProfile.isEmpty ? "No profile yet" : userProfile)

        CRITICAL RULES:
        - The reference must be a REAL place, event, tradition, or experience in \(city).
        - NEVER invent something. If you're not sure it exists, pick something you ARE sure about.
        - Be HYPER-SPECIFIC: not "a museum" but "the Museu de Arte do Rio in Praça Mauá."
        - Not "a festival" but "the Festa de São João in June with forró dancing."
        - Include details only a local would know — insider tips, best times, hidden aspects.
        - Make it something that sparks a CONVERSATION, not just a fact dump.

        Respond with JSON only — no markdown, no fences:
        {
          "topic": "\(targetInterest)",
          "subtopic": "specific_thing_snake_case",
          "title": "The Exact Name",
          "what_it_is": "2-3 sentences: what this is, specific details",
          "why_interesting": "why someone into \(targetInterest) would care",
          "interest_connection": "how it ties to their life",
          "whats_nearby": "surrounding area, neighbourhood vibe",
          "conversation_hooks": ["hook 1 — surface opener", "hook 2 — goes deeper", "hook 3 — personal"],
          "deep_facts": ["surprising fact 1", "surprising fact 2", "surprising fact 3"],
          "source": "gemini_inferred"
        }
        """

        let apiKey = APIConfig.geminiAPIKey
        guard let url = URL(string: "\(APIConfig.geminiBaseURL)?key=\(apiKey)") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 12

        let body: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]],
            "generationConfig": [
                "temperature": 0.8,
                "maxOutputTokens": 2048,
                "responseMimeType": "application/json",
                "thinkingConfig": ["thinkingBudget": 0]
            ]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let candidates = json["candidates"] as? [[String: Any]],
                  let content = candidates.first?["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let text = parts.first?["text"] as? String else {
                NSLog("🌐 [LiveRef] Gemini request failed: \(error?.localizedDescription ?? "parse error")")
                completion(nil)
                return
            }

            let references = self?.parseReferences(from: text) ?? []
            if let ref = references.first {
                NSLog("🌐 [LiveRef] Generated: \(ref.title) [\(ref.topic)]")
                DispatchQueue.main.async { completion(ref) }
            } else {
                NSLog("🌐 [LiveRef] Failed to parse reference")
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }

    // MARK: - Gemini API Call

    private func callGemini(prompt: String, completion: @escaping ([ConversationReference]?) -> Void) {
        let apiKey = APIConfig.geminiAPIKey
        guard !apiKey.isEmpty else {
            NSLog("🌐 [ConvPool] No Gemini API key configured")
            completion(nil)
            return
        }

        guard let url = URL(string: "\(APIConfig.geminiBaseURL)?key=\(apiKey)") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 90

        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "temperature": 0.8,
                "maxOutputTokens": 16384,
                "responseMimeType": "application/json"
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                NSLog("🌐 [ConvPool] Gemini request failed: \(error?.localizedDescription ?? "no data")")
                completion(nil)
                return
            }

            // Parse Gemini response envelope
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let candidates = json["candidates"] as? [[String: Any]],
                  let content = candidates.first?["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let text = parts.first?["text"] as? String else {
                NSLog("🌐 [ConvPool] Failed to parse Gemini envelope: \(String(data: data, encoding: .utf8)?.prefix(500) ?? "nil")")
                completion(nil)
                return
            }

            // Parse the JSON array of references
            let references = self.parseReferences(from: text)
            DispatchQueue.main.async {
                completion(references.isEmpty ? nil : references)
            }
        }.resume()
    }

    private func parseReferences(from text: String) -> [ConversationReference] {
        // Try direct parse as array first
        if let data = text.data(using: .utf8),
           let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return array.compactMap { parseReference($0) }
        }

        // Try as single object (Gemini sometimes returns {} instead of [{}])
        if let data = text.data(using: .utf8),
           let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let ref = parseReference(obj) {
            return [ref]
        }

        // Strip markdown fences if present
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let data = cleaned.data(using: .utf8),
           let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return array.compactMap { parseReference($0) }
        }

        NSLog("🌐 [ConvPool] Failed to parse references JSON: \(text.prefix(300))")
        return []
    }

    private func parseReference(_ dict: [String: Any]) -> ConversationReference? {
        guard let topic = dict["topic"] as? String,
              let subtopic = dict["subtopic"] as? String,
              let title = dict["title"] as? String,
              let whatItIs = dict["what_it_is"] as? String,
              let whyInteresting = dict["why_interesting"] as? String else {
            return nil
        }

        let sourceStr = dict["source"] as? String ?? "universal"
        let source: ReferenceSource = {
            switch sourceStr {
            case "user_selected": return .userSelected
            case "gemini_inferred": return .geminiInferred
            default: return .universal
            }
        }()

        return ConversationReference(
            topic: topic,
            subtopic: subtopic,
            title: title,
            whatItIs: whatItIs,
            whyInteresting: whyInteresting,
            interestConnection: dict["interest_connection"] as? String ?? "",
            whatsNearby: dict["whats_nearby"] as? String ?? "",
            conversationHooks: dict["conversation_hooks"] as? [String] ?? [],
            deepFacts: dict["deep_facts"] as? [String] ?? [],
            source: source
        )
    }

    // MARK: - Persistence

    private func savePool() {
        guard let defaults = defaults,
              let data = try? JSONEncoder().encode(pool) else { return }
        defaults.set(data, forKey: Self.poolKey)
        defaults.synchronize()
    }

    private func loadPool() {
        guard let defaults = defaults,
              let data = defaults.data(forKey: Self.poolKey),
              let decoded = try? JSONDecoder().decode([ConversationReference].self, from: data) else { return }
        pool = decoded
    }

    private func saveRefinements() {
        guard let defaults = defaults,
              let data = try? JSONEncoder().encode(refinements) else { return }
        defaults.set(data, forKey: Self.refinementsKey)
        defaults.synchronize()
    }

    private func loadRefinements() {
        guard let defaults = defaults,
              let data = defaults.data(forKey: Self.refinementsKey),
              let decoded = try? JSONDecoder().decode([InterestRefinement].self, from: data) else { return }
        refinements = decoded
    }

    // MARK: - Live Enrichment (mid-conversation Gemini lookup)

    /// Extra context fetched mid-conversation, injected into Sol's next turn.
    /// Cleared after being consumed so it doesn't repeat.
    private(set) var liveEnrichment: String?

    /// Consume the live enrichment (called when building Sol's system prompt).
    /// Returns the enrichment text and clears it so it's only used once.
    func consumeEnrichment() -> String? {
        guard let text = liveEnrichment else { return nil }
        liveEnrichment = nil
        return text
    }

    /// Fire a background Gemini call to get deeper info on whatever the user just asked about.
    /// Called after each Sol response with the last few messages as context.
    /// The result lands in `liveEnrichment` — available for Sol's NEXT turn.
    func enrichFromConversation(city: String, recentMessages: [(role: String, text: String)]) {
        // Only enrich if there's something to work with
        guard recentMessages.count >= 2 else { return }

        // Build a brief context from the last few exchanges
        let context = recentMessages.suffix(4)
            .map { "\($0.role == "user" ? "User" : "Sol"): \($0.text)" }
            .joined(separator: "\n")

        let langName = LanguageManager.shared.targetLangName ?? "the local language"

        let prompt = """
        A language learner in \(city) (learning \(langName)) is having a conversation \
        with their coach. Based on the recent exchange below, provide deep background \
        knowledge that the coach can use in the NEXT response.

        RECENT CONVERSATION:
        \(context)

        Provide 5-8 specific, interesting facts about whatever the user is asking about \
        or showing interest in. Focus on:
        - Surprising details, history, insider knowledge
        - Local connections to \(city) if any exist
        - Things that would make the conversation richer and more engaging
        - Cultural context a foreigner wouldn't know

        ACCURACY: Only state facts you're confident about. Never invent.

        Respond as a plain text list — one fact per line, starting with "- ". \
        No JSON, no markdown headers. Keep each fact to 1-2 sentences.
        """

        // Lightweight call — shorter timeout, less tokens
        let apiKey = APIConfig.geminiAPIKey
        guard !apiKey.isEmpty,
              let url = URL(string: "\(APIConfig.geminiBaseURL)?key=\(apiKey)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15  // fast — this is a background boost, not critical

        let body: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 1024
            ]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let candidates = json["candidates"] as? [[String: Any]],
                  let content = candidates.first?["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let text = parts.first?["text"] as? String,
                  !text.isEmpty else {
                NSLog("🌐 [Enrichment] failed: \(error?.localizedDescription ?? "parse error")")
                return
            }

            DispatchQueue.main.async {
                self?.liveEnrichment = text
                NSLog("🌐 [Enrichment] ready for next turn (\(text.prefix(80))...)")
            }
        }.resume()
    }

    // MARK: - Debug

    var poolSummary: String {
        let byTopic = Dictionary(grouping: pool, by: { $0.topic })
        return byTopic.map { "\($0.key): \($0.value.count) refs" }.joined(separator: ", ")
    }
}
