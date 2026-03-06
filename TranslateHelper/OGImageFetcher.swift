//  OGImageFetcher.swift
//  Wandr — scrapes og:image / twitter:image from a business website URL.
//  Results are cached in-memory so cards never re-fetch during the same session.

import Foundation

actor OGImageFetcher {
    static let shared = OGImageFetcher()

    // nil stored = "checked but nothing found" — avoids repeat fetches
    private var cache: [String: String?] = [:]

    func imageURL(for websiteHost: String) async -> String? {
        let key = websiteHost.lowercased()

        if let cached = cache[key] { return cached }

        // Build a full URL — handle hosts with or without scheme
        let fullURL: URL?
        if websiteHost.hasPrefix("http") {
            fullURL = URL(string: websiteHost)
        } else {
            fullURL = URL(string: "https://\(websiteHost)")
        }
        guard let url = fullURL else { cache[key] = nil; return nil }

        do {
            var req = URLRequest(url: url, timeoutInterval: 8)
            // Pretend to be a browser so sites don't serve empty shells
            req.setValue(
                "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15",
                forHTTPHeaderField: "User-Agent"
            )
            let (data, response) = try await URLSession.shared.data(for: req)
            // Only parse 200 responses
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                cache[key] = nil; return nil
            }
            let html = String(data: data, encoding: .utf8)
                    ?? String(data: data, encoding: .isoLatin1)
                    ?? ""

            let found = parseOGImage(from: html, base: url)
            cache[key] = found
            return found
        } catch {
            cache[key] = nil
            return nil
        }
    }

    // MARK: - HTML parsing

    private func parseOGImage(from html: String, base: URL) -> String? {
        // Try properties in priority order
        let patterns: [String] = [
            #"property=["\']og:image["\'][^>]+content=["\']([^"\'>\s]+)["\']"#,
            #"content=["\']([^"\'>\s]+)["\'][^>]+property=["\']og:image["\']"#,
            #"name=["\']twitter:image["\'][^>]+content=["\']([^"\'>\s]+)["\']"#,
            #"content=["\']([^"\'>\s]+)["\'][^>]+name=["\']twitter:image["\']"#,
        ]

        for pattern in patterns {
            guard
                let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
                let match = regex.firstMatch(
                    in: html, range: NSRange(html.startIndex..., in: html)
                ),
                let range = Range(match.range(at: 1), in: html)
            else { continue }

            let raw = String(html[range])
                .trimmingCharacters(in: .whitespacesAndNewlines)

            // Resolve relative URLs
            if raw.hasPrefix("http://") || raw.hasPrefix("https://") {
                return raw
            } else if raw.hasPrefix("//") {
                return "https:" + raw
            } else if raw.hasPrefix("/") {
                let scheme = base.scheme ?? "https"
                let host   = base.host ?? ""
                return "\(scheme)://\(host)\(raw)"
            } else if !raw.isEmpty {
                return raw
            }
        }
        return nil
    }
}
