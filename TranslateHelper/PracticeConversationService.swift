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
        guard hwFmt.sampleRate > 0, hwFmt.channelCount > 0 else { return }

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
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        NSLog("🎤 [Practice] recording stopped")
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
        userCity: String = "Rio de Janeiro",
        targetLanguage: String = "pt",
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

        let systemPrompt = """
        You are Sol, a warm and fun language coach having a casual conversation \
        in \(langName) with an English speaker who lives in \(userCity). \
        \
        CRITICAL — HOW YOU SPEAK: \
        - Speak like a REAL person from \(userCity) — use actual slang, contractions, \
          and colloquial expressions that people use on the street. \
        - NEVER speak like a textbook. Nobody in \(userCity) talks like a textbook. \
        - Use expressions that the user won't find in language courses — figures of speech, \
          local idioms, casual contractions. This is the whole point. \
        - Keep responses short and natural (2-3 sentences) \
        - Be warm, playful, and conversational — like a friend at a bar, not a teacher \
        \
        CONVERSATION RULES: \
        - If they make a grammar or vocabulary mistake, don't correct them inline — \
          just continue naturally. Corrections come in the JSON. \
        - Reference \(userCity) naturally — neighborhoods, local spots, culture \
        - Ask follow-up questions to keep the conversation flowing \
        - Adapt to their level — if they're advanced, challenge them with complex topics \
          and nuanced slang. If they're struggling, simplify without being patronizing. \
        - The conversation has no fixed length — keep going as long as it's natural. \
          When a topic wraps up naturally, suggest a new direction or wind down. \
        \
        \(transferBlock) \
        \
        Respond ONLY with valid JSON: \
        { \
          "response": "your response in \(langName) — speak like a real local", \
          "translation": "English translation of your response", \
          "translation_notes": "1 brief note about a word/phrase you used (optional, null if none)", \
          "native_correction": "how a native would say what the USER just said, or null if fine", \
          "native_correction_notes": "brief note about what was improved, or null", \
          "slang_notes": [{"phrase": "the slang/expression", "meaning": "what it means", \
            "context": "when/where people use this — be specific to the city/region"}] or [] if none \
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
            "max_tokens": 400,
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
