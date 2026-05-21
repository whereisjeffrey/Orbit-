import UIKit

/// Orbit keyboard: native iOS keyboard clone (KeyboardPlate) with translation layer above.
/// The keyboard plate is LOCKED — draws and handles touches in a single view.
/// Orbit features (strip, drawer) sit above the fold.
protocol QWERTYViewDelegate: AnyObject {
    func qwertyDidTapKey(_ character: String)
    func qwertyDidTapBackspace()
    func qwertyDidTapSpace()
    func qwertyDidTapReturn()
    func qwertyDidTapTranslate()
    func qwertyDidTapGlobe()
    func qwertyDidTapSpeak()
    func qwertyDidTapDrawer()
    func qwertyDidTapSavePhrase()
    func qwertyDidLongPressWord(_ word: String, inTranslation: Bool)
    func qwertyNeedsAutoCapCheck() -> Bool
}

class QWERTYView: UIView {

    weak var delegate: QWERTYViewDelegate?

    // MARK: - Subviews

    private let plate = KeyboardPlate()

    // Orbit layer (above fold)
    private let stripHeight: CGFloat = 44
    private let translationStrip = UIView()
    private let originalLabel = UILabel()
    private let translatedLabel = UILabel()
    private let saveButton = UIButton(type: .system)
    private let drawerHandle = UIButton(type: .system)

    private let drawerView = UIView()
    private let drawerNotesLabel = UILabel()
    private let drawerPronunciationLabel = UILabel()
    private let drawerCloseButton = UIButton(type: .system)
    private var drawerHeightConstraint: NSLayoutConstraint!
    private var drawerExpanded = false

    // Colors for Orbit layer (dark to match plate)
    private let stripBg = UIColor(white: 0.08, alpha: 1)
    private let drawerBg = UIColor(white: 0.10, alpha: 1)
    private let secondaryText = UIColor(white: 0.6, alpha: 1)
    private let translateBlue = UIColor.systemBlue
    private let textWhite = UIColor.white

    // Double-tap space
    private var lastSpaceTime: TimeInterval = 0

    // MARK: - Init

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)  // match plate bg
        clipsToBounds = true

        setupTranslationStrip()
        setupDrawer()
        setupPlate()
    }

    // MARK: - Plate

    private func setupPlate() {
        plate.delegate = self
        plate.translatesAutoresizingMaskIntoConstraints = false
        addSubview(plate)
        // No gesture recognizers — plate handles all touches internally via raw touch tracking
    }

    // MARK: - Translation Strip

    private func setupTranslationStrip() {
        translationStrip.translatesAutoresizingMaskIntoConstraints = false
        translationStrip.backgroundColor = stripBg
        translationStrip.layer.cornerRadius = 6
        translationStrip.isHidden = true
        addSubview(translationStrip)

        originalLabel.font = .systemFont(ofSize: 11, weight: .regular)
        originalLabel.textColor = secondaryText
        originalLabel.numberOfLines = 1
        originalLabel.translatesAutoresizingMaskIntoConstraints = false
        translationStrip.addSubview(originalLabel)

        translatedLabel.font = .systemFont(ofSize: 14, weight: .medium)
        translatedLabel.textColor = textWhite
        translatedLabel.numberOfLines = 1
        translatedLabel.isUserInteractionEnabled = true
        translatedLabel.translatesAutoresizingMaskIntoConstraints = false
        translationStrip.addSubview(translatedLabel)
        let tlp = UILongPressGestureRecognizer(target: self, action: #selector(translationLongPressed(_:)))
        tlp.minimumPressDuration = 0.5
        translatedLabel.addGestureRecognizer(tlp)

        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setImage(UIImage(systemName: "bookmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)), for: .normal)
        saveButton.tintColor = translateBlue
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        translationStrip.addSubview(saveButton)

        drawerHandle.translatesAutoresizingMaskIntoConstraints = false
        drawerHandle.setImage(UIImage(systemName: "chevron.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)), for: .normal)
        drawerHandle.tintColor = secondaryText
        drawerHandle.addTarget(self, action: #selector(drawerToggleTapped), for: .touchUpInside)
        translationStrip.addSubview(drawerHandle)

        NSLayoutConstraint.activate([
            translationStrip.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            translationStrip.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            translationStrip.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            translationStrip.heightAnchor.constraint(equalToConstant: stripHeight),
            originalLabel.topAnchor.constraint(equalTo: translationStrip.topAnchor, constant: 4),
            originalLabel.leadingAnchor.constraint(equalTo: translationStrip.leadingAnchor, constant: 10),
            originalLabel.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -6),
            translatedLabel.topAnchor.constraint(equalTo: originalLabel.bottomAnchor, constant: 1),
            translatedLabel.leadingAnchor.constraint(equalTo: translationStrip.leadingAnchor, constant: 10),
            translatedLabel.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -6),
            saveButton.centerYAnchor.constraint(equalTo: translationStrip.centerYAnchor),
            saveButton.trailingAnchor.constraint(equalTo: drawerHandle.leadingAnchor, constant: -4),
            saveButton.widthAnchor.constraint(equalToConstant: 28),
            drawerHandle.centerYAnchor.constraint(equalTo: translationStrip.centerYAnchor),
            drawerHandle.trailingAnchor.constraint(equalTo: translationStrip.trailingAnchor, constant: -6),
            drawerHandle.widthAnchor.constraint(equalToConstant: 24),
        ])
    }

    // MARK: - Drawer

    private func setupDrawer() {
        drawerView.translatesAutoresizingMaskIntoConstraints = false
        drawerView.backgroundColor = drawerBg
        drawerView.layer.cornerRadius = 8
        drawerView.clipsToBounds = true
        drawerView.isHidden = true
        addSubview(drawerView)

        drawerNotesLabel.font = .systemFont(ofSize: 12); drawerNotesLabel.textColor = textWhite; drawerNotesLabel.numberOfLines = 0
        drawerNotesLabel.translatesAutoresizingMaskIntoConstraints = false; drawerView.addSubview(drawerNotesLabel)
        drawerPronunciationLabel.font = .systemFont(ofSize: 11); drawerPronunciationLabel.textColor = secondaryText; drawerPronunciationLabel.numberOfLines = 0
        drawerPronunciationLabel.translatesAutoresizingMaskIntoConstraints = false; drawerView.addSubview(drawerPronunciationLabel)
        drawerCloseButton.translatesAutoresizingMaskIntoConstraints = false
        drawerCloseButton.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)), for: .normal)
        drawerCloseButton.tintColor = secondaryText
        drawerCloseButton.addTarget(self, action: #selector(drawerToggleTapped), for: .touchUpInside)
        drawerView.addSubview(drawerCloseButton)

        drawerHeightConstraint = drawerView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            drawerView.topAnchor.constraint(equalTo: translationStrip.bottomAnchor, constant: 2),
            drawerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            drawerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            drawerHeightConstraint,
            drawerNotesLabel.topAnchor.constraint(equalTo: drawerView.topAnchor, constant: 8),
            drawerNotesLabel.leadingAnchor.constraint(equalTo: drawerView.leadingAnchor, constant: 10),
            drawerNotesLabel.trailingAnchor.constraint(equalTo: drawerCloseButton.leadingAnchor, constant: -6),
            drawerPronunciationLabel.topAnchor.constraint(equalTo: drawerNotesLabel.bottomAnchor, constant: 4),
            drawerPronunciationLabel.leadingAnchor.constraint(equalTo: drawerView.leadingAnchor, constant: 10),
            drawerPronunciationLabel.trailingAnchor.constraint(equalTo: drawerView.trailingAnchor, constant: -10),
            drawerPronunciationLabel.bottomAnchor.constraint(lessThanOrEqualTo: drawerView.bottomAnchor, constant: -8),
            drawerCloseButton.topAnchor.constraint(equalTo: drawerView.topAnchor, constant: 6),
            drawerCloseButton.trailingAnchor.constraint(equalTo: drawerView.trailingAnchor, constant: -6),
            drawerCloseButton.widthAnchor.constraint(equalToConstant: 24),
            drawerCloseButton.heightAnchor.constraint(equalToConstant: 24),
        ])
    }

    // MARK: - Layout

    private var orbitLayerHeight: CGFloat {
        if translationStrip.isHidden { return 0 }
        var h = stripHeight + 4
        if drawerExpanded { h += drawerHeightConstraint.constant + 2 }
        return h
    }

    var requiredHeight: CGFloat { orbitLayerHeight + plate.plateHeight }

    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        guard w > 0 else { return }
        let plateY = orbitLayerHeight
        plate.frame = CGRect(x: 0, y: plateY, width: w, height: plate.plateHeight)
    }

    // MARK: - Actions

    @objc private func saveTapped() {
        delegate?.qwertyDidTapSavePhrase()
        UIView.animate(withDuration: 0.15, animations: { self.saveButton.transform = .init(scaleX: 1.3, y: 1.3) }) { _ in
            UIView.animate(withDuration: 0.15) { self.saveButton.transform = .identity }
        }
    }

    @objc private func drawerToggleTapped() {
        drawerExpanded.toggle()
        if drawerExpanded {
            drawerView.isHidden = false; drawerHeightConstraint.constant = 80
            drawerHandle.setImage(UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)), for: .normal)
        } else {
            drawerHeightConstraint.constant = 0
            drawerHandle.setImage(UIImage(systemName: "chevron.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)), for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                guard let self, !self.drawerExpanded else { return }; self.drawerView.isHidden = true
            }
        }
        UIView.animate(withDuration: 0.25) { self.setNeedsLayout(); self.layoutIfNeeded(); self.superview?.layoutIfNeeded() }
        delegate?.qwertyDidTapDrawer()
    }

    @objc private func translationLongPressed(_ g: UILongPressGestureRecognizer) {
        guard g.state == .began, let text = translatedLabel.text, !text.isEmpty else { return }
        if let word = wordAt(g.location(in: translatedLabel), in: translatedLabel) {
            delegate?.qwertyDidLongPressWord(word, inTranslation: true)
            highlight(word)
        }
    }

    // MARK: - Auto-Capitalization

    func checkAutoCapitalization() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self, !self.plate.isNumberMode, !self.plate.isSymbolMode, !self.plate.isCapsLock else { return }
            let should = self.delegate?.qwertyNeedsAutoCapCheck() ?? false
            if should != self.plate.isShifted { self.plate.isShifted = should }
        }
    }

    // MARK: - Public API

    func showTranslation(original: String, translated: String) {
        translationStrip.isHidden = false; originalLabel.text = original; translatedLabel.text = translated; setNeedsLayout()
    }
    func hideTranslation() {
        translationStrip.isHidden = true; originalLabel.text = ""; translatedLabel.text = ""; setNeedsLayout()
    }
    func updateDrawerContent(notes: String?, pronunciation: String?) {
        drawerNotesLabel.text = notes ?? ""
        drawerPronunciationLabel.text = pronunciation != nil ? "🗣 \(pronunciation!)" : ""
    }
    func showDrawerAutoOpen() { if !drawerExpanded { drawerToggleTapped() } }
    var hasTranslation: Bool { !translationStrip.isHidden && !(translatedLabel.text?.isEmpty ?? true) }

    // MARK: - Word Detection

    private func wordAt(_ pt: CGPoint, in label: UILabel) -> String? {
        guard let text = label.text, !text.isEmpty, let font = label.font else { return nil }
        let s = NSTextStorage(attributedString: NSAttributedString(string: text, attributes: [.font: font]))
        let m = NSLayoutManager(); let c = NSTextContainer(size: label.bounds.size); c.lineFragmentPadding = 0
        m.addTextContainer(c); s.addLayoutManager(m)
        let idx = m.characterIndex(for: pt, in: c, fractionOfDistanceBetweenInsertionPoints: nil)
        guard idx < text.count else { return nil }
        let ns = text as NSString
        var a = idx, b = idx
        while a > 0, let sc = Unicode.Scalar(ns.character(at: a-1)), CharacterSet.letters.contains(sc) { a -= 1 }
        while b < ns.length, let sc = Unicode.Scalar(ns.character(at: b)), CharacterSet.letters.contains(sc) { b += 1 }
        guard b - a > 0 else { return nil }
        return ns.substring(with: NSRange(location: a, length: b - a))
    }

    private func highlight(_ word: String) {
        guard let text = translatedLabel.text else { return }
        let a = NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: textWhite])
        if let r = text.range(of: word, options: .caseInsensitive) {
            a.addAttributes([.backgroundColor: translateBlue.withAlphaComponent(0.3), .foregroundColor: translateBlue], range: NSRange(r, in: text))
        }
        translatedLabel.attributedText = a
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in self?.translatedLabel.attributedText = nil; self?.translatedLabel.text = text }
    }
}

// MARK: - KeyboardPlateDelegate

extension QWERTYView: KeyboardPlateDelegate {
    func plateDidTapCharacter(_ char: String) {
        delegate?.qwertyDidTapKey(char)
        checkAutoCapitalization()
    }
    func plateDidTapBackspace() {
        delegate?.qwertyDidTapBackspace()
        checkAutoCapitalization()
    }
    func plateDidTapShift() { /* handled internally by plate */ }
    func plateDidDoubleTapShift() { /* handled internally by plate */ }
    func plateDidTapSpace() {
        let now = Date().timeIntervalSince1970
        if now - lastSpaceTime < 0.3 {
            delegate?.qwertyDidTapBackspace()
            delegate?.qwertyDidTapKey(". ")
            lastSpaceTime = 0
        } else {
            delegate?.qwertyDidTapSpace()
            lastSpaceTime = now
        }
        checkAutoCapitalization()
    }
    func plateDidTapGlobe() { delegate?.qwertyDidTapGlobe() }
    func plateDidTapNumberToggle() {
        if plate.isSymbolMode { plate.isSymbolMode = false; plate.isNumberMode = true }
        else if plate.isNumberMode { plate.isNumberMode = false }
        else { plate.isNumberMode = true }
    }
    func plateDidTapTranslate() { delegate?.qwertyDidTapTranslate() }
    func plateDidBeginBackspaceRepeat() { /* repeat handled inside plate */ }
    func plateDidEndBackspaceRepeat() { checkAutoCapitalization() }
}
