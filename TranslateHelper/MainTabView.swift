//  MainTabView.swift

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                LibraryView()    .tag(0)
                CommunityView()  .tag(1)
                KitView()        .tag(2)
                SettingsView()   .tag(3)
            }

            // Custom tab bar
            HStack(spacing: 0) {
                TabBarItem(icon: "books.vertical",  label: "Library",   tag: 0, selected: $selectedTab)
                TabBarItem(icon: "person.2",         label: "Community", tag: 1, selected: $selectedTab)
                TabBarItem(icon: "square.grid.2x2",  label: "Kit",       tag: 2, selected: $selectedTab)
                TabBarItem(icon: "gearshape",        label: "Settings",  tag: 3, selected: $selectedTab)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 4)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let tag: Int
    @Binding var selected: Int

    var isSelected: Bool { selected == tag }

    var body: some View {
        Button(action: { selected = tag }) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? icon + ".fill" : icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .tsAccent : .tsSecondary)
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .tsAccent : .tsSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
