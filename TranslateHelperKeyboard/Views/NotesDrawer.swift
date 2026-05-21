import SwiftUI

/// Notes drawer that slides up between the bar and keyboard.
/// Shows translation context, slang explanations, pronunciation.
/// Auto-closes when user starts typing.
struct NotesDrawer: View {

    var notesText: String
    var pronunciationText: String
    var onSaveToDeck: (() -> Void)?
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    if !notesText.isEmpty {
                        Text(notesText)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.white)
                            .lineLimit(3)
                    }
                    if !pronunciationText.isEmpty {
                        Text("🗣 \(pronunciationText)")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color(white: 0.6))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 8) {
                    // Close button
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(white: 0.5))
                    }

                    // Save button
                    if let save = onSaveToDeck {
                        Button(action: save) {
                            Image(systemName: "bookmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(white: 0.10))
        .cornerRadius(10)
        .padding(.horizontal, 4)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
