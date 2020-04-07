//
//  AudioStreamer.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 02/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import Foundation
import AVFoundation

/// Stream audio from audio data transefred via `scheduleData` function.
class AudioStreamer {
    
    private var audioEngine: AVAudioEngine = AVAudioEngine()
    private var audioBufferPlayer: AVAudioPlayerNode = AVAudioPlayerNode()
    
    private var audioFormat: AVAudioFormat
    
    init?(audioFormat: AVAudioFormat) {
        self.audioFormat = audioFormat
        do {
            let mixer = audioEngine.mainMixerNode
            audioEngine.attach(audioBufferPlayer)
            audioEngine.connect(audioBufferPlayer, to: mixer, format: self.audioFormat)
            try audioEngine.start()
            audioBufferPlayer.play()
        } catch let error {
            print(error)
        }
    }
    
    func scheduleData(audioData: Data) {
        guard let audioFileBuffer = audioData.makePCMBuffer(format: audioFormat) else { return }
        audioBufferPlayer.scheduleBuffer(audioFileBuffer)
    }
}
