//  BureaucracyView.swift
//  TalkSwitch

import SwiftUI

// MARK: - Tab

private enum BureauTab: String, CaseIterable {
    case banking    = "Banking"
    case visas      = "Visas"
    case healthcare = "Health"
    case renting    = "Renting"
    case consulate  = "Consulate"
}

// MARK: - Main View

struct BureaucracyView: View {
    @State private var tab: BureauTab = .banking
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ZStack { TSGradientBackground()
                ScrollView {
                    VStack(spacing: 0) {

                        // ── Tab picker ────────────────────────────────────
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(BureauTab.allCases, id: \.self) { t in
                                    Button {
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) { tab = t }
                                    } label: {
                                        Text(t.rawValue)
                                            .font(.custom("HelveticaNeue-Medium", size: 13))
                                            .foregroundColor(tab == t ? .tsAccent : .tsSecondary)
                                            .padding(.vertical, 8).padding(.horizontal, 14)
                                            .background(tab == t ? Color(UIColor.systemBackground) : Color.clear)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(3)
                            .background(Color.tsInputBg)
                            .cornerRadius(11)
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 20)

                        Group {
                            switch tab {
                            case .banking:    BankingSection(openURL: openURL)
                            case .visas:      VisasSection(openURL: openURL)
                            case .healthcare: HealthSection(openURL: openURL)
                            case .renting:    RentingSection(openURL: openURL)
                            case .consulate:  ConsulateSection(openURL: openURL)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 96)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Bureaucracy")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Banking

private struct BankingSection: View {
    let openURL: OpenURLAction
    @State private var expanded: String? = nil

    var body: some View {
        VStack(spacing: 12) {
            BureauInfoCard(icon: "exclamationmark.circle.fill", color: Color(hex: "#FF9500"),
                title: "The hard truth",
                bodyText: "Most traditional Mexican banks (BBVA, Santander, Banorte) require a Temporary Residency card or a CURP. Without one, your real options are digital accounts and international cards.")

            // Non-resident options
            BureauSectionLabel(title: "WITHOUT RESIDENCY")
            VStack(spacing: 0) {
                BankRow(icon: "creditcard.fill", color: Color(hex: "#1A1F71"),
                        name: "Wise (Recommended)",
                        tagline: "Multi-currency account, Mexican peso supported",
                        detail: "Open from your home country before arriving. Get a Wise debit card, hold MXN, USD, EUR in one account. Best exchange rates in the market. Works everywhere Mastercard is accepted in Mexico. No Mexican address needed.",
                        badge: "BEST OPTION",
                        url: "https://wise.com", isExpanded: expanded == "Wise", openURL: openURL) {
                    withAnimation(.easeInOut(duration: 0.2)) { expanded = expanded == "Wise" ? nil : "Wise" }
                }
                Divider().padding(.leading, 56)
                BankRow(icon: "creditcard.fill", color: Color(hex: "#0075EB"),
                        name: "Revolut",
                        tagline: "Works in Mexico, good for travel spending",
                        detail: "Open before you arrive. No Mexico-specific account but the card works everywhere. Good for tracking spend. Currency exchange rates are competitive. Some features locked for non-EU/UK accounts.",
                        badge: nil,
                        url: "https://revolut.com", isExpanded: expanded == "Revolut", openURL: openURL) {
                    withAnimation(.easeInOut(duration: 0.2)) { expanded = expanded == "Revolut" ? nil : "Revolut" }
                }
                Divider().padding(.leading, 56)
                BankRow(icon: "bag.fill", color: Color(hex: "#E2231A"),
                        name: "Spin by OXXO",
                        tagline: "Mexican digital account — open with just a phone number",
                        detail: "The easiest way to get a Mexican peso account without residency. Open in the Spin app with a phone number and selfie. Load cash at any Oxxo. Debit card available. Limited features but great for local payments like Mercado Pago or OXXO bills.",
                        badge: "NO DOCS NEEDED",
                        url: "https://spin.com.mx", isExpanded: expanded == "Spin", openURL: openURL) {
                    withAnimation(.easeInOut(duration: 0.2)) { expanded = expanded == "Spin" ? nil : "Spin" }
                }
            }
            .background(Color.tsCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))

            // With residency
            BureauSectionLabel(title: "WITH TEMPORARY RESIDENCY")
            VStack(spacing: 0) {
                BankRow(icon: "building.columns.fill", color: Color(hex: "#004A97"),
                        name: "BBVA Mexico",
                        tagline: "Largest bank — widely accepted for residency holders",
                        detail: "With a Temporary Resident card you can open a Cuenta Débito. Bring: residency card, passport, CURP, RFC (if you have it), and proof of address (Airbnb confirmation or utility bill from landlord works sometimes). Process takes 1–3 days.",
                        badge: nil,
                        url: "https://bbva.mx", isExpanded: expanded == "BBVA", openURL: openURL) {
                    withAnimation(.easeInOut(duration: 0.2)) { expanded = expanded == "BBVA" ? nil : "BBVA" }
                }
                Divider().padding(.leading, 56)
                BankRow(icon: "building.columns.fill", color: Color(hex: "#EC0000"),
                        name: "Hey Banco (Banregio)",
                        tagline: "Most foreigner-friendly traditional bank",
                        detail: "Digital-first arm of Banregio. More flexible than BBVA with documentation. Can sometimes open with just residency card and passport. App is clean and modern. Recommended by the expat community as the easiest traditional bank path.",
                        badge: "EXPAT FAVOURITE",
                        url: "https://heybanco.com", isExpanded: expanded == "Hey", openURL: openURL) {
                    withAnimation(.easeInOut(duration: 0.2)) { expanded = expanded == "Hey" ? nil : "Hey" }
                }
            }
            .background(Color.tsCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))

            // RFC / CURP
            BureauSectionLabel(title: "RFC & CURP — FOR FREELANCERS")
            VStack(spacing: 0) {
                BureauTipRow(icon: "person.text.rectangle.fill", color: Color(hex: "#5856D6"),
                             title: "CURP — Personal ID number",
                             detail: "Free from gob.mx. Required for: bank accounts, SIM contracts, IMSS enrolment, rental agreements. Foreigners with temporary/permanent residency can get one. Process: online at renapo.gob.mx with your residency card.")
                Divider().padding(.leading, 50)
                BureauTipRow(icon: "doc.text.fill", color: Color(hex: "#FF9500"),
                             title: "RFC — Tax ID (freelancers/self-employed)",
                             detail: "Required to legally invoice clients in Mexico and pay Mexican taxes. Get one at any SAT office (Servicio de Administración Tributaria) or online at sat.gob.mx. Needs CURP + e.firma. Essential if you plan to rent formally, hire staff, or invoice Mexican companies.")
            }
            .background(Color.tsCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
    }
}

// MARK: - Visas

private struct VisasSection: View {
    let openURL: OpenURLAction
    @State private var expanded: String? = nil

    var body: some View {
        VStack(spacing: 12) {
            BureauInfoCard(icon: "checkmark.seal.fill", color: Color(hex: "#34C759"),
                title: "Good news for most nationalities",
                bodyText: "US, Canadian, EU, UK, Australian and most Western passport holders enter Mexico visa-free and receive up to 180 days. No pre-approval needed — just show up.")

            // Visa types
            BureauSectionLabel(title: "STAY TYPES")
            VStack(spacing: 0) {
                VisaCard(
                    title: "Tourist / FMM",
                    subtitle: "Up to 180 days — no visa needed",
                    color: Color(hex: "#34C759"),
                    icon: "airplane.arrival",
                    isExpanded: expanded == "FMM",
                    onTap: { withAnimation(.easeInOut(duration: 0.2)) { expanded = expanded == "FMM" ? nil : "FMM" } }
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        BureauDetailRow(icon: "checkmark.circle.fill", color: Color(hex: "#34C759"), text: "Valid for US, Canada, EU, UK, Australia, most of Latin America — no visa required")
                        BureauDetailRow(icon: "calendar", color: Color.tsAccent, text: "Maximum 180 days. The immigration officer decides how many days to grant — usually 180 but can be less.")
                        BureauDetailRow(icon: "exclamationmark.circle.fill", color: Color(hex: "#FF9500"), text: "You cannot work legally on a tourist entry. Remote work for foreign clients is a grey area most nomads operate in.")
                        BureauDetailRow(icon: "arrow.counterclockwise", color: Color(hex: "#5856D6"), text: "Renewal: leave Mexico and re-enter. Some people do 'visa runs' to Guatemala, Belize, or the US.")
                    }
                }
                Divider().padding(.leading, 50)
                VisaCard(
                    title: "Temporary Resident (Residente Temporal)",
                    subtitle: "1–4 years, renewable — most popular for nomads",
                    color: Color.tsAccent,
                    icon: "clock.fill",
                    isExpanded: expanded == "Temporal",
                    onTap: { withAnimation(.easeInOut(duration: 0.2)) { expanded = expanded == "Temporal" ? nil : "Temporal" } }
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        BureauDetailRow(icon: "dollarsign.circle.fill", color: Color(hex: "#34C759"), text: "Income requirement: ~$2,600 USD/month average over 12 months (bank statements) OR ~$43,000 USD in savings")
                        BureauDetailRow(icon: "building.2.fill", color: Color.tsAccent, text: "Step 1: Apply at a Mexican consulate in your home country — not inside Mexico")
                        BureauDetailRow(icon: "airplane.arrival", color: Color(hex: "#34C759"), text: "Step 2: Arrive in Mexico with your consulate-issued entry visa within 6 months")
                        BureauDetailRow(icon: "person.badge.clock.fill", color: Color(hex: "#FF9500"), text: "Step 3: Visit INM (immigration) office within 30 days of arrival for biometrics and residency card")
                        BureauDetailRow(icon: "checkmark.seal.fill", color: Color(hex: "#5856D6"), text: "Allows: open bank accounts, CURP, IMSS enrolment, long-term rental contracts. Does not automatically allow local employment.")
                        BureauDetailRow(icon: "arrow.clockwise", color: Color.tsAccent, text: "Renewable. After 4 years can apply for Permanent Residency.")
                    }
                }
                Divider().padding(.leading, 50)
                VisaCard(
                    title: "Permanent Resident (Residente Permanente)",
                    subtitle: "Indefinite stay — full work rights",
                    color: Color(hex: "#AF52DE"),
                    icon: "house.fill",
                    isExpanded: expanded == "Permanent",
                    onTap: { withAnimation(.easeInOut(duration: 0.2)) { expanded = expanded == "Permanent" ? nil : "Permanent" } }
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        BureauDetailRow(icon: "checkmark.circle.fill", color: Color(hex: "#34C759"), text: "Eligibility: 4 years of Temporary Residency, OR retirement income ~$3,600/month, OR marriage to a Mexican national")
                        BureauDetailRow(icon: "briefcase.fill", color: Color(hex: "#AF52DE"), text: "Full work authorisation — can be employed by Mexican companies, freelance locally, run a business")
                        BureauDetailRow(icon: "dollarsign.circle.fill", color: Color(hex: "#34C759"), text: "No annual renewal — card renewed every 10 years")
                        BureauDetailRow(icon: "globe.americas.fill", color: Color.tsAccent, text: "Some Latin American nationalities (Argentine, Colombian, etc.) may qualify more easily via special agreements")
                    }
                }
            }
            .background(Color.tsCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))

            // Travel from Mexico
            BureauSectionLabel(title: "LEAVING MEXICO — VISA REQUIREMENTS")
            VStack(spacing: 0) {
                ForEach(travelDestinations, id: \.country) { dest in
                    TravelVisaRow(dest: dest)
                    if dest.country != travelDestinations.last?.country {
                        Divider().padding(.leading, 50)
                    }
                }
            }
            .background(Color.tsCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))

            Text("Visa requirements are for US/EU/Canadian passport holders and subject to change. Always verify before booking.")
                .font(.custom("HelveticaNeue", size: 12))
                .foregroundColor(.tsSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
    }

    struct TravelDestination {
        let country: String; let flag: String; let status: String
        let color: Color; let note: String
    }

    let travelDestinations: [TravelDestination] = [
        TravelDestination(country: "Colombia",    flag: "🇨🇴", status: "Visa-free",        color: Color(hex: "#34C759"), note: "90 days on arrival. Popular nomad destination. No pre-approval."),
        TravelDestination(country: "Argentina",   flag: "🇦🇷", status: "Visa-free",        color: Color(hex: "#34C759"), note: "90 days on arrival for US, EU, Canada. No visa needed."),
        TravelDestination(country: "Peru",        flag: "🇵🇪", status: "Visa-free",        color: Color(hex: "#34C759"), note: "90 days on arrival. No visa for most Western passports."),
        TravelDestination(country: "Brazil",      flag: "🇧🇷", status: "Visa-free",        color: Color(hex: "#34C759"), note: "90 days since 2023 for US, Canada, Australia. EU also visa-free."),
        TravelDestination(country: "Cuba",        flag: "🇨🇺", status: "Tourist card",     color: Color(hex: "#FF9500"), note: "Tourist card (~$25 USD) required, available at airport. US travellers: Treasury Dept rules apply — check current guidance."),
        TravelDestination(country: "Guatemala",   flag: "🇬🇹", status: "Visa-free",        color: Color(hex: "#34C759"), note: "90 days. Popular visa-run destination from CDMX. CA-4 agreement."),
        TravelDestination(country: "India",       flag: "🇮🇳", status: "e-Visa required",  color: Color(hex: "#FF9500"), note: "e-Visa online before travel (~$25). Takes 3–5 business days. Apply at indianvisaonline.gov.in."),
        TravelDestination(country: "Japan",       flag: "🇯🇵", status: "Visa-free",        color: Color(hex: "#34C759"), note: "90 days visa-free for US, EU, Canada, UK, Australia."),
        TravelDestination(country: "China",       flag: "🇨🇳", status: "Visa required",    color: Color(hex: "#FF3B30"), note: "Full visa required for most Western passports. Apply via Chinese consulate. Some 144h transit exemptions in select airports."),
        TravelDestination(country: "Russia",      flag: "🇷🇺", status: "Visa required",    color: Color(hex: "#FF3B30"), note: "Visa required for US/UK/EU. Situation complex due to current political climate — check travel advisories."),
    ]
}

private struct TravelVisaRow: View {
    let dest: VisasSection.TravelDestination
    @State private var expanded = false
    var body: some View {
        VStack(spacing: 0) {
            Button { withAnimation(.easeInOut(duration: 0.18)) { expanded.toggle() } } label: {
                HStack(spacing: 12) {
                    Text(dest.flag).font(.system(size: 26)).frame(width: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dest.country).font(.custom("HelveticaNeue-Bold", size: 15)).foregroundColor(.tsLabel)
                        Text(dest.status).font(.custom("HelveticaNeue-Medium", size: 12)).foregroundColor(dest.color)
                    }
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 6).fill(dest.color.opacity(0.12)).frame(height: 22)
                        Text(dest.status).font(.custom("HelveticaNeue-Medium", size: 11)).foregroundColor(dest.color).padding(.horizontal, 8)
                    }
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .medium)).foregroundColor(.tsSecondary.opacity(0.4))
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
            }.buttonStyle(PlainButtonStyle())
            if expanded {
                VStack {
                    Divider().background(Color.tsAccent.opacity(0.08))
                    Text(dest.note).font(.custom("HelveticaNeue", size: 13)).foregroundColor(.tsSecondary)
                        .fixedSize(horizontal: false, vertical: true).padding(14)
                }
            }
        }
    }
}

// MARK: - Healthcare

private struct HealthSection: View {
    let openURL: OpenURLAction
    var body: some View {
        VStack(spacing: 12) {
            BureauInfoCard(icon: "cross.case.fill", color: Color(hex: "#FF3B30"),
                title: "Healthcare in Mexico is genuinely affordable",
                bodyText: "Private care is high quality and a fraction of US prices. Public care exists but wait times are long. Most nomads use a mix of Farmacia Similares for minor issues and private hospitals for anything serious.")

            BureauSectionLabel(title: "YOUR OPTIONS")
            VStack(spacing: 0) {
                BureauTipRow(icon: "storefront.fill", color: Color(hex: "#E2231A"),
                             title: "Farmacia del Ahorro / Similares",
                             detail: "Walk-in doctor consultation inside any pharmacy — $50–80 MXN (~$3–4 USD). No appointment. Great for: infections, UTIs, colds, prescriptions, basic diagnoses. Prescription medicines often dispensed immediately on-site.")
                Divider().padding(.leading, 50)
                BureauTipRow(icon: "building.2.fill", color: Color(hex: "#0099FF"),
                             title: "Private hospitals (best quality)",
                             detail: "Hospital ABC (Santa Fe), Hospital Médica Sur, Hospital Ángeles — all excellent. English-speaking staff available. A basic consult runs $600–1,200 MXN ($30–60 USD). Emergency care, surgery, labs all available and far cheaper than US.")
                Divider().padding(.leading, 50)
                BureauTipRow(icon: "person.badge.shield.checkmark.fill", color: Color(hex: "#34C759"),
                             title: "Voluntary IMSS enrolment",
                             detail: "IMSS is Mexico's public healthcare system for employees. Freelancers and temporary residents can enrol voluntarily for ~$60–100 USD/month. Covers consultations, hospital stays, medications, and maternity. Wait times can be long but the coverage is real.")
                Divider().padding(.leading, 50)
                BureauTipRow(icon: "cross.fill", color: Color(hex: "#AF52DE"),
                             title: "IMSS Bienestar (public emergency care)",
                             detail: "Mexico's constitution guarantees emergency care to anyone regardless of residency or insurance status. In practice, public hospitals will treat emergencies. Quality and wait times vary widely. Not a substitute for insurance but useful to know.")
            }
            .background(Color.tsCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))

            BureauSectionLabel(title: "USEFUL NUMBERS")
            VStack(spacing: 0) {
                BureauTipRow(icon: "phone.fill", color: Color(hex: "#FF3B30"), title: "Emergency (ambulance, police, fire)", detail: "📞 911 — works nationwide, available in Spanish and some English support")
                Divider().padding(.leading, 50)
                BureauTipRow(icon: "cross.case.fill", color: Color(hex: "#0099FF"), title: "Hospital ABC (CDMX)", detail: "📞 (55) 5230-8000 — Sur: (55) 5424-7200. English spoken. Private, excellent care.")
                Divider().padding(.leading, 50)
                BureauTipRow(icon: "pills.fill", color: Color(hex: "#34C759"), title: "Farmacia del Ahorro 24h line", detail: "📞 800-013-5000. Locate nearest pharmacy, check medicine availability.")
            }
            .background(Color.tsCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
    }
}

// MARK: - Renting

private struct RentingSection: View {
    let openURL: OpenURLAction
    var body: some View {
        VStack(spacing: 12) {
            BureauInfoCard(icon: "exclamationmark.triangle.fill", color: Color(hex: "#FF9500"),
                title: "The fiador system — biggest surprise for foreigners",
                bodyText: "Most Mexican landlords require a 'fiador' — a Mexican co-signer who owns property in Mexico and can be held liable if you don't pay. If you don't know anyone in Mexico, this is a real obstacle. Here's how to get around it.")

            BureauSectionLabel(title: "GETTING AN APARTMENT")
            VStack(spacing: 0) {
                BureauTipRow(icon: "person.fill.checkmark", color: Color(hex: "#34C759"),
                             title: "Homie.mx — no fiador required",
                             detail: "Platform designed for exactly this problem. No fiador. Pay a deposit instead. Listed apartments are pre-vetted. Great for CDMX, GDL, MTY. Most listings are furnished or semi-furnished.")
                Divider().padding(.leading, 50)
                BureauTipRow(icon: "shield.fill", color: Color.tsAccent,
                             title: "Aval Plus — paid fiador service",
                             detail: "A company that acts as your fiador for a fee (~$3,000 MXN / $150 USD first year). Accepted by most traditional landlords. Legitimate and widely used by expats. Google 'Aval Plus Mexico' to apply.")
                Divider().padding(.leading, 50)
                BureauTipRow(icon: "house.fill", color: Color(hex: "#FF9500"),
                             title: "3–6 months deposit",
                             detail: "Many landlords will accept extra deposit in lieu of a fiador. 2 months rent is standard; offering 3–4 upfront often closes the deal. Get everything in writing.")
                Divider().padding(.leading, 50)
                BureauTipRow(icon: "calendar", color: Color(hex: "#AF52DE"),
                             title: "Airbnb / Furnished long-term",
                             detail: "30+ day Airbnb stays are common in CDMX and significantly cheaper per night than short stays. No fiador needed, no contract complexity. Good bridge while you find a permanent place.")
            }
            .background(Color.tsCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))

            BureauSectionLabel(title: "TYPICAL COSTS — CDMX")
            VStack(spacing: 0) {
                RentRow(type: "Studio / 1BR — Roma Norte, Condesa",   range: "$800–1,400 USD/mo")
                Divider().padding(.leading, 16)
                RentRow(type: "1BR — Juárez, Narvarte",               range: "$600–1,000 USD/mo")
                Divider().padding(.leading, 16)
                RentRow(type: "1BR — Polanco",                        range: "$1,200–2,200 USD/mo")
                Divider().padding(.leading, 16)
                RentRow(type: "2BR — Roma / Condesa",                 range: "$1,400–2,400 USD/mo")
                Divider().padding(.leading, 16)
                RentRow(type: "Furnished short-term (30+ days)",      range: "$1,200–2,000 USD/mo")
            }
            .background(Color.tsCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))

            Text("Prices in USD. MXN contracts are common — factor in exchange rate fluctuation.")
                .font(.custom("HelveticaNeue", size: 12)).foregroundColor(.tsSecondary)
                .multilineTextAlignment(.center).padding(.horizontal, 8)
        }
    }
}

private struct RentRow: View {
    let type: String; let range: String
    var body: some View {
        HStack {
            Text(type).font(.custom("HelveticaNeue", size: 14)).foregroundColor(.tsLabel)
            Spacer()
            Text(range).font(.custom("HelveticaNeue-Bold", size: 13)).foregroundColor(.tsAccent)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }
}

// MARK: - Consulate

private struct ConsulateSection: View {
    let openURL: OpenURLAction

    struct Embassy: Identifiable {
        let id = UUID()
        let country: String; let flag: String; let phone: String
        let address: String; let hours: String; let website: String
        let emergency: String; let canHelp: [String]
    }

    let embassies: [Embassy] = [
        Embassy(country: "United States", flag: "🇺🇸",
                phone: "(55) 5080-2000",
                address: "Paseo de la Reforma 305, Cuauhtémoc, CDMX",
                hours: "Mon–Fri 8AM–5PM. Emergencies 24/7.",
                website: "https://mx.usembassy.gov",
                emergency: "(55) 5080-2000",
                canHelp: ["Lost/stolen passport replacement", "Emergency repatriation", "Notarial services", "Arrest/detention assistance", "Death of a US citizen abroad"]),
        Embassy(country: "Canada", flag: "🇨🇦",
                phone: "(55) 5724-7900",
                address: "Schiller 529, Polanco, CDMX",
                hours: "Mon–Fri 8AM–12PM (public). Emergencies 24/7.",
                website: "https://www.canadainternational.gc.ca/mexico-mexique",
                emergency: "1-613-996-8885 (collect calls accepted)",
                canHelp: ["Emergency passport", "Arrest assistance", "Medical emergency support", "Financial distress assistance"]),
        Embassy(country: "United Kingdom", flag: "🇬🇧",
                phone: "(55) 1670-3200",
                address: "Río Lerma 71, Cuauhtémoc, CDMX",
                hours: "Mon–Thu 8AM–4PM, Fri 8AM–1PM.",
                website: "https://www.gov.uk/world/organisations/british-embassy-mexico-city",
                emergency: "(55) 1670-3200",
                canHelp: ["Emergency travel document", "Arrest notification", "Hospital visits", "Help if you're a victim of crime"]),
        Embassy(country: "Australia", flag: "🇦🇺",
                phone: "(55) 1101-2200",
                address: "Rubén Darío 55, Polanco, CDMX",
                hours: "Mon–Fri 9AM–1PM.",
                website: "https://mexico.embassy.gov.au",
                emergency: "+61 2 6261 3305 (24h from Australia)",
                canHelp: ["Emergency passport", "Welfare checks", "Arrest assistance"]),
    ]

    @State private var expanded: String? = nil

    var body: some View {
        VStack(spacing: 12) {
            BureauInfoCard(icon: "building.columns.fill", color: Color(hex: "#5856D6"),
                title: "When to contact your consulate",
                bodyText: "Lost passport, arrest, hospitalisation, or death of a fellow citizen abroad. They can't get you out of legal trouble, pay your bills, or intervene in civil disputes — but they can ensure you're treated fairly and help you get home.")

            BureauSectionLabel(title: "EMBASSIES IN CDMX")
            VStack(spacing: 0) {
                ForEach(embassies) { emb in
                    EmbassyCard(emb: emb, isExpanded: expanded == emb.country, openURL: openURL) {
                        withAnimation(.easeInOut(duration: 0.2)) { expanded = expanded == emb.country ? nil : emb.country }
                    }
                    if emb.country != embassies.last?.country {
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .background(Color.tsCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))

            BureauInfoCard(icon: "globe", color: Color.tsAccent,
                title: "Not from the US, Canada, UK or Australia?",
                bodyText: "Search 'your country + embassy Mexico City' for contact details. Most countries maintain an embassy in Polanco or Lomas de Chapultepec. The Mexican government's SRE directory lists all accredited embassies at sre.gob.mx.")
        }
    }
}

private struct EmbassyCard: View {
    let emb: ConsulateSection.Embassy
    let isExpanded: Bool
    let openURL: OpenURLAction
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    Text(emb.flag).font(.system(size: 28)).frame(width: 40)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(emb.country).font(.custom("HelveticaNeue-Bold", size: 16)).foregroundColor(.tsLabel)
                        Text(emb.phone).font(.custom("HelveticaNeue-Medium", size: 13)).foregroundColor(.tsAccent)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium)).foregroundColor(.tsSecondary.opacity(0.5))
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
            }.buttonStyle(PlainButtonStyle())

            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Divider().background(Color.tsAccent.opacity(0.08))
                    VStack(alignment: .leading, spacing: 6) {
                        BureauDetailRow(icon: "mappin.circle.fill", color: Color(hex: "#FF3B30"), text: emb.address)
                        BureauDetailRow(icon: "clock.fill", color: Color(hex: "#FF9500"), text: emb.hours)
                        BureauDetailRow(icon: "phone.fill.arrow.down.left", color: Color(hex: "#FF3B30"), text: "Emergency: \(emb.emergency)")
                    }
                    .padding(.horizontal, 16)

                    Text("THEY CAN HELP WITH")
                        .font(.custom("HelveticaNeue-Bold", size: 11))
                        .foregroundColor(.tsSecondary).tracking(0.5)
                        .padding(.horizontal, 16)
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(emb.canHelp, id: \.self) { h in
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill").font(.system(size: 12))
                                    .foregroundColor(Color(hex: "#34C759"))
                                Text(h).font(.custom("HelveticaNeue", size: 13)).foregroundColor(.tsLabel)
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    Button {
                        if let url = URL(string: emb.website) { openURL(url) }
                    } label: {
                        Text("Visit Embassy Website")
                            .font(.custom("HelveticaNeue-Medium", size: 14)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 40)
                            .background(Color.tsAccent).cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle()).padding(.horizontal, 16).padding(.bottom, 14)
                }
            }
        }
    }
}

// MARK: - Shared helpers

private struct BureauInfoCard: View {
    let icon: String; let color: Color; let title: String; let bodyText: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon).font(.system(size: 20)).foregroundColor(color)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.custom("HelveticaNeue-Bold", size: 14)).foregroundColor(.tsLabel)
                Text(bodyText).font(.custom("HelveticaNeue", size: 13)).foregroundColor(.tsSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14).background(Color.tsCard).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
    }
}

private struct BureauSectionLabel: View {
    let title: String
    var body: some View {
        Text(title).font(.custom("HelveticaNeue-Bold", size: 11))
            .foregroundColor(.tsSecondary).tracking(0.8)
            .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 4)
    }
}

private struct BureauTipRow: View {
    let icon: String; let color: Color; let title: String; let detail: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 13)).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.custom("HelveticaNeue-Bold", size: 14)).foregroundColor(.tsLabel)
                Text(detail).font(.custom("HelveticaNeue", size: 13)).foregroundColor(.tsSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
    }
}

private struct BureauDetailRow: View {
    let icon: String; let color: Color; let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon).font(.system(size: 12)).foregroundColor(color).padding(.top, 1)
            Text(text).font(.custom("HelveticaNeue", size: 13)).foregroundColor(.tsSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct BankRow: View {
    let icon: String; let color: Color; let name: String; let tagline: String
    let detail: String; let badge: String?; let url: String
    let isExpanded: Bool; let openURL: OpenURLAction; let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.12)).frame(width: 36, height: 36)
                        Image(systemName: icon).font(.system(size: 13)).foregroundColor(color)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(name).font(.custom("HelveticaNeue-Bold", size: 15)).foregroundColor(.tsLabel)
                            if let b = badge {
                                Text(b).font(.custom("HelveticaNeue-Bold", size: 9)).foregroundColor(Color(hex: "#34C759"))
                                    .padding(.horizontal, 5).padding(.vertical, 2)
                                    .background(Color(hex: "#34C759").opacity(0.12)).cornerRadius(4)
                            }
                        }
                        Text(tagline).font(.custom("HelveticaNeue", size: 12)).foregroundColor(.tsSecondary)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .medium)).foregroundColor(.tsSecondary.opacity(0.4))
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
            }.buttonStyle(PlainButtonStyle())
            if isExpanded {
                VStack(spacing: 10) {
                    Divider().background(Color.tsAccent.opacity(0.08))
                    Text(detail).font(.custom("HelveticaNeue", size: 13)).foregroundColor(.tsSecondary)
                        .fixedSize(horizontal: false, vertical: true).padding(.horizontal, 14)
                    Button {
                        if let u = URL(string: url) { openURL(u) }
                    } label: {
                        Text("Open \(name)").font(.custom("HelveticaNeue-Medium", size: 13)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 36)
                            .background(color).cornerRadius(9)
                    }.buttonStyle(PlainButtonStyle()).padding(.horizontal, 14).padding(.bottom, 12)
                }
            }
        }
    }
}

private struct VisaCard<Content: View>: View {
    let title: String; let subtitle: String; let color: Color; let icon: String
    let isExpanded: Bool; let onTap: () -> Void
    @ViewBuilder let expandedContent: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.12)).frame(width: 36, height: 36)
                        Image(systemName: icon).font(.system(size: 13)).foregroundColor(color)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title).font(.custom("HelveticaNeue-Bold", size: 14)).foregroundColor(.tsLabel)
                        Text(subtitle).font(.custom("HelveticaNeue", size: 12)).foregroundColor(.tsSecondary)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .medium)).foregroundColor(.tsSecondary.opacity(0.4))
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
            }.buttonStyle(PlainButtonStyle())
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider().background(Color.tsAccent.opacity(0.08))
                    expandedContent().padding(.horizontal, 14).padding(.vertical, 10)
                }
            }
        }
    }
}
