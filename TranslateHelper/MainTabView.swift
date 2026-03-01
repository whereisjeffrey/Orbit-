//
//  MainTabView.swift
//  TranslateHelper
//

import SwiftUI

struct MainTabView: View {
    @State private var selected = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selected {
                case 0: LibraryView()
                default: LibraryView() // placeholder for other tabs
                }
            }

            // ── Custom tab bar ─────────────────────────────────────────
            VStack(spacing: 0) {
                Divider().background(Color.white.opacity(0.05))
                HStack {
                    TabBarItem(icon: "square.stack.3d.up.fill", label: "Library",  tag: 0, selected: $selected)
                    TabBarItem(icon: "keyboard",                  label: "Keyboard", tag: 1, selected: $selected)

                    // FAB
                    Button {} label: {
                        ZStack {
                            Circle()
                                .fill(LinearGradient.tsVibrant)
                                .frame(width: 64, height: 64)
                                .shadow(color: Color.tsAccent.opacity(0.39), radius: 10, x: 0, y: 4)
                            Image(systemName: "plus")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(y: -20)
                    .frame(maxWidth: .infinity)

                    TabBarItem(icon: "chart.line.uptrend.xyaxis", label: "Stats",    tag: 3, selected: $selected)
                    TabBarItem(icon: "gearshape",                  label: "Settings", tag: 4, selected: $selected)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
                .background(.ultraThinMaterial.opacity(0))
                .background(Color.black.opacity(0.8))
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let tag: Int
    @Binding var selected: Int

    var isActive: Bool { selected == tag }

    var body: some View {
        Button { selected = tag } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(isActive ? .tsAccent : .tsSecondary.opacity(0.5))
            .frame(maxWidth: .infinity)
        }
    }
}
