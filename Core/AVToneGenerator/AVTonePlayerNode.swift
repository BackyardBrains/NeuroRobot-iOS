//
//  AVTonePlayerNode.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 07/04/2020.
//  Copyright © 2020 Go Go Encode. All rights reserved.
//

import Foundation
import AVFoundation

final class AVTonePlayerNode: AVAudioPlayerNode {
    
    var frequency: Double = 0
    var amplitude: Double = 0.25
    
    let sampleRate: Double = 44_100.0
    
    private var theta: Double = 0.0
    private let bufferCapacity: AVAudioFrameCount = 512
    private lazy var audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
    
    private func prepareBuffer() -> AVAudioPCMBuffer {
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: bufferCapacity)!
        fillBuffer(buffer)
        return buffer
    }

    private func fillBuffer(_ buffer: AVAudioPCMBuffer) {
        let data = buffer.floatChannelData?[0]
        let numberFrames = buffer.frameCapacity
        var theta = self.theta
        let theta_increment = 2.0 * .pi * frequency / sampleRate

        for frame in 0..<Int(numberFrames) {
            data?[frame] = Float32(sin(theta) * amplitude)

            theta += theta_increment
            if theta > 2.0 * .pi {
                theta -= 2.0 * .pi
            }
        }
        buffer.frameLength = numberFrames
        self.theta = theta
    }

    private func scheduleBuffer() {
        let buffer = prepareBuffer()
        scheduleBuffer(buffer) { [weak self] in
            guard let self = self else { return }
            guard self.isPlaying else { return }

            self.scheduleBuffer()
        }
    }

    func preparePlaying() {
        scheduleBuffer()
        scheduleBuffer()
        scheduleBuffer()
        scheduleBuffer()
    }
}
