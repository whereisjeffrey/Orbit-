//  NewInTownSection.swift

import SwiftUI

struct NewInTownSection: View {
    @AppStorage("selected_city_id")   private var cityId      = "mx_cdmx"
    @AppStorage("new_in_town_opt_in") private var optedIn     = false
    @AppStorage("user_expat_status")  private var myStatus    = ""
    @State private var showOptInCard  = false
    @State private var selectedUser: CommunityUser? = nil

    var newArrivals: [CommunityUser] {
        seedCommunityUsers.filter {
            $0.cityId == cityId &&
            $0.isVisibleNewInTown &&
            ($0.statusRaw == "just_arrived" || $0.statusRaw == "settling")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.tsAccent)
                    Text("New in town")
                        .font(.custom("HelveticaNeue-Bold", size: 17))
                        .foregroundColor(.tsLabel)
                }
                Spacer()
                Text("\(newArrivals.count) people")
                    .font(.custom("HelveticaNeue", size: 13))
                    .foregroundColor(.tsSecondary)
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {

                    // Opt-in card for eligible users
                    if !optedIn && (myStatus == "just_arrived" || myStatus == "settling") {
                        NewInTownOptInCard { showOptInCard = true }
                    }

                    ForEach(newArrivals) { user in
                        NewArrivalCard(user: user) { selectedUser = user }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 2)
            }
        }
        .sheet(isPresented: $showOptInCard) { NewInTownOptInSheet(optedIn: $optedIn) }
        .sheet(item: $selectedUser)         { user in CommunityUserProfileView(user: user) }
    }
}

// MARK: - Arrival card
struct NewArrivalCard: View {
    let user: CommunityUser
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(user.initialsColor)
                        .frame(width: 56, height: 56)
                    Text(user.initials)
                        .font(.custom("HelveticaNeue-Bold", size: 20))
                        .foregroundColor(.white)
                }
                .overlay(alignment: .bottomTrailing) {
                    Circle()
                        .fill(Color(hex: "#34C759"))
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(Color.tsCard, lineWidth: 2))
                }

                Text(user.firstName)
                    .font(.custom("HelveticaNeue-Medium", size: 13))
                    .foregroundColor(.tsLabel)

                Text(user.timeInCityLabel)
                    .font(.custom("HelveticaNeue", size: 11))
                    .foregroundColor(.tsSecondary)

                TrustBadge(level: user.trustLevel, compact: true)
            }
            .frame(width: 80)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(Color.tsCard)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Opt-in prompt card
struct NewInTownOptInCard: View {
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.tsAccent.opacity(0.12))
                        .frame(width: 56, height: 56)
                    Image(systemName: "person.badge.plus")
                        .font(.custom("HelveticaNeue", size: 22))
                        .foregroundColor(.tsAccent)
                }
                Text("Show up")
                    .font(.custom("HelveticaNeue-Medium", size: 13))
                    .foregroundColor(.tsAccent)
                Text("Let locals\nfind you")
                    .font(.custom("HelveticaNeue", size: 11))
                    .foregroundColor(.tsSecondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .frame(width: 80).frame(maxHeight: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(Color.tsAccent.opacity(0.08))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.tsAccent.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [4]))
            )
        }
    }
}

// MARK: - Opt-in sheet
struct NewInTownOptInSheet: View {
    @Binding var optedIn: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack { Color.tsBackground.ignoresSafeArea()
                VStack(spacing: 24) {
                    Spacer()
                    Image(systemName: "person.2.fill")
                        .font(.custom("HelveticaNeue", size: 48))
                        .foregroundColor(.tsAccent)

                    VStack(spacing: 8) {
                        Text("Let the community\nknow you\'re here")
                            .font(.custom("HelveticaNeue-Bold", size: 26))
                            .foregroundColor(.tsLabel)
                            .multilineTextAlignment(.center)
                        Text("Locals and fellow newcomers can see\nyou arrived recently and say hi.")
                            .font(.custom("HelveticaNeue", size: 15))
                            .foregroundColor(.tsSecondary)
                            .multilineTextAlignment(.center)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        OptInBenefit(icon: "hand.wave.fill",    text: "Locals welcome you and share tips")
                        OptInBenefit(icon: "person.2",          text: "Meet others who just arrived too")
                        OptInBenefit(icon: "lock.fill",         text: "You control who can message you")
                        OptInBenefit(icon: "xmark.circle",      text: "Turn it off any time in Settings")
                    }
                    .padding(.horizontal, 32)

                    Spacer()

                    VStack(spacing: 12) {
                        TSButton(title: "Yes, show me in New Arrivals") {
                            optedIn = true
                            dismiss()
                        }
                        Button("Not right now") { dismiss() }
                            .font(.custom("HelveticaNeue", size: 15))
                            .foregroundColor(.tsSecondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }}
        }
    }
}

struct OptInBenefit: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.custom("HelveticaNeue", size: 16))
                .foregroundColor(.tsAccent)
                .frame(width: 24)
            Text(text)
                .font(.custom("HelveticaNeue", size: 15))
                .foregroundColor(.tsLabel)
        }
    }
}
