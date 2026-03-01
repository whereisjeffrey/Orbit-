import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.text = "TranslateHelper Share ✅\nLoading…"
        return l
    }()

    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Close", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        NSLog("TTT_SHARE ✅ viewDidLoad")
         view.backgroundColor = .systemBackground

        view.addSubview(statusLabel)
        view.addSubview(closeButton)

        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            statusLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

            closeButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("TTT_SHARE ✅ viewDidAppear")
        dumpIncomingItems()
    }

    private func dumpIncomingItems() {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            NSLog("TTT_SHARE ❌ No inputItems")
            statusLabel.text = "TranslateHelper Share ❌\nNo inputItems received"
            return
        }

        NSLog("TTT_SHARE inputItems count = \(items.count)")
        statusLabel.text = "TranslateHelper Share ✅\ninputItems: \(items.count)"

        for (i, item) in items.enumerated() {
            let providers = item.attachments ?? []
            NSLog("TTT_SHARE item[\(i)] attachments count = \(providers.count)")

            for (j, p) in providers.enumerated() {
                let typeIDs = p.registeredTypeIdentifiers
                NSLog("TTT_SHARE item[\(i)] provider[\(j)] typeIDs = \(typeIDs)")

                // Optional: quickly detect common text types
                if p.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    NSLog("TTT_SHARE item[\(i)] provider[\(j)] ✅ has plain text")
                }
                if p.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    NSLog("TTT_SHARE item[\(i)] provider[\(j)] ✅ has URL")
                }
                if p.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    NSLog("TTT_SHARE item[\(i)] provider[\(j)] ✅ has image")
                }
            }
        }
    }

    @objc private func closeTapped() {
        NSLog("TTT_SHARE ✅ Close tapped -> completeRequest")
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
