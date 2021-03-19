//
//  NeuroRobot-Library-Wrapper.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 6/9/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import Foundation
import UIKit

protocol NeuroRobotDelegate: class {
    func updatedStreamState(stateMessage: String?)
    func updatedSocketState(stateMessage: String)
}

enum NeuroRobotVersion: Int {
    case v1 = 0
    case v2
}

final class NeuroRobot {
    
    static let shared = NeuroRobot()
    weak var delegate: NeuroRobotDelegate?
    
    private var ipAddress: String?
    
    private var robotObject: UnsafeRawPointer?
    private static let kStreamStateUpdatedNotificationName = Notification.Name("kStreamStateUpdatedNotification")
    private static let kSocketStateUpdatedNotificationName = Notification.Name("kSocketStateUpdatedNotification")
    
    private init() {
        NotificationCenter.default.addObserver(forName: NeuroRobot.kStreamStateUpdatedNotificationName, object: nil, queue: nil) { [weak self] (notification) in
            guard let self = self else { return }

            var errorString: String?
            if let error = notification.object as? String {
                errorString = error
            }
            self.delegate?.updatedStreamState(stateMessage: errorString)
        }
        
        NotificationCenter.default.addObserver(forName: NeuroRobot.kSocketStateUpdatedNotificationName, object: nil, queue: nil) { [weak self] (notification) in
            guard let self = self else { return }

            var errorString = ""
            if let error = notification.object as? String {
                errorString = error
            }
            self.delegate?.updatedSocketState(stateMessage: errorString)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getIpAddress() -> String? {
        return ipAddress
    }
    
    func connect(ipAddress: String, port: String, version: NeuroRobotVersion) {
        self.ipAddress = ipAddress
        swift_init(ipAddress: ipAddress, port: port, version: version.rawValue)
    }
    
    func start() {
        guard let _ = robotObject else { return }
        swift_start()
    }
    
    func readVideoRaw() -> UnsafePointer<UInt8>? {
        guard let _ = robotObject else { return nil }
        return swift_readVideoRaw()
    }
    
    func readVideo() -> (UIImage, UIImage)? {
        guard let _ = robotObject else { return nil }
        guard let images = swift_readVideo() else { return nil }
        
        return images
    }
    
    func stop() {
        guard let _ = robotObject else { return }
        swift_stop()
    }
    
    func readSerial() -> String? {
        guard let _ = robotObject else { return nil }
        return swift_readSerial()
    }
    
    func writeSerial(message: String) {
        guard let _ = robotObject else { return }
        swift_writeSerial(message: message)
    }
    
    /// Send audio to robot's speaker
    /// - Parameters:
    ///   - audioData: 14bit wav (raw) data, 8kHz
    ///   - numberOfBytes: number of bytes
    func sendAudio(audioData: UnsafeMutablePointer<Int16>, numberOfBytes: Int) {
        guard let _ = robotObject else { return }
        swift_sendAudio(audioData: audioData, numberOfBytes: numberOfBytes)
    }
    
    /// Send audio to robot's speaker
    /// - Parameter url: url to wav file, 8kHz
    func sendAudio(url: URL) {
//        guard let audioPlayer = try? AVAudioPlayer(contentsOf: url) else { fatalError("There is no sample rate") }
//        guard let sampleRate = audioPlayer.settings[AVSampleRateKey] as? Int else { fatalError("There is no sample rate") }
        
        let offset = 4096
        guard let data = try? Data(contentsOf: url) else { return }
        let size = data.count - offset
        guard size > 0 else { return }
        
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        data.advanced(by: offset).copyBytes(to: pointer, count: size)
        
        let audioData = UnsafeMutablePointer<Int16>.allocate(capacity: size / 2)
        
        audioData.assign(from: pointer.withMemoryRebound(to: Int16.self, capacity: size / 2, { (pointer) -> UnsafeMutablePointer<Int16> in
            return pointer
        }), count: size / 2)
        
        let audioData2 = UnsafeMutablePointer<Int16>.allocate(capacity: Int(size / 2))
        
        for i in 0..<size / 2 {
            let value = Int16(audioData.advanced(by: i).pointee)
            audioData2.advanced(by: i).pointee = Int16(Double(value) / Double(INT16_MAX) * 8158)
        }
        NeuroRobot.shared.sendAudio(audioData: audioData2, numberOfBytes: size)
        
        pointer.deallocate()
        audioData.deallocate()
        audioData2.deallocate()
    }
    
    func sendBeepAudio() {
        let foo3 = UnsafeMutablePointer<Int16>.allocate(capacity: Int(10000))
        for i in 0..<10000 {
            let multiplier = Double(i % 10) / Double(10)
            let sinus = sin(2 * Double.pi * multiplier) * 8158
            let value = Int16(sinus)
            print(value)
            foo3.advanced(by: i).pointee = value
        }
        NeuroRobot.shared.sendAudio(audioData: foo3, numberOfBytes: 10000)
        foo3.deallocate()
    }
    
    func readAudio() -> Data? {
        guard let _ = robotObject else { return nil }
        return swift_readAudio()
    }
    
    func readError() -> String? {
        guard let _ = robotObject else { return nil }
        return swift_readError()
    }
    
    func videoWidth() -> Int {
        return swift_readVideoWidth()
    }
    
    func videoHeight() -> Int {
        return swift_readVideoHeight()
    }
    
    func audioSampleRate() -> Int {
        return swift_readaudioSampleRate()
    }
}

private extension NeuroRobot
{
    func swift_init(ipAddress: String, port: String, version: Int) {
        let ipAddressPointer = UnsafeMutablePointer<Int8>(mutating: (ipAddress as NSString).utf8String)
        let portPointer = UnsafeMutablePointer<Int8>(mutating: (port as NSString).utf8String)
        
        robotObject = swiftBridge_Init(ipAddressPointer, portPointer, Int16(version), { (streamState) in
            if let errorString = NeuroRobot.parseStreamError(error: streamState) {
                NotificationCenter.default.post(name: NeuroRobot.kStreamStateUpdatedNotificationName, object: errorString)
            }
        }) { (socketState) in
            if let errorString = NeuroRobot.parseSocketError(error: socketState) {
                NotificationCenter.default.post(name: NeuroRobot.kSocketStateUpdatedNotificationName, object: errorString)
            }
        }
        
        let streamState = swiftBridge_readStreamState(robotObject)
        let streamStateDescription = NeuroRobot.parseStreamError(error: streamState)
        
        NotificationCenter.default.post(name: NeuroRobot.kStreamStateUpdatedNotificationName, object: streamStateDescription)
    }
    
    func swift_start() {
        swiftBridge_start(robotObject)
    }
    
    func swift_stop() {
        swiftBridge_stop(robotObject)
        robotObject = nil
    }
    
    func swift_readVideoRaw() -> UnsafePointer<UInt8> {
        return swiftBridge_readVideo(robotObject)
    }
    
    func swift_readVideoWidth() -> Int {
        return Int(swiftBridge_videoWidth(robotObject))
    }
    
    func swift_readVideoHeight() -> Int {
        return Int(swiftBridge_videoHeight(robotObject))
    }
    
    func swift_readaudioSampleRate() -> Int {
        return Int(swiftBridge_audioSampleRate(robotObject))
    }
    
    func swift_readVideo() -> (UIImage, UIImage)? {
        let videoWidth = Int(swiftBridge_videoWidth(robotObject))
        let videoHeight = Int(swiftBridge_videoHeight(robotObject))
        let videoFrame = swiftBridge_readVideo(robotObject)
        
        guard videoFrame != nil, videoWidth != 0, videoHeight != 0 else { return nil }
        
        return NeurorobotImage.make(imagePointer: videoFrame!, width: videoWidth, height: videoHeight)!
    }
    
    func swift_readSerial() -> String? {
        let sizePtr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        let serialData = swiftBridge_readSerial(robotObject, sizePtr)
        sizePtr.deallocate()
        
        guard serialData != nil else { return nil }
        
        let message = String(cString: serialData!)
        
        return message
    }
    
    func swift_writeSerial(message: String) {
        swiftBridge_writeSerial(robotObject, message.makeCString())
    }
    
    func swift_sendAudio(audioData: UnsafeMutablePointer<Int16>, numberOfBytes: Int) {
        swiftBridge_sendAudio(robotObject, audioData, numberOfBytes)
    }
    
    func swift_readAudio() -> Data? {
        let totalBytesPtr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        let bytesPerSamplePtr = UnsafeMutablePointer<UInt16>.allocate(capacity: 1)
        defer {
            totalBytesPtr.deallocate()
            bytesPerSamplePtr.deallocate()
        }
        
        let audioDataPtr = swiftBridge_readAudio(robotObject, totalBytesPtr, bytesPerSamplePtr)
        
        let totalBytes = Int(totalBytesPtr.pointee)
        let bytesPerSample = Int(bytesPerSamplePtr.pointee)
        
        guard totalBytes != 0, bytesPerSample != 0, audioDataPtr != nil else { return nil }

        let pointer = UnsafeBufferPointer(start: audioDataPtr?.assumingMemoryBound(to: Float.self), count: totalBytes / bytesPerSample)

        return Data(buffer: pointer)
    }
    
    func swift_readError() -> String? {
        var stateString: String? = nil
        let streamStateType = swiftBridge_readStreamState(robotObject!)
        let socketStateType = swiftBridge_readSocketState(robotObject)
        if let streamState = NeuroRobot.parseStreamError(error: streamStateType) {
            stateString = "Stream: " + streamState
        }
        if let socketState = NeuroRobot.parseSocketError(error: socketStateType) {
            if stateString != nil {
                stateString = stateString! + "\n"
            }
            stateString = "Socket: " + socketState
        }
        return stateString
    }
}

private extension NeuroRobot {
    class func parseStreamError(error: StreamStateType) -> String? {
        guard error.rawValue >= 100 else { return nil }
        
        let statePointer = getStreamStateMessage(error)
        let state = String(cString: statePointer!)
        
        return state
    }
    
    class func parseSocketError(error: SocketStateType) -> String? {
        guard error.rawValue >= 100, error.rawValue < 200 else { return nil }
        
        let statePointer = getSocketStateMessage(error)
        let state = String(cString: statePointer!)
        
        return state
    }
}
