//
//  WordSaveOverlay.swift
//  TranslateHelper
//
//  Long-press on Sol's message → zoomed overlay with text selection.
//  Tap a word = selects that word. Hold & drag = selects a phrase.
//  Text card pinned to top — never moves. Result card below grows as needed.
//

import SwiftUI
import UIKit

// MARK: - Zoomed Overlay

struct WordSaveOverlay: View {
    let messageText: String
    let onSave: (String, String, String) -> Void
    let onDismiss: () -> Void

    @State private var selectedText = ""
    @State private var isLookingUp = false
    @State private var lookupResult: (meaning: String, notes: String)? = nil
    @State private var isSaved = false
    @State private var appeared = false
    @State private var lookupWorkItem: DispatchWorkItem? = nil
    @State private var copiedToClipboard = false

    var body: some View {
        ZStack {
            // Light backdrop — white-ish so the blue card looks right
            Color.white.opacity(appeared ? 0.92 : 0)
                .ignoresSafeArea()
                .onTapGesture { dismissWithAnimation() }

            VStack(spacing: 0) {
                // ── TOP: Close button ─────────────────────────────
                HStack {
                    Spacer()
                    Button(action: dismissWithAnimation) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.tsSecondary.opacity(0.5))
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 12)
                }

                // ── TEXT CARD: Pinned, fixed size, never moves ───
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tap a word or drag to select")
                        .font(.custom("HelveticaNeue-Medium", size: 12))
                        .foregroundColor(.tsAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.tsAccent.opacity(0.1)))

                    SelectableTextView(
                        text: messageText,
                        selectedText: $selectedText
                    )
                    .frame(height: 160)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.tsCard)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.tsBorder, lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // ── RESULT CARD: Below text, grows as needed ─────
                VStack(alignment: .leading, spacing: 10) {
                    if selectedText.isEmpty {
                        HStack {
                            Spacer()
                            Text("Select a word or phrase above")
                                .font(.custom("HelveticaNeue", size: 13))
                                .foregroundColor(.tsAccent.opacity(0.4))
                            Spacer()
                        }
                        .padding(.vertical, 16)
                    } else {
                        // Selected phrase in bold
                        Text(selectedText)
                            .font(.custom("HelveticaNeue-Bold", size: 17))
                            .foregroundColor(.tsLabel)

                        if isLookingUp {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(0.7)
                                Text("Looking up...")
                                    .font(.custom("HelveticaNeue", size: 13))
                                    .foregroundColor(.tsSecondary)
                            }
                            .padding(.vertical, 4)
                        } else if let result = lookupResult {
                            // Meaning
                            Text(result.meaning)
                                .font(.custom("HelveticaNeue-Medium", size: 15))
                                .foregroundColor(.tsLabel)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)

                            // Usage notes
                            if !result.notes.isEmpty {
                                Text(result.notes)
                                    .font(.custom("HelveticaNeue", size: 13))
                                    .foregroundColor(.tsSecondary)
                                    .italic()
                                    .lineSpacing(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            // Save button
                            HStack {
                                Spacer()
                                Button(action: saveAndDismiss) {
                                    HStack(spacing: 6) {
                                        Image(systemName: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                                            .font(.system(size: 13, weight: .medium))
                                        Text(isSaved ? "Saved!" : "Save to Library")
                                            .font(.custom("HelveticaNeue-Bold", size: 13))
                                    }
                                    .foregroundColor(isSaved ? Color(hex: "#34C759") : .white)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule().fill(
                                            isSaved ? Color(hex: "#34C759").opacity(0.15) : Color.tsAccent
                                        )
                                    )
                                }
                                .disabled(isSaved)
                            }
                            .padding(.top, 4)
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.tsAccent.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.tsAccent.opacity(0.15), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer()
            }
            .scaleEffect(appeared ? 1.0 : 0.9)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
        }
        .onAppear {
            SoundEffect.pop.play()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                appeared = true
            }
        }
        .onChange(of: selectedText) { _, newValue in
            // Cancel any pending lookup — debounce so we don't fire on every drag movement
            lookupWorkItem?.cancel()

            if !newValue.isEmpty {
                lookupResult = nil
                isSaved = false

                let item = DispatchWorkItem {
                    lookupSelectedText()
                }
                lookupWorkItem = item
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: item)
            }
        }
    }

    private func dismissWithAnimation() {
        withAnimation(.easeOut(duration: 0.2)) {
            appeared = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }

    private func saveAndDismiss() {
        onSave(selectedText, lookupResult?.meaning ?? "", lookupResult?.notes ?? "")
        // Also copy to clipboard
        UIPasteboard.general.string = selectedText
        SoundEffect.saved.play()
        withAnimation(.spring(response: 0.3)) {
            isSaved = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismissWithAnimation()
        }
    }

    private func lookupSelectedText() {
        let phrase = selectedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard phrase.count >= 2 else { return }  // skip single characters

        isLookingUp = true
        NSLog("📖 [WordLookup] looking up: \(phrase)")
        let langName = LanguageManager.shared.targetLangName ?? "the language"

        let prompt = """
        The user is learning \(langName) and wants to know what this means:
        "\(phrase)"

        Context sentence: "\(messageText)"

        Respond with JSON only:
        {
          "meaning": "English meaning in under 10 words",
          "notes": "1 sentence: when/how locals use this, register, nuance"
        }
        """

        let apiKey = APIConfig.geminiAPIKey
        guard let url = URL(string: "\(APIConfig.geminiBaseURL)?key=\(apiKey)") else {
            isLookingUp = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10

        let body: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]],
            "generationConfig": [
                "temperature": 0.3,
                "maxOutputTokens": 1024,
                "responseMimeType": "application/json",
                "thinkingConfig": ["thinkingBudget": 0]
            ]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { DispatchQueue.main.async { isLookingUp = false } }

            if let error = error {
                NSLog("📖 [WordLookup] network error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                NSLog("📖 [WordLookup] no data returned")
                return
            }

            let rawResponse = String(data: data, encoding: .utf8) ?? "nil"

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let candidates = json["candidates"] as? [[String: Any]],
                  let content = candidates.first?["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let text = parts.first?["text"] as? String else {
                NSLog("📖 [WordLookup] failed to parse Gemini envelope: \(rawResponse.prefix(300))")
                return
            }

            // Extract JSON object from anywhere in the response — handles
            // prose, markdown fences, or raw JSON from Gemini
            guard let jsonString = extractJSON(from: text),
                  let resultData = jsonString.data(using: .utf8),
                  let parsed = try? JSONSerialization.jsonObject(with: resultData) as? [String: Any],
                  let meaning = parsed["meaning"] as? String else {
                NSLog("📖 [WordLookup] failed to parse JSON result: \(text.prefix(300))")
                return
            }

            let notes = parsed["notes"] as? String ?? ""
            NSLog("📖 [WordLookup] success: \(phrase) → \(meaning)")
            DispatchQueue.main.async {
                lookupResult = (meaning: meaning, notes: notes)
            }
        }.resume()
    }
}

// MARK: - JSON Extraction

/// Finds and extracts a JSON object from anywhere in a string.
/// Handles: raw JSON, markdown fences, prose wrapping ("Here is the JSON:").
private func extractJSON(from text: String) -> String? {
    // Find the first { and the last } — that's our JSON
    guard let start = text.firstIndex(of: "{"),
          let end = text.lastIndex(of: "}") else { return nil }
    guard start < end else { return nil }
    return String(text[start...end])
}

// MARK: - Selectable Text (tap word + drag to select phrase)

struct SelectableTextView: UIViewRepresentable {
    let text: String
    @Binding var selectedText: String

    func makeUIView(context: Context) -> NoMenuTextView {
        let tv = NoMenuTextView()
        tv.text = text
        tv.font = UIFont(name: "HelveticaNeue", size: 22)
        tv.textColor = UIColor.label
        tv.backgroundColor = .clear
        tv.isEditable = false
        tv.isSelectable = true
        tv.isScrollEnabled = true
        tv.showsVerticalScrollIndicator = false
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        tv.delegate = context.coordinator

        // Single tap → select the word under finger
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tap.numberOfTapsRequired = 1
        tv.addGestureRecognizer(tap)

        return tv
    }

    func updateUIView(_ uiView: NoMenuTextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedText: $selectedText)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var selectedText: String

        init(selectedText: Binding<String>) {
            _selectedText = selectedText
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let textView = gesture.view as? UITextView else { return }
            let point = gesture.location(in: textView)
            let layoutManager = textView.layoutManager
            let textContainer = textView.textContainer

            let adjustedPoint = CGPoint(
                x: point.x - textView.textContainerInset.left,
                y: point.y - textView.textContainerInset.top
            )

            let charIndex = layoutManager.characterIndex(
                for: adjustedPoint,
                in: textContainer,
                fractionOfDistanceBetweenInsertionPoints: nil
            )

            guard charIndex < textView.text.count else { return }

            let nsText = textView.text as NSString

            // Check if tapped on whitespace — ignore
            let tappedChar = nsText.substring(with: NSRange(location: charIndex, length: 1))
            if tappedChar.rangeOfCharacter(from: .whitespacesAndNewlines) != nil { return }

            // Find word boundaries
            let separators = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
            var start = charIndex
            var end = charIndex

            while start > 0 {
                let ch = nsText.substring(with: NSRange(location: start - 1, length: 1))
                if ch.rangeOfCharacter(from: separators) != nil { break }
                start -= 1
            }

            while end < nsText.length {
                let ch = nsText.substring(with: NSRange(location: end, length: 1))
                if ch.rangeOfCharacter(from: separators) != nil { break }
                end += 1
            }

            let range = NSRange(location: start, length: end - start)
            guard range.length > 0 else { return }

            if let textStart = textView.position(from: textView.beginningOfDocument, offset: range.location),
               let textEnd = textView.position(from: textStart, offset: range.length) {
                textView.selectedTextRange = textView.textRange(from: textStart, to: textEnd)
            }
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            guard let range = textView.selectedTextRange else {
                selectedText = ""
                return
            }
            selectedText = textView.text(in: range) ?? ""
        }
    }
}

// MARK: - UITextView subclass — no system menu

class NoMenuTextView: UITextView {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

    override func buildMenu(with builder: any UIMenuBuilder) {
        builder.remove(menu: .lookup)
        builder.remove(menu: .standardEdit)
        builder.remove(menu: .share)
        super.buildMenu(with: builder)
    }
}
