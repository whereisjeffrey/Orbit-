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
    case pop        // subtle open/expand sound
    case saved      // success chime for saving

    /// System sound IDs — change these to update all features at once.
    var systemSoundID: SystemSoundID {
        switch self {
        case .correct:   return 1394  // System fanfare / success chime
        case .incorrect: return 1053  // System error / tock
        case .pop:       return 1306  // Subtle pop / begin
        case .saved:     return 1001  // Short success ping
        }
    }

    /// Play the sound + appropriate haptic feedback.
    func play() {
        AudioServicesPlaySystemSound(systemSoundID)

        let generator: UIImpactFeedbackGenerator
        switch self {
        case .correct, .saved:
            generator = UIImpactFeedbackGenerator(style: .light)
        case .incorrect:
            generator = UIImpactFeedbackGenerator(style: .medium)
        case .pop:
            generator = UIImpactFeedbackGenerator(style: .soft)
        }
        generator.impactOccurred()
    }
}
