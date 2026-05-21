import UIKit

/// Single-view keyboard plate — draws all keys and handles all touches centrally.
/// No subviews, no AutoLayout, no gesture recognizers, no live shadows.
/// Matches native iOS keyboard feel: multi-touch, zero dead zones, cached rendering.

protocol KeyboardPlateDelegate: AnyObject {
    func plateDidTapCharacter(_ char: String)
    func plateDidTapBackspace()
    func plateDidTapShift()
    func plateDidDoubleTapShift()
    func plateDidTapSpace()
    func plateDidTapGlobe()
    func plateDidTapNumberToggle()
    func plateDidTapTranslate()
    func plateDidBeginBackspaceRepeat()
    func plateDidEndBackspaceRepeat()
}

// MARK: - Key Definition

struct KeyDef {
    var label: String
    let char: String
    let type: KeyType
    var frame: CGRect = .zero
    enum KeyType { case letter, special, space, translate }
}

// MARK: - KeyboardPlate

class KeyboardPlate: UIView {

    weak var delegate: KeyboardPlateDelegate?

    // MARK: - State

    var isShifted = false  { didSet { if oldValue != isShifted { updateLabelsAndRedraw() } } }
    var isCapsLock = false
    var isNumberMode = false { didSet { if oldValue != isNumberMode { fullRebuild() } } }
    var isSymbolMode = false { didSet { if oldValue != isSymbolMode { fullRebuild() } } }

    // MARK: - Native iOS Keyboard Specs (LOCKED — do not change)

    private let keyH: CGFloat = 42
    private let keyGap: CGFloat = 6
    private let rowGap: CGFloat = 11
    private let edgeInset: CGFloat = 3
    private let row2Inset: CGFloat = 18
    private let topPad: CGFloat = 8
    private let bottomPad: CGFloat = 3
    private let specialKeyW: CGFloat = 44
    private let keyRadius: CGFloat = 5

    // Dark mode colors
    private let kbBg        = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
    private let letterKeyBg = UIColor(red: 0.29, green: 0.29, blue: 0.30, alpha: 1)
    private let specialBg   = UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1)
    private let pressedBg   = UIColor(white: 0.45, alpha: 1)
    private let keyTextColor = UIColor.white
    private let translateBlue = UIColor.systemBlue

    private let keyFont      = UIFont.systemFont(ofSize: 22, weight: .light)
    private let specialFont  = UIFont.systemFont(ofSize: 14, weight: .medium)
    private let spaceFont    = UIFont.systemFont(ofSize: 15, weight: .regular)
    private let translateFont = UIFont.systemFont(ofSize: 14, weight: .semibold)

    // Key rows
    private let letterRow1 = ["Q","W","E","R","T","Y","U","I","O","P"]
    private let letterRow2 = ["A","S","D","F","G","H","J","K","L"]
    private let letterRow3 = ["Z","X","C","V","B","N","M"]
    private let numberRow1 = ["1","2","3","4","5","6","7","8","9","0"]
    private let numberRow2 = ["-","/",":",";","(",")","$","&","@","\""]
    private let numberRow3 = [".",",","?","!","'"]
    private let symbolRow1 = ["[","]","{","}","#","%","^","*","+","="]
    private let symbolRow2 = ["_","\\","|","~","<",">","€","£","¥","•"]
    private let symbolRow3 = [".",",","?","!","'"]

    // MARK: - Cached SF Symbol Images (rendered once at setup)

    private var shiftImg: UIImage!
    private var shiftFillImg: UIImage!
    private var deleteImg: UIImage!
    private var globeImg: UIImage!

    // MARK: - Layout State

    private var allKeys: [KeyDef] = []
    private var pressedIndices: Set<Int> = []  // multi-touch: multiple keys can be pressed
    private var lastLayoutWidth: CGFloat = 0

    // MARK: - Touch Tracking (multi-touch, raw — no gesture recognizers)

    private var touchKeyMap: [UITouch: Int] = [:]  // track which key each finger is on
    private var backspaceTouch: UITouch? = nil
    private var backspaceTimer: Timer?
    private var backspaceAccelTimer: Timer?

    // Shift double-tap
    private var lastShiftTime: TimeInterval = 0

    // Popup
    private let popupLayer = CALayer()
    private let popupTextLayer = CATextLayer()

    // Haptic (fire-and-forget on background queue)
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    /// Fixed keyboard height
    var plateHeight: CGFloat { topPad + 4 * keyH + 3 * rowGap + bottomPad }

    // MARK: - Init

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        backgroundColor = kbBg
        isMultipleTouchEnabled = true  // track both thumbs
        isOpaque = true               // rendering optimization
        clearsContextBeforeDrawing = false
        haptic.prepare()
        cacheSymbolImages()
        setupPopupLayers()
    }

    private func cacheSymbolImages() {
        let medCfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let regCfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        shiftImg     = UIImage(systemName: "shift", withConfiguration: medCfg)?.withTintColor(keyTextColor, renderingMode: .alwaysOriginal)
        shiftFillImg = UIImage(systemName: "shift.fill", withConfiguration: medCfg)?.withTintColor(keyTextColor, renderingMode: .alwaysOriginal)
        deleteImg    = UIImage(systemName: "delete.left", withConfiguration: medCfg)?.withTintColor(keyTextColor, renderingMode: .alwaysOriginal)
        globeImg     = UIImage(systemName: "globe", withConfiguration: regCfg)?.withTintColor(keyTextColor, renderingMode: .alwaysOriginal)
    }

    private func setupPopupLayers() {
        popupLayer.cornerRadius = 8
        popupLayer.shadowOffset = CGSize(width: 0, height: 2)
        popupLayer.shadowRadius = 4
        popupLayer.shadowOpacity = 0.4
        popupLayer.backgroundColor = UIColor(white: 0.42, alpha: 1).cgColor
        popupLayer.isHidden = true
        layer.addSublayer(popupLayer)

        popupTextLayer.font = UIFont.systemFont(ofSize: 32, weight: .light)
        popupTextLayer.fontSize = 32
        popupTextLayer.foregroundColor = UIColor.white.cgColor
        popupTextLayer.alignmentMode = .center
        popupTextLayer.contentsScale = UIScreen.main.scale
        popupTextLayer.isHidden = true
        layer.addSublayer(popupTextLayer)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.width > 0 && bounds.width != lastLayoutWidth {
            lastLayoutWidth = bounds.width
            fullRebuild()
        }
    }

    private func fullRebuild() {
        allKeys.removeAll(keepingCapacity: true)
        let w = lastLayoutWidth > 0 ? lastLayoutWidth : bounds.width
        guard w > 0 else { return }
        let rowW = w - 2 * edgeInset

        let r1, r2, r3: [String]
        if isSymbolMode      { r1 = symbolRow1; r2 = symbolRow2; r3 = symbolRow3 }
        else if isNumberMode { r1 = numberRow1; r2 = numberRow2; r3 = numberRow3 }
        else                 { r1 = letterRow1; r2 = letterRow2; r3 = letterRow3 }

        var y = topPad

        // Row 1
        addRow(r1, y: y, x: edgeInset, width: rowW)

        // Row 2
        y += keyH + rowGap
        let r2x = edgeInset + row2Inset
        addRow(r2, y: y, x: r2x, width: w - 2 * r2x)

        // Row 3: shift + letters + backspace
        y += keyH + rowGap
        let shiftLabel = (isNumberMode || isSymbolMode) ? "#+=" : "⇧"
        allKeys.append(KeyDef(label: shiftLabel, char: "SHIFT", type: .special, frame: CGRect(x: edgeInset, y: y, width: specialKeyW, height: keyH)))
        let letterArea = rowW - 2 * specialKeyW - 2 * keyGap
        let kw3 = (letterArea - CGFloat(r3.count - 1) * keyGap) / CGFloat(r3.count)
        let sx = edgeInset + specialKeyW + keyGap
        for (i, c) in r3.enumerated() {
            allKeys.append(KeyDef(label: displayChar(c), char: c, type: .letter, frame: CGRect(x: sx + CGFloat(i) * (kw3 + keyGap), y: y, width: kw3, height: keyH)))
        }
        allKeys.append(KeyDef(label: "⌫", char: "BACKSPACE", type: .special, frame: CGRect(x: edgeInset + rowW - specialKeyW, y: y, width: specialKeyW, height: keyH)))

        // Row 4: 123, globe, space, translate
        y += keyH + rowGap
        let smallW: CGFloat = 40; let transW: CGFloat = 88
        let spaceW = max(40, rowW - 2 * smallW - transW - 3 * keyGap)
        var x4 = edgeInset
        allKeys.append(KeyDef(label: (isNumberMode || isSymbolMode) ? "ABC" : "123", char: "NUM_TOGGLE", type: .special, frame: CGRect(x: x4, y: y, width: smallW, height: keyH))); x4 += smallW + keyGap
        allKeys.append(KeyDef(label: "🌐", char: "GLOBE", type: .special, frame: CGRect(x: x4, y: y, width: smallW, height: keyH))); x4 += smallW + keyGap
        allKeys.append(KeyDef(label: "space", char: "SPACE", type: .space, frame: CGRect(x: x4, y: y, width: spaceW, height: keyH))); x4 += spaceW + keyGap
        allKeys.append(KeyDef(label: "Translate", char: "TRANSLATE", type: .translate, frame: CGRect(x: x4, y: y, width: transW, height: keyH)))

        setNeedsDisplay()
    }

    private func addRow(_ chars: [String], y: CGFloat, x: CGFloat, width: CGFloat) {
        let n = CGFloat(chars.count)
        let kw = (width - (n - 1) * keyGap) / n
        for (i, c) in chars.enumerated() {
            allKeys.append(KeyDef(label: displayChar(c), char: c, type: .letter, frame: CGRect(x: x + CGFloat(i) * (kw + keyGap), y: y, width: kw, height: keyH)))
        }
    }

    /// Update labels only (no layout change) — used for shift toggle
    private func updateLabelsAndRedraw() {
        for i in allKeys.indices {
            if allKeys[i].type == .letter && !isNumberMode && !isSymbolMode {
                allKeys[i].label = displayChar(allKeys[i].char)
            }
        }
        setNeedsDisplay()
    }

    private func displayChar(_ c: String) -> String {
        (!isNumberMode && !isSymbolMode && !isShifted && !isCapsLock) ? c.lowercased() : c
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        // Fill background
        ctx.setFillColor(kbBg.cgColor)
        ctx.fill(bounds)

        for (i, key) in allKeys.enumerated() {
            let f = key.frame
            let pressed = pressedIndices.contains(i)

            // Background
            let bg: UIColor
            switch key.type {
            case .letter:    bg = pressed ? pressedBg : letterKeyBg
            case .special:   bg = pressed ? pressedBg : specialBg
            case .space:     bg = pressed ? pressedBg : letterKeyBg
            case .translate: bg = pressed ? translateBlue.withAlphaComponent(0.7) : translateBlue
            }
            let path = UIBezierPath(roundedRect: f, cornerRadius: keyRadius)
            ctx.setFillColor(bg.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()

            // 1px shadow at bottom
            if !pressed {
                ctx.setFillColor(UIColor(white: 0, alpha: 0.25).cgColor)
                ctx.fill(CGRect(x: f.minX, y: f.maxY, width: f.width, height: 1))
            }

            // Content
            switch key.char {
            case "SHIFT":
                drawImage((isShifted || isCapsLock) ? shiftFillImg : shiftImg, in: f)
            case "BACKSPACE":
                drawImage(deleteImg, in: f)
            case "GLOBE":
                drawImage(globeImg, in: f)
            default:
                let tc: UIColor = key.type == .translate ? .white : keyTextColor
                let font: UIFont
                switch key.type {
                case .letter: font = keyFont
                case .special: font = specialFont
                case .space: font = spaceFont
                case .translate: font = translateFont
                }
                let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: tc]
                let sz = key.label.size(withAttributes: attrs)
                key.label.draw(at: CGPoint(x: f.midX - sz.width / 2, y: f.midY - sz.height / 2), withAttributes: attrs)
            }
        }
    }

    private func drawImage(_ img: UIImage?, in rect: CGRect) {
        guard let img else { return }
        let s = img.size
        img.draw(at: CGPoint(x: rect.midX - s.width / 2, y: rect.midY - s.height / 2))
    }

    // MARK: - Touch Handling (multi-touch, zero dead zones)

    /// Every point on the keyboard maps to the nearest key center — no dead zones
    private func nearestKeyIndex(at point: CGPoint) -> Int? {
        guard !allKeys.isEmpty else { return nil }
        var bestIdx = 0
        var bestDist: CGFloat = .greatestFiniteMagnitude
        for (i, key) in allKeys.enumerated() {
            let dx = point.x - key.frame.midX
            let dy = point.y - key.frame.midY
            let dist = dx * dx + dy * dy
            if dist < bestDist { bestDist = dist; bestIdx = i }
        }
        return bestIdx
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let pt = touch.location(in: self)
            guard let idx = nearestKeyIndex(at: pt) else { continue }
            touchKeyMap[touch] = idx
            pressedIndices.insert(idx)

            // Show popup for letter keys
            if allKeys[idx].type == .letter { showPopup(for: allKeys[idx]) }

            // Start backspace repeat timer via raw touch (no gesture recognizer)
            if allKeys[idx].char == "BACKSPACE" {
                backspaceTouch = touch
                backspaceTimer?.invalidate()
                backspaceAccelTimer?.invalidate()
                backspaceTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
                    self?.delegate?.plateDidTapBackspace()
                }
                backspaceAccelTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
                    self?.backspaceTimer?.invalidate()
                    self?.backspaceTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] _ in
                        self?.delegate?.plateDidTapBackspace()
                    }
                }
            }
        }
        setNeedsDisplay()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var changed = false
        for touch in touches {
            let pt = touch.location(in: self)
            guard let newIdx = nearestKeyIndex(at: pt) else { continue }
            let oldIdx = touchKeyMap[touch]
            if newIdx != oldIdx {
                if let old = oldIdx { pressedIndices.remove(old) }
                pressedIndices.insert(newIdx)
                touchKeyMap[touch] = newIdx
                changed = true

                // Cancel backspace repeat if finger moved off backspace
                if touch == backspaceTouch && allKeys[newIdx].char != "BACKSPACE" {
                    cancelBackspaceRepeat()
                }

                // Update popup
                hidePopup()
                if allKeys[newIdx].type == .letter { showPopup(for: allKeys[newIdx]) }
            }
        }
        if changed { setNeedsDisplay() }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let idx = touchKeyMap[touch] {
                pressedIndices.remove(idx)

                // Cancel backspace repeat — the single initial tap is handled by fireKey
                if touch == backspaceTouch { cancelBackspaceRepeat() }

                fireKey(allKeys[idx])
                touchKeyMap.removeValue(forKey: touch)
            }
        }
        hidePopup()
        setNeedsDisplay()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let idx = touchKeyMap[touch] { pressedIndices.remove(idx) }
            if touch == backspaceTouch { cancelBackspaceRepeat() }
            touchKeyMap.removeValue(forKey: touch)
        }
        hidePopup()
        setNeedsDisplay()
    }

    private func cancelBackspaceRepeat() {
        backspaceTimer?.invalidate(); backspaceTimer = nil
        backspaceAccelTimer?.invalidate(); backspaceAccelTimer = nil
        backspaceTouch = nil
        delegate?.plateDidEndBackspaceRepeat()
    }

    // MARK: - Fire Key

    private func fireKey(_ key: KeyDef) {
        // Haptic + sound off the critical path
        haptic.impactOccurred()
        haptic.prepare()
        DispatchQueue.main.async { UIDevice.current.playInputClick() }

        switch key.char {
        case "SHIFT":
            let now = Date().timeIntervalSince1970
            if now - lastShiftTime < 0.4 {
                isCapsLock = true; isShifted = true; lastShiftTime = 0
            } else {
                if isCapsLock { isCapsLock = false; isShifted = false }
                else { isShifted.toggle() }
                lastShiftTime = now
            }
        case "BACKSPACE":
            delegate?.plateDidTapBackspace()
        case "SPACE":
            delegate?.plateDidTapSpace()
        case "GLOBE":
            delegate?.plateDidTapGlobe()
        case "NUM_TOGGLE":
            delegate?.plateDidTapNumberToggle()
        case "TRANSLATE":
            delegate?.plateDidTapTranslate()
        default:
            var ch = key.char
            if !isNumberMode && !isSymbolMode {
                ch = (isShifted || isCapsLock) ? ch.uppercased() : ch.lowercased()
            }
            delegate?.plateDidTapCharacter(ch)
            if isShifted && !isCapsLock { isShifted = false }
        }
    }

    // MARK: - Popup

    private func showPopup(for key: KeyDef) {
        let f = key.frame
        let pw = max(f.width + 16, 48), ph: CGFloat = 52
        let px = min(max(f.midX - pw / 2, 2), bounds.width - pw - 2)
        let py = max(0, f.minY - ph - 2)
        CATransaction.begin(); CATransaction.setDisableActions(true)
        popupLayer.frame = CGRect(x: px, y: py, width: pw, height: ph); popupLayer.isHidden = false
        popupTextLayer.frame = popupLayer.frame; popupTextLayer.string = key.label; popupTextLayer.isHidden = false
        CATransaction.commit()
    }

    private func hidePopup() {
        guard !popupLayer.isHidden else { return }
        CATransaction.begin(); CATransaction.setDisableActions(true)
        popupLayer.isHidden = true; popupTextLayer.isHidden = true
        CATransaction.commit()
    }

    // MARK: - Public

    func isBackspaceAt(_ point: CGPoint) -> Bool {
        guard let idx = nearestKeyIndex(at: point) else { return false }
        return allKeys[idx].char == "BACKSPACE"
    }
}
