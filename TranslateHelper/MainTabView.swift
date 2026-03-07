//  MainTabView.swift

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0: LibraryView()
                case 1: CommunityView()
                case 2: KitView()
                case 3: SettingsView()
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
                    TabBarItem(icon: "bubble.left.and.bubble.right", label: "Learn",     tag: 0, selected: $selectedTab)
                    TabBarItem(icon: "person.2",                     label: "Community", tag: 1, selected: $selectedTab)
                    TabBarItem(icon: "backpack",                     label: "Kit",       tag: 2, selected: $selectedTab)
                    TabBarItem(icon: "gearshape",                    label: "Settings",  tag: 3, selected: $selectedTab)
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
    let label: String
    let tag: Int
    @Binding var selected: Int

    var isSelected: Bool { selected == tag }

    var body: some View {
        Button(action: { selected = tag }) {
            VStack(spacing: 4) {
                Group {
                    if icon == "backpack" && isSelected {
                        Image(systemName: "backpack.fill")
                            .symbolRenderingMode(.palette)
                            // Primary is the main part of the backpack, Secondary is the pouches
                            .foregroundStyle(Color.tsAccent, Color.tsInputBg)
                    } else {
                        Image(systemName: isSelected ? icon + ".fill" : icon)
                    }
                }
                .font(.system(size: 22))
                
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .tsAccent : .tsSecondary)
            .frame(maxWidth: .infinity)
        }
    }
}
