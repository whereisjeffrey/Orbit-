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
        case .flip:  playPageTurn()
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
    // MARK: - Page-Turn (Skeuomorphic v3 — Physical Model)
    //
    // What makes real cardstock sound like cardstock:
    //
    //  A) A hard, dry CLICK (0–3 ms)   — fingernail/thumb-tip releasing the edge
    //  B) A downward CHIRP (0–40 ms)   — the card bending and snapping back
    //                                     (sine sweep 5 kHz → 900 Hz). This "fwip"
    //                                     shape is what the brain IDs as paper.
    //  C) Bright PAPER NOISE (0–90 ms) — high LP coefficient (0.6) so it's mid/
    //                                     high, not dark. Hard zero-attack.
    //  D) A thin 2.2 kHz RING (0–20ms) — damped resonance of card stock, fades
    //                                     in ~15 ms. Adds papery "body".
    //  E) Settle CLICK (100–120 ms)    — tiny wideband burst as card lands flat.
    //
    //  Total: 120 ms stereo (left→right pan arc on layers B,C).
    //  The key insight: filtered noise alone sounds synthetic because it has no
    //  pitch contour. The chirp (B) is the acoustic signature of a physical object
    //  bending — without it, everything sounds like a retro sound effect.
    private func playPageTurn() {
        let duration: Double = 0.120
        let sr = sampleRate
        let fmt = AVAudioFormat(standardFormatWithSampleRate: sr, channels: 2)!
        let frameCount = AVAudioFrameCount(sr * duration)
        guard let buf = AVAudioPCMBuffer(pcmFormat: fmt, frameCapacity: frameCount),
              let chL = buf.floatChannelData?[0],
              let chR = buf.floatChannelData?[1] else { return }
        buf.frameLength = frameCount

        // ── Filter state ───────────────────────────────────────────────────────
        var noiseLP: Double = 0           // paper noise low-pass
        var ringPhase: Double = 0         // 2.2 kHz ring oscillator
        var chirpPhase: Double = 0        // fwip chirp oscillator

        // Settle click: fires at 100 ms
        let settleOnset: Double = 0.100
        let settleLen:   Double = 0.018   // 18 ms burst

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sr            // time in seconds
            let p = t / duration              // 0 → 1

            // ── A) Click transient (0–3 ms) ─────────────────────────────────
            // Pure white noise, instant on, instant off — dry and percussive.
            let clickAmt: Double = t < 0.003 ? 1.0 : 0.0
            let clickSample = Double.random(in: -1...1) * clickAmt * 0.65

            // ── B) Chirp "fwip" (0–40 ms) — the physical card bend ───────────
            // Frequency sweeps 5000 Hz → 900 Hz exponentially.
            // Envelope: instant on, decays with exp(-80·t) → gone by ~35 ms.
            let chirpDur: Double = 0.040
            let chirpFreq: Double = t < chirpDur
                ? 5000.0 * pow(0.18, t / chirpDur)  // 5k→900 Hz
                : 0.0
            chirpPhase += 2.0 * .pi * chirpFreq / sr
            let chirpEnv  = t < chirpDur ? exp(-70.0 * t) : 0.0
            let chirpSample = sin(chirpPhase) * chirpEnv * 0.55

            // ── C) Paper noise (0–90 ms) ─────────────────────────────────────
            // LP coefficient 0.62 keeps it bright (mid + upper-mid focus).
            // Hard zero-attack — no fade-in, just like real paper.
            let noiseCoeff: Double = 0.62
            noiseLP = noiseLP * (1.0 - noiseCoeff) + Double.random(in: -1...1) * noiseCoeff
            let noiseDur: Double = 0.090
            let noiseEnv: Double = t < noiseDur
                ? exp(-22.0 * t)   // sharp exponential tail from frame 0
                : 0.0
            let noiseSample = noiseLP * noiseEnv * 0.70

            // ── D) 2.2 kHz resonance ring (0–20 ms) ──────────────────────────
            // Damped sine — models the card-stock's natural resonance.
            let ringFreq: Double = 2200.0
            let ringDecay = exp(-200.0 * t)   // gone by ~15 ms
            ringPhase += 2.0 * .pi * ringFreq / sr
            let ringSample = sin(ringPhase) * ringDecay * 0.18

            // ── E) Settle click (100–118 ms) ─────────────────────────────────
            // A short wideband burst; sounds like the card landing flat.
            var settleSample: Double = 0.0
            if t >= settleOnset && t < (settleOnset + settleLen) {
                let q = (t - settleOnset) / settleLen   // 0 → 1 within burst
                let settleEnv = q < 0.08 ? q / 0.08 : exp(-30.0 * (q - 0.08))
                settleSample = Double.random(in: -1...1) * settleEnv * 0.28
            }

            // ── Stereo pan: left→right with sine-arc ─────────────────────────
            // Layers B and C pan; A, D, E stay center (they're very short).
            let panAngle = p * .pi
            let panL = cos(panAngle / 2)
            let panR = sin(panAngle / 2)

            let panMono   = (chirpSample + noiseSample)               // panned
            let centerMono = (clickSample + ringSample + settleSample) // center

            chL[i] = Float((panMono * panL + centerMono) * 0.62)
            chR[i] = Float((panMono * panR + centerMono) * 0.62)
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

    // MARK: - Chirp (smooth frequency glide — kept for potential future use)
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
