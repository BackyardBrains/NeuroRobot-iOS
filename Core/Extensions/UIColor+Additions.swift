//
//  UIColor+Additions.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 19/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1) {
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: a)
    }
}
