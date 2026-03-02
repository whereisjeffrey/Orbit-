//
//  DesignSystem.swift
//  TranslateHelper
//

import SwiftUI
import UIKit

// MARK: - Spacing Grid
//
// ALL spacing, padding, and sizing must use the 4pt base grid.
// Prefer multiples of 8 wherever possible.
//
//  4   8   12   16   20   24   32   40   48   56   64
//
// Rules:
//  - Never use odd numbers (1, 3, 5, 7...) for spacing
//  - Never use values like 15, 22, 35 — round to nearest grid unit
//  - When a % change is requested, calculate result then round to nearest 8
//  - Icon sizes: 16 / 20 / 24 / 32 / 40 / 44 / 48 / 56 / 64
//  - Corner radius: 8 / 12 / 14 / 16 / 24 (cards) / 9999 (pill)
//
// Examples:
//  padding(.horizontal, 24)   ✅
//  padding(.vertical, 16)     ✅
//  padding(.all, 13)          ❌ → use 12 or 16

extension UIColor {
    convenience init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        self.init(
            red:   CGFloat((rgb >> 16) & 0xFF) / 255.0,
            green: CGFloat((rgb >>  8) & 0xFF) / 255.0,
            blue:  CGFloat( rgb        & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}

// MARK: - Colours
extension Color {
    static let tsBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(hex: "#000000") : UIColor(hex: "#FFFFFF")
    })
    
    static let tsCard = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(hex: "#1C1C1E") : UIColor(hex: "#F2F2F7")
    })
    
    static let tsBorder = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor.white.withAlphaComponent(0.08) : UIColor(hex: "#C6C6C8")
    })
    
    static let tsAccent = Color(hex: "#007AFF")
    
    static let tsAccentTeal = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(hex: "#00C7BE") : UIColor(hex: "#5AC8FA")
    })
    
    static let tsSecondary = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(hex: "#8E8E93") : UIColor(hex: "#3C3C43").withAlphaComponent(0.6)
    })
    
    static let tsLabel = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(hex: "#FFFFFF") : UIColor(hex: "#000000")
    })
    
    static let tsInputBg = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(hex: "#787880").withAlphaComponent(0.12) : UIColor(hex: "#F2F2F7")
    })

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


// MARK: - Fonts
extension Font {
    /// Sono Regular — used for TalkSwitch wordmark / brand text
    static func sono(_ size: CGFloat) -> Font {
        .custom("Sono-Regular", size: size)
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
        HStack(spacing: 6) {
            TSLogoIcon(size: iconSize)
            Text("TalkSwitch")
                .font(.custom("Sono-Regular", size: fontSize))
                .kerning(fontSize * 0.01) // 1% letter spacing per Figma spec
                .foregroundColor(.tsLabel)
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
        .foregroundColor(.tsLabel)
        .padding()
        .background(Color.tsInputBg)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tsBorder, lineWidth: 1))
        .cornerRadius(12)
    }
}

struct TSButton: View {
    let title: String
    var isLoading = false
    let action: () -> Void

    private let gradient = LinearGradient(
        colors: [
            Color(hex: "#5BA8FF"),  // lighter blue — top highlight
            Color(hex: "#007AFF"),  // standard blue — bottom
        ],
        startPoint: .top,
        endPoint: .bottom
    )

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
            .background(gradient)
            .cornerRadius(14)
            .shadow(color: Color.tsAccent.opacity(0.39), radius: 14, x: 0, y: 4)
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
