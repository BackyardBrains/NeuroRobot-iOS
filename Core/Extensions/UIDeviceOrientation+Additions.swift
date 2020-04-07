//
//  UIDeviceOrientation+Additions.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 17/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import UIKit.UIDevice
import AVFoundation.AVCaptureSession

extension UIDeviceOrientation {
    func videoOrientation() -> AVCaptureVideoOrientation {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .portrait
        }
    }
}
