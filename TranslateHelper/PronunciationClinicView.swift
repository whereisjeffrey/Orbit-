
//
//  PronunciationClinicView.swift
//  TranslateHelper
//
//  Pronunciation drill triggered from Coach for flagged words.
//  Evaluator is tiered:
//    • missCount ≤ 3  → Option C (SFSpeechRecognizer, fast, free)
//    • missCount >  3  → Option B (GPT-4o audio-preview, nuanced, ~$0.006/attempt)
//  Options are hot-swappable: only evaluatePronunciation() differs.
//

import SwiftUI
import Speech
import AVFoundation

// MARK: - Drill State

private enum DrillPhase: Equatable {
    case idle           // waiting to start / between attempts
    case listening      // recording in progress
    case evaluating     // processing result
    case pass           // this attempt was correct
    case tryAgain       // incorrect, attempts remaining
    case gracePass      // 3rd miss — encouraging forward movement
    case allDone        // finished all words in the queue
}

// MARK: - View

struct PronunciationClinicView: View {

    @ObservedObject private var store = PronunciationMistakeStore.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // Drill engine state
    @State private var currentIndex: Int = 0
    @State private var phase: DrillPhase = .idle
    @State private var attemptCount: Int = 0
    @State private var tip: String = ""

    // Animation
    @State private var micPulse: CGFloat = 1.0
    @State private var resultScale: CGFloat = 0.6
    @State private var resultOpacity: Double = 0

    // Recording (file-based — works for both Option B and Option C)
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioEngine        = AVAudioEngine()
    @State private var recognitionTask:   SFSpeechRecognitionTask?
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?

    private let maxAttempts = 3

    // MARK: - Computed

    private var queue: [PronunciationMistake] {
        store.clinicQueue
    }

    private var current: PronunciationMistake? {
        guard currentIndex < queue.count else { return nil }
        return queue[currentIndex]
    }

    private var wordsRemaining: Int {
        max(0, queue.count - currentIndex)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            TSGradientBackground().ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Header ────────────────────────────────────────────────
                HStack {
                    TSDismissButton(action: { stopListening(); dismiss() })

                    Spacer()

                    Text("Pronunciation Clinic")
                        .font(.custom("HelveticaNeue-Medium", size: 16))
                        .foregroundColor(.tsLabel)

                    Spacer()

                    // Progress counter
                    if !queue.isEmpty && phase != .allDone {
                        Text("\(currentIndex + 1) of \(queue.count)")
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsSecondary)
                    } else {
                        Color.clear.frame(width: 32, height: 32)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)

                // ── Progress bar ──────────────────────────────────────────
                if !queue.isEmpty && queue.count > 1 {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.tsAccent.opacity(0.12))
                                .frame(height: 3)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.tsAccent)
                                .frame(
                                    width: geo.size.width * CGFloat(currentIndex) / CGFloat(queue.count),
                                    height: 3
                                )
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentIndex)
                        }
                    }
                    .frame(height: 3)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }

                Spacer()

                // ── Main content ──────────────────────────────────────────
                if phase == .allDone || queue.isEmpty {
                    allDoneView
                } else if let word = current {
                    drillContent(for: word)
                }

                Spacer()

            }
        }
        .onAppear { setupSession() }
        .onDisappear { stopListening() }
    }

    // MARK: - Drill Content

    @ViewBuilder
    private func drillContent(for mistake: PronunciationMistake) -> some View {
        VStack(spacing: 32) {

            // Miss count badge
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                Text(missCountLabel(mistake.missCount))
                    .font(.custom("HelveticaNeue", size: 13))
                    .foregroundColor(.tsSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(Color.orange.opacity(0.08))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.orange.opacity(0.15), lineWidth: 1))

            // The word
            Text(mistake.word)
                .font(.custom("HelveticaNeue-Bold", size: 36))
                .foregroundColor(.tsLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Language name
            Text(languageName(for: mistake.language))
                .font(.custom("HelveticaNeue", size: 15))
                .foregroundColor(.tsSecondary)

            // ── Mic / Result area ──────────────────────────────────────
            ZStack {
                micArea(for: mistake)
                resultOverlay
            }
            .frame(height: 160)

            // ── Tip text ───────────────────────────────────────────────
            if !tip.isEmpty {
                Text(tip)
                    .font(.custom("HelveticaNeue", size: 14))
                    .foregroundColor(.tsSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            // ── Attempt dots ───────────────────────────────────────────
            HStack(spacing: 8) {
                ForEach(0..<maxAttempts, id: \.self) { i in
                    Circle()
                        .fill(i < attemptCount ? Color.orange : Color.tsAccent.opacity(0.15))
                        .frame(width: 8, height: 8)
                        .animation(.spring(response: 0.3), value: attemptCount)
                }
            }

            // ── Action buttons ─────────────────────────────────────────
            VStack(spacing: 12) {
                // Primary: Listen then Try
                if phase == .idle || phase == .tryAgain || phase == .gracePass || phase == .pass {
                    HStack(spacing: 12) {
                        // Hear it button
                        Button {
                            playWord(mistake)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 15))
                                Text("Hear it")
                                    .font(.custom("HelveticaNeue-Medium", size: 15))
                            }
                            .foregroundColor(.tsAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.tsAccent.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tsAccent.opacity(0.20), lineWidth: 1))
                        }

                        // Try it button — disabled if at max attempts or already passed
                        if phase != .pass && phase != .gracePass {
                            Button {
                                startListening(for: mistake)
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "mic.fill")
                                        .font(.system(size: 15))
                                    Text(attemptCount == 0 ? "Try it" : "Try again")
                                        .font(.custom("HelveticaNeue-Medium", size: 15))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.tsAccent)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .disabled(attemptCount >= maxAttempts)
                        }
                    }
                    .padding(.horizontal, 32)
                }

                // Listening indicator
                if phase == .listening {
                    listeningButton(for: mistake)
                }

                // Next / Continue
                if phase == .pass || phase == .gracePass {
                    Button {
                        advanceToNext(wasPass: phase == .pass)
                    } label: {
                        Text(currentIndex + 1 >= queue.count ? "Finish" : "Next word →")
                            .font(.custom("HelveticaNeue-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient.tsVibrant
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color.tsAccent.opacity(0.30), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 32)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: phase)
        }
    }

    // MARK: - Mic Area

    @ViewBuilder
    private func micArea(for mistake: PronunciationMistake) -> some View {
        VStack(spacing: 16) {
            ZStack {
                // Outer pulse ring — only during recording
                if phase == .listening {
                    Circle()
                        .stroke(Color.tsAccent.opacity(0.25), lineWidth: 2)
                        .frame(width: 96, height: 96)
                        .scaleEffect(micPulse)
                        .animation(
                            .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                            value: micPulse
                        )
                }

                Circle()
                    .fill(micCircleColor)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Circle().stroke(micBorderColor, lineWidth: 1.5)
                    )

                Image(systemName: phase == .listening ? "mic.fill" : "mic")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(phase == .listening ? .white : .tsAccent)
            }

            if phase == .listening {
                Text("Listening…")
                    .font(.custom("HelveticaNeue", size: 14))
                    .foregroundColor(.tsSecondary)
            } else if phase == .evaluating {
                HStack(spacing: 8) {
                    ProgressView().tint(.tsAccent).scaleEffect(0.8)
                    Text("Checking…")
                        .font(.custom("HelveticaNeue", size: 14))
                        .foregroundColor(.tsSecondary)
                }
            }
        }
    }

    private var micCircleColor: Color {
        switch phase {
        case .listening:   return Color.tsAccent
        case .evaluating:  return Color.tsCard
        default:           return Color.tsAccent.opacity(0.10)
        }
    }

    private var micBorderColor: Color {
        switch phase {
        case .listening:  return Color.tsAccent.opacity(0.40)
        default:          return Color.tsAccent.opacity(0.20)
        }
    }

    // MARK: - Result Overlay

    @ViewBuilder
    private var resultOverlay: some View {
        switch phase {
        case .pass:
            resultBadge(
                icon: "checkmark.circle.fill",
                text: "Nailed it!",
                color: Color(hex: "#34C759")
            )
        case .tryAgain:
            resultBadge(
                icon: "arrow.counterclockwise.circle.fill",
                text: "Try again",
                color: Color.orange
            )
        case .gracePass:
            resultBadge(
                icon: "heart.circle.fill",
                text: "That's a tough one",
                color: Color(hex: "#FF6B6B")
            )
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private func resultBadge(icon: String, text: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 44, weight: .medium))
                .foregroundColor(color)
            Text(text)
                .font(.custom("HelveticaNeue-Bold", size: 16))
                .foregroundColor(.tsLabel)
        }
        .scaleEffect(resultScale)
        .opacity(resultOpacity)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                resultScale   = 1.0
                resultOpacity = 1.0
            }
        }
    }

    // MARK: - Listening Button (active recording)

    @ViewBuilder
    private func listeningButton(for mistake: PronunciationMistake) -> some View {
        Button {
            stopListening()
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                Text("Stop recording")
                    .font(.custom("HelveticaNeue-Medium", size: 15))
                    .foregroundColor(.tsLabel)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.tsCard)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tsBorder, lineWidth: 1))
        }
        .padding(.horizontal, 32)
    }

    // MARK: - All Done View

    private var allDoneView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#34C759").opacity(0.12))
                    .frame(width: 120, height: 120)
                Circle()
                    .fill(Color(hex: "#34C759").opacity(0.06))
                    .frame(width: 160, height: 160)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 52, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#34C759"), Color(hex: "#00C7BE")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 8) {
                Text("Session complete!")
                    .font(.custom("HelveticaNeue-Bold", size: 24))
                    .foregroundColor(.tsLabel)

                let masteredCount = store.mastered.count
                Text(masteredCount > 0
                    ? "You've mastered \(masteredCount) \(masteredCount == 1 ? "word" : "words") so far. Keep going."
                    : "Every attempt builds the muscle memory. Keep speaking.")
                    .font(.custom("HelveticaNeue", size: 15))
                    .foregroundColor(.tsSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
            }

            Button {
                dismiss()
            } label: {
                Text("Back to Coach")
                    .font(.custom("HelveticaNeue-Bold", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.tsAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 48)
        }
    }

    // MARK: - TTS Playback

    private func playWord(_ mistake: PronunciationMistake) {
        let locale = TTSService.bcp47Locale(for: mistake.language)
        TTSService.shared.speak(mistake.word, language: locale)
    }

    // MARK: - Recording

    private func setupSession() {
        SFSpeechRecognizer.requestAuthorization { _ in }
    }

    /// Returns true if this word should use Option B (GPT-4o audio) vs Option C.
    /// Threshold: after 3 misses the user has proven Option C can't help enough.
    private func shouldUseOptionB(for mistake: PronunciationMistake) -> Bool {
        mistake.missCount > 3
    }

    private func clinicAudioURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("ts_pronunciation_attempt.wav")
    }

    private func startListening(for mistake: PronunciationMistake) {
        stopListening()

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: [])
            try session.setActive(true)
        } catch { return }

        let url = clinicAudioURL()
        let settings: [String: Any] = [
            AVFormatIDKey:             Int(kAudioFormatLinearPCM),
            AVSampleRateKey:           16000.0,
            AVNumberOfChannelsKey:     1,
            AVLinearPCMBitDepthKey:    16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey:     false
        ]

        guard let recorder = try? AVAudioRecorder(url: url, settings: settings) else { return }
        audioRecorder = recorder
        recorder.record()

        withAnimation { phase = .listening }
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            micPulse = 1.3
        }

        // Auto-stop after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            guard self.phase == .listening else { return }
            self.stopListening()
            self.evaluatePronunciation(for: mistake)
        }
    }

    private func stopListening() {
        audioRecorder?.stop()
        audioRecorder = nil
        // Clean up any Option C stream if still open
        recognitionTask?.cancel(); recognitionTask = nil
        recognitionRequest?.endAudio(); recognitionRequest = nil
        if audioEngine.isRunning {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
        }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        micPulse = 1.0
    }

    // MARK: - Evaluation Router

    private func evaluatePronunciation(for mistake: PronunciationMistake) {
        withAnimation { phase = .evaluating }
        if shouldUseOptionB(for: mistake) {
            evaluateWithOptionB(for: mistake)
        } else {
            evaluateWithOptionC(for: mistake)
        }
    }

    // MARK: - Option B: GPT-4o Audio
    //
    // Sends the recorded WAV to gpt-4o-audio-preview.
    // GPT returns a JSON object: { "pass": Bool, "tip": String }
    // Falls back to Option C if the API call fails for any reason.

    private func evaluateWithOptionB(for mistake: PronunciationMistake) {
        let url = clinicAudioURL()
        guard let audioData = try? Data(contentsOf: url) else {
            evaluateWithOptionC(for: mistake); return
        }
        let base64Audio = audioData.base64EncodedString()
        let langName    = languageName(for: mistake.language)

        guard let endpoint = URL(string: "\(APIConfig.openAIBaseURL)/chat/completions") else {
            evaluateWithOptionC(for: mistake); return
        }

        let systemPrompt = """
        You are a pronunciation coach evaluator. The user is trying to say the \(langName) word or phrase: "\(mistake.word)".
        Listen to their audio attempt and evaluate it.

        Respond with ONLY a JSON object in this exact format — no markdown, no preamble:
        {"pass": true, "tip": "One short, specific tip (max 12 words). Empty string if they passed."}

        Scoring rules:
        - Pass (true) if the word is understandable to a native \(langName) speaker, even if slightly accented.
        - Fail (false) if key sounds, stress, or tones are wrong enough to cause confusion or misunderstanding.
        - Tip: if failing, give ONE concrete actionable tip. If passing, use empty string "".
        """

        let body: [String: Any] = [
            "model": "gpt-4o-audio-preview",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": [
                    ["type": "input_audio",
                     "input_audio": ["data": base64Audio, "format": "wav"]]
                ]]
            ],
            "temperature": 0.2,
            "max_tokens": 80
        ]

        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("Bearer \(APIConfig.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json",                  forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        req.timeoutInterval = 15

        URLSession.shared.dataTask(with: req) { data, _, error in
            DispatchQueue.main.async {
                // On any failure, fall back to Option C silently
                guard error == nil,
                      let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let choices = json["choices"] as? [[String: Any]],
                      let message = choices.first?["message"] as? [String: Any],
                      let content = message["content"] as? String,
                      let parsed  = try? JSONSerialization.jsonObject(
                          with: Data(content.utf8)) as? [String: Any],
                      let isPass  = parsed["pass"] as? Bool
                else {
                    // API unavailable or parse failed — fall back to Option C
                    self.evaluateWithOptionC(for: mistake)
                    return
                }

                let gptTip = (parsed["tip"] as? String) ?? ""
                self.handleResult(isPass: isPass, tip: gptTip, mistake: mistake)

                // Clean up the temp audio file
                try? FileManager.default.removeItem(at: self.clinicAudioURL())
            }
        }.resume()
    }

    // MARK: - Option C: SFSpeechRecognizer
    //
    // Transcribes the recorded file and checks if the target word was recognised.
    // Used for beginners (missCount ≤ 3) and as a fallback when Option B is unavailable.

    private func evaluateWithOptionC(for mistake: PronunciationMistake) {
        let url = clinicAudioURL()
        let localeID = fullLocale(for: mistake.language)
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeID)),
              recognizer.isAvailable else {
            // Recognizer unavailable — grace pass
            handleResult(isPass: false, tip: "Speech recognition isn't available for \(languageName(for: mistake.language)) right now.", mistake: mistake)
            return
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false

        recognizer.recognitionTask(with: request) { result, error in
            DispatchQueue.main.async {
                guard let result = result, result.isFinal else {
                    // Nothing heard
                    self.handleResult(isPass: false, tip: "Nothing was heard — tap Try again and speak clearly.", mistake: mistake)
                    return
                }
                let heard      = result.bestTranscription.formattedString
                let heardNorm  = heard.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let targetNorm = mistake.word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

                let isPass = heardNorm == targetNorm
                    || heardNorm.contains(targetNorm)
                    || targetNorm.contains(heardNorm)
                    || self.stringSimilarity(heardNorm, targetNorm) > 0.80

                let tip = isPass
                    ? ""
                    : self.tipForAttempt(self.attemptCount + 1, word: mistake.word)

                self.handleResult(isPass: isPass, tip: tip, mistake: mistake)
                try? FileManager.default.removeItem(at: url)
            }
        }
    }

    // MARK: - Result Handler (shared by both evaluators)

    private func handleResult(isPass: Bool, tip gptTip: String, mistake: PronunciationMistake) {
        resultScale   = 0.6
        resultOpacity = 0.0
        attemptCount += 1

        if isPass {
            withAnimation { phase = .pass }
            tip = gptTip.isEmpty ? "Well said — the evaluator understood you clearly." : gptTip
            store.markMastered(id: mistake.id)
        } else if attemptCount >= maxAttempts {
            withAnimation { phase = .gracePass }
            tip = gptTip.isEmpty
                ? "That's one of the trickier ones. Keep speaking — it'll click."
                : gptTip
        } else {
            withAnimation { phase = .tryAgain }
            tip = gptTip.isEmpty ? tipForAttempt(attemptCount, word: mistake.word) : gptTip
        }
    }

    // MARK: - Navigation

    private func advanceToNext(wasPass: Bool) {
        stopListening()
        withAnimation(.easeInOut(duration: 0.2)) {
            resultOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.attemptCount = 0
            self.tip = ""
            self.resultScale = 0.6
            self.resultOpacity = 0

            let nextIndex = self.currentIndex + 1
            if nextIndex >= self.queue.count {
                withAnimation { self.phase = .allDone }
            } else {
                self.currentIndex = nextIndex
                withAnimation { self.phase = .idle }
            }
        }
    }

    // MARK: - Helpers

    /// Levenshtein-based string similarity (0–1). Used as fuzzy match for Option C.
    private func stringSimilarity(_ a: String, _ b: String) -> Double {
        let aArr = Array(a)
        let bArr = Array(b)
        let n    = aArr.count
        let m    = bArr.count
        guard n > 0, m > 0 else { return 0 }

        var dp = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        for i in 0...n { dp[i][0] = i }
        for j in 0...m { dp[0][j] = j }
        for i in 1...n {
            for j in 1...m {
                let cost = aArr[i - 1] == bArr[j - 1] ? 0 : 1
                dp[i][j] = Swift.min(dp[i-1][j] + 1, dp[i][j-1] + 1, dp[i-1][j-1] + cost)
            }
        }
        let dist    = dp[n][m]
        let maxLen  = Double(max(n, m))
        return 1.0 - Double(dist) / maxLen
    }

    private func tipForAttempt(_ attempt: Int, word: String) -> String {
        switch attempt {
        case 1: return "Listen carefully and try to match each syllable exactly."
        case 2: return "Slow down — break \"\(word)\" into syllables and say each one."
        default: return "Take your time. Pronunciation is muscle memory — every attempt helps."
        }
    }

    private func missCountLabel(_ count: Int) -> String {
        count == 1 ? "Flagged once" : "Flagged \(count) times"
    }

    private func languageName(for code: String) -> String {
        let names: [String: String] = [
            "en": "English",    "es": "Spanish",    "zh": "Chinese",
            "fr": "French",     "de": "German",     "it": "Italian",
            "ja": "Japanese",   "ko": "Korean",     "ar": "Arabic",
            "pt": "Portuguese", "ru": "Russian",    "nl": "Dutch",
            "pl": "Polish",     "tr": "Turkish",    "uk": "Ukrainian",
            "sv": "Swedish",    "da": "Danish",     "no": "Norwegian",
            "hi": "Hindi",      "id": "Indonesian", "vi": "Vietnamese",
            "he": "Hebrew",     "th": "Thai",
        ]
        return names[code] ?? code.uppercased()
    }

    private func fullLocale(for code: String) -> String {
        switch code {
        case "es": return "es-MX"; case "zh": return "zh-Hans-CN"
        case "pt": return "pt-BR"; case "fr": return "fr-FR"
        case "de": return "de-DE"; case "it": return "it-IT"
        case "ja": return "ja-JP"; case "ko": return "ko-KR"
        case "ar": return "ar-SA"; case "ru": return "ru-RU"
        case "nl": return "nl-NL"; case "pl": return "pl-PL"
        case "tr": return "tr-TR"; case "uk": return "uk-UA"
        case "sv": return "sv-SE"; case "da": return "da-DK"
        case "no": return "nb-NO"; case "fi": return "fi-FI"
        case "hi": return "hi-IN"; case "id": return "id-ID"
        case "vi": return "vi-VN"; case "he": return "he-IL"
        case "th": return "th-TH"
        default:   return "\(code)-\(code.uppercased())"
        }
    }
}
