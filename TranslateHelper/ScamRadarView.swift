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
        case .headsUp: return Color(hex: "#FFCC00")
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
    let prevalence: String
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

    // ── HIGH RISK ──────────────────────────────────────────────────────────────

    Scam(severity: .high, icon: "car.fill",
         name: "Express Kidnapping / Fake Taxis",
         tagline: "Fake or colluding drivers force ATM withdrawals at gunpoint",
         prevalence: "CDMX recorded roughly 1,900 express kidnappings in 2023 — tourists are a minority of victims but are specifically targeted near the airport, Zona Rosa, and Polanco between midnight and 4am. The overwhelming majority end without physical harm once cash is taken. Risk drops to near-zero with Uber or DiDi booked from inside a venue.",
         howItWorks: "A driver — posing as a legitimate taxi or working with a gang — picks you up and locks the doors. They drive to multiple ATMs and force you to withdraw the daily maximum (typically $500–800 USD equivalent in pesos). The daily ATM limit is well-known to them, so they hit several machines. Victims are released unharmed after cash is taken. Drivers are sometimes tipped off by bar staff, parking attendants, or hotel concierge — trust the app, not a recommendation from someone you just met. The risk is almost entirely concentrated in the late-night window; daytime taxi kidnappings are extremely rare.",
         avoid: [
             "Book every ride through Uber or DiDi — never hail a street cab, ever, regardless of how convenient it looks",
             "Before getting in: confirm licence plate, car make, colour AND the driver's face match the app exactly",
             "Use Uber's 'Share Trip' feature — send your live location to a friend or family member",
             "Wait inside the venue until the app shows your driver arriving — not on the pavement",
             "Sit behind the driver, not the front passenger seat — harder to control from there",
             "If something feels wrong after you're already in, call someone loudly: 'I'm in an Uber, heading to [address]' — drivers have aborted on this alone",
             "Late-night airport arrivals: use only the official CDMX airport taxi booths inside the terminal — prepaid, registered, and far safer than anything on the kerb",
         ]),

    Scam(severity: .high, icon: "person.badge.shield.checkmark.fill",
         name: "Fake Police / Bribe Demands",
         tagline: "Plainclothes 'officers' invent infractions and demand immediate cash",
         prevalence: "This is consistently one of the top three tourist complaints received by Mexico City's Secretaría de Turismo. Incidents cluster near the Zócalo, Zona Rosa, and Coyoacán market. It's common enough that the US, UK, and Canadian embassies all include it in their Mexico City travel advisories. Real Mexican police almost never stop tourists on the street for minor infractions.",
         howItWorks: "One or two people approach you — sometimes flashing a badge, sometimes in a partial uniform — and claim to have found drugs near you, or accuse you of a minor infraction (jaywalking, an open drink, 'suspicious behaviour'). They say you must pay a fine immediately in cash to avoid arrest or a lengthy process at the station. They often work in pairs: one distracts, one plays authority. Tourists with large cameras, maps out, or who look disoriented are prime targets. The whole interaction is designed to create urgency and fear — both of which cloud judgment fast.",
         avoid: [
             "The single most powerful phrase: 'Prefiero ir a la estación' (I prefer to go to the station) — say it calmly. Real officers welcome this. Scammers almost always back off immediately.",
             "Real Mexican police NEVER collect fines on the street — all fines go through official municipal channels",
             "Ask to see their credencial oficial (official ID card) — real officers are legally required to show it on request",
             "Never get into an unmarked vehicle with anyone claiming to be police, under any circumstances",
             "Never hand over your passport physically — hold it open to show, but do not release it from your hand",
             "Call 911 or the Tourist Police hotline (55 5207-4155) on the spot if you feel threatened",
             "Move toward a busy, well-lit, public space — scammers rely on isolation",
         ]),

    Scam(severity: .high, icon: "wineglass.fill",
         name: "Spiked Drinks",
         tagline: "Drink tampered with, then phone and cards stolen while incapacitated",
         prevalence: "The US, UK, and Canadian embassies all issue active travel warnings specifically about drink spiking in CDMX. Documented incidents cluster in Zona Rosa (particularly LGBT-facing venues), Condesa, Roma Norte bars, and dating-app meetups. GHB — the most common agent — is colourless, odourless, and takes effect in 15–30 minutes. Many victims don't report it due to embarrassment, so actual numbers are believed to be significantly higher than official records show.",
         howItWorks: "A new 'friend' or date spends 20–40 minutes building genuine rapport with you first — this is deliberate. Then they slip GHB or a similar substance into your drink while you're distracted. Once incapacitated, your phone, wallet, and cards are taken. In some cases you're moved to a second location. Dating-app meetups gone wrong are a growing variant: you arrive at a venue the other person chose, where they may have accomplices already in place. The social engineering is sophisticated — these aren't random attacks.",
         avoid: [
             "Never leave your drink unattended — if you do, order a new one. No exceptions, ever.",
             "Be alert to anyone who is unusually attentive and repeatedly offers to buy you drinks",
             "For app dates: always choose the venue yourself, in a neighbourhood you already know",
             "Go out with a trusted friend and have an explicit check-in system between you throughout the night",
             "Know the warning signs: sudden dizziness, nausea, or confusion after just 1–2 drinks is a serious red flag",
             "If you feel suddenly impaired, go directly to bar staff — not the bathroom alone",
             "Drink-spiking test strips (available cheaply online) can be tucked in a wallet and dipped discreetly",
             "Cover your drink with your palm when not actively drinking",
         ]),

    // ── CAUTION ────────────────────────────────────────────────────────────────

    Scam(severity: .caution, icon: "creditcard.and.123",
         name: "ATM Skimming",
         tagline: "Card reader installed over the slot captures your data silently",
         prevalence: "Mexico's financial regulator Condusef logs tens of thousands of cloned-card complaints annually. Mexico consistently ranks in the top three countries globally for ATM fraud. Freestanding machines at Oxxo, 7-Eleven, and mini-markets are the most compromised — bank-branch ATMs are significantly safer but not immune. Skimming equipment can be installed and removed in under two minutes.",
         howItWorks: "A thin overlay device is placed precisely over the card slot — nearly invisible and tactilely similar to the real slot. It reads your card's magnetic strip on insertion. A pinhole camera above the keypad or a transparent PIN-pad overlay captures your code. Your data is cloned onto a blank card and used remotely within hours, or sold to a network. Some sophisticated operations also intercept chip data, though magnetic strip cloning remains the most common method in CDMX.",
         avoid: [
             "Use ATMs inside bank branches only — avoid all freestanding machines at convenience stores",
             "Before inserting: wiggle the card slot firmly. A skimmer overlay feels slightly loose or sits at a different depth",
             "Always cover the entire keypad with your other hand when entering your PIN",
             "Use Apple Pay, Google Pay, or contactless tap — no physical card insertion means no skimmer risk",
             "Enable instant transaction SMS or push alerts through your bank app for every charge",
             "If your card is retained by a machine unexpectedly, call your bank to freeze it immediately — don't wait",
             "Withdraw larger amounts less frequently rather than small amounts often — fewer exposures to compromised machines",
         ]),

    Scam(severity: .caution, icon: "tshirt.fill",
         name: "The Mustard / Ketchup Distraction",
         tagline: "Something lands on you — an accomplice picks your pocket while you're helped",
         prevalence: "CDMX's Policía Turística explicitly warns about this in tourist area briefings. Highest concentration near the Zócalo, Metro Bellas Artes, Mercado de Artesanías, and the Centro Histórico pedestrian zones. The bird-dropping variant operates under the dense trees around Alameda Central. It works because the victim's instinct — look down, accept help — is completely predictable and automatic.",
         howItWorks: "A stranger 'accidentally' squirts mustard, ketchup, or a realistic bird-dropping substance on your shoulder or bag. They — or an accomplice who appears a moment later — immediately rush to help you clean up, apologising and producing napkins. While you're distracted, looking down, and being touched on one side by a helpful person, your phone (from a back pocket or open bag), wallet, or camera is lifted by the other. The operation is under 20 seconds. It succeeds because the 'help' genuinely feels kind and the victim never looks around.",
         avoid: [
             "If something suddenly lands on you in a tourist area: decline all help politely but immediately, and walk away first",
             "Clean up in a private spot — café bathroom, your hotel — not standing on the street",
             "Phone in a front trouser pocket or inside a zipped compartment of your bag at all times in crowded areas",
             "Bags worn cross-body with the clasp and zip facing your body, not outward",
             "Be especially alert near Metro station entrances during rush hours — highest pickpocket density in CDMX",
         ]),

    Scam(severity: .caution, icon: "fork.knife",
         name: "Tab Inflation at Bars & Restaurants",
         tagline: "Items appear on your bill that you never ordered",
         prevalence: "Tab padding is one of the most commonly reported tourist experiences across CDMX nightlife and tourist-facing restaurants. Garibaldi (Mariachi Plaza), Zona Rosa clubs, and Zócalo-adjacent cantinas are particularly documented. The cubierto (cover charge) is a legitimate practice at many venues but is also regularly used as a silent add-on that tourists don't notice or question.",
         howItWorks: "Extra drinks, snacks, or a cubierto appear on your bill at checkout. Sometimes a 'tourist menu' with higher prices is handed to non-locals while locals receive a cheaper version — two menus in circulation simultaneously. In clubs, bottles are opened and added to tables without explicit consent. In a common card terminal scam, the waiter enters the total facing away from you, then hands the terminal over after the amount is already locked in. Itemised receipts are rarely offered proactively.",
         avoid: [
             "Ask for an itemised bill (cuenta desglosada) before paying — always, every time",
             "Ask about cover charges before sitting down, not after you've ordered",
             "In clubs: establish bottle prices explicitly and in writing (or photograph the menu price) before they're opened",
             "When the terminal is handed to you, re-read the total displayed before entering your PIN or tapping",
             "Challenge discrepancies calmly but firmly: 'Esto no lo ordené' (I didn't order this)",
             "Paying cash at taco spots and casual cantinas reduces terminal manipulation risk",
         ]),

    Scam(severity: .caution, icon: "dollarsign.circle.fill",
         name: "Currency Exchange Shortchanging",
         tagline: "Rigged calculators or sleight of hand at dodgy casas de cambio",
         prevalence: "Mexico's consumer protection agency Profeco has issued formal warnings about exchange booth practices in tourist zones. Airport booths routinely offer rates 15–20% below the interbank rate — before any shortchanging occurs. Zócalo and Insurgentes-adjacent booths are the most complained-about in CDMX tourism reports. Using a bank ATM or Wise card instead typically saves 12–18% on every transaction.",
         howItWorks: "Booths in tourist areas quote a competitive rate to draw you in, then shortchange during the hand-off. Common methods: a rigged calculator display that shows one number while computing another; a fast bill swap where smaller denominations are folded inside larger ones; a distraction mid-count (a phone rings, a question is asked). The airport is the worst environment — cashiers work fast, queues create pressure, and the unfamiliar currency makes errors harder to spot. Victims rarely notice until they count their cash later.",
         avoid: [
             "Check the live mid-market rate on Google or xe.com before approaching any booth",
             "Use a Wise debit card or your bank's ATM — near-interbank rates with zero sleight of hand",
             "If you must use a booth: count every bill yourself, slowly, before stepping away from the window",
             "Slow down deliberately if they're rushing you — that urgency is a tactic",
             "Skip all airport exchange booths entirely; use the ATM in the international arrivals hall",
             "Better exchange neighbourhoods: Santa Fe, Polanco — avoid anything marketed as 'Zona Turística'",
         ]),

    Scam(severity: .caution, icon: "wifi",
         name: "Fake Public WiFi Honeypots",
         tagline: "Rogue hotspot captures your logins and traffic invisibly",
         prevalence: "Kaspersky consistently ranks Mexico in the top three Latin American countries for public WiFi attacks. Airports, hotel lobbies, and cafés are the highest-risk environments. Setting up a rogue hotspot requires equipment that costs under $30 and basic technical knowledge — the barrier is extremely low, and the payoff on captured banking credentials is high.",
         howItWorks: "A fake WiFi network named something convincing — 'Starbucks_Free', 'Hotel_Lobby_WiFi', 'AICM_Airport' — is broadcast in a public space. When you connect, all unencrypted traffic is visible to the attacker. More sophisticated setups perform a man-in-the-middle attack, silently intercepting and logging traffic even on HTTPS connections if your device auto-trusts the certificate. Banking sessions, email logins, and any credentials entered during the session are at risk. You'll never know it happened.",
         avoid: [
             "Use a VPN on all public WiFi — Mullvad, ProtonVPN, or ExpressVPN all work well and are worth the small cost",
             "Verify the exact network name directly with staff before connecting — one character off is the giveaway",
             "Use your phone's mobile data for banking, email, and anything with a login",
             "Enable HTTPS-only mode in your browser settings (available in Chrome, Firefox, and Safari)",
             "Turn off auto-connect to open/known networks in your device's WiFi settings when travelling",
         ]),

    Scam(severity: .caution, icon: "house.fill",
         name: "Rental Deposit Scams",
         tagline: "Fake listing collects your deposit, then vanishes",
         prevalence: "Facebook Marketplace and Craigslist rental scams targeting foreign renters have surged sharply in CDMX since 2021, fuelled by the remote-work nomad influx. Colonia Roma, Condesa, and Polanco are the most impersonated neighbourhoods — their desirability makes fake listings easy to present convincingly. Losses typically range from one to three months rent ($800–3,000 USD) per victim.",
         howItWorks: "A listing looks completely real — professional photos, warm conversational Spanish or English, possibly a fake lease template with real-looking legal language. You're asked to wire a deposit (often one to two months rent) to 'hold' the apartment before someone else takes it. Once paid, the landlord goes silent and the listing disappears. Some operations add a fake video tour to build further trust before the request. In a newer variant, they string you along for several weeks to increase the emotional investment before the ask.",
         avoid: [
             "Never wire money to hold a rental — no legitimate landlord in Mexico requires this before a signed lease and in-person viewing",
             "Video-call the landlord and ask them to walk through the apartment live, on camera — scammers cannot do this",
             "Reverse-image-search every listing photo — stolen real-estate images are the giveaway",
             "Use platforms with built-in protections: Airbnb for short stays, Homie or Inmuebles24 with verified agents for longer rentals",
             "Meet in person at the property and verify the landlord's ID before any money changes hands",
             "A convincing fake contract means nothing without a physical meeting — scammers send very professional-looking documents",
         ]),

    // ── HEADS UP ───────────────────────────────────────────────────────────────

    Scam(severity: .headsUp, icon: "heart.fill",
         name: "Romance Scams",
         tagline: "Intense connection builds for weeks, then pivots to a money request",
         prevalence: "The FBI's IC3 reported romance scam losses of over $1.3 billion USD in 2022 globally — experts believe this represents under 10% of actual cases due to embarrassment-related underreporting. A specific variant called 'pig butchering' (long-con crypto investment fraud) has grown significantly in Mexico, often operated by organised criminal networks targeting English-speaking visitors and expats.",
         howItWorks: "You match on Tinder, Bumble, or Hinge. The person is unusually attentive — they move to WhatsApp fast, message constantly, remember every detail you share, and seem almost perfect. After one to three weeks of real emotional investment, a crisis appears: a sick relative, a limited-window crypto or stock investment you could 'get in on together', or a travel emergency. Sometimes they visit once in person before the financial ask — this physical meeting is deliberate trust-building. The pig-butchering variant is more patient: they guide you through small profitable trades first, then encourage ever-larger investments before executing a full exit with everything deposited.",
         avoid: [
             "Be genuinely sceptical of unusually fast emotional escalation — it's a documented technique, not just great chemistry",
             "Never send money, gift cards, or crypto to someone you haven't met in person multiple times",
             "Video calls are useful but not conclusive — AI deepfakes can now convincingly fake real-time video",
             "Any mention of an investment 'opportunity' — especially crypto — is an immediate red flag regardless of how it's framed",
             "Tell a trusted friend IRL about the relationship and take their reaction seriously — outside perspective breaks the isolation these scams depend on",
         ]),

    Scam(severity: .headsUp, icon: "car.2.fill",
         name: "Fake Uber / Unsolicited Ride Offers",
         tagline: "'Your Uber is here' outside clubs — but it isn't yours",
         prevalence: "This scam functions as a direct feeder into express kidnapping risk. Most documented cases occur between midnight and 3am outside clubs in Condesa, Polanco, and Zona Rosa. Uber Mexico issued a specific safety warning to CDMX users in 2023 following a spike in 'wrong car' incidents. Airport arrivals are a secondary hotspot, where unofficial drivers offer 'better rates' than licensed taxis.",
         howItWorks: "Someone outside a bar or club approaches people waiting for rides and says 'Are you [common name]? Your Uber's here.' Targets who are tired or slightly drunk and relieved to see their ride will comply and get in without checking. The driver either dramatically overcharges, takes an indirect route, or in worst-case scenarios connects to express kidnapping networks. The airport version involves men near the arrivals exit offering 'cheaper' rides than the official taxi counters — appealing to travellers who've just landed and want to save money.",
         avoid: [
             "Always verify all three before getting in: plate number, car make/colour, AND driver's face — all must match the app",
             "The driver should say your name unprompted — you never tell them your name first",
             "Wait inside the venue until the app shows your driver is one to two minutes away",
             "Never accept a ride from anyone who approaches you, regardless of how plausible they sound",
             "Airport arrivals: use only the prepaid taxi counters inside the terminal, or open the Uber app yourself from inside arrivals hall",
         ]),

    Scam(severity: .headsUp, icon: "bag.fill",
         name: "Market Overcharging",
         tagline: "Tourist prices quoted — haggling is normal and expected",
         prevalence: "Tiered pricing for foreigners is a cultural norm across informal Mexican markets — not inherently a scam, but a system that catches unprepared visitors off guard. The gap between the tourist opening price and the local price is typically 2–4x at artisan markets. Knowing this going in turns what could be a frustrating experience into a fun and fair negotiation.",
         howItWorks: "At La Ciudadela, Mercado de Artesanías, and most street stalls throughout Centro, the first price quoted to an obvious foreigner is well above what a Mexican local would pay — sometimes 3x. Vendors read signals: big camera, guidebook, asking questions in accented Spanish, or looking uncertain about prices. The inflated first offer is both a business strategy and a social expectation that the visitor will negotiate. Most tourists simply pay it, unaware that haggling is entirely normal and even appreciated.",
         avoid: [
             "Counter-offer at 40–50% of the first price and work up from there — this is the expected opening",
             "Walk away slowly if the price doesn't move — vendors will often call you back with a better number",
             "Buy multiple items from the same stall and negotiate a bundle price",
             "Rough price guides: artisan blanket 200–350 MXN, silver bracelet 150–300 MXN, hand-painted pottery piece 80–200 MXN, embroidered bag 250–500 MXN",
             "Relaxed, friendly negotiating consistently gets better results than aggressive or impatient bargaining",
             "Locals never pay the tourist price — don't feel awkward about negotiating firmly",
         ]),

    Scam(severity: .headsUp, icon: "ticket.fill",
         name: "Fake Event Tickets",
         tagline: "Scalpers sell counterfeits or already-scanned stubs outside venues",
         prevalence: "Counterfeit ticket operations outside Arena México, Foro Sol, and Palacio de los Deportes are persistent enough that venue security teams specifically warn arriving crowds. Lucha Libre events are a favourite target given their strong tourist appeal and relatively informal ticket culture. A newer digital variant — selling legitimate tickets then immediately invalidating the barcode via a refund — has emerged as QR-based entry becomes standard.",
         howItWorks: "Scalpers outside arenas sell tickets that look convincing — correct venue logo, plausible print quality — but are counterfeits or previously scanned stubs. The victim only discovers this at the turnstile, at which point the scalper has disappeared. In the QR invalidation variant, the scalper sells you a genuinely valid ticket, then immediately processes a refund through Ticketmaster on their end — voiding the barcode — before you have a chance to use it.",
         avoid: [
             "Buy exclusively from the official box office on-site or Ticketmaster.com.mx — no exceptions for sold-out or high-demand events",
             "If using a reseller, use only platforms with explicit buyer protection guarantees like StubHub",
             "Physical tickets: poor print quality, missing holograms, or unusually thin paper are all red flags",
             "For Lucha Libre at Arena México: tickets are sold at the arena box office on the day of the event — no need to go near scalpers",
             "Screenshot your QR code and verify it renders correctly in the Ticketmaster app before you leave home — a valid QR will resolve correctly",
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
                Color.tsBackground.ignoresSafeArea()
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
                                .background(Color(hex: "#FF3B30").opacity(0.10))
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
                            ScamSection(label: "🟡  HEADS UP", color: Color(hex: "#FFCC00"),
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
                            .fill(Color.tsSecondary.opacity(0.1))
                            .frame(width: 40, height: 40)
                        Image(systemName: scam.icon)
                            .font(.system(size: 16))
                            .foregroundColor(.tsSecondary)
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
                VStack(alignment: .leading, spacing: 16) {
                    Divider().background(scam.severity.color.opacity(0.12))

                    // ── Prevalence chip ────────────────────────────
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 11))
                            .foregroundColor(scam.severity.color)
                            .padding(.top, 1)
                        Text(scam.prevalence)
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsLabel.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .background(scam.severity.color.opacity(0.07))
                    .cornerRadius(10)

                    // ── How it works ───────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        Text("HOW IT WORKS")
                            .font(.custom("HelveticaNeue-Bold", size: 11))
                            .foregroundColor(.tsSecondary).tracking(0.5)
                        Text(scam.howItWorks)
                            .font(.custom("HelveticaNeue", size: 14))
                            .foregroundColor(.tsLabel)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(3)
                    }

                    // ── How to avoid ───────────────────────────────
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
