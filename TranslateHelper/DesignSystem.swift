//
//  DesignSystem.swift
//  TranslateHelper
//

import SwiftUI

// MARK: - Colours
extension Color {
    static let tsBackground  = Color(hex: "#000000")
    static let tsCard        = Color(hex: "#1C1C1E")
    static let tsBorder      = Color.white.opacity(0.08)
    static let tsAccent      = Color(hex: "#007AFF")
    static let tsAccentTeal  = Color(hex: "#00C7BE")
    static let tsSecondary   = Color(hex: "#8E8E93")

    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        self.init(
            red:   Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >>  8) & 0xFF) / 255,
            blue:  Double( rgb        & 0xFF) / 255
        )
    }
}

// MARK: - Gradient
extension LinearGradient {
    static let tsVibrant = LinearGradient(
        colors: [.tsAccent, .tsAccentTeal],
        startPoint: .leading, endPoint: .trailing
    )
}

// MARK: - Shared Components


// MARK: - Logo Components
//
// Two variants:
//   TSLogoIcon   — the wifi/signal icon only (use in tab bars, small contexts)
//   TSWordmark   — icon + "TalkSwitch" text side by side (use in headers, auth screens)
//
// Asset names: "TalkSwitchLogo" (icon only) in Assets.xcassets

struct TSLogoIcon: View {
    var size: CGFloat = 32
    var body: some View {
        Image("TalkSwitchLogo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

struct TSWordmark: View {
    var iconSize: CGFloat = 28
    var fontSize: CGFloat = 18

    var body: some View {
        HStack(spacing: 8) {
            TSLogoIcon(size: iconSize)
            Text("TalkSwitch")
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct TSTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(placeholder.lowercased().contains("email") ? .emailAddress : .default)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.tsCard)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tsBorder, lineWidth: 1))
        .cornerRadius(12)
    }
}

struct TSButton: View {
    let title: String
    var isLoading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(isLoading ? 0 : 1)
                if isLoading { ProgressView().tint(.white) }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.tsAccent)
            .cornerRadius(14)
        }
        .disabled(isLoading)
    }
}

struct TSDivider: View {
    var body: some View {
        HStack {
            Rectangle().frame(height: 1).foregroundColor(Color.tsBorder)
            Text("or").font(.caption).foregroundColor(.tsSecondary).padding(.horizontal, 8)
            Rectangle().frame(height: 1).foregroundColor(Color.tsBorder)
        }
    }
}

// Pill button with vibrant gradient + blue glow
struct TSGradientPill: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(LinearGradient.tsVibrant)
            .clipShape(Capsule())
            .shadow(color: Color.tsAccent.opacity(0.39), radius: 10, x: 0, y: 4)
        }
    }
}

// Circular progress ring
struct TSProgressRing: View {
    let progress: Double // 0.0 – 1.0
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 3)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.tsAccent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
    }
}
