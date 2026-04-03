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
    @State private var voiceHeard: String = ""
    @State private var voiceWasCorrect: Bool = false

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
            // Start generating cards as soon as the Lightning Round screen appears.
            // While the user watches the intro animation (2-3 seconds), cards are
            // being fetched in the background. By the time they tap "Let's Go",
            // cards are usually ready — instant start.
            if phase == .intro && cards.isEmpty {
                DispatchQueue.global(qos: .userInitiated).async {
                    // Seed mistakes if needed
                    let profile = MistakeProfileStore.shared
                    if !profile.hasMistakes(for: self.targetLang) {
                        let sem = DispatchSemaphore(value: 0)
                        profile.seedStarterMistakes(language: self.targetLang) { sem.signal() }
                        _ = sem.wait(timeout: .now() + 15)
                    }
                    // Try pre-gen (will skip if already cached)
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
                    .fill(Color(hex: "#F3F9FB"))
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
            // Context / dialogue — bold, dark text on light card
            Text(parts.context)
                .font(.custom("HelveticaNeue-Bold", size: 18))
                .foregroundColor(.black)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

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

    /// Splits prompt into context (top) + question (bottom).
    private func splitPrompt(_ prompt: String) -> (context: String, question: String?) {
        // Try newline split first
        if prompt.contains("\n") {
            let lines = prompt.split(separator: "\n", maxSplits: 1)
            if lines.count == 2 {
                return (String(lines[0]).trimmingCharacters(in: .whitespacesAndNewlines),
                        String(lines[1]).trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }

        // Try splitting on question mark — everything before is context, the question + rest is the question
        if let qRange = prompt.range(of: "? ") {
            let before = String(prompt[prompt.startIndex...qRange.lowerBound])
            let after = String(prompt[qRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            // If "after" looks like options (a/b/c), put the question mark part as the question
            if !after.isEmpty {
                return (after, before + "?")
            }
        }

        // Try colon split
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
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(optionBorderColor(option, card: card), lineWidth: 1)
                        )
                    }
                    .disabled(selectedOption != nil)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func optionLetterColor(_ option: String, card: LightningCard) -> Color {
        guard selectedOption != nil else { return .black.opacity(0.5) }
        if answersMatch(option, card.correctAnswer) { return Color(hex: "#34C759") }
        if option == selectedOption { return Color(hex: "#FF3B30") }
        return .black.opacity(0.2)
    }

    private func optionLetterBg(_ option: String, card: LightningCard) -> Color {
        guard selectedOption != nil else { return Color(hex: "#F3F9FB") }
        if answersMatch(option, card.correctAnswer) { return Color(hex: "#34C759").opacity(0.12) }
        if option == selectedOption && option != card.correctAnswer { return Color(hex: "#FF3B30").opacity(0.12) }
        return Color(hex: "#F3F9FB").opacity(0.5)
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

            // Voice result verification
            if showVoiceResult {
                VStack(spacing: 10) {
                    // What you said
                    HStack(spacing: 8) {
                        Image(systemName: voiceWasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(voiceWasCorrect ? Color(hex: "#34C759") : Color(hex: "#FF3B30"))
                            .font(.system(size: 20))
                        Text("You said:")
                            .font(.custom("HelveticaNeue-Medium", size: 13))
                            .foregroundColor(.tsSecondary)
                    }

                    Text("\"\(voiceHeard)\"")
                        .font(.custom("HelveticaNeue-Medium", size: 15))
                        .foregroundColor(voiceWasCorrect ? Color(hex: "#34C759") : Color(hex: "#FF3B30"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)

                    if !voiceWasCorrect {
                        // Show correct answer
                        Text("Expected:")
                            .font(.custom("HelveticaNeue", size: 12))
                            .foregroundColor(.tsSecondary)
                        Text("\"\(card.audioText ?? card.correctAnswer)\"")
                            .font(.custom("HelveticaNeue-Bold", size: 15))
                            .foregroundColor(Color(hex: "#34C759"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(voiceWasCorrect ? Color(hex: "#34C759").opacity(0.08) : Color(hex: "#FF3B30").opacity(0.08))
                )
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

                Text("💡 \(card.explanation)")
                    .font(.custom("HelveticaNeue", size: 13))
                    .foregroundColor(.black.opacity(0.5))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
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
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            // Summary card — light bluish like the active card
            VStack(spacing: 20) {
                // Score circle
                ZStack {
                    Circle()
                        .stroke(Color.black.opacity(0.06), lineWidth: 8)
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: CGFloat(correctCount) / max(CGFloat(totalAnswered), 1))
                        .stroke(
                            scoreColor,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(correctCount)/\(totalAnswered)")
                            .font(.custom("HelveticaNeue-Bold", size: 24))
                            .foregroundColor(.black)
                        Text("correct")
                            .font(.custom("HelveticaNeue", size: 12))
                            .foregroundColor(.black.opacity(0.4))
                    }
                }
                .padding(.top, 8)

                Text(summaryMessage)
                    .font(.custom("HelveticaNeue-Medium", size: 17))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text(summarySubtext)
                    .font(.custom("HelveticaNeue", size: 13))
                    .foregroundColor(.black.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

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
                        Text("Go Again")
                            .font(.custom("HelveticaNeue-Medium", size: 16))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.tsAccent)
                    .cornerRadius(14)
                }
                .padding(.horizontal, 20)

                Button { dismiss() } label: {
                    Text("Done")
                        .font(.custom("HelveticaNeue", size: 14))
                        .foregroundColor(.black.opacity(0.4))
                }
                .padding(.bottom, 4)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "#F3F9FB"))
                    .shadow(color: .black.opacity(0.1), radius: 16, y: 4)
            )
            .padding(.horizontal, 16)

            Spacer()
        }
    }

    // MARK: - Logic

    private func generateRound() {
        isGenerating = true

        // 1. Check in-memory cache first (fastest)
        if let cached = engine.cachedCards, !cached.isEmpty,
           cached.first?.language == targetLang {
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
            engine.clearDiskCache()
            self.cards = diskCached
            startRound()
            preGenerateNextRound()
            return
        }

        let profile = MistakeProfileStore.shared
        var mistakes = engine.selectMistakesForRound(count: 10, language: targetLang)

        // If no mistakes exist, seed them on demand and retry
        if mistakes.isEmpty {
            NSLog("⚡ [LightningRound] no mistakes — seeding on demand for \(targetLang)")
            profile.seedStarterMistakes(language: targetLang) { [self] in
                let retryMistakes = engine.selectMistakesForRound(count: 10, language: targetLang)
                if retryMistakes.isEmpty {
                    NSLog("⚡ [LightningRound] seeding failed — dismissing")
                    dismiss()
                    return
                }
                // Retry with seeded mistakes
                let types = engine.buildRoundCardTypes()
                let prompt = engine.generateCardsPrompt(cardTypes: types, mistakes: retryMistakes, language: targetLang)
                generateCardsViaGPT(prompt: prompt, cardTypes: types, mistakes: retryMistakes)
            }
            return
        }

        let cardTypes = engine.buildRoundCardTypes()
        let prompt = engine.generateCardsPrompt(
            cardTypes: cardTypes,
            mistakes: mistakes,
            language: targetLang
        )

        generateCardsViaGPT(prompt: prompt, cardTypes: cardTypes, mistakes: mistakes)
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
        let apiKey = APIConfig.openAIAPIKey
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You generate quiz cards for language learners. Respond ONLY with a valid JSON array."],
                ["role": "user", "content": prompt],
            ],
            "temperature": 0.5,
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

                    // Filter out dash/empty options from GPT
                    let rawOptions = cardJSON["options"] as? [String]
                    let cleanedOptions = rawOptions?.filter { opt in
                        let trimmed = opt.trimmingCharacters(in: .whitespacesAndNewlines)
                        return trimmed.count >= 2 && trimmed != "—" && trimmed != "-" && trimmed != "–"
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

                // Validate — discard bad cards
                let validated = self.engine.validateCards(generatedCards, language: self.targetLang)
                self.cards = validated.isEmpty ? generatedCards : validated
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
        // For voice cards, compare against audioText (what they were asked to say),
        // NOT correctAnswer (which may be a different field for some card types)
        let expectedRaw = (card.audioText ?? card.correctAnswer)
        let expected = expectedRaw.lowercased()
            .trimmingCharacters(in: .punctuationCharacters)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let actual = heard.lowercased()
            .trimmingCharacters(in: .punctuationCharacters)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Word-level similarity — at least 60% match (more forgiving for pronunciation)
        let expectedWords = Set(expected.split(separator: " ").map(String.init))
        let actualWords = Set(actual.split(separator: " ").map(String.init))
        let intersection = expectedWords.intersection(actualWords)
        let similarity = expectedWords.isEmpty ? 0 : Double(intersection.count) / Double(expectedWords.count)

        let isCorrect = similarity >= 0.6

        cards[currentIndex].userAnswer = heard
        cards[currentIndex].isCorrect = isCorrect
        cards[currentIndex].answeredAt = Date()

        totalAnswered += 1
        if isCorrect { correctCount += 1 }

        let generator = UIImpactFeedbackGenerator(style: isCorrect ? .light : .medium)
        generator.impactOccurred()

        // Show voice result verification
        voiceHeard = heard
        voiceWasCorrect = isCorrect
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            showVoiceResult = true
        }

        // Play sound
        if isCorrect { SoundEffect.correct.play() } else { SoundEffect.incorrect.play() }

        if isCorrect {
            // Auto-advance after showing result for 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showVoiceResult = false
                advanceToNext()
            }
        }
        // If wrong, they swipe to continue (same as tap cards)
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
