//
//  CGFloat+Additions.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 6/25/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import CoreGraphics

extension CGFloat {
    func sign() -> Int {
        return self.sign.rawValue == 1 ? -1 : 1
    }
    
    mutating func limit(lower: CGFloat, upper: CGFloat) {
        if self < lower {
            print("number lower limit reached")
            self = lower
        }
        if self > upper {
            print("number upper limit reached")
            self = upper
        }
    }
}
