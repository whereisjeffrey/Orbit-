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

    struct SolResponse {
        let text: String
        let translation: String?
        let translationNotes: String?
        let nativeCorrectionForUser: String?
        let nativeCorrectionNotes: String?
        let slangNotes: [SlangNote]
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

        let langName: String = {
            let map: [String: String] = ["pt": "Portuguese", "es": "Spanish", "fr": "French", "de": "German", "it": "Italian", "ja": "Japanese", "ko": "Korean", "zh": "Chinese"]
            return map[targetLanguage] ?? "Portuguese"
        }()

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

        let memoryBlock = SolMemoryStore.shared.buildContextBlock()
        let callbackHint = SolMemoryStore.shared.buildCallbackSuggestion() ?? ""

        let systemPrompt = """
        You are Sol, a warm and fun language coach having a conversation \
        in \(langName) with an English speaker who lives in \(userCity). \
        \
        \(toneBlock) \
        \(memoryBlock) \
        \(callbackHint) \
        \
        CRITICAL — HOW YOU SPEAK: \
        - Speak like a REAL person from \(userCity) — use actual slang, contractions, \
          and colloquial expressions that people use on the street. \
        - NEVER speak like a textbook. Nobody in \(userCity) talks like a textbook. \
        - Use expressions that the user won't find in language courses — figures of speech, \
          local idioms, casual contractions. This is the whole point. \
        - Keep responses short and natural (2-3 sentences) \
        - Match the tone described above — your personality shifts based on the setting \
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
        - LOCATION ACCURACY: ONLY mention places, parks, landmarks, restaurants that are ACTUALLY in \(userCity). \
          Do NOT reference places from other cities in the same country — this destroys trust. \
          If you're unsure whether a place is in \(userCity), don't mention it. \
        - SLANG SCOPE: Use slang from \(userCity) and its region + nationwide slang that everyone understands. \
          Do NOT teach slang that's specific to OTHER cities or regions — if someone in \(userCity) \
          wouldn't naturally use or understand it, don't teach it. \
          Nationwide expressions are great. City-specific expressions from \(userCity) are great. \
          City-specific expressions from other cities are NOT — they'll confuse the user. \
        - Ask follow-up questions to keep the conversation flowing \
        - Adapt to their level — if they're advanced, challenge them with complex topics \
          and nuanced slang. If they're struggling, simplify without being patronizing. \
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
        MUST be written in English. When referencing \(langName) words or phrases inline, \
        keep them in \(langName) — e.g. "Use 'cara' instead of 'pessoa' — it sounds more casual." \
        The user reads English. The \(langName) words teach them vocabulary in context. \
        \
        Respond ONLY with valid JSON: \
        { \
          "response": "your response in \(langName) — speak like a real local", \
          "translation": "English translation of your response", \
          "translation_notes": "1 brief English note about a word/phrase you used (optional, null if none)", \
          "native_correction": "ONLY the specific part the user got wrong — format: 'Instead of [what they said], try [correct version]'. Do NOT repeat the entire sentence. If multiple errors, list each one separately. null if their \(langName) was fine.", \
          "native_correction_notes": "English explanation of WHY — the grammar rule, the pattern, the nuance. Can be multiple sentences. Use \(langName) words inline. null if no correction.", \
          "slang_notes": [{"phrase": "the \(langName) slang/expression", "meaning": "English meaning", \
            "context": "English explanation of when/where people use this — be specific to the city/region"}] or [] if none, \
          "user_facts": ["any personal facts the user revealed in their last message — e.g. 'Looking for an apartment in Condesa', 'Works as a designer', 'Has a date on Friday'. Only include NEW information, not things you already know. Empty array if none."] or [] \
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

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            // Parse Sol's JSON response
            // GPT may return "response" (conversation) or "message" (topic generation) — accept both
            guard let responseData = content.data(using: .utf8),
                  let parsed = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                  let responseText = (parsed["response"] as? String) ?? (parsed["message"] as? String) else {
                NSLog("🎤 [Practice] failed to parse Sol response: \(content.prefix(200))")
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
                for fact in userFacts where !fact.isEmpty {
                    SolMemoryStore.shared.remember(fact, category: "personal")
                }
            }

            let result = SolResponse(
                text: responseText,
                translation: parsed["translation"] as? String,
                translationNotes: parsed["translation_notes"] as? String,
                nativeCorrectionForUser: parsed["native_correction"] as? String,
                nativeCorrectionNotes: parsed["native_correction_notes"] as? String,
                slangNotes: slangNotes
            )

            DispatchQueue.main.async { completion(result) }
        }.resume()
    }
}
