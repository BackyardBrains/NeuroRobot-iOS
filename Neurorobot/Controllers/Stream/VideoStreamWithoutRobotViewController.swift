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
    @IBOutlet weak var stackView    : UIStackView!
    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var scrollView   : UIScrollView!
    
    // Capture session
    private let captureSession  = AVCaptureSession()
    private let videoOutput     = AVCaptureVideoDataOutput()
    private var videoDeviceInput: AVCaptureDeviceInput? {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return nil }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return nil }
        return videoDeviceInput
    }
    private let audioOutput     = AVCaptureAudioDataOutput()
    private var audioDeviceInput: AVCaptureDeviceInput? {
        guard let audioDevice = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .unspecified) else { return nil }
        guard let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice) else { return nil }
        return audioDeviceInput
    }

    // Dispatch group
    private let group = DispatchGroup()

    // Services
    private let toneGenerator = AVToneGenerator()

    // Data
    private var audioData = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSessions()
        setupBrain()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        setCorrectCameraOrientation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
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

    private func setupSessions() {
        group.enter()
        group.enter()
        handleCameraAccess()
        handleMicrophoneAccess()
        setupCaptureSession()
    }
    
    private func setupBrain() {
        brain = Brain(colorSpace: .bgra)
        brain.setVideoSize(width: 1000, height: 1000)
        brain.setDistance(distance: 4000)
        brain.delegate = self
    }
    
    private func updateSpeaker() {
        guard brain.isRunning else { return }
        
        let speakerTone = brain.getSpeakerTone()
        if AppSettings.shared.isVocalEnabled {
            guard speakerTone > 0 else { return }
            
            let index = speakerTone.firstDigit() - 1
            let url = Sounds.shared.getURL(index: index)
            toneGenerator.playAudio(url: url)
        } else {
            toneGenerator.playTone(frequency: speakerTone)
        }
    }
    
    private func updateVideo(_ videoFrame: UIImage) {
        guard let images = NeurorobotImage.makeSquareImages(image: videoFrame) else { return }
        videoStreamView.setVideo(images: images)
        
        if brain.isRunning, let bytes = videoFrame.rawData()?.copyBytes(as: UInt8.self).baseAddress {
            brain.setVideo(videoFrame: bytes)
        }
        
        /// Brain update
        if brain.isRunning {
            brainActivityView?.updateActivityValues(brain: brain)
            brainRasterView.updateActivityValues(brain: brain)
            brainNetworkView.update(brain: brain)
        }
    }
    
    private func setCorrectCameraOrientation() {
        guard let connection = videoOutput.connection(with: .video) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = UIDevice.current.orientation.videoOrientation()
    }
}

// MARK: - Camera access
private extension VideoStreamWithoutRobotViewController {
    
    func handleCameraAccess() {

        func showAccessCameraError() {
            Message.error(message: "You have to grant access to camera in order to use the app.")
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            group.leave()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { [weak self] in
                    guard granted else { showAccessCameraError(); return }
                    self?.group.leave()
                }
            }
        default:
            showAccessCameraError()
        }
    }

    func handleMicrophoneAccess() {

        func showAccessMicrophoneError() {
            Message.error(message: "You have to grant access to microphone in order to use the app.")
        }

        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            group.leave()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { [weak self] in
                    guard granted else { showAccessMicrophoneError(); return }
                    self?.group.leave()
                }
            }
        default:
            showAccessMicrophoneError()
        }
    }
    
    func setupCaptureSession() {
        func setup() {
            guard let videoDeviceInput = videoDeviceInput else { Message.error(message: "Cannot use the camera"); return }
            guard let audioDeviceInput = audioDeviceInput else { Message.error(message: "Cannot use the microphone"); return }
            guard captureSession.canAddInput(videoDeviceInput) else { return }
            guard captureSession.canAddInput(audioDeviceInput) else { return }
            guard captureSession.canAddOutput(videoOutput) else { return }
            guard captureSession.canAddOutput(audioOutput) else { return }

            let captureSessionQueue = DispatchQueue(label: "CameraSessionQueue")
            videoOutput.setSampleBufferDelegate(self, queue: captureSessionQueue)
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]

            let captureSessionQueue2 = DispatchQueue(label: "CameraSessionQueue2")
            audioOutput.setSampleBufferDelegate(self, queue: captureSessionQueue2)

            captureSession.beginConfiguration()
            captureSession.sessionPreset = .photo
            captureSession.addInput(videoDeviceInput)
            captureSession.addInput(audioDeviceInput)
            captureSession.addOutput(videoOutput)
            captureSession.addOutput(audioOutput)
            captureSession.commitConfiguration()
            captureSession.startRunning()

            setCorrectCameraOrientation()
        }

        group.notify(queue: .main) {
            setup()
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate
extension VideoStreamWithoutRobotViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let imageFoo = UIImage(sampleBuffer: sampleBuffer) {
            handleVideoFrame(image: imageFoo)
        } else {
            handleAudioFrame(sampleBuffer: sampleBuffer)
        }
        updateSpeaker()
    }

    private func handleVideoFrame(image: UIImage) {
        let image = image.fixImageOrientation()

        if Int(image.size.width) != width {
            brain.setVideoSize(width: Int(image.size.width), height: Int(image.size.height))

            width = Int(image.size.width)
            height = Int(image.size.height)
        }

        DispatchQueue.main.async { [weak self] in self?.updateVideo(image) }
    }

    private func handleAudioFrame(sampleBuffer: CMSampleBuffer) {
        let data = Data(sampleBuffer: sampleBuffer)
        audioData.append(data)

        guard audioData.count > 2048 else { return }
        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else { return }
        let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription)
        let sampleRate = Int(asbd?.pointee.mSampleRate ?? 0)

        guard sampleRate > 0 else { return }
        guard let spectrum = Brain.getSpectrum(audioData: audioData, sampleRate: sampleRate / 2) else { return }
        DispatchQueue.main.async { [weak self] in self?.chartView.setData(spectrum: spectrum) }


        // TODO: Find better way to transfer data [Int16] to data [Float]
        let bytes16 = audioData.copyBytes(as: Int16.self)
        var dataFloat = [Float]()
        let foo = [Int16](bytes16)
        for num in foo {
            dataFloat.append(Float(num))
        }
        let bytes1 = dataFloat.withUnsafeBufferPointer { (bufferPointer) in
            return bufferPointer
        }
        let dataFloat2 = Data(buffer: bytes1)

        if brain.isRunning {
            brain.setAudio(audioData: dataFloat2, sampleRate: sampleRate / 2)
        }
        
        audioData = Data()
    }
}

// MARK: - UIScrollViewDelegate
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

// MARK: - BrainDelegate
extension VideoStreamWithoutRobotViewController: BrainDelegate {
    
    func brainStarted() {
        
    }
    
    func brainStopped() {
        toneGenerator.stop()
    }
}
