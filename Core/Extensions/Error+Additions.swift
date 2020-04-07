//
//  Error+Additions.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 14/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import Foundation

extension Error {
    
    func asNSError() -> NSError {
        return self as NSError
    }
    
    var code: Int {
        return asNSError().code
    }
}
