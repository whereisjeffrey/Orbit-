//  MainTabView.swift

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var hasLoadedCoach = false
    @State private var hasLoadedSettings = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Lazy tab loading — Coach and Settings only initialize on first tap.
            // This avoids creating CoachView (4000+ lines) on app launch.
            Group {
                switch selectedTab {
                case 0: LibraryView()
                case 1: CoachView()
                    .onAppear { hasLoadedCoach = true }
                case 2: SettingsView()
                    .onAppear { hasLoadedSettings = true }
                default: LibraryView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // ── Custom tab bar ──────────────────────────────────────────
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.tsSecondary.opacity(0.25))
                    .frame(height: 0.5)
                HStack(spacing: 0) {
                    TabBarItem(icon: "bubble.left.and.bubble.right",                       label: "Learn",    tag: 0, selected: $selectedTab)
                    TabBarItem(icon: "waveform",                     selectedIcon: "waveform", label: "Coach",    tag: 1, selected: $selectedTab)
                    TabBarItem(icon: "gearshape",                                             label: "Settings", tag: 2, selected: $selectedTab)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .background(Color.tsBackground)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct TabBarItem: View {
    let icon: String
    var selectedIcon: String? = nil   // explicit selected-state icon (for symbols without .fill)
    let label: String
    let tag: Int
    @Binding var selected: Int

    var isSelected: Bool { selected == tag }

    private var activeIcon: String {
        if isSelected {
            return selectedIcon ?? (icon + ".fill")
        }
        return icon
    }

    var body: some View {
        Button(action: { selected = tag }) {
            VStack(spacing: 4) {
                Image(systemName: activeIcon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .tsAccent : .tsSecondary)
            .frame(maxWidth: .infinity)
        }
    }
}
