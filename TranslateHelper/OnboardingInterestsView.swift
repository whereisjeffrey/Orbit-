//  OnboardingInterestsView.swift

import SwiftUI

struct Interest: Identifiable, Hashable {
    let id: String
    let emoji: String
    let label: String
}

let allInterests: [Interest] = [
    Interest(id: "remote_work",  emoji: "💻", label: "Remote work"),
    Interest(id: "nightlife",    emoji: "🎉", label: "Nightlife"),
    Interest(id: "food",         emoji: "🍽️", label: "Food & dining"),
    Interest(id: "arts",         emoji: "🎨", label: "Arts & culture"),
    Interest(id: "outdoors",     emoji: "🏃", label: "Outdoor activities"),
    Interest(id: "wellness",     emoji: "🧘", label: "Wellness"),
    Interest(id: "music",        emoji: "🎵", label: "Live music"),
    Interest(id: "lgbtq",        emoji: "🏳️‍🌈", label: "LGBTQ+ community"),
    Interest(id: "family",       emoji: "🏡", label: "Family life"),
    Interest(id: "news",         emoji: "📰", label: "News & events"),
    Interest(id: "history",      emoji: "🏛️", label: "History"),
    Interest(id: "markets",      emoji: "🧺", label: "Markets"),
    Interest(id: "language",     emoji: "💬", label: "Language learning"),
    Interest(id: "photography",  emoji: "📷", label: "Photography"),
]

struct OnboardingInterestsView: View {
    let onBack: () -> Void
    let onContinue: () -> Void

    @AppStorage("user_interests") private var savedInterests = ""
    @State private var selected: Set<String> = []

    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack { TSGradientBackground()
            VStack(spacing: 0) {

                // ── Nav bar with progress ──────────────────────────────
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.tsLabel)
                    }
                    .frame(width: 40, height: 40)

                    Spacer()

                    OnboardingProgressBar(currentStep: 5, totalSteps: 6)

                    Spacer()
                    if !selected.isEmpty {
                        Text("\(selected.count) selected")
                            .font(.custom("HelveticaNeue", size: 14))
                            .foregroundColor(.tsAccent)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {

                        // ── Header ─────────────────────────────────
                        VStack(spacing: 12) {
                            Text("What are you into?")
                                .font(.custom("HelveticaNeue-Bold", size: 30))
                                .foregroundColor(.tsLabel)
                                .multilineTextAlignment(.center)
                            Text("Your speaking coach will weave these\ninto your conversations. Pick as many as you want.")
                                .font(.custom("HelveticaNeue", size: 16))
                                .foregroundColor(.tsSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 32)

                        // ── Interest grid ──────────────────────────
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(allInterests) { interest in
                                InterestTile(
                                    interest: interest,
                                    isSelected: selected.contains(interest.id)
                                ) {
                                    if selected.contains(interest.id) {
                                        selected.remove(interest.id)
                                    } else {
                                        selected.insert(interest.id)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 32)
                }

                // ── CTA ────────────────────────────────────────────
                VStack(spacing: 16) {
                    TSButton(title: selected.isEmpty ? "Continue" : "Continue →") {
                        savedInterests = selected.joined(separator: ",")
                        onContinue()
                    }
                    if selected.isEmpty {
                        Button(action: {
                            savedInterests = ""
                            onContinue()
                        }) {
                            Text("Skip for now")
                                .font(.custom("HelveticaNeue", size: 15))
                                .foregroundColor(.tsSecondary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}

struct InterestTile: View {
    let interest: Interest
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                Text(interest.emoji)
                    .font(.custom("HelveticaNeue", size: 32))
                Text(interest.label)
                    .font(.custom("HelveticaNeue-Medium", size: 14))
                    .foregroundColor(.tsLabel)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.tsAccent.opacity(0.08) : Color.tsCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.tsAccent : Color.tsBorder, lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
