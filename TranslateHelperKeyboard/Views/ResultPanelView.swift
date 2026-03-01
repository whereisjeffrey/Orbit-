//
//  ResultPanelView.swift
//  TranslateHelperKeyboard
//
//  Created by TalkSwitch on 15/02/26.
//

import UIKit

protocol ResultPanelViewDelegate: AnyObject {
    func resultPanelDidTapReplace(text: String)
    func resultPanelDidTapCopy(text: String)
    func resultPanelDidTapSave(text: String)
    func resultPanelDidTapSend(text: String)
    func resultPanelDidSelectTone(_ tone: Tone)
}

class ResultPanelView: UIView {
    
    weak var delegate: ResultPanelViewDelegate?
    
    private var isExpanded = false
    private var currentOutputText: String = ""
    private var currentTone: Tone = .casual
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemBackground
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let handleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.tertiaryLabel
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let outputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let toneStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let actionStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var heightConstraint: NSLayoutConstraint!
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(handleView)
        containerView.addSubview(outputTextView)
        containerView.addSubview(toneStackView)
        containerView.addSubview(actionStackView)
        containerView.addSubview(loadingIndicator)
        
        setupToneButtons()
        setupActionButtons()
        
        heightConstraint = containerView.heightAnchor.constraint(equalToConstant: 40)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightConstraint,
            
            handleView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            handleView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 40),
            handleView.heightAnchor.constraint(equalToConstant: 4),
            
            outputTextView.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 8),
            outputTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            outputTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            outputTextView.heightAnchor.constraint(equalToConstant: 100),
            
            toneStackView.topAnchor.constraint(equalTo: outputTextView.bottomAnchor, constant: 12),
            toneStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            toneStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            toneStackView.heightAnchor.constraint(equalToConstant: 36),
            
            actionStackView.topAnchor.constraint(equalTo: toneStackView.bottomAnchor, constant: 12),
            actionStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            actionStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            actionStackView.heightAnchor.constraint(equalToConstant: 44),
            actionStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: outputTextView.centerYAnchor)
        ])
        
        // Start collapsed
        collapse(animated: false)
    }
    
    private func setupToneButtons() {
        for tone in Tone.allCases {
            let button = createToneButton(for: tone)
            toneStackView.addArrangedSubview(button)
        }
    }
    
    private func createToneButton(for tone: Tone) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("\(tone.emoji)", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = UIColor.systemGray5
        button.layer.cornerRadius = 8
        button.tag = Tone.allCases.firstIndex(of: tone) ?? 0
        button.addTarget(self, action: #selector(toneTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func setupActionButtons() {
        let replaceButton = createActionButton(title: "Replace", action: #selector(replaceTapped))
        let copyButton = createActionButton(title: "Copy", action: #selector(copyTapped))
        let saveButton = createActionButton(title: "Save", action: #selector(saveTapped))
        let sendButton = createActionButton(title: "Send", action: #selector(sendTapped))
        
        actionStackView.addArrangedSubview(replaceButton)
        actionStackView.addArrangedSubview(copyButton)
        actionStackView.addArrangedSubview(saveButton)
        actionStackView.addArrangedSubview(sendButton)
    }
    
    private func createActionButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    // MARK: - Actions
    
    @objc private func toneTapped(_ sender: UIButton) {
        let tone = Tone.allCases[sender.tag]
        currentTone = tone
        updateToneSelection()
        delegate?.resultPanelDidSelectTone(tone)
    }
    
    @objc private func replaceTapped() {
        delegate?.resultPanelDidTapReplace(text: currentOutputText)
    }
    
    @objc private func copyTapped() {
        delegate?.resultPanelDidTapCopy(text: currentOutputText)
    }
    
    @objc private func saveTapped() {
        delegate?.resultPanelDidTapSave(text: currentOutputText)
    }
    
    @objc private func sendTapped() {
        delegate?.resultPanelDidTapSend(text: currentOutputText)
    }
    
    // MARK: - Public Methods
    
    func expand(animated: Bool = true) {
        guard !isExpanded else { return }
        isExpanded = true
        
        heightConstraint.constant = 280
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                self.superview?.layoutIfNeeded()
            }
        }
        
        outputTextView.isHidden = false
        toneStackView.isHidden = false
        actionStackView.isHidden = false
    }
    
    func collapse(animated: Bool = true) {
        guard isExpanded else { return }
        isExpanded = false
        
        heightConstraint.constant = 40
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
                self.superview?.layoutIfNeeded()
            }
        }
        
        outputTextView.isHidden = true
        toneStackView.isHidden = true
        actionStackView.isHidden = true
    }
    
    func showLoading() {
        outputTextView.text = ""
        loadingIndicator.startAnimating()
        expand()
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
    }
    
    func showResult(_ text: String, tone: Tone = .casual) {
        currentOutputText = text
        currentTone = tone
        outputTextView.text = text
        hideLoading()
        updateToneSelection()
        expand()
    }
    
    private func updateToneSelection() {
        for (index, view) in toneStackView.arrangedSubviews.enumerated() {
            guard let button = view as? UIButton else { continue }
            let tone = Tone.allCases[index]
            button.backgroundColor = tone == currentTone ? UIColor.systemBlue : UIColor.systemGray5
        }
    }
}
