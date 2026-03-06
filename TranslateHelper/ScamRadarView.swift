//  ScamRadarView.swift
//  TalkSwitch

import SwiftUI

// MARK: - Models

private enum ScamSeverity: String {
    case high     = "HIGH RISK"
    case caution  = "CAUTION"
    case headsUp  = "HEADS UP"

    var color: Color {
        switch self {
        case .high:    return Color(hex: "#FF3B30")
        case .caution: return Color(hex: "#FF9500")
        case .headsUp: return Color(hex: "#34C759")
        }
    }
    var badgeIcon: String {
        switch self {
        case .high:    return "exclamationmark.triangle.fill"
        case .caution: return "exclamationmark.circle.fill"
        case .headsUp: return "info.circle.fill"
        }
    }
}

private struct Scam: Identifiable {
    let id = UUID()
    let severity: ScamSeverity
    let icon: String
    let name: String
    let tagline: String
    let howItWorks: String
    let avoid: [String]
}

private struct SubmittedAlert: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

// MARK: - Data

private let scams: [Scam] = [
    // ── HIGH RISK ──────────────────────────────────────────────────
    Scam(severity: .high, icon: "car.fill",
         name: "Express Kidnapping / Fake Taxis",
         tagline: "Fake or colluding drivers force ATM withdrawals",
         howItWorks: "A driver (often posing as a legitimate taxi, or working with a gang) picks you up, locks the doors, drives to multiple ATMs and forces you to withdraw the daily maximum. Victims are released unharmed after cash is taken. Happens mostly late at night near clubs, bars, and the airport.",
         avoid: [
             "Always book through Uber or DiDi — never hail a cab off the street",
             "If leaving a bar or club late, order your ride from inside, not on the pavement",
             "Share your trip in real-time with a friend using Uber's share feature",
             "Sit behind the driver, not the passenger seat",
         ]),
    Scam(severity: .high, icon: "person.badge.shield.checkmark.fill",
         name: "Fake Police / Bribe Demands",
         tagline: "Plainclothes 'officers' invent infractions for cash",
         howItWorks: "Someone approaches you, sometimes flashing a badge or wearing a partial uniform. They claim to have found drugs near you, or accuse you of a minor infraction (jaywalking, open container), and say you must pay a fine immediately in cash to avoid arrest.",
         avoid: [
             "Real Mexican police do not collect fines on the street — fines go through official channels",
             "Calmly say 'prefiero ir a la estación' (I prefer to go to the station). Scammers almost always back off.",
             "Ask to see their official ID (credencial). Real officers are required to show it.",
             "Never hand over your passport — offer to show it without giving it up",
         ]),
    Scam(severity: .high, icon: "wineglass.fill",
         name: "Spiked Drinks",
         tagline: "Drink tampered with, phone and cards stolen while incapacitated",
         howItWorks: "A new 'friend' or date slips something into your drink at a bar or club. Once incapacitated, your phone, wallet, and cards are stolen — or you're taken somewhere more dangerous. Documented particularly in Zona Rosa, tourist bars, and dating-app meetups gone wrong.",
         avoid: [
             "Never leave your drink unattended — if you do, order a new one",
             "Be cautious with overly friendly strangers who insist on buying you a drink",
             "Meet dates from apps in public places you chose yourself, not places they suggest",
             "Go out with a friend and have a system — check in on each other",
             "If you feel suddenly dizzy or unusual, tell bar staff immediately and call a friend",
         ]),

    // ── CAUTION ───────────────────────────────────────────────────
    Scam(severity: .caution, icon: "creditcard.and.123",
         name: "ATM Skimming",
         tagline: "Card reader installed over the ATM slot captures your data",
         howItWorks: "A small device is placed over the card slot of an ATM (often a freestanding one in an Oxxo or mini-market). It reads your card data. A tiny camera above the keypad captures your PIN. Data is cloned onto a blank card and used to drain your account.",
         avoid: [
             "Use ATMs inside bank branches — avoid freestanding machines at convenience stores",
             "Wiggle the card slot before inserting — a skimmer feels loose",
             "Always cover the keypad with your other hand when typing your PIN",
             "Use contactless payment or Apple Pay where possible — no card, no skimmer",
             "Set up transaction alerts on your phone so you're notified of every charge",
         ]),
    Scam(severity: .caution, icon: "tshirt.fill",
         name: "The Mustard / Ketchup Distraction",
         tagline: "Something lands on you — an accomplice picks your pocket",
         howItWorks: "A stranger 'accidentally' spills mustard, ketchup, or bird droppings on your clothing. They or an accomplice immediately rush to help you clean up. While you're distracted and looking down, your phone, wallet, or bag are taken. Common near Centro Histórico, the Metro, and tourist markets.",
         avoid: [
             "Politely decline help from strangers who spill things on you — walk away",
             "Keep your phone in a front pocket or inside a zipped bag in crowded areas",
             "Be especially alert near the Metro during rush hour and in tourist areas",
         ]),
    Scam(severity: .caution, icon: "fork.knife",
         name: "Tab Inflation at Bars & Restaurants",
         tagline: "Items added to your bill you never ordered",
         howItWorks: "Extra drinks, items, or a 'cubierto' (cover charge) appear on your bill. Sometimes it's an honest mistake; sometimes intentional with tourists. Particularly common in Zona Rosa nightlife strips and tourist-facing restaurants near the Zócalo.",
         avoid: [
             "Ask for an itemised bill (cuenta desglosada) before paying",
             "Check every line — query anything you don't recognise",
             "Ask about cover charges before sitting down",
             "Pay attention when the card terminal is brought to you — verify the amount",
         ]),
    Scam(severity: .caution, icon: "dollarsign.circle.fill",
         name: "Currency Exchange Shortchanging",
         tagline: "Rigged calculators or sleight of hand at dodgy casas de cambio",
         howItWorks: "Exchange booths near tourist areas (airport, Zócalo, Insurgentes) may quote competitive rates but shortchange you in the hand-off using a rigged counting method, fast-handed bill swap, or a calculator that shows one number while calculating another.",
         avoid: [
             "Check the live rate on xe.com or Google before approaching any booth",
             "Count your money before leaving the window — never walk away first",
             "Use Wise or a bank ATM instead — far better rates, zero sleight of hand",
             "Avoid exchange booths inside the airport — rates are always worse",
         ]),
    Scam(severity: .caution, icon: "wifi",
         name: "Fake Public WiFi Honeypots",
         tagline: "Rogue hotspot captures your login credentials and traffic",
         howItWorks: "A fake WiFi network named something like 'Starbucks_Free' or 'Airport_WiFi' is set up in a café or public space. When you connect, all unencrypted traffic can be intercepted — including banking app logins, emails, and passwords.",
         avoid: [
             "Use a VPN (NordVPN, ExpressVPN, Mullvad) whenever on public WiFi",
             "Verify the network name with staff before connecting",
             "Use mobile data for banking and anything sensitive",
             "Enable HTTPS-only mode in your browser",
         ]),
    Scam(severity: .caution, icon: "house.fill",
         name: "Rental Deposit Scams",
         tagline: "Fake listing takes your deposit and disappears",
         howItWorks: "A listing looks real — photos, a nice conversation, maybe even a fake contract. You're asked to wire a deposit to hold the apartment. Once paid, the 'landlord' goes silent and the listing vanishes. Common on Facebook Marketplace and Craigslist where verification is minimal.",
         avoid: [
             "Never wire money to hold a rental before signing a contract and viewing the property",
             "Use platforms with built-in protections: Homie, Airbnb, Inmuebles24 agents",
             "Video call the landlord and ask them to walk through the apartment on camera",
             "Reverse-image-search the listing photos — scammers reuse real photos from other listings",
         ]),

    // ── HEADS UP ──────────────────────────────────────────────────
    Scam(severity: .headsUp, icon: "heart.fill",
         name: "Romance Scams",
         tagline: "Intense connection quickly pivots to a money request",
         howItWorks: "You match on Tinder, Bumble or Hinge. The person is unusually attentive — they move to WhatsApp quickly, message constantly, seem perfect. After a week or two of emotional investment they reveal a crisis: a sick relative, a business opportunity you could 'invest' in together, or an emergency needing a transfer. You never meet in person (or the in-person meetup is cut short). The money never comes back.",
         avoid: [
             "Be sceptical of anyone who escalates emotionally very fast",
             "Never send money to someone you haven't met in person multiple times",
             "Video calls are good but not conclusive — deepfakes exist",
             "If they pitch an 'investment opportunity', block immediately — this is a known variant called pig butchering",
         ]),
    Scam(severity: .headsUp, icon: "car.2.fill",
         name: "Fake Uber / Unsolicited Ride Offers",
         tagline: "'Your Uber is here' outside clubs — it isn't",
         howItWorks: "Someone outside a club or bar approaches people waiting for rides and says 'are you waiting for an Uber? That's me.' Victims get in. Best case: overcharged for the ride. Worst case: connects back to the express kidnapping risk. Also happens with people offering 'cheaper' rides than Uber at the airport.",
         avoid: [
             "Always check the plate number AND driver's face against the app before getting in",
             "Wait for your ride inside the venue, not on the street",
             "Never accept rides from people who approach you — only get in a car you booked",
         ]),
    Scam(severity: .headsUp, icon: "bag.fill",
         name: "Market Overcharging",
         tagline: "Tourist prices quoted — haggling is expected",
         howItWorks: "At artisan markets (La Ciudadela, Mercado de Artesanías) and some street stalls, the first price quoted to an obvious foreigner is 2–3x what a local would pay. This isn't exactly a scam — it's cultural — but it catches many people off guard.",
         avoid: [
             "Counter-offer at 40–50% of the first price and negotiate from there",
             "Walk away if the price doesn't move — they'll often call you back",
             "Research typical prices for common items (blankets, silver jewellery, pottery) before shopping",
             "Locals don't pay the tourist price — don't feel bad negotiating hard",
         ]),
    Scam(severity: .headsUp, icon: "ticket.fill",
         name: "Fake Event Tickets",
         tagline: "Scalpers outside venues sell worthless paper",
         howItWorks: "Outside Arena México (Lucha Libre), Foro Sol, or concert venues, scalpers sell tickets that look real but are counterfeits or already-used stubs. You only find out at the gate.",
         avoid: [
             "Buy directly from the official box office or Ticketmaster.com.mx",
             "If buying from resellers, only use verifiable platforms (StubHub)",
             "Inspect tickets carefully — poor print quality, missing holograms are red flags",
         ]),
]

// MARK: - Main View

struct ScamRadarView: View {
    @State private var showSubmitSheet = false
    @State private var submittedAlerts: [SubmittedAlert] = []
    @State private var expanded: UUID? = nil
    @State private var showThanks = false

    private var highRisk:  [Scam] { scams.filter { $0.severity == .high } }
    private var caution:   [Scam] { scams.filter { $0.severity == .caution } }
    private var headsUp:   [Scam] { scams.filter { $0.severity == .headsUp } }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                TSGradientBackground()
                ScrollView {
                    VStack(spacing: 0) {
                        VStack(spacing: 16) {

                            // ── Crowdsource banner ────────────────────
                            Button { showSubmitSheet = true } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "#FF3B30").opacity(0.12))
                                            .frame(width: 52, height: 52)
                                        Text("🚨").font(.system(size: 26))
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Scam Alert")
                                            .font(.custom("HelveticaNeue-Bold", size: 17))
                                            .foregroundColor(.tsLabel)
                                        Text("Seen something suspicious? Help protect the community.")
                                            .font(.custom("HelveticaNeue", size: 13))
                                            .foregroundColor(.tsSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer(minLength: 4)
                                    VStack(spacing: 3) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(Color(hex: "#FF3B30"))
                                        Text("Submit")
                                            .font(.custom("HelveticaNeue-Medium", size: 11))
                                            .foregroundColor(Color(hex: "#FF3B30"))
                                    }
                                }
                                .padding(16)
                                .background(Color.tsCard)
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "#FF3B30").opacity(0.22), lineWidth: 1))
                            }
                            .buttonStyle(ScaleButtonStyle())

                            // ── Community submitted alerts ────────────
                            if !submittedAlerts.isEmpty {
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("COMMUNITY ALERTS")
                                            .font(.custom("HelveticaNeue-Bold", size: 11))
                                            .foregroundColor(.tsSecondary).tracking(0.8)
                                        Spacer()
                                        Text("\(submittedAlerts.count) recent")
                                            .font(.custom("HelveticaNeue", size: 12))
                                            .foregroundColor(.tsSecondary)
                                    }
                                    VStack(spacing: 0) {
                                        ForEach(submittedAlerts.reversed()) { alert in
                                            HStack(alignment: .top, spacing: 10) {
                                                Text("🚨").font(.system(size: 16))
                                                VStack(alignment: .leading, spacing: 3) {
                                                    Text(alert.title)
                                                        .font(.custom("HelveticaNeue-Bold", size: 14))
                                                        .foregroundColor(.tsLabel)
                                                    Text(alert.body)
                                                        .font(.custom("HelveticaNeue", size: 13))
                                                        .foregroundColor(.tsSecondary)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                }
                                            }
                                            .padding(14)
                                            if alert.id != submittedAlerts.last?.id {
                                                Divider().padding(.leading, 44)
                                            }
                                        }
                                    }
                                    .background(Color.tsCard).cornerRadius(14)
                                    .overlay(RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color(hex: "#FF3B30").opacity(0.15), lineWidth: 0.5))
                                }
                            }

                            // ── Scam sections ─────────────────────────
                            ScamSection(label: "🔴  HIGH RISK", color: Color(hex: "#FF3B30"),
                                        scams: highRisk, expanded: $expanded)
                            ScamSection(label: "🟠  USE CAUTION", color: Color(hex: "#FF9500"),
                                        scams: caution, expanded: $expanded)
                            ScamSection(label: "🟢  HEADS UP", color: Color(hex: "#34C759"),
                                        scams: headsUp, expanded: $expanded)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 96)
                    }
                }

                // ── Thanks toast ──────────────────────────────────
                if showThanks {
                    VStack {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "#34C759"))
                            Text("Alert submitted — thanks for keeping it real 🙌")
                                .font(.custom("HelveticaNeue-Medium", size: 14))
                                .foregroundColor(.tsLabel)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .background(Color.tsCard)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
                        .padding(.top, 8)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .navigationTitle("Scam Radar")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showSubmitSheet) {
                SubmitScamSheet { title, body in
                    submittedAlerts.append(SubmittedAlert(title: title, body: body))
                    withAnimation(.spring()) { showThanks = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation { showThanks = false }
                    }
                }
            }
        }
    }
}

// MARK: - Scam Section

private struct ScamSection: View {
    let label: String
    let color: Color
    let scams: [Scam]
    @Binding var expanded: UUID?

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(label)
                    .font(.custom("HelveticaNeue-Bold", size: 11))
                    .foregroundColor(color).tracking(0.6)
                Spacer()
            }
            VStack(spacing: 0) {
                ForEach(scams) { scam in
                    ScamCard(scam: scam, isExpanded: expanded == scam.id) {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            expanded = expanded == scam.id ? nil : scam.id
                        }
                    }
                    if scam.id != scams.last?.id {
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .background(Color.tsCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.10), lineWidth: 0.5))
        }
    }
}

// MARK: - Scam Card

private struct ScamCard: View {
    let scam: Scam
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(scam.severity.color.opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: scam.icon)
                            .font(.system(size: 16))
                            .foregroundColor(scam.severity.color)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(scam.name)
                                .font(.custom("HelveticaNeue-Bold", size: 15))
                                .foregroundColor(.tsLabel)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            // Severity badge
                            HStack(spacing: 3) {
                                Image(systemName: scam.severity.badgeIcon)
                                    .font(.system(size: 8))
                                Text(scam.severity.rawValue)
                                    .font(.custom("HelveticaNeue-Bold", size: 9))
                            }
                            .foregroundColor(scam.severity.color)
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(scam.severity.color.opacity(0.10))
                            .cornerRadius(5)
                        }
                        Text(scam.tagline)
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsSecondary)
                    }
                }
                .padding(.horizontal, 14).padding(.vertical, 14)
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                VStack(alignment: .leading, spacing: 14) {
                    Divider().background(scam.severity.color.opacity(0.12))

                    // How it works
                    VStack(alignment: .leading, spacing: 6) {
                        Text("HOW IT WORKS")
                            .font(.custom("HelveticaNeue-Bold", size: 11))
                            .foregroundColor(.tsSecondary).tracking(0.5)
                        Text(scam.howItWorks)
                            .font(.custom("HelveticaNeue", size: 14))
                            .foregroundColor(.tsLabel)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // How to avoid
                    VStack(alignment: .leading, spacing: 8) {
                        Text("HOW TO AVOID IT")
                            .font(.custom("HelveticaNeue-Bold", size: 11))
                            .foregroundColor(.tsSecondary).tracking(0.5)
                        ForEach(scam.avoid, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "shield.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(scam.severity.color)
                                    .padding(.top, 1)
                                Text(tip)
                                    .font(.custom("HelveticaNeue", size: 13))
                                    .foregroundColor(.tsLabel)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding(.horizontal, 14).padding(.bottom, 16)
            }
        }
    }
}

// MARK: - Submit Sheet

private struct SubmitScamSheet: View {
    let onSubmit: (String, String) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @FocusState private var focused: Bool

    var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle().fill(Color(hex: "#FF3B30").opacity(0.10))
                                .frame(width: 80, height: 80)
                            Text("🚨").font(.system(size: 40))
                        }
                        .padding(.top, 24)

                        VStack(spacing: 6) {
                            Text("Submit a Scam Alert")
                                .font(.custom("HelveticaNeue-Bold", size: 22))
                                .foregroundColor(.tsLabel)
                            Text("Help protect the community.\nKeep it factual and specific.")
                                .font(.custom("HelveticaNeue", size: 14))
                                .foregroundColor(.tsSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }

                    // Fields
                    VStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("SCAM NAME OR TYPE")
                                .font(.custom("HelveticaNeue-Bold", size: 11))
                                .foregroundColor(.tsSecondary).tracking(0.5)
                            TextField("e.g. Fake taxi near Zona Rosa", text: $title)
                                .font(.custom("HelveticaNeue", size: 16))
                                .foregroundColor(.tsLabel)
                                .padding(14)
                                .background(Color.tsInputBg)
                                .cornerRadius(12)
                                .focused($focused)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("WHAT HAPPENED / HOW TO AVOID IT")
                                .font(.custom("HelveticaNeue-Bold", size: 11))
                                .foregroundColor(.tsSecondary).tracking(0.5)
                            ZStack(alignment: .topLeading) {
                                if description.isEmpty {
                                    Text("Describe what happened and how others can protect themselves...")
                                        .font(.custom("HelveticaNeue", size: 15))
                                        .foregroundColor(.tsSecondary.opacity(0.55))
                                        .padding(.horizontal, 14).padding(.top, 14)
                                }
                                TextEditor(text: $description)
                                    .font(.custom("HelveticaNeue", size: 15))
                                    .foregroundColor(.tsLabel)
                                    .frame(minHeight: 130)
                                    .padding(10)
                                    .scrollContentBackground(.hidden)
                            }
                            .background(Color.tsInputBg)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Submit button
                    Button {
                        let t = title.trimmingCharacters(in: .whitespaces)
                        let d = description.trimmingCharacters(in: .whitespaces)
                        onSubmit(t, d)
                        dismiss()
                    } label: {
                        Text("Submit Alert")
                            .font(.custom("HelveticaNeue-Bold", size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(canSubmit ? Color(hex: "#FF3B30") : Color.tsSecondary.opacity(0.3))
                            .cornerRadius(14)
                    }
                    .disabled(!canSubmit)
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.tsBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.custom("HelveticaNeue", size: 17))
                        .foregroundColor(.tsAccent)
                }
            }
            .onAppear { focused = true }
        }
    }
}
