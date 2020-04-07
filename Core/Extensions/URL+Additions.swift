//
//  URL+Additions.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 8/29/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import Foundation

extension URL {
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
