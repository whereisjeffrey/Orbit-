//
//  LibraryView.swift
//  TranslateHelper
//

import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var store = SharedPhraseStore.shared
    @State private var searchText = ""
    @FocusState private var searchFocused: Bool
    @State private var selectedPhraseForDetail: SavedPhrase? = nil
    @State private var searchBarMaxY: CGFloat = 140  // updated dynamically
    @State private var showingGoalSheet = false
    @State private var showingStudyMode = false
    @State private var showMyDecks = false

    @ObservedObject private var deckStore = DeckStore.shared
    @State private var showNewDeck = false
    @AppStorage("daily_goal") private var dailyGoal: Int = 20
    @AppStorage("phrases_reviewed_today") private var reviewedToday: Int = 0
    @AppStorage("has_swiped_to_deck_v2") private var hasSwipedToDeck: Bool = false
    @AppStorage("starter_decks_seeded_lang") private var seededLanguageCode: String = ""
    @State private var isSeedingDecks: Bool = false
    @State private var showReviewPrompt: Bool = false
    @State private var activeWidgetPage: Int = 0
    // nil = no deck open; set to a Deck to present study mode.
    @State private var showDeckHome = false
    @State private var selectedDeck: Deck? = nil

    var goalProgress: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(Double(reviewedToday) / Double(dailyGoal), 1.0)
    }

    @State private var cachedSearchablePhrases: [SavedPhrase] = []

    /// Rebuild the searchable phrases list — call on appear and when data changes
    private func rebuildSearchablePhrases() {
        let clipboardPhrases = store.phrases
        let deckPhrases = deckStore.decks.flatMap { $0.cards.map { $0.toSavedPhrase() } }
        var seenIDs = Set<UUID>()
        var combined: [SavedPhrase] = []
        for phrase in (clipboardPhrases + deckPhrases) {
            if !seenIDs.contains(phrase.id) {
                seenIDs.insert(phrase.id)
                combined.append(phrase)
            }
        }
        cachedSearchablePhrases = combined
    }

    var filteredPhrases: [SavedPhrase] {
        guard !searchText.isEmpty else { return [] }
        return cachedSearchablePhrases.filter {
            $0.sourceText.localizedCaseInsensitiveContains(searchText) ||
            $0.translatedText.localizedCaseInsensitiveContains(searchText) ||
            ($0.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TSGradientBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Header ─────────────────────────────────────────
                    HStack(alignment: .center) {
                        OrbitWordmark()
                        Spacer()
                    }
                    .frame(minHeight: 36)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                    // ── Keyboard setup banner (hidden once keyboard is active) ──
                    KeyboardSetupBanner()
                        .padding(.bottom, 12)

                    // ── Review prompt (behavioral triggers) ──
                    if showReviewPrompt {
                        ReviewPromptCard(isShowing: $showReviewPrompt)
                            .padding(.bottom, 12)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

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
                            .focused($searchFocused)
                        if !searchText.isEmpty || searchFocused {
                            Button {
                                withAnimation(.easeOut(duration: 0.15)) {
                                    searchText = ""
                                    searchFocused = false
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(.tsSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 40)
                    .background(
                        Color.tsCard
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear { searchBarMaxY = geo.frame(in: .global).maxY }
                                        .onChange(of: geo.frame(in: .global).maxY) { _, newY in
                                            searchBarMaxY = newY
                                        }
                                }
                            )
                    )
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)

                    // ── ACTIVE ─────────────────────────────────────────
                    Text("ACTIVE")
                        .font(.custom("HelveticaNeue-Medium", size: 13))
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.80) : .black.opacity(0.80))
                        .tracking(1.2)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)

                    // ── Weekly Clipboard + Streak ──────────────────────
                    // ── Throw-style swipe: Clipboard + Deck widgets ──
                    let deckList = Array(deckStore.decks.prefix(5))
                    let widgetPages: [AnyView] = {
                        var views: [AnyView] = [
                            AnyView(WeeklyClipboardWidget(store: store, onStudy: { showingStudyMode = true })
                                .padding(.horizontal, 16))
                        ]
                        for deck in deckList {
                            views.append(AnyView(
                                DeckClipboardWidget(deck: deck, onStudy: {
                                    selectedDeck = deck; showDeckHome = true
                                })
                                .padding(.horizontal, 16)
                            ))
                        }
                        return views
                    }()
                    DeckPagerContainer(pages: widgetPages,
                                       currentPage: $activeWidgetPage)
                    .frame(height: 440)
                    .onChange(of: activeWidgetPage) { _, p in
                        if p > 0 { hasSwipedToDeck = true }
                    }
                    .padding(.bottom, 8)

                    // ── Swipe hint ──────────────────────────────────
                    if !hasSwipedToDeck && !deckStore.decks.isEmpty {
                        SwipeDeckHint()
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }

                    // ── Daily Goal — botanical card ───────────────────
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Daily Goal")
                                    .font(.custom("HelveticaNeue-Bold", size: 15))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text(dailyGoal == 0
                                     ? "0 / 20 phrases reviewed"
                                     : "\(reviewedToday) of \(dailyGoal) phrases reviewed")
                                    .font(.custom("HelveticaNeue", size: 13))
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.80) : .tsSecondary)
                            }
                            Spacer()
                            Button(action: { showingGoalSheet = true }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.tsAccent)
                                    Text("Set Goal")
                                        .font(.custom("HelveticaNeue-Medium", size: 13))
                                        .foregroundColor(colorScheme == .dark ? .white : .tsAccent)
                                }
                                .padding(.horizontal, 14).padding(.vertical, 6)
                                .background(colorScheme == .dark ? Color.black : Color.tsAccent.opacity(0.12))
                                .clipShape(Capsule())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(colorScheme == .dark ? Color.white.opacity(0.20) : Color.tsAccent.opacity(0.15))
                                    .frame(height: 6)
                                Capsule()
                                    .fill(Color.tsAccent)
                                    .frame(width: geo.size.width * goalProgress, height: 6)
                                    .animation(.spring(response: 0.4), value: goalProgress)
                            }
                        }
                        .frame(height: 6)
                    }
                    .padding(16)
                    .background(BotanicalCardBackground())
                    .cornerRadius(20)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    // ── This Week's Streak ───────────────────────────
                    WeeklyStreakCard()
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 24)

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
                                    selectedDeck = deck; showDeckHome = true
                                }
                                .frame(width: 160)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 2)
                    }
                    .padding(.bottom, 24)

                    Spacer(minLength: 120)
                }
            }

            // ── Search results overlay (escapes ScrollView clipping) ─────────
            if searchFocused || !searchText.isEmpty {
                // Transparent tap-outside area — dismisses keyboard & collapses search
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.15)) {
                            searchText = ""
                            searchFocused = false
                        }
                    }
                    .zIndex(49)

                VStack(spacing: 0) {
                    Spacer().frame(height: searchBarMaxY + 8)
                    PhraseSearchOverlay(
                        searchText: $searchText,
                        allPhrases: cachedSearchablePhrases,
                        selectedPhrase: $selectedPhraseForDetail
                    )
                    Spacer()
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(50)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.spring(response: 0.28, dampingFraction: 0.82), value: searchText)
            }

            // ── Deck seeding overlay (AI generation only) ─────────────
            if isSeedingDecks {
                ZStack {
                    Color.black.opacity(0.45).ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.4)
                            .tint(.white)
                        Text("Building your starter decks…")
                            .font(.custom("HelveticaNeue-Bold", size: 16))
                            .foregroundColor(.white)
                        Text("Crafting Timeless Adages, Euphemisms & Dating & Romance in \(StarterDeckSeeder.shared.targetLanguageName)")
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.white.opacity(0.80))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(28)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal, 48)
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            store.load()
            // Mark today as active if the user has engaged at all this session
            // (keyboard translations, Sol conversations, study cards — anything)
            if let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper"),
               defaults.bool(forKey: "keyboard_has_launched") {
                PracticeStatsStore.shared.recordEngagement()
            }
            // Demo seed disabled — clipboard fills from real keyboard + Sol usage
            rebuildSearchablePhrases()

            // Seed language-specific starter decks whenever the target language changes
            let langCode = StarterDeckSeeder.shared.targetLanguageCode
            if seededLanguageCode != langCode {
                seededLanguageCode = langCode

                // All 39 languages now have static content — instant seed, no loading overlay
                StarterDeckSeeder.shared.seed(forceLanguage: langCode) { _ in
                    NSLog("📚 Starter decks seeded for \(langCode)")
                }
            }
        }
        .sheet(isPresented: $showingGoalSheet) {
            SetDailyGoalSheet(dailyGoal: $dailyGoal)
        }

        .sheet(isPresented: $showNewDeck) { CreateDeckSheet() }
        .sheet(item: $selectedPhraseForDetail) { phrase in
            PhraseDetailSheet(phrase: phrase)
        }
        .fullScreenCover(isPresented: $showMyDecks) {
            MyDecksView()
        }
        .fullScreenCover(isPresented: $showingStudyMode) {
            NavigationView {
                let duePhrases = store.activePhrases.filter { $0.nextReviewDate <= Date() }
                StudySourceWordView(phrases: duePhrases.isEmpty ? store.activePhrases : duePhrases, listName: "Clipboard List")
            }
        }
        // Deck home screen — shows stats, Study and Review actions
        .fullScreenCover(isPresented: $showDeckHome) {
            if let deck = selectedDeck {
                NavigationView {
                    DeckHomeView(initialDeck: deck)
                }
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
                        .font(.custom("HelveticaNeue-Medium", size: 13))
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
                        .font(.custom("HelveticaNeue-Medium", size: 13))
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
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .foregroundColor(Color.tsAccent.opacity(0.3))
            )
        }
        .buttonStyle(DeckTapStyle())
    }
}

// (LearnBackground removed as it has been moved to DesignSystem.swift as TSGradientBackground)
