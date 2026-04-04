//
//  LightningRoundView.swift
//  TranslateHelper
//
//  Full-screen Lightning Round experience.
//  Gradient background, card cycling, swipe-to-continue correction flow.
//

import SwiftUI
import AVFoundation

struct LightningRoundView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("talkswitch_target_lang",
                store: UserDefaults(suiteName: "group.com.jeff.translatehelper"))
    private var targetLang = LanguageManager.shared.targetLangRequired

    // MARK: - State

    @State private var phase: RoundPhase = .intro
    @State private var cards: [LightningCard] = []
    @State private var currentIndex = 0
    @State private var selectedOption: String?
    @State private var showCorrection = false
    @State private var correctionOffset: CGFloat = 0
    @State private var cardSwipeOffset: CGFloat = 0
    @State private var cardSwipeRotation: Double = 0
    @State private var isGenerating = false
    @State private var roundStartTime = Date()
    @State private var cardAppearTime = Date()

    // Voice recording
    @State private var isRecording = false
    @State private var recordingSeconds = 0
    @State private var recordingTimer: Timer?
    @State private var showVoiceResult = false
    @State private var savedToClipboard = false
    @State private var clipboardCheckmark = false
    @State private var voiceHeard: String = ""
    @State private var voiceWasCorrect: Bool = false
    @State private var pronunciationScore: Int = 0
    @State private var pronunciationFeedback: String = ""

    // Results
    @State private var correctCount = 0
    @State private var totalAnswered = 0

    // Intro animations
    @State private var boltOpacity: Double = 0
    @State private var circleBounce: CGFloat = 0.6
    @State private var rainBolts: [RainBolt] = []
    @State private var rainStarted = false

    private let ttsService = PracticeTTSService()
    private let engine = LightningRoundEngine.shared
    private let conversationService = PracticeConversationService.shared

    enum RoundPhase {
        case intro       // Lightning bolt splash
        case loading     // Generating cards
        case active      // Cards cycling
        case summary     // End-of-round results
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Gradient background
            VoiceKeyboardBackground()
                .ignoresSafeArea()

            switch phase {
            case .intro:
                introView
            case .loading:
                loadingView
            case .active:
                if currentIndex < cards.count {
                    activeCardView
                } else {
                    // Shouldn't happen, but safety
                    summaryView
                }
            case .summary:
                summaryView
            }
        }
        .statusBarHidden(true)
        .onAppear {
            // Trigger pre-gen as soon as the intro screen appears.
            // Single API call — no seeding prerequisite. If app launch pre-gen
            // already completed, this is a no-op (cache exists).
            if phase == .intro && cards.isEmpty {
                DispatchQueue.global(qos: .userInitiated).async {
                    LightningRoundEngine.preGenerate(language: self.targetLang)
                }
            }
        }
    }

    // MARK: - Intro

    private var introView: some View {
        ZStack {
            // Raining lightning bolts — uniform diagonal fall
            ForEach(rainBolts) { bolt in
                Image(systemName: "bolt.fill")
                    .font(.system(size: bolt.size))
                    .foregroundColor(Color(hex: "#FFD60A").opacity(bolt.opacity))
                    .position(x: bolt.x, y: bolt.y)
            }

            VStack(spacing: 24) {
                Spacer()

                // Lightning bolt circle — matches Let's Go button style, glow outside only
                ZStack {
                    // Frosted glass circle (same treatment as the button)
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        // Yellow glow on the outside edge
                        .shadow(color: Color(hex: "#FFD60A").opacity(0.4), radius: 16)
                        .shadow(color: Color(hex: "#FFD60A").opacity(0.15), radius: 32)

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Color(hex: "#FFD60A"))
                        .opacity(boltOpacity)
                        .shadow(color: Color(hex: "#FFD60A").opacity(0.5), radius: 6)
                }
                .scaleEffect(circleBounce)

                Text("Lightning Round")
                    .font(.custom("HelveticaNeue-Bold", size: 28))
                    .foregroundColor(.white)


                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        phase = .loading
                    }
                    generateRound()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#FFD60A"))
                            .shadow(color: Color(hex: "#FFD60A").opacity(0.5), radius: 4)
                        Text("Let's Go")
                            .font(.custom("HelveticaNeue-Bold", size: 17))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 48)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                    )
                }

                Button { dismiss() } label: {
                    Text("Not now")
                        .font(.custom("HelveticaNeue", size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .onAppear { startIntroAnimations() }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView()
                .tint(.white)
                .scaleEffect(1.2)
            Text("Building your round...")
                .font(.custom("HelveticaNeue", size: 15))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
        }
    }

    // MARK: - Active Card

    private var activeCardView: some View {
        let card = cards[currentIndex]

        return VStack(spacing: 0) {
            // Top bar: progress + close
            HStack {
                HStack(spacing: 6) {
                    ForEach(0..<cards.count, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(dotColor(for: i))
                            .frame(width: i == currentIndex ? 20 : 8, height: 4)
                            .animation(.easeInOut(duration: 0.2), value: currentIndex)
                    }
                }

                Spacer()

                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer().frame(height: 32)

            // Frosted glass card container
            VStack(spacing: 0) {
                // Card type header
                HStack {
                    Text(card.type.displayName.uppercased())
                        .font(.custom("HelveticaNeue-Bold", size: 10))
                        .foregroundColor(.black.opacity(0.4))
                        .kerning(1.0)
                    Spacer()
                    Text("\(currentIndex + 1) of \(cards.count)")
                        .font(.custom("HelveticaNeue", size: 11))
                        .foregroundColor(.black.opacity(0.4))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                // Prompt — split into instruction + content (white text on glass)
                promptBlock(card: card)
                    .padding(.bottom, 20)

                // Card-type-specific content
                if card.type.isVoiceCard && !showCorrection {
                    voiceInputArea(card: card)
                        .padding(.bottom, 24)
                } else if card.type.isListenCard && card.type != .echo && !showCorrection {
                    listenArea(card: card)
                        .padding(.bottom, 24)
                } else if !showCorrection {
                    optionsArea(card: card)
                        .padding(.bottom, 24)
                }

                // Correction section (inline, below the options)
                if showCorrection {
                    correctionCard(card: card)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .padding(.bottom, 20)
                }

                // Voice result (inline, below mic)
                if showVoiceResult && !showCorrection && card.type.isVoiceCard {
                    // Already shown inside voiceInputArea
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 16, y: 4)
            )
            .padding(.horizontal, 16)
            // Whole-card swipe — same rotation style as keyboard/flashcards
            .offset(x: cardSwipeOffset)
            .rotationEffect(.degrees(cardSwipeRotation), anchor: .bottom)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width > 0 {
                            cardSwipeOffset = gesture.translation.width
                            cardSwipeRotation = Double(gesture.translation.width / 20)
                        }
                    }
                    .onEnded { gesture in
                        if gesture.translation.width > 90 {
                            // Fly off to the right
                            withAnimation(.easeOut(duration: 0.25)) {
                                cardSwipeOffset = 500
                                cardSwipeRotation = 15
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                cardSwipeOffset = 0
                                cardSwipeRotation = 0
                                advanceToNext()
                            }
                        } else {
                            // Snap back
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                cardSwipeOffset = 0
                                cardSwipeRotation = 0
                            }
                        }
                    }
            )

            Spacer()
        }
    }

    // MARK: - Prompt Block

    /// Splits the prompt into context (dialogue/statement) + question, displayed on separate lines.
    private func promptBlock(card: LightningCard) -> some View {
        let parts = splitPrompt(card.prompt)

        return VStack(alignment: .leading, spacing: 14) {
            // Context / dialogue — for slang cards, underline the slang term
            if card.type == .slangInContext {
                Text(underlineTermInText(parts.context, card: card))
                    .font(.custom("HelveticaNeue-Medium", size: 17))
                    .foregroundColor(.black)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(parts.context)
                    .font(.custom("HelveticaNeue-Medium", size: 17))
                    .foregroundColor(.black)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Question — regular weight, softer
            if let question = parts.question {
                Text(question)
                    .font(.custom("HelveticaNeue", size: 15))
                    .foregroundColor(.black.opacity(0.5))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 20)
    }

    /// Splits prompt into context (statement/quote at top) + question (below).
    /// Ensures the foreign language phrase is always visually separated from the English question.
    /// Underlines the slang term (quoted text, targetWord, or correctAnswer) in the prompt
    private func underlineTermInText(_ text: String, card: LightningCard) -> AttributedString {
        var result = AttributedString(text)
        let terms = [card.targetWord, card.correctAnswer].compactMap { $0 }.filter { !$0.isEmpty }

        // Try quoted terms first
        let quoteChars: [Character] = ["'", "'", "'", "\"", "\u{201C}", "\u{201D}"]
        var i = text.startIndex
        while i < text.endIndex {
            if quoteChars.contains(text[i]) {
                let searchStart = text.index(after: i)
                if searchStart < text.endIndex,
                   let closeIdx = text[searchStart...].firstIndex(where: { quoteChars.contains($0) }) {
                    let nsRange = NSRange(i...closeIdx, in: text)
                    if let attrRange = Range(nsRange, in: result) {
                        result[attrRange].underlineStyle = .single
                        return result
                    }
                }
            }
            i = text.index(after: i)
        }

        // Fallback: underline targetWord or correctAnswer
        for term in terms {
            if let range = text.range(of: term, options: .caseInsensitive) {
                let nsRange = NSRange(range, in: text)
                if let attrRange = Range(nsRange, in: result) {
                    result[attrRange].underlineStyle = .single
                    return result
                }
            }
        }
        return result
    }

    /// Bolds the slang term inside the explanation text
    private func boldTermInText(_ text: String, card: LightningCard) -> AttributedString {
        var result = AttributedString(text)
        let terms = [card.targetWord, card.correctAnswer].compactMap { $0 }.filter { !$0.isEmpty }
        for term in terms {
            if let range = text.range(of: term, options: .caseInsensitive) {
                let nsRange = NSRange(range, in: text)
                if let attrRange = Range(nsRange, in: result) {
                    result[attrRange].font = .custom("HelveticaNeue-Bold", size: 13)
                    result[attrRange].foregroundColor = .black
                    return result
                }
            }
        }
        return result
    }

    private func splitPrompt(_ prompt: String) -> (context: String, question: String?) {
        // 1. Explicit newline split
        if prompt.contains("\n") {
            let lines = prompt.split(separator: "\n", maxSplits: 1)
            if lines.count == 2 {
                return (String(lines[0]).trimmingCharacters(in: .whitespacesAndNewlines),
                        String(lines[1]).trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }

        // 2. Quoted text — split before or after quotes
        //    e.g., "Ele muita bomba de ouvido" What does this mean?
        let quotePatterns: [Character] = ["\"", "'", "\u{201C}", "\u{201D}", "\u{2018}", "\u{2019}"]
        if let firstQuote = prompt.firstIndex(where: { quotePatterns.contains($0) }),
           let lastQuote = prompt.lastIndex(where: { quotePatterns.contains($0) }),
           firstQuote != lastQuote {
            let quoted = String(prompt[firstQuote...lastQuote])
            let beforeQuote = String(prompt[prompt.startIndex..<firstQuote]).trimmingCharacters(in: .whitespacesAndNewlines)
            let afterQuote = String(prompt[prompt.index(after: lastQuote)...]).trimmingCharacters(in: .whitespacesAndNewlines)

            if !afterQuote.isEmpty {
                // Quote first, question after: "Ele falou" What does this mean?
                return (quoted, afterQuote)
            } else if !beforeQuote.isEmpty {
                // Question first, quote after: What does "falou" mean?
                return (quoted, beforeQuote)
            }
        }

        // 3. Common question phrases — split at the question boundary
        let questionStarters = [
            "What does", "What do", "What is", "What are",
            "Which", "How do you", "How would",
            "Is this", "Is the", "Does this",
            "True or false", "Choose the",
        ]
        for starter in questionStarters {
            if let range = prompt.range(of: starter, options: .caseInsensitive) {
                let before = String(prompt[prompt.startIndex..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                let question = String(prompt[range.lowerBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !before.isEmpty && before.count > 3 {
                    return (before, question)
                }
            }
        }

        // 4. Question mark split — statement before, question after
        if let qRange = prompt.range(of: "? ") {
            let before = String(prompt[prompt.startIndex...qRange.lowerBound])
            let after = String(prompt[qRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !after.isEmpty {
                return (after, before + "?")
            }
        }

        // 5. Colon split
        if let colonRange = prompt.range(of: ": ") {
            let instruction = String(prompt[prompt.startIndex..<colonRange.lowerBound])
            let content = String(prompt[colonRange.upperBound...])
            if !content.isEmpty {
                return (content, instruction)
            }
        }

        return (prompt, nil)
    }

    // MARK: - Options (Tap Cards)

    private let optionLetters = ["A", "B", "C", "D"]

    private func optionsArea(card: LightningCard) -> some View {
        VStack(spacing: 12) {
            if let options = card.options {
                ForEach(Array(options.enumerated()), id: \.element) { index, option in
                    Button {
                        handleAnswer(option, card: card)
                    } label: {
                        HStack(spacing: 12) {
                            // Letter label — frosted circle
                            Text(index < optionLetters.count ? optionLetters[index] : "\(index + 1)")
                                .font(.custom("HelveticaNeue-Bold", size: 13))
                                .foregroundColor(optionLetterColorGlass(option, card: card))
                                .frame(width: 28, height: 28)
                                .background(
                                    Circle()
                                        .fill(optionLetterBgGlass(option, card: card))
                                )

                            Text(option)
                                .font(.custom("HelveticaNeue", size: 15))
                                .foregroundColor(optionTextColor(option, card: card))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer()

                            if selectedOption == option {
                                Image(systemName: answersMatch(option, card.correctAnswer) ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(answersMatch(option, card.correctAnswer) ? Color(hex: "#34C759") : Color(hex: "#FF3B30"))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                        )
                    }
                    .disabled(selectedOption != nil)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func optionLetterColor(_ option: String, card: LightningCard) -> Color {
        guard selectedOption != nil else { return .tsAccent }
        if answersMatch(option, card.correctAnswer) { return Color(hex: "#34C759") }
        if option == selectedOption { return Color(hex: "#FF3B30") }
        return .tsAccent.opacity(0.3)
    }

    private func optionLetterBg(_ option: String, card: LightningCard) -> Color {
        guard selectedOption != nil else { return Color.tsAccent.opacity(0.1) }
        if answersMatch(option, card.correctAnswer) { return Color(hex: "#34C759").opacity(0.12) }
        if option == selectedOption && option != card.correctAnswer { return Color(hex: "#FF3B30").opacity(0.12) }
        return Color.tsAccent.opacity(0.05)
    }

    private func optionLetterColorGlass(_ option: String, card: LightningCard) -> Color {
        optionLetterColor(option, card: card)
    }

    private func optionLetterBgGlass(_ option: String, card: LightningCard) -> Color {
        optionLetterBg(option, card: card)
    }

    // MARK: - Voice Input Area

    private func voiceInputArea(card: LightningCard) -> some View {
        VStack(spacing: 16) {
            if card.type == .echo {
                Button {
                    if let audioText = card.audioText {
                        ttsService.speak(text: audioText, language: targetLang) {}
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 14))
                        Text("Listen first")
                            .font(.custom("HelveticaNeue-Medium", size: 14))
                    }
                    .foregroundColor(.tsAccent)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.tsAccent.opacity(0.08))
                    )
                }
            }

            Button {
                if isRecording {
                    stopRecordingAndScore(card: card)
                } else {
                    startRecording()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(isRecording ? Color(hex: "#FF3B30") : Color.tsAccent)
                        .frame(width: 64, height: 64)
                        .shadow(color: isRecording ? Color(hex: "#FF3B30").opacity(0.3) : Color.tsAccent.opacity(0.3), radius: 10)

                    if isRecording {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: 22, height: 22)
                    } else {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
            }

            Text(isRecording ? formatTime(recordingSeconds) : "Tap to record")
                .font(.custom(isRecording ? "HelveticaNeue-Bold" : "HelveticaNeue", size: 13))
                .foregroundColor(.black.opacity(0.4))

            // Voice result with pronunciation score — white card
            if showVoiceResult {
                VStack(alignment: .leading, spacing: 10) {
                    // Score + status
                    HStack(spacing: 8) {
                        Image(systemName: voiceWasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(voiceWasCorrect ? Color(hex: "#34C759") : Color(hex: "#FF3B30"))
                            .font(.system(size: 20))
                        Text(voiceWasCorrect ? "Correct" : "Not quite")
                            .font(.custom("HelveticaNeue-Medium", size: 14))
                            .foregroundColor(voiceWasCorrect ? Color(hex: "#34C759") : Color(hex: "#FF3B30"))
                        Spacer()
                        Text("Pronunciation: \(pronunciationScore)%")
                            .font(.custom("HelveticaNeue-Bold", size: 13))
                            .foregroundColor(pronunciationScore >= 75 ? Color(hex: "#34C759") : pronunciationScore >= 50 ? Color(hex: "#FF9500") : Color(hex: "#FF3B30"))
                    }

                    // What you said
                    Text("\"\(voiceHeard)\"")
                        .font(.custom("HelveticaNeue-Medium", size: 15))
                        .foregroundColor(.tsLabel)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Pronunciation feedback
                    if !pronunciationFeedback.isEmpty {
                        Text(pronunciationFeedback)
                            .font(.custom("HelveticaNeue", size: 12))
                            .foregroundColor(.tsSecondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if !voiceWasCorrect {
                        HStack(spacing: 4) {
                            Text("Expected:")
                                .font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(.tsSecondary)
                            Text("\"\(card.audioText ?? card.correctAnswer)\"")
                                .font(.custom("HelveticaNeue-Medium", size: 13))
                                .foregroundColor(Color(hex: "#34C759"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
                )
                .padding(.horizontal, 16)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
    }

    // MARK: - Listen Area

    private func listenArea(card: LightningCard) -> some View {
        VStack(spacing: 16) {
            Button {
                if let audioText = card.audioText {
                    ttsService.speak(text: audioText, language: targetLang) {}
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.tsAccent.opacity(0.08))
                        .frame(width: 56, height: 56)

                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.tsAccent)
                }
            }

            Text("Tap to replay")
                .font(.custom("HelveticaNeue", size: 11))
                .foregroundColor(.black.opacity(0.4))

            if let options = card.options {
                VStack(spacing: 12) {
                    ForEach(Array(options.enumerated()), id: \.element) { index, option in
                        Button {
                            handleAnswer(option, card: card)
                        } label: {
                            HStack(spacing: 12) {
                                Text(index < optionLetters.count ? optionLetters[index] : "\(index + 1)")
                                    .font(.custom("HelveticaNeue-Bold", size: 13))
                                    .foregroundColor(optionLetterColorGlass(option, card: card))
                                    .frame(width: 28, height: 28)
                                    .background(Circle().fill(optionLetterBgGlass(option, card: card)))
                                Text(option)
                                    .font(.custom("HelveticaNeue", size: 15))
                                    .foregroundColor(optionTextColor(option, card: card))
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                                if selectedOption == option {
                                    Image(systemName: answersMatch(option, card.correctAnswer) ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(answersMatch(option, card.correctAnswer) ? Color(hex: "#34C759") : Color(hex: "#FF3B30"))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(optionBorderColor(option, card: card), lineWidth: 1)
                            )
                        }
                        .disabled(selectedOption != nil)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            if let audioText = card.audioText {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ttsService.speak(text: audioText, language: targetLang) {}
                }
            }
        }
    }

    // MARK: - Correction Card

    private func correctionCard(card: LightningCard) -> some View {
        let isRight = card.isCorrect == true
        let accentColor = isRight ? Color(hex: "#34C759") : Color(hex: "#FF3B30")

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: isRight ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(accentColor)
                Text(isRight ? "Correct!" : "Not quite")
                    .font(.custom("HelveticaNeue-Bold", size: 15))
                    .foregroundColor(accentColor)
                Spacer()
            }

            if !isRight {
                Divider()

                HStack(spacing: 6) {
                    Text("Answer:")
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.black.opacity(0.4))
                    Text(card.correctAnswer)
                        .font(.custom("HelveticaNeue-Bold", size: 13))
                        .foregroundColor(.black)
                }

                // Explanation — bold the slang term if slang card
                if card.type == .slangInContext {
                    Text(boldTermInText("💡 \(card.explanation)", card: card))
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.black.opacity(0.5))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("💡 \(card.explanation)")
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.black.opacity(0.5))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Slang cards — clipboard → checkmark animation
                if card.type == .slangInContext && savedToClipboard {
                    if clipboardCheckmark {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#34C759"))
                            Text("Saved")
                                .font(.custom("HelveticaNeue-Medium", size: 12))
                                .foregroundColor(Color(hex: "#34C759"))
                        }
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    } else {
                        HStack(spacing: 6) {
                            Text("📋")
                                .font(.system(size: 14))
                            Text("Added to your clipboard")
                                .font(.custom("HelveticaNeue-Medium", size: 12))
                                .foregroundColor(.tsAccent)
                        }
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .move(edge: .bottom)).combined(with: .scale(scale: 0.8)))
                    }
                }
            }

            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Text("Swipe to continue")
                        .font(.custom("HelveticaNeue", size: 11))
                        .foregroundColor(.black.opacity(0.25))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10))
                        .foregroundColor(.black.opacity(0.25))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(accentColor.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(accentColor.opacity(0.25), lineWidth: 0.5)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Summary

    private var summaryView: some View {
        ZStack {
            // Gradient background — same as intro
            VoiceKeyboardBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 50)

                // Lightning bolt for perfect rounds
                if correctCount == totalAnswered && totalAnswered > 0 {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color(hex: "#FFD60A"))
                        .shadow(color: Color(hex: "#FFD60A").opacity(0.6), radius: 12)
                        .padding(.bottom, 12)
                }

                // Score circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 8)
                        .frame(width: 110, height: 110)

                    Circle()
                        .trim(from: 0, to: CGFloat(correctCount) / max(CGFloat(totalAnswered), 1))
                        .stroke(
                            scoreColor,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 110, height: 110)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(correctCount)/\(totalAnswered)")
                            .font(.custom("HelveticaNeue-Bold", size: 28))
                            .foregroundColor(.white)
                        Text("correct")
                            .font(.custom("HelveticaNeue", size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.bottom, 16)

                // Result message
                Text(summaryMessage)
                    .font(.custom("HelveticaNeue-Bold", size: 20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)

                // Focus areas (what they got wrong)
                if !focusAreas.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(randomFocusPhrase)
                            .font(.custom("HelveticaNeue-Medium", size: 14))
                            .foregroundColor(.white.opacity(0.7))

                        ForEach(focusAreas, id: \.category) { area in
                            HStack(spacing: 10) {
                                Text(area.icon)
                                    .font(.system(size: 16))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(area.category)
                                        .font(.custom("HelveticaNeue-Medium", size: 14))
                                        .foregroundColor(.white)
                                    if let example = area.example {
                                        Text(example)
                                            .font(.custom("HelveticaNeue", size: 12))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.08))
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                } else {
                    // Perfect round message
                    Text(randomPerfectPhrase)
                        .font(.custom("HelveticaNeue", size: 15))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 24)
                }

                Spacer()

                // Go Again button
                Button {
                    resetRound()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        phase = .loading
                    }
                    generateRound()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#FFD60A"))
                        Text("Go Again")
                            .font(.custom("HelveticaNeue-Bold", size: 17))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 24)

                Button { dismiss() } label: {
                    Text("Done")
                        .font(.custom("HelveticaNeue", size: 14))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.top, 12)
                .padding(.bottom, 48)
            }
        }
    }

    // MARK: - Summary Data

    private struct FocusArea {
        let category: String
        let icon: String
        let example: String?
    }

    /// Extract focus areas from wrong answers
    private var focusAreas: [FocusArea] {
        let wrongCards = cards.filter { $0.isCorrect == false }
        var seen = Set<String>()
        var areas: [FocusArea] = []

        for card in wrongCards {
            let cat: String
            let icon: String
            switch card.type {
            case .speedConjugation: cat = "Conjugation"; icon = "🔄"
            case .thisOrThat: cat = "Gender"; icon = "⚥"
            case .minimalPairs, .echo, .speakIt: cat = "Pronunciation"; icon = "🗣"
            case .slangInContext: cat = "Vocabulary"; icon = "📖"
            case .quickPick, .trueOrFalse: cat = "Grammar"; icon = "📐"
            // contextualResponse removed
            case .whatDidSheSay: cat = "Listening"; icon = "👂"
            }

            if !seen.contains(cat) {
                seen.insert(cat)
                let example = card.correctAnswer.isEmpty ? nil : card.correctAnswer
                areas.append(FocusArea(category: cat, icon: icon, example: example))
            }
        }
        return areas
    }

    private var randomFocusPhrase: String {
        let phrases = [
            "Still working on:",
            "Keep an eye on:",
            "Almost there with:",
            "One more round should lock in:",
            "Getting closer on:",
            "Just needs a little more practice:",
            "You're right on the edge of mastering:",
            "So close with:",
            "Let's keep sharpening:",
            "Worth another look:",
            "Don't let this one slip:",
            "This one's almost yours:",
            "Stay on this:",
            "Keep chipping away at:",
            "Tricky one to watch:",
            "This one keeps sneaking in:",
            "Not quite locked in yet:",
            "Your brain's still cooking on:",
            "Give this one more reps:",
        ]
        return phrases.randomElement() ?? "Keep working on:"
    }

    private var randomPerfectPhrase: String {
        let phrases = [
            "Nothing got past you this time.",
            "Clean sweep.",
            "Every single one. Respect.",
            "You didn't miss a beat.",
            "Flawless round — keep that energy.",
            "Zero mistakes. That's the standard now.",
            "Locked in. All of it.",
        ]
        return phrases.randomElement() ?? "Perfect round."
    }

    // MARK: - Logic

    private func generateRound() {
        isGenerating = true
        NSLog("⚡ [LightningRound] generateRound called — checking caches")

        // 1. Check in-memory cache first (fastest)
        if let cached = engine.cachedCards, !cached.isEmpty,
           cached.first?.language == targetLang {
            NSLog("⚡ [LightningRound] HIT: memory cache (\(cached.count) cards)")
            engine.cachedCards = nil
            engine.clearDiskCache()
            self.cards = cached
            startRound()
            preGenerateNextRound()
            return
        } else if engine.cachedCards != nil {
            engine.cachedCards = nil
        }

        // 2. Check disk cache (survives app close — still instant, no API call)
        if let diskCached = engine.loadCacheFromDisk(language: targetLang) {
            NSLog("⚡ [LightningRound] HIT: disk cache (\(diskCached.count) cards)")
            engine.clearDiskCache()
            self.cards = diskCached
            startRound()
            preGenerateNextRound()
            return
        }

        // 3. Check if pre-gen is in flight — wait for it instead of making a duplicate call
        NSLog("⚡ [LightningRound] MISS: no cache — checking if pre-gen is in flight")
        engine.waitForPreGen { [self] waitedCards in
            if let cards = waitedCards, !cards.isEmpty,
               cards.first?.language == targetLang {
                NSLog("⚡ [LightningRound] HIT: waited for in-flight pre-gen (\(cards.count) cards)")
                self.engine.cachedCards = nil
                self.engine.clearDiskCache()
                self.cards = cards
                self.startRound()
                self.preGenerateNextRound()
                return
            }
            NSLog("⚡ [LightningRound] MISS: no in-flight pre-gen — generating fresh")
            self.generateRoundFresh()
        }
    }

    /// Generate a round from scratch (no cache available)
    /// Generate a round from scratch using the unified single-call approach
    private func generateRoundFresh() {
        NSLog("⚡ [LightningRound] generating fresh round (single API call)")
        let langName = LanguageManager.languageName(for: targetLang)
        let existingMistakes = engine.selectMistakesForRound(count: 10, language: targetLang)
        let cardTypes = engine.buildRoundCardTypes()
        let prompt = engine.buildUnifiedPrompt(
            cardTypes: cardTypes,
            existingMistakes: existingMistakes,
            language: targetLang,
            langName: langName
        )
        generateCardsViaGPT(prompt: prompt, cardTypes: cardTypes, mistakes: existingMistakes)
    }

    /// Pre-generates the next round in the background so it's ready instantly
    private func preGenerateNextRound() {
        let lang = targetLang
        DispatchQueue.global(qos: .background).async {
            LightningRoundEngine.preGenerate(language: lang)
        }
    }

    private func generateCardsViaGPT(
        prompt: String,
        cardTypes: [LightningCardType],
        mistakes: [MistakeEntry]
    ) {
        let apiKey = APIConfig.anthropicAPIKey
        guard let url = URL(string: "\(APIConfig.anthropicBaseURL)/messages") else { return }

        let body: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 2000,
            "messages": [
                ["role": "user", "content": "You generate quiz cards for language learners. Respond ONLY with valid JSON.\n\n\(prompt)"],
            ],
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 30

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                self.isGenerating = false

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let contentArray = json["content"] as? [[String: Any]],
                      let firstContent = contentArray.first,
                      let content = firstContent["text"] as? String
                else {
                    self.cards = self.generateFallbackCards(types: cardTypes, mistakes: mistakes)
                    self.startRound()
                    return
                }

                // Extract JSON from Claude's response
                let jsonString: String
                if let start = content.range(of: "["), let end = content.range(of: "]", options: .backwards) {
                    jsonString = String(content[start.lowerBound...end.upperBound])
                } else if let start = content.range(of: "{"), let end = content.range(of: "}", options: .backwards) {
                    jsonString = String(content[start.lowerBound...end.upperBound])
                } else {
                    jsonString = content
                }

                guard let contentData = jsonString.data(using: .utf8),
                      let rawParsed = try? JSONSerialization.jsonObject(with: contentData)
                else {
                    self.cards = self.generateFallbackCards(types: cardTypes, mistakes: mistakes)
                    self.startRound()
                    return
                }

                let parsed: [String: Any]
                if let dict = rawParsed as? [String: Any] {
                    parsed = dict
                } else if let arr = rawParsed as? [[String: Any]] {
                    parsed = ["cards": arr]
                } else {
                    self.cards = self.generateFallbackCards(types: cardTypes, mistakes: mistakes)
                    self.startRound()
                    return
                }

                // Parse cards from GPT response — handle both {cards: [...]} and raw [...]
                let cardsArray: [[String: Any]]
                if let arr = parsed["cards"] as? [[String: Any]] {
                    cardsArray = arr
                } else if let directArray = try? JSONSerialization.jsonObject(with: contentData) as? [[String: Any]] {
                    cardsArray = directArray
                } else {
                    // Try any array-valued key
                    cardsArray = parsed.values.compactMap { $0 as? [[String: Any]] }.first ?? []
                }

                var generatedCards: [LightningCard] = []
                for (i, cardJSON) in cardsArray.enumerated() where i < cardTypes.count {
                    let type = cardTypes[i]
                    let mistakeIdx = (cardJSON["mistake_index"] as? Int) ?? (i % mistakes.count)
                    let mistake = mistakes[min(mistakeIdx, mistakes.count - 1)]

                    // Filter out dash/empty/duplicate options from GPT
                    let rawOptions = cardJSON["options"] as? [String]
                    var seenOpts = Set<String>()
                    let cleanedOptions: [String]? = rawOptions?.filter { opt in
                        let trimmed = opt.trimmingCharacters(in: .whitespacesAndNewlines)
                        let key = trimmed.lowercased()
                        guard trimmed.count >= 2,
                              trimmed != "—", trimmed != "-", trimmed != "–",
                              !seenOpts.contains(key)
                        else { return false }
                        seenOpts.insert(key)
                        return true
                    }

                    let rawPrompt = cardJSON["prompt"] as? String ?? ""
                    let rawAudioText = cardJSON["audio_text"] as? String
                    let rawCorrectAnswer = cardJSON["correct_answer"] as? String ?? mistake.correctForm

                    // Validate voice cards — must have audio_text and a real prompt
                    let audioText: String?
                    let prompt: String
                    if type.isVoiceCard {
                        // If audio_text is missing/empty, use correctForm from the mistake
                        audioText = (rawAudioText?.isEmpty == false) ? rawAudioText : mistake.correctForm
                        // If prompt is empty or generic, provide a proper one
                        prompt = rawPrompt.isEmpty ? (type == .echo ? "Listen and repeat:" : "Say this out loud:") : rawPrompt
                    } else {
                        audioText = rawAudioText
                        prompt = rawPrompt.isEmpty ? "What's the correct form?" : rawPrompt
                    }

                    let card = LightningCard(
                        type: type,
                        mistakeId: mistake.id,
                        language: self.targetLang,
                        prompt: prompt,
                        correctAnswer: rawCorrectAnswer,
                        options: cleanedOptions,
                        explanation: cardJSON["explanation"] as? String ?? mistake.explanation,
                        audioText: audioText,
                        targetWord: cardJSON["target_word"] as? String
                    )
                    generatedCards.append(card)
                }

                // Fill any missing cards with fallback
                while generatedCards.count < cardTypes.count {
                    let i = generatedCards.count
                    let fallback = self.generateFallbackCard(
                        type: cardTypes[i],
                        mistake: mistakes[i % mistakes.count]
                    )
                    generatedCards.append(fallback)
                }

                // Validate — discard bad cards. NEVER fall back to unvalidated.
                let validated = self.engine.validateCards(generatedCards, language: self.targetLang)
                if validated.isEmpty {
                    NSLog("⚡ [LightningRound] ALL cards failed validation — using fallback cards")
                    // Build fallback cards from the mistake data we already have
                    let fallbacks = cardTypes.enumerated().map { (i, type) in
                        self.generateFallbackCard(type: type, mistake: mistakes[i % mistakes.count])
                    }
                    self.cards = fallbacks
                } else {
                    self.cards = validated
                }
                self.startRound()
            }
        }.resume()
    }

    private func startRound() {
        roundStartTime = Date()
        cardAppearTime = Date()
        currentIndex = 0
        withAnimation(.easeInOut(duration: 0.3)) {
            phase = .active
        }
    }

    /// Normalized comparison — handles case, whitespace, and accent differences from GPT
    private func answersMatch(_ a: String, _ b: String) -> Bool {
        a.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ==
        b.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func handleAnswer(_ answer: String, card: LightningCard) {
        guard selectedOption == nil else { return } // Already answered
        selectedOption = answer

        let isCorrect = answersMatch(answer, card.correctAnswer)
        cards[currentIndex].userAnswer = answer
        cards[currentIndex].isCorrect = isCorrect
        cards[currentIndex].answeredAt = Date()

        totalAnswered += 1
        if isCorrect { correctCount += 1 }

        // Play sound + haptic (shared with flashcards)
        if isCorrect {
            SoundEffect.correct.play()
        } else {
            SoundEffect.incorrect.play()
        }

        if isCorrect {
            // Green flash, auto-advance after brief pause
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                advanceToNext()
            }
        } else {
            // Show correction card
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                showCorrection = true
            }

            // Auto-save slang cards — delayed so correction card appears first
            if card.type == .slangInContext {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    saveSlangToClipboard(card: card)
                }
            }
        }
    }

    private func advanceToNext() {
        withAnimation(.easeInOut(duration: 0.25)) {
            showCorrection = false
            showVoiceResult = false
            selectedOption = nil
            correctionOffset = 0
            cardSwipeOffset = 0
            cardSwipeRotation = 0
            savedToClipboard = false
            clipboardCheckmark = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if currentIndex + 1 < cards.count {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentIndex += 1
                    cardAppearTime = Date()
                }
            } else {
                // Round complete — process results
                engine.processResults(cards)
                engine.recordUsedPrompts(cards)
                withAnimation(.easeInOut(duration: 0.4)) {
                    phase = .summary
                }
                // Pre-generate next round in background
                preGenerateNextRound()
            }
        }
    }

    private func resetRound() {
        cards = []
        currentIndex = 0
        selectedOption = nil
        showCorrection = false
        showVoiceResult = false
        voiceHeard = ""
        voiceWasCorrect = false
        correctCount = 0
        totalAnswered = 0
    }

    // MARK: - Voice Recording

    private func startRecording() {
        isRecording = true
        recordingSeconds = 0
        conversationService.startRecording()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            recordingSeconds += 1
            if recordingSeconds >= 10 {
                stopRecordingAndScore(card: cards[currentIndex])
            }
        }
    }

    private func stopRecordingAndScore(card: LightningCard) {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        conversationService.stopRecording()

        conversationService.transcribe(language: targetLang) { transcription in
            guard let text = transcription, !text.isEmpty else {
                // Transcription failed — treat as incorrect
                self.handleVoiceResult(heard: "...", card: card)
                return
            }
            self.handleVoiceResult(heard: text, card: card)
        }
    }

    private func handleVoiceResult(heard: String, card: LightningCard) {
        let expectedRaw = (card.audioText ?? card.correctAnswer)
        let expected = expectedRaw.lowercased()
            .trimmingCharacters(in: .punctuationCharacters)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let actual = heard.lowercased()
            .trimmingCharacters(in: .punctuationCharacters)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Word match
        let expectedWords = expected.split(separator: " ").map(String.init)
        let actualWords = actual.split(separator: " ").map(String.init)
        let expectedSet = Set(expectedWords)
        let actualSet = Set(actualWords)
        let intersection = expectedSet.intersection(actualSet)
        let wordMatch = expectedSet.isEmpty ? 0.0 : Double(intersection.count) / Double(expectedSet.count)

        // Levenshtein similarity for pronunciation accuracy
        let levenshteinScore = Self.levenshteinSimilarity(expected, actual)

        // Combined score: 50% word match + 50% Levenshtein
        let score = Int((wordMatch * 50) + (levenshteinScore * 50))
        let isCorrect = wordMatch >= 0.6

        // Pronunciation feedback
        let feedback: String
        if score >= 90 {
            feedback = "Excellent pronunciation!"
        } else if score >= 75 {
            feedback = "Good — clearly understood."
        } else if score >= 60 {
            let missed = expectedSet.subtracting(actualSet)
            if let firstMissed = missed.first {
                feedback = "Watch your pronunciation on \"\(firstMissed)\""
            } else {
                feedback = "Almost — a few sounds were off."
            }
        } else if score >= 40 {
            feedback = "Keep practicing — some sounds need work."
        } else {
            feedback = "Try again slowly — focus on each word."
        }

        cards[currentIndex].userAnswer = heard
        cards[currentIndex].isCorrect = isCorrect
        cards[currentIndex].answeredAt = Date()

        totalAnswered += 1
        if isCorrect { correctCount += 1 }

        let generator = UIImpactFeedbackGenerator(style: isCorrect ? .light : .medium)
        generator.impactOccurred()

        // Show voice result with pronunciation score
        voiceHeard = heard
        voiceWasCorrect = isCorrect
        pronunciationScore = score
        pronunciationFeedback = feedback
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            showVoiceResult = true
        }

        if isCorrect { SoundEffect.correct.play() } else { SoundEffect.incorrect.play() }

        if isCorrect {
            // Longer hold for lower scores so they can read feedback
            let delay = score >= 85 ? 2.0 : 3.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                showVoiceResult = false
                advanceToNext()
            }
        }
        // If wrong, they swipe to continue (same as tap cards)
    }

    /// Levenshtein similarity between two strings (0.0 = completely different, 1.0 = identical)
    private static func levenshteinSimilarity(_ s1: String, _ s2: String) -> Double {
        let a = Array(s1)
        let b = Array(s2)
        let m = a.count, n = b.count
        guard m > 0 && n > 0 else { return m == n ? 1.0 : 0.0 }

        var matrix = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
        for i in 0...m { matrix[i][0] = i }
        for j in 0...n { matrix[0][j] = j }

        for i in 1...m {
            for j in 1...n {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j - 1] + cost
                )
            }
        }

        let distance = matrix[m][n]
        let maxLen = max(m, n)
        return 1.0 - (Double(distance) / Double(maxLen))
    }

    /// Auto-save slang to clipboard with animated feedback
    private func saveSlangToClipboard(card: LightningCard) {
        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        let key = "talkswitch_saved_phrases"
        var existing = defaults?.array(forKey: key) as? [[String: String]] ?? []

        // Don't save duplicates
        if existing.contains(where: { $0["translation"] == card.correctAnswer }) {
            withAnimation { savedToClipboard = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.3)) { clipboardCheckmark = true }
            }
            return
        }

        let entry: [String: String] = [
            "id": UUID().uuidString,
            "sourceText": card.explanation,
            "translation": card.correctAnswer,
            "sourceLang": "en",
            "targetLang": targetLang,
            "savedAt": ISO8601DateFormatter().string(from: Date()),
            "notes": "From Lightning Round"
        ]
        existing.insert(entry, at: 0)
        defaults?.set(existing, forKey: key)
        defaults?.synchronize()

        withAnimation { savedToClipboard = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.3)) { clipboardCheckmark = true }
        }
    }

    // MARK: - Fallback Card Generation

    private func generateFallbackCards(types: [LightningCardType], mistakes: [MistakeEntry]) -> [LightningCard] {
        types.enumerated().map { i, type in
            generateFallbackCard(type: type, mistake: mistakes[i % mistakes.count])
        }
    }

    private func generateFallbackCard(type: LightningCardType, mistake: MistakeEntry) -> LightningCard {
        switch type {
        case .thisOrThat, .trueOrFalse:
            return LightningCard(
                type: type,
                mistakeId: mistake.id,
                language: targetLang,
                prompt: "Which is correct?",
                correctAnswer: mistake.correctForm,
                options: [mistake.correctForm, mistake.userSaid].shuffled(),
                explanation: mistake.explanation
            )
        case .speakIt:
            return LightningCard(
                type: type,
                mistakeId: mistake.id,
                language: targetLang,
                prompt: "Say this sentence out loud:",
                correctAnswer: mistake.correctForm,
                explanation: mistake.explanation,
                audioText: mistake.correctForm,
                targetWord: mistake.correctForm
            )
        case .echo:
            return LightningCard(
                type: type,
                mistakeId: mistake.id,
                language: targetLang,
                prompt: "Listen and repeat:",
                correctAnswer: mistake.correctForm,
                explanation: mistake.explanation,
                audioText: mistake.correctForm,
                targetWord: mistake.correctForm
            )
        default:
            return LightningCard(
                type: type,
                mistakeId: mistake.id,
                language: targetLang,
                prompt: "What's the correct form?",
                correctAnswer: mistake.correctForm,
                options: [mistake.correctForm, mistake.userSaid].shuffled(),
                explanation: mistake.explanation
            )
        }
    }

    // MARK: - Helpers

    private func dotColor(for index: Int) -> Color {
        if index < currentIndex {
            // Completed — green or red
            let card = cards[index]
            return card.isCorrect == true ? Color(hex: "#34C759") : Color(hex: "#FF3B30")
        } else if index == currentIndex {
            return .white
        } else {
            return .white.opacity(0.25)
        }
    }

    private func optionTextColor(_ option: String, card: LightningCard) -> Color {
        guard selectedOption != nil else { return .black }
        if answersMatch(option, card.correctAnswer) { return Color(hex: "#34C759") }
        if option == selectedOption { return Color(hex: "#FF3B30") }
        return .black.opacity(0.3)
    }

    private func optionBgColor(_ option: String, card: LightningCard) -> Color {
        guard selectedOption != nil else { return Color.white }
        if answersMatch(option, card.correctAnswer) { return Color(hex: "#34C759").opacity(0.1) }
        if option == selectedOption && option != card.correctAnswer { return Color(hex: "#FF3B30").opacity(0.1) }
        return Color.white.opacity(0.5)
    }

    private func optionBorderColor(_ option: String, card: LightningCard) -> Color {
        guard selectedOption != nil else { return Color.black.opacity(0.08) }
        if answersMatch(option, card.correctAnswer) { return Color(hex: "#34C759").opacity(0.4) }
        if option == selectedOption && option != card.correctAnswer { return Color(hex: "#FF3B30").opacity(0.4) }
        return Color.black.opacity(0.04)
    }



    private var scoreColor: Color {
        let pct = Double(correctCount) / max(Double(totalAnswered), 1)
        if pct >= 0.8 { return Color(hex: "#34C759") }
        if pct >= 0.5 { return Color(hex: "#FF9500") }
        return Color(hex: "#FF3B30")
    }

    private var summaryMessage: String {
        if correctCount == totalAnswered && totalAnswered > 0 { return "Perfect Round!" }
        let pct = Double(correctCount) / max(Double(totalAnswered), 1)
        if pct >= 0.7 { return "Strong round!" }
        if pct >= 0.4 { return "Getting there!" }
        return "Keep at it!"
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    // MARK: - Intro Animations

    private func startIntroAnimations() {
        guard !rainStarted else { return }
        rainStarted = true

        // 1. Circle bounces in
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            circleBounce = 1.0
        }

        // 2. Bolt fades in after circle lands
        withAnimation(.easeIn(duration: 0.8).delay(0.4)) {
            boltOpacity = 1.0
        }

        // 3. Rain — uniform diagonal fall, all at the same speed
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let fallDuration = 1.2  // Same speed for all bolts
        let driftX: CGFloat = -60  // Diagonal drift (slightly left)
        let totalBolts = 20

        for i in 0..<totalBolts {
            let delay = Double(i) * 0.07  // Staggered start, but same fall speed
            let startX = CGFloat.random(in: 40...(screenWidth + 30))
            let startY: CGFloat = CGFloat.random(in: -60 ... -10)
            let endY = screenHeight + 40
            let size = CGFloat.random(in: 14...22)
            let opacity = Double.random(in: 0.15...0.35)
            let id = UUID()

            let bolt = RainBolt(id: id, x: startX, y: startY, size: size, opacity: 0)
            rainBolts.append(bolt)

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if let idx = rainBolts.firstIndex(where: { $0.id == id }) {
                    // Fade in instantly
                    withAnimation(.easeIn(duration: 0.1)) {
                        rainBolts[idx].opacity = opacity
                    }
                    // Fall diagonally — same duration for all
                    withAnimation(.linear(duration: fallDuration)) {
                        rainBolts[idx].y = endY
                        rainBolts[idx].x = startX + driftX
                    }
                }
            }

            // Fade out near the end
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + fallDuration - 0.2) {
                if let idx = rainBolts.firstIndex(where: { $0.id == id }) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        rainBolts[idx].opacity = 0
                    }
                }
            }
        }

        // Clean up
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            rainBolts.removeAll()
        }
    }
}

// MARK: - Rain Bolt Model

struct RainBolt: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    var opacity: Double
}
