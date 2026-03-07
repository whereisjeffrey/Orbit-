//  DeckPageView.swift — horizontal-swipe deck pages in Library
import SwiftUI

// MARK: - Swipe Hint Banner

struct SwipeDeckHint: View {
    var body: some View {
        HStack(spacing: 10) {
            Text("\u{1F4CB}")            // 📋
                .font(.system(size: 15))
            Text("Swipe right to explore your starter decks")
                .font(.custom("HelveticaNeue-Medium", size: 13))
                .foregroundColor(Color(hex: "#0079C6"))
            Spacer()
            Image(systemName: "arrow.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "#0079C6"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(hex: "#E8F4FF"))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(Color(hex: "#0079C6").opacity(0.25), lineWidth: 1))
    }
}

// MARK: - Deck Page

struct DeckPageView: View {
    let deck: Deck

    private var progress: Double {
        guard !deck.cards.isEmpty else { return 0 }
        return Double(deck.conqueredCards.count) / Double(deck.cards.count)
    }

    var body: some View {
        ZStack {
            TSGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text(deck.emoji)
                            .font(.system(size: 38))
                            .padding(.bottom, 2)
                        Text(deck.name)
                            .font(.custom("HelveticaNeue-Bold", size: 26))
                            .foregroundColor(.tsLabel)
                        Text("\(deck.conqueredCards.count) of \(deck.cards.count) conquered")
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 16)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(UIColor.systemGray5))
                                .frame(height: 6)
                            Capsule()
                                .fill(deck.tintColor)
                                .frame(width: geo.size.width * progress, height: 6)
                                .animation(.spring(response: 0.4), value: progress)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                    // Card list
                    VStack(spacing: 0) {
                        ForEach(Array(deck.cards.enumerated()), id: \.element.id) { idx, card in
                            DeckCardRow(card: card, tint: deck.tintColor)
                            if idx < deck.cards.count - 1 {
                                Divider().padding(.leading, 58)
                            }
                        }
                    }
                    .background(Color.tsCard)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Card Row

struct DeckCardRow: View {
    let card: DeckCard
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(card.isConquered ? tint.opacity(0.15) : Color(UIColor.systemGray6))
                    .frame(width: 32, height: 32)
                if card.isConquered {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(tint)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(card.spanish)
                    .font(.custom("HelveticaNeue-Medium", size: 14))
                    .foregroundColor(.tsLabel)
                Text(card.english)
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                    .lineLimit(1)
            }
            Spacer()
            if card.isConquered {
                Text("Conquered")
                    .font(.custom("HelveticaNeue", size: 11))
                    .foregroundColor(tint)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(tint.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
    }
}
