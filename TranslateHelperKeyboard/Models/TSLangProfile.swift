import Foundation

struct TSLangProfile {
    let code: String
    let deepL: TranslationService.Language
    let flag: String
    let name: String
    let emojiFont: Bool
}

let TSProfiles: [String: TSLangProfile] = [
    // Tier 1 — DeepL supported
    "en": TSLangProfile(code: "en", deepL: .english,      flag: "🇺🇸", name: "ENGLISH",     emojiFont: true),
    "pt": TSLangProfile(code: "pt", deepL: .portugueseBR,  flag: "🇧🇷", name: "PORTUGUESE",  emojiFont: true),
    "es": TSLangProfile(code: "es", deepL: .spanish,       flag: "🇪🇸", name: "SPANISH",     emojiFont: true),
    "fr": TSLangProfile(code: "fr", deepL: .french,        flag: "🇫🇷", name: "FRENCH",      emojiFont: true),
    "de": TSLangProfile(code: "de", deepL: .german,        flag: "🇩🇪", name: "GERMAN",      emojiFont: true),
    "it": TSLangProfile(code: "it", deepL: .italian,       flag: "🇮🇹", name: "ITALIAN",     emojiFont: true),
    "ja": TSLangProfile(code: "ja", deepL: .japanese,      flag: "🇯🇵", name: "JAPANESE",    emojiFont: true),
    "ko": TSLangProfile(code: "ko", deepL: .korean,        flag: "🇰🇷", name: "KOREAN",      emojiFont: true),
    "ar": TSLangProfile(code: "ar", deepL: .arabic,        flag: "🇦🇪", name: "ARABIC",      emojiFont: true),
    "zh": TSLangProfile(code: "zh", deepL: .chinese,       flag: "🇨🇳", name: "CHINESE",     emojiFont: true),
    "ru": TSLangProfile(code: "ru", deepL: .russian,       flag: "🇷🇺", name: "RUSSIAN",     emojiFont: true),
    "nl": TSLangProfile(code: "nl", deepL: .dutch,         flag: "🇳🇱", name: "DUTCH",       emojiFont: true),
    "pl": TSLangProfile(code: "pl", deepL: .polish,        flag: "🇵🇱", name: "POLISH",      emojiFont: true),
    "tr": TSLangProfile(code: "tr", deepL: .turkish,       flag: "🇹🇷", name: "TURKISH",     emojiFont: true),
    "uk": TSLangProfile(code: "uk", deepL: .ukrainian,     flag: "🇺🇦", name: "UKRAINIAN",   emojiFont: true),
    "cs": TSLangProfile(code: "cs", deepL: .czech,         flag: "🇨🇿", name: "CZECH",       emojiFont: true),
    "ro": TSLangProfile(code: "ro", deepL: .romanian,      flag: "🇷🇴", name: "ROMANIAN",    emojiFont: true),
    "bg": TSLangProfile(code: "bg", deepL: .bulgarian,     flag: "🇧🇬", name: "BULGARIAN",   emojiFont: true),
    "el": TSLangProfile(code: "el", deepL: .greek,         flag: "🇬🇷", name: "GREEK",       emojiFont: true),
    "sv": TSLangProfile(code: "sv", deepL: .swedish,       flag: "🇸🇪", name: "SWEDISH",     emojiFont: true),
    "da": TSLangProfile(code: "da", deepL: .danish,        flag: "🇩🇰", name: "DANISH",      emojiFont: true),
    "no": TSLangProfile(code: "no", deepL: .norwegian,     flag: "🇳🇴", name: "NORWEGIAN",   emojiFont: true),
    "fi": TSLangProfile(code: "fi", deepL: .finnish,       flag: "🇫🇮", name: "FINNISH",     emojiFont: true),
    "hu": TSLangProfile(code: "hu", deepL: .hungarian,     flag: "🇭🇺", name: "HUNGARIAN",   emojiFont: true),
    "sk": TSLangProfile(code: "sk", deepL: .slovak,        flag: "🇸🇰", name: "SLOVAK",      emojiFont: true),
    "id": TSLangProfile(code: "id", deepL: .indonesian,    flag: "🇮🇩", name: "INDONESIAN",  emojiFont: true),
    "vi": TSLangProfile(code: "vi", deepL: .vietnamese,    flag: "🇻🇳", name: "VIETNAMESE",  emojiFont: true),
    "he": TSLangProfile(code: "he", deepL: .hebrew,        flag: "🇮🇱", name: "HEBREW",      emojiFont: true),
    "hr": TSLangProfile(code: "hr", deepL: .croatian,      flag: "🇭🇷", name: "CROATIAN",    emojiFont: true),
    // Tier 2 — GPT-only
    "hi": TSLangProfile(code: "hi", deepL: .hindi,         flag: "🇮🇳", name: "HINDI",       emojiFont: true),
    "bn": TSLangProfile(code: "bn", deepL: .bengali,       flag: "🇧🇩", name: "BENGALI",     emojiFont: true),
    "ur": TSLangProfile(code: "ur", deepL: .urdu,          flag: "🇵🇰", name: "URDU",        emojiFont: true),
    "sw": TSLangProfile(code: "sw", deepL: .swahili,       flag: "🇰🇪", name: "SWAHILI",     emojiFont: true),
    "th": TSLangProfile(code: "th", deepL: .thai,          flag: "🇹🇭", name: "THAI",        emojiFont: true),
    "fa": TSLangProfile(code: "fa", deepL: .persian,       flag: "🇮🇷", name: "PERSIAN",     emojiFont: true),
    "ms": TSLangProfile(code: "ms", deepL: .malay,         flag: "🇲🇾", name: "MALAY",       emojiFont: true),
    "tl": TSLangProfile(code: "tl", deepL: .filipino,      flag: "🇵🇭", name: "FILIPINO",    emojiFont: true),
    "af": TSLangProfile(code: "af", deepL: .afrikaans,     flag: "🇿🇦", name: "AFRIKAANS",   emojiFont: true),
    "ta": TSLangProfile(code: "ta", deepL: .tamil,         flag: "🇮🇳", name: "TAMIL",       emojiFont: true),
    "ca": TSLangProfile(code: "ca", deepL: .catalan,       flag: "🇪🇸", name: "CATALAN",     emojiFont: true),
]
