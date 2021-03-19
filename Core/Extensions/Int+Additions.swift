//
//  UserDefaults+Additions.swift
//
//  Copyright © 2021 Go Go Encode.
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

extension Int {
    
    /// Returns first digit of given number
    /// - Returns: first digit of given number
    func firstDigit() -> Int {
        let firstLetter = String(self).first!
        let firstNumberString = String(firstLetter)
        let firstNumber = Int(firstNumberString)!
        return firstNumber
    }
}
