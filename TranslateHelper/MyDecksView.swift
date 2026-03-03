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
}

// MARK: - MyDecksView

struct MyDecksView: View {
    @State private var searchText = ""
    @State private var showCreateSheet = false
    @State private var showFlirtySheet = false
    @State private var flirtyDeckAdded = false
    @AppStorage("ts_flirty_context_set") private var flirtyContextSet: Bool = false

    // TODO: Replace with @StateObject var deckStore = DeckStore()
    let autoDecksSample: [DeckModel] = [
        DeckModel(id: "conquered", emoji: "🏆", title: "Conquered",
                  description: "Words recalled 3× in a row", cardCount: 0,
                  tint: .yellow),
        DeckModel(id: "spring26", emoji: "🌸", title: "Spring 2026",
                  description: "Auto-saved from your clipboard", cardCount: 0,
                  tint: .green)
    ]

    let userDecksSample: [DeckModel] = [
        DeckModel(id: "1", emoji: "❄️", title: "Winter 2026",
                  description: "Seasonal clipboard phrases", cardCount: 0,
                  tint: .blue),
        DeckModel(id: "2", emoji: "🍳", title: "Food & Cooking",
                  description: "Market, kitchen, restaurants", cardCount: 0,
                  tint: .orange)
    ]

    let featuredSample: [FeaturedDeckModel] = [
        FeaturedDeckModel(id: "f1", emoji: "🌆", title: "Mexico City Slang",
                          subtitle: "Street Spanish, CDMX style", cardCount: 48, tint: .red),
        FeaturedDeckModel(id: "f2", emoji: "💃", title: "Romantic Phrases",
                          subtitle: "Flirting, love & relationships", cardCount: 32, tint: .pink),
        FeaturedDeckModel(id: "f3", emoji: "🏥", title: "Medical Spanish",
                          subtitle: "Clinic, pharmacy & emergencies", cardCount: 60, tint: .mint),
        FeaturedDeckModel(id: "f4", emoji: "🍽️", title: "Food & Markets",
                          subtitle: "Order like a local", cardCount: 40, tint: .orange),
        FeaturedDeckModel(id: "f5", emoji: "😏", title: "Flirting & Banter",
                          subtitle: "Playful, real — not textbook", cardCount: 34, tint: .purple),
        FeaturedDeckModel(id: "f6", emoji: "⚽", title: "Sports & Fútbol",
                          subtitle: "Match day vocabulary", cardCount: 36, tint: .green),
    ]

    var filteredFeatured: [FeaturedDeckModel] {
        guard !searchText.isEmpty else { return featuredSample }
        return featuredSample.filter {
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
                    Text("My Decks")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.tsLabel)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 16)

                    // ── Search / Browse Categories ───────────────────────
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.tsSecondary)
                            .font(.system(size: 16))
                        TextField("Search categories...", text: $searchText)
                            .foregroundColor(.tsLabel)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .background(Color.tsCard)
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                    // ── AUTO DECKS ───────────────────────────────────────
                    SectionHeader(title: "AUTO DECKS", action: nil)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(autoDecksSample) { deck in
                                AutoDeckCard(deck: deck)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 32)

                    // ── YOUR DECKS ───────────────────────────────────────
                    SectionHeader(title: "YOUR DECKS") {
                        // TODO: navigate to full deck list
                    }

                    if userDecksSample.isEmpty {
                        EmptyDecksPrompt { showCreateSheet = true }
                            .padding(.horizontal, 24)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                                  spacing: 16) {
                            ForEach(userDecksSample) { deck in
                                UserDeckCard(deck: deck)
                            }
                            // "Create new" card always at end
                            CreateDeckCell { showCreateSheet = true }
                        }
                        .padding(.horizontal, 24)
                    }

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
                                FeaturedDeckRow(deck: deck)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120) // space for FAB
                }
            }

            // ── FAB: Create Deck ────────────────────────────────────────
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color.tsBackground.opacity(0), Color.tsBackground],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 32)
                .allowsHitTesting(false)

                Button(action: { showCreateSheet = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Create Deck")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(LinearGradient.tsBluePrimary)
                    .clipShape(Capsule())
                    .shadow(color: Color.tsAccent.opacity(0.4), radius: 16, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .background(Color.tsBackground)
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
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.tsSecondary)
                .tracking(1.2)
            Spacer()
            if let action {
                Button("See All", action: action)
                    .font(.system(size: 15, weight: .semibold))
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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(deck.tint.opacity(0.15))
                    .frame(width: 40, height: 40)
                Text(deck.emoji).font(.system(size: 20))
            }
            Spacer()
            Text(deck.title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.tsLabel)
            Text(deck.cardCount == 0 ? "No phrases yet" : "\(deck.cardCount) phrases")
                .font(.system(size: 12))
                .foregroundColor(.tsSecondary)
                .padding(.top, 2)
        }
        .padding(16)
        .frame(width: 148, height: 148)
        .background(Color.tsCard)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(deck.tint.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - User Deck Card (grid)

struct UserDeckCard: View {
    let deck: DeckModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(deck.tint.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Text(deck.emoji).font(.system(size: 16))
                }
                Spacer()
                if deck.isAI {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.tsAccent.opacity(0.7))
                }
            }
            Spacer()
            Text(deck.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.tsLabel)
                .lineLimit(2)
            Text(deck.cardCount == 0 ? "Empty" : "\(deck.cardCount) cards")
                .font(.system(size: 12))
                .foregroundColor(.tsSecondary)
                .padding(.top, 2)
        }
        .padding(16)
        .frame(height: 152)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tsCard)
        .cornerRadius(20)
    }
}

// MARK: - Create Deck Cell (end of grid)

struct CreateDeckCell: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(Color.tsAccent.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                        .frame(width: 40, height: 40)
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.tsAccent)
                }
                Text("New Deck")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.tsAccent)
            }
            .frame(height: 152)
            .frame(maxWidth: .infinity)
            .background(Color.tsAccent.opacity(0.04))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.tsAccent.opacity(0.15), lineWidth: 1)
            )
        }
    }
}

// MARK: - Featured Deck Row

struct FeaturedDeckRow: View {
    let deck: FeaturedDeckModel
    @State private var importing = false

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(deck.tint.opacity(0.12))
                    .frame(width: 48, height: 48)
                Text(deck.emoji).font(.system(size: 22))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(deck.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.tsLabel)
                Text(deck.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.tsSecondary)
                Text("\(deck.cardCount) cards")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.tsAccent.opacity(0.8))
                    .padding(.top, 2)
            }

            Spacer()

            Button(action: { importing = true }) {
                Text("Add")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.tsAccent)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.tsAccent.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(Color.tsCard)
        .cornerRadius(16)
    }
}

// MARK: - Locked Flirting Row (Special Case)

struct LockedFlirtingRow: View {
    let deck: FeaturedDeckModel
    let isAdded: Bool
    let onSetUp: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(deck.tint.opacity(0.12))
                    .frame(width: 48, height: 48)
                Text(deck.emoji).font(.system(size: 22))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(deck.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.tsLabel)
                Text(deck.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.tsSecondary)
                if isAdded {
                    Text("\(deck.cardCount) personalised cards")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.tsAccent.opacity(0.8))
                        .padding(.top, 2)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.tsSecondary)
                        Text("Quick setup required")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.tsSecondary)
                    }
                    .padding(.top, 2)
                }
            }

            Spacer()

            if isAdded {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                    Text("Added")
                        .font(.system(size: 14, weight: .bold))
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
                            .font(.system(size: 12))
                        Text("Set Up")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(LinearGradient.tsBluePrimary)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(Color.tsCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isAdded ? Color.green.opacity(0.2) : Color.tsBorder, lineWidth: 1)
        )
    }
}


struct EmptyDecksPrompt: View {
    let onCreate: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.tsAccent.opacity(0.5))
            Text("No decks yet")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.tsLabel)
            Text("Create your first deck or import a featured one below")
                .font(.system(size: 14))
                .foregroundColor(.tsSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color.tsCard)
        .cornerRadius(20)
    }
}

// MARK: - Create Deck Sheet

struct CreateDeckSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var deckName = ""
    @State private var deckDescription = ""
    @State private var useAI = true
    @State private var isGenerating = false

    var canCreate: Bool { !deckName.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tsBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // ── Deck Name ────────────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DECK NAME")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.tsSecondary)
                                .tracking(1.0)

                            TextField("e.g. Medical Radiology, Sports Slang...", text: $deckName)
                                .font(.system(size: 17))
                                .foregroundColor(.tsLabel)
                                .padding(16)
                                .background(Color.tsCard)
                                .cornerRadius(14)
                                .overlay(RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.tsBorder, lineWidth: 1))
                        }

                        // ── Description / Context ────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DESCRIBE WHAT YOU WANT TO LEARN")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.tsSecondary)
                                .tracking(1.0)

                            TextField(
                                "e.g. Vocabulary for a radiology resident — anatomy terms and imaging procedures",
                                text: $deckDescription,
                                axis: .vertical
                            )
                            .lineLimit(3...6)
                            .font(.system(size: 15))
                            .foregroundColor(.tsLabel)
                            .padding(16)
                            .background(Color.tsCard)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.tsBorder, lineWidth: 1))

                            Text("The more detail you give, the better your cards will be.")
                                .font(.system(size: 12))
                                .foregroundColor(.tsSecondary.opacity(0.7))
                        }

                        // ── AI vs Manual toggle ──────────────────────────
                        VStack(alignment: .leading, spacing: 12) {
                            Text("HOW DO YOU WANT TO ADD CARDS?")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.tsSecondary)
                                .tracking(1.0)

                            HStack(spacing: 12) {
                                ModeToggleCard(
                                    icon: "sparkles",
                                    title: "Generate with AI",
                                    subtitle: "~25 cards created instantly",
                                    isSelected: useAI,
                                    action: { useAI = true }
                                )
                                ModeToggleCard(
                                    icon: "pencil",
                                    title: "Add Manually",
                                    subtitle: "Build your own card by card",
                                    isSelected: !useAI,
                                    action: { useAI = false }
                                )
                            }
                        }

                        // ── AI info banner ───────────────────────────────
                        if useAI {
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.tsAccent)
                                    .font(.system(size: 16))
                                Text("AI will generate Spanish–English flashcard pairs tailored to your description. You can add or edit cards after.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.tsSecondary)
                            }
                            .padding(16)
                            .background(Color.tsAccent.opacity(0.06))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.tsAccent.opacity(0.15), lineWidth: 1))
                        }

                        Spacer(minLength: 40)

                        // ── CTA ──────────────────────────────────────────
                        Button(action: {
                            // TODO: call DeckStore.createDeck(name:, description:, useAI:)
                            isGenerating = true
                        }) {
                            ZStack {
                                HStack(spacing: 10) {
                                    Image(systemName: useAI ? "sparkles" : "plus")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text(useAI ? "Generate My Deck" : "Create Empty Deck")
                                        .font(.system(size: 17, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .opacity(isGenerating ? 0 : 1)

                                if isGenerating {
                                    ProgressView().tint(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(canCreate
                                ? LinearGradient.tsBluePrimary
                                : LinearGradient(colors: [Color.tsCard], startPoint: .leading, endPoint: .trailing))
                            .clipShape(Capsule())
                            .shadow(color: canCreate ? Color.tsAccent.opacity(0.35) : .clear, radius: 14, x: 0, y: 4)
                        }
                        .disabled(!canCreate || isGenerating)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Create Deck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.tsAccent)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
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
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isSelected
                        ? AnyShapeStyle(LinearGradient.tsBluePrimary)
                        : AnyShapeStyle(Color.tsSecondary))
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isSelected ? .tsLabel : .tsSecondary)
                Text(subtitle)
                    .font(.system(size: 12))
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
