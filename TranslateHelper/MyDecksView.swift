//
//  MyDecksView.swift
//  TranslateHelper
//
//  The dedicated deck management page. Reached from LibraryView's "See All" → "My Decks" or
//  directly from the bottom nav when we add a Decks tab.
//
//  Architecture (TODO — wired up in implementation phase):
//    - Auto Decks:     Firestore: users/{uid}/auto_decks   (seasonal clipboard + conquered)
//    - User Decks:     Firestore: users/{uid}/decks         (created/imported)
//    - Featured Decks: Firestore: featured_decks            (shared, curated by TalkSwitch team)
//    - AI Generation:  GPT-4o-mini prompt → returns JSON array of card pairs → saved to Firestore
//

import SwiftUI

// MARK: - Placeholder Models (will be replaced by Firestore-backed DeckStore)

struct DeckModel: Identifiable {
    let id: String
    var emoji: String
    var title: String
    var description: String
    var cardCount: Int
    var tint: Color
    var createdAt: Date = Date()
    var isAI: Bool = false
}

struct FeaturedDeckModel: Identifiable {
    let id: String
    var emoji: String
    var title: String
    var subtitle: String
    var cardCount: Int
    var tint: Color
    var tintName: String = "blue"
}

// MARK: - MyDecksView

struct MyDecksView: View {
    @State private var searchText = ""
    @State private var showCreateSheet = false
    @State private var showFlirtySheet = false
    @State private var flirtyDeckAdded = false
    @State private var showStudyMode = false
    @State private var activeDeckName = ""
    @State private var activeDeckPhrases: [SavedPhrase] = []
    @StateObject private var store = SharedPhraseStore.shared
    @ObservedObject private var deckStore = DeckStore.shared
    @AppStorage("ts_flirty_context_set") private var flirtyContextSet: Bool = false
    @AppStorage("ts_added_featured_ids") private var addedIdsRaw: String = ""
    @Environment(\.dismiss) var dismiss

    // MARK: - Added IDs persistence

    var addedIds: Set<String> {
        Set(addedIdsRaw.split(separator: ",").map(String.init))
    }

    func markAdded(_ id: String) {
        if addedIdsRaw.isEmpty {
            addedIdsRaw = id
        } else {
            addedIdsRaw += ",\(id)"
        }
    }

    // ── Real auto deck data ─────────────────────────────────────────────────
    var conqueredCount: Int {
        deckStore.allConqueredDeckCards.count + store.conqueredPhrases.count
    }
    var clipboardCount: Int { store.activePhrases.count }

    var autoDecks: [DeckModel] {
        [
            DeckModel(id: "conquered", emoji: "🏆", title: "Conquered",
                      description: "Words recalled 3× in a row", cardCount: conqueredCount,
                      tint: .yellow),
            DeckModel(id: "clipboard", emoji: "🌸", title: "Spring 2026",
                      description: "Auto-saved from your clipboard", cardCount: clipboardCount,
                      tint: .green)
        ]
    }

    // Featured decks — language-agnostic, AI-generated on tap
    var allFeatured: [FeaturedDeckModel] {
        let city = UserLocationsStore.shared.locations.first?.city ?? "your city"
        let langName = LanguageManager.languageName(for: LanguageManager.shared.targetLangRequired)
        return [
            // Slang
            FeaturedDeckModel(id: "f_local_slang", emoji: "📍", title: "Local Slang — \(city)",
                              subtitle: "Expressions specific to where you are", cardCount: 25, tint: .orange,
                              tintName: "orange"),
            FeaturedDeckModel(id: "f_street_slang", emoji: "🔥", title: "Street Slang",
                              subtitle: "Nationwide casual expressions everyone uses", cardCount: 25, tint: .red,
                              tintName: "red"),
            // Social
            FeaturedDeckModel(id: "f_flirting", emoji: "😏", title: "Flirting & Banter",
                              subtitle: "Playful, confident — not textbook", cardCount: 25, tint: .purple,
                              tintName: "purple"),
            FeaturedDeckModel(id: "f_nightlife", emoji: "🌙", title: "Nightlife & Going Out",
                              subtitle: "Bars, clubs & late nights", cardCount: 25, tint: .indigo,
                              tintName: "indigo"),
            // Daily life
            FeaturedDeckModel(id: "f_food", emoji: "🍽️", title: "Food & Ordering",
                              subtitle: "Restaurants, street food & markets", cardCount: 25, tint: .orange,
                              tintName: "orange"),
            FeaturedDeckModel(id: "f_getting_around", emoji: "🚕", title: "Getting Around",
                              subtitle: "Uber, directions & public transit", cardCount: 25, tint: .blue,
                              tintName: "blue"),
            FeaturedDeckModel(id: "f_texting", emoji: "📱", title: "Texting & WhatsApp",
                              subtitle: "How locals actually text", cardCount: 25, tint: .green,
                              tintName: "green"),
            // Professional
            FeaturedDeckModel(id: "f_work", emoji: "💼", title: "Work & Professional",
                              subtitle: "Office talk, emails & meetings", cardCount: 25, tint: .blue,
                              tintName: "blue"),
            // Practical
            FeaturedDeckModel(id: "f_medical", emoji: "🏥", title: "Medical & Emergencies",
                              subtitle: "Doctor visits, pharmacy & urgent situations", cardCount: 25, tint: .mint,
                              tintName: "mint"),
            FeaturedDeckModel(id: "f_housing", emoji: "🏠", title: "Real Estate & Renting",
                              subtitle: "Apartment hunting & home life", cardCount: 25, tint: .green,
                              tintName: "green"),
            // Culture
            FeaturedDeckModel(id: "f_humor", emoji: "😂", title: "Humor & Sarcasm",
                              subtitle: "Double meanings, jokes & wordplay", cardCount: 25, tint: .yellow,
                              tintName: "yellow"),
            FeaturedDeckModel(id: "f_arguments", emoji: "🗣️", title: "Arguments & Boundaries",
                              subtitle: "Saying no, complaining & standing your ground", cardCount: 25, tint: .red,
                              tintName: "red"),
            FeaturedDeckModel(id: "f_politics", emoji: "🏛️", title: "Political Expressions",
                              subtitle: "Political terms, idioms & debate vocab", cardCount: 25, tint: .indigo,
                              tintName: "indigo"),
            FeaturedDeckModel(id: "f_proverbs", emoji: "📜", title: "Proverbs & Sayings",
                              subtitle: "Timeless wisdom that travels between cultures", cardCount: 25, tint: .orange,
                              tintName: "orange"),
        ]
    }

    var filteredFeatured: [FeaturedDeckModel] {
        let visible = addedIds.isEmpty ? allFeatured : allFeatured.filter { !addedIds.contains($0.id) }
        guard !searchText.isEmpty else { return visible }
        return visible.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.subtitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.tsBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Header ──────────────────────────────────────────
                    HStack {
                        Text("My Decks")
                            .font(.custom("HelveticaNeue-Bold", size: 30))
                            .foregroundColor(.tsLabel)
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.custom("HelveticaNeue", size: 28))
                                .foregroundColor(.tsSecondary)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 16)

                    // ── Search / Browse Categories ───────────────────────
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.tsSecondary)
                            .font(.custom("HelveticaNeue", size: 16))
                        TextField("Search categories...", text: $searchText)
                            .foregroundColor(.tsLabel)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .background(Color.tsCard)
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                    // ── AUTO DECKS ───────────────────────────────────────
                    SectionHeader(title: "AUTO DECKS", action: nil)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(autoDecks) { deck in
                                AutoDeckCard(deck: deck) {
                                    launchStudy(name: deck.title)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 32)

                    // ── YOUR DECKS ───────────────────────────────────────
                    SectionHeader(title: "YOUR DECKS") {
                        // TODO: navigate to full deck list
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            CreateDeckCell { showCreateSheet = true }
                            ForEach(deckStore.decks) { deck in
                                let dm = DeckModel(
                                    id: deck.id.uuidString, emoji: deck.emoji,
                                    title: deck.name, description: deck.deckDescription,
                                    cardCount: deck.activeCards.count,
                                    tint: deck.tintColor, isAI: deck.isAI
                                )
                                UserDeckCard(deck: dm) {
                                    launchDeckStudy(deck)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 32)

                    // ── BROWSE FEATURED ──────────────────────────────────
                    SectionHeader(title: "BROWSE FEATURED", action: nil)
                        .padding(.top, 32)

                    VStack(spacing: 12) {
                        ForEach(filteredFeatured) { deck in
                            if deck.id == "f5" { // Flirting & Banter — needs preference setup first
                                LockedFlirtingRow(
                                    deck: deck,
                                    isAdded: flirtyContextSet || flirtyDeckAdded,
                                    onSetUp: { showFlirtySheet = true }
                                )
                            } else {
                                FeaturedDeckRow(
                                    deck: deck,
                                    isAdded: addedIds.contains(deck.id),
                                    canAdd: deckStore.canAddDeck,
                                    onAdd: { markAdded(deck.id) }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120) // space for FAB
                }
            }

        }
        .sheet(isPresented: $showCreateSheet) {
            CreateDeckSheet()
        }
        .sheet(isPresented: $showFlirtySheet) {
            FlirtyContextSheet { cards in
                // TODO: save cards to DeckStore / Firestore
                flirtyDeckAdded = true
                print("Generated \(cards.count) flirting cards")
            }
        }
        .fullScreenCover(isPresented: $showStudyMode) {
            NavigationView {
                StudySourceWordView(
                    phrases: activeDeckPhrases,
                    listName: activeDeckName
                )
            }
        }
    }

    /// Launch study for an auto-deck (Conquered or Clipboard).
    private func launchStudy(name: String) {
        let all: [SavedPhrase]
        if name == "Conquered" {
            // Conquered auto-deck: clipboard conquered + all deck conquered cards
            let fromClipboard = store.conqueredPhrases
            let fromDecks     = deckStore.allConqueredDeckCards.map { $0.toSavedPhrase() }
            all = fromClipboard + fromDecks
        } else {
            // Clipboard / Spring deck
            let due = store.activePhrases.filter { $0.nextReviewDate <= Date() }
            all = due.isEmpty ? store.activePhrases : due
        }
        activeDeckPhrases = all
        activeDeckName    = name
        showStudyMode     = true
    }

    /// Launch study for a real user deck from DeckStore.
    private func launchDeckStudy(_ deck: Deck) {
        let all = deck.activeCards.map { $0.toSavedPhrase() }
        let due = all.filter { $0.nextReviewDate <= Date() }
        activeDeckPhrases = due.isEmpty ? all : due
        activeDeckName    = deck.name
        showStudyMode     = true
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.custom("HelveticaNeue-Medium", size: 13))
                .foregroundColor(.tsSecondary)
                .tracking(1.2)
            Spacer()
            if let action {
                Button("See All", action: action)
                    .font(.custom("HelveticaNeue-Medium", size: 15))
                    .foregroundColor(.tsAccent)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }
}

// MARK: - Auto Deck Card (horizontal scroll)

struct AutoDeckCard: View {
    let deck: DeckModel
    var onTap: (() -> Void)? = nil
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(deck.tint.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Text(deck.emoji).font(.custom("HelveticaNeue", size: 20))
                }
                Spacer()
                Text(deck.title)
                    .font(.custom("HelveticaNeue-Bold", size: 17))
                    .foregroundColor(.tsLabel)
                Text(deck.cardCount == 0 ? "No phrases yet" : "\(deck.cardCount) phrases")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                    .padding(.top, 2)
            }
            .padding(16)
            .frame(width: 148, height: 148)
            .background(Color.tsGrayCard)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(
                Color.tsAccent.opacity(0.08),
                lineWidth: 0.5))
        }
        .buttonStyle(DeckTapStyle())
    }
}

// MARK: - User Deck Card (grid)

struct UserDeckCard: View {
    let deck: DeckModel
    var onTap: (() -> Void)? = nil
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(deck.tint.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Text(deck.emoji).font(.custom("HelveticaNeue", size: 18))
                    }
                    Spacer()
                    if deck.isAI {
                        Image(systemName: "sparkles")
                            .font(.custom("HelveticaNeue-Medium", size: 12))
                            .foregroundColor(.tsAccent.opacity(0.7))
                    }
                }
                Spacer()
                Text(deck.title)
                    .font(.custom("HelveticaNeue-Bold", size: 16))
                    .foregroundColor(.tsLabel)
                    .lineLimit(2)
                Text(deck.cardCount == 0 ? "Empty" : "\(deck.cardCount) cards")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                    .padding(.top, 2)
            }
            .padding(16)
            .frame(width: 148, height: 148)
            .background(Color.tsGrayCard)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(
                Color.tsAccent.opacity(0.08),
                lineWidth: 0.5))
        }
        .buttonStyle(DeckTapStyle())
    }
}

// MARK: - Shared press-scale style for deck cards

struct DeckTapStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Create Deck Cell
// Matches AutoDeckCard dimensions (148×148) so it sits consistently in the
// same horizontal scroll row as the auto decks.

struct CreateDeckCell: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.tsAccent.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "plus")
                        .font(.custom("HelveticaNeue-Medium", size: 18))
                        .foregroundColor(.tsAccent)
                }
                Spacer()
                Text("New Deck")
                    .font(.custom("HelveticaNeue-Bold", size: 17))
                    .foregroundColor(.tsAccent)
                Text("Create your own")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsAccent.opacity(0.6))
                    .padding(.top, 2)
            }
            .padding(16)
            .frame(width: 148, height: 148)
            .background(Color.tsAccent.opacity(0.06))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.tsAccent.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(DeckTapStyle())
    }
}

// MARK: - Featured Deck Row

struct FeaturedDeckRow: View {
    let deck: FeaturedDeckModel
    let isAdded: Bool
    let canAdd: Bool
    let onAdd: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isGenerating = false

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(deck.tint.opacity(0.12))
                    .frame(width: 48, height: 48)
                Text(deck.emoji).font(.custom("HelveticaNeue", size: 22))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(deck.title)
                    .font(.custom("HelveticaNeue-Bold", size: 16))
                    .foregroundColor(.tsLabel)
                Text(deck.subtitle)
                    .font(.custom("HelveticaNeue", size: 13))
                    .foregroundColor(.tsSecondary)
                    .lineLimit(1)
                Text("\(deck.cardCount) cards")
                    .font(.custom("HelveticaNeue-Medium", size: 11))
                    .foregroundColor(.tsAccent.opacity(0.8))
                    .padding(.top, 2)
            }

            Spacer()

            if isAdded {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.custom("HelveticaNeue", size: 14))
                    Text("Added ✓")
                        .font(.custom("HelveticaNeue-Bold", size: 14))
                }
                .foregroundColor(.green)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .clipShape(Capsule())
            } else if !canAdd {
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10, weight: .bold))
                    Text("Slots full")
                        .font(.custom("HelveticaNeue-Medium", size: 13))
                }
                .foregroundColor(.tsSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGray5))
                .clipShape(Capsule())
            } else {
                Button(action: {
                    isGenerating = true
                    let city = UserLocationsStore.shared.locations.first?.displayName ?? "their city"
                    let country = UserLocationsStore.shared.locations.first?.country ?? ""
                    let langName = LanguageManager.languageName(for: LanguageManager.shared.targetLangRequired)
                    let langCode = LanguageManager.shared.targetLangRequired
                    let level = UserDefaults(suiteName: "group.com.jeff.translatehelper")?.string(forKey: "ts_self_reported_level") ?? "intermediate"

                    let isSlangDeck = deck.id.contains("slang")
                    let slangContext = isSlangDeck ? """
                    SLANG CONTEXT RULES — every card's notes MUST include:
                    1. WHO uses it: age group, subculture, social class (young people, older generation, urban, etc.)
                    2. WHERE it's used: city-specific, regional, nationwide, urban vs rural
                    3. WHEN: current and trendy, been around for decades, fading out, retro
                    Example note: "Used by young people in urban areas. Came from funk culture in the 2010s. Fine with friends but skip it at work."
                    The user is in \(city), \(country). For local slang, focus on expressions from this city and surrounding area.
                    """ : ""

                    Task {
                        do {
                            let generated = try await DeckGenerationService.shared.generateCustomDeck(
                                name: deck.title,
                                description: """
                                \(deck.subtitle). Language: \(langName). User level: \(level). User is in \(city).
                                \(slangContext)
                                Generate natural, useful expressions — not textbook phrases.
                                Each card's notes should include cultural context, not just a definition.
                                """,
                                cardCount: 25
                            )
                            await MainActor.run {
                                let deckCards = generated.map {
                                    DeckCard(english: $0.sourceText, spanish: $0.translatedText,
                                             notes: $0.notes, targetLang: langCode)
                                }
                                let newDeck = Deck(emoji: deck.emoji, name: deck.title,
                                                   deckDescription: deck.subtitle,
                                                   isAI: true, tintName: deck.tintName, cards: deckCards)
                                DeckStore.shared.addDeck(newDeck)
                                isGenerating = false
                                onAdd()
                            }
                        } catch {
                            await MainActor.run {
                                isGenerating = false
                                NSLog("📚 [Featured] generation failed: \(error)")
                            }
                        }
                    }
                }) {
                    if isGenerating {
                        ProgressView()
                            .tint(.tsAccent)
                            .frame(width: 60, height: 34)
                    } else {
                        Text("Add")
                            .font(.custom("HelveticaNeue-Bold", size: 14))
                            .foregroundColor(.tsAccent)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.tsAccent.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                .disabled(isGenerating)
            }
        }
        .frame(minHeight: 80)
        .padding(16)
        .background(Color.tsGrayCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(
            deck.tint.opacity(colorScheme == .dark ? 0.45 : 0.35),
            lineWidth: 1))
    }
}

// MARK: - Locked Flirting Row (Special Case)

struct LockedFlirtingRow: View {
    let deck: FeaturedDeckModel
    let isAdded: Bool
    let onSetUp: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(deck.tint.opacity(0.12))
                    .frame(width: 48, height: 48)
                Text(deck.emoji).font(.custom("HelveticaNeue", size: 22))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(deck.title)
                    .font(.custom("HelveticaNeue-Bold", size: 16))
                    .foregroundColor(.tsLabel)
                Text(deck.subtitle)
                    .font(.custom("HelveticaNeue", size: 13))
                    .foregroundColor(.tsSecondary)
                    .lineLimit(1)
                if isAdded {
                    Text("\(deck.cardCount) personalised cards")
                        .font(.custom("HelveticaNeue-Medium", size: 11))
                        .foregroundColor(.tsAccent.opacity(0.8))
                        .padding(.top, 2)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.custom("HelveticaNeue", size: 10))
                            .foregroundColor(.tsSecondary)
                        Text("Quick setup required")
                            .font(.custom("HelveticaNeue-Medium", size: 11))
                            .foregroundColor(.tsSecondary)
                    }
                    .padding(.top, 2)
                }
            }

            Spacer()

            if isAdded {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.custom("HelveticaNeue", size: 14))
                    Text("Added")
                        .font(.custom("HelveticaNeue-Bold", size: 14))
                }
                .foregroundColor(.green)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .clipShape(Capsule())
            } else {
                Button(action: onSetUp) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.custom("HelveticaNeue", size: 12))
                        Text("Set Up")
                            .font(.custom("HelveticaNeue-Bold", size: 14))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.tsAccent)
                    .clipShape(Capsule())
                }
            }
        }
        .frame(minHeight: 80)
        .padding(16)
        .background(Color.tsGrayCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(deck.tint.opacity(colorScheme == .dark ? 0.45 : 0.35), lineWidth: 1)
        )
    }
}


struct EmptyDecksPrompt: View {
    let onCreate: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.custom("HelveticaNeue", size: 40))
                .foregroundColor(.tsAccent.opacity(0.5))
            Text("No decks yet")
                .font(.custom("HelveticaNeue-Bold", size: 18))
                .foregroundColor(.tsLabel)
            Text("Create your first deck or import a featured one below")
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.tsSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color.tsGrayCard)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
    }
}

// MARK: - Create Deck Sheet

struct CreateDeckSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var deckStore = DeckStore.shared

    @State private var deckName        = ""
    @State private var deckDescription = ""
    @State private var useAI           = true
    @State private var isGenerating    = false
    @State private var errorMessage: String? = nil
    @State private var selectedEmoji   = "📚"
    @State private var selectedTint    = "blue"

    let emojiOptions = ["📚","🎯","💼","🏥","🍽️","✈️","💬","🎵","⚽","🌆","💡","🛒","🎭","🏋️","🌍","🔬"]
    let tintOptions: [(name: String, color: Color)] = [
        ("blue", .blue), ("green", .green), ("orange", .orange),
        ("purple", .purple), ("pink", .pink), ("red", .red),
        ("yellow", .yellow), ("mint", .mint)
    ]

    var canCreate: Bool    { !deckName.trimmingCharacters(in: .whitespaces).isEmpty }
    var aiLimitReached: Bool { useAI && !deckStore.canCreateAIDeck }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tsBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // ── AI Limit Warning ─────────────────────────────
                        if aiLimitReached {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.custom("HelveticaNeue", size: 16))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("AI deck limit reached (\(deckStore.aiDeckCount)/\(DeckStore.maxAIDecks))")
                                        .font(.custom("HelveticaNeue-Bold", size: 14))
                                        .foregroundColor(.tsLabel)
                                    Text("Switch to Manual to create another deck, or delete an existing AI deck first.")
                                        .font(.custom("HelveticaNeue", size: 12))
                                        .foregroundColor(.tsSecondary)
                                }
                            }
                            .padding(16)
                            .background(Color.orange.opacity(0.08))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.orange.opacity(0.25), lineWidth: 1))
                        }

                        // ── Emoji Picker ─────────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CHOOSE AN EMOJI")
                                .font(.custom("HelveticaNeue-Medium", size: 12))
                                .foregroundColor(.tsSecondary)
                                .tracking(1.0)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(emojiOptions, id: \.self) { emoji in
                                        Button(action: { selectedEmoji = emoji }) {
                                            Text(emoji)
                                                .font(.custom("HelveticaNeue", size: 22))
                                                .frame(width: 44, height: 44)
                                                .background(selectedEmoji == emoji
                                                    ? Color.tsAccent.opacity(0.15) : Color.tsCard)
                                                .cornerRadius(12)
                                                .overlay(RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedEmoji == emoji
                                                        ? Color.tsAccent.opacity(0.6) : Color.clear,
                                                            lineWidth: 1.5))
                                        }
                                    }
                                }
                            }
                        }

                        // ── Tint Picker ──────────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("COLOUR")
                                .font(.custom("HelveticaNeue-Medium", size: 12))
                                .foregroundColor(.tsSecondary)
                                .tracking(1.0)
                            HStack(spacing: 10) {
                                ForEach(tintOptions, id: \.name) { opt in
                                    Button(action: { selectedTint = opt.name }) {
                                        Circle()
                                            .fill(opt.color)
                                            .frame(width: 30, height: 30)
                                            .overlay(Circle()
                                                .stroke(Color.white.opacity(0.9), lineWidth: 2)
                                                .scaleEffect(selectedTint == opt.name ? 1 : 0))
                                            .scaleEffect(selectedTint == opt.name ? 1.15 : 1.0)
                                            .animation(.spring(response: 0.2), value: selectedTint)
                                    }
                                }
                                Spacer()
                            }
                        }

                        // ── Deck Name ────────────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DECK NAME")
                                .font(.custom("HelveticaNeue-Medium", size: 12))
                                .foregroundColor(.tsSecondary)
                                .tracking(1.0)
                            TextField("e.g. Medical Radiology, Sports Slang...", text: $deckName)
                                .font(.custom("HelveticaNeue", size: 17))
                                .foregroundColor(.tsLabel)
                                .padding(16)
                                .background(Color.tsCard)
                                .cornerRadius(14)
                                .overlay(RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.tsBorder, lineWidth: 1))
                        }

                        // ── Description ──────────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DESCRIBE WHAT YOU WANT TO LEARN")
                                .font(.custom("HelveticaNeue-Medium", size: 12))
                                .foregroundColor(.tsSecondary)
                                .tracking(1.0)
                            TextField(
                                "e.g. Vocabulary for a radiology resident — anatomy terms and imaging procedures",
                                text: $deckDescription, axis: .vertical
                            )
                            .lineLimit(3...6)
                            .font(.custom("HelveticaNeue", size: 15))
                            .foregroundColor(.tsLabel)
                            .padding(16)
                            .background(Color.tsCard)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.tsBorder, lineWidth: 1))
                            Text("The more detail you give, the better your cards will be.")
                                .font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(.tsSecondary.opacity(0.7))
                        }

                        // ── AI vs Manual toggle ──────────────────────────
                        VStack(alignment: .leading, spacing: 12) {
                            Text("HOW DO YOU WANT TO ADD CARDS?")
                                .font(.custom("HelveticaNeue-Medium", size: 12))
                                .foregroundColor(.tsSecondary)
                                .tracking(1.0)
                            HStack(spacing: 12) {
                                ModeToggleCard(icon: "sparkles", title: "Generate with AI",
                                               subtitle: "~50 cards created instantly",
                                               isSelected: useAI, action: { useAI = true })
                                ModeToggleCard(icon: "pencil", title: "Add Manually",
                                               subtitle: "Build your own card by card",
                                               isSelected: !useAI, action: { useAI = false })
                            }
                        }

                        // ── Info / error banners ─────────────────────────
                        if useAI && !aiLimitReached {
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.tsAccent).font(.custom("HelveticaNeue", size: 16))
                                Text("AI will generate up to 50 flashcard pairs in your target language. You can add more cards after.")
                                    .font(.custom("HelveticaNeue", size: 13)).foregroundColor(.tsSecondary)
                            }
                            .padding(16)
                            .background(Color.tsAccent.opacity(0.06))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.tsAccent.opacity(0.15), lineWidth: 1))
                        }

                        if let err = errorMessage {
                            HStack(spacing: 10) {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                                Text(err).font(.custom("HelveticaNeue", size: 13)).foregroundColor(.red)
                            }
                            .padding(14).background(Color.red.opacity(0.07)).cornerRadius(12)
                        }

                        Spacer(minLength: 40)

                        // ── CTA ──────────────────────────────────────────
                        Button(action: handleCreate) {
                            ZStack {
                                Text(useAI ? "Generate My Deck" : "Create Empty Deck")
                                    .font(.custom("HelveticaNeue-Bold", size: 18))
                                    .foregroundColor(.white)
                                    .opacity(isGenerating ? 0 : 1)
                                if isGenerating { ProgressView().tint(.white) }
                            }
                            .frame(maxWidth: .infinity).frame(height: 56)
                            .background(canCreate && !aiLimitReached
                                ? Color.tsAccent
                                : Color.tsSecondary.opacity(0.35))
                            .clipShape(Capsule())
                        }
                        .disabled(!canCreate || isGenerating || aiLimitReached)
                    }
                    .padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 40)
                }
            }
            .navigationTitle("Create Deck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.tsSecondary)
                            .frame(width: 32, height: 32)
                            .background(Color.tsCard)
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - handleCreate

    private func handleCreate() {
        guard canCreate else { return }
        errorMessage = nil
        if useAI {
            isGenerating = true
            Task {
                do {
                    let generated = try await DeckGenerationService.shared.generateCustomDeck(
                        name: deckName, description: deckDescription, cardCount: 50
                    )
                    let deckCards = generated.map {
                        DeckCard(english: $0.sourceText, spanish: $0.translatedText, notes: $0.notes, targetLang: LanguageManager.shared.targetLangRequired)
                    }
                    let deck = Deck(emoji: selectedEmoji,
                                   name: deckName.trimmingCharacters(in: .whitespaces),
                                   deckDescription: deckDescription,
                                   isAI: true, tintName: selectedTint, cards: deckCards)
                    await MainActor.run {
                if DeckStore.shared.canAddDeck {
                    DeckStore.shared.addDeck(deck)
                }
                isGenerating = false; dismiss()
            }
                } catch {
                    await MainActor.run { isGenerating = false; errorMessage = error.localizedDescription }
                }
            }
        } else {
            let deck = Deck(emoji: selectedEmoji,
                            name: deckName.trimmingCharacters(in: .whitespaces),
                            deckDescription: deckDescription,
                            isAI: false, tintName: selectedTint, cards: [])
            DeckStore.shared.addDeck(deck)
            dismiss()
        }
    }
}

// MARK: - Mode Toggle Card

struct ModeToggleCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.custom("HelveticaNeue-Medium", size: 20))
                    .foregroundStyle(isSelected
                        ? AnyShapeStyle(LinearGradient.tsBluePrimary)
                        : AnyShapeStyle(Color.tsSecondary))
                Text(title)
                    .font(.custom("HelveticaNeue-Bold", size: 14))
                    .foregroundColor(isSelected ? .tsLabel : .tsSecondary)
                Text(subtitle)
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                    .lineLimit(2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.tsCard : Color.tsBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.tsAccent.opacity(0.5) : Color.tsBorder, lineWidth: 1.5)
            )
        }
    }
}
