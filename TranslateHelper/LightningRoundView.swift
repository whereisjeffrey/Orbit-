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
    private var targetLang = "es"

    // MARK: - State

    @State private var phase: RoundPhase = .intro
    @State private var cards: [LightningCard] = []
    @State private var currentIndex = 0
    @State private var selectedOption: String?
    @State private var showCorrection = false
    @State private var correctionOffset: CGFloat = 0
    @State private var isGenerating = false
    @State private var roundStartTime = Date()
    @State private var cardAppearTime = Date()

    // Voice recording
    @State private var isRecording = false
    @State private var recordingSeconds = 0
    @State private var recordingTimer: Timer?

    // Results
    @State private var correctCount = 0
    @State private var totalAnswered = 0

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
    }

    // MARK: - Intro

    private var introView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Lightning bolt circle
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .shadow(color: .white.opacity(0.3), radius: 20)

                Image(systemName: "bolt.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color.tsAccent)
            }

            Text("Lightning Round")
                .font(.custom("HelveticaNeue-Bold", size: 28))
                .foregroundColor(.white)

            Text("6 quick exercises based on your real mistakes.\nTap, speak, listen — 60 seconds.")
                .font(.custom("HelveticaNeue", size: 15))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 40)

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
                    Text("Let's Go")
                        .font(.custom("HelveticaNeue-Bold", size: 17))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 48)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(Color.tsAccent)
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
                // Progress dots
                HStack(spacing: 6) {
                    ForEach(0..<cards.count, id: \.self) { i in
                        Circle()
                            .fill(dotColor(for: i))
                            .frame(width: 8, height: 8)
                    }
                }

                Spacer()

                // Card type label
                Text(card.type.displayName.uppercased())
                    .font(.custom("HelveticaNeue-Bold", size: 10))
                    .foregroundColor(.white.opacity(0.5))
                    .kerning(1.0)

                Spacer()

                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer()

            // Card content
            VStack(spacing: 24) {
                // Prompt
                Text(card.prompt)
                    .font(.custom("HelveticaNeue-Medium", size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
                    .fixedSize(horizontal: false, vertical: true)

                // Card-type-specific content
                if card.type.isVoiceCard && !showCorrection {
                    voiceInputArea(card: card)
                } else if card.type.isListenCard && card.type != .echo && !showCorrection {
                    listenArea(card: card)
                } else if !showCorrection {
                    optionsArea(card: card)
                }
            }

            Spacer()

            // Correction card (slides up from bottom when wrong)
            if showCorrection {
                correctionCard(card: card)
                    .offset(y: correctionOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                // Only allow right swipe
                                if gesture.translation.width > 0 {
                                    correctionOffset = -gesture.translation.width * 0.3
                                }
                            }
                            .onEnded { gesture in
                                if gesture.translation.width > 80 {
                                    advanceToNext()
                                } else {
                                    withAnimation(.spring(response: 0.3)) {
                                        correctionOffset = 0
                                    }
                                }
                            }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Options (Tap Cards)

    private func optionsArea(card: LightningCard) -> some View {
        VStack(spacing: 12) {
            if let options = card.options {
                ForEach(options, id: \.self) { option in
                    Button {
                        handleAnswer(option, card: card)
                    } label: {
                        HStack {
                            Text(option)
                                .font(.custom("HelveticaNeue-Medium", size: 16))
                                .foregroundColor(optionTextColor(option, card: card))
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if selectedOption == option {
                                Image(systemName: option == card.correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(option == card.correctAnswer ? Color(hex: "#34C759") : Color(hex: "#FF3B30"))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(optionBgColor(option, card: card))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(optionBorderColor(option, card: card), lineWidth: 1)
                        )
                    }
                    .disabled(selectedOption != nil)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Voice Input Area

    private func voiceInputArea(card: LightningCard) -> some View {
        VStack(spacing: 16) {
            if card.type == .echo {
                // Play button for echo cards
                Button {
                    if let audioText = card.audioText {
                        ttsService.speak(text: audioText, language: targetLang) {}
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 16))
                        Text("Listen")
                            .font(.custom("HelveticaNeue-Medium", size: 15))
                    }
                    .foregroundColor(.tsAccent)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                    )
                }
            }

            // Record button
            Button {
                if isRecording {
                    stopRecordingAndScore(card: card)
                } else {
                    startRecording()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(isRecording ? Color(hex: "#FF3B30") : Color.white)
                        .frame(width: 72, height: 72)
                        .shadow(color: isRecording ? Color(hex: "#FF3B30").opacity(0.4) : .white.opacity(0.3), radius: 12)

                    if isRecording {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color.tsAccent)
                    }
                }
            }

            if isRecording {
                Text(formatTime(recordingSeconds))
                    .font(.custom("HelveticaNeue-Bold", size: 14))
                    .foregroundColor(.white.opacity(0.6))
            } else {
                Text("Tap to record")
                    .font(.custom("HelveticaNeue", size: 13))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
    }

    // MARK: - Listen Area

    private func listenArea(card: LightningCard) -> some View {
        VStack(spacing: 20) {
            // Auto-play on appear
            Button {
                if let audioText = card.audioText {
                    ttsService.speak(text: audioText, language: targetLang) {}
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 64, height: 64)

                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
            }

            Text("Tap to replay")
                .font(.custom("HelveticaNeue", size: 12))
                .foregroundColor(.white.opacity(0.4))

            // Options below the play button
            if let options = card.options {
                VStack(spacing: 10) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            handleAnswer(option, card: card)
                        } label: {
                            HStack {
                                Text(option)
                                    .font(.custom("HelveticaNeue-Medium", size: 15))
                                    .foregroundColor(optionTextColor(option, card: card))
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                if selectedOption == option {
                                    Image(systemName: option == card.correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(option == card.correctAnswer ? Color(hex: "#34C759") : Color(hex: "#FF3B30"))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(optionBgColor(option, card: card))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(optionBorderColor(option, card: card), lineWidth: 1)
                            )
                        }
                        .disabled(selectedOption != nil)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            // Auto-play audio for listen cards
            if let audioText = card.audioText {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ttsService.speak(text: audioText, language: targetLang) {}
                }
            }
        }
    }

    // MARK: - Correction Card

    private func correctionCard(card: LightningCard) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("💡")
                    .font(.system(size: 16))
                Text(card.isCorrect == true ? "Correct!" : "Not quite")
                    .font(.custom("HelveticaNeue-Bold", size: 16))
                    .foregroundColor(card.isCorrect == true ? Color(hex: "#34C759") : Color(hex: "#FF3B30"))
                Spacer()
            }

            if card.isCorrect != true {
                // Show correct answer
                HStack(spacing: 6) {
                    Text("Answer:")
                        .font(.custom("HelveticaNeue", size: 14))
                        .foregroundColor(.tsSecondary)
                    Text(card.correctAnswer)
                        .font(.custom("HelveticaNeue-Bold", size: 14))
                        .foregroundColor(.tsLabel)
                }

                // Explanation
                Text(card.explanation)
                    .font(.custom("HelveticaNeue", size: 14))
                    .foregroundColor(.tsLabel)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Swipe hint
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Text("Swipe to continue")
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(.tsSecondary)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11))
                        .foregroundColor(.tsSecondary)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color.tsCard : Color.white)
                .shadow(color: .black.opacity(0.15), radius: 12, y: -4)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
    }

    // MARK: - Summary

    private var summaryView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Score circle
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 8)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: CGFloat(correctCount) / max(CGFloat(totalAnswered), 1))
                    .stroke(
                        scoreColor,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(correctCount)/\(totalAnswered)")
                        .font(.custom("HelveticaNeue-Bold", size: 28))
                        .foregroundColor(.white)
                    Text("correct")
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            Text(summaryMessage)
                .font(.custom("HelveticaNeue-Medium", size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Text(summarySubtext)
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                // Reset and do another round
                resetRound()
                withAnimation(.easeInOut(duration: 0.3)) {
                    phase = .loading
                }
                generateRound()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 15))
                    Text("Go Again")
                        .font(.custom("HelveticaNeue-Bold", size: 16))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 14)
                .background(Capsule().fill(Color.tsAccent))
            }

            Button { dismiss() } label: {
                Text("Done")
                    .font(.custom("HelveticaNeue", size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Logic

    private func generateRound() {
        isGenerating = true
        let profile = MistakeProfileStore.shared
        let mistakes = engine.selectMistakesForRound(count: 6, language: targetLang)

        // If no mistakes recorded yet, use seed data for demo
        let effectiveMistakes: [MistakeEntry]
        if mistakes.isEmpty {
            #if DEBUG
            profile.seedTestData(language: targetLang)
            effectiveMistakes = engine.selectMistakesForRound(count: 6, language: targetLang)
            #else
            effectiveMistakes = []
            #endif
        } else {
            effectiveMistakes = mistakes
        }

        guard !effectiveMistakes.isEmpty else {
            // No mistakes — can't generate a round
            withAnimation { phase = .intro }
            return
        }

        let cardTypes = engine.buildRoundCardTypes()
        let prompt = engine.generateCardsPrompt(
            cardTypes: cardTypes,
            mistakes: effectiveMistakes,
            language: targetLang
        )

        // Call GPT to generate cards
        generateCardsViaGPT(prompt: prompt, cardTypes: cardTypes, mistakes: effectiveMistakes)
    }

    private func generateCardsViaGPT(
        prompt: String,
        cardTypes: [LightningCardType],
        mistakes: [MistakeEntry]
    ) {
        let apiKey = APIConfig.openAIAPIKey
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You generate quiz cards for language learners. Respond ONLY with a valid JSON array."],
                ["role": "user", "content": prompt],
            ],
            "temperature": 0.9,
            "max_tokens": 1500,
            "response_format": ["type": "json_object"],
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 20

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                self.isGenerating = false
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let choices = json["choices"] as? [[String: Any]],
                      let message = choices.first?["message"] as? [String: Any],
                      let content = message["content"] as? String,
                      let contentData = content.data(using: .utf8),
                      let parsed = try? JSONSerialization.jsonObject(with: contentData) as? [String: Any]
                else {
                    // Fallback: generate cards locally
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

                    let card = LightningCard(
                        type: type,
                        mistakeId: mistake.id,
                        language: self.targetLang,
                        prompt: cardJSON["prompt"] as? String ?? "What's the correct form?",
                        correctAnswer: cardJSON["correct_answer"] as? String ?? mistake.correctForm,
                        options: cardJSON["options"] as? [String],
                        explanation: cardJSON["explanation"] as? String ?? mistake.explanation,
                        audioText: cardJSON["audio_text"] as? String,
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

                self.cards = generatedCards
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

    private func handleAnswer(_ answer: String, card: LightningCard) {
        guard selectedOption == nil else { return } // Already answered
        selectedOption = answer

        let isCorrect = answer == card.correctAnswer
        cards[currentIndex].userAnswer = answer
        cards[currentIndex].isCorrect = isCorrect
        cards[currentIndex].answeredAt = Date()

        totalAnswered += 1
        if isCorrect { correctCount += 1 }

        let generator = UIImpactFeedbackGenerator(style: isCorrect ? .light : .medium)
        generator.impactOccurred()

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
        }
    }

    private func advanceToNext() {
        withAnimation(.easeInOut(duration: 0.25)) {
            showCorrection = false
            selectedOption = nil
            correctionOffset = 0
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
                withAnimation(.easeInOut(duration: 0.4)) {
                    phase = .summary
                }
            }
        }
    }

    private func resetRound() {
        cards = []
        currentIndex = 0
        selectedOption = nil
        showCorrection = false
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
        let expected = card.correctAnswer.lowercased()
            .trimmingCharacters(in: .punctuationCharacters)
        let actual = heard.lowercased()
            .trimmingCharacters(in: .punctuationCharacters)

        // Simple similarity check — at least 70% word match
        let expectedWords = Set(expected.split(separator: " ").map(String.init))
        let actualWords = Set(actual.split(separator: " ").map(String.init))
        let intersection = expectedWords.intersection(actualWords)
        let similarity = expectedWords.isEmpty ? 0 : Double(intersection.count) / Double(expectedWords.count)

        let isCorrect = similarity >= 0.7

        cards[currentIndex].userAnswer = heard
        cards[currentIndex].isCorrect = isCorrect
        cards[currentIndex].answeredAt = Date()

        totalAnswered += 1
        if isCorrect { correctCount += 1 }

        let generator = UIImpactFeedbackGenerator(style: isCorrect ? .light : .medium)
        generator.impactOccurred()

        if isCorrect {
            selectedOption = card.correctAnswer
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                advanceToNext()
            }
        } else {
            selectedOption = heard
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                showCorrection = true
            }
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
                options: [mistake.correctForm, mistake.userSaid, "—"].shuffled(),
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
        guard selectedOption != nil else { return .white }
        if option == card.correctAnswer { return Color(hex: "#34C759") }
        if option == selectedOption { return Color(hex: "#FF3B30") }
        return .white.opacity(0.4)
    }

    private func optionBgColor(_ option: String, card: LightningCard) -> Color {
        guard selectedOption != nil else { return Color.white.opacity(0.1) }
        if option == card.correctAnswer { return Color(hex: "#34C759").opacity(0.15) }
        if option == selectedOption && option != card.correctAnswer { return Color(hex: "#FF3B30").opacity(0.15) }
        return Color.white.opacity(0.05)
    }

    private func optionBorderColor(_ option: String, card: LightningCard) -> Color {
        guard selectedOption != nil else { return Color.white.opacity(0.15) }
        if option == card.correctAnswer { return Color(hex: "#34C759").opacity(0.4) }
        if option == selectedOption && option != card.correctAnswer { return Color(hex: "#FF3B30").opacity(0.4) }
        return Color.white.opacity(0.05)
    }

    private var scoreColor: Color {
        let pct = Double(correctCount) / max(Double(totalAnswered), 1)
        if pct >= 0.8 { return Color(hex: "#34C759") }
        if pct >= 0.5 { return Color(hex: "#FF9500") }
        return Color(hex: "#FF3B30")
    }

    private var summaryMessage: String {
        let pct = Double(correctCount) / max(Double(totalAnswered), 1)
        if pct >= 0.9 { return "Incredible. You're on fire." }
        if pct >= 0.7 { return "Solid round. Getting sharper." }
        if pct >= 0.5 { return "Good work. Those mistakes are fading." }
        return "Keep at it. Every round makes you better."
    }

    private var summarySubtext: String {
        let due = MistakeProfileStore.shared.dueForReview.count
        if due > 0 {
            return "\(due) pattern\(due == 1 ? "" : "s") still due for review. Come back tomorrow."
        }
        return "All caught up for now. Come back tomorrow."
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
