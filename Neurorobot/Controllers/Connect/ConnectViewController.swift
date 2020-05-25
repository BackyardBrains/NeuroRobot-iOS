//
//  ConnectViewController.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 6/20/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import UIKit

class ConnectViewController: BaseViewController {

    // UI
    @IBOutlet weak var ipAddressTextField   : UITextField!
    @IBOutlet weak var portTextField        : UITextField!
    @IBOutlet weak var activityIndicator    : UIActivityIndicatorView!
    @IBOutlet weak var segmentedControl     : UISegmentedControl!
    
    @IBOutlet weak var connectButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sutupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func sutupUI() {
        ipAddressTextField.text = "192.168.100.1"
        portTextField.text = "80"
    }
}

private extension ConnectViewController {
    
    @IBAction func connectButtonTapped(_ sender: Any) {
        
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2) {
            self.connectButton.alpha = 0
        }
        
        guard let version = NeuroRobotVersion(rawValue: segmentedControl.selectedSegmentIndex) else {
            AlertBanner.shared.showError(message: "Choose the correct robot version")
            return
        }
        
        let vc = VideoStreamViewController.loadFromNib()
        vc.setupConnection(ip: ipAddressTextField.text!, port: portTextField.text!, version: version, completionBlock: { [weak self] (errorMessage) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.view.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.2) {
                    self?.connectButton.alpha = 1
                }
                if errorMessage == nil {
                    self?.navigationController?.pushViewController(vc, animated: true)
                } else {
                    AlertBanner.shared.showError(message: errorMessage!)
                }
            }
        })
    }
    
    @IBAction func dontHaveARobotButtonTapped(_ sender: Any) {
        navigationController?.pushViewController(VideoStreamWithoutRobotViewController.loadFromNib(), animated: true)
    }
}
