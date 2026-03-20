import Foundation

class TranslationService {
    static let shared = TranslationService()
    private let urlSession = URLSession(configuration: .default)
    private init() {}
    
    enum Language: String {
        // Tier 1 — DeepL natively supported
        case english      = "EN"
        case spanish      = "ES"
        case french       = "FR"
        case german       = "DE"
        case italian      = "IT"
        case japanese     = "JA"
        case chinese      = "ZH"
        case arabic       = "AR"
        case korean       = "KO"
        case portugueseBR = "PT-BR"
        case russian      = "RU"
        case dutch        = "NL"
        case polish       = "PL"
        case turkish      = "TR"
        case ukrainian    = "UK"
        case czech        = "CS"
        case romanian     = "RO"
        case bulgarian    = "BG"
        case greek        = "EL"
        case swedish      = "SV"
        case danish       = "DA"
        case norwegian    = "NB"   // DeepL uses NB (Bokmål) for Norwegian
        case finnish      = "FI"
        case hungarian    = "HU"
        case slovak       = "SK"
        case indonesian   = "ID"
        case vietnamese   = "VI"
        case hebrew       = "HE"
        case croatian     = "HR"
        // Tier 2 — Not in DeepL; we use English as the API fallback and let
        //          OpenAI refinement handle the actual target language.
        //          The raw values are non-DeepL placeholders — the TSProfile
        //          for these langs sets deepL: .english so the DeepL call
        //          always has a valid target, and refineTranslation is given
        //          the real ISO code so GPT produces the correct output.
        case hindi        = "HI_FALLBACK"
        case bengali      = "BN_FALLBACK"
        case urdu         = "UR_FALLBACK"
        case swahili      = "SW_FALLBACK"
        case persian      = "FA_FALLBACK"
        case thai         = "TH_FALLBACK"
        case catalan      = "CA_FALLBACK"
        case malay        = "MS_FALLBACK"
        case filipino     = "FIL_FALLBACK"
        case afrikaans    = "AF_FALLBACK"
        case tamil        = "TA_FALLBACK"
        
        /// Languages not natively supported by DeepL. For these, `translate()` returns
        /// the original text immediately and OpenAI refinement handles the actual output.
        var isFallbackOnly: Bool {
            rawValue.hasSuffix("_FALLBACK")
        }
    }
    
    enum TranslationStyle {
        case casual, natural, formal, slang
        
        var formalityLevel: String {
            switch self {
            case .casual, .slang: return "less"
            case .natural: return "default"
            case .formal: return "more"
            }
        }
    }
    
    func translate(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language,
        style: TranslationStyle = .natural,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Tier-2 languages aren't in DeepL — pass the original through unchanged;
        // the caller's OpenAI refinement step performs the actual translation.
        if targetLanguage.isFallbackOnly {
            NSLog("TSKBD_API: Tier-2 fallback lang \(targetLanguage.rawValue) — skipping DeepL")
            completion(.success(text))
            return
        }
        

        let urlString = "\(APIConfig.deeplBaseURL)/translate"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "TranslationService", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("DeepL-Auth-Key \(APIConfig.deeplAPIKey)", forHTTPHeaderField: "Authorization")
        
        // DeepL only accepts base language code for source (e.g. "PT" not "PT-BR")
        let sourceLang = sourceLanguage.rawValue.components(separatedBy: "-").first ?? sourceLanguage.rawValue
        
        // DeepL doesn't support formality for EN, JA, ZH targets
        let unsupportedFormalityTargets: Set<String> = ["EN", "JA", "ZH"]
        let targetLangBase = String(targetLanguage.rawValue.prefix(2))
        
        var parameters = [
            "text": text,
            "source_lang": sourceLang,
            "target_lang": targetLanguage.rawValue
        ]
        
        if !unsupportedFormalityTargets.contains(targetLangBase) {
            parameters["formality"] = style.formalityLevel
        }
        
        let bodyString = parameters.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        let task = self.urlSession.dataTask(with: request) { data, response, error in
            NSLog("%@", "TSKBD_API: URL: \(url.absoluteString)")
            NSLog("%@", "TSKBD_API: Body: \(bodyString)")
            NSLog("%@", "TSKBD_API: Response status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            
            if let error = error {
                NSLog("TSKBD_API: Request Error \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                NSLog("TSKBD_API: No Data returned")
                completion(.failure(NSError(domain: "TranslationService", code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    NSLog("%@", "TSKBD_API_JSON: \(json)")
                    if let translations = json["translations"] as? [[String: Any]],
                       let firstTranslation = translations.first,
                       let translatedText = firstTranslation["text"] as? String {
                        completion(.success(translatedText))
                    } else {
                        NSLog("TSKBD_API: Could not find 'translations[0].text' in JSON")
                        completion(.failure(NSError(domain: "TranslationService", code: -3,
                            userInfo: [NSLocalizedDescriptionKey: "Could not parse translation"])))
                    }
                } else {
                    NSLog("TSKBD_API: Root not dictionary. Raw Data: \(String(data: data, encoding: .utf8) ?? "null")")
                    completion(.failure(NSError(domain: "TranslationService", code: -3,
                        userInfo: [NSLocalizedDescriptionKey: "Could not parse translation"])))
                }
            } catch {
                NSLog("TSKBD_API: JSON Catch Error: \(error.localizedDescription). Raw Data: \(String(data: data, encoding: .utf8) ?? "null")")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
