//
//  LibraryView.swift
//  TranslateHelper
//

import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var auth: AuthManager
    @StateObject private var store = SharedPhraseStore.shared
    @State private var searchText = ""
    @State private var showingGoalSheet = false
    @State private var showingStudyMode = false
    @State private var showMyDecks = false
    @State private var showDeckStudy = false
    @State private var activeDeckStudyName = ""
    @ObservedObject private var deckStore = DeckStore.shared
    @State private var showNewDeck = false
    @AppStorage("daily_goal") private var dailyGoal: Int = 20
    @AppStorage("phrases_reviewed_today") private var reviewedToday: Int = 0

    var goalProgress: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(Double(reviewedToday) / Double(dailyGoal), 1.0)
    }

    var filteredPhrases: [SavedPhrase] {
        guard !searchText.isEmpty else { return store.phrases }
        return store.phrases.filter {
            $0.sourceText.localizedCaseInsensitiveContains(searchText) ||
            $0.translatedText.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TSGradientBackground()

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
                            Button(action: { auth.signOut() }) {
                                Circle()
                                    .fill(Color.tsCard)
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                            .foregroundColor(.tsAccent)
                                            .font(.system(size: 16))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                    // ── Keyboard setup banner (hidden once keyboard is active) ──
                    KeyboardSetupBanner()
                        .padding(.bottom, 12)

                    // ── Search ─────────────────────────────────────────
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.tsSecondary)
                            .font(.system(size: 16))
                        TextField("Search phrases...", text: $searchText)
                            .foregroundColor(.tsLabel)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 40)
                    .background(Color.tsCard)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)

                    // ── ACTIVE ─────────────────────────────────────────
                    Text("ACTIVE")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.tsSecondary)
                        .tracking(1.2)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)

                    // My Clipboard card
                    Button(action: { showingStudyMode = true }) {
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
                            // Live count badge
                            Text(store.activePhrases.isEmpty ? "0 Phrases" : "\(store.activePhrases.count) Phrase\(store.activePhrases.count == 1 ? "" : "s")")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(store.activePhrases.isEmpty ? .tsSecondary : .tsAccent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(store.activePhrases.isEmpty ? Color.tsCard : Color.tsAccent.opacity(0.1))
                                .clipShape(Capsule())
                        }

                        Spacer()

                        HStack {
                            // Languages: EN + PT only
                            HStack(spacing: -8) {
                                LanguageBubble(label: "EN", color: .blue)
                                LanguageBubble(label: "PT", color: .green)
                            }
                            Spacer()
                            if store.activePhrases.isEmpty {
                                Text("Save phrases from the keyboard")
                                    .font(.system(size: 12))
                                    .foregroundColor(.tsSecondary)
                            } else {
                                TSGradientPill(title: "Study", icon: "graduationcap.fill") {
                                    showingStudyMode = true
                                }
                            }
                        }
                    }
                    .padding(20)
                    .frame(height: 176)
                    .background(Color.tsCard)
                    .cornerRadius(24)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    .fullScreenCover(isPresented: $showingStudyMode) {
                        NavigationView {
                            let duePhrases = store.activePhrases.filter { $0.nextReviewDate <= Date() }
                            StudySourceWordView(phrases: duePhrases.isEmpty ? store.activePhrases : duePhrases, listName: "Clipboard List")
                        }
                    }

                    // ── MY DECKS ───────────────────────────────────────
                    HStack {
                        Text("MY DECKS")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.tsSecondary)
                            .tracking(1.2)
                        Spacer()
                    Button("See All") { showMyDecks = true }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        // New Deck — always pinned left
                        NewDeckCard { showNewDeck = true }
                        // User decks — newest first (DeckStore inserts at 0)
                        ForEach(deckStore.decks) { deck in
                            LibraryDeckCard(emoji: deck.emoji, title: deck.name, count: deck.cards.count, tint: deck.tintColor) {
                                activeDeckStudyName = deck.name
                                showDeckStudy = true
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)

                    // ── Daily Goal ─────────────────────────────────────
                    HStack(spacing: 16) {
                        TSProgressRing(progress: goalProgress, size: 44)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Daily Goal")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.tsLabel)
                            Text(dailyGoal == 0
                                 ? "No goal set yet"
                                 : "\(reviewedToday) / \(dailyGoal) phrases reviewed")
                                .font(.system(size: 13))
                                .foregroundColor(.tsSecondary)
                        }

                        Spacer()

                        Button(action: { showingGoalSheet = true }) {
                            Text("Set Daily Goal")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.tsAccent)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .overlay(Capsule().stroke(Color.tsAccent.opacity(0.4), lineWidth: 1))
                        }
                    }
                    .padding(16)
                    .background(Color.tsCard)
                    .cornerRadius(24)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                }
            }
        }
        .onAppear {
            store.load()
            // Seed starter decks once if empty
            if deckStore.decks.isEmpty {
                deckStore.addDeck(Deck(emoji: "🍳", name: "Food & Cooking", tintName: "green"))
                deckStore.addDeck(Deck(emoji: "❄️", name: "Winter 2026",    tintName: "blue"))
            }
        }
        .sheet(isPresented: $showingGoalSheet) {
            SetDailyGoalSheet(dailyGoal: $dailyGoal)
        }
        .sheet(isPresented: $showNewDeck) { CreateDeckSheet() }
        .fullScreenCover(isPresented: $showMyDecks) {
            MyDecksView()
        }
        .fullScreenCover(isPresented: $showDeckStudy) {
            NavigationView {
                let all = store.phrases
                let due = all.filter { $0.nextReviewDate <= Date() }
                StudySourceWordView(
                    phrases: due.isEmpty ? all : due,
                    listName: activeDeckStudyName
                )
            }
        }
    }
}

// MARK: - Set Daily Goal Sheet
struct SetDailyGoalSheet: View {
    @Binding var dailyGoal: Int
    @Environment(\.dismiss) var dismiss
    let options = [5, 10, 15, 20, 30, 50]

    var body: some View {
        VStack(spacing: 24) {
            Text("Set Daily Goal")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.tsLabel)
                .padding(.top, 24)

            Text("How many phrases do you want to review each day?")
                .font(.system(size: 15))
                .foregroundColor(.tsSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(options, id: \.self) { n in
                    Button(action: { dailyGoal = n; dismiss() }) {
                        Text("\(n)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(dailyGoal == n ? .white : .tsLabel)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(dailyGoal == n ? Color.tsAccent : Color.tsCard)
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(TSGradientBackground())
        .presentationDetents([.medium])
    }
}



// MARK: - Sub-components
struct LanguageBubble: View {
    let label: String
    let color: Color
    var body: some View {
        Text(label)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 32, height: 32)
            .background(color)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.tsCard, lineWidth: 2))
    }
}

struct LibraryDeckCard: View {
    let emoji: String
    let title: String
    let count: Int
    let tint: Color
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
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
                    Text(count == 0 ? "No phrases yet" : "\(count) phrases")
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
        .buttonStyle(DeckTapStyle())
    }
}


// MARK: - New Deck Card
struct NewDeckCard: View {
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.tsAccent.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.tsAccent)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text("New Deck")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.tsLabel)
                    Text("Create your own")
                        .font(.system(size: 13))
                        .foregroundColor(.tsSecondary)
                }
            }
            .padding(16)
            .frame(height: 176)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.tsCard)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .foregroundColor(Color.tsAccent.opacity(0.3))
            )
        }
        .buttonStyle(DeckTapStyle())
    }
}
