//
//  UIImage+Additions.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 14/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import UIKit
import CoreMedia.CMSampleBuffer

extension UIImage {
    convenience init?(sampleBuffer: CMSampleBuffer) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        CVPixelBufferLockBaseAddress(imageBuffer, [])

        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo:CGBitmapInfo = [.byteOrder32Little, CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)]
        
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return nil }

        guard let quartzImage = context.makeImage() else { return nil }
        CVPixelBufferUnlockBaseAddress(imageBuffer, [])

        self.init(cgImage: quartzImage)
    }
    
    func fixImageOrientation() -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        self.draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
    
    func unsafePointer() -> UnsafePointer<UInt8>? {
        let data = cgImage?.dataProvider?.data as Data?
        let bufferPointer = data?.copyBytes(as: UInt8.self)
        guard let pointer = bufferPointer?.baseAddress else { return nil }
        return pointer
    }
}
