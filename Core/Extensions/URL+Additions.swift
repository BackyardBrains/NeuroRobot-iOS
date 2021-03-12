//
//  URL+Additions.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 8/29/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import Foundation

extension URL {
    
    static func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func temporaryDirectory() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }
}
