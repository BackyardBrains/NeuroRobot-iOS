//
//  Data+Additions.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 03/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import Foundation

extension Data {
    
    func copyBytes<T>(as _: T.Type) -> UnsafeBufferPointer<T> {
        
        return withUnsafeBytes { rawBufferPointer in
            let bufferPointer: UnsafePointer<T> = rawBufferPointer.baseAddress!.assumingMemoryBound(to: T.self)
            return UnsafeBufferPointer(start: bufferPointer, count: count / MemoryLayout<T>.stride)
        }
    }
}
