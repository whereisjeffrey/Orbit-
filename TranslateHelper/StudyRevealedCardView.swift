import SwiftUI
import AppIntents

struct StudyRevealedCardView: View {
    @Environment(\.dismiss) var dismiss
    let phrases: [SavedPhrase]
    @Binding var currentIndex: Int
    @AppStorage("studyModeSwapLanguage") private var swapLanguage: Bool = false
    
    /// Holds the pending auto-play work item so it can be cancelled on disappear.
    @State private var autoPlayTask: DispatchWorkItem?
    
    var currentPhrase: SavedPhrase? {
        guard currentIndex < phrases.count else { return nil }
        return phrases[currentIndex]
    }
    
    var body: some View {
        ZStack {
            TSGradientBackground()
                .ignoresSafeArea()
            
            if let phrase = currentPhrase {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.custom("HelveticaNeue-Bold", size: 24))
                                .foregroundColor(.tsAccent)
                                .frame(width: 40, height: 40)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Text("Study Mode")
                                .font(.custom("HelveticaNeue-Bold", size: 18))
                                .foregroundColor(.tsLabel)
                            Text("\(currentIndex + 1) OF \(phrases.count) CARDS")
                                .font(.custom("HelveticaNeue-Medium", size: 10))
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
                                let leftCode = swapLanguage ? phrase.targetLang : phrase.sourceLang
                                let leftLang = allLanguages.first(where: { $0.code == leftCode })
                                Text(leftLang?.flag ?? "🏴").font(.custom("HelveticaNeue", size: 16))
                                Text(leftLang?.name ?? leftCode)
                                    .font(.custom("HelveticaNeue-Medium", size: 12)).foregroundColor(.tsLabel)
                            }
                            
                            Image(systemName: "arrow.right")
                                .font(.custom("HelveticaNeue-Bold", size: 12))
                                .foregroundColor(.tsSecondary)
                            
                            HStack(spacing: 4) {
                                let rightCode = swapLanguage ? phrase.sourceLang : phrase.targetLang
                                let rightLang = allLanguages.first(where: { $0.code == rightCode })
                                Text(rightLang?.flag ?? "🏴").font(.custom("HelveticaNeue", size: 16))
                                Text(rightLang?.name ?? rightCode)
                                    .font(.custom("HelveticaNeue-Medium", size: 12)).foregroundColor(.tsLabel)
                            }
                            
                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    swapLanguage.toggle()
                                }
                            }) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.custom("HelveticaNeue-Bold", size: 14))
                                    .foregroundColor(.tsSecondary)
                            }
                            .padding(.leading, 4)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.tsGrayCard)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color(.systemGray4), lineWidth: 0.5))
                        .padding(.top, 24)
                        
                        Spacer()
                        
                        // Main Content Area
                        VStack(spacing: 40) {
                            // Source Word
                            VStack(spacing: 8) {
                                Text("SOURCE WORD")
                                    .font(.custom("HelveticaNeue-Bold", size: 10))
                                    .foregroundColor(.tsSecondary)
                                    .tracking(1.5)
                                
                                Text(swapLanguage ? phrase.translatedText : phrase.sourceText)
                                    .font(.custom("HelveticaNeue-Bold", size: 24))
                                    .foregroundColor(.tsLabel)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            // Translation
                            VStack(spacing: 8) {
                                Text("TRANSLATION")
                                    .font(.custom("HelveticaNeue-Bold", size: 10))
                                    .foregroundColor(.tsSecondary)
                                    .tracking(1.5)
                                
                                Text(swapLanguage ? phrase.sourceText : phrase.translatedText)
                                    .font(.custom("HelveticaNeue-Medium", size: 24))
                                    .foregroundColor(.tsLabel)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            // Audio Button
                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                
                                // Always speak the language being learned (target lang), regardless of card orientation
                                let langCode = TTSService.bcp47Locale(for: phrase.targetLang)
                                TTSService.shared.speak(phrase.translatedText, language: langCode)
                            }) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.custom("HelveticaNeue", size: 24))
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
                                        .foregroundColor(Color(hex: "F5A623"))
                                        .font(.custom("HelveticaNeue", size: 14))
                                    Text("CULTURAL CONTEXT")
                                        .font(.custom("HelveticaNeue-Bold", size: 11))
                                        .foregroundColor(Color(hex: "F5A623"))
                                        .tracking(1.5)
                                }
                                
                                Text(notes)
                                    .font(.custom("HelveticaNeue-Medium", size: 14))
                                    .foregroundColor(.tsLabel.opacity(0.9))
                                    .lineSpacing(4)
                            }
                            .padding(20)
                            .background(
                                Color(UIColor { trait in
                                    trait.userInterfaceStyle == .dark
                                        ? UIColor(red: 0.96, green: 0.65, blue: 0.14, alpha: 0.10)
                                        : UIColor(red: 1.0, green: 0.97, blue: 0.88, alpha: 1.0)
                                })
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "F5A623").opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        } else {
                            Spacer().frame(height: 24)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.tsGrayCard)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(Color(hex: "0A84FF").opacity(0.55), lineWidth: 1)
                    )
                    .shadow(color: Color(hex: "0A84FF").opacity(0.45), radius: 14, x: 0, y: 0)
                    .shadow(color: Color(hex: "0A84FF").opacity(0.22), radius: 30, x: 0, y: 0)
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
        .onAppear {
            guard let phrase = currentPhrase else { return }
            // Always speak the target (learning) language — same logic as the manual button.
            let langCode = TTSService.bcp47Locale(for: phrase.targetLang)
            let text = phrase.translatedText
            let task = DispatchWorkItem {
                TTSService.shared.speak(text, language: langCode)
            }
            autoPlayTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: task)
        }
        .onDisappear {
            autoPlayTask?.cancel()
            autoPlayTask = nil
            TTSService.shared.stopSpeaking()
        }
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
                    .font(.custom("HelveticaNeue-Bold", size: 16))
                    .foregroundColor(color)
                
                Text(time)
                    .font(.custom("HelveticaNeue-Bold", size: 10))
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
