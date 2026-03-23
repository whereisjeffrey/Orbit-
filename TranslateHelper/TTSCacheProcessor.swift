//
//  TTSCacheProcessor.swift
//  TranslateHelper
//
//  Processes TTS cache requests from the keyboard extension.
//  Called from SceneDelegate when the main app opens.
//  Generates Neural2 audio and saves to the App Group shared container.

import Foundation

enum TTSCacheProcessor {

    private static let appGroup = "group.com.jeff.translatehelper"

    private static var cacheDir: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
            .appendingPathComponent("tts_cache", isDirectory: true)
    }

    private static var requestsFile: URL? {
        cacheDir?.appendingPathComponent("_pending.json")
    }

    /// Called by the keyboard to queue a TTS request
    static func queueRequest(text: String, language: String) {
        guard let dir = cacheDir else { return }
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        // Check if already cached
        let hash = String(abs("\(text)|\(language)".hashValue))
        let cacheFile = dir.appendingPathComponent("\(hash).mp3")
        if FileManager.default.fileExists(atPath: cacheFile.path) { return }

        guard let file = requestsFile else { return }
        var requests: [[String: String]] = []
        if let data = try? Data(contentsOf: file),
           let existing = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] {
            requests = existing
        }

        let entry = ["text": text, "language": language]
        guard !requests.contains(where: { $0["text"] == text && $0["language"] == language }) else { return }
        requests.append(entry)
        if requests.count > 30 { requests = Array(requests.suffix(30)) }

        if let data = try? JSONSerialization.data(withJSONObject: requests) {
            try? data.write(to: file)
        }
    }

    /// Called from main app (SceneDelegate) to generate cached audio
    static func processPendingRequests() {
        guard let dir = cacheDir, let file = requestsFile else { return }
        guard let data = try? Data(contentsOf: file),
              let requests = try? JSONSerialization.jsonObject(with: data) as? [[String: String]],
              !requests.isEmpty else { return }

        NSLog("🔊 [TTSCache] processing \(requests.count) pending requests")

        // Clear file immediately
        try? FileManager.default.removeItem(at: file)

        let apiKey = APIConfig.googleTTSAPIKey
        let baseURL = APIConfig.googleTTSBaseURL

        for request in requests {
            guard let text = request["text"], let language = request["language"] else { continue }

            let hash = String(abs("\(text)|\(language)".hashValue))
            let cacheFile = dir.appendingPathComponent("\(hash).mp3")
            if FileManager.default.fileExists(atPath: cacheFile.path) { continue }

            let locale = googleLocale(for: language)
            guard let url = URL(string: "\(baseURL)/text:synthesize?key=\(apiKey)") else { continue }

            let body: [String: Any] = [
                "input": ["text": text],
                "voice": [
                    "languageCode": locale,
                    "name": "\(locale)-Neural2-A",
                    "ssmlGender": "FEMALE"
                ],
                "audioConfig": [
                    "audioEncoding": "MP3",
                    "speakingRate": 0.95,
                    "pitch": 0.0
                ]
            ]

            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try? JSONSerialization.data(withJSONObject: body)
            req.timeoutInterval = 15

            URLSession.shared.dataTask(with: req) { data, _, _ in
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let audioContent = json["audioContent"] as? String,
                      let audioData = Data(base64Encoded: audioContent) else { return }

                try? audioData.write(to: cacheFile)
                NSLog("🔊 [TTSCache] cached: \(text.prefix(30)) → \(audioData.count) bytes")
            }.resume()
        }
    }

    private static func googleLocale(for language: String) -> String {
        let code = String(language.prefix(2))
        switch code {
        case "es": return "es-US"
        case "pt": return "pt-BR"
        case "zh": return "cmn-CN"
        case "fr": return "fr-FR"
        case "de": return "de-DE"
        case "it": return "it-IT"
        case "ja": return "ja-JP"
        case "ko": return "ko-KR"
        case "ar": return "ar-XA"
        case "en": return "en-US"
        default: return "\(code)-\(code.uppercased())"
        }
    }
}
