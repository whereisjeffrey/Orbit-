//
//  DeckHomeView.swift
//  TranslateHelper
//
//  Landing screen when tapping a deck — shows stats, Study and Review actions.

import SwiftUI
import MapKit
import CoreLocation

struct DeckHomeView: View {
    let initialDeck: Deck
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var deckStore = DeckStore.shared
    @State private var showStudy = false
    @State private var showReview = false
    @State private var showDeleteConfirmation = false
    @State private var studyPhrases: [SavedPhrase] = []
    @State private var mapSnapshot: UIImage?
    @State private var mapCoordinate: CLLocationCoordinate2D?

    // Live deck from store (for updates after delete/remix), falls back to initial
    private var deck: Deck {
        deckStore.decks.first(where: { $0.id == initialDeck.id }) ?? initialDeck
    }

    private var deckName: String { deck.name }

    private var isLocalSlang: Bool {
        deck.name.contains("Local Slang") || deck.name.contains("Street Slang")
    }

    var body: some View {
        ZStack {
            TSGradientBackground().ignoresSafeArea()

            VStack(spacing: 20) {
                    Spacer().frame(height: 40)

                    // ── Deck identity ──────────────────────
                    VStack(spacing: 12) {
                        if isLocalSlang {
                            // Map snapshot for slang decks — large, flat style
                            ZStack {
                                if let snapshot = mapSnapshot {
                                    Image(uiImage: snapshot)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 270, height: 270)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(Color.tsAccent.opacity(0.15), lineWidth: 1)
                                        )
                                } else {
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.tsCard)
                                        .frame(width: 270, height: 270)
                                        .overlay(
                                            ProgressView()
                                                .tint(.tsSecondary)
                                        )
                                }

                            }
                            .onAppear { loadMapSnapshot() }
                            .padding(.bottom, 8)

                            // Title with 3D pin
                            HStack(spacing: 8) {
                                Text("📍")
                                    .font(.system(size: 22))
                                Text("Local Slang")
                                    .font(.custom("HelveticaNeue-Bold", size: 26))
                                    .foregroundColor(.tsLabel)
                            }

                            // City name subtitle
                            let city = UserLocationsStore.shared.locations.first?.displayName ?? ""
                            if !city.isEmpty {
                                Text(city)
                                    .font(.custom("HelveticaNeue-Medium", size: 15))
                                    .foregroundColor(.tsSecondary)
                            }
                        } else {
                            // Standard emoji for non-slang decks
                            Text(deck.emoji)
                                .font(.system(size: 48))
                                .shadow(color: Color.tsAccent.opacity(0.3), radius: 16, x: 0, y: 0)
                                .shadow(color: Color.tsAccent.opacity(0.15), radius: 32, x: 0, y: 0)

                            Text(deck.name)
                                .font(.custom("HelveticaNeue-Bold", size: 22))
                                .foregroundColor(.tsLabel)
                                .multilineTextAlignment(.center)

                            if !deck.deckDescription.isEmpty {
                                Text(deck.deckDescription)
                                    .font(.custom("HelveticaNeue", size: 14))
                                    .foregroundColor(.tsSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        }

                        // Card count pill
                        HStack(spacing: 6) {
                            Image(systemName: "rectangle.stack.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.tsAccent)
                            Text("\(deck.cards.count) cards")
                                .font(.custom("HelveticaNeue-Bold", size: 16))
                                .foregroundColor(.tsAccent)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color.tsAccent.opacity(0.1))
                        .clipShape(Capsule())
                        .padding(.top, 4)
                    }

                    Spacer()

                    // ── Actions ────────────────────────────
                    VStack(spacing: 12) {
                        // Study — primary
                        Button(action: {
                            // Capture phrases NOW before presenting the cover
                            studyPhrases = deck.activeCards.map { $0.toSavedPhrase() }
                            NSLog("📚 [DeckHome] Study tapped — \(studyPhrases.count) active cards")
                            if !studyPhrases.isEmpty {
                                showStudy = true
                            }
                        }) {
                            Text("Study")
                                .font(.custom("HelveticaNeue-Bold", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(deck.activeCards.isEmpty ? Color.tsSecondary.opacity(0.35) : Color.tsAccent)
                                .clipShape(Capsule())
                        }
                        .disabled(deck.activeCards.isEmpty)

                        // Review — secondary
                        Button(action: { showReview = true }) {
                            Text("Review")
                                .font(.custom("HelveticaNeue-Bold", size: 18))
                                .foregroundColor(.tsAccent)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.tsAccent.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
        }
        .onAppear {
            NSLog("📚 [DeckHome] appeared — name: \(deck.name), cards: \(deck.cards.count), active: \(deck.activeCards.count)")
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.tsAccent)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                        Label("Remove Deck", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.tsSecondary)
                }
            }
        }
        .fullScreenCover(isPresented: $showStudy) {
            NavigationView {
                StudySourceWordView(
                    phrases: studyPhrases,
                    listName: deckName
                )
            }
        }
        .sheet(isPresented: $showReview) {
            DeckPhraseListView(
                phrases: deck.cards.map { $0.toSavedPhrase() },
                deckName: deck.name,
                deckId: deck.id
            )
        }
        .alert("Remove Deck?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                deckStore.deleteDeck(deck)
                dismiss()
            }
        } message: {
            Text("This will permanently remove this deck and all its cards.")
        }
    }

    // MARK: - Map Snapshot

    private func loadMapSnapshot() {
        guard mapSnapshot == nil else { return }
        let cityName = UserLocationsStore.shared.locations.first?.displayName ?? ""
        guard !cityName.isEmpty else { return }

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { placemarks, error in
            guard let coordinate = placemarks?.first?.location?.coordinate else {
                NSLog("🗺️ [Map] geocoding failed for \(cityName): \(error?.localizedDescription ?? "unknown")")
                return
            }

            self.mapCoordinate = coordinate

            let options = MKMapSnapshotter.Options()
            options.region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
            )
            options.size = CGSize(width: 500, height: 500)  // square, 2x retina
            options.mapType = .mutedStandard  // flat 2D, muted colors
            options.pointOfInterestFilter = .excludingAll
            options.showsBuildings = false
            options.traitCollection = UITraitCollection(userInterfaceStyle: .light)  // white/yellow palette

            let snapshotter = MKMapSnapshotter(options: options)
            snapshotter.start { snapshot, error in
                guard let snapshot = snapshot else {
                    NSLog("🗺️ [Map] snapshot failed: \(error?.localizedDescription ?? "unknown")")
                    return
                }
                DispatchQueue.main.async {
                    self.mapSnapshot = snapshot.image
                    NSLog("🗺️ [Map] snapshot ready for \(cityName)")
                }
            }
        }
    }
}
