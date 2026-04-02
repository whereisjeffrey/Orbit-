//
//  StarterDeckSeeder.swift
//  TranslateHelper
//
//  Seeds 3 starter decks for every target language:
//    1. Timeless Adages  📜  — proverbs native speakers actually use today
//    2. Euphemisms       😏  — phrases with a double meaning
//    3. Dating & Romance 💘  — real phrases for love and connection
//
//  Spanish: uses existing static content instantly (FeaturedDeckContent f13/f14/f15).
//  All other languages: AI-generated via DeckGenerationService on first sign-up.
//

import Foundation

// MARK: - StarterDeckSeeder

final class StarterDeckSeeder {
    static let shared = StarterDeckSeeder()
    private init() {}

    // AppGroup shared between main app and keyboard extension
    private let appGroup = "group.com.jeff.translatehelper"

    /// The current target language code.
    var targetLanguageCode: String {
        LanguageManager.shared.targetLangRequired
    }

    /// Human-readable name for the target language.
    var targetLanguageName: String {
        allLanguages.first(where: { $0.code == targetLanguageCode })?.name ?? "English"
    }

    // MARK: - Seed

    /// Seeds the 3 starter decks for the current target language.
    /// - For Spanish + any language with pre-written content in StarterDeckContent,
    ///   returns immediately with static cards (no AI wait).
    /// - For all other languages, calls the AI generation service.
    /// - Calls `completion` on the main thread when done (success or failure).
    func seed(forceLanguage languageCode: String? = nil,
              completion: @escaping (Bool) -> Void) {
        let code = languageCode ?? targetLanguageCode
        let name = allLanguages.first(where: { $0.code == code })?.name ?? LanguageManager.languageName(for: code)

        if code == "es" {
            // ── Fast path: Spanish static content ───────────────────────
            seedStaticSpanish()
            DispatchQueue.main.async { completion(true) }
        } else if hasStaticContent(for: code) {
            // ── Fast path: pre-written static content for this language ──
            seedStaticLanguage(code: code, name: name)
            DispatchQueue.main.async { completion(true) }
        } else {
            // ── AI path: generate for target language ────────────────────
            Task {
                do {
                    try await seedAIDecks(languageCode: code, languageName: name)
                    await MainActor.run { completion(true) }
                } catch {
                    print("[StarterDeckSeeder] AI generation failed: \(error)")
                    await MainActor.run { completion(false) }
                }
            }
        }
    }

    /// Returns true if StarterDeckContent has pre-written cards for this language.
    private func hasStaticContent(for code: String) -> Bool {
        StarterDeckContent.cardsFor(lang: code, type: .timelessAdages) != nil
    }

    /// Seeds all 3 starter decks from StarterDeckContent (instant, no AI).
    private func seedStaticLanguage(code: String, name: String) {
        let store = DeckStore.shared
        for deck in store.decks { store.deleteDeck(deck) }

        let adages  = StarterDeckContent.cardsFor(lang: code, type: .timelessAdages)   ?? []
        let euph    = StarterDeckContent.cardsFor(lang: code, type: .euphemisms)        ?? []
        let romance = StarterDeckContent.cardsFor(lang: code, type: .datingAndRomance)  ?? []

        // Add in reverse so insert-at-0 gives: Timeless Adages | Euphemisms | Dating & Romance
        store.addDeck(Deck(emoji: "💘", name: "Dating & Romance",
                           deckDescription: "20 \(name) phrases for love, flirting & connection",
                           isAI: false, tintName: "pink", cards: romance))
        store.addDeck(Deck(emoji: "😏", name: "Euphemisms",
                           deckDescription: "20 \(name) phrases with a cheeky double meaning",
                           isAI: false, tintName: "purple", cards: euph))
        store.addDeck(Deck(emoji: "📜", name: "Timeless Adages",
                           deckDescription: "20 \(name) proverbs native speakers still use today",
                           isAI: false, tintName: "orange", cards: adages))
    }

    // MARK: - Static Spanish Path

    private func seedStaticSpanish() {
        let store = DeckStore.shared
        // Clear any existing decks first
        for deck in store.decks { store.deleteDeck(deck) }

        // Add in reverse so insert-at-0 gives: Timeless Adages | Euphemisms | Dating & Romance
        store.addDeck(Deck(
            emoji: "💘",
            name: "Dating & Romance",
            deckDescription: "30 Spanish phrases for love, flirting & connection",
            isAI: false, tintName: "pink",
            cards: FeaturedDeckContent.cards(forId: "f15")
        ))
        store.addDeck(Deck(
            emoji: "😏",
            name: "Euphemisms",
            deckDescription: "30 Spanish phrases with a cheeky double meaning",
            isAI: false, tintName: "purple",
            cards: FeaturedDeckContent.cards(forId: "f14")
        ))
        store.addDeck(Deck(
            emoji: "📜",
            name: "Timeless Adages",
            deckDescription: "30 Spanish proverbs native speakers still use today",
            isAI: false, tintName: "orange",
            cards: FeaturedDeckContent.cards(forId: "f13")
        ))
    }

    // MARK: - AI Path

    private func seedAIDecks(languageCode: String, languageName: String) async throws {
        let store = DeckStore.shared

        // ── Generate all 3 decks FIRST (before touching existing data) ──────
        // If any call throws, the user's current decks are untouched.
        async let adagesCards  = DeckGenerationService.shared.generateStarterDeck(type: .timelessAdages,   targetLanguage: languageName, languageCode: languageCode)
        async let euphCards    = DeckGenerationService.shared.generateStarterDeck(type: .euphemisms,       targetLanguage: languageName, languageCode: languageCode)
        async let romanceCards = DeckGenerationService.shared.generateStarterDeck(type: .datingAndRomance, targetLanguage: languageName, languageCode: languageCode)

        let (adages, euph, romance) = try await (adagesCards, euphCards, romanceCards)

        // ── All 3 succeeded — now atomically swap out the old decks ──────────
        await MainActor.run {
            // Remove only the old starter decks (not any user-created decks)
            for deck in store.decks { store.deleteDeck(deck) }

            // Add in reverse so insert-at-0 gives: Timeless Adages | Euphemisms | Dating & Romance
            store.addDeck(Deck(
                emoji: "💘",
                name: "Dating & Romance",
                deckDescription: "30 \(languageName) phrases for love, flirting & connection",
                isAI: true, tintName: "pink",
                cards: romance
            ))
            store.addDeck(Deck(
                emoji: "😏",
                name: "Euphemisms",
                deckDescription: "30 \(languageName) phrases with a cheeky double meaning",
                isAI: true, tintName: "purple",
                cards: euph
            ))
            store.addDeck(Deck(
                emoji: "📜",
                name: "Timeless Adages",
                deckDescription: "30 \(languageName) proverbs native speakers still use today",
                isAI: true, tintName: "orange",
                cards: adages
            ))
        }
    }
}


// MARK: - Starter Deck Type

enum StarterDeckType {
    case timelessAdages
    case euphemisms
    case datingAndRomance

    var systemPrompt: String {
        switch self {
        case .timelessAdages:
            return """
            You are a native-language expert and linguist. Generate exactly 30 flashcard pairs \
            for proverbs and adages that are genuinely used by native speakers TODAY.

            CRITICAL RULES — failure to follow these makes the deck useless:
            1. AUTHENTICITY FIRST: Do NOT simply translate English proverbs into TARGET LANGUAGE. \
               Find the proverb that native speakers of TARGET LANGUAGE actually say. \
               If a direct equivalent exists, great. If not, find the closest native expression \
               that carries the same wisdom — even if the imagery is completely different.
            2. CURRENCY: Every single phrase must be in active circulation RIGHT NOW. \
               If a proverb is archaic, regional, or something a grandparent said 50 years ago \
               but nobody says anymore — omit it. A learner repeating it to a native speaker \
               must immediately be understood and recognised.
            3. MIX: ~60% should be very well-known (a beginner-intermediate learner will \
               definitely encounter these), ~40% should be a step up — still widely used, \
               but the kind that would impress or surprise someone with intermediate knowledge.
            4. VARIETY: Cover diverse life themes — hard work, patience, luck, greed, \
               friendship, caution, timing, appearances. Do not repeat similar themes.
            5. NOTES: For each card, write a brief note explaining the literal meaning, \
               what it's really saying, and ideally a real-life context in which a \
               native speaker would drop it into conversation.

            Each card:
            - sourceText: The English equivalent OR a plain English description of the meaning
            - translatedText: The authentic TARGET LANGUAGE expression
            - notes: Literal meaning + real meaning + when it's used

            Return ONLY valid JSON as an array:
            [{"sourceText": "...", "translatedText": "...", "notes": "..."}, ...]
            Do not include any text outside the JSON array.
            """
        case .euphemisms:
            return """
            You are a native-language expert specialising in colloquial double-meaning speech. \
            Generate exactly 30 flashcard pairs for TARGET LANGUAGE expressions that have a \
            secondary — cheeky, humorous, or suggestive — meaning beneath their innocent surface.

            WHAT WE WANT (the fun kind):
            Phrases where the literal words sound innocent or mundane, but native speakers \
            use them with a wink — to talk about sex, getting drunk, desire, physical \
            attraction, or bold behaviour while technically saying something harmless. \
            Think expressions like "warm up the engines" or "put on your boots" — things \
            that would make a native speaker grin when a learner uses them correctly. \
            The Spanish deck includes: echar un polvo, calentar los motores, ponerse las botas, \
            irse de juerga, ponerse hasta las chanclas, tener mucha cara. Match this energy.

            WHAT WE DO NOT WANT (the boring kind):
            Do NOT generate polite-softening language like "passed away" for died, \
            "let go" for fired, "between jobs", or "big-boned" for overweight. \
            These are bland, unteachable, and ruin the deck. Every single card must \
            have a payoff — the learner should feel clever and a little naughty for knowing it.

            CRITICAL RULES:
            1. AUTHENTICITY: Every expression must come FROM TARGET LANGUAGE culture — \
               do NOT translate English expressions. Find what native speakers of \
               TARGET LANGUAGE actually say.
            2. CURRENCY: Must be in active use right now. A native speaker must immediately \
               grin in recognition — not look confused.
            3. RANGE: Cover a variety of cheeky topics — sexual innuendo, drinking, \
               desire, flirting, boldness, physical attraction, getting lucky. \
               Don't cluster more than 4 cards in any one theme.
            4. MIX: ~60% very familiar to any speaker, ~40% a step up — still common, \
               but the kind a learner would feel proud to know.
            5. NOTES: For each card, explain the literal meaning, the real meaning, \
               and mark the register: casual, adult-only, saloon-appropriate, etc.

            Each card:
            - sourceText: A plain English description of the REAL underlying meaning
            - translatedText: The authentic TARGET LANGUAGE expression (the cheeky one)
            - notes: Literal meaning + real meaning + register note

            Return ONLY valid JSON as an array:
            [{"sourceText": "...", "translatedText": "...", "notes": "..."}, ...]
            Do not include any text outside the JSON array.
            """
        case .datingAndRomance:
            return """
            You are a bilingual language and romance expert. Generate exactly 30 flashcard pairs \
            for authentic dating and romance phrases used in everyday conversation TODAY.

            CRITICAL RULES:
            1. AUTHENTICITY: These must be phrases that people in TARGET LANGUAGE speaking \
               cultures actually say when flirting, dating, or in relationships — right now. \
               Do NOT translate English romantic phrases. Find what real people say natively.
            2. CURRENCY: No cheesy textbook phrases. A native speaker must immediately \
               recognise these as real things people say. If it sounds like a translated \
               movie subtitle, reject it.
            3. FULL ARC: Cover the complete romantic journey — first meeting & openers, \
               compliments, asking someone out, expressing feelings, relationship stages, \
               terms of endearment, and making up after a fight.
            4. MIX OF TONE: ~40% sweet and genuine, ~35% playful and flirty, ~25% bold \
               and confident. Include grammatical gender variants in the notes where relevant.
            5. MIX OF DIFFICULTY: ~60% phrases any learner would need immediately, ~40% \
               the more expressive or culturally nuanced phrases that would genuinely \
               impress or resonate with a native speaker.

            Each card:
            - sourceText: The English phrase or a natural English description of the meaning
            - translatedText: The authentic TARGET LANGUAGE expression
            - notes: Usage context + any gender variants + tone note (sweet/flirty/bold)

            Return ONLY valid JSON as an array:
            [{"sourceText": "...", "translatedText": "...", "notes": "..."}, ...]
            Do not include any text outside the JSON array.
            """
        }
    }

    func userPrompt(forLanguage language: String) -> String {
        switch self {
        case .timelessAdages:
            return """
            Generate 30 proverbs and timeless adages for TARGET LANGUAGE speakers. \
            These must be expressions native \(language) speakers actually use today — \
            not just translations of English proverbs. Cover a wide range of life themes.
            """.replacingOccurrences(of: "TARGET LANGUAGE", with: language)
        case .euphemisms:
            return """
            Generate 30 cheeky double-meaning expressions used by \(language) speakers today. \
            These must sound innocent on the surface but carry a playful, suggestive, or humorous \
            second meaning — the kind that makes a native speaker grin. \
            Do NOT generate polite euphemisms like "passed away" or "let go" — those are boring. \
            Focus on expressions about sex, drinking, desire, attraction, and bold behaviour. \
            All expressions must come from \(language) culture, not translated from English.
            """
        case .datingAndRomance:
            return """
            Generate 30 authentic dating and romance phrases used by \(language) speakers today. \
            Cover the full romantic arc and include tone and gender notes where relevant.
            """
        }
    }
}
