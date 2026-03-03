import SwiftUI

struct StudyOptionsCard: View {
    @Environment(\.dismiss) var dismiss
    let listName: String

    // Callbacks — parent wires these up
    var onEdit:      (() -> Void)? = nil
    var onDelete:    (() -> Void)? = nil
    var onAddNew:    (() -> Void)? = nil
    var onSeeList:   (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color.tsBorder)
                .frame(width: 36, height: 4)
                .padding(.top, 12)

            // Header — deck name in bold
            Text(listName)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.tsLabel)
                .padding(.top, 16)
                .padding(.bottom, 16)

            Divider()
                .background(Color.tsBorder)

            // Options
            VStack(spacing: 12) {
                OptionButton(title: "See My List", icon: "list.bullet") {
                    fire(onSeeList)
                }
                OptionButton(title: "Add New", icon: "plus") {
                    fire(onAddNew)
                }
                OptionButton(title: "Edit", icon: "pencil") {
                    fire(onEdit)
                }
                OptionButton(title: "Delete", icon: "trash", isDestructive: true) {
                    fire(onDelete)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            Spacer()
        }
        .background(Color.tsBackground.ignoresSafeArea())
    }

    /// Dismisses the sheet first, then fires the callback after the sheet
    /// has had time to animate away (so navigation works cleanly).
    private func fire(_ action: (() -> Void)?) {
        dismiss()
        guard let action else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            action()
        }
    }
}

// MARK: - Button Style (mirrors SocialButtonStyle from SignInView)
private struct OptionButtonStyle: ButtonStyle {
    let isDestructive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isPressed ? Color.tsCard.opacity(0.6) : Color.tsCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isDestructive
                            ? Color.red.opacity(configuration.isPressed ? 1.0 : 0.4)
                            : Color.tsAccent.opacity(configuration.isPressed ? 1.0 : 0.4),
                        lineWidth: 1.5
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Option Button
struct OptionButton: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 18, weight: .medium))

                Spacer()
            }
            .foregroundColor(isDestructive ? .red : .tsLabel)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 64) // Big enough for thumb tap
        }
        .buttonStyle(OptionButtonStyle(isDestructive: isDestructive))
    }
}
