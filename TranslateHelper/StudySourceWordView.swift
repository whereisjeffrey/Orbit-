import SwiftUI

struct StudySourceWordView: View {
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
                NavigationLink(destination: StudyRevealedCardView()) {
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
                        .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
                        .padding(.top, 24)
                        
                        Spacer()
                        
                        // Source Word
                        VStack(spacing: 8) {
                            Text("SOURCE WORD")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.tsSecondary)
                                .tracking(1.5)
                            
                            Text("saudades")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.tsLabel)
                        }
                        
                        Spacer()
                        
                        // Tap to reveal
                        VStack(spacing: 12) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.tsSecondary)
                            
                            Text("Tap to reveal")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.tsSecondary)
                        }
                        .opacity(0.5)
                        
                        Spacer().frame(height: 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.tsCard)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Bottom Spacing
                Spacer().frame(height: 120) // Leave exact same space as buttons
            }
        }
        .navigationBarHidden(true)
    }
}
