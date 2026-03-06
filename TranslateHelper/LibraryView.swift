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
                            .font(.custom("HelveticaNeue-Bold", size: 30))
                            .foregroundColor(.tsLabel)
                        Spacer()
                        HStack(spacing: 12) {
                            Button(action: { auth.signOut() }) {
                                Circle()
                                    .fill(Color.tsCard)
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                            .foregroundColor(.tsAccent)
                                            .font(.custom("HelveticaNeue", size: 16))
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
                            .foregroundColor(.tsLabel.opacity(0.7))
                            .font(.custom("HelveticaNeue", size: 16))
                        TextField("", text: $searchText, prompt: Text("Search phrases...")
                            .font(.custom("HelveticaNeue", size: 16))
                            .foregroundColor(.tsLabel.opacity(0.5)))
                            .foregroundColor(.tsLabel)
                            .tint(.tsAccent)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 40)
                    .background(Color.tsCard)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)

                    // ── ACTIVE ─────────────────────────────────────────
                    Text("ACTIVE")
                        .font(.custom("HelveticaNeue-Medium", size: 13))
                        .foregroundColor(.tsSecondary)
                        .tracking(1.2)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)

                    // My Clipboard card
                    Button(action: { showingStudyMode = true }) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top) {
                            HStack(spacing: 12) {
                                Text("📋").font(.custom("HelveticaNeue", size: 24))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("My Clipboard")
                                        .font(.custom("HelveticaNeue-Bold", size: 20))
                                        .foregroundColor(.tsLabel)
                                    Text("Synced from keyboard")
                                        .font(.custom("HelveticaNeue", size: 13))
                                        .foregroundColor(.tsSecondary)
                                }
                            }
                            Spacer()
                            // Live count badge
                            Text(store.activePhrases.isEmpty ? "0 Phrases" : "\(store.activePhrases.count) Phrase\(store.activePhrases.count == 1 ? "" : "s")")
                                .font(.custom("HelveticaNeue-Bold", size: 11))
                                .foregroundColor(store.activePhrases.isEmpty ? .tsSecondary : .tsAccent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(store.activePhrases.isEmpty ? Color.tsCard : Color.tsAccent.opacity(0.1))
                                .clipShape(Capsule())
                        }

                        Spacer().frame(maxHeight: 30)

                        HStack {
                            // Languages: EN + PT only
                            HStack(spacing: -8) {
                                ZStack {
                                    Circle()
                                        .fill(Color.tsAccent)
                                        .frame(width: 32, height: 32)
                                        .overlay(Circle().stroke(Color.tsCard, lineWidth: 2))
                                    Text("EN")
                                        .font(.custom("HelveticaNeue-Bold", size: 11))
                                        .foregroundColor(.white)
                                }
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "#FF3B30"))
                                        .frame(width: 32, height: 32)
                                        .overlay(Circle().stroke(Color.tsCard, lineWidth: 2))
                                    Text("ES")
                                        .font(.custom("HelveticaNeue-Bold", size: 11))
                                        .foregroundColor(.white)
                                }
                                .zIndex(1)
                            }
                            Spacer()
                            if store.activePhrases.isEmpty {
                                Text("Save phrases from the keyboard")
                                    .font(.custom("HelveticaNeue", size: 12))
                                    .foregroundColor(.tsSecondary)
                            } else {
                                TSGradientPill(title: "Study", icon: "graduationcap.fill") {
                                    showingStudyMode = true
                                }
                            }
                        }
                    }
                    .padding(16)
                    .frame(height: 172)
                    .background(Color.tsCard)
                    .cornerRadius(24)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
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
                            .font(.custom("HelveticaNeue-Medium", size: 13))
                            .foregroundColor(.tsSecondary)
                            .tracking(1.2)
                        Spacer()
                    Button("See All") { showMyDecks = true }
                            .foregroundColor(.tsAccent)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // New Deck — always pinned left
                            NewDeckCard { showNewDeck = true }
                                .frame(width: 160)
                            // User decks — newest first (DeckStore inserts at 0)
                            ForEach(deckStore.decks) { deck in
                                LibraryDeckCard(emoji: deck.emoji, title: deck.name, count: deck.cards.count, tint: deck.tintColor) {
                                    activeDeckStudyName = deck.name
                                    showDeckStudy = true
                                }
                                .frame(width: 160)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 2)
                    }
                    .padding(.bottom, 24)

                    // ── Daily Goal ─────────────────────────────────────
                    HStack(spacing: 12) {
                        TSProgressRing(progress: goalProgress, size: 36)

                        Text(dailyGoal == 0
                             ? "0 / 20 phrases reviewed"
                             : "\(reviewedToday) / \(dailyGoal) phrases reviewed")
                            .font(.custom("HelveticaNeue-Medium", size: 14))
                            .foregroundColor(.tsLabel)

                        Spacer()

                        Button(action: { showingGoalSheet = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(hex: "#FFD60A"))
                                Text("Set Goal")
                                    .font(.custom("HelveticaNeue-Medium", size: 13))
                                    .foregroundColor(.tsAccent)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .overlay(Capsule().stroke(Color.tsAccent.opacity(0.35), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.tsCard)
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
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
                .font(.custom("HelveticaNeue-Bold", size: 20))
                .foregroundColor(.tsLabel)
                .padding(.top, 24)

            Text("How many phrases do you want to review each day?")
                .font(.custom("HelveticaNeue", size: 15))
                .foregroundColor(.tsSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(options, id: \.self) { n in
                    Button(action: { dailyGoal = n; dismiss() }) {
                        Text("\(n)")
                            .font(.custom("HelveticaNeue-Bold", size: 22))
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
            .font(.custom("HelveticaNeue-Bold", size: 10))
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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(tint.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Text(emoji).font(.custom("HelveticaNeue", size: 18))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.custom("HelveticaNeue-Bold", size: 17))
                        .foregroundColor(.tsLabel)
                    Text(count == 0 ? "No phrases yet" : "\(count) phrases")
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.tsSecondary)

                }
            }
            .padding(16)
            .frame(height: 176)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.tsCard)
            .cornerRadius(24)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(
                Color.tsAccent.opacity(0.08),
                lineWidth: 0.5))
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
                        .font(.custom("HelveticaNeue-Medium", size: 18))
                        .foregroundColor(.tsAccent)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text("New Deck")
                        .font(.custom("HelveticaNeue-Bold", size: 17))
                        .foregroundColor(.tsLabel)
                    Text("Create your own")
                        .font(.custom("HelveticaNeue", size: 13))
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
