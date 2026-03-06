//  KitSegmentedPicker.swift
//  Wandr
//
//  Single source of truth for all pill-shaped tab pickers in Kit tools.
//  To change the style globally, edit this file only.
//
//  Usage — fixed-width tabs (2–4 options, equal width):
//      KitSegmentedPicker(items: Array(WorkTab.allCases), selection: $activeTab) { $0.rawValue }
//
//  Usage — scrollable (5+ options or long labels):
//      KitSegmentedPicker(items: Array(TransportMode.allCases), selection: $mode, scrollable: true) { $0.rawValue }

import SwiftUI

struct KitSegmentedPicker<T: Hashable>: View {
    let items: [T]
    @Binding var selection: T
    let label: (T) -> String
    var scrollable: Bool = false
    var horizontalPadding: CGFloat = 16   // set to 0 when parent already pads

    var body: some View {
        Group {
            if scrollable {
                ScrollView(.horizontal, showsIndicators: false) {
                    track.padding(.horizontal, horizontalPadding)
                }
            } else {
                track.padding(.horizontal, horizontalPadding)
            }
        }
    }

    private var track: some View {
        HStack(spacing: 2) {
            ForEach(items, id: \.self) { item in
                Button(action: {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        selection = item
                    }
                }) {
                    Text(label(item))
                        .font(.custom(
                            selection == item ? "HelveticaNeue-Medium" : "HelveticaNeue",
                            size: 14
                        ))
                        .foregroundColor(selection == item ? Color(hex: "#0099FF") : .tsSecondary)
                        .frame(maxWidth: scrollable ? nil : .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, scrollable ? 14 : 0)
                        .background(
                            selection == item
                                ? Color(UIColor.systemBackground)
                                : Color.clear
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(Color.tsInputBg)
        .clipShape(Capsule())
    }
}
