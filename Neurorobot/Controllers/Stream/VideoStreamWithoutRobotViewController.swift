//
//  VideoStreamWithoutRobotViewController.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 29/01/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import UIKit
import AVKit

final class VideoStreamWithoutRobotViewController: BaseStreamViewController {
    
    // UI
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Video session
    private let captureSession  = AVCaptureSession()
    private let videoOutput     = AVCaptureVideoDataOutput()
    private var videoDeviceInput: AVCaptureDeviceInput? {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return nil }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return nil }
        return videoDeviceInput
    }
    
    private let toneGenerator = AVToneGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        handleCameraAccess()
        setupBrain()
    }
    
    func setupUI() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        scrollView.decelerationRate = .fast
    }
    
    func setupBrain() {
        brain.setVideoSize(width: 1000, height: 1000)
        brain.setDistance(distance: 4000)
        brain.delegate = self
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        setCorrectCameraOrientation()
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
    
    private func updateVideo(_ videoFrame: UIImage) {
        
        guard let images = NeurorobotImage.makeSquareImages(image: videoFrame) else { return }
        videoStreamView.setVideo(images: images)
        
        if brain.isRunning, let pointer = videoFrame.unsafePointer() {
            brain.setVideo(videoFrame: pointer)
        }
//        brain.setAudio(audioData: fooAudio!, sampleRate: NeuroRobot.shared.audioSampleRate())
        
        /// Brain update
        if brain.isRunning {
            brainActivityView?.updateActivityValues(brain: brain)
            brainRasterView.updateActivityValues(brain: brain)
            brainNetworkView.update(brain: brain)
            
            let speakerTone = brain.getSpeakerTone()
            toneGenerator.playTone(frequency: speakerTone)
        }
    }
    
    private func setCorrectCameraOrientation() {
        guard let connection = videoOutput.connection(with: .video) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = UIDevice.current.orientation.videoOrientation()
    }
}

//MARK:- Camera access
private extension VideoStreamWithoutRobotViewController {
    
    func handleCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard granted else { self?.showAccessCameraError(); return }
                    self?.setupCaptureSession()
                }
            }
        default:
            showAccessCameraError()
        }
    }
    
    func showAccessCameraError() {
        AlertBanner.shared.showError(message: "You have to grant access to camera in order to use the app.")
    }
    
    func setupCaptureSession() {
        guard let videoDeviceInput = videoDeviceInput else { AlertBanner.shared.showError(message: "Cannot use the camera"); return }
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        guard captureSession.canAddOutput(videoOutput) else { return }
        
        let captureSessionQueue = DispatchQueue(label: "CameraSessionQueue")
        videoOutput.setSampleBufferDelegate(self, queue: captureSessionQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        captureSession.addInput(videoDeviceInput)
        captureSession.addOutput(videoOutput)
        captureSession.commitConfiguration()
        captureSession.startRunning()
        
        setCorrectCameraOrientation()
    }
}

//MARK:- AVCaptureVideoDataOutputSampleBufferDelegate
extension VideoStreamWithoutRobotViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageFoo = UIImage(sampleBuffer: sampleBuffer) else { return }
        
        let image = imageFoo.fixImageOrientation()
        
        if Int(image.size.width) != width {
            brain.setVideoSize(width: Int(image.size.width), height: Int(image.size.height))
            
            width = Int(image.size.width)
            height = Int(image.size.height)
        }
        
        DispatchQueue.main.async { [weak self] in self?.updateVideo(image) }
    }
}

//MARK:- UIScrollViewDelegate
extension VideoStreamWithoutRobotViewController: UIScrollViewDelegate {
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

//MARK:- BrainDelegate
extension VideoStreamWithoutRobotViewController: BrainDelegate {
    
    func brainStopped() {
        toneGenerator.stop()
    }
}
