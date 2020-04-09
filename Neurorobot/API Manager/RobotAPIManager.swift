//
//  RobotAPIManager.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 31/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import Foundation

extension APIManager {
    
    enum PipeType: Int {
        case local = 0
        case remote = 1
    }
    
    /// Set baud rate of serial communication
    /// - Parameters:
    ///   - baudRate: The baud rate, default is 115200
    ///   - completion: Completion block
    func setBaudRate(baudRate: String = "115200", completion: (() -> Void)? = nil) {
        let params = [
            "command": "set_baudrate",
            "type": "uart1",
            "value": baudRate
        ]
        call(type: .setBaudRate, params: params) { (json, message) in
            completion?()
        }
    }
    
    /// Get baud rate of serial communication
    /// - Parameter completion: Completion block
    func getBaudRate(completion: @escaping (RobotResponse?) -> Void) {
        let params = [
            "command": "get_baudrate",
            "type": "uart1"
        ]
        call(type: .getBaudRate, params: params) { (baudRate: RobotResponse?, message) in
            completion(baudRate)
        }
    }
    
    /// Set FPS of module
    /// - Parameters:
    ///   - fps: The FPS of module you want to set (range: 1~30)
    ///   - type: Local video resolution or Remote video resolution, default is local
    ///   - completion: Completion block
    func setFPS(fps: String, type: PipeType = .local, completion: (() -> Void)? = nil) {
        let params: [String : Any] = [
            "command": "set_max_fps",
            "type": "h264",
            "pipe": type.rawValue,
            "value": fps
        ]
        call(type: .setFPS, params: params) { (json, message) in
            completion?()
        }
    }
    
    /// Get FPS of module
    /// - Parameters:
    ///   - type: Local video resolution or Remote video resolution, default is local
    ///   - completion: Completion block
    func getFPS(type: PipeType = .local, completion: @escaping (RobotResponse?) -> Void) {
        let params: [String : Any] = [
            "command": "get_max_fps",
            "type": "h264",
            "pipe": type.rawValue
        ]
        call(type: .getFPS, params: params) { (baudRate: RobotResponse?, message) in
            completion(baudRate)
        }
    }
    
    /// Set GOP of module
    /// - Parameters:
    ///   - gop: The GOP of module you want to set (range: 1~100)
    ///   - type: Local video resolution or Remote video resolution, default is remote
    ///   - completion: Completion block
    func setGOP(gop: String, type: PipeType = .remote, completion: (() -> Void)? = nil) {
        let params: [String : Any] = [
            "command": "set_enc_gop",
            "type": "h264",
            "pipe": type.rawValue,
            "value": gop
        ]
        call(type: .setGOP, params: params) { (json, message) in
            completion?()
        }
    }
    
    /// Get GOP of module
    /// - Parameters:
    ///   - type: Local video resolution or Remote video resolution, default is remote
    ///   - completion: Completion block
    func getGOP(type: PipeType = .remote, completion: @escaping (RobotResponse?) -> Void) {
        let params: [String : Any] = [
            "command": "get_enc_gop",
            "type": "h264",
            "pipe": type.rawValue
        ]
        call(type: .getGOP, params: params) { (baudRate: RobotResponse?, message) in
            completion(baudRate)
        }
    }
    
    /// Set quality of module
    /// - Parameters:
    ///   - quality: The quality of module you want to set (range: 1~52)
    ///   - type: Local video resolution or Remote video resolution, default is local
    ///   - completion: Completion block
    func setQuality(quality: String, type: PipeType = .local, completion: (() -> Void)? = nil) {
        let params: [String : Any] = [
            "command": "set_enc_quality",
            "type": "h264",
            "pipe": type.rawValue,
            "value": quality
        ]
        call(type: .setGOP, params: params) { (json, message) in
            completion?()
        }
    }
    
    /// Get quality of module
    /// - Parameters:
    ///   - type: Local video resolution or Remote video resolution, default is local
    ///   - completion: Completion block
    func getQuality(type: PipeType = .local, completion: @escaping (RobotResponse?) -> Void) {
        let params: [String : Any] = [
            "command": "get_enc_quality",
            "type": "h264",
            "pipe": type.rawValue
        ]
        call(type: .getGOP, params: params) { (baudRate: RobotResponse?, message) in
            completion(baudRate)
        }
    }
}
