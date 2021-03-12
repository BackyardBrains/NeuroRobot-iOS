//
//  Data+CMSampleBuffer.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 26.1.21..
//  Copyright © 2021 Backyard Brains. All rights reserved.
//

import Foundation
import CoreMedia

extension Data {
    init(sampleBuffer: CMSampleBuffer) {
        var audioBufferList = AudioBufferList()
        self = Data()
        var blockBuffer : CMBlockBuffer?

        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, bufferListSizeNeededOut: nil, bufferListOut: &audioBufferList, bufferListSize: MemoryLayout<AudioBufferList>.size, blockBufferAllocator: nil, blockBufferMemoryAllocator: nil, flags: 0, blockBufferOut: &blockBuffer)

        let buffers = UnsafeBufferPointer<AudioBuffer>(start: &audioBufferList.mBuffers, count: Int(audioBufferList.mNumberBuffers))

        for audioBuffer in buffers {
            let frame = audioBuffer.mData?.assumingMemoryBound(to: UInt8.self)
            self.append(frame!, count: Int(audioBuffer.mDataByteSize))
        }
    }
}
