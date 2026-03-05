//  LinkPreviewFetcher.swift — extracts og:image, og:title, og:description from any URL

import Foundation
import Combine

struct LinkPreview {
    let url:         String
    let imageURL:    String?
    let title:       String?
    let description: String?
    let siteName:    String?
}

@MainActor
class LinkPreviewFetcher: ObservableObject {
    @Published var preview:   LinkPreview? = nil
    @Published var isLoading: Bool         = false
    @Published var error:     String?      = nil

    private var lastURL = ""

    func fetch(urlString: String) async {
        let clean = urlString.trimmingCharacters(in: .whitespaces)
        guard clean != lastURL, clean.hasPrefix("http"), let url = URL(string: clean) else { return }
        lastURL = clean
        isLoading = true; preview = nil; error = nil

        do {
            var req = URLRequest(url: url)
            req.setValue("Mozilla/5.0 (compatible; TalkSwitchBot/1.0)", forHTTPHeaderField: "User-Agent")
            req.timeoutInterval = 8
            let (data, _) = try await URLSession.shared.data(for: req)
            let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) ?? ""

            preview = LinkPreview(
                url:         clean,
                imageURL:    og(html, "og:image")    ?? og(html, "twitter:image"),
                title:       og(html, "og:title")    ?? titleTag(html),
                description: og(html, "og:description"),
                siteName:    og(html, "og:site_name") ?? URL(string: clean)?.host
            )
        } catch {
            self.error = "Couldn't load preview"
        }
        isLoading = false
    }

    func reset() { preview = nil; isLoading = false; error = nil; lastURL = "" }

    // MARK: - Parsers
    private func og(_ html: String, _ prop: String) -> String? {
        // <meta property="og:image" content="..." />
        let patterns = [
            "property=\"\(prop)\"[^>]+content=\"([^\"]+)\"",
            "content=\"([^\"]+)\"[^>]+property=\"\(prop)\""
        ]
        for p in patterns {
            if let r = try? NSRegularExpression(pattern: p, options: .caseInsensitive),
               let m = r.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
               let range = Range(m.range(at: 1), in: html) {
                return String(html[range]).htmlDecoded
            }
        }
        return nil
    }

    private func titleTag(_ html: String) -> String? {
        guard let start = html.range(of: "<title", options: .caseInsensitive),
              let end   = html.range(of: "</title>", options: .caseInsensitive, range: start.upperBound..<html.endIndex),
              let inner = html.range(of: ">", range: start) else { return nil }
        return String(html[inner.upperBound..<end.lowerBound]).htmlDecoded
    }
}

extension String {
    var htmlDecoded: String {
        var s = self
        let map = ["&amp;":"&","&lt;":"<","&gt;":">","&quot;":"\"","&#39;":"'","&nbsp;":" "]
        map.forEach { s = s.replacingOccurrences(of: $0.key, with: $0.value) }
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
