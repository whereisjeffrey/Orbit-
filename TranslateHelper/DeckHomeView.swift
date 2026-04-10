//
//  DeckHomeView.swift
//  TranslateHelper
//
//  Landing screen when tapping a deck — shows stats, Study and Review actions.

import SwiftUI
import MapKit
import CoreLocation

struct DeckHomeView: View {
    let deckId: UUID
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var deckStore = DeckStore.shared
    @State private var showStudy = false
    @State private var showReview = false
    @State private var showDeleteConfirmation = false
    @State private var mapSnapshot: UIImage?
    @State private var mapCoordinate: CLLocationCoordinate2D?

    private var deck: Deck? {
        deckStore.decks.first(where: { $0.id == deckId })
    }

    private var isLocalSlang: Bool {
        deck?.name.contains("Local Slang") == true || deck?.name.contains("Street Slang") == true
    }

    var body: some View {
        ZStack {
            TSGradientBackground().ignoresSafeArea()

            if let deck = deck {
                VStack(spacing: 20) {
                    Spacer().frame(height: 60)

                    // ── Deck identity ──────────────────────
                    VStack(spacing: 12) {
                        if isLocalSlang {
                            // Map snapshot for slang decks
                            ZStack {
                                if let snapshot = mapSnapshot {
                                    Image(uiImage: snapshot)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 200, height: 140)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.tsAccent.opacity(0.2), lineWidth: 1)
                                        )
                                        .shadow(color: Color.tsAccent.opacity(0.2), radius: 12, x: 0, y: 4)
                                } else {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.tsCard)
                                        .frame(width: 200, height: 140)
                                        .overlay(
                                            ProgressView()
                                                .tint(.tsSecondary)
                                        )
                                }

                                // Pin
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(Color(hex: "#FF3B30"))
                                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                            .onAppear { loadMapSnapshot() }

                            // Title — larger for slang
                            Text(deck.name)
                                .font(.custom("HelveticaNeue-Bold", size: 24))
                                .foregroundColor(.tsLabel)
                                .multilineTextAlignment(.center)

                            // Location subtitle
                            let city = UserLocationsStore.shared.locations.first?.displayName ?? ""
                            if !city.isEmpty {
                                Text("Expressions specific to \(city)")
                                    .font(.custom("HelveticaNeue", size: 14))
                                    .foregroundColor(.tsSecondary)
                                    .multilineTextAlignment(.center)
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
                            Text("🃏")
                                .font(.system(size: 12))
                            Text("\(deck.cards.count) cards")
                                .font(.custom("HelveticaNeue-Bold", size: 13))
                                .foregroundColor(.tsAccent)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.tsAccent.opacity(0.1))
                        .clipShape(Capsule())
                        .padding(.top, 4)
                    }

                    Spacer()

                    // ── Actions ────────────────────────────
                    VStack(spacing: 12) {
                        // Study — primary
                        Button(action: { showStudy = true }) {
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

                        // Remove deck
                        Button(action: { showDeleteConfirmation = true }) {
                            Text("Remove Deck")
                                .font(.custom("HelveticaNeue-Medium", size: 15))
                                .foregroundColor(.tsSecondary)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            } else {
                // Deck was deleted while viewing
                VStack {
                    Text("Deck not found")
                        .foregroundColor(.tsSecondary)
                    Button("Go Back") { dismiss() }
                        .foregroundColor(.tsAccent)
                }
            }
        }
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
        .fullScreenCover(isPresented: $showStudy) {
            if let deck = deck {
                NavigationView {
                    StudySourceWordView(
                        phrases: deck.activeCards.map { $0.toSavedPhrase() },
                        listName: deck.name
                    )
                }
            }
        }
        .sheet(isPresented: $showReview) {
            if let deck = deck {
                DeckPhraseListView(
                    phrases: deck.cards.map { $0.toSavedPhrase() },
                    deckName: deck.name,
                    deckId: deck.id
                )
            }
        }
        .alert("Remove Deck?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                if let deck = deck {
                    deckStore.deleteDeck(deck)
                    dismiss()
                }
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
                span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
            )
            options.size = CGSize(width: 400, height: 280)  // 2x for retina
            options.traitCollection = UITraitCollection(userInterfaceStyle: .dark)

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
