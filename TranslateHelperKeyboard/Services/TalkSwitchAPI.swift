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

    // MARK: - Language Name Mapper

    /// Maps ISO language codes to their display names for use in prompts
    private func languageName(for code: String) -> String {
        switch code {
        case "en": return "English"
        case "es": return "Mexican Spanish"
        case "fr": return "French"
        case "de": return "German"
        case "it": return "Italian"
        case "pt": return "Brazilian Portuguese"
        case "ja": return "Japanese"
        case "zh": return "Chinese"
        case "ar": return "Arabic"
        case "ko": return "Korean"
        case "ru": return "Russian"
        case "nl": return "Dutch"
        case "pl": return "Polish"
        case "tr": return "Turkish"
        case "uk": return "Ukrainian"
        case "cs": return "Czech"
        case "ro": return "Romanian"
        case "bg": return "Bulgarian"
        case "el": return "Greek"
        case "sv": return "Swedish"
        case "da": return "Danish"
        case "no": return "Norwegian"
        case "fi": return "Finnish"
        case "hu": return "Hungarian"
        case "sk": return "Slovak"
        case "id": return "Indonesian"
        case "vi": return "Vietnamese"
        case "he": return "Hebrew"
        case "hr": return "Croatian"
        case "hi": return "Hindi"
        case "bn": return "Bengali"
        case "ur": return "Urdu"
        case "sw": return "Swahili"
        case "fa": return "Persian"
        case "th": return "Thai"
        case "ca": return "Catalan"
        case "ms": return "Malay"
        case "fil": return "Filipino"
        case "af": return "Afrikaans"
        case "ta": return "Tamil"
        default: return "English"
        }
    }
    
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
        
        let systemPrompt = buildSystemPrompt(sourceLang: sourceLang, targetLang: targetLang, tone: tone, originalText: original)
        let userPrompt = buildUserPrompt(original: original, deeplTranslation: deeplTranslation, tone: tone)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Long messages need more output room for paragraph-formatted translations
        let wordCount = original.split(separator: " ").count
        let maxToks = wordCount > 60 ? 900 : 500

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": tone == .flirty ? 0.9 : 0.7,
            "max_tokens": maxToks
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

        let langName = languageName(for: language)
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
        Pay attention to common grammar pitfalls in \(langName) — verb conjugation, gender agreement, \
        formal vs informal register, and any language-specific patterns learners often get wrong.
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
    
    func getGentleCorrection(text: String, language: String, completion: @escaping (Result<GentleCorrectionResult, Error>) -> Void) {
        let apiKey = APIConfig.openAIAPIKey
        guard apiKey != "YOUR_OPENAI_KEY_HERE" else {
            completion(.failure(NSError(domain: "TalkSwitchAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "OpenAI not configured"])))
            return
        }

        guard let url = URL(string: "\(APIConfig.openAIBaseURL)/chat/completions") else {
            completion(.failure(NSError(domain: "TalkSwitchAPI", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let langName = languageName(for: language)
        let systemPrompt = """
        You are a warm, advanced language coach for \(langName).
        A student typed a passage in \(langName). Your ONLY job is to isolate a specific phrase
        where they made a mistake or sounded unnatural, and show them how a native speaker would naturally express *just that part*.

        RULES:
        - NEVER rewrite their entire passage. Only pick out the specific phrase or sentence chunk that needs fixing.
        - Focus on these common advanced-learner patterns:
          1. Preposition misuse
          2. Register mismatch (overly formal when casual is natural)
          3. Literal translation from English (word order, false friends)
          4. Idiomatic phrasing
        - Keep explanations ultra-brief (1 sentence).

        Respond ONLY with valid JSON:
        {
          "userSaid": "the specific short phrase they wrote that needs fixing",
          "nativeSay": "how a native speaker would say that exact short phrase",
          "explanation": "brief, warm explanation of the difference",
          "severity": "improvement" | "natural"
        }
        If severity is "natural", it means their language was already native-sounding, and you should leave userSaid/nativeSay blank.
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
    
    // MARK: - Per-Audio Speech Coaching (1 pronunciation tip + 1 grammar tip)

    struct SpeechCoachingTip {
        let pronunciationTip: String?   // nil if pronunciation was fine
        let grammarTip: String?         // nil if grammar was fine
    }

    /// Analyzes a voice message transcription and returns max 1 pronunciation tip + 1 grammar tip.
    /// Designed to be lightweight, fast, and non-overwhelming.
    func getSpeechCoachingTips(
        spokenText: String,
        spokenLanguage: String,
        nativeLanguage: String = "en",
        mistakeProfile: String = "",
        completion: @escaping (Result<SpeechCoachingTip, Error>) -> Void
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

        let spokenLangName = languageName(for: spokenLanguage)
        let nativeLangName = languageName(for: nativeLanguage)

        let profileBlock = mistakeProfile.isEmpty ? "" : """
        \
        \
        ════════════ USER'S KNOWN WEAK SPOTS ════════════ \
        \(mistakeProfile) \
        If the user makes a mistake in one of their known weak areas, acknowledge the pattern \
        warmly — e.g. "That sneaky preposition again — you'll get this one!" \
        If they got a previously weak area RIGHT, celebrate it — e.g. "You nailed the gender on that one!" \
        ══════════════════════════════════════════════════
        """

        let systemPrompt = """
        You are a warm, encouraging language coach. A user just sent a voice message in \(spokenLangName). \
        Their native language is \(nativeLangName). \
        \
        Analyze their spoken text and provide AT MOST: \
        - 1 pronunciation tip (if applicable) \
        - 1 grammar tip (if applicable) \
        \
        If their speech was perfect, say so — don't invent problems. \
        \
        PRONUNCIATION TIPS: Focus on sounds that \(nativeLangName) speakers commonly struggle with \
        in \(spokenLangName). If a word or phrase would likely be mispronounced based on the text, \
        give a specific tip. Don't guess wildly — only flag things that are genuinely tricky. \
        \
        GRAMMAR TIPS: Look for word order issues, gender agreement, verb conjugation, preposition \
        misuse, or native language transfer patterns (structures that work in \(nativeLangName) but \
        not in \(spokenLangName)). When you spot a native language transfer, explicitly acknowledge it: \
        "I know in \(nativeLangName) you'd say it this way, but in \(spokenLangName)..." \
        \
        \(profileBlock)\
        \
        CRITICAL RULES: \
        - Write ALL tips in \(nativeLangName) with \(spokenLangName) words quoted inline \
        - Be warm, encouraging, and brief — max 2 sentences per tip \
        - Never be condescending or overly academic \
        - If nothing needs correcting, just say something encouraging about their speech \
        \
        Respond ONLY with valid JSON: \
        {"pronunciation": "tip or null", "grammar": "tip or null"} \
        If no issue in a category, use null (not the string "null"). \
        If everything was great: {"pronunciation": null, "grammar": null, "praise": "short encouragement"}
        """

        let userPrompt = "Spoken \(spokenLangName) text: \"\(spokenText)\"\nGive me 1 pronunciation tip and 1 grammar tip (or praise if perfect)."

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
            "temperature": 0.5,
            "max_tokens": 200
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        urlSession.dataTask(with: request) { data, _, error in
            if let error = error { completion(.failure(error)); return }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                completion(.failure(NSError(domain: "TalkSwitchAPI", code: -4,
                    userInfo: [NSLocalizedDescriptionKey: "Could not parse coaching response"])))
                return
            }

            // Parse JSON response
            let cleaned = content.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if let tipData = cleaned.data(using: .utf8),
               let tipJSON = try? JSONSerialization.jsonObject(with: tipData) as? [String: Any] {
                let pronTip = tipJSON["pronunciation"] as? String
                let gramTip = tipJSON["grammar"] as? String
                let praise = tipJSON["praise"] as? String

                // If no tips but there's praise, put praise in pronunciation slot
                let finalPronTip = pronTip ?? praise
                completion(.success(SpeechCoachingTip(pronunciationTip: finalPronTip, grammarTip: gramTip)))
            } else {
                // Fallback: use raw content as a general tip
                completion(.success(SpeechCoachingTip(pronunciationTip: cleaned, grammarTip: nil)))
            }
        }.resume()
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

        let sourceName = languageName(for: sourceLang)
        let targetName = languageName(for: targetLang)
        let toneDesc = tone.displayName.lowercased()

        // Pull location context — same 4-tier slang distribution used in translation prompts
        let locationInstruction = buildLocationInstruction()
        let locationBlock = locationInstruction.isEmpty
            ? ""
            : "\n\n\(locationInstruction)"

        // Notes are ALWAYS about the target-language phrase — regardless of which direction the card is studied.
        // The English side is never the subject. Teach the learner about target language usage, culture, slang.

        var systemPrompt = ""
        var userPrompt = ""

        // ── FLIRTY TONE: completely separate, gender-aware prompt ──────────────────────
        if tone == .flirty {
            let genderContext = buildFlirtyGenderContext()
            let targetText = sourceLang == "en" ? translated : original
            let enOrigin = sourceLang == "en"

            let prohibitionBlock = enOrigin ? """
            \
            ════════════ ABSOLUTE PROHIBITION ════════════ \
            The user typed in ENGLISH. They have NO idea what any other \(targetName) phrasing would be. \
            NEVER write: "[\(targetName) A] was changed to [\(targetName) B]" or compare two \(targetName) options. \
            NEVER say "instead of '...' we used '...'". \
            ══════════════════════════════════════════════
            """ : ""

            systemPrompt = """
            You are a charming, insider bilingual coach specialising in \(targetName) flirting and social dynamics. \
            Your job is to write a short, memorable coaching note about the \(targetName) phrase used — \
            WHY it works, what emotional effect it has on the listener, and how native \(targetName) speakers actually use it \
            in real flirty situations. \
            \(prohibitionBlock)\
            \
            \(genderContext)\
            \
            VARIETY RULE — CRITICAL: \
            Every note must open with a DIFFERENT sentence structure. \
            Think of yourself as a charming friend whispering insider tips. \
            Draw naturally from openers like these — or invent your own variation: \
            • "A little insider tip: '...' is what smooth speakers reach for when they want to..." \
            • "There's something magnetic about '...' — it signals..." \
            • "If you said this to a native speaker, they'd..." \
            • "Native \(targetName) speakers who know how to charm naturally reach for '...' — it carries..." \
            • "The secret power of '...' is that it sounds effortless, not rehearsed —" \
            • "This phrase hits differently because..." \
            • "'...' walks the perfect line between warm and bold — you'd use it when..." \
            • "The vibe of '...' is hard to fake — it's what you say when you want to come across as..." \
            • "Want to make someone smile? '...' does it naturally because..." \
            • "There's a playfulness baked into '...' that makes it land without trying too hard —" \
            Feel free to rephrase any of these in your own words — the goal is that no two notes \
            ever open the same way. Variety makes coaching feel human, not robotic. \
            \
            ════════════ LANGUAGE OF OUTPUT ════════════ \
            You MUST write the note in ENGLISH. The user is an English speaker learning \(targetName). \
            They cannot read a note written entirely in \(targetName). \
            Write your explanation in English. Only use \(targetName) words when quoting specific phrases — \
            these should be in quotes inline within English sentences. \
            ══════════════════════════════════════════════ \
            \
            CRITICAL RULES: \
            • The note body MUST be in English — never write the whole note in \(targetName) \
            • \(targetName) words/phrases appear inline in quotes within English sentences \
            • Focus on the EMOTIONAL and SOCIAL effect of the phrase — not just its literal meaning \
            • If the user's target gender is known, make the coaching specific: how does THIS phrase land on a man / woman? \
            • Maximum 2 sentences. Be punchy and concise — the user is mid-conversation. No JSON. Plain text only.\(locationBlock)
            """
            let promptPrefix = enOrigin
                ? "\(targetName) phrase chosen: \"\(targetText)\""
                : "\(targetName) phrase used: \"\(targetText)\""
            userPrompt = "\(promptPrefix)\nTone: flirty\nIMPORTANT: Write your note in ENGLISH with \(targetName) phrases quoted inline. Write a short, varied note about why this phrase works and how it lands — who uses it, in what situation, what feeling it creates."

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
                "temperature": 0.85,  // Higher for flirty — more personality, more warmth
                "max_tokens": 300
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            self.urlSession.dataTask(with: request) { data, _, error in
                DispatchQueue.main.async {
                    if let error = error { completion(.failure(error)); return }
                    guard let data = data,
                          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let choices = json["choices"] as? [[String: Any]],
                          let message = choices.first?["message"] as? [String: Any],
                          let content = message["content"] as? String else {
                        completion(.failure(NSError(domain: "TalkSwitchAPI", code: -4,
                            userInfo: [NSLocalizedDescriptionKey: "Could not parse flirty notes"])))
                        return
                    }
                    completion(.success(content.trimmingCharacters(in: .whitespacesAndNewlines)))
                }
            }.resume()
            return  // ← Exit early; flirty has its own request lifecycle
        }

        // ── All other tones ────────────────────────────────────────────────────────────
        if original == translated && sourceLang == targetLang {
            // ── Branch A: User typed in target language — note is a pure cultural observation ──
            systemPrompt = """
            You are a bilingual cultural coach specialising in \(targetName). \
            A learner has typed a phrase in \(targetName). \
            Write a short cultural note EXCLUSIVELY about their \(targetName) phrase. \
            \
            Always cover: \
            1. How the \(targetName) phrase is actually used — regional flavour, tone, register \
            2. A more natural or \(toneDesc) alternative a native speaker might reach for, and why \
            3. One cultural slang, idiom, or tip about the phrasing \
            \
            VARIETY RULE — CRITICAL: \
            Every note must open with a DIFFERENT sentence structure. \
            Draw naturally from openers like these — or invent your own variation: \
            • "A native speaker would typically say..." \
            • "A local would lean toward... because..." \
            • "Worth knowing:" \
            • "Locals would probably phrase it as..." \
            • "One thing to notice:" \
            • "This phrasing works, but..." \
            • "The street-level version of this is..." \
            • "Native twist:" \
            • "In everyday conversation, you'd hear..." \
            • "The neighbourhood way of saying this is..." \
            Feel free to rephrase any of these in your own words — the goal is that no two notes \
            ever open the same way. Variety makes the coaching feel human, not robotic. \
            \
            ════════════ LANGUAGE OF OUTPUT ════════════ \
            You MUST write the note in ENGLISH. The user is an English speaker learning \(targetName). \
            They cannot read a note written entirely in \(targetName). \
            Write your explanation in English. Only use \(targetName) words when quoting specific phrases — \
            these should be in quotes inline within English sentences. \
            ══════════════════════════════════════════════ \
            \
            CRITICAL RULES: \
            • The note body MUST be in English — never write the whole note in \(targetName) \
            • \(targetName) words/phrases appear inline in quotes within English sentences \
            • Don't correct their grammar (another system does that) \
            • Maximum 2 sentences. Be punchy and concise — the user is mid-conversation. No JSON. Plain text only.\(locationBlock)
            """
            userPrompt = "\(targetName) phrase: \"\(original)\"\nTone context: \(toneDesc)\nIMPORTANT: Write your note in ENGLISH with \(targetName) phrases quoted inline. Write a short, varied cultural note or local slang connection ONLY about this phrase."

        } else if sourceLang == "en" {
            // ── Branch B: User typed English — we translated it to target language ──
            // The user NEVER said anything in the target language. NEVER compare target phrase A to target phrase B.
            let targetText = translated
            systemPrompt = """
            You are a bilingual cultural coach specialising in \(targetName). \
            A user typed something in ENGLISH and we translated it into \(targetName). \
            Write a short cultural note explaining the \(targetName) phrase that was chosen — \
            what it means culturally, why it sounds natural, and how native speakers actually use it. \
            \
            Always cover: \
            1. Why this particular \(targetName) phrase is a natural, culturally fitting choice \
            2. How native speakers actually use it — context, register, vibe \
            3. One slang, idiom, or cultural tip that enriches the learner's understanding \
            \
            ════════════ ABSOLUTE PROHIBITION ════════════ \
            The user typed in ENGLISH. They have NO idea what any other \(targetName) phrasing would be. \
            NEVER write notes in the form: "[\(targetName) A] was changed to [\(targetName) B]". \
            NEVER write: "instead of [\(targetName) phrase], we used [\(targetName) phrase]". \
            NEVER compare two \(targetName) options — that is broken logic for an English speaker. \
            ══════════════════════════════════════════════ \
            \
            VARIETY RULE — CRITICAL: \
            Every note must open with a DIFFERENT sentence structure. \
            Draw naturally from openers like these — or invent your own variation: \
            • "We went with '...' here because..." \
            • "People often use '...' in \(targetName) to..." \
            • "A very natural way to say this is '...' — you'd hear it when..." \
            • "The phrase chosen here — '...' — is deliberate:" \
            • "Worth noting: '...' has a..." \
            • "This expression lands well because..." \
            • "You'll hear '...' when..." \
            • "The cultural pick here is '...' —" \
            • "Native speakers naturally gravitate toward '...' because..." \
            • "In \(targetName), this kind of phrase tends to use '...' — it carries..." \
            Feel free to rephrase any of these in your own words — the goal is that no two notes \
            ever open the same way. Variety makes the coaching feel human, not robotic. \
            \
            ════════════ LANGUAGE OF OUTPUT ════════════ \
            You MUST write the note in ENGLISH. The user is an English speaker learning \(targetName). \
            They cannot read a note written entirely in \(targetName). \
            Write your explanation in English. Only use \(targetName) words when quoting specific phrases \
            from the translation — these should be in quotes or italics inline within English sentences. \
            ══════════════════════════════════════════════ \
            \
            CRITICAL RULES: \
            • The note body MUST be in English — never write the whole note in \(targetName) \
            • \(targetName) words/phrases appear inline in quotes within English sentences \
            • Do NOT explain the English phrase. Never say "In English..." — they already know English \
            • Maximum 2 sentences. Be punchy and concise — the user is mid-conversation. No JSON. Plain text only.\(locationBlock)
            """
            userPrompt = "\(targetName) phrase chosen: \"\(targetText)\"\nTone: \(toneDesc)\nIMPORTANT: Write your note in ENGLISH with \(targetName) phrases quoted inline. Explain why this \(targetName) phrase is a great, natural choice."

        } else {
            // ── Branch C: User typed in target language, translated to English — note is about the original ──
            let targetText = original
            let enText = translated
            systemPrompt = """
            You are a bilingual cultural coach specialising in \(targetName). \
            A user typed something in \(targetName) and we translated it to English. \
            Write a short cultural note EXCLUSIVELY about their \(targetName) phrase. \
            \
            Always cover: \
            1. How the \(targetName) phrase is actually used — regional flavour, tone, register \
            2. A more natural or \(toneDesc) \(targetName) alternative a native speaker might prefer, and why \
            3. One cultural slang, idiom, or tip about the phrasing \
            \
            VARIETY RULE — CRITICAL: \
            Every note must open with a DIFFERENT sentence structure. \
            Draw naturally from openers like these — or invent your own variation: \
            • "A native speaker would typically say..." \
            • "A local would lean toward... because..." \
            • "Worth knowing:" \
            • "Locals would probably phrase it as..." \
            • "One thing to notice:" \
            • "This phrasing works, but..." \
            • "The street-level version of this is..." \
            • "Native twist:" \
            • "In everyday conversation, you'd hear..." \
            • "The neighbourhood way of saying this is..." \
            Feel free to rephrase any of these in your own words — the goal is that no two notes \
            ever open the same way. Variety makes the coaching feel human, not robotic. \
            \
            ════════════ LANGUAGE OF OUTPUT ════════════ \
            You MUST write the note in ENGLISH. The user is an English speaker learning \(targetName). \
            They cannot read a note written entirely in \(targetName). \
            Write your explanation in English. Only use \(targetName) words when quoting specific phrases — \
            these should be in quotes inline within English sentences. \
            ══════════════════════════════════════════════ \
            \
            CRITICAL RULES: \
            • The note body MUST be in English — never write the whole note in \(targetName) \
            • \(targetName) words/phrases appear inline in quotes within English sentences \
            • Do NOT explain the English phrase. Never say "In English..." — they already know English \
            • Maximum 2 sentences. Be punchy and concise — the user is mid-conversation. No JSON. Plain text only.\(locationBlock)
            """
            userPrompt = "\(targetName): \"\(targetText)\"\nEnglish: \"\(enText)\"\nTone: \(toneDesc)\nIMPORTANT: Write your note in ENGLISH with \(targetName) phrases quoted inline. Write notes ONLY about the \(targetName) phrase — cultural context, how it's used, and a natural variation."
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
            "temperature": 0.78,  // Slightly higher for more expressive, human-feeling phrasing variety
            "max_tokens": 280
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

        let sourceName = languageName(for: sourceLang)
        let targetName = languageName(for: targetLang)

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

    /// Returns a paragraph-formatting block to inject into the system prompt when
    /// the source text is long enough to benefit from it (voice messages, multi-idea texts).
    /// The block instructs the model to break the translation at natural idea/topic shifts,
    /// mimicking how a human would write a multi-paragraph message.
    private func buildParagraphFormattingInstruction(for text: String) -> String {
        let wordCount = text.split(separator: " ").count
        guard wordCount >= 40 else { return "" }  // Short texts: no instruction needed

        return """
         \
         ════════════ PARAGRAPH FORMATTING — CRITICAL ════════════ \
         This message is long (likely from a voice recording or extended text). \
         A single wall of text is hard to read and looks unnatural. \
         STRUCTURE your translation output like a human writing a multi-paragraph message: \
         • Identify every natural shift in topic, idea, or point. \
         • Break there with a blank line (\\n\\n) — exactly as someone would in WhatsApp or iMessage. \
         • Aim for 2–4 sentences per paragraph. A new thought = a new paragraph. \
         • DO NOT break mid-sentence or split a single idea across paragraphs. \
         • Short messages that contain only one idea should remain as a single block. \
         The goal is a translation that reads like a thoughtful human wrote it — not an AI dump. \
         ══════════════════════════════════════════════════════════
        """
    }

    private func buildSystemPrompt(sourceLang: String, targetLang: String, tone: Tone, originalText: String = "") -> String {
        let sourceName = languageName(for: sourceLang)
        let targetName = languageName(for: targetLang)
        let langPair = "\(sourceName) to \(targetName)"

        // Fetch user persona if it exists
        var personaInstruction = ""
        if let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper"),
           let persona = defaults.string(forKey: "talkswitch_user_persona") {
            personaInstruction = "\n\nCRITICAL CONTEXT ABOUT THE USER:\n\(persona)\nUse this context to inform your word choice, structure, and tone naturally without explicitly mentioning it."
        }

        // Build location context for slang distribution
        let locationInstruction = buildLocationInstruction()

        // Build paragraph-formatting instruction (only injects for long texts)
        let paragraphInstruction = buildParagraphFormattingInstruction(for: originalText)

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
            \(paragraphInstruction)\
            \
            Respond ONLY with valid JSON: {"translation": "...", "notes": "...", "localityTag": "..."}
            The "notes" field should briefly explain what flirty expressions you chose in the OUTPUT translation and why they work. \
            CRITICAL: Never frame notes as comparing one \(targetName) version to another \(targetName) version. \
            Describe the word or phrase you chose and why a native speaker would use it in that flirty, charming way. \
            If the grammatical gender was adjusted, mention the alternate form naturally in the note. \
            VARIETY RULE: Every note must open with a different sentence structure — draw from openers like: \
            "We went with '...' because...", "This expression lands well because...", "People often reach for '...' when...", \
            "A very natural flirty choice here is '...' —", "Worth noting: '...' carries...", \
            "Native \(targetName) speakers naturally gravitate toward '...' in this kind of moment because...". \
            Feel free to rephrase these in your own words — variety makes coaching feel human, not robotic.
            The "localityTag" field should describe the geographic scope of the translation, e.g. \
            "Understood in Spain & Latin America", "Common across Latin America", \
            "Used in [Country]", or "Used in [City]" — be specific with city/country names. \
            If there is no location context, set "localityTag" to null.
            """
        case .casual, .work:
            let toneLabel = tone == .work ? "professional business" : "casual conversational"
            let workExtra = tone == .work
                ? "For business tone: treat phrases like 'circle back', 'heads-down', 'loop you in', 'take this offline', 'bandwidth', 'move the needle', 'in the weeds', etc. as idioms that need cultural equivalents — not literal translations. In \(targetName), business people use different fixed expressions to convey these ideas. \\"
                : ""
            return """
            You are a bilingual translation expert specializing in \(langPair). \
            Refine the translation to sound natural with a \(toneLabel) tone. \(personaInstruction)\
            \(locationInstruction)\
            \(paragraphInstruction)\
            \
            IDIOM AWARENESS — CRITICAL RULE: \
            If the source text contains a recognizable idiom, proverb, or fixed expression \
            (e.g. "between a rock and a hard place", "not my cup of tea", "hit the ground running", \
            "circle back", "heads-down", "bite the bullet", "under the weather", "cost an arm and a leg"), \
            do NOT translate it word-for-word. Instead, identify the culturally equivalent expression \
            that a native \(targetName) speaker would actually use, \
            and substitute it naturally in the translation. \
            \(workExtra)\
            When an idiom swap was made, explain it in the "notes" field: name what the source idiom meant and why the chosen expression in \(targetName) carries the same weight. \
            CRITICAL: Do NOT frame notes as comparing one phrase to another phrase in the target language. \
            The notes explain what choice was made in the OUTPUT and why it resonates with a native speaker. \
            If no idiom is present, leave a brief, vivid observation about why the chosen phrasing sounds natural. \
            VARIETY RULE: Every note must open with a different sentence structure — draw from openers like: \
            "We went with '...' here because...", "People often use '...' to...", "A very natural way to say this is '...' —", \
            "Worth noting: '...' carries...", "This expression lands well because...", "In \(targetName), this kind of phrase tends toward '...' —", \
            "The cultural pick here is '...' because...", "Native speakers naturally reach for '...' when...". \
            Feel free to rephrase these in your own words — variety makes coaching feel human, not robotic. \
            \
            Respond ONLY with valid JSON: {"translation": "...", "notes": "...", "localityTag": "..."}
            The "localityTag" field should describe the geographic scope, e.g. \
            "Understood in Spain & Latin America", "Common across Latin America", \
            "Used in [Country]", or "Used in [City]". Set to null if no location context.
            """
        case .slang:
            return """
            You are a bilingual translation expert specializing in \(langPair) street slang and colloquial speech. \
            Your job is to refine translations using real slang, gírias, and informal expressions appropriate for the target language. \
            Use authentic street slang and colloquial expressions that native speakers actually use. \
            Don't sanitize — keep it authentic. But don't add profanity that wasn't in the original. \(personaInstruction)\
            \(locationInstruction)\
            \(paragraphInstruction)\
            \
            Respond ONLY with valid JSON: {"translation": "...", "notes": "...", "localityTag": "..."}
            The "notes" field should explain the slang terms you chose in the OUTPUT translation so the user learns and remembers them. \
            CRITICAL: Do NOT frame notes as comparing one phrase to another phrase in the target language. \
            Describe what slang word or expression you picked and what it means — bring it to life with a sentence about how and where you'd hear it. \
            VARIETY RULE: Every note must open with a different sentence structure — draw from openers like: \
            "We went with '...' here —", "People often throw in '...' when...", "'...' is the real street way to say this —", \
            "Worth knowing: '...' is what you'd hear...", "This slang — '...' — lands well because...", \
            "In [city/region], '...' is the go-to expression for...". \
            Feel free to rephrase these in your own words — variety makes coaching feel human, not robotic. \
            The "localityTag" field should describe the geographic scope of the slang, e.g. \
            "Common across [language-speaking regions]", \
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
        1. UNIVERSAL (🌐): ~40% — expressions understood broadly across all regions where this language is spoken.\
        2. PAN-REGIONAL (🌎): ~30% — expressions common across multiple regions.\
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
    /// Produces a gender-context paragraph for use inside COACHING notes (not translation prompts).
    /// Written in the coaching voice so it blends naturally into the system prompt.
    private func buildFlirtyGenderContext() -> String {
        guard let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper"),
              defaults.bool(forKey: "ts_flirty_context_set")
        else {
            return "GENDER CONTEXT: Not set yet — write in a way that works for any gender dynamic."
        }
        let speakerForm  = defaults.string(forKey: "ts_speaker_form")  ?? "both"
        let targetGender = defaults.string(forKey: "ts_target_gender") ?? "varies"

        let speakerLine: String
        switch speakerForm {
        case "masculine": speakerLine = "The user speaks as a man (masculine forms: 'enamorado', 'contento')."
        case "feminine":  speakerLine = "The user speaks as a woman (feminine forms: 'enamorada', 'contenta')."
        default:          speakerLine = "The user may use either masculine or feminine speaker forms."
        }

        let targetLine: String
        switch targetGender {
        case "male":
            targetLine = "They are flirting WITH a man. Make the coaching specific: how does this phrase land on a man? What does it signal to him?"
        case "female":
            targetLine = "They are flirting WITH a woman. Make the coaching specific: how does this phrase land on a woman? What feeling does it create for her?"
        default:
            targetLine = "Target gender varies — keep coaching gender-neutral, focusing on the phrase's universal charm."
        }

        return "GENDER CONTEXT (use to personalise the coaching note): \(speakerLine) \(targetLine)"
    }

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
        let wordCount = original.split(separator: " ").count
        let longMessageNote = wordCount >= 40
            ? "\n\nIMPORTANT: The original is a long message (likely from a voice recording). Your translation MUST use \\n\\n (blank line) to separate distinct ideas or topic shifts into separate paragraphs. It should read like a human who naturally hits Enter between different points — not one continuous wall of text."
            : ""
        return """
        Original text: "\(original)"
        Base translation (DeepL): "\(deeplTranslation)"
        
        Refine the base translation to match the \(tone.displayName.lowercased()) tone. \
        Keep the meaning accurate but make it sound natural for the target language with the right vibe.\(longMessageNote)
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
        targetLang: String,
        tone: Tone,
        variation: Int,
        completion: @escaping (Result<RefinedTranslation, Error>) -> Void
    ) {
        let sourceName = languageName(for: sourceLang)
        let targetName = languageName(for: targetLang)
        let langPair = "\(sourceName) to \(targetName)"

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
        The "notes" field should briefly explain what makes this version different by describing \
        the specific word, expression, or tone choice used in the new translation — \
        e.g. "Used a more casual, colloquial expression for a natural feel." \
        CRITICAL: Do NOT frame notes as changing one \(targetName) phrase into another \(targetName) phrase. \
        Simply describe what was chosen and why it sounds natural or different.
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
