//
//  CoreGraphics+Additions.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 25/04/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}

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

extension CGSize {
    init(_ size: CGFloat) {
        self.init(width: size, height: size)
    }
}
