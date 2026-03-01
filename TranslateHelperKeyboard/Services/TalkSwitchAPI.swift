//
//  TalkSwitchAPI.swift
//  TranslateHelperKeyboard
//
//  Created by TalkSwitch on 15/02/26.
//

import Foundation

class TalkSwitchAPI {
    
    static let shared = TalkSwitchAPI()
    private init() {}
    
    struct RefinedTranslation {
        let output: String
        let notes: String?
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
        
        let langName = language == "pt" ? "Brazilian Portuguese" : "English"
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
        For Portuguese, pay attention to: preposition contractions (de+o=do, em+a=na, etc), \
        verb conjugation, gender agreement, and informal vs formal register.
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
            notes += "🇧🇷 Native version:\n\"\(native)\"\n\n"
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
        
        let sourceName = sourceLang == "pt" ? "Brazilian Portuguese" : "English"
        let targetName = targetLang == "pt" ? "Brazilian Portuguese" : "English"
        let toneDesc = tone.displayName.lowercased()
        
        // Different coaching based on direction
        let systemPrompt: String
        if sourceLang == "pt" {
            // User wrote/spoke in Portuguese → coach their Portuguese
            systemPrompt = """
            You are a friendly Brazilian Portuguese coach. A student wrote something in Portuguese. \
            Analyze their Portuguese and provide helpful, concise coaching notes. \
            \
            Your notes should include: \
            1. If there are grammar mistakes, point them out briefly with corrections \
            2. How a native Brazilian would more naturally say it (especially for \(toneDesc) tone) \
            3. One cultural/usage tip about a word or phrase they used \
            \
            Keep it SHORT — max 3-4 lines. Use emoji sparingly. Be encouraging. \
            If their Portuguese is perfect, say so and teach them an alternative expression or slang. \
            Write in English (they're learning Portuguese, they need to understand the notes). \
            Do NOT use JSON. Write plain text only.
            """
        } else {
            // User wrote in English → teach them the Portuguese cultural context
            systemPrompt = """
            You are a bilingual cultural coach for \(sourceName) → \(targetName) translation. \
            A user just translated something. Provide brief, insightful notes about the translation. \
            \
            Your notes should include: \
            1. A more natural/\(toneDesc) alternative if the translation is too literal \
            2. Cultural context — how natives actually say this in conversation \
            3. One useful expression, idiom, or slang related to what they said \
            \
            Keep it SHORT — max 3-4 lines. Use emoji sparingly. \
            If there's an idiom or expression that fits, teach it to them. \
            Write in English with Portuguese examples in quotes. \
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
    
    // MARK: - Prompt Building
    
    private func buildSystemPrompt(sourceLang: String, targetLang: String, tone: Tone) -> String {
        let langPair = sourceLang == "pt"
            ? "Brazilian Portuguese to American English"
            : "American English to Brazilian Portuguese"
        
        switch tone {
        case .flirty:
            return """
            You are a bilingual translation expert specializing in \(langPair). \
            Your job is to refine translations with a flirty, charming tone. \
            Make it sound like someone who's confident and smooth — not creepy or over-the-top. \
            Use natural flirty expressions that native speakers actually use. \
            Keep the core meaning intact but add warmth and playful energy. \
            \
            Respond ONLY with valid JSON: {"translation": "...", "notes": "..."}
            The "notes" field should briefly explain what flirty expressions you used and why.
            """
        case .casual, .work:
            // These shouldn't normally reach OpenAI, but handle gracefully
            return """
            You are a bilingual translation expert specializing in \(langPair). \
            Refine the translation to sound natural and conversational. \
            \
            Respond ONLY with valid JSON: {"translation": "...", "notes": "..."}
            """
        case .slang:
            // Slang / street
            return """
            You are a bilingual translation expert specializing in \(langPair) street slang and colloquial speech. \
            Your job is to refine translations using real slang, gírias, and informal expressions. \
            For Portuguese: use real Brazilian gírias (mano, véi, tá ligado, suave, de boa, etc). \
            For English: use real American casual/street expressions. \
            Don't sanitize — keep it authentic. But don't add profanity that wasn't in the original. \
            \
            Respond ONLY with valid JSON: {"translation": "...", "notes": "..."}
            The "notes" field should explain the slang terms used so the user learns them.
            """
        }
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
            return RefinedTranslation(output: translation, notes: notes)
        }
        
        // Fallback: use the raw content as the translation
        return RefinedTranslation(output: content, notes: nil)
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
        let langPair = sourceLang == "pt"
            ? "Brazilian Portuguese to American English"
            : "American English to Brazilian Portuguese"

        let variationHints = [
            "Use completely different vocabulary and sentence structure.",
            "Try a more idiomatic, native-sounding phrasing.",
            "Make it shorter and punchier.",
            "Make it more expressive and vivid.",
            "Use a different cultural reference or expression."
        ]
        let hint = variationHints[(variation - 1) % variationHints.count]

        let system = """
        You are a creative bilingual translator specializing in \(langPair).
        The user didn't like the previous translation and wants a fresh alternative.
        \(hint)
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
}
