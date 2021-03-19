//
//  SplashViewController.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 30/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import UIKit
import Alamofire

class SplashViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        download()
    }
    
    private func download() {
        
        guard checkInternet(), AppSettings.shared.isBrainAutoDownloadEnabled else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                appDelegate.goToConnect()
            }
            return
        }
        
        APIManager.shared().getBrains { (url) in
            appDelegate.goToConnect()
        }
    }
}
