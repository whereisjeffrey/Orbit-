import KeyboardKit
import UIKit

/// Custom action handler that intercepts the primary (return) key
/// and triggers Orbit translation instead of inserting a newline.
class OrbitActionHandler: KeyboardAction.StandardActionHandler {

    /// Called when the primary key (return/translate) is tapped
    var onPrimaryAction: (() -> Void)?

    override func action(
        for gesture: Keyboard.Gesture,
        on action: KeyboardAction
    ) -> KeyboardAction.GestureAction? {
        if case .primary = action, gesture == .release {
            return { [weak self] _ in
                self?.onPrimaryAction?()
            }
        }
        return super.action(for: gesture, on: action)
    }
}
