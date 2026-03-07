//  WorkTipViews.swift

import SwiftUI

// MARK: - Nudge card (shown at top of Work tab)
struct WorkTipNudgeCard: View {
    let intent: WorkDirectionsIntent
    @State private var showSheet = false
    @ObservedObject var store = WorkTipStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Did you make it to \(intent.placeName)?")
                    .font(.custom("HelveticaNeue-Medium", size: 15))
                    .foregroundColor(.tsLabel)
                Text("Leave a recommendation — takes 15 seconds.")
                    .font(.custom("HelveticaNeue", size: 13))
                    .foregroundColor(.tsSecondary)
            }
            HStack(spacing: 10) {
                Button(action: { showSheet = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 14))
                        Text("Add recommendation")
                            .font(.custom("HelveticaNeue-Medium", size: 14))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 9)
                    .background(Color.tsAccent)
                    .clipShape(Capsule())
                }
                Button(action: { store.dismissNudge(placeId: intent.placeId) }) {
                    Text("Nope, that's okay")
                        .font(.custom("HelveticaNeue", size: 14))
                        .foregroundColor(.tsSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.tsCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16)
            .stroke(Color.tsAccent.opacity(0.2), lineWidth: 1))
        .sheet(isPresented: $showSheet) {
            WorkTipSubmitSheet(intent: intent)
        }
    }
}

// MARK: - Tip submission sheet
struct WorkTipSubmitSheet: View {
    let intent: WorkDirectionsIntent
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store = WorkTipStore.shared

    @State private var wifi:    WifiRating         = .fast
    @State private var noise:   NoiseLevel         = .moderate
    @State private var outlets: OutletAvailability = .some
    @State private var note:    String             = ""
    @State private var done:    Bool               = false
    @FocusState private var noteFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text(intent.placeName)
                                .font(.custom("HelveticaNeue-Bold", size: 22))
                                .foregroundColor(.tsLabel)
                            Text("Quick recommendation for the community")
                                .font(.custom("HelveticaNeue", size: 14))
                                .foregroundColor(.tsSecondary)
                        }

                        // ── WiFi (first — most important) ──────────
                        TipSection(title: "WiFi") {
                            HStack(spacing: 8) {
                                ForEach(WifiRating.allCases, id: \.self) { r in
                                    TipOptionPill(
                                        label: r.rawValue,
                                        icon: r.icon,
                                        color: Color(hex: r.color),
                                        selected: wifi == r
                                    ) { wifi = r }
                                }
                            }
                        }

                        // ── Noise ──────────────────────────────────
                        TipSection(title: "Noise level") {
                            HStack(spacing: 8) {
                                ForEach(NoiseLevel.allCases, id: \.self) { n in
                                    TipOptionPill(
                                        label: n.rawValue,
                                        icon: n.icon,
                                        color: Color(hex: n.color),
                                        selected: noise == n
                                    ) { noise = n }
                                }
                            }
                        }

                        // ── Outlets ────────────────────────────────
                        TipSection(title: "Power outlets") {
                            HStack(spacing: 8) {
                                ForEach(OutletAvailability.allCases, id: \.self) { o in
                                    TipOptionPill(
                                        label: o.rawValue,
                                        icon: "bolt.fill",
                                        color: Color(hex: "#FF9500"),
                                        selected: outlets == o
                                    ) { outlets = o }
                                }
                            }
                        }

                        // ── Note ───────────────────────────────────
                        TipSection(title: "Anything else? (optional)") {
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.tsCard)
                                    .frame(minHeight: 72)
                                TextEditor(text: $note)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .font(.custom("HelveticaNeue", size: 15))
                                    .foregroundColor(.tsLabel)
                                    .frame(minHeight: 72)
                                    .padding(8)
                                    .focused($noteFocused)
                                if note.isEmpty {
                                    Text("e.g. \"Quiet mornings, busy at lunch\"")
                                        .font(.custom("HelveticaNeue", size: 15))
                                        .foregroundColor(.tsSecondary)
                                        .padding(16)
                                        .allowsHitTesting(false)
                                }
                            }
                        }

                        TSButton(title: "Submit recommendation") {
                            store.submitTip(
                                placeId: intent.placeId,
                                placeType: intent.placeType,
                                wifi: wifi, noise: noise,
                                outlets: outlets,
                                note: note.isEmpty ? nil : note
                            )
                            done = true
                        }
                        .padding(.bottom, 48)
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }}
            .alert("Thanks!", isPresented: $done) {
                Button("Done") { dismiss() }
            } message: {
                Text("Your recommendation helps every remote worker who comes after you.")
            }
        }
    }
}

// MARK: - Community tip card (shown on detail view)
struct CommunityTipCard: View {
    let tip: WorkTip

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Icons row
            HStack(spacing: 14) {
                TipBadge(icon: tip.wifi.icon,        label: tip.wifi.rawValue,    color: Color(hex: tip.wifi.color))
                TipBadge(icon: tip.noise.icon,       label: tip.noise.rawValue,   color: Color(hex: tip.noise.color))
                TipBadge(icon: "bolt.fill",          label: tip.outlets.rawValue, color: Color(hex: "#FF9500"))
                Spacer()
                Text(tip.timeAgoLabel)
                    .font(.custom("HelveticaNeue", size: 11))
                    .foregroundColor(.tsSecondary)
            }
            // Note
            if let note = tip.note {
                Text("\"\(note)\"")
                    .font(.custom("HelveticaNeue", size: 14))
                    .foregroundColor(.tsLabel)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color.tsCard)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(Color.tsSecondary.opacity(0.12), lineWidth: 1))
    }
}

// MARK: - Community tips section (used in detail views)
struct CommunityTipsSection: View {
    let placeId: String
    @ObservedObject var store = WorkTipStore.shared

    var tips: [WorkTip] { store.tips(for: placeId) }

    var body: some View {
        if !tips.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("From the community")
                        .font(.custom("HelveticaNeue-Bold", size: 17))
                        .foregroundColor(.tsLabel)
                    Spacer()
                    Text("\(tips.count) recommendation\(tips.count == 1 ? "" : "s")")
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.tsSecondary)
                }
                ForEach(tips.prefix(3)) { tip in
                    CommunityTipCard(tip: tip)
                }
                if tips.count > 3 {
                    Text("+ \(tips.count - 3) more recommendation\(tips.count - 3 == 1 ? "" : "s")")
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.tsAccent)
                }
            }
        }
    }
}

// MARK: - Sub-components

struct TipSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.custom("HelveticaNeue-Medium", size: 11))
                .foregroundColor(.tsSecondary)
                .tracking(1)
            content()
        }
    }
}

struct TipOptionPill: View {
    let label: String
    let icon: String
    let color: Color
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.custom("HelveticaNeue-Medium", size: 12))
                Text(label).font(.custom("HelveticaNeue-Medium", size: 13))
            }
            .foregroundColor(selected ? .white : .tsLabel)
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(selected ? color : Color.tsCard)
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(selected ? Color.clear : Color.tsSecondary.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct TipBadge: View {
    let icon: String
    let label: String
    let color: Color
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.custom("HelveticaNeue", size: 11)).foregroundColor(color)
            Text(label).font(.custom("HelveticaNeue", size: 12)).foregroundColor(.tsSecondary)
        }
    }
}
