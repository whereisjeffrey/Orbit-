import UIKit

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        // App icon / logo area
        let iconLabel = UILabel()
        iconLabel.text = "🌐"
        iconLabel.font = UIFont.systemFont(ofSize: 72)
        iconLabel.textAlignment = .center

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "TalkSwitch"
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label

        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Translate as you type"
        subtitleLabel.font = UIFont.systemFont(ofSize: 17)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .secondaryLabel

        // Status card
        let statusCard = UIView()
        statusCard.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        statusCard.layer.cornerRadius = 12

        let statusLabel = UILabel()
        statusLabel.text = "✅ Keyboard Installed"
        statusLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.textColor = .systemBlue
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusCard.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: statusCard.topAnchor, constant: 16),
            statusLabel.bottomAnchor.constraint(equalTo: statusCard.bottomAnchor, constant: -16),
            statusLabel.leadingAnchor.constraint(equalTo: statusCard.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: statusCard.trailingAnchor, constant: -16),
        ])

        // Instructions
        let instructionsLabel = UILabel()
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textAlignment = .center
        instructionsLabel.textColor = .secondaryLabel
        instructionsLabel.font = UIFont.systemFont(ofSize: 15)
        instructionsLabel.text = """
        How to use:
        
        1. Open any app with a text field
        2. Tap the 🌐 globe to switch to TalkSwitch
        3. Type or paste text — translation appears automatically
        4. Tap Replace to swap in the translation
        """

        // Settings button
        let settingsButton = UIButton(type: .system)
        settingsButton.setTitle("Open Keyboard Settings", for: .normal)
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        settingsButton.addTarget(self, action: #selector(openKeyboardSettings), for: .touchUpInside)

        // Stack
        let stack = UIStackView(arrangedSubviews: [
            iconLabel, titleLabel, subtitleLabel,
            spacer(height: 20),
            statusCard,
            spacer(height: 16),
            instructionsLabel,
            spacer(height: 24),
            settingsButton,
        ])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            statusCard.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            statusCard.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
        ])
    }

    private func spacer(height: CGFloat) -> UIView {
        let v = UIView()
        v.heightAnchor.constraint(equalToConstant: height).isActive = true
        return v
    }

    @objc private func openKeyboardSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
