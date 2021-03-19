//
//  VideoStreamDebugViewController.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 6/20/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import UIKit
import AVFoundation

final class VideoStreamDebugViewController: BaseStreamViewController {
    
    // UI
    @IBOutlet weak var scrollView               : UIScrollView!
    @IBOutlet weak var leftWheelCounterLabel    : UILabel!
    @IBOutlet weak var rightWheelCounterLabel   : UILabel!
    @IBOutlet weak var distanceLabel            : UILabel!
    @IBOutlet weak var temperatureLabel         : UILabel!
    @IBOutlet weak var acxLabel                 : UILabel!
    @IBOutlet weak var acyLabel                 : UILabel!
    @IBOutlet weak var aczLabel                 : UILabel!
    @IBOutlet weak var gyxLabel                 : UILabel!
    @IBOutlet weak var gyyLabel                 : UILabel!
    @IBOutlet weak var gyzLabel                 : UILabel!
    @IBOutlet weak var messageTextField         : UITextField!
    @IBOutlet weak var recordButton             : UIButton!
    @IBOutlet weak var polygonView              : UIView!
    @IBOutlet weak var controllView             : FingerView!
    @IBOutlet weak var intensityLabel           : UILabel!
    @IBOutlet weak var maxPWMTextField          : UITextField!
    @IBOutlet weak var bottomScrollView         : UIScrollView!
    
    // Data
    private var maxPWM          : CGFloat = 255
    private var ipAddress       : String!
    private var port            : String!
    private var timer           : Timer!
    private var robotConnected  = false
    private var initialCompletionBlock: ((_ : String?) -> ())?
    
    // Audio
    private var recordingSession    : AVAudioSession!
    private var audioRecorder       : AVAudioRecorder!
    private var streamerIsWorking   = false
    private var audioSteramer       : AudioStreamer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        robotConnected = true
        initialCompletionBlock = nil
        brain.delegate = self
        
        setupUI()
        setupAudioRecorder()
        setupAudioSession()
        setupAudioStreamer()
        setupParameters()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer.invalidate()
        
        send(leftPWM: 0, rightPWM: 0, toneFrequency: 0)
        NeuroRobot.shared.stop()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        polygonView.layer.cornerRadius = polygonView.bounds.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] (timer) in
            self?.handleTimer()
        }
        
        timer.fire()
    }
    
    func handleTimer() {
        
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
            
            if (brain.isRunning || streamerIsWorking) {
                let fooAudio = NeuroRobot.shared.readAudio()
                
                if brain.isRunning {
                    if let fooFrame = NeuroRobot.shared.readVideoRaw() {
                        brain.setVideo(videoFrame: fooFrame)
                    }
                    if fooAudio != nil {
                        brain.setAudio(audioData: fooAudio!, sampleRate: NeuroRobot.shared.audioSampleRate())
                    }
                }
                
                if streamerIsWorking, fooAudio != nil {
                    audioSteramer?.scheduleData(audioData: fooAudio!)
                }
            }
        }
        
        /// Serial read
        if let message = NeuroRobot.shared.readSerial(), let serialData = SerialData(message: message) {
            
            var distance = Int32(serialData.distance) ?? 4000
            if distance == 0 {
                distance = 4000
            }
            
            leftWheelCounterLabel.text     = serialData.leftEncoderValue
            rightWheelCounterLabel.text    = serialData.rightEncoderValue
            distanceLabel.text             = "\(distance)"
            acxLabel.text                  = serialData.acx
            acyLabel.text                  = serialData.acy
            aczLabel.text                  = serialData.acz
            temperatureLabel.text          = serialData.temperature
            gyxLabel.text                  = serialData.gyx
            gyyLabel.text                  = serialData.gyy
            gyzLabel.text                  = serialData.gyz
            
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
    
    func setupUI() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        polygonView.layer.borderColor = UIColor.black.cgColor
        polygonView.layer.borderWidth = 5
        controllView.intensityChanged { [weak self] (vector, radius) in
            self?.intensityChanged(vector: vector, radius: radius)
        }
        
        maxPWMTextField.text = String(Int(maxPWM))
    }
    
    func intensityChanged(vector: Vector, radius: CGFloat) {
        let intensity = vector.intensity / radius
        
        intensityLabel.text = String(format: "%.0f", intensity * maxPWM)
        
        var leftPWM: Int = 0
        var rightPWM: Int = 0
        
        let totalPWM = intensity * maxPWM
        
        let yPWM = Int(totalPWM * vector.dY * vector.dY) * -vector.dY.sign()
        let xPWM = Int(totalPWM * vector.dX * vector.dX) * vector.dX.sign()
        
        leftPWM = yPWM
        rightPWM = yPWM
        
        leftPWM = leftPWM + xPWM
        rightPWM = rightPWM - xPWM
        
        print("left PWM: ", leftPWM)
        print("right PWM: ", rightPWM)
        
        send(leftPWM: leftPWM, rightPWM: rightPWM, toneFrequency: 0)
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
    
    func setupParameters() {
        APIManager.shared().setGOP(gop: "50") {
            APIManager.shared().getGOP { (resp: RobotResponse?) in
                print("set gop: \(resp!.value)")
            }
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            APIManager.shared().setBaudRate(baudRate: "115200")
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            APIManager.shared().setFPS(fps: "25") {
                APIManager.shared().getFPS { (resp: RobotResponse?) in
                    print("set fps: \(resp!.value)")
                }
            }
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            APIManager.shared().setQuality(quality: "0") {
                APIManager.shared().getQuality { (resp: RobotResponse?) in
                    print("set quality: \(resp!.value)")
                }
            }
        }
    }
}

// MARK:- Audio setup
extension VideoStreamDebugViewController {
    
    func setupAudioRecorder() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async { [weak self] in
                    self?.recordButton.isHidden = !allowed
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            if #available(iOS 11.0, *) {
                try session.setCategory(.playAndRecord, mode: .default, policy: .default, options: [.allowBluetoothA2DP, .defaultToSpeaker])
            } else {
                AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:error:"), with: AVAudioSession.Category.playAndRecord)
            }
            try session.setActive(true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func setupAudioStreamer() {
        audioSteramer = AudioStreamer(audioFormat: AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 16000, channels: 1, interleaved: false)!)
    }
}
// MARK:- Actions
extension VideoStreamDebugViewController
{
    @IBAction func speakerButtonTapped(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        
        streamerIsWorking = !streamerIsWorking
        
        if streamerIsWorking {
            button.alpha = 1.0
        } else {
            button.alpha = 0.5
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        guard let message = messageTextField.text, message.count != 0 else { return }
        NeuroRobot.shared.writeSerial(message: message)
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        let audioFilename = URL.documentsDirectory().appendingPathComponent("recording2.wav")
        
        let settings: [String : Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 8000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.setTitle("Recording...", for: .normal)
        } catch {
            recordButtonEnded(self)
        }
    }
    
    @IBAction func recordButtonEnded(_ sender: Any) {
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
            recordButton.isEnabled = false
            recordButton.setTitle("Please wait", for: .normal)
        } else {
            recordButton.isEnabled = true
            recordButton.setTitle("Hold to record", for: .normal)
        }
    }
    
    func send(leftPWM: Int, rightPWM: Int, toneFrequency: Int) {
        
        let message = String(format: "l:%i;r:%i;s:%i", leftPWM, rightPWM, toneFrequency)
        print(message)
        NeuroRobot.shared.writeSerial(message: message)
    }
    
//    func sendTone(toneFrequency: Int) {
//        let message = String(format: "s:%i", toneFrequency)
//        print(message)
//        NeuroRobot.shared.writeSerial(message: message)
//    }
}

// MARK:- Delegate AVAudioRecorderDelegate
extension VideoStreamDebugViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordButton.isEnabled = true
        recordButton.setTitle("Hold to record", for: .normal)
        
        let url = URL.documentsDirectory().appendingPathComponent("recording2.wav")
        NeuroRobot.shared.sendAudio(url: url)
    }
    
    func playBeep() {
        let foo3 = UnsafeMutablePointer<Int16>.allocate(capacity: Int(10000))
        for i in 0..<10000 {
            let multiplier = Double(i % 10) / Double(10)
            let sinus = sin(2 * Double.pi * multiplier) * 8158
            let value = Int16(sinus)
            print(value)
            foo3.advanced(by: i).pointee = value
        }
        NeuroRobot.shared.sendAudio(audioData: foo3, numberOfBytes: 10000)
    }
}

// MARK:- UITextFieldDelegate
extension VideoStreamDebugViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let finalNum = textField.text! + string
        
        guard string != "" else { return true } // Backspace
        guard let range = finalNum.rangeOfCharacter(from: .decimalDigits), !range.isEmpty else { return false } // Not decimal char
        guard var number = Int(finalNum) else { return false }
        
        if number > 255 {
            number = 255
        } else if number < 0 {
            number = 0
        }
        
        textField.text = String(number)
        maxPWM = CGFloat(number)
        
        return false
    }
}

// MARK:- NeuroRobotDelegate
extension VideoStreamDebugViewController: NeuroRobotDelegate {
    
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
extension VideoStreamDebugViewController: BrainDelegate {
    
    func brainStarted() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.bottomScrollView.scrollRectToVisible(self.brainNetworkView.frame, animated: true)
        }
    }
    
    func brainStopped() {
        send(leftPWM: 0, rightPWM: 0, toneFrequency: 0)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.bottomScrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.bottomScrollView.bounds.height), animated: true)
        }
    }
}
