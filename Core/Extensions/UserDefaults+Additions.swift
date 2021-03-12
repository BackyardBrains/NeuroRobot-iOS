//
//  UserDefaults+Additions.swift
//
//  Copyright © 2019 Go Go Encode.
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

extension UserDefaults {
    static func set<T>(key: String, value: T?) {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
    static func get<T>(key: String) -> T? {
        return UserDefaults.standard.value(forKeyPath: key) as? T
    }
}
