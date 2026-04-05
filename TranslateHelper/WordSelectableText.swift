//
//  WordSelectableText.swift
//  TranslateHelper
//
//  Tap-and-hold + slide to select words/phrases from Sol's messages.
//  Selected text gets looked up via Gemini and saved to Library.
//

import SwiftUI

// MARK: - Word Selectable Text View

struct WordSelectableText: View {
    let text: String
    let contextSentence: String  // full sentence for lookup context
    let isVisible: Bool          // controls fade-in (matches existing text reveal)
    let onSave: (String, String, String) -> Void  // (phrase, meaning, notes) callback

    @State private var words: [WordItem] = []
    @State private var selectionStart: Int? = nil
    @State private var selectionEnd: Int? = nil
    @State private var isSelecting = false
    @State private var showPopup = false
    @State private var popupPhrase = ""
    @State private var isLookingUp = false
    @State private var lookupResult: (meaning: String, notes: String)? = nil
    @State private var savedAnimation = false

    private var selectedRange: ClosedRange<Int>? {
        guard let start = selectionStart, let end = selectionEnd else { return nil }
        return min(start, end)...max(start, end)
    }

    private var selectedText: String {
        guard let range = selectedRange else { return "" }
        return words[range].map(\.text).joined(separator: " ")
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Word layout using FlowLayout
            WordFlowLayout(spacing: 3, lineSpacing: 5) {
                ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                    Text(word.text)
                        .font(.custom("HelveticaNeue", size: 14))
                        .foregroundColor(.tsLabel)
                        .padding(.vertical, 1)
                        .padding(.horizontal, isWordSelected(index) ? 2 : 0)
                        .background(
                            isWordSelected(index)
                            ? RoundedRectangle(cornerRadius: 4)
                                .fill(Color.tsAccent.opacity(0.2))
                                .padding(.vertical, -1)
                            : nil
                        )
                        .id(index)
                }
            }
            .drawingGroup()
            .opacity(isVisible ? 1 : 0)
            .gesture(
                LongPressGesture(minimumDuration: 0.3)
                    .sequenced(before: DragGesture(minimumDistance: 0))
                    .onChanged { value in
                        switch value {
                        case .second(true, let drag):
                            guard let drag = drag else { return }
                            if !isSelecting {
                                // Start selection
                                isSelecting = true
                                showPopup = false
                                lookupResult = nil
                                let idx = wordIndex(at: drag.location)
                                selectionStart = idx
                                selectionEnd = idx
                            } else {
                                // Extend selection
                                selectionEnd = wordIndex(at: drag.location)
                            }
                        default:
                            break
                        }
                    }
                    .onEnded { _ in
                        isSelecting = false
                        if let range = selectedRange, !range.isEmpty || selectionStart != nil {
                            popupPhrase = selectedText
                            if !popupPhrase.isEmpty {
                                showPopup = true
                                lookupWord(popupPhrase)
                            }
                        }
                    }
            )

            // Save popup
            if showPopup && !popupPhrase.isEmpty {
                WordSavePopup(
                    phrase: popupPhrase,
                    meaning: lookupResult?.meaning,
                    notes: lookupResult?.notes,
                    isLoading: isLookingUp,
                    isSaved: savedAnimation,
                    onSave: {
                        if let result = lookupResult {
                            onSave(popupPhrase, result.meaning, result.notes)
                            withAnimation(.spring(response: 0.3)) {
                                savedAnimation = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    showPopup = false
                                    selectionStart = nil
                                    selectionEnd = nil
                                    savedAnimation = false
                                }
                            }
                        }
                    },
                    onDismiss: {
                        withAnimation(.easeOut(duration: 0.15)) {
                            showPopup = false
                            selectionStart = nil
                            selectionEnd = nil
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .zIndex(100)
            }
        }
        .onAppear {
            words = text.components(separatedBy: " ")
                .enumerated()
                .map { WordItem(index: $0.offset, text: $0.element) }
        }
        .onChange(of: text) { _, newText in
            words = newText.components(separatedBy: " ")
                .enumerated()
                .map { WordItem(index: $0.offset, text: $0.element) }
        }
    }

    private func isWordSelected(_ index: Int) -> Bool {
        guard let range = selectedRange else { return false }
        return range.contains(index)
    }

    private func wordIndex(at location: CGPoint) -> Int {
        // Approximate word index from drag position
        // Words flow left-to-right, ~8pt per character average at 14pt font
        let avgCharWidth: CGFloat = 7.5
        let lineHeight: CGFloat = 22
        let wordsPerLine = max(1, Int(UIScreen.main.bounds.width * 0.6 / (avgCharWidth * 5)))

        let row = max(0, Int(location.y / lineHeight))
        let col = max(0, Int(location.x / (avgCharWidth * 5)))
        let index = row * wordsPerLine + col

        return max(0, min(index, words.count - 1))
    }

    private func lookupWord(_ phrase: String) {
        isLookingUp = true
        let langName = LanguageManager.shared.targetLangName ?? "the language"

        let prompt = """
        The user is learning \(langName) and wants to know what this means:
        "\(phrase)"

        Context sentence: "\(contextSentence)"

        Respond with JSON only:
        {
          "meaning": "clear English meaning — 1 sentence max",
          "notes": "Brief usage note — when/how locals use this, any nuance, register (formal/casual/slang). 1-2 sentences. If it's part of an expression, explain the full expression."
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
                "maxOutputTokens": 256,
                "responseMimeType": "application/json"
            ]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            defer { DispatchQueue.main.async { isLookingUp = false } }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let candidates = json["candidates"] as? [[String: Any]],
                  let content = candidates.first?["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let text = parts.first?["text"] as? String,
                  let resultData = text.data(using: .utf8),
                  let parsed = try? JSONSerialization.jsonObject(with: resultData) as? [String: String],
                  let meaning = parsed["meaning"] else {
                NSLog("📖 [WordLookup] failed to parse response")
                return
            }

            DispatchQueue.main.async {
                lookupResult = (meaning: meaning, notes: parsed["notes"] ?? "")
            }
        }.resume()
    }
}

// MARK: - Word Item

private struct WordItem: Identifiable {
    let index: Int
    let text: String
    var id: Int { index }
}

// MARK: - Save Popup

struct WordSavePopup: View {
    let phrase: String
    let meaning: String?
    let notes: String?
    let isLoading: Bool
    let isSaved: Bool
    let onSave: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with dismiss
            HStack {
                Text(phrase)
                    .font(.custom("HelveticaNeue-Bold", size: 15))
                    .foregroundColor(.tsLabel)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.tsSecondary)
                        .padding(5)
                        .background(Circle().fill(Color.tsSecondary.opacity(0.1)))
                }
            }

            if isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Looking up...")
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(.tsSecondary)
                }
            } else if let meaning = meaning {
                Text(meaning)
                    .font(.custom("HelveticaNeue-Medium", size: 13))
                    .foregroundColor(.tsLabel)
                    .lineSpacing(2)

                if let notes = notes, !notes.isEmpty {
                    Text(notes)
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(.tsSecondary)
                        .italic()
                        .lineSpacing(2)
                }

                // Save button
                Button(action: onSave) {
                    HStack(spacing: 6) {
                        Image(systemName: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                            .font(.system(size: 12, weight: .medium))
                        Text(isSaved ? "Saved" : "Save to Library")
                            .font(.custom("HelveticaNeue-Bold", size: 12))
                    }
                    .foregroundColor(isSaved ? Color(hex: "#34C759") : .tsAccent)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(isSaved ? Color(hex: "#34C759").opacity(0.1) : Color.tsAccent.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(isSaved ? Color(hex: "#34C759").opacity(0.3) : Color.tsAccent.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .disabled(isSaved)
                .padding(.top, 4)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.tsCard)
                .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.tsAccent.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 4)
        .padding(.top, 8)
    }
}

// MARK: - Flow Layout (word wrapping)

struct WordFlowLayout: Layout {
    var spacing: CGFloat
    var lineSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() where index < subviews.count {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                                  proposal: .unspecified)
        }
    }

    private struct ArrangeResult {
        var positions: [CGPoint]
        var size: CGSize
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> ArrangeResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            lineHeight = max(lineHeight, size.height)
            x += size.width + spacing
        }

        return ArrangeResult(
            positions: positions,
            size: CGSize(width: maxWidth, height: y + lineHeight)
        )
    }
}
