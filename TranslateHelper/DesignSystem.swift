//
//  DesignSystem.swift
//  TranslateHelper
//

import SwiftUI

extension Color {
    static let tsBackground   = Color(red: 0.04, green: 0.055, blue: 0.102) // #0A0E1A
    static let tsCard         = Color(red: 0.09, green: 0.11,  blue: 0.18)
    static let tsBorder       = Color.white.opacity(0.08)
    static let tsAccent       = Color(red: 0.0,  green: 0.478, blue: 1.0)   // #007AFF
    static let tsSecondary    = Color(red: 0.56, green: 0.56,  blue: 0.58)  // #8E8E93
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
                if isLoading {
                    ProgressView().tint(.white)
                }
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
