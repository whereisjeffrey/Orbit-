//
//  Tone.swift
//  TranslateHelperKeyboard
//
//  Created by TalkSwitch on 15/02/26.
//

import Foundation

enum Tone: String, CaseIterable {
    case casual = "casual"
    case slang = "slang"
    case work = "work"
    case flirty = "flirty"
    
    var displayName: String {
        switch self {
        case .casual: return "Casual"
        case .slang: return "Slang"
        case .work: return "Work"
        case .flirty: return "Flirty"
        }
    }
    
    var emoji: String {
        switch self {
        case .casual: return "😊"
        case .slang: return "🗣️"
        case .work: return "💼"
        case .flirty: return "🔥"
        }
    }
}
