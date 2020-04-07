//
//  BaseStreamViewController.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 14/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import UIKit

class BaseStreamViewController: BaseViewController {
    
    // UI
    var brainPicker = BrainPickerView()
    @IBOutlet weak var videoStreamView          : VideoStreamView!
    @IBOutlet weak var brainActivityView        : BrainActivityView?
    @IBOutlet weak var brainRasterView          : BrainActivityRasterView!
    @IBOutlet weak var brainNetworkView         : BrainNetworkView!
    
    // Data
    var brain = Brain()
    var width: Int = 0
    var height: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        brain.stop()
    }
    
    private func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startNeuronNetworkTapped))
        view.addSubview(brainPicker)
        brainPicker.choosenBrainWithPath = choosenBrainWithPath
    }
}

// MARK:- Actions
private extension BaseStreamViewController
{
    @IBAction func startNeuronNetworkTapped(_ sender: Any) {
        brain.stop()
        togglePickerConstraints(brainIsRunning: false)
    }
    
    @IBAction func pauseNeuronNetworkTapped(_ sender: Any) {
        brain.stop()
        brainRasterView.pause()
        self.title = ""
        togglePickerConstraints(changeConstraints: false, brainIsRunning: false)
    }
}

//MARK:- Brain picking
extension BaseStreamViewController {
    
    func togglePickerConstraints(changeConstraints: Bool = true, brainIsRunning: Bool) {
        changeConstraints ? brainPicker.toggle() : nil
        
        if brainIsRunning {
            
            let activityIndicator = UIActivityIndicatorView(style: .gray)
            activityIndicator.startAnimating()
            let activityItem = UIBarButtonItem(customView: activityIndicator)
            let pauseButton = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(self.pauseNeuronNetworkTapped))
            
            navigationItem.rightBarButtonItems = [pauseButton, activityItem]
        } else {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(self.startNeuronNetworkTapped))]
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}

//MARK:- Brain picking
private extension BaseStreamViewController {
    
    func choosenBrainWithPath(brainPath: String?, brainName: String?) {
        
        title = brainName
        
        guard let brainPath = brainPath else {
            togglePickerConstraints(brainIsRunning: false)
            return
        }
        
        guard let _ = try? brain.load(pathToMatFile: brainPath) else { AlertBanner.shared.showError(message: "Cannot load brain"); return }
        
        brain.start()
        brainNetworkView.initialSetup(brain: brain)
        brainNetworkView.isHidden = false
        
        brainActivityView?.configureUI(brain: brain)
        brainRasterView.configureUI(brain: brain)
        brainRasterView.play()
        
        if brain.isRunning {
            togglePickerConstraints(brainIsRunning: true)
        } else {
            AlertBanner.shared.showError(message: "Cannot load brain")
        }
    }
}
