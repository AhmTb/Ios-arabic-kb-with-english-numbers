import UIKit

final class KeyboardViewController: UIInputViewController {
    private let rows = UIStackView()
    private var symbols = false
    private var marks = false
    private var deletionTimer: Timer?
    private var heightConstraint: NSLayoutConstraint?
    private let normalRows = [
        ["ض", "ص", "ث", "ق", "ف", "غ", "ع", "ه", "خ", "ح", "ج"],
        ["ش", "س", "ي", "ب", "ل", "ا", "ت", "ن", "م", "ك", "د"],
        ["ئ", "ء", "ؤ", "ر", "ﻻ", "ى", "ة", "و", "ز", "ظ", "ط", "ذ"]
    ]
    private let diacriticRows = [
        ["َ", "ً", "ُ", "ٌ", "ِ", "ٍ", "ْ", "ّ", "ٰ", "ـ"],
        ["أ", "إ", "آ", "ا", "لأ", "لإ", "لآ", "لا", "ؤ", "ئ"],
        ["،", "؛", "؟", ".", "!", "«", "»", "(", ")"]
    ]
    private let symbolRows = [
        ["@", "#", "$", "%", "&", "*", "-", "+", "=", "/"],
        ["(", ")", "[", "]", "{", "}", ":", ";", "\"", "'"],
        [".", ",", "،", "؟", "!", "_", "\\", "|", "~", "€"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        rows.axis = .vertical
        rows.distribution = .fillEqually
        rows.spacing = 7
        rows.semanticContentAttribute = .forceLeftToRight
        rows.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rows)
        NSLayoutConstraint.activate([
            rows.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            rows.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            rows.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            rows.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -6)
        ])
        let height = view.heightAnchor.constraint(equalToConstant: 300)
        height.priority = .defaultHigh
        height.isActive = true
        heightConstraint = height
        render()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopDeleting()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        heightConstraint?.constant = size.width > 600 ? 250 : 300
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if isViewLoaded { render() }
    }

    private func render() {
        stopDeleting()
        for row in rows.arrangedSubviews {
            rows.removeArrangedSubview(row)
            row.removeFromSuperview()
        }
        // Literal ASCII digits, independent of device language or region.
        addRow(Array("1234567890").map(String.init), numberRow: true)
        let current = symbols ? symbolRows : (marks ? diacriticRows : normalRows)
        for row in current { addRow(row) }

        let controls = makeRow()
        controls.distribution = .fill
        let mode = button(symbols ? "أبج" : "#+=", action: #selector(toggleSymbols))
        controls.addArrangedSubview(mode)
        mode.widthAnchor.constraint(equalTo: controls.widthAnchor, multiplier: 0.13).isActive = true

        if needsInputModeSwitchKey {
            let globe = button("🌐", action: nil)
            globe.accessibilityLabel = "Switch keyboard"
            globe.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
            controls.addArrangedSubview(globe)
            globe.widthAnchor.constraint(equalTo: controls.widthAnchor, multiplier: 0.11).isActive = true
        }
        let shift = button(marks ? "أبج" : "⇧", action: #selector(toggleMarks))
        shift.accessibilityLabel = "Letters and diacritics"
        controls.addArrangedSubview(shift)
        shift.widthAnchor.constraint(equalTo: controls.widthAnchor, multiplier: 0.11).isActive = true

        let space = button("مسافة", action: #selector(insertSpace))
        controls.addArrangedSubview(space)
        let backspace = button("⌫", action: nil)
        backspace.accessibilityLabel = "Delete"
        backspace.addTarget(self, action: #selector(deleteOnce), for: .touchUpInside)
        backspace.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(repeatDelete(_:))))
        controls.addArrangedSubview(backspace)
        backspace.widthAnchor.constraint(equalTo: controls.widthAnchor, multiplier: 0.12).isActive = true
        let enter = button("↵", action: #selector(insertReturn))
        enter.accessibilityLabel = "Return"
        controls.addArrangedSubview(enter)
        enter.widthAnchor.constraint(equalTo: controls.widthAnchor, multiplier: 0.13).isActive = true
        rows.addArrangedSubview(controls)
    }

    private func makeRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 4
        row.distribution = .fillEqually
        row.semanticContentAttribute = .forceLeftToRight
        return row
    }

    private func addRow(_ values: [String], numberRow: Bool = false) {
        let row = makeRow()
        for value in values {
            let key = button(value, action: #selector(insertKey(_:)))
            key.titleLabel?.font = .systemFont(ofSize: numberRow ? 23 : 25)
            if ["ا", "و", "ي"].contains(value) && !symbols && !marks {
                key.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showVariants(_:))))
            }
            row.addArrangedSubview(key)
        }
        rows.addArrangedSubview(row)
    }

    private func button(_ title: String, action: Selector?) -> UIButton {
        let key = UIButton(type: .system)
        key.setTitle(title, for: .normal)
        key.titleLabel?.font = .systemFont(ofSize: 20)
        key.titleLabel?.adjustsFontSizeToFitWidth = true
        key.titleLabel?.minimumScaleFactor = 0.6
        key.backgroundColor = .tertiarySystemBackground
        key.layer.cornerRadius = 6
        key.layer.shadowColor = UIColor.black.cgColor
        key.layer.shadowOpacity = 0.18
        key.layer.shadowOffset = CGSize(width: 0, height: 1)
        key.layer.shadowRadius = 0
        key.setTitleColor(.label, for: .normal)
        key.accessibilityLabel = title
        if let action = action { key.addTarget(self, action: action, for: .touchUpInside) }
        return key
    }

    @objc private func insertKey(_ sender: UIButton) {
        guard let text = sender.title(for: .normal) else { return }
        // Normalize the lam-alef presentation glyph to two ordinary letters.
        textDocumentProxy.insertText(text == "ﻻ" ? "لا" : text)
    }
    @objc private func insertSpace() { textDocumentProxy.insertText(" ") }
    @objc private func insertReturn() { textDocumentProxy.insertText("\n") }
    @objc private func deleteOnce() { textDocumentProxy.deleteBackward() }
    @objc private func toggleSymbols() { symbols.toggle(); marks = false; render() }
    @objc private func toggleMarks() { symbols = false; marks.toggle(); render() }

    @objc private func showVariants(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let key = gesture.view as? UIButton,
              let letter = key.title(for: .normal) else { return }
        let variants: [String]
        switch letter {
        case "ا": variants = ["أ", "إ", "آ", "ٱ"]
        case "و": variants = ["و", "ؤ"]
        default: variants = ["ي", "ى", "ئ"]
        }
        // Keep the chooser inside the keyboard; extensions cannot rely on
        // presenting a popover outside their input view's bounds.
        let chooser = makeRow()
        chooser.backgroundColor = .secondarySystemBackground
        chooser.layer.cornerRadius = 10
        chooser.layer.borderWidth = 1
        chooser.layer.borderColor = UIColor.separator.cgColor
        chooser.translatesAutoresizingMaskIntoConstraints = false
        chooser.tag = 1234
        view.viewWithTag(1234)?.removeFromSuperview()
        for variant in variants {
            let item = button(variant, action: #selector(chooseVariant(_:)))
            chooser.addArrangedSubview(item)
        }
        let close = button("×", action: #selector(closeVariants))
        close.accessibilityLabel = "Close letter variants"
        chooser.addArrangedSubview(close)
        view.addSubview(chooser)
        NSLayoutConstraint.activate([
            chooser.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chooser.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            chooser.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            chooser.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func chooseVariant(_ sender: UIButton) {
        insertKey(sender)
        closeVariants()
    }
    @objc private func closeVariants() { view.viewWithTag(1234)?.removeFromSuperview() }

    @objc private func repeatDelete(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            deleteOnce()
            deletionTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
                self?.deleteOnce()
            }
        case .ended, .cancelled, .failed: stopDeleting()
        default: break
        }
    }
    private func stopDeleting() { deletionTimer?.invalidate(); deletionTimer = nil }
}
