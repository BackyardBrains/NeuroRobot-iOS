//
//  BaseViewController.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 6/19/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import UIKit
import Alamofire

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseSetupUI()
    }
    
    private func baseSetupUI() {
        view.backgroundColor = .white
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {}
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
    
    deinit {
        print("deinit: " + String(describing: self))
    }
    
    func checkInternet() -> Bool {
        guard let manager = NetworkReachabilityManager(), manager.isReachable else {
            Message.warning(message: "You are not connected to the internet")
            return false
        }
        return true
    }
}
