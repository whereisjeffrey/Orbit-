import SwiftUI
import AppIntents

struct StudyRevealedCardView: View {
    @Environment(\.dismiss) var dismiss
    let phrases: [SavedPhrase]
    @Binding var currentIndex: Int
    @AppStorage("studyModeSwapLanguage") private var swapLanguage: Bool = false
    
    var currentPhrase: SavedPhrase? {
        guard currentIndex < phrases.count else { return nil }
        return phrases[currentIndex]
    }
    
    var body: some View {
        ZStack {
            Color.tsBackground.ignoresSafeArea()
            
            if let phrase = currentPhrase {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.tsAccent)
                                .frame(width: 40, height: 40)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Text("Study Mode")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.tsLabel)
                            Text("\(currentIndex + 1) OF \(phrases.count) CARDS")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.tsSecondary)
                                .tracking(1.5)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.tsSecondary)
                                .frame(width: 40, height: 40)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    
                    // Main Card
                    VStack(spacing: 0) {
                        
                        // Language Switch Pill
                        HStack(spacing: 8) {
                            HStack(spacing: 4) {
                                let leftLang = swapLanguage ? phrase.targetLang : phrase.sourceLang
                                Text(leftLang == "en" ? "🇺🇸" : "🇲🇽").font(.system(size: 16))
                                Text(leftLang == "en" ? "English" : "Spanish")
                                    .font(.system(size: 12, weight: .semibold)).foregroundColor(.tsLabel)
                            }
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.tsSecondary)
                            
                            HStack(spacing: 4) {
                                let rightLang = swapLanguage ? phrase.sourceLang : phrase.targetLang
                                Text(rightLang == "en" ? "🇺🇸" : "🇲🇽").font(.system(size: 16))
                                Text(rightLang == "en" ? "English" : "Spanish")
                                    .font(.system(size: 12, weight: .semibold)).foregroundColor(.tsLabel)
                            }
                            
                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    swapLanguage.toggle()
                                }
                            }) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.tsSecondary)
                            }
                            .padding(.leading, 4)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6).opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.tsBorder, lineWidth: 1))
                        .padding(.top, 24)
                        
                        Spacer()
                        
                        // Main Content Area
                        VStack(spacing: 40) {
                            // Source Word
                            VStack(spacing: 8) {
                                Text("SOURCE WORD")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.tsSecondary)
                                    .tracking(1.5)
                                
                                Text(swapLanguage ? phrase.translatedText : phrase.sourceText)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.tsLabel)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            // Translation
                            VStack(spacing: 8) {
                                Text("TRANSLATION")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.tsSecondary)
                                    .tracking(1.5)
                                
                                Text(swapLanguage ? phrase.sourceText : phrase.translatedText)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.tsLabel)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            // Audio Button
                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                
                                let targetText = swapLanguage ? phrase.sourceText : phrase.translatedText
                                let targetLangCode = swapLanguage ? phrase.sourceLang : phrase.targetLang
                                let langCode = targetLangCode == "en" ? "en-US" : "es-MX"
                                
                                TTSService.shared.speak(targetText, language: langCode)
                            }) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.tsAccent)
                                    .frame(width: 56, height: 56)
                                    .background(Color.tsAccent.opacity(0.15))
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.tsAccent, lineWidth: 1.5))
                            }
                        }
                        // Context Box
                        Spacer()
                        if let notes = phrase.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 6) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(Color(hex: "D4AF37"))
                                        .font(.system(size: 14))
                                    Text("CULTURAL CONTEXT")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Color(hex: "D4AF37"))
                                        .tracking(1.5)
                                }
                                
                                Text(notes)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.tsLabel.opacity(0.9))
                                    .lineSpacing(4)
                            }
                            .padding(20)
                            .background(
                                ZStack {
                                    Color(UIColor { $0.userInterfaceStyle == .dark ? .clear : .systemBackground })
                                    Color(hex: "D4AF37").opacity(0.1)
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "D4AF37").opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        } else {
                            Spacer().frame(height: 24)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.tsCard)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(Color.tsBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Footer Buttons
                    Spacer().frame(height: 24)
                    
                    HStack(spacing: 12) {
                        RatingButton(title: "Again", time: "< 1 MIN", color: Color(hex: "FF453A")) { nextCard() }
                        RatingButton(title: "Hard", time: "6 MIN", color: Color(hex: "FF9F0A")) { nextCard() }
                        RatingButton(title: "Good", time: "10 MIN", color: Color(hex: "30D158")) { nextCard() }
                        RatingButton(title: "Easy", time: "3 DAYS", color: Color(hex: "0A84FF")) { nextCard() }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            } else {
                EmptyView() // Handled by StudySourceWordView completion UI
            }
        }
        .navigationBarHidden(true)
    }
    
    private func nextCard() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Return to Front face (StudySourceWordView) while indexing the card
        if currentIndex < phrases.count {
            currentIndex += 1
        }
        dismiss()
    }
}

struct RatingButton: View {
    let title: String
    let time: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
                
                Text(time)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(color.opacity(0.6))
                    .tracking(1.0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
