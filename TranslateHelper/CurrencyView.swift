//  CurrencyView.swift

import SwiftUI

// MARK: - Data
let otherCurrencies: [(code: String, flag: String, name: String)] = [
    ("GBP", "🇬🇧", "British Pound"),
    ("EUR", "🇪🇺", "Euro"),
    ("CAD", "🇨🇦", "Canadian Dollar"),
]
// Simulate a plausible 7-day sparkline ending at the live rate
func mockSparkline(around rate: Double) -> [Double] {
    guard rate > 0 else { return Array(repeating: 17.5, count: 28) }
    var pts: [Double] = []
    var cur = rate * 0.987
    for _ in 0..<28 {
        let trend = (rate - cur) * 0.045
        cur += trend + Double.random(in: -0.055...0.055)
        pts.append(cur)
    }
    pts[pts.count - 1] = rate
    return pts
}

// MARK: - Sparkline
struct SparklineView: View {
    let data:  [Double]
    let color: Color

    var minV:  Double { data.min() ?? 0 }
    var maxV:  Double { data.max() ?? 1 }
    var midV:  Double { (minV + maxV) / 2 }
    var range: Double { max(maxV - minV, 0.001) }

    var body: some View {
        ZStack(alignment: .trailing) {

            // Canvas — reference lines + fill + line + end dot
            Canvas { ctx, size in
                guard data.count > 1 else { return }
                let w   = size.width - 40   // right margin for y-axis labels
                let h   = size.height
                let pad = h * 0.12
                let ch  = h - 2 * pad

                func pt(_ i: Int) -> CGPoint {
                    CGPoint(
                        x: w * Double(i) / Double(data.count - 1),
                        y: pad + ch * (1.0 - (data[i] - minV) / range)
                    )
                }
                let pts = data.indices.map { pt($0) }

                // Dashed reference lines
                for frac in [0.12, 0.5, 0.88] as [Double] {
                    let y = pad + ch * frac
                    var p = Path()
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: w, y: y))
                    ctx.stroke(p,
                               with: .color(Color(hex: "#6D6D72").opacity(0.18)),
                               style: StrokeStyle(lineWidth: 0.5, dash: [4, 3]))
                }

                // Gradient fill under line
                var fill = Path()
                fill.move(to: CGPoint(x: pts[0].x, y: h))
                fill.addLine(to: pts[0])
                pts.dropFirst().forEach { fill.addLine(to: $0) }
                fill.addLine(to: CGPoint(x: pts.last!.x, y: h))
                fill.closeSubpath()
                ctx.fill(fill, with: .linearGradient(
                    Gradient(stops: [
                        .init(color: Color(hex: "#0099FF").opacity(0.14), location: 0),
                        .init(color: Color(hex: "#0099FF").opacity(0.00), location: 1),
                    ]),
                    startPoint: .zero,
                    endPoint: CGPoint(x: 0, y: h)
                ))

                // Line
                var line = Path()
                line.move(to: pts[0])
                pts.dropFirst().forEach { line.addLine(to: $0) }
                ctx.stroke(line,
                           with: .color(Color(hex: "#0099FF")),
                           style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                // End dot — blue ring, white centre
                if let last = pts.last {
                    var outer = Path()
                    outer.addEllipse(in: CGRect(x: last.x-5, y: last.y-5, width: 10, height: 10))
                    ctx.fill(outer, with: .color(Color(hex: "#0099FF")))
                    var inner = Path()
                    inner.addEllipse(in: CGRect(x: last.x-2.5, y: last.y-2.5, width: 5, height: 5))
                    ctx.fill(inner, with: .color(.white))
                }
            }

            // Y-axis value labels
            VStack(alignment: .trailing) {
                Text(String(format: "%.2f", maxV))
                    .font(.custom("HelveticaNeue", size: 10))
                    .foregroundColor(.tsSecondary)
                Spacer()
                Text(String(format: "%.2f", midV))
                    .font(.custom("HelveticaNeue", size: 10))
                    .foregroundColor(.tsSecondary)
                Spacer()
                Text(String(format: "%.2f", minV))
                    .font(.custom("HelveticaNeue", size: 10))
                    .foregroundColor(.tsSecondary)
            }
            .frame(width: 38)
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Rate Hero Card (chart + calculator unified)
struct RateHeroCard: View {
    @Binding var usdText:    String
    @Binding var mxnText:    String
    @Binding var editingUSD: Bool
    let rate:         Double
    let updatedLabel: String
    let isLoading:    Bool

    @State private var sparkData: [Double] = []
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 0) {

            // ── Rate header ───────────────────────────────────────────
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Text("🇺🇸")
                            .font(.system(size: 15))
                        Text("USD")
                            .font(.custom("HelveticaNeue-Medium", size: 14))
                            .foregroundColor(.tsSecondary)
                        Text("=")
                            .font(.custom("HelveticaNeue", size: 14))
                            .foregroundColor(.tsSecondary)
                        Text("🇲🇽")
                            .font(.system(size: 15))
                        Text("MXN")
                            .font(.custom("HelveticaNeue-Medium", size: 14))
                            .foregroundColor(.tsSecondary)
                    }
                    if isLoading || rate == 0 {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.tsSecondary.opacity(0.10))
                            .frame(width: 150, height: 34)
                    } else {
                        Text(String(format: "%.4f", rate))
                            .font(.custom("HelveticaNeue-Bold", size: 32))
                            .foregroundColor(.tsLabel)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color(hex: "#34C759"))
                            .frame(width: 7, height: 7)
                            .scaleEffect(pulse ? 1.45 : 1.0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulse)
                        Text("LIVE")
                            .font(.custom("HelveticaNeue-Bold", size: 11))
                            .foregroundColor(Color(hex: "#34C759"))
                            .tracking(1.2)
                    }
                    Text(updatedLabel)
                        .font(.custom("HelveticaNeue", size: 11))
                        .foregroundColor(.tsSecondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 14)

            // ── Sparkline ─────────────────────────────────────────────
            if sparkData.isEmpty {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.tsSecondary.opacity(0.06))
                    .frame(height: 120)
                    .padding(.horizontal, 16)
            } else {
                SparklineView(data: sparkData, color: .tsAccent)
                    .frame(height: 120)
                    .padding(.horizontal, 16)
            }

            // X-axis
            HStack {
                Text("7 days ago")
                    .font(.custom("HelveticaNeue", size: 11))
                    .foregroundColor(.tsSecondary)
                Spacer()
                Text("Today")
                    .font(.custom("HelveticaNeue-Bold", size: 11))
                    .foregroundColor(.tsAccent)
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 16)

            // ── Separator ────────────────────────────────────────────
            Rectangle()
                .fill(Color.tsAccent.opacity(0.10))
                .frame(height: 1)
                .padding(.horizontal, 20)
                .padding(.bottom, 14)

            // ── Calculator — white fields on card-color tray ──────────
            ZStack(alignment: .center) {
                VStack(spacing: 8) {
                    WiseCurrencyRow(
                        flag: "🇺🇸", code: "USD",
                        text: $usdText, isActive: editingUSD
                    ) { val in
                        editingUSD = true
                        if let v = Double(val.replacingOccurrences(of: ",", with: "")) {
                            mxnText = rate > 0 ? String(format: "%.2f", v * rate) : ""
                        } else { mxnText = "" }
                    }

                    WiseCurrencyRow(
                        flag: "🇲🇽", code: "MXN",
                        text: $mxnText, isActive: !editingUSD
                    ) { val in
                        editingUSD = false
                        if let v = Double(val.replacingOccurrences(of: ",", with: "")) {
                            usdText = rate > 0 ? String(format: "%.2f", v / rate) : ""
                        } else { usdText = "" }
                    }
                }

                // Swap button floats in the gap
                Button {
                    let t = usdText; usdText = mxnText; mxnText = t
                    editingUSD.toggle()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 36, height: 36)
                            .overlay(Circle().stroke(Color.tsAccent.opacity(0.25), lineWidth: 1.5))
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.tsAccent)
                    }
                }
            }
            .padding(12)
            .background(Color.tsCard)
        }
        .background(Color.tsCard)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 2)
        .onAppear {
            pulse = true
            if rate > 0 { sparkData = mockSparkline(around: rate) }
        }
        .onChange(of: rate) { _, newRate in
            if newRate > 0 { sparkData = mockSparkline(around: newRate) }
        }
    }
}

// MARK: - Wise-style input row
struct WiseCurrencyRow: View {
    let flag:    String
    let code:    String
    @Binding var text: String
    let isActive: Bool
    let onChange: (String) -> Void
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            TextField("0", text: $text)
                .font(.custom("HelveticaNeue-Bold", size: 34))
                .foregroundColor(colorScheme == .dark ? .tsSecondary : (isActive ? .tsLabel : .tsSecondary.opacity(0.35)))
                .keyboardType(.decimalPad)
                .tint(.tsAccent)
                .focused($isFocused)
                .onChange(of: text) { _, v in
                    // Only convert when the user is actually typing here,
                    // not when we programmatically update the other field.
                    if isFocused { onChange(v) }
                }
            Spacer()
            HStack(spacing: 6) {
                Text(flag).font(.system(size: 22))
                Text(code)
                    .font(.custom("HelveticaNeue-Bold", size: 16))
                    .foregroundColor(.tsLabel)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(colorScheme == .dark ? Color.tsCard : Color.white)
        .cornerRadius(12)
    }
}


// MARK: - Other Rates
struct OtherRatesSection: View {
    @ObservedObject var store: CurrencyStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("GBP · EUR · CAD → MXN")
                .font(.custom("HelveticaNeue-Bold", size: 11))
                .foregroundColor(.tsSecondary)
                .tracking(1.2)

            VStack(spacing: 0) {
                ForEach(Array(otherCurrencies.enumerated()), id: \.offset) { i, pair in
                    if let fromRate = store.rates[pair.code],
                       let mxnRate  = store.rates["MXN"] {
                        let rate = mxnRate / fromRate
                        HStack {
                            Text(pair.flag).font(.system(size: 22))
                            VStack(alignment: .leading, spacing: 1) {
                                Text(pair.code)
                                    .font(.custom("HelveticaNeue-Bold", size: 14))
                                    .foregroundColor(.tsLabel)
                                Text(pair.name)
                                    .font(.custom("HelveticaNeue", size: 12))
                                    .foregroundColor(.tsSecondary)
                            }
                            Spacer()
                            Text(String(format: "%.2f", rate))
                                .font(.custom("HelveticaNeue-Bold", size: 16))
                                .foregroundColor(.tsLabel)
                            Text("MXN")
                                .font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(.tsSecondary)
                                .padding(.leading, 2)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)

                        if i < otherCurrencies.count - 1 {
                            Divider().background(Color.tsAccent.opacity(0.06)).padding(.leading, 54)
                        }
                    }
                }
            }
            .background(Color.tsCard)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
    }
}

// MARK: - ATM Tips (location-aware)
struct ATMTipsCard: View {

    // Mirrors UserLearningLocation — only what we need
    private struct SavedLocation: Codable {
        var id: UUID
        var displayName: String
        var city: String
        var country: String
    }

    typealias Tip = (icon: String, color: String, title: String, detail: String)

    private var primaryLocation: SavedLocation? {
        guard let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper"),
              let data    = defaults.data(forKey: "talkswitch_learning_locations"),
              let locs    = try? JSONDecoder().decode([SavedLocation].self, from: data),
              !locs.isEmpty else { return nil }
        return locs[0]
    }

    private var cityLabel: String { primaryLocation?.city ?? "Worldwide" }

    private var tips: [Tip] {
        let country = primaryLocation?.country.lowercased() ?? ""
        let city    = primaryLocation?.city.lowercased() ?? ""

        switch true {
        case country.contains("mexico"):                          return mexicoTips(city: city)
        case country.contains("colombia"):                        return colombiaTips()
        case country.contains("argentina"):                       return argentinaTips()
        case country.contains("portugal"):                        return portugalTips()
        case country.contains("spain") || country.contains("españa"): return spainTips()
        case country.contains("indonesia") || city.contains("bali"):  return baliTips()
        case country.contains("thailand"):                        return thailandTips()
        default:                                                  return genericTips()
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ATM & CASH TIPS — \(cityLabel.uppercased())")
                .font(.custom("HelveticaNeue-Bold", size: 11))
                .foregroundColor(.tsSecondary)
                .tracking(1.2)

            VStack(spacing: 0) {
                ForEach(Array(tips.enumerated()), id: \.offset) { i, tip in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: tip.color).opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: tip.icon)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: tip.color))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(tip.title)
                                .font(.custom("HelveticaNeue-Bold", size: 14))
                                .foregroundColor(.tsLabel)
                            Text(tip.detail)
                                .font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(.tsSecondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    if i < tips.count - 1 {
                        Divider().background(Color.tsAccent.opacity(0.06)).padding(.leading, 64)
                    }
                }
            }
            .background(Color.tsCard)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
    }

    // MARK: - Tip sets per region

    private func mexicoTips(city: String) -> [Tip] {
        let atm  = city.contains("guadalajara") ? "Banamex or HSBC"
                 : city.contains("monterrey")   ? "Banorte or HSBC"
                 : city.contains("oaxaca")       ? "Banamex or Bancomer"
                 :                                 "Citibanamex or HSBC"
        let note = city.contains("guadalajara") ? "Best foreign-card ATMs in GDL centro"
                 : city.contains("monterrey")   ? "Lowest surcharges in MTY"
                 : city.contains("oaxaca")       ? "Most reliable for foreign cards in Oaxaca"
                 :                                 "Lowest foreign card fees in CDMX"
        return [
            (icon: "banknote.fill",     color: "#34C759", title: "Use \(atm) ATMs",      detail: note),
            (icon: "xmark.circle.fill", color: "#FF3B30", title: "Avoid airport exchange", detail: "Rates are 15–20% worse than mid-market"),
            (icon: "dollarsign.circle", color: "#0099FF", title: "Carry cash",             detail: "Markets, tacos and microbuses are cash only"),
            (icon: "creditcard.fill",   color: "#AF52DE", title: "Always pay in MXN",      detail: "Decline DCC — never pay in your home currency"),
        ]
    }

    private func colombiaTips() -> [Tip] {[
        (icon: "banknote.fill",        color: "#34C759", title: "Use Bancolombia ATMs",    detail: "Widest network and best rates for foreign cards"),
        (icon: "arrow.up.circle.fill", color: "#0099FF", title: "Withdraw larger amounts", detail: "Fees run $3–5 USD per transaction — minimise trips"),
        (icon: "exclamationmark.circle.fill", color: "#FF9500", title: "Low ATM limits",   detail: "Max ~500K–1M COP per withdrawal — plan ahead"),
        (icon: "creditcard.fill",      color: "#AF52DE", title: "Always pay in COP",       detail: "Decline any USD pricing — insist on local currency"),
    ]}

    private func argentinaTips() -> [Tip] {[
        (icon: "chart.line.uptrend.xyaxis", color: "#34C759", title: "Dual-rate reality",        detail: "Official vs blue dollar can differ 2–3× — research before you go"),
        (icon: "building.columns.fill",     color: "#0099FF", title: "Licensed casa de cambio",  detail: "Exchange houses legally offer far better rates than ATMs"),
        (icon: "banknote.fill",             color: "#FF9500", title: "ATM fees are steep",       detail: "Expect 500–1500 ARS in fees — use Brubank to cut costs"),
        (icon: "dollarsign.circle",         color: "#AF52DE", title: "USD cash is useful",       detail: "Widely accepted informally at favourable rates"),
    ]}

    private func portugalTips() -> [Tip] {[
        (icon: "banknote.fill",     color: "#34C759", title: "Use Multibanco ATMs",   detail: "Portugal's national network — fairest rates and fees"),
        (icon: "xmark.circle.fill", color: "#FF3B30", title: "Avoid Euronet ATMs",    detail: "Private network with inflated fees — recognisable by orange branding"),
        (icon: "creditcard",        color: "#0099FF", title: "Cards accepted widely", detail: "Visa and Mastercard work almost universally in Portugal"),
        (icon: "creditcard.fill",   color: "#AF52DE", title: "Decline DCC",           detail: "Always pay in euros — not your home currency"),
    ]}

    private func spainTips() -> [Tip] {[
        (icon: "banknote.fill",     color: "#34C759", title: "CaixaBank or Santander", detail: "Widest ATM network in Spain with fair foreign-card rates"),
        (icon: "xmark.circle.fill", color: "#FF3B30", title: "Avoid Euronet ATMs",     detail: "Common near tourist areas — fees and rates are punishing"),
        (icon: "creditcard",        color: "#0099FF", title: "Tap-to-pay everywhere",  detail: "Contactless is the norm in Spanish cities — cards are king"),
        (icon: "creditcard.fill",   color: "#AF52DE", title: "Decline DCC always",     detail: "Pay in euros — reject any offer to charge your home currency"),
    ]}

    private func baliTips() -> [Tip] {[
        (icon: "banknote.fill",        color: "#34C759", title: "Use BRI or BCA ATMs",      detail: "Most reliable ATMs for foreign cards across Bali"),
        (icon: "building.columns.fill",color: "#0099FF", title: "Licensed money changers",  detail: "Authorised changers on main roads beat ATM rates"),
        (icon: "xmark.circle.fill",    color: "#FF3B30", title: "Avoid tourist strip FX",   detail: "Kuta and Legian changers offer poor unofficial rates"),
        (icon: "arrow.down.circle",    color: "#FF9500", title: "Low withdrawal limits",    detail: "Typical max is 1.5–2.5M IDR — factor in multiple trips"),
    ]}

    private func thailandTips() -> [Tip] {[
        (icon: "dollarsign.circle",    color: "#FF3B30", title: "220 THB fee per ATM use",  detail: "Every Thai ATM charges ~$6 for foreign cards — minimise use"),
        (icon: "arrow.up.circle.fill", color: "#0099FF", title: "Withdraw the max",         detail: "30,000 THB limit per transaction — make each one count"),
        (icon: "creditcard",           color: "#34C759", title: "Use Wise for card spend",  detail: "Skip ATMs entirely where cards are accepted"),
        (icon: "building.columns.fill",color: "#FF9500", title: "Airport exchange is fine", detail: "Surprisingly fair rates at BKK and Suvarnabhumi airports"),
    ]}

    private func genericTips() -> [Tip] {[
        (icon: "banknote.fill",     color: "#34C759", title: "Use partner bank ATMs",  detail: "Check your home bank's global ATM network to skip fees"),
        (icon: "xmark.circle.fill", color: "#FF3B30", title: "Skip airport exchanges", detail: "Rates are always 15–20% worse than mid-market"),
        (icon: "creditcard.fill",   color: "#AF52DE", title: "Decline DCC always",     detail: "Always pay in local currency — never your home one"),
        (icon: "dollarsign.circle", color: "#0099FF", title: "Carry some cash",        detail: "Markets and small vendors rarely take cards"),
    ]}
}


// MARK: - Free ATM Banks
struct FreeATMSection: View {
    @Environment(\.openURL) private var openURL
    struct ATMBank {
        let name: String
        let tagline: String
        let detail: String
        let logoAsset: String
        let initial: String
        let color: String
        let url: String
    }

    let banks: [ATMBank] = [
        ATMBank(
            name:    "Charles Schwab",
            tagline: "Reimburses every ATM fee globally",
            detail:  "No cap. No monthly fee. Best card for nomads.",
            logoAsset: "logo-schwab",
            initial: "S", color: "#00A0DC",
            url:     "https://www.schwab.com/checking"
        ),
        ATMBank(
            name:    "Fidelity Cash Management",
            tagline: "Unlimited ATM fee reimbursements",
            detail:  "All domestic + international ATM fees refunded.",
            logoAsset: "logo-fidelity",
            initial: "F", color: "#317D2E",
            url:     "https://www.fidelity.com/cash-management/fidelity-cash-management-account/overview"
        ),
        ATMBank(
            name:    "Revolut",
            tagline: "Free ATM up to $400/month",
            detail:  "Great app, real exchange rate, easy sign-up.",
            logoAsset: "logo-revolut",
            initial: "R", color: "#0075EB",
            url:     "https://www.revolut.com"
        ),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("FREE ATM WORLDWIDE")
                .font(.custom("HelveticaNeue-Bold", size: 11))
                .foregroundColor(.tsSecondary)
                .tracking(1.2)

            VStack(spacing: 0) {
                ForEach(Array(banks.enumerated()), id: \.offset) { i, bank in
                    Button { if let url = URL(string: bank.url) { openURL(url) } } label: {
                        HStack(spacing: 12) {
                            Image(bank.logoAsset)
                                .resizable()
                                .scaledToFit()
                                .padding(4)
                                .frame(width: 40, height: 40)
                                .background(Color(hex: bank.color).opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(bank.name)
                                    .font(.custom("HelveticaNeue-Bold", size: 14))
                                    .foregroundColor(.tsLabel)
                                Text(bank.tagline)
                                    .font(.custom("HelveticaNeue", size: 12))
                                    .foregroundColor(.tsSecondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.tsAccent)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    if i < banks.count - 1 {
                        Divider().background(Color.tsAccent.opacity(0.06)).padding(.leading, 68)
                    }
                }
            }
            .background(Color.tsCard)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
    }
}

// MARK: - Best Travel Cards
struct TravelCardsSection: View {
    @Environment(\.openURL) private var openURL
    struct TravelCard {
        let name: String
        let issuer: String
        let annualFee: String
        let bonus: String
        let perk: String
        let logoAsset: String
        let initial: String
        let color: String
        let url: String
    }

    let cards: [TravelCard] = [
        TravelCard(
            name:      "Sapphire Preferred",
            issuer:    "Chase",
            annualFee: "$95/yr",
            bonus:     "60K pts sign-up (~$750)",
            perk:      "3x dining · no foreign fees",
            logoAsset: "logo-chase",
            initial:   "C", color: "#117ACA",
            url:       "https://creditcards.chase.com/rewards-credit-cards/sapphire/preferred"
        ),
        TravelCard(
            name:      "Venture Rewards",
            issuer:    "Capital One",
            annualFee: "$95/yr",
            bonus:     "75K miles sign-up (~$750)",
            perk:      "2x on everything · no foreign fees",
            logoAsset: "logo-capitalone",
            initial:   "C", color: "#D03027",
            url:       "https://www.capitalone.com/credit-cards/venture/"
        ),
        TravelCard(
            name:      "Double Cash",
            issuer:    "Citi",
            annualFee: "No annual fee",
            bonus:     "No sign-up bonus",
            perk:      "2% on everything · no foreign fees",
            logoAsset: "logo-citi",
            initial:   "C", color: "#003B70",
            url:       "https://www.citi.com/credit-cards/citi-double-cash-credit-card"
        ),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("BEST TRAVEL CARDS")
                .font(.custom("HelveticaNeue-Bold", size: 11))
                .foregroundColor(.tsSecondary)
                .tracking(1.2)

            VStack(spacing: 0) {
                ForEach(Array(cards.enumerated()), id: \.offset) { i, card in
                    Button { if let url = URL(string: card.url) { openURL(url) } } label: {
                        HStack(spacing: 12) {
                            Image(card.logoAsset)
                                .resizable()
                                .scaledToFit()
                                .padding(4)
                                .frame(width: 40, height: 40)
                                .background(Color(hex: card.color).opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(card.name)
                                        .font(.custom("HelveticaNeue-Bold", size: 14))
                                        .foregroundColor(.tsLabel)
                                    Text(card.annualFee)
                                        .font(.custom("HelveticaNeue", size: 11))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 7).padding(.vertical, 2)
                                        .background(card.annualFee == "No annual fee"
                                            ? Color(hex: "#34C759")
                                            : Color.tsSecondary.opacity(0.4))
                                        .clipShape(Capsule())
                                }
                                Text(card.bonus)
                                    .font(.custom("HelveticaNeue-Medium", size: 12))
                                    .foregroundColor(.tsAccent)
                                Text(card.perk)
                                    .font(.custom("HelveticaNeue", size: 12))
                                    .foregroundColor(.tsSecondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.tsAccent)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 14)
                    }
                    .buttonStyle(PlainButtonStyle())
                    if i < cards.count - 1 {
                        Divider().background(Color.tsAccent.opacity(0.06)).padding(.leading, 68)
                    }
                }
            }
            .background(Color.tsCard)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        }
    }
}

// MARK: - Main View
struct CurrencyView: View {
    @StateObject private var store = CurrencyStore.shared
    @State private var usdText    = ""
    @State private var mxnText    = ""
    @State private var editingUSD = true

    var mxnRate: Double { store.rates["MXN"] ?? 0 }

    var body: some View {
        ZStack { TSGradientBackground()
            ScrollView {
                VStack(spacing: 16) {

                    RateHeroCard(
                        usdText:      $usdText,
                        mxnText:      $mxnText,
                        editingUSD:   $editingUSD,
                        rate:         mxnRate,
                        updatedLabel: store.updatedLabel,
                        isLoading:    store.isLoading
                    )

                    if !store.rates.isEmpty {
                        OtherRatesSection(store: store)
                    }

                    ATMTipsCard()

                    FreeATMSection()

                    TravelCardsSection()

                    Spacer().frame(height: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .onTapGesture {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        }
        .task { await store.fetchRates() }
    }
}
