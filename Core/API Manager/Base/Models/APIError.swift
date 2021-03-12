//
//  APIError.swift
//
//  Copyright © 2019 Go Go Encode.
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

class APIError: Codable {
    
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case message = "ExceptionMessage"
    }
}
