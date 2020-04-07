//
//  APIManager.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 03/12/2019.
//  Copyright © 2019 Go Go Encode. All rights reserved.
//

import Alamofire

enum NetworkEnvironment {
    case dev
    case production
    case stage
}

class APIManager {
    
    // MARK: - Vars & Lets
    
    private let sessionManager: Session
    static let networkEnviroment: NetworkEnvironment = .dev
    
    private static var sharedApiManager: APIManager = {
        let apiManager = APIManager(sessionManager: Session())
        
        return apiManager
    }()
    
    // MARK: - Accessors
    
    class func shared() -> APIManager {
        return sharedApiManager
    }
    
    // MARK: - Initialization
    
    private init(sessionManager: Session) {
        self.sessionManager = sessionManager
    }
    
    // MARK: - Implementation
    func call<T>(type: EndpointType, params: Parameters? = nil, handler: @escaping (T?, _ error: AlertMessage?)->()) where T: Codable {
        
        self.sessionManager.request(type.url,
                                    method: type.httpMethod,
                                    parameters: params,
                                    encoding: type.encoding,
                                    headers: type.headers).validate().responseJSON { data in
                                        switch data.result {
                                        case .success(_):
                                            if let jsonData = data.data {
                                                let result = try! JSONDecoder().decode(T.self, from: jsonData)
                                                handler(result, nil)
                                            }
                                        case .failure(_):
                                            handler(nil, self.parseApiError(data: data.data))
                                        }
        }
    }
    
    func call(type: EndpointType, params: Parameters? = nil, handler: @escaping (_ json: [String: Any]?, _ error: AlertMessage?)->()) {
        
        self.sessionManager.request(type.url,
                                    method: type.httpMethod,
                                    parameters: params,
                                    encoding: type.encoding,
                                    headers: type.headers).validate().responseJSON { data in
                                        switch data.result {
                                        case .success(let value):
                                            if let json = value as? [String: Any] {
                                               handler(json, nil)
                                            } else {
                                               handler(nil, nil)
                                            }
                                        case .failure(_):
                                            handler(nil, self.parseApiError(data: data.data))
                                        }
        }
    }
    
    private func parseApiError(data: Data?) -> AlertMessage {
        if let jsonData = data, let error = try? JSONDecoder().decode(ErrorObject.self, from: jsonData) {
            return AlertMessage(title: APIConstants.errorAlertTitle, body: error.key ?? error.message)
        }
        return AlertMessage(title: APIConstants.errorAlertTitle, body: APIConstants.genericErrorMessage)
    }
    
    private func parseApiError(error: Error?) -> AlertMessage {
        if let error = error {
            return AlertMessage(title: APIConstants.errorAlertTitle, body: error.localizedDescription)
        }
        return AlertMessage(title: APIConstants.errorAlertTitle, body: APIConstants.genericErrorMessage)
    }
}
