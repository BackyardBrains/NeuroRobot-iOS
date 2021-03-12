//
//  VideoStreamViewController.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 10/04/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import UIKit

final class VideoStreamViewController: BaseStreamViewController {
    
    // UI
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!

    // Data
    private var ipAddress       : String!
    private var port            : String!
    private var timer           : Timer!
    private var robotConnected  = false
    private var initialCompletionBlock: ((_ : String?) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        robotConnected = true
        initialCompletionBlock = nil
        
        setupUI()
        setupBrain()
        setupParameters()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        timer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] (timer) in
            self?.handleTimer()
        }
        RunLoop.main.add(timer, forMode: .common)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer.invalidate()
        
        send(leftPWM: 0, rightPWM: 0, toneFrequency: 0)
    }
    
    deinit {
        NeuroRobot.shared.stop()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = view.safeAreaInsets
        }
        pageIndicator.currentPage = 0
        stackView.spacing = max(insets.left, insets.right)
    }
    
    private func setupUI() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        scrollView.decelerationRate = .fast
    }
    
    private func setupBrain() {
        brain = Brain(colorSpace: .rgb)
        brain.delegate = self
    }
    
    func setupConnection(ip: String, port: String, version: NeuroRobotVersion, completionBlock: ((_ : String?) -> ())?) {
        self.ipAddress = ip
        self.port = port
        
        NeuroRobot.shared.delegate = self
        initialCompletionBlock = completionBlock
        
        DispatchQueue.global().async { [unowned self] in
            NeuroRobot.shared.connect(ipAddress: self.ipAddress, port: self.port, version: version)
        }
    }
    
    private func setupParameters() {
        APIManager.shared().setGOP(gop: "50") {
            APIManager.shared().getGOP { (resp: RobotResponse?) in
                guard let response = resp else { return }
                print("set gop: \(response.value)")
            }
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            APIManager.shared().setBaudRate(baudRate: "115200")
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            APIManager.shared().setFPS(fps: "25") {
                APIManager.shared().getFPS { (resp: RobotResponse?) in
                    guard let response = resp else { return }
                    print("set fps: \(response.value)")
                }
            }
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            APIManager.shared().setQuality(quality: "0") {
                APIManager.shared().getQuality { (resp: RobotResponse?) in
                    guard let response = resp else { return }
                    print("set quality: \(response.value)")
                }
            }
        }
    }
    
    private func handleTimer() {
        
        /// Set video size
        if NeuroRobot.shared.videoWidth() != width {
            brain.setVideoSize(width: NeuroRobot.shared.videoWidth(), height: NeuroRobot.shared.videoHeight())
            
            width = NeuroRobot.shared.videoWidth()
            height = NeuroRobot.shared.videoHeight()
        }
        
        /// Read video
        if NeuroRobot.shared.readError() == nil {
            if let eyeImages = NeuroRobot.shared.readVideo() {
                videoStreamView.setVideo(images: eyeImages)
            }
            
            let fooAudio = NeuroRobot.shared.readAudio()
            let sampleRate = NeuroRobot.shared.audioSampleRate()

            if fooAudio != nil, let spectrum = Brain.getSpectrum(audioData: fooAudio!, sampleRate: sampleRate) {
                chartView.setData(spectrum: spectrum)
            }

            if brain.isRunning {
                
                if let fooFrame = NeuroRobot.shared.readVideoRaw() {
                    brain.setVideo(videoFrame: fooFrame)
                }
                if fooAudio != nil {
                    brain.setAudio(audioData: fooAudio!, sampleRate: sampleRate)
                }
            }
        } else {
            videoStreamView.setProgress()
        }
        
        /// Serial read
        if let message = NeuroRobot.shared.readSerial(), let serialData = SerialData(message: message) {
            
            var distance = Int32(serialData.distance) ?? 4000
            if distance == 0 {
                distance = 4000
            }
            
            brain.setDistance(distance: distance)
        }
        
        /// Brain update
        if brain.isRunning {
            let rightTorque = brain.getRightTorque()
            let leftTorque = brain.getLeftTorque()
            let speakerTone = brain.getSpeakerTone()
            
            send(leftPWM: leftTorque, rightPWM: rightTorque, toneFrequency: speakerTone)
            brainActivityView?.updateActivityValues(brain: brain)
            brainRasterView.updateActivityValues(brain: brain)
            brainNetworkView.update(brain: brain)
        }
    }
    
    private func send(leftPWM: Int, rightPWM: Int, toneFrequency: Int) {
        
        let message = String(format: "l:%i;r:%i;s:%i;", leftPWM, rightPWM, toneFrequency)
        print(message)
        NeuroRobot.shared.writeSerial(message: message)
    }
}

// MARK: - UIScrollViewDelegate
extension VideoStreamViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let leftInset = stackView.spacing
        let pageWidth = Float(videoStreamView.frame.width + leftInset)
        let contentWidth = Float(scrollView.contentSize.width)
        
        var newPage = Float(pageIndicator.currentPage)
        let targetXContentOffset = Float(targetContentOffset.pointee.x)
        
        if velocity.x == 0 {
            newPage = floor((targetXContentOffset - Float(pageWidth) / 2) / Float(pageWidth)) + 1.0
        } else {
            newPage = Float(velocity.x > 0 ? pageIndicator.currentPage + 1 : pageIndicator.currentPage - 1)
            if newPage < 0 {
                newPage = 0
            }
            if (newPage > contentWidth / pageWidth) {
                newPage = ceil(contentWidth / pageWidth) - 1.0
            }
        }
        
        pageIndicator.currentPage = Int(newPage)
        let point = CGPoint(x: CGFloat(newPage * pageWidth) - leftInset, y: targetContentOffset.pointee.y)
        targetContentOffset.pointee = point
    }
}

// MARK:- NeuroRobotDelegate
extension VideoStreamViewController: NeuroRobotDelegate {
    
    func updatedStreamState(stateMessage: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            guard self.robotConnected else {
                
                if stateMessage == nil {
                    NeuroRobot.shared.start()
                }
                self.initialCompletionBlock?(stateMessage)
                
                return
            }
            guard stateMessage != nil else { return }
            
            self.videoStreamView.setProgress()
            Message.error(message: stateMessage!)
        }
    }
    
    func updatedSocketState(stateMessage: String) {
        DispatchQueue.main.async {
            Message.error(message: stateMessage)
        }
    }
}

// MARK: - BrainDelegate
extension VideoStreamViewController: BrainDelegate {
    
    func brainStarted() {
        
    }
    
    func brainStopped() {
        
    }
}
