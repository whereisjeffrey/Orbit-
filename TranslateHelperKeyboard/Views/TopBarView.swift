//
//  TopBarView.swift
//  TranslateHelperKeyboard
//
//  Created by TalkSwitch on 15/02/26.
//

import UIKit

protocol TopBarViewDelegate: AnyObject {
    func topBarDidTapTalkSwitch()
    func topBarDidTapSettings()
}

class TopBarView: UIView {
    
    weak var delegate: TopBarViewDelegate?
    
    // MARK: - UI Components
    
    private let talkSwitchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔄 TalkSwitch", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let directionLabel: UILabel = {
        let label = UILabel()
        label.text = "Auto: en → pt"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("⚙️", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
        backgroundColor = UIColor.systemBackground
        
        addSubview(talkSwitchButton)
        addSubview(directionLabel)
        addSubview(settingsButton)
        
        talkSwitchButton.addTarget(self, action: #selector(talkSwitchTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // TalkSwitch button - left side
            talkSwitchButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            talkSwitchButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            talkSwitchButton.heightAnchor.constraint(equalToConstant: 36),
            talkSwitchButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            // Direction label - center
            directionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            directionLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Settings button - right side
            settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            settingsButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 44),
            settingsButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func talkSwitchTapped() {
        delegate?.topBarDidTapTalkSwitch()
    }
    
    @objc private func settingsTapped() {
        delegate?.topBarDidTapSettings()
    }
    
    // MARK: - Public Methods
    
    func updateDirection(from: String, to: String) {
        directionLabel.text = "Auto: \(from) → \(to)"
    }
    
    func setLoading(_ isLoading: Bool) {
        talkSwitchButton.isEnabled = !isLoading
        if isLoading {
            talkSwitchButton.setTitle("⏳ Loading...", for: .normal)
        } else {
            talkSwitchButton.setTitle("🔄 TalkSwitch", for: .normal)
        }
    }
}
