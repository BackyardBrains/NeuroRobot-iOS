//
//  EndpointType.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 03/12/2019.
//  Copyright © 2019 Go Go Encode. All rights reserved.
//

import Alamofire

protocol EndPointTypeProtocol {
    
    // MARK: - Vars & Lets
    
    var baseURL: String { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var url: URL { get }
    var encoding: ParameterEncoding { get }
    var version: String { get }
}
