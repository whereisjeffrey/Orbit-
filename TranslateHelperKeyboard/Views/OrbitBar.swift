import SwiftUI

/// The Orbit action bar that sits above the keyboard fold.
/// Layout: [🎤] [  🌐 Translate  ] [😊 ▼] [📝 ▲]
/// Recording: [🔴 0:05  ···  Tap to cancel]
struct OrbitBar: View {

    @Binding var selectedTone: Tone
    @Binding var isNotesOpen: Bool
    @Binding var isToneExpanded: Bool
    var isRecording: Bool = false
    var recordingSeconds: Int = 0
    var onTranslate: () -> Void
    var onMic: () -> Void

    private let darkButtonBg = Color(red: 0.28, green: 0.28, blue: 0.29)

    var body: some View {
        if isRecording {
            // Recording state — full-width recording bar
            Button(action: onMic) {
                HStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                    Text(formatTime(recordingSeconds))
                        .font(.system(size: 15, weight: .medium).monospacedDigit())
                        .foregroundColor(.white)
                    Spacer()
                    Text("Tap to cancel")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(white: 0.5))
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(darkButtonBg)
                .cornerRadius(8)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        } else {
            // Normal state — action buttons
            HStack(spacing: 6) {
                // Mic button
                Button(action: onMic) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(darkButtonBg)
                        .cornerRadius(8)
                }

                // Translate button
                Button(action: onTranslate) {
                    HStack(spacing: 5) {
                        Image(systemName: "globe")
                            .font(.system(size: 14, weight: .medium))
                        Text("Translate")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(Color.blue)
                    .cornerRadius(8)
                }

                // Tone selector
                if isToneExpanded {
                    ForEach(Tone.allCases, id: \.self) { tone in
                        Button(action: {
                            selectedTone = tone
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isToneExpanded = false
                            }
                        }) {
                            HStack(spacing: 2) {
                                Text(tone.emoji)
                                    .font(.system(size: 12))
                                Text(tone.displayName)
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(tone == selectedTone ? .white : Color(white: 0.85))
                            .padding(.horizontal, 6)
                            .frame(height: 36)
                            .background(tone == selectedTone ? Color.blue.opacity(0.8) : darkButtonBg)
                            .cornerRadius(8)
                        }
                    }
                } else {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isToneExpanded = true
                        }
                    }) {
                        HStack(spacing: 3) {
                            Text(selectedTone.emoji)
                                .font(.system(size: 16))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(Color(white: 0.6))
                        }
                        .frame(width: 44, height: 36)
                        .background(darkButtonBg)
                        .cornerRadius(8)
                    }
                }

                // Notes button
                if !isToneExpanded {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isNotesOpen.toggle()
                        }
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "note.text")
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: isNotesOpen ? "chevron.down" : "chevron.up")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(Color(white: 0.6))
                        }
                        .foregroundColor(.white)
                        .frame(width: 44, height: 36)
                        .background(darkButtonBg)
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
