//
//  PracticeConversationService.swift
//  TranslateHelper
//
//  Handles the live practice session conversation loop:
//  1. Records user audio → transcribes via WhisperKit or API
//  2. Sends conversation history to GPT-4o-mini for Sol's response
//  3. Returns Sol's response text for TTS playback

import Foundation
import AVFoundation

class PracticeConversationService {

    static let shared = PracticeConversationService()

    /// Reads coaching preference sliders from UserDefaults and builds a prompt block.
    static func coachingPrefsBlock() -> String {
        let slang = UserDefaults.standard.double(forKey: "coaching_slang_level")
        let grammar = UserDefaults.standard.double(forKey: "coaching_grammar_level")
        let pronunciation = UserDefaults.standard.double(forKey: "coaching_pronunciation_level")

        // Default to 50% if never set
        let s = slang == 0 ? 0.5 : slang
        let g = grammar == 0 ? 0.5 : grammar
        let p = pronunciation == 0 ? 0.5 : pronunciation

        func intensity(_ val: Double) -> String {
            if val >= 0.8 { return "HIGH — focus heavily on this" }
            if val >= 0.5 { return "MODERATE — include naturally" }
            if val >= 0.2 { return "LOW — only mention occasionally" }
            return "MINIMAL — rarely mention this"
        }

        return """
        Slang & expressions: \(intensity(s)) (\(Int(s * 100))%) — \(s >= 0.5 ? "Use slang every 2-3 exchanges" : "Use slang sparingly, only when very natural")
        Grammar corrections: \(intensity(g)) (\(Int(g * 100))%) — \(g >= 0.5 ? "Point out grammar mistakes and patterns" : "Only correct significant errors")
        Pronunciation tips: \(intensity(p)) (\(Int(p * 100))%) — \(p >= 0.5 ? "Note pronunciation in slang_notes when relevant" : "Only flag pronunciation for critical misunderstandings")
        """
    }
    /// Build level context for Sol's system prompt based on self-reported + assessed level.
    static func solLevelContext() -> String {
        let store = UserLevelStore.shared
        if store.hasBeenAssessed {
            let level = store.overallLevel.rawValue
            return "\(level) (\(store.overallLevel.title)) — \(store.overallLevel.description)"
        } else if let selfReport = SelfReportedLevel.saved {
            return "\(selfReport.initialCEFR.rawValue) (self-reported as '\(selfReport.label)')"
        } else {
            return "Unknown — start at B1 and adjust based on their responses"
        }
    }

    /// Tier-specific behavior instructions based on the user's level.
    static func levelBehaviorBlock() -> String {
        let levelStr = solLevelContext()
        let cefr: String = {
            let store = UserLevelStore.shared
            if store.hasBeenAssessed { return store.overallLevel.rawValue }
            if let sr = SelfReportedLevel.saved { return sr.initialCEFR.rawValue }
            return "B1"
        }()

        switch cefr {
        case "A1", "A2":
            return """
            USER'S LEVEL: \(levelStr) — BEGINNER \
            CRITICAL — BEGINNER MODE: \
            - Be bilingual: say something short in the target language, then give the English \
              right after in parentheses so they can follow along. \
            - Use VERY short sentences — 4-6 words max per sentence in the target language. \
            - Offer role-play scenarios: ordering food, asking for directions, introductions, \
              shopping, getting a taxi. Ask "Want to practice ordering coffee?" type openers. \
            - Teach vocabulary in natural context — greetings, numbers, food, transport, common verbs. \
            - Check in: "Did you get that?" or "Want me to explain?" every 2-3 exchanges. \
            - When they make a mistake, gently show the correct version inline — don't just \
              put it in the JSON. They need to see corrections in real time. \
            - Celebrate small wins: "Nice, you nailed that conjugation!" \
            - If they seem stuck, offer two choices: "You could say A or B — which feels right?" \
            - Slang: minimal. Stick to essential everyday expressions, not street slang. \
            - Your energy: patient, encouraging, like a friend helping them survive their first week.
            """

        case "B1", "B2":
            return """
            USER'S LEVEL: \(levelStr) — INTERMEDIATE \
            - Speak fully in the target language — no English in your messages. \
            - Use natural everyday language with some local color and slang mixed in. \
            - Corrections go in the JSON only — don't interrupt the flow. \
            - Push them slightly: use expressions just above their comfort zone. \
            - If they respond in English, acknowledge it and respond in the target language — \
              don't switch to English yourself. \
            - Match B1 with simpler structures, B2 with more complex ones (subjunctive, \
              conditional, idiomatic expressions). \
            - Your energy: a friend who happens to speak the language perfectly.
            """

        case "C1", "C2":
            return """
            USER'S LEVEL: \(levelStr) — ADVANCED \
            - Speak like you're talking to a native — full speed, full complexity. \
            - Use subjunctive, literary expressions, wordplay, cultural references, humor. \
            - Corrections should focus on NUANCE, not basics: "That's grammatically correct \
              but a native would phrase it differently because..." \
            - Challenge them: throw in double meanings, regional differences, formal vs informal \
              register switches. \
            - Teach the difference between "correct" and "natural" — they probably know the \
              grammar but sound textbook-ish. Your job is to make them sound local. \
            - Don't hold back on slang density — they can handle it. \
            - Your energy: a sharp, witty local friend who doesn't dumb anything down.
            """

        default:
            return """
            USER'S LEVEL: \(levelStr). \
            Adapt your vocabulary, sentence complexity, and slang difficulty to this level. \
            Don't speak above or below them — match their ability.
            """
        }
    }

    private init() {}

    private var audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?

    private var tempAudioURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("practice_recording.wav")
    }

    // MARK: - Recording

    func startRecording() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            NSLog("🎤 [Practice] audio session error: \(error)")
            return
        }

        let engine = AVAudioEngine()
        let node = engine.inputNode
        let hwFmt = node.outputFormat(forBus: 0)
        guard hwFmt.sampleRate > 0, hwFmt.channelCount > 0 else {
            NSLog("🎤 [Practice] audio format invalid: sampleRate=\(hwFmt.sampleRate), channels=\(hwFmt.channelCount)")
            return
        }

        try? FileManager.default.removeItem(at: tempAudioURL)

        do {
            audioFile = try AVAudioFile(forWriting: tempAudioURL, settings: hwFmt.settings)
        } catch {
            NSLog("🎤 [Practice] could not create audio file: \(error)")
            return
        }

        node.installTap(onBus: 0, bufferSize: 4096, format: nil) { [weak self] buffer, _ in
            guard let self = self, let file = self.audioFile else { return }
            do { try file.write(from: buffer) } catch {}
        }

        engine.prepare()
        do { try engine.start() } catch { return }

        audioEngine = engine
        NSLog("🎤 [Practice] recording started")
    }

    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
        }
        audioFile = nil
        // Switch to playback mode so TTS can play Sol's response
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        NSLog("🎤 [Practice] recording stopped, switched to playback mode")
    }

    // MARK: - Transcribe

    func transcribe(language: String, completion: @escaping (String?) -> Void) {
        let fileURL = tempAudioURL
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            completion(nil)
            return
        }

        // Use Whisper API with forced language
        let apiKey = APIConfig.openAIAPIKey
        guard let url = URL(string: "\(APIConfig.openAIBaseURL)/audio/transcriptions") else {
            completion(nil)
            return
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"recording.wav\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        if let audioData = try? Data(contentsOf: fileURL) {
            body.append(audioData)
        }
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"language\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(language)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"response_format\"\r\n\r\n".data(using: .utf8)!)
        body.append("json\r\n".data(using: .utf8)!)

        // Hint Whisper with city/location names so it recognizes them
        let locations = UserLocationsStore.shared.locations.map(\.displayName)
        let langName = LanguageManager.shared.targetLangName ?? ""
        let whisperHint = (locations + [langName]).joined(separator: ", ")
        if !whisperHint.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"prompt\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(whisperHint)\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, _, error in
            try? FileManager.default.removeItem(at: fileURL)

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let text = json["text"] as? String else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            DispatchQueue.main.async {
                completion(text.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }.resume()
    }

    // MARK: - Get Sol's Response

    struct SlangNote {
        let phrase: String
        let meaning: String
        let context: String
    }

    struct MistakeLog {
        let userFragment: String    // "eu sou 25 anos"
        let correctFragment: String // "eu tenho 25 anos"
        let rule: String            // "Portuguese uses 'ter' for age: tenho 25, tenho fome"
    }

    struct SolResponse {
        let text: String
        let translation: String?
        let translationNotes: String?
        let nativeCorrectionForUser: String?
        let nativeCorrectionNotes: String?
        let slangNotes: [SlangNote]
        let mistakeLog: MistakeLog?
    }

    func getSolResponse(
        conversationHistory: [(role: String, text: String)],
        userCity: String = "their city",
        targetLanguage: String = "pt",
        tone: String = "casual",
        completion: @escaping (SolResponse?) -> Void
    ) {
        let apiKey = APIConfig.openAIAPIKey
        guard let url = URL(string: "\(APIConfig.openAIBaseURL)/chat/completions") else {
            completion(nil)
            return
        }

        let langName = LanguageManager.languageName(for: targetLanguage)

        let transferBlock = TransferPatterns.patterns(for: targetLanguage)

        let toneBlock: String = {
            switch tone {
            case "slang":
                return """
                TONE — STREET SLANG: \
                You speak like someone who grew up on the streets of \(userCity). \
                Heavy slang, abbreviations, contractions that only locals would know. \
                Throw in expressions that would confuse a textbook learner. \
                You're at a house party, not a classroom.
                """
            case "flirty":
                return """
                TONE — FLIRTY: \
                You're playful, teasing, and a little bold. Think first date at a bar. \
                Use romantic and flirty expressions natural to \(userCity). \
                Compliment them, be cheeky, use double meanings when the language allows it. \
                Keep it fun and charming — this is how real people flirt in \(langName). \
                If they escalate, match their energy within what feels natural.
                """
            case "work":
                return """
                TONE — PROFESSIONAL: \
                You're a colleague at a business meeting or a job interview. \
                Use formal register — proper conjugations, polite forms (usted/você, etc). \
                Topics: presentations, emails, negotiations, office small talk, networking. \
                Still warm and natural — not stiff, but clearly professional. \
                Teach them the difference between casual and formal register.
                """
            default: // casual
                return """
                TONE — CASUAL: \
                You're a friend hanging out — relaxed, warm, natural. \
                Mix of everyday language with some local color. \
                Topics can be anything: food, weekend plans, dating, music, life.
                """
            }
        }()

        // Discovery phase — Sol actively learns about the user in early conversations
        let factCount = SolMemoryStore.shared.facts.count
        let discoveryBlock: String = factCount < 5 ? """

        DISCOVERY PHASE — You don't know much about this person yet. \
        Your priority right now is to understand who they are — not by \
        interrogating them, but by being genuinely curious through natural \
        conversation. Try to learn: what brought them here, what they do, \
        how they're finding it, what their daily life looks like, and what \
        they need. Save everything they share in user_facts. Once you know \
        them well, this phase ends and you shift to being a knowledgeable \
        friend who references what you know about them.
        """ : ""

        let memoryBlock = SolMemoryStore.shared.buildContextBlock()
        let callbackHint = SolMemoryStore.shared.buildCallbackSuggestion() ?? ""
        let poolBlock = ConversationPoolManager.shared.buildPoolContextBlock()
        let enrichmentBlock: String = {
            if let enrichment = ConversationPoolManager.shared.consumeEnrichment() {
                return """

                LIVE KNOWLEDGE — Fresh background info on what the user just asked about:
                \(enrichment)

                Use this naturally in your NEXT response — weave in 1-2 of these facts to \
                show depth. Don't dump everything at once. Don't say "I looked it up" — \
                just know it, like a knowledgeable friend would.
                """
            }
            return ""
        }()

        let systemPrompt = """
        You are Sol, a warm and fun language coach having a conversation \
        in \(langName) with an English speaker who lives in \(userCity). \
        \
        \(toneBlock) \
        \(discoveryBlock) \
        \(memoryBlock) \
        \(callbackHint) \
        \(poolBlock) \
        \(enrichmentBlock) \
        \
        CRITICAL — HOW YOU SPEAK: \
        - Speak like a REAL person from \(userCity) — use actual slang, contractions, \
          and colloquial expressions that people use on the street. \
        - NEVER speak like a textbook. Nobody in \(userCity) talks like a textbook. \
        - Use expressions that the user won't find in language courses — figures of speech, \
          local idioms, casual contractions. This is the whole point. \
        - Keep responses short and natural (2-3 sentences) \
        - Match the tone described above — your personality shifts based on the setting \
        - CODE-SWITCHING: If the user switches to English mid-conversation — like "how do you \
          say [English word]?" or "what's the word for [English]?" — recognize it and help. \
          Teach them the \(langName) expression naturally: use it in a sentence, explain the \
          nuance. Then continue the conversation in \(langName). Don't ignore English insertions \
          — they're asking for help. Even if the transcription mangled the English, try to \
          figure out what they meant from context. \
        \
        VARIETY — CRITICAL (read this carefully): \
        - NEVER start two messages in a row the same way. If you just said "E aí", do NOT \
          start the next message with "E aí". Vary your openers EVERY time. \
        - Draw from MANY different openers: questions, reactions, observations, exclamations, \
          statements, jokes, callbacks to what they said. Rotate constantly. \
        - NEVER repeat the same topic across consecutive messages. If you just talked about \
          bars, do NOT bring up bars again. Switch to something completely different. \
        - Think of yourself as having a short attention span — you bounce between topics \
          naturally, like a real friend would in a casual conversation. \
        - If the user keeps the same topic going, that's fine — follow their lead. But when \
          YOU initiate, always go somewhere new. \
        \
        CONVERSATION RULES: \
        - If they make a grammar or vocabulary mistake, don't correct them inline — \
          just continue naturally. Corrections come in the JSON. \
        - The user is in \(userCity). If it's a city, reference neighborhoods and local spots naturally. \
          If it's a country, use country-wide slang and cultural references — don't assume a specific city. \
        - LOCATION ACCURACY: When YOU bring up places, only reference places actually in \(userCity). \
          Don't mix up landmarks between cities — that destroys trust. \
          BUT if the USER asks about another city, follow their lead — talk about it naturally, \
          compare it to \(userCity), share what you know. Expats love comparing cities. \
          Just be honest if you're not sure about a specific place. \
        - SLANG SCOPE: Use slang from \(userCity) and its region + nationwide slang that everyone understands. \
          Do NOT teach slang that's specific to OTHER cities or regions — if someone in \(userCity) \
          wouldn't naturally use or understand it, don't teach it. \
          Nationwide expressions are great. City-specific expressions from \(userCity) are great. \
          City-specific expressions from other cities are NOT — they'll confuse the user. \
        - BE GENUINELY CURIOUS — don't just respond, dig in. When they say something, \
          ask the unexpected follow-up a real friend would ask. Not "that's cool" but \
          "wait, is that different from how it works back home?" or "do you go alone or \
          is it a social thing?" Go sideways, not just forward. Compare their experience \
          to local culture. Ask what surprised them. Challenge them to think. \
          EVERY response should end with something that pulls them back in — a question, \
          a playful challenge, a "what about you?" that makes them WANT to respond. \
          Dead-end responses kill conversations. You are never the one who lets it die. \
        - PERSONAL BOUNDARIES: If the user mentions a partner, family, health, or finances, \
          acknowledge it warmly but steer toward the city/experience — don't probe. \
          "Moved here for my girlfriend" → "Nice, that's a great reason — how are you liking it?" \
          NOT "How long have you been together?" Follow their lead only if THEY keep going. \
        \(Self.levelBehaviorBlock()) \
        - The conversation has no fixed length — keep going as long as it's natural. \
          When a topic wraps up naturally, suggest a new direction or wind down. \
        \
        COACHING INTENSITY (user's preferences from Settings — respect these): \
        \(Self.coachingPrefsBlock()) \
        \
        SLANG TEACHING — PROACTIVE: \
        - Naturally weave in local slang and expressions from \(userCity) into your messages. \
        - When you use slang, ALWAYS include it in the slang_notes array so the user can learn and save it. \
        - Prioritize slang specific to \(userCity) or the region — not generic textbook expressions. \
        - Examples of what to teach: greetings locals actually use, street-level expressions, \
          food/drink ordering shortcuts, compliments people really say, common reactions, \
          expressions for agreeing/disagreeing, and words that change meaning by city/region. \
        - Frame it naturally in conversation — don't say "here's a slang word." Just USE it, \
          and let the slang_notes explain it. \
        \
        \(transferBlock) \
        \
        NOTES LANGUAGE RULE: \
        All notes fields (translation_notes, native_correction_notes, slang meaning/context) \
        MUST be written in \(LanguageManager.languageName(for: LanguageManager.shared.nativeLang)). \
        When referencing \(langName) words or phrases inline, \
        keep them in \(langName) — e.g. "Use 'cara' instead of 'pessoa' — it sounds more casual." \
        The user reads \(LanguageManager.languageName(for: LanguageManager.shared.nativeLang)). \
        The \(langName) words teach them vocabulary in context. \
        \
        Respond ONLY with valid JSON: \
        { \
          "response": "your response in \(langName) — speak like a real local", \
          "translation": "English translation of your response", \
          "translation_notes": "1 brief English note about a word/phrase you used (optional, null if none)", \
          "native_correction": "REQUIRED. Take the text the USER just said (the last 'user' role message in the conversation) and rewrite it as a native from \(userCity) would say it. FIX their grammar, use local phrasing, add natural contractions. This must be a rewrite of THEIR words — NOT your reply to them. Your reply goes in 'response' above. This field is THEIR message, improved. Never null.", \
          "native_correction_notes": "REQUIRED — IN ENGLISH: explain how a local would say it differently and why. Frame it as 'Locals say X' or 'On the street you'd hear X' — not 'You made a mistake'. 1-2 sentences with \(langName) words inline. Must ALWAYS be a string, never null.", \
          "mistake_log": {"user_fragment": "The EXACT wrong part only — 1-5 words max. No full sentences. No arrows. No 'null'. e.g. 'a prédio' or 'eu sou 25'. If you can't isolate a short fragment, set mistake_log to null.", "correct_fragment": "The corrected version — same length as user_fragment. 1-5 words. e.g. 'o prédio' or 'eu tenho 25'. NEVER put 'null' as the value.", "rule": "One sentence in \(LanguageManager.languageName(for: LanguageManager.shared.nativeLang)): the grammar pattern + 2-3 examples. Max 100 chars. e.g. 'Words ending in -agem are feminine: viagem, garagem, paisagem.'"} or null if no real mistake (naturalness tweaks don't count), \
          "slang_notes": [{"phrase": "the \(langName) slang/expression", "meaning": "English meaning", \
            "context": "English explanation of when/where people use this — be specific to the city/region"}] or [] if none, \
          "user_facts": ["any personal facts the user revealed in their last message — e.g. 'Looking for an apartment in Condesa', 'Works as a designer', 'Has a date on Friday'. Only include NEW information, not things you already know. Empty array if none."] or [], \
          "interest_refinements": [{"interest": "category like wellness/food/outdoors", "likes": ["specific things they expressed liking"], "dislikes": ["specific things they rejected or showed disinterest in"]}] or [] \
        }
        """

        var gptMessages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]

        for msg in conversationHistory {
            gptMessages.append(["role": msg.role, "content": msg.text])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": gptMessages,
            "temperature": 0.8,
            "max_tokens": 800,
            "response_format": ["type": "json_object"]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        // Helper to execute the request with auto-retry on parse failure
        func executeRequest(retryCount: Int = 0) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                if retryCount < 1 {
                    NSLog("🎤 [Practice] request failed — retrying (attempt \(retryCount + 2))")
                    executeRequest(retryCount: retryCount + 1)
                    return
                }
                DispatchQueue.main.async { completion(nil) }
                return
            }

            // Parse Sol's JSON response
            // GPT may return "response" (conversation) or "message" (topic generation) — accept both
            guard let responseData = content.data(using: .utf8),
                  let parsed = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                  let responseText = (parsed["response"] as? String) ?? (parsed["message"] as? String) else {
                if retryCount < 1 {
                    NSLog("🎤 [Practice] parse failed — retrying (attempt \(retryCount + 2)): \(content.prefix(200))")
                    executeRequest(retryCount: retryCount + 1)
                    return
                }
                NSLog("🎤 [Practice] failed to parse Sol response after retry: \(content.prefix(200))")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            // Parse slang notes
            var slangNotes: [SlangNote] = []
            if let rawNotes = parsed["slang_notes"] as? [[String: String]] {
                for note in rawNotes {
                    if let phrase = note["phrase"], let meaning = note["meaning"] {
                        slangNotes.append(SlangNote(
                            phrase: phrase,
                            meaning: meaning,
                            context: note["context"] ?? ""
                        ))
                    }
                }
            }

            // Extract and save user facts for Sol's cross-session memory
            if let userFacts = parsed["user_facts"] as? [String] {
                var hasHighSignal = false
                for fact in userFacts where !fact.isEmpty {
                    SolMemoryStore.shared.remember(fact, category: "personal")

                    // Detect high-signal facts — career, major life events, deep passions
                    let lower = fact.lowercased()
                    let highSignalKeywords = [
                        "chef", "career", "job", "work as", "profession", "studying",
                        "moving to", "leaving", "getting married", "pregnant", "baby",
                        "starting a", "opening a", "business", "company", "freelance",
                        "passion", "dream", "goal", "plan to", "training",
                        "divorce", "breakup", "relationship", "dating",
                        "visa", "residency", "citizenship", "permanent",
                    ]
                    if highSignalKeywords.contains(where: { lower.contains($0) }) {
                        hasHighSignal = true
                    }
                }

                // High-signal fact detected — fire immediate Gemini enrichment
                if hasHighSignal {
                    let city = UserLocationsStore.shared.locations.first?.displayName ?? userCity
                    let factsSummary = userFacts.joined(separator: ". ")
                    DispatchQueue.global(qos: .utility).async {
                        ConversationPoolManager.shared.enrichFromConversation(
                            city: city,
                            recentMessages: [
                                (role: "system", text: "HIGH-SIGNAL: The user just revealed important personal information: \(factsSummary). Generate deep, specific knowledge related to this in \(city).")
                            ]
                        )
                        NSLog("🌐 [Enrichment] HIGH-SIGNAL trigger: \(factsSummary.prefix(80))")
                    }
                }
            }

            // Extract interest refinements (likes/dislikes inferred from conversation)
            if let refines = parsed["interest_refinements"] as? [[String: Any]] {
                for r in refines {
                    if let interest = r["interest"] as? String {
                        let likes = r["likes"] as? [String] ?? []
                        let dislikes = r["dislikes"] as? [String] ?? []
                        if !likes.isEmpty || !dislikes.isEmpty {
                            ConversationPoolManager.shared.addRefinement(
                                interest: interest, likes: likes, dislikes: dislikes
                            )
                        }
                    }
                }
            }

            // Parse structured mistake log (for clean target area display)
            var mistakeLog: MistakeLog? = nil
            if let logDict = parsed["mistake_log"] as? [String: Any],
               let userFrag = logDict["user_fragment"] as? String,
               let correctFrag = logDict["correct_fragment"] as? String,
               let rule = logDict["rule"] as? String,
               !userFrag.isEmpty, !correctFrag.isEmpty {
                mistakeLog = MistakeLog(userFragment: userFrag, correctFragment: correctFrag, rule: rule)
            }

            // DEBUG: Log exactly what Sol returned for correction fields
            let rawCorrection = parsed["native_correction"]
            let rawNotes = parsed["native_correction_notes"]
            NSLog("🔬 [Sol Debug] native_correction type=\(type(of: rawCorrection)), value=\(String(describing: rawCorrection).prefix(150))")
            NSLog("🔬 [Sol Debug] native_correction_notes type=\(type(of: rawNotes)), value=\(String(describing: rawNotes).prefix(150))")
            NSLog("🔬 [Sol Debug] mistake_log: \(mistakeLog != nil ? "\(mistakeLog!.userFragment) → \(mistakeLog!.correctFragment)" : "nil")")

            var nativeCorrection = parsed["native_correction"] as? String
            var nativeCorrectionNotes = parsed["native_correction_notes"] as? String

            // Reject if Sol put its own response in native_correction (common GPT mistake)
            // Check: exact match, starts-with match (first 40 chars), or high overlap
            if let correction = nativeCorrection {
                let corrTrimmed = correction.trimmingCharacters(in: .whitespacesAndNewlines)
                let respTrimmed = responseText.trimmingCharacters(in: .whitespacesAndNewlines)
                let corrStart = String(corrTrimmed.prefix(40))
                let respStart = String(respTrimmed.prefix(40))

                if corrTrimmed == respTrimmed || corrStart == respStart {
                    NSLog("🔬 [Correction] REJECTED — Sol put its own response in native_correction")
                    nativeCorrection = nil
                    nativeCorrectionNotes = nil
                }
            }

            if nativeCorrection == nil {
                NSLog("🔬 [Correction] Sol returned null or rejected — GPT non-compliance")
            }

            let result = SolResponse(
                text: responseText,
                translation: parsed["translation"] as? String,
                translationNotes: parsed["translation_notes"] as? String,
                nativeCorrectionForUser: nativeCorrection,
                nativeCorrectionNotes: nativeCorrectionNotes,
                slangNotes: slangNotes,
                mistakeLog: mistakeLog
            )

            DispatchQueue.main.async { completion(result) }
        }.resume()
        }  // end executeRequest

        executeRequest()
    }

    // MARK: - Dedicated Local Phrasing Call (separate from conversation)

    /// Rewrites the user's message as a local would say it.
    /// Fires independently from Sol's conversation response — same approach as keyboard.
    func getLocalPhrasing(
        userText: String,
        city: String,
        language: String,
        completion: @escaping (String?, String?) -> Void  // (localVersion, notes)
    ) {
        let apiKey = APIConfig.openAIAPIKey
        guard let url = URL(string: "\(APIConfig.openAIBaseURL)/chat/completions") else {
            completion(nil, nil)
            return
        }

        let langName = LanguageManager.languageName(for: language)

        let prompt = """
        Take this message from a language learner and rewrite it as a native speaker from \(city) would say it.
        Use local phrasing, contractions, slang where natural. Fix any grammar errors.

        User said: "\(userText)"

        Respond in JSON only:
        {
          "local": "the full message rewritten as a local from \(city) would say it",
          "notes": "IN ENGLISH: 1-2 sentences explaining what you changed — frame it as 'Locals say X' or 'On the street you'd hear X', with \(langName) words inline"
        }
        """

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 400,
            "response_format": ["type": "json_object"]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String,
                  let responseData = content.data(using: .utf8),
                  let parsed = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                  let local = parsed["local"] as? String else {
                NSLog("🔬 [LocalPhrasing] failed to get local version")
                completion(nil, nil)
                return
            }

            let notes = parsed["notes"] as? String
            NSLog("🔬 [LocalPhrasing] success: \(local.prefix(60))")
            completion(local, notes)
        }.resume()
    }
}
