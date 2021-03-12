//
//  NeurorobotImage.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 9/29/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import UIKit

class NeurorobotImage {
    
    static func make(imagePointer: UnsafePointer<UInt8>, width: Int, height: Int) -> (UIImage, UIImage)? {
        guard let cgImage = convert(imagePointer: imagePointer, width: width, height: height) else { return nil }
        guard let images = makeSquareImages(cgImage: cgImage, width: width, height: height) else { return nil }
        return images
    }
    
    static func makeSquareImages(image: UIImage) -> (UIImage, UIImage)? {
        return makeSquareImages(cgImage: image.cgImage!, width: Int(image.size.width), height: Int(image.size.height))
    }
    
    private static func makeSquareImages(cgImage: CGImage, width: Int, height: Int) -> (UIImage, UIImage)? {
        
        var y: Int = 0
        var size = height
        
        if height > width {
            size = Int(Float(width) * 0.8)
            y = Int((height - size) / 2)
        }
        
        let leftImgFrame = CGRect(x: 0, y: y, width: size, height: size)
        let rightImgFrame = CGRect(x: width - size, y: y, width: size, height: size)
        
        guard let left = cgImage.cropping(to: leftImgFrame) else { return nil }
        guard let right = cgImage.cropping(to: rightImgFrame) else { return nil }
        
        return (UIImage(cgImage: left), UIImage(cgImage: right))
    }
    
    private static func convert(imagePointer: UnsafePointer<UInt8>, width: Int, height: Int) -> CGImage? {
        let imagePointerMutate = UnsafeMutablePointer(mutating: imagePointer)
        
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        
        let bitsPerComponent = 8
        let bytesPerPixel = 3
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).union(.byteOrderMask)
        let releaseMaskImagePixelData: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
            // https://developer.apple.com/reference/coregraphics/cgdataproviderreleasedatacallback
            // N.B. 'CGDataProviderRelease' is unavailable: Core Foundation objects are automatically memory managed
            return
        }
        
        let providerRef = CGDataProvider(dataInfo: nil, data: imagePointerMutate, size: totalBytes, releaseData: releaseMaskImagePixelData)
        guard let imageRef = CGImage(width: width,
                                     height: height,
                                     bitsPerComponent: bitsPerComponent,
                                     bitsPerPixel: bitsPerPixel,
                                     bytesPerRow: bytesPerRow,
                                     space: colorSpaceRef,
                                     bitmapInfo: bitmapInfo,
                                     provider: providerRef!,
                                     decode: nil,
                                     shouldInterpolate: false,
                                     intent: CGColorRenderingIntent.defaultIntent) else { return nil }
        return imageRef
    }
    
//    func pixelValuesFromImage(image: UIImage) -> ([UInt8]?, width: Int, height: Int) {
////        var width = 0
////        var height = 0
////        var pixelValues: [UInt8]?
////
////        width = imageRef.width
////        height = imageRef.height
////        let bitsPerComponent = imageRef.bitsPerComponent
////        let bytesPerRow = imageRef.bytesPerRow
////        let totalBytes = height * bytesPerRow
////
////        let colorSpace = CGColorSpaceCreateDeviceGray()
////        //        let colorSpace = CGColorSpaceCreateDeviceRGB()
////        let buffer = [UInt8](repeating: 0, count: totalBytes)
////        UnsafeMutablePointer<UInt8>(
////        let mutablePointer = UnsafeMutablePointer<UInt8>(buffer)
////
////        let contextRef = CGBitmapContextCreate(mutablePointer, width, height, bitsPerComponent, bytesPerRow, colorSpace, 0)
////        CGContextDrawImage(contextRef, CGRectMake(0.0, 0.0, CGFloat(width), CGFloat(height)), imageRef)
////
////        let bufferPointer = UnsafeBufferPointer<UInt8>(start: mutablePointer, count: totalBytes)
////        pixelValues = Array<UInt8>(bufferPointer)
////
////        return (pixelValues, width, height)
//        
//        
//        let colorSpace = image.cgImage!.colorSpace
//        let cols: CGFloat = image.size.width;
//        let rows: CGFloat = image.size.height;
//
////        cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
//
//        let contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
//            cols,                       // Width of bitmap
//            rows,                       // Height of bitmap
//            8,                          // Bits per component
//            cvMat.step[0],              // Bytes per row
//            colorSpace,                 // Colorspace
//            kCGImageAlphaNoneSkipLast |
//            kCGBitmapByteOrderDefault); // Bitmap info flags
//
//        CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
//        CGContextRelease(contextRef);
//    }
}
