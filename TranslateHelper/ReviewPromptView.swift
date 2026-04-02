//
//  ReviewPromptView.swift
//  TranslateHelper
//
//  "Are you enjoying Orbit?" card — shown on the Library tab.
//  Yes → Apple review prompt. Not yet → feedback email.
//

import SwiftUI

struct ReviewPromptCard: View {
    @Binding var isShowing: Bool

    var body: some View {
        VStack(spacing: 14) {
            Text("Are you enjoying Orbit?")
                .font(.custom("HelveticaNeue-Bold", size: 16))
                .foregroundColor(.tsLabel)

            Text("Your feedback helps us make Orbit better for everyone.")
                .font(.custom("HelveticaNeue", size: 13))
                .foregroundColor(.tsSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                // Not yet → feedback
                Button {
                    ReviewPromptManager.openFeedback()
                    withAnimation(.easeOut(duration: 0.2)) {
                        isShowing = false
                    }
                } label: {
                    Text("Not yet")
                        .font(.custom("HelveticaNeue-Medium", size: 14))
                        .foregroundColor(.tsSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            Capsule()
                                .fill(Color.tsSecondary.opacity(0.08))
                        )
                }

                // Yes → Apple review
                Button {
                    ReviewPromptManager.requestReview()
                    withAnimation(.easeOut(duration: 0.2)) {
                        isShowing = false
                    }
                } label: {
                    Text("Yes! ⭐")
                        .font(.custom("HelveticaNeue-Bold", size: 14))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            Capsule()
                                .fill(Color.tsAccent)
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#F3F9FB"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.tsAccent.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}
