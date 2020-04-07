//
//  UIWindow+Additions.swift
//  Go Go Encode
//
//  Created by Djordje Jovic on 13/03/2020.
//  Copyright © 2020 Go Go Encode. All rights reserved.
//

import UIKit

extension UIWindow {
    @nonobjc class var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
