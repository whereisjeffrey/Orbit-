//
//  SoundManager.swift
//  TranslateHelper
//
//  Shared sound effects for the app. Used by flashcards, Lightning Round,
//  and any future quiz/drill UI. Change sounds here — they update everywhere.
//

import AudioToolbox
import UIKit

enum SoundEffect {
    case correct
    case incorrect

    /// System sound IDs — change these to update all features at once.
    var systemSoundID: SystemSoundID {
        switch self {
        case .correct:   return 1394  // System fanfare / success chime
        case .incorrect: return 1053  // System error / tock
        }
    }

    /// Play the sound + appropriate haptic feedback.
    func play() {
        AudioServicesPlaySystemSound(systemSoundID)

        let generator: UIImpactFeedbackGenerator
        switch self {
        case .correct:
            generator = UIImpactFeedbackGenerator(style: .light)
        case .incorrect:
            generator = UIImpactFeedbackGenerator(style: .medium)
        }
        generator.impactOccurred()
    }
}
