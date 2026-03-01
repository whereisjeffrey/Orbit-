//
//  LibraryView.swift
//  TranslateHelper
//

import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var searchText = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.tsBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Header ─────────────────────────────────────────
                    HStack {
                        Text("Library")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.tsLabel)
                        Spacer()
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.tsCard)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.tsAccent)
                                        .font(.system(size: 16))
                                )
                            Button(action: {
                                auth.signOut()
                            }) {
                                Circle()
                                    .fill(Color(red: 1.0, green: 0.84, blue: 0.75))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                            .foregroundColor(.black)
                                            .font(.system(size: 14, weight: .bold))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                    // ── Search bar ─────────────────────────────────────
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.tsSecondary)
                            .font(.system(size: 16))
                        TextField("Search your decks...", text: $searchText)
                            .foregroundColor(.tsLabel)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 40)
                    .background(Color.tsCard)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)

                    // ── ACTIVE section ─────────────────────────────────
                    Text("ACTIVE")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.tsSecondary)
                        .tracking(1.2)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)

                    // My Clipboard card
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top) {
                            HStack(spacing: 12) {
                                Text("📋").font(.system(size: 24))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("My Clipboard")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.tsLabel)
                                    Text("Synced from keyboard")
                                        .font(.system(size: 13))
                                        .foregroundColor(.tsSecondary)
                                }
                            }
                            Spacer()
                            Text("124 Phrases")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.tsAccent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.tsAccent.opacity(0.1))
                                .clipShape(Capsule())
                        }

                        Spacer()

                        HStack {
                            // Language bubbles
                            HStack(spacing: -8) {
                                LanguageBubble(label: "EN", color: .blue)
                                LanguageBubble(label: "PT", color: .green)
                                LanguageBubble(label: "ES", color: Color(red: 0.9, green: 0.7, blue: 0))
                            }
                            Spacer()
                            TSGradientPill(title: "Study", icon: "graduationcap.fill") {}
                        }
                    }
                    .padding(20)
                    .frame(height: 176)
                    .background(Color.tsCard)
                    .cornerRadius(24)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)

                    // ── MY DECKS section ───────────────────────────────
                    HStack {
                        Text("MY DECKS")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.tsSecondary)
                            .tracking(1.2)
                        Spacer()
                        Button("See All") {}
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.tsAccent)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        DeckCard(emoji: "☀️", title: "Summer 2026",   count: 42, tint: .orange)
                        DeckCard(emoji: "🍳", title: "Food & Cooking", count: 86, tint: .green)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)

                    // ── Daily Goal ─────────────────────────────────────
                    HStack(spacing: 16) {
                        TSProgressRing(progress: 0.75, size: 44)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Daily Goal")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.tsLabel)
                            Text("15 / 20 phrases reviewed")
                                .font(.system(size: 13))
                                .foregroundColor(.tsSecondary)
                        }

                        Spacer()

                        Button("Keep Going") {}
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.tsLabel)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                    .padding(16)
                    .background(Color.tsCard)
                    .cornerRadius(24)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120) // space for tab bar
                }
            }
        }
    }
}

// MARK: - Sub-components

struct LanguageBubble: View {
    let label: String
    let color: Color
    var body: some View {
        Text(label)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.tsLabel)
            .frame(width: 32, height: 32)
            .background(color)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.tsCard, lineWidth: 2))
    }
}

struct DeckCard: View {
    let emoji: String
    let title: String
    let count: Int
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(tint.opacity(0.1))
                    .frame(width: 40, height: 40)
                Text(emoji).font(.system(size: 18))
            }
            Spacer()
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.tsLabel)
                Text("\(count) phrases")
                    .font(.system(size: 13))
                    .foregroundColor(.tsSecondary)
            }
        }
        .padding(16)
        .frame(height: 176)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tsCard)
        .cornerRadius(24)
    }
}
