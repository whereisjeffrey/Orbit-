//
//  PronunciationScorer.swift
//  TranslateHelper
//
//  Scores pronunciation using Apple's SFSpeechRecognizer.
//  Records the user saying a word, then checks:
//  1. Did the recognizer understand the target word? (accuracy)
//  2. How confident was it? (confidence score)
//  3. Did it hear the right word or something else? (correctness)

import Foundation
import Speech
import AVFoundation

class PronunciationScorer {

    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var isListening = false

    /// Records the user and scores their pronunciation of a target word.
    /// - Parameters:
    ///   - targetWord: The word they're trying to say (e.g., "porta")
    ///   - language: The language code (e.g., "pt-BR")
    ///   - duration: How long to record (seconds)
    ///   - completion: Returns (score 0-100, what was heard, feedback)
    func scorePronounciation(
        targetWord: String,
        language: String,
        duration: TimeInterval = 3.0,
        completion: @escaping (Int, String, String) -> Void
    ) {
        let locale = Locale(identifier: language)
        guard let recognizer = SFSpeechRecognizer(locale: locale), recognizer.isAvailable else {
            completion(0, "", "Speech recognition not available for this language.")
            return
        }

        // Set up audio session
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            completion(0, "", "Could not set up audio: \(error.localizedDescription)")
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = false

        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        guard recordingFormat.sampleRate > 0 else {
            completion(0, "", "Microphone not available.")
            return
        }

        inputNode.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        engine.prepare()
        do { try engine.start() } catch {
            completion(0, "", "Could not start recording.")
            return
        }

        audioEngine = engine
        recognitionRequest = request
        isListening = true

        // Stop recording after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.stopRecording()
        }

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result, result.isFinal {
                let heard = result.bestTranscription.formattedString
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased()

                let target = targetWord.lowercased()

                // Calculate score from multiple factors
                let score = self.calculateScore(
                    target: target,
                    heard: heard,
                    segments: result.bestTranscription.segments
                )

                let feedback = self.generateFeedback(score: score, target: targetWord, heard: heard)

                DispatchQueue.main.async {
                    completion(score, heard, feedback)
                }
            }

            if let error = error {
                let nsError = error as NSError
                // Error code 1110 = no speech detected
                if nsError.code == 1110 {
                    DispatchQueue.main.async {
                        completion(0, "", "Didn't catch that — try speaking louder and closer to your phone.")
                    }
                }
            }
        }
    }

    private func stopRecording() {
        guard isListening else { return }
        isListening = false

        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()

        // Switch back to playback mode so WaveNet audio can play immediately after
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            NSLog("PronunciationScorer: failed to switch back to playback: \(error)")
        }
    }

    // MARK: - Scoring

    private func calculateScore(target: String, heard: String, segments: [SFTranscriptionSegment]) -> Int {
        // Factor 1: Did they say the right word? (50% of score)
        let wordMatch: Double
        if heard == target {
            wordMatch = 1.0
        } else if heard.contains(target) || target.contains(heard) {
            wordMatch = 0.7
        } else {
            // Check similarity
            let similarity = stringSimilarity(target, heard)
            wordMatch = similarity
        }

        // Factor 2: Confidence from the recognizer (50% of score)
        let avgConfidence: Double
        if segments.isEmpty {
            avgConfidence = 0.0
        } else {
            let total = segments.reduce(0.0) { $0 + Double($1.confidence) }
            avgConfidence = total / Double(segments.count)
            // Confidence of 0 means Apple didn't provide a score (common)
            // In that case, rely more on word match
        }

        let score: Double
        if avgConfidence > 0 {
            score = (wordMatch * 50.0) + (avgConfidence * 50.0)
        } else {
            // No confidence data — score based on word match alone
            score = wordMatch * 100.0
        }

        return min(100, max(0, Int(score)))
    }

    /// Simple string similarity (Levenshtein-based, normalized 0-1)
    private func stringSimilarity(_ a: String, _ b: String) -> Double {
        let aChars = Array(a)
        let bChars = Array(b)
        let aLen = aChars.count
        let bLen = bChars.count

        if aLen == 0 && bLen == 0 { return 1.0 }
        if aLen == 0 || bLen == 0 { return 0.0 }

        var matrix = Array(repeating: Array(repeating: 0, count: bLen + 1), count: aLen + 1)
        for i in 0...aLen { matrix[i][0] = i }
        for j in 0...bLen { matrix[0][j] = j }

        for i in 1...aLen {
            for j in 1...bLen {
                let cost = aChars[i-1] == bChars[j-1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i-1][j] + 1,
                    matrix[i][j-1] + 1,
                    matrix[i-1][j-1] + cost
                )
            }
        }

        let maxLen = Double(max(aLen, bLen))
        let distance = Double(matrix[aLen][bLen])
        return 1.0 - (distance / maxLen)
    }

    // MARK: - Feedback

    private func generateFeedback(score: Int, target: String, heard: String) -> String {
        if score >= 90 {
            return "Excellent! That sounded very natural. 👏"
        } else if score >= 75 {
            return "Good! The recognizer understood you. Keep refining the sound."
        } else if score >= 60 {
            if heard.isEmpty {
                return "Try speaking a bit louder and more clearly."
            }
            return "Almost — I heard '\(heard)' instead of '\(target).' Focus on the sounds that are different."
        } else if score >= 40 {
            return "The sounds are off — try listening to the native version again and match the rhythm."
        } else {
            if heard.isEmpty {
                return "Didn't catch that — try speaking louder and closer to your phone."
            }
            return "I heard '\(heard)' — that's quite different from '\(target).' Listen again and try matching each sound."
        }
    }
}
