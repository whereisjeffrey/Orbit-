//
//  TalkSwitchAPI.swift
//  TalkSwitch
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
    private let urlSession = URLSession(configuration: .default)
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
    
    struct GentleCorrectionResult {
        let userSaid: String
        let nativeSay: String
        let explanation: String
        let category: String?
        let severity: String
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
        
        let task = self.urlSession.dataTask(with: request) { data, response, error in
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
        
        let task = self.urlSession.dataTask(with: request) { data, response, error in
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
    
    func getGentleCorrection(text: String, completion: @escaping (Result<GentleCorrectionResult, Error>) -> Void) {
        let apiKey = APIConfig.openAIAPIKey
        guard apiKey != "YOUR_OPENAI_KEY_HERE" else {
            completion(.failure(NSError(domain: "TalkSwitchAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "OpenAI not configured"])))
            return
        }
        
        guard let url = URL(string: "\(APIConfig.openAIBaseURL)/chat/completions") else {
            completion(.failure(NSError(domain: "TalkSwitchAPI", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let systemPrompt = """
        You are a warm, advanced language coach for Mexican Spanish.
        A student typed a passage in Spanish. Your ONLY job is to isolate a specific phrase 
        where they made a mistake or sounded unnatural, and show them how a Mexican would naturally express *just that part*.

        RULES:
        - NEVER rewrite their entire passage. Only pick out the specific phrase or sentence chunk that needs fixing.
        - Focus on these common advanced-learner patterns:
          1. Preposition misuse (para/por, en/a, de/con)
          2. Register mismatch (overly formal when casual is natural)
          3. Literal translation from English (word order, false friends)
          4. Idiomatic phrasing
        - Keep explanations ultra-brief (1 sentence).

        Respond ONLY with valid JSON:
        {
          "userSaid": "the specific short phrase they wrote that needs fixing",
          "nativeSay": "how a Mexican would say that exact short phrase",
          "explanation": "brief, warm explanation of the difference",
          "severity": "improvement" | "natural"
        }
        If severity is "natural", it means their entirely Spanish was already native-sounding, and you should leave userSaid/nativeSay blank.
        """
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": text]
            ],
            "response_format": ["type": "json_object"],
            "temperature": 0.2, // Low temp for more consistent formatting
            "max_tokens": 150
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = self.urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "TalkSwitchAPI", code: -3, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    let strData = String(data: data, encoding: .utf8) ?? "unknown"
                    completion(.failure(NSError(domain: "TalkSwitchAPI", code: -4, userInfo: [NSLocalizedDescriptionKey: "JSON Parse failed. Output: \(strData)"])))
                    return
                }
                
                if let apiError = json["error"] as? [String: Any],
                   let message = apiError["message"] as? String {
                    completion(.failure(NSError(domain: "TalkSwitchAPI", code: -5, userInfo: [NSLocalizedDescriptionKey: "OpenAI: \(message)"])))
                    return
                }
                
                if let choices = json["choices"] as? [[String: Any]],
                   let first = choices.first,
                   let message = first["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    // clean markdown markers if any
                    let cleanContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: "```json", with: "")
                        .replacingOccurrences(of: "```", with: "")
                    
                    if let contentData = cleanContent.data(using: .utf8),
                       let resultJSON = try JSONSerialization.jsonObject(with: contentData) as? [String: Any] {
                        
                        let userSaid = resultJSON["userSaid"] as? String ?? ""
                        let nativeSay = resultJSON["nativeSay"] as? String ?? ""
                        let explanation = resultJSON["explanation"] as? String ?? ""
                        let category = resultJSON["category"] as? String
                        let severity = resultJSON["severity"] as? String ?? "suggestion"
                        
                        let result = GentleCorrectionResult(userSaid: userSaid, nativeSay: nativeSay, explanation: explanation, category: category, severity: severity)
                        completion(.success(result))
                        return
                    }
                }
                let strData = String(data: data, encoding: .utf8) ?? "unknown"
                completion(.failure(NSError(domain: "TalkSwitchAPI", code: -4, userInfo: [NSLocalizedDescriptionKey: "JSON Parse failed. Output: \(strData)"])))
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

        // Pull location context — same 4-tier slang distribution used in translation prompts
        let locationInstruction = buildLocationInstruction()
        let locationBlock = locationInstruction.isEmpty
            ? ""
            : "\n\n\(locationInstruction)"

        // Notes are ALWAYS about the Spanish phrase — regardless of which direction the card is studied.
        // The English side is never the subject. Teach the learner about Spanish usage, culture, slang.
        
        var systemPrompt = ""
        var userPrompt = ""
        
        if original == translated && sourceLang == "es" {
            // User typed raw Spanish
            systemPrompt = """
            You are a bilingual cultural coach specialising in Mexican Spanish. \
            A learner has typed a phrase in Spanish. \
            Write a short cultural note EXCLUSIVELY about their Spanish phrase. \
            \
            Always cover: \
            1. How the Spanish phrase is actually used — regional flavour, tone, register \
            2. One Mexican or Latin American slang, idiom, or cultural tip about the phrasing \
            \
            CRITICAL RULES: \
            • Write notes in English so the learner understands — but every example must be in Spanish \
            • Never discuss English slang, idioms, or cultural context — Spanish only \
            • Don't correct their grammar (another system does that) \
            • Max 3-4 lines. No JSON. Plain text only.\(locationBlock)
            """
            userPrompt = "Spanish phrase: \"\(original)\"\nTone context: \(toneDesc)\nWrite a short cultural note or local slang connection ONLY about this phrase."
        } else {
            // Usual translation pair
            systemPrompt = """
            You are a bilingual cultural coach specialising in Mexican Spanish. \
            A user has a translation between English and Spanish. \
            Write a short cultural note EXCLUSIVELY about the SPANISH phrase. \
            \
            Always cover: \
            1. How the Spanish phrase is actually used — regional flavour, tone, register \
            2. A more natural or \(toneDesc) Spanish alternative if the phrasing is literal \
            3. One Mexican or Latin American slang, idiom, or cultural tip about the Spanish phrase \
            \
            CRITICAL RULES: \
            • Write notes in English so the learner understands — but every example must be in Spanish \
            • Do NOT explain the English phrase. Never say "In English..." — they already know English \
            • Never discuss English slang, idioms, or cultural context — Spanish only \
            • Max 3-4 lines. No JSON. Plain text only.\(locationBlock)
            """
            let enText = sourceLang == "en" ? original : translated
            let esText = sourceLang == "es" ? original : translated
            userPrompt = "English: \"\(enText)\"\nSpanish: \"\(esText)\"\nTone: \(toneDesc)\nWrite notes ONLY about the Spanish phrase."
        }
        
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
        
        let task = self.urlSession.dataTask(with: request) { data, response, error in
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
                    let strData = String(data: data, encoding: .utf8) ?? "unknown"
                    completion(.failure(NSError(domain: "TalkSwitchAPI", code: -4,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid response: \(strData)"])))
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
        
        let task = self.urlSession.dataTask(with: request) { data, response, error in
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
            let toneLabel = tone == .work ? "professional business" : "casual conversational"
            let workExtra = tone == .work
                ? "For business tone: treat phrases like 'circle back', 'heads-down', 'loop you in', 'take this offline', 'bandwidth', 'move the needle', 'in the weeds', etc. as idioms that need cultural equivalents — not literal translations. In Spanish/Portuguese, business people use different fixed expressions to convey these ideas. \\"
                : ""
            return """
            You are a bilingual translation expert specializing in \(langPair). \
            Refine the translation to sound natural with a \(toneLabel) tone. \(personaInstruction)\
            \(locationInstruction)\
            \
            IDIOM AWARENESS — CRITICAL RULE: \
            If the source text contains a recognizable idiom, proverb, or fixed expression \
            (e.g. "between a rock and a hard place", "not my cup of tea", "hit the ground running", \
            "circle back", "heads-down", "bite the bullet", "under the weather", "cost an arm and a leg"), \
            do NOT translate it word-for-word. Instead, identify the culturally equivalent expression \
            that a native \(targetLang == "pt" ? "Brazilian Portuguese" : "Spanish") speaker would actually use, \
            and substitute it naturally in the translation. \
            \(workExtra)\
            Always explain the swap in the "notes" field so the user learns both sides — \
            e.g. "Note: 'not my cup of tea' → 'não é minha praia' (literally 'not my beach') in Brazilian Portuguese." \
            If no idiom is present, simply refine for natural tone as usual. \
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

        self.urlSession.dataTask(with: req) { data, _, error in
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

        self.urlSession.dataTask(with: req) { data, _, _ in
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
