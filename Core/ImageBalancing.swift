//
//  ImageBalancing.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 12/05/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import Foundation
import Accelerate

@available(iOS 13.0, *)
extension CGImage {
    
    func balance() -> CGImage? {
        
        var err = vImage_Error()
        var _img = vImage_Buffer()
        
        var format = vImage_CGImageFormat(cgImage: self)!
        
        let width = vImagePixelCount(exactly: self.width)!
        let height = vImagePixelCount(exactly: self.height)!
        
        var _dstA = vImage_Buffer()
        var _dstR = vImage_Buffer()
        var _dstG = vImage_Buffer()
        var _dstB = vImage_Buffer()
        
        err = vImageBuffer_InitWithCGImage(&_img, &format, nil, self, UInt32(kvImageNoFlags))
        guard err == .zero else {
            print(String(format: "vImageBuffer_InitWithCGImage error: %ld", err))
            return nil
        }
        
        err = vImageBuffer_Init(&_dstA, height, width, 8 * UInt32(MemoryLayout<__uint8_t>.size), .zero)
        guard err == .zero else {
            print(String(format: "vImageBuffer_Init (alpha) error: %ld", err))
            return nil
        }
        
        err = vImageBuffer_Init(&_dstR, height, width, 8 * UInt32(MemoryLayout<__uint8_t>.size), .zero)
        guard err == .zero else {
            print(String(format: "vImageBuffer_Init (red) error: %ld", err))
            return nil
        }
        
        err = vImageBuffer_Init(&_dstG, height, width, 8 * UInt32(MemoryLayout<__uint8_t>.size), .zero)
        guard err == .zero else {
            print(String(format: "vImageBuffer_Init (green) error: %ld", err))
            return nil
        }
        
        err = vImageBuffer_Init(&_dstB, height, width, 8 * UInt32(MemoryLayout<__uint8_t>.size), .zero)
        guard err == .zero else {
            print(String(format: "vImageBuffer_Init (blue) error: %ld", err))
            return nil
        }
        
        err = vImageConvert_ARGB8888toPlanar8(&_img, &_dstA, &_dstR, &_dstG, &_dstB, .zero)
        guard err == .zero else {
            print(String(format: "vImageConvert_ARGB8888toPlanar8 error: %ld", err))
            return nil
        }
        
        err = vImageEqualization_Planar8(&_dstR, &_dstR, .zero)
        guard err == .zero else {
            print(String(format: "vImageEqualization_Planar8 (red) error: %ld", err))
            return nil
        }
        
        err = vImageEqualization_Planar8(&_dstG, &_dstG, .zero)
        guard err == .zero else {
            print(String(format: "vImageEqualization_Planar8 (green) error: %ld", err))
            return nil
        }
        
        err = vImageEqualization_Planar8(&_dstB, &_dstB, .zero)
        guard err == .zero else {
            print(String(format: "vImageEqualization_Planar8 (blue) error: %ld", err))
            return nil
        }
        
        err = vImageConvert_Planar8toARGB8888(&_dstA, &_dstR, &_dstG, &_dstB, &_img, .zero)
        guard err == .zero else {
            print(String(format: "vImageConvert_Planar8toARGB8888 error: %ld", err))
            return nil
        }
        
        err = vImageContrastStretch_ARGB8888(&_img, &_img, .zero)
        guard err == .zero else {
            print(String(format: "vImageContrastStretch_ARGB8888 error: %ld", err))
            return nil
        }
        
        free(_dstA.data)
        free(_dstR.data)
        free(_dstG.data)
        free(_dstB.data)
        
        func callback(po1: UnsafeMutableRawPointer?, po2: UnsafeMutableRawPointer?) {
            print("callback called")
        }
        
        let userData = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1)
        
        let result = vImageCreateCGImageFromBuffer(&_img, &format, callback, userData, .zero, &err)
        guard err == .zero else {
            print(String(format: "vImageCreateCGImageFromBuffer error: %ld", err))
            return nil
        }

        free(_img.data)

        return result!.takeRetainedValue()
    }
}

////// use this when you need to CIImage* -> CGImageRef
////CIImage *ciImage = [CIImage imageWithCGImage:cgImage];
////
////// use this when you need to CGImageRef -> CIImage*
////CIContext* context = [[CIContext alloc] init];
////CGImageRef cgImage = [context createCGImage:ciImage fromRect:ciImage.extent];
//
//// the algorithm itself, which uses vImage and has to convert to/from it via CGImage
//CGImageRef CreateEqualisedCGImageFromCGImage(CGImageRef original)
//{
//    vImage_Error err;
//    vImage_Buffer _img;
//    vImage_CGImageFormat format = {
//        .bitsPerComponent = 8,
//        .bitsPerPixel = 32,
//        .colorSpace = NULL,
//        .bitmapInfo = (CGBitmapInfo)kCGImageAlphaFirst,
//        .version = 0,
//        .decode = NULL,
//        .renderingIntent = kCGRenderingIntentDefault,
//    };
//
//    CGFloat width = CGImageGetWidth(original);
//    CGFloat height = CGImageGetHeight(original);
//
//    vImage_Buffer _dstA, _dstR, _dstG, _dstB;
//
//    err = vImageBuffer_InitWithCGImage(&_img, &format, NULL, original, kvImageNoFlags);
//    if (err != kvImageNoError)
//        NSLog(@"vImageBuffer_InitWithCGImage error: %ld", err);
//
//    err = vImageBuffer_Init( &_dstA, height, width, 8 * sizeof( uint8_t ), kvImageNoFlags);
//    if (err != kvImageNoError)
//        NSLog(@"vImageBuffer_Init (alpha) error: %ld", err);
//
//    err = vImageBuffer_Init( &_dstR, height, width, 8 * sizeof( uint8_t ), kvImageNoFlags);
//    if (err != kvImageNoError)
//        NSLog(@"vImageBuffer_Init (red) error: %ld", err);
//
//    err = vImageBuffer_Init( &_dstG, height, width, 8 * sizeof( uint8_t ), kvImageNoFlags);
//    if (err != kvImageNoError)
//        NSLog(@"vImageBuffer_Init (green) error: %ld", err);
//
//    err = vImageBuffer_Init( &_dstB, height, width, 8 * sizeof( uint8_t ), kvImageNoFlags);
//    if (err != kvImageNoError)
//        NSLog(@"vImageBuffer_Init (blue) error: %ld", err);
//
//    err = vImageConvert_ARGB8888toPlanar8(&_img, &_dstA, &_dstR, &_dstG, &_dstB, kvImageNoFlags);
//    if (err != kvImageNoError)
//        NSLog(@"vImageConvert_ARGB8888toPlanar8 error: %ld", err);
//
//    err = vImageEqualization_Planar8(&_dstR, &_dstR, kvImageNoFlags);
//    if (err != kvImageNoError)
//        NSLog(@"vImageEqualization_Planar8 (red) error: %ld", err);
//
//    err = vImageEqualization_Planar8(&_dstG, &_dstG, kvImageNoFlags);
//    if (err != kvImageNoError)
//        NSLog(@"vImageEqualization_Planar8 (green) error: %ld", err);
//
//    err = vImageEqualization_Planar8(&_dstB, &_dstB, kvImageNoFlags);
//    if (err != kvImageNoError)
//        NSLog(@"vImageEqualization_Planar8 (blue) error: %ld", err);
//
//    err = vImageConvert_Planar8toARGB8888(&_dstA, &_dstR, &_dstG, &_dstB, &_img, kvImageNoFlags);
//    if (err != kvImageNoError)
//        NSLog(@"vImageConvert_Planar8toARGB8888 error: %ld", err);
//
//    err = vImageContrastStretch_ARGB8888( &_img, &_img, kvImageNoError );
//    if (err != kvImageNoError)
//        NSLog(@"vImageContrastStretch_ARGB8888 error: %ld", err);
//
//    free(_dstA.data);
//    free(_dstR.data);
//    free(_dstG.data);
//    free(_dstB.data);
//
//    CGImageRef result = vImageCreateCGImageFromBuffer(&_img, &format, NULL, NULL, kvImageNoFlags, &err);
//    if (err != kvImageNoError)
//        NSLog(@"vImageCreateCGImageFromBuffer error: %ld", err);
//
//    free(_img.data);
//
//    return result;
//}
