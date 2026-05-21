import KeyboardKit
import UIKit

/// Autocomplete service powered by Apple's built-in UITextChecker.
/// Free, offline, uses the system dictionary. No Pro license needed.
class UITextCheckerAutocompleteService: AutocompleteService {

    var locale: Locale = .current

    private let checker = UITextChecker()
    private var _ignoredWords: Set<String> = []
    private var _learnedWords: Set<String> = []

    var maxSuggestionCount: Int = 3

    private var language: String {
        locale.language.languageCode?.identifier ?? "en"
    }

    // MARK: - Core Autocomplete

    func autocomplete(_ text: String) async throws -> Autocomplete.Result {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            return Autocomplete.Result(inputText: text, suggestions: [])
        }

        let words = trimmed.components(separatedBy: .whitespaces)
        let currentWord = words.last ?? ""
        guard !currentWord.isEmpty else {
            return Autocomplete.Result(inputText: text, suggestions: [])
        }

        var suggestions: [Autocomplete.Suggestion] = []

        let wordRange = NSRange(0..<currentWord.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(
            in: currentWord,
            range: wordRange,
            startingAt: 0,
            wrap: false,
            language: language
        )

        if misspelledRange.location != NSNotFound {
            // Word is misspelled — get corrections
            let guesses = checker.guesses(
                forWordRange: misspelledRange,
                in: currentWord,
                language: language
            ) ?? []

            for (i, guess) in guesses.prefix(maxSuggestionCount).enumerated() {
                if _ignoredWords.contains(guess.lowercased()) { continue }
                let type: Autocomplete.SuggestionType = (i == 0) ? .autocorrect : .regular
                suggestions.append(
                    Autocomplete.Suggestion(text: guess, type: type)
                )
            }
        } else {
            // Word is valid or partial — get completions
            suggestions.append(
                Autocomplete.Suggestion(text: currentWord, type: .regular)
            )

            let completions = checker.completions(
                forPartialWordRange: wordRange,
                in: currentWord,
                language: language
            ) ?? []

            for completion in completions.prefix(maxSuggestionCount - 1) {
                if completion.lowercased() == currentWord.lowercased() { continue }
                if _ignoredWords.contains(completion.lowercased()) { continue }
                suggestions.append(
                    Autocomplete.Suggestion(text: completion, type: .regular)
                )
            }
        }

        // Add learned words matching the prefix
        let matchingLearned = _learnedWords.filter {
            $0.lowercased().hasPrefix(currentWord.lowercased()) &&
            $0.lowercased() != currentWord.lowercased()
        }.sorted().prefix(2)

        for word in matchingLearned {
            if !suggestions.contains(where: { $0.text.lowercased() == word.lowercased() }) {
                suggestions.insert(
                    Autocomplete.Suggestion(text: word, type: .regular),
                    at: min(1, suggestions.count)
                )
            }
        }

        suggestions = Array(suggestions.prefix(maxSuggestionCount))
        return Autocomplete.Result(inputText: text, suggestions: suggestions)
    }

    // MARK: - Ignore / Learn

    var canIgnoreWords: Bool { true }
    var canLearnWords: Bool { true }
    var ignoredWords: [String] { Array(_ignoredWords) }
    var learnedWords: [String] { Array(_learnedWords) }

    func hasIgnoredWord(_ word: String) -> Bool { _ignoredWords.contains(word.lowercased()) }
    func hasLearnedWord(_ word: String) -> Bool { _learnedWords.contains(word.lowercased()) }

    func ignoreWord(_ word: String) { _ignoredWords.insert(word.lowercased()) }
    func learnWord(_ word: String) {
        _learnedWords.insert(word)
        UITextChecker.learnWord(word)
    }

    func removeIgnoredWord(_ word: String) { _ignoredWords.remove(word.lowercased()) }
    func unlearnWord(_ word: String) {
        _learnedWords.remove(word)
        UITextChecker.unlearnWord(word)
    }
}
