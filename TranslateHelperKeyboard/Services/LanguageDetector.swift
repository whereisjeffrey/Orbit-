//
//  LanguageDetector.swift
//  TalkSwitch
//
//  Created by TalkSwitch on 15/02/26.
//

import Foundation
import NaturalLanguage

class LanguageDetector {
    
    /// Detects the dominant language in the given text
    /// - Parameter text: The text to analyze
    /// - Returns: ISO language code (e.g., "en", "pt", "es") or nil if detection fails
    func detectLanguage(from text: String) -> String? {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        guard let dominantLanguage = recognizer.dominantLanguage else {
            return nil
        }
        
        // Convert NLLanguage to ISO code string
        return dominantLanguage.rawValue
    }
    
    /// Detects language with confidence score
    /// - Parameter text: The text to analyze
    /// - Returns: Tuple of (language code, confidence) or nil if detection fails
    func detectLanguageWithConfidence(from text: String) -> (language: String, confidence: Double)? {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        guard let dominantLanguage = recognizer.dominantLanguage else {
            return nil
        }
        
        let hypotheses = recognizer.languageHypotheses(withMaximum: 1)
        let confidence = hypotheses[dominantLanguage] ?? 0.0
        
        return (dominantLanguage.rawValue, confidence)
    }
}
