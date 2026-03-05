//
//  SoundEngine.swift
//  TranslateHelper
//
//  Retro lo-fi game sounds for study mode — synthesised on the fly, no audio files needed.
//

import AVFoundation
import Foundation

final class SoundEngine {

    static let shared = SoundEngine()

    private let engine   = AVAudioEngine()
    private let mixer    = AVAudioMixerNode()
    private let sampleRate: Double = 44100
    private var ready    = false

    enum Sound { case flip, again, hard, good, easy }

    private init() {
        engine.attach(mixer)
        engine.connect(mixer, to: engine.mainMixerNode, format: nil)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
            ready = true
        } catch {
            print("SoundEngine init error: \(error)")
        }
    }

    func play(_ sound: Sound) {
        guard ready else { return }
        switch sound {
        case .flip:  playChirp(startHz: 1800, endHz: 90, duration: 0.13, volume: 0.13)
        case .again: scheduleNotes([(180,0.07,0.30),(150,0.07,0.24),(130,0.10,0.18)], gap: 0.0,  wave: .square)
        case .hard:  scheduleNotes([(330,0.10,0.22),(294,0.14,0.16)],                 gap: 0.06, wave: .square)
        case .good:  scheduleNotes([(523,0.08,0.24),(659,0.08,0.24),(784,0.14,0.26)], gap: 0.07, wave: .square)
        case .easy:  scheduleNotes([(523,0.08,0.26),(659,0.08,0.26),(784,0.08,0.26),(1047,0.18,0.28)], gap: 0.07, wave: .square)
        }
    }

    // MARK: - Synthesis

    private enum Wave { case square, sine }

    private func scheduleNotes(_ notes: [(Double, Double, Float)], gap: Double, wave: Wave) {
        var offset: Double = 0
        for (freq, dur, vol) in notes {
            let t = offset
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + t) { [weak self] in
                self?.playOnce(freq: freq, duration: dur, volume: vol, wave: wave)
            }
            offset += dur + gap
        }
    }

    private func playOnce(freq: Double, duration: Double, volume: Float, wave: Wave) {
        let fmt = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buf = AVAudioPCMBuffer(pcmFormat: fmt, frameCapacity: frameCount),
              let data = buf.floatChannelData?[0] else { return }
        buf.frameLength = frameCount

        for i in 0..<Int(frameCount) {
            let t  = Double(i) / sampleRate
            let ph = 2.0 * .pi * freq * t
            let p  = Double(i) / Double(frameCount)
            // 2% attack, linear decay
            let env = p < 0.02 ? p / 0.02 : 1.0 - p
            let raw: Double = wave == .square ? (sin(ph) >= 0 ? 1 : -1) : sin(ph)
            data[i] = Float(raw * env * Double(volume))
        }

        let node = AVAudioPlayerNode()
        engine.attach(node)
        engine.connect(node, to: mixer, format: fmt)
        node.scheduleBuffer(buf, at: nil, options: []) { [weak self] in
            DispatchQueue.main.async { self?.engine.detach(node) }
        }
        node.play()
    }
    // MARK: - Chirp (smooth frequency glide — skeuomorphic page-flip whoosh)
    private func playChirp(startHz: Double, endHz: Double, duration: Double, volume: Float) {
        let fmt = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buf = AVAudioPCMBuffer(pcmFormat: fmt, frameCapacity: frameCount),
              let data = buf.floatChannelData?[0] else { return }
        buf.frameLength = frameCount

        var phase: Double = 0
        for i in 0..<Int(frameCount) {
            let t   = Double(i) / sampleRate
            let p   = t / duration                          // 0 → 1 progress
            // Exponential frequency sweep feels more natural than linear
            let freq = startHz * pow(endHz / startHz, p)
            let dPhase = 2.0 * .pi * freq / sampleRate
            phase += dPhase

            // Envelope: 3% attack, then smooth exponential decay
            let env: Double = p < 0.03
                ? p / 0.03
                : exp(-4.5 * (p - 0.03))

            data[i] = Float(sin(phase) * env * Double(volume))
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let node = AVAudioPlayerNode()
            self.engine.attach(node)
            self.engine.connect(node, to: self.mixer, format: fmt)
            node.scheduleBuffer(buf, at: nil, options: []) { [weak self] in
                DispatchQueue.main.async { self?.engine.detach(node) }
            }
            node.play()
        }
    }

}
