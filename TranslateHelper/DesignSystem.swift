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


// MARK: - Background
struct TSGradientBackground: View {
    var body: some View {
        Color.tsBackground.ignoresSafeArea()
    }
}

// MARK: - Colours
extension Color {
    static let tsBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(hex: "#111111") : UIColor(hex: "#FFFFFF")
    })
    
    static let tsCard = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(hex: "#1E1E1E") : UIColor(hex: "#F3F9FB")
    })
    
    static let tsBorder = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor.white.withAlphaComponent(0.08) : UIColor(hex: "#0099FF").withAlphaComponent(0.08)
    })
    
    static let tsAccent = Color(hex: "#0099FF")
    
    static let tsAccentTeal = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(hex: "#00C7BE") : UIColor(hex: "#5AC8FA")
    })
    
    static let tsSecondary = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(hex: "#8E8E93") : UIColor(hex: "#6D6D72")
    })
    
    static let tsLabel = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(hex: "#FFFFFF") : UIColor(hex: "#0A0A0A")
    })
    
    static let tsInputBg = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(hex: "#787880").withAlphaComponent(0.12) : UIColor(hex: "#E8F4FA")
    })

    /// Footer / tab bar background.
    /// Dark:  #1E1E1E — lifted near-black with a subtle warm haze (à la TestFlight banner).
    /// Light: #FFFFFF — standard white to match system tab bar convention.
    static let tsFooter = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(hex: "#111111") : UIColor(hex: "#FFFFFF")
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
    
    static let tsBluePrimary = LinearGradient(
        colors: [Color(hex: "#0099FF"), Color(hex: "#005C99")],
        startPoint: .topLeading, endPoint: .bottomTrailing
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

/// Vertical variant — icon stacked above "TalkSwitch" text.
/// Text colour is tsLabel (black in light mode, white in dark mode).
/// Use on splash / intro screens where the brand mark is the hero.
/// `spacing` controls the gap between icon and text (default 10).
struct TSVerticalWordmark: View {
    var iconSize: CGFloat = 56
    var fontSize: CGFloat = 28
    var spacing: CGFloat  = 10  // pass a tighter value on large-icon screens

    var body: some View {
        VStack(spacing: spacing) {
            TSLogoIcon(size: iconSize)
            Text("TalkSwitch")
                .font(.custom("Sono-Regular", size: fontSize))
                .kerning(fontSize * 0.01)
                .foregroundColor(.tsLabel) // black in light, white in dark ✅
        }
    }
}

struct TSTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure = false

    // @State (not @FocusState) so computed properties always reliably trigger re-renders.
    // TextField uses onEditingChanged — the most reliable focus callback in UIKit/SwiftUI.
    // SecureField has no onEditingChanged, so we pair @FocusState with onChange(of:).
    @State private var isFocused = false
    @FocusState private var secureFocused: Bool

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .focused($secureFocused)
                    .onChange(of: secureFocused) { focused in
                        withAnimation(.easeInOut(duration: 0.2)) { isFocused = focused }
                    }
            } else {
                TextField(placeholder, text: $text, onEditingChanged: { editing in
                    withAnimation(.easeInOut(duration: 0.2)) { isFocused = editing }
                })
                .keyboardType(placeholder.lowercased().contains("email") ? .emailAddress : .default)
                .autocapitalization(.none)
                .autocorrectionDisabled()
            }
        }
        .foregroundColor(.tsLabel)
        .padding()
        .background(Color.tsInputBg)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color.tsAccent : Color.tsBorder,
                        lineWidth: isFocused ? 1.5 : 1)
        )
        // Soft blue glow blooms in when the keyboard is active
        .shadow(color: Color.tsAccent.opacity(isFocused ? 0.35 : 0), radius: 6, x: 0, y: 0)
    }
}

// MARK: - TSPickerField
//
// A styled dropdown trigger that wraps SwiftUI's Menu.
// Shows the selected label in tsLabel (white in dark mode) with a permanent blue chevron.
//
// Note: SwiftUI's Menu has no open/close callback, so open-state glow is not possible
// without private API. The blue chevron is the primary visual differentiator.
//
// Usage:
//   TSPickerField(label: selectedItem.name) {
//       ForEach(items) { item in Button(item.name) { selectedItem = item } }
//   }

struct TSPickerField<MenuContent: View>: View {
    /// The text displayed inside the field (e.g. the currently selected option).
    let label: String
    /// The menu items built by the caller.
    @ViewBuilder let menuContent: () -> MenuContent

    var body: some View {
        Menu {
            menuContent()
        } label: {
            HStack(spacing: 0) {
                Text(label)
                    .font(.custom("HelveticaNeue-Medium", size: 17))
                    .foregroundColor(.tsLabel)   // white in dark mode ✅
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.custom("HelveticaNeue-Medium", size: 14))
                    .foregroundColor(.tsAccent)  // always blue ✅
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.tsAccent.opacity(0.25), lineWidth: 1)
            )
            .contentShape(Rectangle()) // ensures full row is tappable
        }
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
                    .font(.custom("HelveticaNeue-Medium", size: 16))
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
                    .font(.custom("HelveticaNeue-Medium", size: 16))
                Text(title)
                    .font(.custom("HelveticaNeue-Bold", size: 15))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(LinearGradient.tsBluePrimary)
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
                .fill(Color.tsBackground)
            Circle()
                .stroke(Color.tsBorder.opacity(0.5), lineWidth: 3)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.tsAccent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.custom("HelveticaNeue-Bold", size: 10))
                .foregroundColor(.tsSecondary)
        }
        .frame(width: size, height: size)
    }
}
