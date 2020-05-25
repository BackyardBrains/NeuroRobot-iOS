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
    
    func contains(_ substring: String) -> Bool {
        return range(of: substring) != nil
    }
    
    func collapseWhitespace() -> String {
        let parts = components(separatedBy: CharacterSet.whitespacesAndNewlines).filter { !$0.isEmpty }
        return parts.joined(separator: " ")
    }
    
    func clean(_ with: String, allOf: String...) -> String {
        var string = self
        for target in allOf {
            string = string.replacingOccurrences(of: target, with: with)
        }
        return string
    }
    
    func count(_ substring: String) -> Int {
        return components(separatedBy: substring).count - 1
    }
    
    func endsWith(_ suffix: String) -> Bool {
        return hasSuffix(suffix)
    }

    func indexOf(_ substring: String) -> Int? {
        guard let range = range(of: substring) else { return nil }
        return distance(from: startIndex, to: range.lowerBound)
    }
    
    func lastIndexOf(_ target: String) -> Int? {
        guard let range = range(of: target, options: .backwards) else { return nil }
        return distance(from: startIndex, to: range.lowerBound)
    }
    
    func isAlpha() -> Bool {
        for chr in self {
            if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") ) {
                return false
            }
        }
        return true
    }
    
    func isAlphaNumeric() -> Bool {
        let alphaNumeric = CharacterSet.alphanumerics
        return components(separatedBy: alphaNumeric).joined(separator: "").count == 0
    }
    
    func isNumeric() -> Bool {
        return NumberFormatter().number(from: self) != nil
    }
    
    static func random(_ length: Int = 5) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0 ..< length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        
        return randomString
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isUrl() -> Bool {
        let regEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [regEx])
        return predicate.evaluate(with: self)
    }
    
    func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func splitString(_ separator: String) -> [String] {
        return components(separatedBy: separator)
    }
    
    func substring(from: Int, to: Int) -> String {
        let start = index(startIndex, offsetBy: from)
        let end = index(endIndex, offsetBy: -(count - to) + 1)
        let range = start ..< end
        return String(self[range])
    }

    func substring(from: Int) -> String {
        return String(suffix(from))
    }

    func substring(to: Int) -> String {
        return String(prefix(to))
    }
    
    func remove(_ string: String) -> String {
        return replacingOccurrences(of: string, with: "")
    }
    
    func replace(_ string: String, with newString: String) -> String {
        return replacingOccurrences(of: string, with: newString)
    }
    
    var wordCount: Int {
        let regex = try? NSRegularExpression(pattern: "\\w+")
        return regex?.numberOfMatches(in: self, range: NSRange(location: 0, length: self.utf16.count)) ?? 0
    }
    
    func replacingOccurrences(of search: String, with replacement: String, count maxReplacements: Int) -> String {
        var count = 0
        var returnValue = self
        
        while let range = returnValue.range(of: search) {
            returnValue = returnValue.replacingCharacters(in: range, with: replacement)
            count += 1
            
            if count == maxReplacements {
                return returnValue
            }
        }
        
        return returnValue
    }
}
