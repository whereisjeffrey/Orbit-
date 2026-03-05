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
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 5) {
                        Text("🇺🇸")
                            .font(.system(size: 17))
                        Text("1 USD =")
                            .font(.custom("HelveticaNeue", size: 14))
                            .foregroundColor(.tsSecondary)
                    }
                    if isLoading || rate == 0 {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.tsSecondary.opacity(0.10))
                            .frame(width: 180, height: 34)
                    } else {
                        HStack(alignment: .firstTextBaseline, spacing: 7) {
                            Text(String(format: "%.4f", rate))
                                .font(.custom("HelveticaNeue-Bold", size: 32))
                                .foregroundColor(.tsLabel)
                            Text("🇲🇽 MXN")
                                .font(.custom("HelveticaNeue-Medium", size: 14))
                                .foregroundColor(.tsSecondary)
                        }
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

            // ── Calculator — white fields on grey tray ────────────────
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
                            .fill(Color(UIColor.systemGray6))
                            .frame(width: 36, height: 36)
                        Circle()
                            .stroke(Color.white, lineWidth: 2.5)
                            .frame(width: 36, height: 36)
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.tsAccent)
                    }
                }
            }
            .padding(12)
            .background(Color(UIColor.systemGray6))
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

    var body: some View {
        HStack(spacing: 12) {
            TextField("0", text: $text)
                .font(.custom("HelveticaNeue-Bold", size: 34))
                .foregroundColor(isActive ? .tsLabel : .tsSecondary.opacity(0.35))
                .keyboardType(.decimalPad)
                .tint(.tsAccent)
                .onChange(of: text) { _, v in onChange(v) }

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
        .background(colorScheme == .dark ? Color.black : Color.white)
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

// MARK: - ATM Tips
struct ATMTipsCard: View {
    let tips = [
        ("banknote.fill",     "#34C759", "Use Citibanamex ATMs",   "Lowest foreign card fees in CDMX"),
        ("xmark.circle.fill", "#FF3B30", "Avoid airport exchange", "Rates are 15–20% worse than mid-market"),
        ("dollarsign.circle", "#0099FF", "Carry some cash",        "Markets, tacos and microbuses are cash only"),
        ("creditcard.fill",   "#AF52DE", "DCC = bad deal",         "Always pay in MXN, never your home currency"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ATM & CASH TIPS")
                .font(.custom("HelveticaNeue-Bold", size: 11))
                .foregroundColor(.tsSecondary)
                .tracking(1.2)

            VStack(spacing: 0) {
                ForEach(Array(tips.enumerated()), id: \.offset) { i, tip in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: tip.1).opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: tip.0)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: tip.1))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(tip.2)
                                .font(.custom("HelveticaNeue-Bold", size: 14))
                                .foregroundColor(.tsLabel)
                            Text(tip.3)
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
