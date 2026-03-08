//
//  OnboardingLocationView.swift
//  TranslateHelper
//

import SwiftUI
import MapKit
import Combine

struct OnboardingLocationView: View {
    var step: Int = 3
    var totalSteps: Int = 3
    let onBack: () -> Void
    let onSkip: () -> Void
    let onContinue: () -> Void

    @StateObject private var searchVM = LocationSearchViewModel()
    @StateObject private var locStore = UserLocationsStore.shared
    @FocusState private var isFocused: Bool
    @State private var showOrderTip = false
    @State private var isEditMode: EditMode = .inactive

    // Max locations a user can add
    private let maxLocations = 4

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.tsBackground.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Nav bar ────────────────────────────────────────────
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.custom("HelveticaNeue-Medium", size: 22))
                            .foregroundColor(.tsAccent)
                    }
                    .frame(width: 40, height: 40)

                    Spacer()

                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 128, height: 6)
                        Capsule()
                            .fill(Color.tsAccent)
                            .frame(width: 128 * (CGFloat(step) / CGFloat(totalSteps)), height: 6)
                    }

                    Spacer()

                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.custom("HelveticaNeue-Medium", size: 16))
                            .foregroundColor(.tsAccent)
                    }
                    .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)

                // ── Content ────────────────────────────────────────────
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Where are you learning?")
                                .font(.custom("HelveticaNeue-Bold", size: 34))
                                .foregroundColor(.tsLabel)
                            Text("We'll tailor slang and phrases to where you spend time. Add up to \(maxLocations) locations — your top one gets the most weight.")
                                .font(.custom("HelveticaNeue", size: 17))
                                .foregroundColor(.tsSecondary)
                        }
                        .padding(.top, 16)

                        // ── Saved Location Pills ───────────────────────
                        if !locStore.locations.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(Array(locStore.locations.enumerated()), id: \.element.id) { index, loc in
                                    LocationPill(
                                        location: loc,
                                        isPrimary: index == 0,
                                        onRemove: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                if let i = locStore.locations.firstIndex(where: { $0.id == loc.id }) {
                                                    locStore.locations.remove(at: i)
                                                    locStore.persist()
                                                }
                                            }
                                        }
                                    )
                                }
                            }
                        }

                        // ── Search Field ───────────────────────────────
                        if locStore.locations.count < maxLocations {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(spacing: 12) {
                                    Image(systemName: "location.fill")
                                        .font(.custom("HelveticaNeue", size: 16))
                                        .foregroundColor(.tsAccent)

                                    TextField(
                                        locStore.locations.isEmpty ? "Search a city or region…" : "+ Add another location",
                                        text: $searchVM.searchQuery
                                    )
                                    .font(.custom("HelveticaNeue", size: 17))
                                    .foregroundColor(.tsLabel)
                                    .focused($isFocused)

                                    if !searchVM.searchQuery.isEmpty {
                                        Button(action: {
                                            searchVM.searchQuery = ""
                                            searchVM.completions = []
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.tsSecondary)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.tsInputBg)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isFocused ? Color.tsAccent : Color.tsBorder, lineWidth: isFocused ? 1.5 : 0.5)
                                )
                                .animation(.easeInOut(duration: 0.15), value: isFocused)

                                // Autocomplete dropdown
                                if !searchVM.completions.isEmpty {
                                    VStack(alignment: .leading, spacing: 0) {
                                        ForEach(searchVM.completions.prefix(5), id: \.self) { completion in
                                            Button(action: {
                                                let fullLocation = [completion.title, completion.subtitle]
                                                    .filter { !$0.isEmpty }
                                                    .joined(separator: ", ")
                                                let newLoc = UserLearningLocation(
                                                    displayName: fullLocation,
                                                    city: completion.title,
                                                    country: completion.subtitle
                                                )
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    locStore.add(newLoc)
                                                }
                                                searchVM.searchQuery = ""
                                                searchVM.completions = []
                                                isFocused = false

                                                // Show order tip once more than 1 location exists
                                                if locStore.locations.count > 1 && !showOrderTip {
                                                    withAnimation(.spring()) {
                                                        showOrderTip = true
                                                    }
                                                }
                                            }) {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(completion.title)
                                                        .font(.custom("HelveticaNeue-Medium", size: 16))
                                                        .foregroundColor(.tsLabel)
                                                    if !completion.subtitle.isEmpty {
                                                        Text(completion.subtitle)
                                                            .font(.custom("HelveticaNeue", size: 14))
                                                            .foregroundColor(.tsSecondary)
                                                    }
                                                }
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color.tsInputBg)
                                            }

                                            if completion != searchVM.completions.prefix(5).last {
                                                Divider()
                                                    .background(Color.tsBorder)
                                                    .padding(.horizontal, 16)
                                            }
                                        }
                                    }
                                    .background(Color.tsInputBg)
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tsBorder, lineWidth: 0.5))
                                    .padding(.top, 4)
                                }
                            }
                        }

                        // ── Order Tip Banner ───────────────────────────
                        if locStore.locations.count > 1 {
                            OrderTipBanner(onDismiss: {
                                withAnimation { showOrderTip = false }
                            })
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }
            }

            // ── Fixed bottom CTA ───────────────────────────────────────
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color.tsBackground.opacity(0), Color.tsBackground],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 32)
                .allowsHitTesting(false)

                VStack(spacing: 16) {
                    Button(action: {
                        // Save to shared defaults for legacy compatibility
                        if let primary = locStore.locations.first,
                           let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper") {
                            defaults.set(primary.displayName, forKey: "talkswitch_location")
                            defaults.synchronize()
                        }
                        onContinue()
                    }) {
                        Text(locStore.locations.isEmpty ? "Skip for Now" : "Continue")
                            .font(.custom("HelveticaNeue-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(locStore.locations.isEmpty ? Color.tsSecondary.opacity(0.35) : Color.tsAccent)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 24)
                    .animation(.easeInOut(duration: 0.2), value: locStore.locations.isEmpty)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 128, height: 5)
                        .padding(.bottom, 8)
                }
                .background(Color.tsBackground)
            }
        }
        .onTapGesture { isFocused = false }
    }
}

// MARK: - Location Pill

private struct LocationPill: View {
    let location: UserLearningLocation
    let isPrimary: Bool
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.custom("HelveticaNeue-Medium", size: 14))
                .foregroundColor(.tsAccent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(location.displayName)
                    .font(.custom("HelveticaNeue-Medium", size: 16))
                    .foregroundColor(.tsLabel)
                if isPrimary {
                    Text("Primary — highest slang weight")
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(.tsAccent)
                }
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.tsAccent)
                    .padding(6)
                    .background(Color.tsAccent.opacity(0.12))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.tsAccent.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tsAccent.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Order Tip Banner

private struct OrderTipBanner: View {
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.custom("HelveticaNeue", size: 18))
                .foregroundColor(.tsAccent)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 4) {
                Text("Order matters")
                    .font(.custom("HelveticaNeue-Medium", size: 14))
                    .foregroundColor(.tsLabel)
                Text("Your first location gets the most slang weight. Drag to reorder by where you spend the most time.")
                    .font(.custom("HelveticaNeue", size: 13))
                    .foregroundColor(.tsSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.custom("HelveticaNeue-Medium", size: 12))
                    .foregroundColor(.tsSecondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.tsAccent.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tsAccent.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Location Search View Model

class LocationSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchQuery = ""
    @Published var completions: [MKLocalSearchCompletion] = []

    private var completer: MKLocalSearchCompleter
    private var cancellables = Set<AnyCancellable>()

    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        if #available(iOS 13.0, *) {
            completer.resultTypes = .address
        }

        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                if query.isEmpty {
                    self?.completions = []
                } else {
                    self?.completer.queryFragment = query
                }
            }
            .store(in: &cancellables)
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results.filter { !$0.title.isEmpty }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {}
}
