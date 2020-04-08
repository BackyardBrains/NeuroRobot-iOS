//
//  AVToneGenerator.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 07/04/2020.
//  Copyright © 2020 Go Go Encode. All rights reserved.
//

import Foundation
import AVFoundation

final class AVToneGenerator {
    
    private let engine = AVAudioEngine()
    private let toneNode = AVTonePlayerNode()
    private lazy var format = AVAudioFormat(standardFormatWithSampleRate: toneNode.sampleRate, channels: 1)
    
    init() {
        setupAudioToneGenerator()
    }
    
    private func setupAudioToneGenerator() {
        engine.attach(toneNode)
        engine.connect(toneNode, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.volume = 1.0
    }
    
    func playTone(frequency: Int) {
        if !engine.isRunning, let _ = try? engine.start() {
            toneNode.preparePlaying()
            toneNode.play()
        } else {
            print("Cannot run engine")
        }
        
        toneNode.frequency = Double(frequency)
    }
    
    func stop() {
        toneNode.pause()
        engine.pause()
    }
}
