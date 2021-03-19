//
//  AppSettings.swift
//
//  Copyright © 2019 Go Go Encode.
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

final class AppSettings {
    
    static let shared = AppSettings()
    
    private init() { }
    
    var didLogin: Bool {
        get { return UserDefaults.get(key: "didLogin") as Bool? ?? false }
        set { UserDefaults.set(key: "didLogin", value: newValue) }
    }
    
    var isVocalEnabled: Bool {
        get { return UserDefaults.get(key: "isVocalEnabled") as Bool? ?? false }
        set { UserDefaults.set(key: "isVocalEnabled", value: newValue) }
    }
    
    var isBrainAutoDownloadEnabled = false
}
