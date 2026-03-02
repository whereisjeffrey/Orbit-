import SwiftUI

struct StudyRevealedCardView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.tsBackground.ignoresSafeArea()
            
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
                        Text("12 OF 45 CARDS")
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
                            Text("🇧🇷").font(.system(size: 16))
                            Text("Portuguese").font(.system(size: 12, weight: .semibold)).foregroundColor(.tsLabel)
                        }
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.tsSecondary)
                        
                        HStack(spacing: 4) {
                            Text("🇺🇸").font(.system(size: 16))
                            Text("English").font(.system(size: 12, weight: .semibold)).foregroundColor(.tsLabel)
                        }
                        
                        Button(action: {}) {
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
                            
                            Text("saudades")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.tsLabel)
                        }
                        
                        // Translation
                        VStack(spacing: 8) {
                            Text("ENGLISH TRANSLATION")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.tsSecondary)
                                .tracking(1.5)
                            
                            Text("Longing / Missing")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.tsLabel)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Audio Button
                        Button(action: {}) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.tsAccent)
                                .frame(width: 56, height: 56)
                                .background(Color.tsAccent.opacity(0.15))
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                    
                    // Context Box
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
                        
                        Text("A deep emotional state of nostalgic or profound melancholic longing for an absent something or someone that one cares for and/or loves.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.tsLabel.opacity(0.9))
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .background(Color.tsBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.tsBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
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
                    RatingButton(title: "Again", time: "< 1 MIN", color: Color(hex: "FF453A"))
                    RatingButton(title: "Hard", time: "6 MIN", color: Color(hex: "FF9F0A"))
                    RatingButton(title: "Good", time: "10 MIN", color: Color(hex: "30D158"))
                    RatingButton(title: "Easy", time: "3 DAYS", color: Color(hex: "0A84FF"))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
}

struct RatingButton: View {
    let title: String
    let time: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
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


