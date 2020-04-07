//
//  CGPoint+Additions.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 24/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}
