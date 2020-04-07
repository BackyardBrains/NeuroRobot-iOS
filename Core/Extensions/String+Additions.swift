//
//  String+Additions.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 14/02/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import Foundation

extension String {
    func makeCString() -> UnsafeMutablePointer<Int8> {
        let count = self.utf8.count + 1
        let result = UnsafeMutablePointer<Int8>.allocate(capacity: count)
        self.withCString { (baseAddress) in
            result.initialize(from: baseAddress, count: count)
        }
        return result
    }
    
    init(jsonData: Data) {
        self = String(data: jsonData, encoding: String.Encoding.utf8) ?? ""
    }
    
    init(json: [String: Any]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            self = String(jsonData: data)
        } catch let error {
            print("Cannot convert to JSON string: " + error.localizedDescription)
            self = ""
        }
    }
}
