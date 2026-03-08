import SwiftUI
import AVFoundation

struct StudySourceWordView: View {
    @Environment(\.dismiss) var dismiss
    let phrases: [SavedPhrase]
    var listName: String = "Clipboard List"
    @State private var currentIndex: Int = 0
    @State private var isFlipped: Bool = false
    @State private var showingOptions: Bool = false
    @State private var showPhraseList: Bool = false
    @State private var showConfetti: Bool = false
    @State private var showCompletionUI: Bool = false
    @State private var sessionJustCompleted: Bool = false

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
                        
                        Button(action: { showingOptions = true }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.tsSecondary)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    
                    // Main Card Container
                    ZStack {
                        // FRONT OF CARD
                        FrontCardView(phrase: phrase)
                            .opacity(isFlipped ? 0 : 1)
                            .rotation3DEffect(.degrees(isFlipped ? -180 : 0), axis: (x: 0, y: 1, z: 0))
                            .zIndex(isFlipped ? 0 : 1)
                        
                        // BACK OF CARD
                        BackCardView(phrase: phrase)
                            .opacity(isFlipped ? 1 : 0)
                            .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (x: 0, y: 1, z: 0))
                            .zIndex(isFlipped ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor { trait in
                        trait.userInterfaceStyle == .dark
                            ? UIColor(hex: "#1E1E1E")
                            : UIColor(hex: "#F6F5F9")
                    }))
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .onTapGesture {
                        if !isFlipped {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            SoundEngine.shared.play(.flip)
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                                isFlipped = true
                            }
                        }
                    }
                    
                    // Footer Section (Rating Buttons or Spacing)
                    Spacer().frame(height: 24)
                    
                    ZStack {
                        if isFlipped {
                            HStack(spacing: 12) {
                                RatingButton(title: "Again", time: "< 1 MIN", color: Color(hex: "FF453A")) { handleRating(rating: 1) }
                                RatingButton(title: "Hard", time: "6 MIN", color: Color(hex: "FF9F0A")) { handleRating(rating: 2) }
                                RatingButton(title: "Good", time: "10 MIN", color: Color(hex: "30D158")) { handleRating(rating: 3) }
                                RatingButton(title: "Easy", time: "3 DAYS", color: Color(hex: "0A84FF")) { handleRating(rating: 4) }
                            }
                            .padding(.horizontal, 16)
                            .transition(.opacity) // Use opacity for a simple slow fade in
                        } else {
                            // Bottom Spacing to prevent layout jump
                            Spacer().frame(height: 80)
                        }
                    }
                    .frame(height: 80)
                    .padding(.bottom, 40)
                    // 2.0-second slow fade-in when revealing, 0.2s quick fade-out when hiding
                    .animation(isFlipped ? .easeInOut(duration: 2.0) : .easeOut(duration: 0.2), value: isFlipped)
                }
            } else {
                ZStack {
                    // Confetti layer — stays alive on its own; doesn't control UI visibility
                    if showConfetti {
                        ConfettiView()
                            .ignoresSafeArea()
                            .allowsHitTesting(false)
                    }

                    VStack(spacing: 20) {
                        // Animated trophy icon
                        // Uses showCompletionUI so it is NEVER hidden again after appearing
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color.yellow.opacity(0.35), Color.orange.opacity(0.1), Color.clear],
                                        center: .center,
                                        startRadius: 10,
                                        endRadius: 70
                                    )
                                )
                                .frame(width: 140, height: 140)
                            Text("🏆")
                                .font(.custom("HelveticaNeue", size: 72))
                                .scaleEffect(showCompletionUI ? 1.12 : 0.6)
                                .opacity(showCompletionUI ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1), value: showCompletionUI)
                        }

                        Text("Session Complete!")
                            .font(.custom("HelveticaNeue-Bold", size: 28))
                            .foregroundColor(.tsLabel)
                            .opacity(showCompletionUI ? 1 : 0)
                            .offset(y: showCompletionUI ? 0 : 20)
                            .animation(.easeOut(duration: 0.45).delay(0.25), value: showCompletionUI)

                        Text("You've reviewed all phrases. 🎉")
                            .font(.custom("HelveticaNeue-Medium", size: 16))
                            .foregroundColor(.tsSecondary)
                            .multilineTextAlignment(.center)
                            .opacity(showCompletionUI ? 1 : 0)
                            .offset(y: showCompletionUI ? 0 : 16)
                            .animation(.easeOut(duration: 0.45).delay(0.38), value: showCompletionUI)

                        Button(action: { dismiss() }) {
                            Text("Done")
                                .font(.custom("HelveticaNeue-Bold", size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 14)
                                .background(Color.tsAccent)
                                .clipShape(Capsule())
                        }
                        .padding(.top, 16)
                        .opacity(showCompletionUI ? 1 : 0)
                        .scaleEffect(showCompletionUI ? 1 : 0.85)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.5), value: showCompletionUI)
                    }
                }
                .onAppear {
                    guard !sessionJustCompleted else { return }
                    sessionJustCompleted = true

                    // Animate the completion UI in — this never goes back to false
                    withAnimation { showCompletionUI = true }

                    // Start confetti — ConfettiView self-stops its emitter after 3.5 s
                    showConfetti = true

                    // Victory haptics
                    let notify = UINotificationFeedbackGenerator()
                    notify.notificationOccurred(.success)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        let impact = UIImpactFeedbackGenerator(style: .heavy)
                        impact.impactOccurred()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                    }

                    // Victory sound (system fanfare)
                    AudioServicesPlaySystemSound(1394)
                }
            }
        }
        .sheet(isPresented: $showingOptions) {
            StudyOptionsCard(
                listName: listName,
                onSeeList: { showPhraseList = true }
            )
            .presentationDetents([.height(440)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showPhraseList) {
            DeckPhraseListView(phrases: phrases, deckName: listName)
        }
        .navigationBarHidden(true)
    }

    private func handleRating(rating: Int) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        let ratingSound: SoundEngine.Sound = rating == 1 ? .again : rating == 2 ? .hard : rating == 3 ? .good : .easy
        SoundEngine.shared.play(ratingSound)
        
        if var phrase = currentPhrase {
            // Apply SM-2 spaced repetition logic
            if rating < 3 {
                // Again (1) or Hard (2) -> failed/struggled
                phrase.repetitions = 0
                phrase.interval = rating == 1 ? 1 : 10 // 1 minute or 10 minutes
                // Reduce easiness factor slightly (but not below 1.3)
                phrase.easinessFactor = max(1.3, phrase.easinessFactor - 0.2)
            } else {
                // Good (3) or Easy (4) -> succeeding
                if phrase.repetitions == 0 {
                    phrase.interval = 1440 // 1 day
                } else if phrase.repetitions == 1 {
                    phrase.interval = 4320 // 3 days
                } else {
                    // Subsequent intervals: interval * EF
                    phrase.interval = Int(Double(phrase.interval) * phrase.easinessFactor)
                }
                
                phrase.repetitions += 1
                
                // Increase easiness factor if Easy
                if rating == 4 {
                    phrase.easinessFactor += 0.15
                    phrase.interval = Int(Double(phrase.interval) * 1.3) // Easy bonus interval
                }
            }
            
            // Calculate next review date by adding interval (in minutes) to current date
            phrase.nextReviewDate = Calendar.current.date(byAdding: .minute, value: phrase.interval, to: Date()) ?? Date()
            
            // "Graduation" Rule:
            // If the user has succeeded 3 times AND this rating was Easy, remove it from the clipboard.
            // This ensures the clipboard doesn't get bloated but accounts for users who don't check in frequently.
            if phrase.repetitions >= 3 && rating == 4 {
                SharedPhraseStore.shared.delete(phrase)
            } else {
                // Save the updated phrase back to the store
                SharedPhraseStore.shared.updatePhrase(phrase)
            }
        }
        
        SoundEngine.shared.play(.flip)   // same page-turn burst as reveal tap
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            // Flip back to front
            isFlipped = false
        }
        
        // Wait a tiny bit for the flip animation to start before changing content
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if currentIndex < phrases.count {
                currentIndex += 1
            }
        }
    }
}

// MARK: - Confetti View

import QuartzCore

struct ConfettiView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false

        let emitter = CAEmitterLayer()
        emitter.emitterShape = .line
        emitter.renderMode = .additive

        let colors: [UIColor] = [
            UIColor(red: 1.00, green: 0.84, blue: 0.00, alpha: 1), // gold
            UIColor(red: 0.04, green: 0.52, blue: 1.00, alpha: 1), // blue
            UIColor(red: 0.19, green: 0.82, blue: 0.35, alpha: 1), // green
            UIColor(red: 1.00, green: 0.23, blue: 0.19, alpha: 1), // red
            UIColor(red: 0.69, green: 0.32, blue: 1.00, alpha: 1), // purple
            UIColor(red: 1.00, green: 0.62, blue: 0.04, alpha: 1), // orange
            UIColor(red: 0.25, green: 0.94, blue: 0.94, alpha: 1), // cyan
        ]

        emitter.emitterCells = colors.flatMap { color -> [CAEmitterCell] in
            [makeCell(color: color, shape: "rect"),
             makeCell(color: color, shape: "circle")]
        }

        view.layer.addSublayer(emitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let bounds = UIScreen.main.bounds
            emitter.emitterPosition = CGPoint(x: bounds.midX, y: -10)
            emitter.emitterSize = CGSize(width: bounds.width * 1.2, height: 1)
        }

        // Self-stop the emitter after 3.5 s — existing particles keep falling until
        // their lifetime expires, then everything is naturally gone. No state change
        // needed on the SwiftUI side, so the Done button stays fully visible.
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            emitter.birthRate = 0
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let emitter = uiView.layer.sublayers?.first as? CAEmitterLayer else { return }
        let bounds = UIScreen.main.bounds
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: -10)
        emitter.emitterSize = CGSize(width: bounds.width * 1.2, height: 1)
    }

    private func makeCell(color: UIColor, shape: String) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 6
        cell.lifetime = 5.5
        cell.lifetimeRange = 1.5
        cell.velocity = CGFloat.random(in: 250...450)
        cell.velocityRange = 80
        cell.emissionLongitude = .pi // shoot downward
        cell.emissionRange = .pi / 5
        cell.spin = CGFloat.random(in: -4...4)
        cell.spinRange = 2
        cell.scale = CGFloat.random(in: 0.06...0.14)
        cell.scaleRange = 0.04
        cell.scaleSpeed = -0.012
        cell.alphaSpeed = -0.18
        cell.yAcceleration = 180 // gravity
        cell.xAcceleration = CGFloat.random(in: -30...30)
        cell.color = color.withAlphaComponent(0.9).cgColor

        // Draw a simple shape
        let size = CGSize(width: 10, height: shape == "circle" ? 10 : 6)
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            if shape == "circle" {
                ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
            } else {
                ctx.cgContext.fill(CGRect(origin: .zero, size: size))
            }
        }
        cell.contents = img.cgImage
        return cell
    }
}

// MARK: - SubViews

struct FrontCardView: View {
    let phrase: SavedPhrase
    @AppStorage("studyModeSwapLanguage") private var swapLanguage: Bool = false

    /// The language code and text currently shown as the "source" (question side)
    private var displaySourceLang: String {
        swapLanguage ? phrase.targetLang : phrase.sourceLang
    }
    private var displaySourceText: String {
        swapLanguage ? phrase.translatedText : phrase.sourceText
    }

    var body: some View {
        VStack(spacing: 0) {
            // Language Switch Pill
            LanguageSwitchPill(phrase: phrase)
                .padding(.top, 24)
            
            Spacer()
            
            // Source Word — clean, no labels
            Text(displaySourceText)
                .font(.custom("HelveticaNeue-Bold", size: 28))
                .foregroundColor(.tsLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Spacer()
            
            // Tap to reveal
            VStack(spacing: 12) {
                Image(systemName: "hand.tap.fill")
                    .font(.custom("HelveticaNeue", size: 28))
                    .foregroundColor(.tsAccent)
                
                Text("Tap to reveal")
                    .font(.custom("HelveticaNeue-Medium", size: 14))
                    .foregroundColor(.tsSecondary.opacity(0.5))
            }
            
            Spacer().frame(height: 40)
        }
    }
}

struct BackCardView: View {
    let phrase: SavedPhrase
    @AppStorage("studyModeSwapLanguage") private var swapLanguage: Bool = false

    /// Language code of the text currently shown as "source" (question side)
    private var displaySourceLang: String {
        swapLanguage ? phrase.targetLang : phrase.sourceLang
    }
    private var displaySourceText: String {
        swapLanguage ? phrase.translatedText : phrase.sourceText
    }

    /// Language code of the text currently shown as "translation" (answer side)
    private var displayTranslationLang: String {
        swapLanguage ? phrase.sourceLang : phrase.targetLang
    }
    private var displayTranslationText: String {
        swapLanguage ? phrase.sourceText : phrase.translatedText
    }

    var body: some View {
        VStack(spacing: 0) {
            // Language Switch Pill
            LanguageSwitchPill(phrase: phrase)
                .padding(.top, 24)
            
            Spacer()
            
            VStack(spacing: 20) {
                // Source word — no label
                Text(displaySourceText)
                    .font(.custom("HelveticaNeue-Medium", size: 20))
                    .foregroundColor(Color.primary.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // Divider — same visual width as context box
                Rectangle()
                    .fill(Color.tsSecondary.opacity(0.13))
                    .frame(height: 1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)

                // Translation — no label
                Text(displayTranslationText)
                    .font(.custom("HelveticaNeue-Medium", size: 20))
                    .foregroundColor(Color.primary.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // Extra space — ~50% more gap between translation and speaker (20 → 30)
                Spacer().frame(height: 10)
                
                // Audio Button — speaks the TRANSLATION (answer side) in its correct language
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()

                    // Always speak the language being learned (target = Spanish), regardless of card orientation
                    let langCode = phrase.targetLang == "en" ? "en-US" : "es-MX"
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
            Spacer()
            
            // Context Box — only shown when the card has cultural notes
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
                .padding(.horizontal, 12)
                .padding(.bottom, 24)
            } else {
                Spacer().frame(height: 24)
            }
        }
    }
}

struct LanguageSwitchPill: View {
    let phrase: SavedPhrase
    @AppStorage("studyModeSwapLanguage") private var swapLanguage: Bool = false
    
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                let leftLang = swapLanguage ? phrase.targetLang : phrase.sourceLang
                Text(leftLang == "en" ? "🇺🇸" : "🇲🇽").font(.custom("HelveticaNeue", size: 16))
                Text(leftLang == "en" ? "English" : "Spanish")
                    .font(.custom("HelveticaNeue-Medium", size: 12)).foregroundColor(.tsLabel)
            }
            
            Image(systemName: "arrow.right")
                .font(.custom("HelveticaNeue-Bold", size: 12))
                .foregroundColor(.tsSecondary)
            
            HStack(spacing: 4) {
                let rightLang = swapLanguage ? phrase.sourceLang : phrase.targetLang
                Text(rightLang == "en" ? "🇺🇸" : "🇲🇽").font(.custom("HelveticaNeue", size: 16))
                Text(rightLang == "en" ? "English" : "Spanish")
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
        .background(Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hex: "111111")
                : .white
        }))
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

