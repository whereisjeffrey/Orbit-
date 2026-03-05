//  CurrencyView.swift

import SwiftUI

// MARK: - Supported pairs
private let otherCurrencies: [(code: String, flag: String, name: String)] = [
    ("EUR", "🇪🇺", "Euro"),
    ("GBP", "🇬🇧", "British Pound"),
    ("CAD", "🇨🇦", "Canadian Dollar"),
    ("ARS", "🇦🇷", "Argentine Peso"),
    ("BRL", "🇧🇷", "Brazilian Real"),
    ("COP", "🇨🇴", "Colombian Peso"),
]

private let quickAmounts: [Double] = [5, 10, 20, 50, 100]

// MARK: - Main View
struct CurrencyView: View {
    @StateObject private var store = CurrencyStore.shared
    @State private var usdText  = ""
    @State private var mxnText  = ""
    @State private var editingUSD = true
    @FocusState private var focusedField: Bool

    var mxnRate: Double { store.rates["MXN"] ?? 0 }

    var body: some View {
        ZStack { TSGradientBackground()
            ScrollView {
                VStack(spacing: 16) {

                    // ── Live Rate Hero ──────────────────────────────
                    LiveRateHero(rate: mxnRate, updatedLabel: store.updatedLabel, isLoading: store.isLoading)

                    // ── Calculator ──────────────────────────────────
                    CalculatorCard(
                        usdText:     $usdText,
                        mxnText:     $mxnText,
                        editingUSD:  $editingUSD,
                        rate:        mxnRate,
                        focusedField: $focusedField
                    )

                    // ── Quick chips ─────────────────────────────────
                    if mxnRate > 0 {
                        QuickConvertRow(rate: mxnRate) { amount in
                            usdText    = formatAmount(amount)
                            mxnText    = formatAmount(amount * mxnRate)
                            editingUSD = true
                        }
                    }

                    // ── Other currencies → MXN ──────────────────────
                    if !store.rates.isEmpty {
                        OtherRatesSection(store: store)
                    }

                    // ── ATM Tips ────────────────────────────────────
                    ATMTipsCard()

                    Spacer().frame(height: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .onTapGesture { focusedField = false }
        }
        .task { await store.fetchRates() }
    }

    private func formatAmount(_ v: Double) -> String {
        v == 0 ? "" : String(format: v.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.2f", v)
    }
}

// MARK: - Live Rate Hero
struct LiveRateHero: View {
    let rate: Double
    let updatedLabel: String
    let isLoading: Bool
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "#34C759"))
                        .frame(width: 8, height: 8)
                        .scaleEffect(pulse ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: 1).repeatForever(), value: pulse)
                    Text("LIVE")
                        .font(.custom("HelveticaNeue-Bold", size: 11))
                        .foregroundColor(Color(hex: "#34C759"))
                        .tracking(1.5)
                }
                Spacer()
                Text(updatedLabel)
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
            }
            .padding(.bottom, 20)

            // Big rate
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("🇺🇸")
                    .font(.system(size: 36))
                VStack(alignment: .leading, spacing: 2) {
                    Text("1 USD")
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.tsSecondary)
                    if isLoading {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.tsSecondary.opacity(0.15))
                            .frame(width: 140, height: 38)
                    } else {
                        Text(rate > 0 ? String(format: "%.4f", rate) : "—")
                            .font(.custom("HelveticaNeue-Bold", size: 42))
                            .foregroundColor(.tsLabel)
                    }
                }
                Spacer()
                Text("🇲🇽")
                    .font(.system(size: 36))
                Text("MXN")
                    .font(.custom("HelveticaNeue-Bold", size: 20))
                    .foregroundColor(.tsSecondary)
            }
            .padding(.bottom, 8)

            Text("Mexican Peso · mid-market rate")
                .font(.custom("HelveticaNeue", size: 12))
                .foregroundColor(.tsSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(Color.tsCard)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
        .onAppear { pulse = true }
    }
}

// MARK: - Calculator
struct CalculatorCard: View {
    @Binding var usdText:    String
    @Binding var mxnText:    String
    @Binding var editingUSD: Bool
    let rate: Double
    var focusedField: FocusState<Bool>.Binding

    var body: some View {
        VStack(spacing: 0) {
            // USD row
            CurrencyInputRow(
                flag: "🇺🇸", code: "USD", symbol: "$",
                text: $usdText,
                isEditing: editingUSD
            ) { newVal in
                editingUSD = true
                if let v = Double(newVal.replacingOccurrences(of: ",", with: "")) {
                    mxnText = rate > 0 ? formatAmt(v * rate) : ""
                } else { mxnText = "" }
            }

            // Swap divider
            ZStack {
                Divider().background(Color.tsAccent.opacity(0.08))
                Button(action: swapCurrencies) {
                    ZStack {
                        Circle().fill(Color.tsBackground).frame(width: 36, height: 36)
                        Circle().stroke(Color.tsAccent.opacity(0.15), lineWidth: 1).frame(width: 36, height: 36)
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.tsAccent)
                    }
                }
            }
            .frame(height: 36)

            // MXN row
            CurrencyInputRow(
                flag: "🇲🇽", code: "MXN", symbol: "$",
                text: $mxnText,
                isEditing: !editingUSD
            ) { newVal in
                editingUSD = false
                if let v = Double(newVal.replacingOccurrences(of: ",", with: "")) {
                    usdText = rate > 0 ? formatAmt(v / rate) : ""
                } else { usdText = "" }
            }
        }
        .background(Color.tsCard)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
    }

    private func swapCurrencies() {
        let tmp = usdText; usdText = mxnText; mxnText = tmp
        editingUSD.toggle()
    }

    private func formatAmt(_ v: Double) -> String {
        v == 0 ? "" : String(format: v.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.2f", v)
    }
}

struct CurrencyInputRow: View {
    let flag:     String
    let code:     String
    let symbol:   String
    @Binding var text: String
    let isEditing: Bool
    let onChange: (String) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(flag).font(.system(size: 28))
            VStack(alignment: .leading, spacing: 2) {
                Text(code)
                    .font(.custom("HelveticaNeue-Bold", size: 13))
                    .foregroundColor(.tsSecondary)
                TextField("0", text: $text)
                    .font(.custom("HelveticaNeue-Bold", size: 28))
                    .foregroundColor(.tsLabel)
                    .keyboardType(.decimalPad)
                    .tint(.tsAccent)
                    .onChange(of: text) { onChange(text) }
            }
            Spacer()
            Text(symbol)
                .font(.custom("HelveticaNeue-Light", size: 28))
                .foregroundColor(isEditing ? .tsAccent : .tsSecondary.opacity(0.4))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Quick Convert Row
struct QuickConvertRow: View {
    let rate: Double
    let onSelect: (Double) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("QUICK CONVERT")
                .font(.custom("HelveticaNeue-Bold", size: 11))
                .foregroundColor(.tsSecondary)
                .tracking(1.2)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickAmounts, id: \.self) { amount in
                        Button(action: { onSelect(amount) }) {
                            VStack(spacing: 3) {
                                Text("$\(Int(amount))")
                                    .font(.custom("HelveticaNeue-Bold", size: 15))
                                    .foregroundColor(.tsLabel)
                                Text(String(format: "%.0f", amount * rate))
                                    .font(.custom("HelveticaNeue", size: 12))
                                    .foregroundColor(.tsSecondary)
                            }
                            .frame(width: 72, height: 56)
                            .background(Color.tsCard)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Other Rates
struct OtherRatesSection: View {
    @ObservedObject var store: CurrencyStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("OTHER CURRENCIES → MXN")
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

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
        ("banknote.fill",        "#34C759", "Use Citibanamex ATMs",    "Lowest foreign card fees in CDMX"),
        ("xmark.circle.fill",    "#FF3B30", "Avoid airport exchange",  "Rates are 15–20% worse than mid-market"),
        ("dollarsign.circle",    "#0099FF", "Carry some cash",         "Markets, tacos and microbuses are cash only"),
        ("creditcard.fill",      "#AF52DE", "DCC = bad deal",          "Always pay in MXN, never your home currency"),
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
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
