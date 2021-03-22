//
//  SettingsController.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 19.3.21..
//  Copyright © 2021 Backyard Brains. All rights reserved.
//

import UIKit

final class SettingsController: BaseViewController {
    
    // UI
    private let vocalLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14, weight: .light)
        view.textColor = .black
        view.textAlignment = .left
        view.text = "Vocal"
        return view
    }()
    private lazy var vocalSwitch: UISwitch = {
        let view = UISwitch()
        view.isOn = AppSettings.shared.isVocalEnabled
        view.addTarget(self, action: #selector(vocalSwitchTapped), for: .valueChanged)
        return view
    }()
    private let versionLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 12)
        view.textColor = UIColor(210)
        view.textAlignment = .center
        if let dict = Bundle.main.infoDictionary, let version = dict["CFBundleShortVersionString"] as? String, let build = dict["CFBundleVersion"] as? String {
            view.text = "v. " + version + "(" + build + ")"
        }
        return view
    }()
    
    private lazy var brainAutoDownloadSwitch: UISwitch = {
        let view = UISwitch()
        view.isOn = AppSettings.shared.isBrainAutoDownloadEnabled
        view.addTarget(self, action: #selector(brainAutoDownloadSwitchTapped), for: .valueChanged)
        return view
    }()
    private let brainAutoDownloadLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14, weight: .light)
        view.textColor = .black
        view.textAlignment = .left
        view.text = "Brain auto download"
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setupUI() {
        title = "Settings"
        
        let verticalStack = UIStackView()
        view.addSubview(verticalStack)
        verticalStack.fillTopOfSuperView()
        verticalStack.distribution = .fillEqually
        verticalStack.alignment = .fill
        verticalStack.spacing = 2
        verticalStack.axis = .vertical
        verticalStack.isLayoutMarginsRelativeArrangement = true
        if #available(iOS 11.0, *) {
            verticalStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        } else {
            debugPrint("directionalLayoutMargins not available on this iOS")
        }
        
        let vocalStack = UIStackView()
        verticalStack.addArrangedSubview(vocalStack)
        vocalStack.height(50)
        vocalStack.distribution = .fill
        vocalStack.alignment = .center
        vocalStack.spacing = 0
        vocalStack.axis = .horizontal

        vocalStack.addArrangedSubview(vocalLabel)
        vocalStack.addArrangedSubview(vocalSwitch)
        
        
        let brainAutoDownloadStack = UIStackView()
        verticalStack.addArrangedSubview(brainAutoDownloadStack)
        brainAutoDownloadStack.height(50)
        brainAutoDownloadStack.distribution = .fill
        brainAutoDownloadStack.alignment = .center
        brainAutoDownloadStack.spacing = 0
        brainAutoDownloadStack.axis = .horizontal
        
        brainAutoDownloadStack.addArrangedSubview(brainAutoDownloadLabel)
        brainAutoDownloadStack.addArrangedSubview(brainAutoDownloadSwitch)
        
        view.addSubview(versionLabel)
        versionLabel.fillBottomOfSuperView(insets: UIEdgeInsets(bottom: 10))
    }
}

// MARK: - Actions
extension SettingsController {
    
    @objc func vocalSwitchTapped() {
        AppSettings.shared.isVocalEnabled = vocalSwitch.isOn
    }
    
    @objc func brainAutoDownloadSwitchTapped() {
        AppSettings.shared.isBrainAutoDownloadEnabled = brainAutoDownloadSwitch.isOn
    }
}
