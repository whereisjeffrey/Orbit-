//  CoworkSubmitView.swift

import SwiftUI

enum CoworkSubmitType {
    case newSpace
    case editExisting(CoworkSpace)
}

struct CoworkSubmitView: View {
    let type: CoworkSubmitType
    @Environment(\.dismiss) var dismiss

    @State private var name          = ""
    @State private var neighbourhood = ""
    @State private var address       = ""
    @State private var dayRate       = ""
    @State private var hoursDisplay  = ""
    @State private var hasCallRooms  = false
    @State private var hasCoffee     = false
    @State private var hasFastWifi   = false
    @State private var hasLateHours  = false
    @State private var wifiSpeed     = ""
    @State private var website       = ""
    @State private var notes         = ""
    @State private var submitted     = false

    var isEdit: Bool {
        if case .editExisting = type { return true }
        return false
    }

    var title: String { isEdit ? "Suggest an edit" : "Add a space" }

    var isValid: Bool { !name.isEmpty && !neighbourhood.isEmpty }

    var body: some View {
        NavigationStack {
            ZStack { Color.tsBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // ── Context note ───────────────────────────
                        HStack(spacing: 10) {
                            Image(systemName: isEdit ? "pencil.circle.fill" : "plus.circle.fill")
                                .font(.custom("HelveticaNeue", size: 18))
                                .foregroundColor(.tsAccent)
                            Text(isEdit
                                 ? "Know something that\'s out of date? Fix it for everyone."
                                 : "Know a great coworking spot that\'s not listed? Add it.")
                                .font(.custom("HelveticaNeue", size: 14))
                                .foregroundColor(.tsSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(14)
                        .background(Color.tsAccent.opacity(0.08))
                        .cornerRadius(12)

                        // ── Basic info ─────────────────────────────
                        SubmitSection(title: "The basics") {
                            SubmitField(label: "Space name *", placeholder: "e.g. Homework Condesa", text: $name)
                            SubmitField(label: "Neighbourhood *", placeholder: "e.g. Condesa", text: $neighbourhood)
                            SubmitField(label: "Address", placeholder: "e.g. Tamaulipas 66", text: $address)
                            SubmitField(label: "Website", placeholder: "e.g. homework.com.mx", text: $website)
                        }

                        // ── Pricing + hours ────────────────────────
                        SubmitSection(title: "Pricing & hours") {
                            SubmitField(label: "Day rate (MXN)", placeholder: "e.g. 200", text: $dayRate)
                                .keyboardType(.numberPad)
                            SubmitField(label: "Hours", placeholder: "e.g. 8am – 10pm, Mon–Sat", text: $hoursDisplay)
                        }

                        // ── Amenities ──────────────────────────────
                        SubmitSection(title: "Amenities — tick what you know") {
                            AmenityToggleRow(icon: "phone.fill",          label: "Private call rooms",   color: Color(hex: "#34C759"), isOn: $hasCallRooms)
                            AmenityToggleRow(icon: "cup.and.saucer.fill", label: "Coffee included",      color: Color(hex: "#FF9500"), isOn: $hasCoffee)
                            AmenityToggleRow(icon: "bolt.fill",           label: "Fast WiFi (50+ Mbps)", color: Color.tsAccent, isOn: $hasFastWifi)
                            AmenityToggleRow(icon: "moon.fill",           label: "Open past 9pm",        color: Color(hex: "#AF52DE"), isOn: $hasLateHours)
                            SubmitField(label: "WiFi speed (if known)", placeholder: "e.g. ~80 Mbps", text: $wifiSpeed)
                        }

                        // ── Notes ──────────────────────────────────
                        SubmitSection(title: "The lowdown (optional)") {
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.tsCard)
                                    .frame(minHeight: 80)
                                TextEditor(text: $notes)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .font(.custom("HelveticaNeue", size: 15))
                                    .foregroundColor(.tsLabel)
                                    .frame(minHeight: 80)
                                    .padding(8)
                                if notes.isEmpty {
                                    Text("Anything useful to know — vibe, crowd, parking, noise level…")
                                        .font(.custom("HelveticaNeue", size: 15))
                                        .foregroundColor(.tsSecondary)
                                        .padding(16)
                                        .allowsHitTesting(false)
                                }
                            }
                        }

                        // ── Submit ─────────────────────────────────
                        TSButton(title: isValid ? "Submit" : "Fill in name + neighbourhood to continue") {
                            submitted = true
                        }
                        .disabled(!isValid)
                        .padding(.bottom, 48)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { seedFieldsIfEditing() }
            .alert("Thanks!", isPresented: $submitted) {
                Button("Done", role: .cancel) { dismiss() }
            } message: {
                Text("We\'ll review your submission and add it to the list. You\'re helping every expat who comes after you.")
            }
        }
    }

    // MARK: - Seed existing data
    private func seedFieldsIfEditing() {
        guard case .editExisting(let space) = type else { return }
        name          = space.name
        neighbourhood = space.neighbourhood
        address       = space.address
        dayRate       = space.dayRate.map { String($0) } ?? ""
        hoursDisplay  = "\(space.hoursDisplay) · \(space.hoursDays)"
        hasCallRooms  = space.hasCallRooms
        hasCoffee     = space.hasCoffee
        hasFastWifi   = space.hasFastWifi
        hasLateHours  = space.hasLateHours
        wifiSpeed     = space.wifiSpeed ?? ""
        website       = space.website ?? ""
        notes         = space.notes ?? ""
    }
}

// MARK: - Sub-components
struct SubmitSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.custom("HelveticaNeue-Medium", size: 11))
                .foregroundColor(.tsSecondary)
                .tracking(1)
            content()
        }
    }
}

struct SubmitField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    @FocusState private var focused: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.custom("HelveticaNeue", size: 12))
                .foregroundColor(.tsSecondary)
            TextField(placeholder, text: $text)
                .font(.custom("HelveticaNeue", size: 15))
                .foregroundColor(.tsLabel)
                .padding(12)
                .background(Color.tsCard)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
                .focused($focused)
        }
    }
}

struct AmenityToggleRow: View {
    let icon: String
    let label: String
    let color: Color
    @Binding var isOn: Bool
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(isOn ? color : Color.tsSecondary.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 7))
            Text(label)
                .font(.custom("HelveticaNeue", size: 15))
                .foregroundColor(.tsLabel)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(color)
        }
        .padding(12)
        .background(Color.tsCard)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
    }
}
