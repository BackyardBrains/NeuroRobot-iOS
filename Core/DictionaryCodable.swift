//
//  DictionaryCodable.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 26/02/2020.
//  Copyright © 2020 Go Go Encode. All rights reserved.
//

import Foundation

class DictionaryCodable {
    private init() {}
    
    static func convert<T: Decodable>(dict: [String: Any], to objectType: T.Type) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        return try convert(data: data, to: objectType)
    }
    
    static func convert<T: Decodable>(data: Data, to objectType: T.Type) throws -> T {
        let object = try JSONDecoder().decode(objectType, from: data)
        return object
    }
    
    static func convert<T: Codable>(object: T) -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(object)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            return json
        } catch {
            return nil
        }
    }
    
    static func printJSON(json: [String: Any]) {
        print(String(json: json))
    }
}
