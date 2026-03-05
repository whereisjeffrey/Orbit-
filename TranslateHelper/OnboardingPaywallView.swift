//
//  OnboardingPaywallView.swift
//  TranslateHelper
//

import SwiftUI

struct OnboardingPaywallView: View {
    let onBack: () -> Void
    let onComplete: () -> Void

    @State private var cardNumber    = ""
    @State private var expiry        = ""
    @State private var cvv           = ""
    @State private var cardholderName = ""
    @FocusState private var focusedField: CardField?

    enum CardField { case number, expiry, cvv, name }

    var chargeDate: String {
        let d = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        let f = DateFormatter()
        f.dateFormat = "MMMM d, yyyy"
        return f.string(from: d)
    }

    var isFormComplete: Bool {
        cardNumber.filter(\.isNumber).count == 16 &&
        expiry.count == 5 &&
        cvv.count >= 3 &&
        !cardholderName.isEmpty
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.tsBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {

                    // ── Nav ───────────────────────────────────────────
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.custom("HelveticaNeue-Medium", size: 22))
                                .foregroundColor(.tsAccent)
                        }
                        .frame(width: 40, height: 40)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // ── Header ────────────────────────────────────────
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.custom("HelveticaNeue", size: 14))
                                .foregroundColor(.tsAccent)
                            Text("Secured Payment")
                                .font(.custom("HelveticaNeue-Medium", size: 13))
                                .foregroundColor(.tsAccent)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.tsAccent.opacity(0.12))
                        .clipShape(Capsule())

                        Text("Start your free trial")
                            .font(.custom("HelveticaNeue-Bold", size: 28))
                            .foregroundColor(.tsLabel)

                        // Charge summary card
                        VStack(spacing: 4) {
                            HStack {
                                Text("TalkSwitch Pro")
                                    .font(.custom("HelveticaNeue-Medium", size: 16))
                                    .foregroundColor(.tsLabel)
                                Spacer()
                                Text("$7.99/mo")
                                    .font(.custom("HelveticaNeue-Bold", size: 16))
                                    .foregroundColor(.tsAccent)
                            }
                            HStack {
                                Text("7-day free trial")
                                    .font(.custom("HelveticaNeue", size: 13))
                                    .foregroundColor(.tsSecondary)
                                Spacer()
                                Text("Free today")
                                    .font(.custom("HelveticaNeue-Medium", size: 13))
                                    .foregroundColor(Color(hex: "#34C759"))
                            }
                            Divider().background(Color.tsBorder).padding(.vertical, 8)
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("First charge")
                                        .font(.custom("HelveticaNeue", size: 12))
                                        .foregroundColor(.tsSecondary)
                                    Text(chargeDate)
                                        .font(.custom("HelveticaNeue-Medium", size: 14))
                                        .foregroundColor(.tsLabel)
                                }
                                Spacer()
                                Text("$7.99")
                                    .font(.custom("HelveticaNeue-Bold", size: 14))
                                    .foregroundColor(.tsLabel)
                            }
                        }
                        .padding(16)
                        .background(Color.tsCard)
                        .cornerRadius(16)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 24)

                    // ── Card form ─────────────────────────────────────
                    VStack(spacing: 12) {

                        // Card number
                        CardInputField(
                            label: "Card Number",
                            placeholder: "1234 5678 9012 3456",
                            text: $cardNumber,
                            isFocused: focusedField == .number,
                            keyboardType: .numberPad,
                            trailingIcon: "creditcard"
                        )
                        .focused($focusedField, equals: .number)
                        .onChange(of: cardNumber) { val in
                            cardNumber = formatCardNumber(val)
                        }

                        HStack(spacing: 12) {
                            // Expiry
                            CardInputField(
                                label: "Expiry",
                                placeholder: "MM/YY",
                                text: $expiry,
                                isFocused: focusedField == .expiry,
                                keyboardType: .numberPad
                            )
                            .focused($focusedField, equals: .expiry)
                            .onChange(of: expiry) { val in
                                expiry = formatExpiry(val)
                            }

                            // CVV
                            CardInputField(
                                label: "CVV",
                                placeholder: "123",
                                text: $cvv,
                                isFocused: focusedField == .cvv,
                                keyboardType: .numberPad,
                                isSecure: true
                            )
                            .focused($focusedField, equals: .cvv)
                            .onChange(of: cvv) { val in
                                if val.count > 4 { cvv = String(val.prefix(4)) }
                            }
                        }

                        // Cardholder name
                        CardInputField(
                            label: "Cardholder Name",
                            placeholder: "Full Name",
                            text: $cardholderName,
                            isFocused: focusedField == .name,
                            keyboardType: .default
                        )
                        .focused($focusedField, equals: .name)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 140)
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

                VStack(spacing: 12) {
                    Button(action: onComplete) {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                                .font(.custom("HelveticaNeue", size: 14))
                            Text("Start Free Trial")
                                .font(.custom("HelveticaNeue-Bold", size: 18))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            isFormComplete
                                ? AnyShapeStyle(LinearGradient(
                                    colors: [Color.tsAccent, Color(hex: "#004775")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing))
                                : AnyShapeStyle(Color.tsCard)
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.tsAccent.opacity(isFormComplete ? 0.3 : 0), radius: 16, x: 0, y: 4)
                    }
                    .disabled(!isFormComplete)
                    .animation(.easeInOut(duration: 0.2), value: isFormComplete)
                    .padding(.horizontal, 24)

                    Text("You won\'t be charged until \(chargeDate). Cancel anytime before then.")
                        .font(.custom("HelveticaNeue", size: 11))
                        .foregroundColor(.tsSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 128, height: 5)
                        .padding(.bottom, 8)
                }
                .background(Color.tsBackground)
            }
        }
        .onTapGesture { focusedField = nil }
    }

    // MARK: - Formatters
    func formatCardNumber(_ raw: String) -> String {
        let digits = raw.filter(\.isNumber).prefix(16)
        var result = ""
        for (i, ch) in digits.enumerated() {
            if i > 0 && i % 4 == 0 { result += " " }
            result.append(ch)
        }
        return result
    }

    func formatExpiry(_ raw: String) -> String {
        let digits = raw.filter(\.isNumber).prefix(4)
        if digits.count > 2 {
            return String(digits.prefix(2)) + "/" + String(digits.dropFirst(2))
        }
        return String(digits)
    }
}

// MARK: - Reusable card input field
struct CardInputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isFocused: Bool
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var trailingIcon: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.custom("HelveticaNeue-Medium", size: 12))
                .foregroundColor(.tsSecondary)

            HStack {
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                    }
                }
                .font(.custom("HelveticaNeue", size: 17))
                .foregroundColor(.tsLabel)

                if let icon = trailingIcon {
                    Image(systemName: icon)
                        .font(.custom("HelveticaNeue", size: 14))
                        .foregroundColor(.tsSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.tsInputBg)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color.tsAccent : Color.tsBorder, lineWidth: isFocused ? 1.5 : 0.5)
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)
        }
    }
}
