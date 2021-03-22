//
//  ConnectViewController.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 6/20/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import UIKit
import SideMenu

final class ConnectViewController: BaseViewController {

    // UI
    @IBOutlet weak var ipAddressTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var downloadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sutupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func sutupUI() {
        ipAddressTextField.text = "192.168.100.1"
        portTextField.text = "80"
    }
}

// MARK: - Actions
private extension ConnectViewController {
    
    @IBAction func gearButtonTapped(_ sender: Any) {
        guard let vc = SideMenuManager.default.rightMenuNavigationController else { return }
        present(vc, animated: true)
    }
    
    @IBAction func connectButtonTapped(_ sender: Any) {
        
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2) {
            self.connectButton.alpha = 0
        }
        
        guard let version = NeuroRobotVersion(rawValue: segmentedControl.selectedSegmentIndex) else {
            Message.error(message: "Choose the correct robot version")
            return
        }
        
        let vc = VideoStreamViewController.loadFromNib()
        vc.setupConnection(ip: ipAddressTextField.text!, port: portTextField.text!, version: version, completionBlock: { (errorMessage) in
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.view.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.2) {
                    self?.connectButton.alpha = 1
                }
                if errorMessage == nil {
                    self?.navigationController?.pushViewController(vc, animated: true)
                } else {
                    Message.error(message: errorMessage!)
                }
            }
        })
    }
    
    @IBAction func dontHaveARobotButtonTapped(_ sender: Any) {
        navigationController?.pushViewController(VideoStreamWithoutRobotViewController.loadFromNib(), animated: true)
    }
    
    @IBAction func downloadButtonTapped(_ sender: Any) {
        
        func finalizeUI() {
            DispatchQueue.main.async { [weak self] in
                self?.downloadActivityIndicator.stopAnimating()
                self?.view.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.2) {
                    self?.downloadButton.alpha = 1
                }
            }
        }
        
        guard checkInternet() else { finalizeUI(); return }
        
        downloadActivityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2) {
            self.downloadButton.alpha = 0
        }
        
        APIManager.shared().getBrains { (url) in
            finalizeUI()
        }
    }
}
