//
//  EndpointType.swift
//
//  Created by Djordje Jovic on 03/12/2019.
//  Copyright © 2019 Go Go Encode. All rights reserved.
//

import Alamofire

enum EndpointType {
    
    // MARK: Baud Rate
    case setBaudRate
    case getBaudRate
    
    // MARK: FPS
    case setFPS
    case getFPS
    
    // MARK: GOP
    case setGOP
    case getGOP
    
    // MARK: FPS
    case setQuality
    case getQuality
}

// MARK: - Extensions
// MARK: - EndPointType
extension EndpointType: EndPointTypeProtocol {
    
    // MARK: - Vars & Lets
    
    var baseURL: String {
        switch APIManager.networkEnviroment {
            case .dev: return ""
            case .production: return ""
            case .stage: return ""
        }
    }
    
    var version: String {
        return "/v0_1"
    }
    
    var path: String {
        switch self {
        default:
            return "server.command"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        
        case .setBaudRate:
            return .post
        case .getBaudRate:
            return .get
        case .setFPS:
            return .post
        case .getFPS:
            return .get
        case .setGOP:
            return .post
        case .getGOP:
            return .get
        case .setQuality:
            return .post
        case .getQuality:
            return .get
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        default:
            let loginString = String(format: "%@:%@", "admin", "admin")
            let loginData = loginString.data(using: String.Encoding.utf8)!
            let base64LoginString = loginData.base64EncodedString()
            
            return [
                "Content-Type": "application/x-www-form-urlencoded",
                "Authorization": "Basic \(base64LoginString)"
            ]
        }
    }
    
    var url: URL {
        switch self {
        default:
            return URL(string: "http://" + NeuroRobot.shared.getIpAddress()! + "/" + self.path)!
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        default:
            return URLEncoding.queryString
        }
    }
}
