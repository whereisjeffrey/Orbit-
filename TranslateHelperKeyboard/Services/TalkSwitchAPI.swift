//
//  TalkSwitchAPI.swift
//  TranslateHelperKeyboard
//
//  Created by TalkSwitch on 15/02/26.
//

import Foundation

// Mirrors UserLearningLocation from the main app target.
// Defined here so the keyboard extension can decode it from shared UserDefaults
// without needing to import the main app's module.
private struct UserLearningLocation: Codable {
    var id: UUID
    var displayName: String
    var city: String
    var country: String
}

class TalkSwitchAPI {
    
    static let shared = TalkSwitchAPI()
    private init() {}
    
    struct RefinedTranslation {
        let output: String
        let notes: String?
        /// Geographic/cultural scope label for this translation, e.g.
        /// "Used in Buenos Aires", "Common across Latin America",
        /// "Understood in Spain & Latin America". Only present for
        /// slang/flirty/casual tones when location context is available.
        let localityTag: String?
    }
    
    struct CoachingResult {
        let corrected: String
        let nativeVersion: String
        let mistakes: [String]
        let tips: [String]
        let rawNotes: String
    }
    
    /// Refines a DeepL translation using OpenAI for tone/cultural adaptation
    /// Only used for Slang and Flirty tones — Casual/Work use DeepL directly
    func refineTranslation(
        original: String,
        deeplTranslation: String,
        sourceLang: String,
        targetLang: String,
        tone: Tone,
        completion: @escaping (Result<RefinedTranslation, Error>) -> Void
    ) {
        let apiKey = APIConfig.openAIAPIKey
        guard apiKey != "YOUR_OPENAI_KEY_HERE" else {
            completion(.failure(NSError(domain: "TalkSwitchAPI", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "OpenAI API key not configured"])))
            return
        }
        
        guard let url = URL(string: "\(APIConfig.openAIBaseURL)/chat/completions") else {
            completion(.failure(NSError(domain: "TalkSwitchAPI", code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let systemPrompt = buildSystemPrompt(sourceLang: sourceLang, targetLang: targetLang, tone: tone)
        let userPrompt = buildUserPrompt(original: original, deeplTranslation: deeplTranslation, tone: tone)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": tone == .flirty ? 0.9 : 0.7,
            "max_tokens": 500
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "TalkSwitchAPI", code: -3,
                    userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    completion(.failure(NSError(domain: "TalkSwitchAPI", code: -4,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])))
                    return
                }
                
                // Check for API errors
                if let error = json["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    completion(.failure(NSError(domain: "TalkSwitchAPI", code: -5,
                        userInfo: [NSLocalizedDescriptionKey: "OpenAI: \(message)"])))
                    return
                }
                
                guard let choices = json["choices"] as? [[String: Any]],
                      let first = choices.first,
                      let message = first["message"] as? [String: Any],
                      let content = message["content"] as? String else {
                    completion(.failure(NSError(domain: "TalkSwitchAPI", code: -4,
                        userInfo: [NSLocalizedDescriptionKey: "Could not parse response"])))
                    return
                }
                
                // Parse the response — expect JSON with "translation" and "notes"
                let result = self.parseResponse(content)
                completion(.success(result))
                
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - Coach Mode
    
    /// Analyzes spoken text in the target language and provides corrections/coaching
    func coachSpeech(
        spokenText: String,
        language: String,
        tone: Tone,
        completion: @escaping (Result<CoachingResult, Error>) -> Void
    ) {
        let apiKey = APIConfig.openAIAPIKey
        guard apiKey != "YOUR_OPENAI_KEY_HERE" else {
            completion(.failure(NSError(domain: "TalkSwitchAPI", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "OpenAI API key not configured"])))
            return
        }
        
        guard let url = URL(string: "\(APIConfig.openAIBaseURL)/chat/completions") else {
            completion(.failure(NSError(domain: "TalkSwitchAPI", code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let langName = language == "es" ? "Mexican Spanish" : "English"
        let toneDesc = tone.displayName.lowercased()
        
        let systemPrompt = """
        You are a friendly language coach for \(langName). A student just spoke/typed something in \(langName). \
        Analyze their attempt and provide helpful corrections. \
        \
        The student wants to sound \(toneDesc) in their speech. \
        \
        Respond ONLY with valid JSON in this exact format: \
        { \
          "corrected": "their text with grammar/spelling fixed but keeping their style", \
          "native": "how a native \(langName) speaker would naturally say it in a \(toneDesc) tone", \
          "mistakes": ["mistake 1 explanation", "mistake 2 explanation"], \
          "tips": ["cultural/usage tip 1", "tip 2"] \
        } \
        \
        Keep explanations short and friendly. If they did great, say so! \
        "mistakes" can be empty if there are none. Always provide at least one tip. \
        For Spanish, pay attention to: preposition contractions, ser vs estar, gender agreement, \
        verb conjugation, subjunctive mood, and informal (tú/vos) vs formal (usted) register.
        """
        
        let userPrompt = """
        Student said: "\(spokenText)"
        Desired tone: \(toneDesc)
        Please coach them.
        """
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.6,
            "max_tokens": 600
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "TalkSwitchAPI", code: -3,
                    userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    completion(.failure(NSError(domain: "TalkSwitchAPI", code: -4,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }
                
                if let error = json["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    completion(.failure(NSError(domain: "TalkSwitchAPI", code: -5,
                        userInfo: [NSLocalizedDescriptionKey: "OpenAI: \(message)"])))
                    return
                }
                
                guard let choices = json["choices"] as? [[String: Any]],
                      let first = choices.first,
                      let message = first["message"] as? [String: Any],
                      let content = message["content"] as? String else {
                    completion(.failure(NSError(domain: "TalkSwitchAPI", code: -4,
                        userInfo: [NSLocalizedDescriptionKey: "Could not parse response"])))
                    return
                }
                
                let result = self.parseCoachingResponse(content, original: spokenText)
                completion(.success(result))
                
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func parseCoachingResponse(_ content: String, original: String) -> CoachingResult {
        let cleaned = content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let data = cleaned.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            
            let corrected = json["corrected"] as? String ?? original
            let native = json["native"] as? String ?? corrected
            let mistakes = json["mistakes"] as? [String] ?? []
            let tips = json["tips"] as? [String] ?? []
            
            // Build readable notes
            var notes = ""
            if !mistakes.isEmpty {
                notes += "✏️ Corrections:\n"
                for m in mistakes { notes += "• \(m)\n" }
                notes += "\n"
            }
            notes += "🇲🇽 Native version:\n\"\(native)\"\n\n"
            if !tips.isEmpty {
                notes += "💡 Tips:\n"
                for t in tips { notes += "• \(t)\n" }
            }
            
            return CoachingResult(
                corrected: corrected,
                nativeVersion: native,
                mistakes: mistakes,
                tips: tips,
                rawNotes: notes
            )
        }
        
        // Fallback
        return CoachingResult(
            corrected: original,
            nativeVersion: content,
            mistakes: [],
            tips: [],
            rawNotes: content
        )
    }
    
    // MARK: - Smart Notes (Ambient Coaching)
    
    /// Generates contextual learning notes for any translation
    func getSmartNotes(
        original: String,
        translated: String,
        sourceLang: String,
        targetLang: String,
        tone: Tone,
        pronunciationContext: String? = nil,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let apiKey = APIConfig.openAIAPIKey
        guard apiKey != "YOUR_OPENAI_KEY_HERE" else {
            completion(.failure(NSError(domain: "TalkSwitchAPI", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "OpenAI not configured"])))
            return
        }
        
        guard let url = URL(string: "\(APIConfig.openAIBaseURL)/chat/completions") else {
            completion(.failure(NSError(domain: "TalkSwitchAPI", code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let sourceName = sourceLang == "es" ? "Mexican Spanish" : "English"
        let targetName = targetLang == "es" ? "Mexican Spanish" : "English"
        let toneDesc = tone.displayName.lowercased()
        
        // Different coaching based on direction
        let systemPrompt: String
        if sourceLang == "es" {
            // User wrote/spoke in Spanish → coach their Spanish
            systemPrompt = """
            You are a friendly Mexican Spanish coach. A student wrote something in Spanish. \
            Analyze their Spanish and provide helpful, concise coaching notes. \
            \
            Your notes should include: \
            1. If there are grammar mistakes, point them out briefly with corrections \
            2. How a native Mexican would more naturally say it (especially for \(toneDesc) tone) \
            3. One cultural/usage tip about a word or phrase they used \
            \
            Keep it SHORT — max 3-4 lines. Use emoji sparingly. Be encouraging. \
            If their Spanish is perfect, say so and teach them an alternative expression or slang. \
            Write in English (they're learning Spanish, they need to understand the notes). \
            Do NOT use JSON. Write plain text only.
            """
        } else {
            // User wrote in English → teach them the Spanish cultural context
            systemPrompt = """
            You are a bilingual cultural coach for \(sourceName) → \(targetName) translation. \
            A user just translated something. Provide brief, insightful notes about the translation. \
            \
            Your notes should include: \
            1. A more natural/\(toneDesc) alternative if the translation is too literal \
            2. Cultural context — how natives actually say this in Mexico or Latin America \
            3. One useful expression, idiom, or slang related to what they said \
            \
            Keep it SHORT — max 3-4 lines. Use emoji sparingly. \
            If there’s an idiom or expression that fits, teach it to them. \
            Write in English with Spanish examples in quotes. \
            Do NOT use JSON. Write plain text only.
            """
        }
        
        var userPrompt = "Original (\(sourceName)): \"\(original)\"\nTranslation (\(targetName)): \"\(translated)\"\nTone: \(toneDesc)"
        if let pronContext = pronunciationContext {
            userPrompt += "\n\n⚠️ \(pronContext)"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.7,
            "max_tokens": 250
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "TalkSwitchAPI", code: -3,
                    userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    completion(.failure(NSError(domain: "TalkSwitchAPI", code: -4,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }
                
                if let error = json["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    completion(.failure(NSError(domain: "TalkSwitchAPI", code: -5,
                        userInfo: [NSLocalizedDescriptionKey: "OpenAI: \(message)"])))
                    return
                }
                
                guard let choices = json["choices"] as? [[String: Any]],
                      let first = choices.first,
                      let message = first["message"] as? [String: Any],
                      let content = message["content"] as? String else {
                    completion(.failure(NSError(domain: "TalkSwitchAPI", code: -4,
                        userInfo: [NSLocalizedDescriptionKey: "Could not parse"])))
                    return
                }
                
                completion(.success(content.trimmingCharacters(in: .whitespacesAndNewlines)))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - Key Phrase Extraction
    
    struct KeyPhraseResult {
        let sourcePhrase: String
        let targetPhrase: String
        let notes: String
    }
    
    /// Extracts the most important idiom, slang, or phrase from a long sentence for flashcard memorization
    func extractKeyPhraseForSaving(
        original: String,
        translated: String,
        sourceLang: String,
        targetLang: String,
        tone: Tone,
        completion: @escaping (Result<KeyPhraseResult, Error>) -> Void
    ) {
        let apiKey = APIConfig.openAIAPIKey
        guard apiKey != "YOUR_OPENAI_KEY_HERE" else {
            completion(.failure(NSError(domain: "TalkSwitchAPI", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "OpenAI not configured"])))
            return
        }
        
        guard let url = URL(string: "\(APIConfig.openAIBaseURL)/chat/completions") else {
            completion(.failure(NSError(domain: "TalkSwitchAPI", code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let sourceName = sourceLang == "es" ? "Mexican Spanish" : "English"
        let targetName = targetLang == "es" ? "Mexican Spanish" : "English"
        
        let systemPrompt = """
        You are a bilingual language extraction assistant specializing in \(sourceName) and \(targetName).
        The user wants to save a translation into a flashcard/clipboard for memorization.
        Often, users translate full, long sentences that only contain a single idiom, slang, or key phrase they actually want to learn.
        Your job is to extract the MOST IMPORTANT key phrase, idiom, or slang from the translation that is worth memorizing, stripping away the unnecessary contextual words.
        If the sentence is short or there is no specific idiom, just use the original/translated text as is.
        
        Respond ONLY with valid JSON in this format:
        {
          "sourcePhrase": "The extracted key phrase in \(sourceName)",
          "targetPhrase": "The extracted key phrase in \(targetName)",
          "notes": "A brief, clear explanation of the phrase. e.g. 'let it slide' is a term to signify when people are too lenient."
        }
        Do NOT wrap in markdown blocks like ```json.
        """
        
        let userPrompt = "Original (\(sourceName)): \"\(original)\"\nTranslated (\(targetName)): \"\(translated)\"\nExtract the core idiom/phrase to save."
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.4,
            "max_tokens": 200
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "TalkSwitchAPI", code: -3,
                    userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let choices = json["choices"] as? [[String: Any]],
                      let message = choices.first?["message"] as? [String: Any],
                      let content = message["content"] as? String else {
                    completion(.failure(NSError(domain: "TalkSwitchAPI", code: -4,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }
                
                let cleaned = content
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard let contentData = cleaned.data(using: .utf8),
                      let parsedJSON = try JSONSerialization.jsonObject(with: contentData) as? [String: Any],
                      let sourceP = parsedJSON["sourcePhrase"] as? String,
                      let targetP = parsedJSON["targetPhrase"] as? String else {
                    completion(.failure(NSError(domain: "TalkSwitchAPI", code: -5,
                        userInfo: [NSLocalizedDescriptionKey: "Could not parse JSON fields"])))
                    return
                }
                
                let notes = parsedJSON["notes"] as? String ?? ""
                
                completion(.success(KeyPhraseResult(
                    sourcePhrase: sourceP,
                    targetPhrase: targetP,
                    notes: notes
                )))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - Prompt Building
    
    private func buildSystemPrompt(sourceLang: String, targetLang: String, tone: Tone) -> String {
        let langPair = sourceLang == "es"
            ? "Mexican Spanish to American English"
            : "American English to Mexican Spanish"

        // Fetch user persona if it exists
        var personaInstruction = ""
        if let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper"),
           let persona = defaults.string(forKey: "talkswitch_user_persona") {
            personaInstruction = "\n\nCRITICAL CONTEXT ABOUT THE USER:\n\(persona)\nUse this context to inform your word choice, structure, and tone naturally without explicitly mentioning it."
        }

        // Build location context for slang distribution
        let locationInstruction = buildLocationInstruction()

        switch tone {
        case .flirty:
            let genderInstruction = buildFlirtyGenderInstruction()
            return """
            You are a bilingual translation expert specializing in \(langPair). \
            Your job is to refine translations with a flirty, charming tone. \
            Make it sound like someone who's confident and smooth — not creepy or over-the-top. \
            Use natural flirty expressions that native speakers actually use. \
            Keep the core meaning intact but add warmth and playful energy. \
            \(genderInstruction)\
            \(personaInstruction)\
            \(locationInstruction)\
            \
            Respond ONLY with valid JSON: {"translation": "...", "notes": "...", "localityTag": "..."}
            The "notes" field should briefly explain what flirty expressions you used and why. \
            If the grammatical gender was adjusted, mention the alternate form in notes.
            The "localityTag" field should describe the geographic scope of the translation, e.g. \
            "Understood in Spain & Latin America", "Common across Latin America", \
            "Used in [Country]", or "Used in [City]" — be specific with city/country names. \
            If there is no location context, set "localityTag" to null.
            """
        case .casual, .work:
            return """
            You are a bilingual translation expert specializing in \(langPair). \
            Refine the translation to sound natural and conversational. \(personaInstruction)\
            \(locationInstruction)\
            \
            Respond ONLY with valid JSON: {"translation": "...", "notes": "...", "localityTag": "..."}
            The "localityTag" field should describe the geographic scope, e.g. \
            "Understood in Spain & Latin America", "Common across Latin America", \
            "Used in [Country]", or "Used in [City]". Set to null if no location context.
            """
        case .slang:
            return """
            You are a bilingual translation expert specializing in \(langPair) street slang and colloquial speech. \
            Your job is to refine translations using real slang, gírias, and informal expressions. \
            For Spanish: use real Mexican slang (güey/wey, órale, ¿qué onda?, chido, chingón, etc). \
            For English: use real American casual/street expressions. \
            Don't sanitize — keep it authentic. But don't add profanity that wasn't in the original. \(personaInstruction)\
            \(locationInstruction)\
            \
            Respond ONLY with valid JSON: {"translation": "...", "notes": "...", "localityTag": "..."}
            The "notes" field should explain the slang terms used so the user learns them.
            The "localityTag" field MUST describe the geographic scope of the slang, e.g. \
            "Understood in Spain & Latin America" (universal), \
            "Common across Latin America" (pan-regional), \
            "Used in [Country]" (country-specific), \
            "Used in [City]" (city-specific) — always use the exact city or country name. \
            If no location context is provided, use the most accurate general scope.
            """
        }
    }

    /// Builds a location instruction paragraph for injection into system prompts.
    /// Reads the user's saved learning locations from shared UserDefaults.
    private func buildLocationInstruction() -> String {
        guard let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper"),
              let data = defaults.data(forKey: "talkswitch_learning_locations"),
              let locations = try? JSONDecoder().decode([UserLearningLocation].self, from: data),
              !locations.isEmpty
        else { return "" }

        let primary = locations[0]
        let secondaries = locations.dropFirst()

        var instruction = """
        \
        \
        LOCATION CONTEXT FOR SLANG DISTRIBUTION:\
        The user is primarily learning in \(primary.displayName). \
        When choosing slang expressions, distribute them across these 4 tiers:\
        1. UNIVERSAL (🌐): ~40% — expressions understood in both Spain AND all Latin America.\
        2. PAN-REGIONAL (🌎): ~30% — expressions common across all Spanish-speaking countries.\
        3. COUNTRY-SPECIFIC (🇦🇷): ~20% — expressions specific to \(primary.country). Label these as "Used in \(primary.country)".\
        4. CITY-SPECIFIC (📍): ~10% max — expressions specific to \(primary.city). Label these as "Used in \(primary.city)".\
        IMPORTANT: Never give more than 30% city-specific slang. The user needs broad, transferable language skills — local flavor is a bonus, not the focus.
        """

        if !secondaries.isEmpty {
            let others = secondaries.map { $0.displayName }.joined(separator: ", ")
            instruction += " The user also spends time in: \(others). You may occasionally include slang from these regions too, but \(primary.displayName) remains the priority."
        }

        return instruction
    }

    /// Reads the user's flirty conversation preferences from shared UserDefaults
    /// and returns a grammatical gender instruction for injection into the flirty system prompt.
    /// Falls back gracefully if preferences haven't been set yet.
    private func buildFlirtyGenderInstruction() -> String {
        guard let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper"),
              defaults.bool(forKey: "ts_flirty_context_set")
        else {
            // Preferences not set yet — default to showing both variants in the notes
            return """
            GRAMMATICAL GENDER: Preferences not yet set. Use the most common form, \
            and if gender is ambiguous include both variants (e.g. 'enamorado/enamorada') \
            in the notes field so the user can pick the right one.
            """
        }

        let speakerForm   = defaults.string(forKey: "ts_speaker_form")  ?? "both"
        let targetGender  = defaults.string(forKey: "ts_target_gender") ?? "varies"

        let speakerLine: String
        switch speakerForm {
        case "masculine": speakerLine = "The SPEAKER uses masculine forms (e.g. 'enamorado', 'contento')."
        case "feminine":  speakerLine = "The SPEAKER uses feminine forms (e.g. 'enamorada', 'contenta')."
        default:          speakerLine = "Include both masculine/feminine speaker forms in the notes field."
        }

        let targetLine: String
        switch targetGender {
        case "male":   targetLine = "They are speaking TO a man — use masculine address (e.g. 'eres hermoso', 'mi rey')."
        case "female": targetLine = "They are speaking TO a woman — use feminine address (e.g. 'eres hermosa', 'mi reina')."
        default:       targetLine = "Target gender varies — prefer gender-neutral phrasing where possible."
        }

        return "GRAMMATICAL GENDER (critical — follow exactly): \(speakerLine) \(targetLine) "
    }
    
    private func buildUserPrompt(original: String, deeplTranslation: String, tone: Tone) -> String {
        return """
        Original text: "\(original)"
        Base translation (DeepL): "\(deeplTranslation)"
        
        Refine the base translation to match the \(tone.displayName.lowercased()) tone. \
        Keep the meaning accurate but make it sound natural for the target language with the right vibe.
        """
    }
    
    // MARK: - Response Parsing
    
    private func parseResponse(_ content: String) -> RefinedTranslation {
        // Try to parse as JSON first
        let cleaned = content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let data = cleaned.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let translation = json["translation"] as? String {
            let notes = json["notes"] as? String
            // localityTag may be a string or null
            let localityTag = json["localityTag"] as? String
            return RefinedTranslation(output: translation, notes: notes, localityTag: localityTag)
        }
        
        // Fallback: use the raw content as the translation
        return RefinedTranslation(output: content, notes: nil, localityTag: nil)
    }

    // MARK: - Alternative Translation (swipe for new version)
    func alternativeTranslation(
        original: String,
        currentTranslation: String,
        sourceLang: String,
        tone: Tone,
        variation: Int,
        completion: @escaping (Result<RefinedTranslation, Error>) -> Void
    ) {
        let langPair = sourceLang == "es"
            ? "Mexican Spanish to American English"
            : "American English to Mexican Spanish"

        let variationHints = [
            "Use completely different vocabulary and sentence structure.",
            "Try a more idiomatic, native-sounding phrasing.",
            "Make it shorter and punchier.",
            "Make it more expressive and vivid.",
            "Use a different cultural reference or expression."
        ]
        let hint = variationHints[(variation - 1) % variationHints.count]

        let toneSpecificInstruction: String
        switch tone {
        case .slang:
            toneSpecificInstruction = "CRITICAL: Provide a uniquely different SLANG expression. For example, if the previous was 'going to leave', try 'gonna roll', 'head out', 'bounce'. Give a substantive new option using real street/colloquial speech."
        case .flirty:
            toneSpecificInstruction = "CRITICAL: Provide a uniquely different FLIRTY or charming expression. Avoid basic synonyms; give a completely fresh, playful way to say this."
        case .work:
            toneSpecificInstruction = "CRITICAL: Provide a distinctly different PROFESSIONAL/BUSINESS phrasing. Focus on professional variety, offering a new structural framing for a business environment."
        case .casual:
            toneSpecificInstruction = "CRITICAL: Provide a distinctly different casual phrase, focusing on natural conversational variety."
        }

        let system = """
        You are a creative bilingual translator specializing in \(langPair).
        The user didn't like the previous translation and wants a fresh alternative.
        \(hint)
        \(toneSpecificInstruction)
        Do NOT repeat or closely paraphrase the previous translation.
        Respond ONLY with valid JSON: {"translation": "...", "notes": "..."}
        The "notes" field should briefly explain what makes this version different.
        """

        let user = """
        Original: "\(original)"
        Previous translation (do NOT repeat this): "\(currentTranslation)"
        Provide a meaningfully different \(tone.displayName.lowercased()) translation.
        """

        let apiKey = APIConfig.openAIAPIKey
        guard apiKey != "YOUR_OPENAI_KEY_HERE",
              let url = URL(string: "\(APIConfig.openAIBaseURL)/chat/completions") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "temperature": 1.1,
            "messages": [
                ["role": "system", "content": system],
                ["role": "user",   "content": user]
            ]
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String
            else { completion(.failure(NSError(domain: "TalkSwitchAPI", code: -1))); return }
            completion(.success(self.parseResponse(content)))
        }.resume()
    }
    
    // MARK: - Automated Persona Profiler
    
    /// Records a translation and triggers background persona update if threshold is met
    func recordTranslationForPersona(original: String, translated: String, tone: Tone) {
        guard let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper") else { return }
        let key = "talkswitch_persona_history"
        
        var history = defaults.array(forKey: key) as? [[String: String]] ?? []
        history.append([
            "original": original,
            "translated": translated,
            "tone": tone.displayName
        ])
        
        // If we hit 20 translations, offload to summarize
        if history.count >= 20 {
            defaults.removeObject(forKey: key) // Clear current batch
            generatePersonaSummary(from: history)
        } else {
            defaults.set(history, forKey: key)
        }
        defaults.synchronize()
    }
    
    private func generatePersonaSummary(from history: [[String: String]]) {
        let apiKey = APIConfig.openAIAPIKey
        guard apiKey != "YOUR_OPENAI_KEY_HERE",
              let url = URL(string: "\(APIConfig.openAIBaseURL)/chat/completions") else { return }
              
        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        let existingPersona = defaults?.string(forKey: "talkswitch_user_persona")
        
        // Format history for prompt
        var log = ""
        for (i, entry) in history.enumerated() {
            let tone = entry["tone"] ?? "unknown"
            let text = entry["original"] ?? ""
            log += "[\(i+1)] Tone: \(tone). Text: \"\(text)\"\n"
        }
        
        let existingContext = existingPersona != nil ? "Existing Persona Profile: \(existingPersona!)\n\n" : ""
        
        let systemPrompt = """
        You are an AI profiling an app user to understand their communication style, humor, and vibe.
        Read the following log of the user's last 20 messages.
        \(existingContext)
        Your job is to output a single, consolidated 3-sentence summary of this user's personality.
        Focus on:
        1. Their sense of humor (e.g., sarcastic, dry, playful, literal).
        2. Their tolerance for profanity or crude language.
        3. Their overall communication vibe.
        
        If an 'Existing Persona Profile' is provided above, neatly merge the new insights from these 20 messages into the existing profile to create a smooth, updated 3-sentence composite mean. Do NOT write more than 3 sentences. Output ONLY the summary text.
        """
        
        let userPrompt = "User's recent messages:\n\(log)"
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "temperature": 0.5,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user",   "content": userPrompt]
            ]
        ]
        
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else { return }
                  
            let updatedPersona = content.trimmingCharacters(in: .whitespacesAndNewlines)
            defaults?.set(updatedPersona, forKey: "talkswitch_user_persona")
            defaults?.synchronize()
            NSLog("TSKBD_PERSONA_UPDATED: \(updatedPersona)")
        }.resume()
    }
}
