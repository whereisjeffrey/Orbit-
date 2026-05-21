import SwiftUI

/// Shows the translation result: original text (gray) + translated text (white).
/// Appears between the bar and keyboard after translating.
struct TranslationStrip: View {

    var originalText: String
    var translatedText: String
    var onSave: () -> Void
    var onWordTap: ((String) -> Void)?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(originalText)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(white: 0.5))
                    .lineLimit(1)

                Text(translatedText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onSave) {
                Image(systemName: "bookmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
            }
            .frame(width: 32)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(white: 0.08))
        .cornerRadius(8)
        .padding(.horizontal, 4)
    }
}
