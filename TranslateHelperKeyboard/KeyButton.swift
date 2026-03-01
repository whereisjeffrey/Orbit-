import UIKit

/// Custom key button optimized for keyboard extension responsiveness.
/// - Fires on touchDown (not touchUpInside) for zero-delay input
/// - Expands hit area with generous touch slop
/// - Instant visual feedback with no system animation delay
class KeyButton: UIControl {

    let label = UILabel()
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    var keyText: String = "" {
        didSet { label.text = keyText }
    }

    var isSpecialKey: Bool = false

    // Colors set externally
    var normalBg: UIColor = .white { didSet { backgroundColor = normalBg } }
    var pressedBg: UIColor = UIColor.systemGray3

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

    // Fire immediately on touch down — no waiting for lift
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        backgroundColor = pressedBg
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        backgroundColor = normalBg
    }

    override func cancelTracking(with event: UIEvent?) {
        backgroundColor = normalBg
    }

    // Expand hit area — forgive slightly off-center taps
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expansion: CGFloat = 4
        return bounds.insetBy(dx: -expansion, dy: -expansion).contains(point)
    }
}
