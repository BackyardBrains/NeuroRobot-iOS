//
//  BaseNavigationViewController.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 6/19/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import UIKit

class BaseNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationBar.isTranslucent = false
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {}
    }
}
