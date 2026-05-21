import UIKit

/// Custom key button matching native iOS keyboard behavior.
/// - touchDown: visual highlight only (pressed state)
/// - touchUpInside: fires the actual character input
/// - Generous hit area for fast typing
/// - Supports key popup preview via delegate
class KeyButton: UIControl {

    let label = UILabel()

    var keyText: String = "" {
        didSet { label.text = keyText }
    }

    var isSpecialKey: Bool = false

    // Colors set externally
    var normalBg: UIColor = .white { didSet { if !isHighlighted { backgroundColor = normalBg } } }
    var pressedBg: UIColor = UIColor.systemGray3

    /// Called on touchDown so the parent can show a key popup
    var onTouchDown: (() -> Void)?
    /// Called on touchUp/cancel so the parent can hide the popup
    var onTouchUp: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        isExclusiveTouch = false  // allow fast multi-finger typing
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        layer.cornerRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 0.5
        layer.shadowOpacity = 0.25
    }

    // Visual highlight on touch down — character is NOT fired here
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        backgroundColor = pressedBg
        onTouchDown?()
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        backgroundColor = normalBg
        onTouchUp?()
    }

    override func cancelTracking(with event: UIEvent?) {
        backgroundColor = normalBg
        onTouchUp?()
    }

    // Generous hit area — forgive off-center taps during fast typing
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expansion: CGFloat = 6
        return bounds.insetBy(dx: -expansion, dy: -expansion).contains(point)
    }
}
