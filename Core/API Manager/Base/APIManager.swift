//
//  APIManager.swift
//
//  Copyright © 2019 Go Go Encode.
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Alamofire

enum APIManagerType {
    case `default`
    case alamofire
}

class APIManager: NSObject {
    
    // MARK: - Vars & Lets
    
    typealias ResponseCallbck = (_ json: [String: Any]?, _ error: AlertMessage?) -> Void
    private let sessionManager: Session?
    private var sessionManagerDefault: URLSession?
    
    private let kMessageKey = "kMessage"
    private let kSuccessMessage = "Success"
    private let service = DownloadService()
    
    private static let dependencyType: APIManagerType = .alamofire
    private static var sharedApiManager: APIManager = {
        
        switch dependencyType {
        case .default:
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 60
            configuration.timeoutIntervalForResource = 60
            
            return APIManager(configuration: configuration)
        case .alamofire:
            return APIManager(sessionManager: Session())
        }
    }()
    
    // MARK: - Accessors
    
    class func shared() -> APIManager {
        return sharedApiManager
    }
    
    // MARK: - Initialization
    
    private init(sessionManager: Session) {
        self.sessionManager = sessionManager
        self.sessionManagerDefault = nil
        super.init()
    }
    
    private init(configuration: URLSessionConfiguration) {
        self.sessionManager = nil
        self.sessionManagerDefault = nil
        super.init()
        
        let session = URLSession(configuration: configuration)
        self.sessionManagerDefault = session
    }
    
    // MARK: - Implementation
    func call<T>(type: EndpointType, params: Parameters? = nil, handler: @escaping (T?, _ error: AlertMessage?) -> Void) where T: Codable {
        
        self.sessionManager?.request(type.url,
                                     method: type.httpMethod,
                                     parameters: params,
                                     encoding: type.encoding,
                                     headers: type.headers).validate().responseJSON { [weak self] data in
                                        switch data.result {
                                        case .success(_):
                                            if let jsonData = data.data {
                                                let result = try! JSONDecoder().decode(T.self, from: jsonData)
                                                handler(result, nil)
                                            }
                                        case .failure(_):
                                            if let statusCode = data.response?.statusCode, (200..<300).contains(statusCode) {
                                                handler(nil, nil)
                                                return
                                            }
                                            
                                            handler(nil, self?.parseApiError(data: data.data))
                                        }
                                     }
    }
    
    func call(type: EndpointType, params: Parameters? = nil, handler: ResponseCallbck? = nil) {
        
        self.sessionManager?.request(type.url,
                                     method: type.httpMethod,
                                     parameters: params,
                                     encoding: type.encoding,
                                     headers: type.headers).validate().responseJSON { [weak self] data in
                                        switch data.result {
                                        case .success(_):
                                            self?.parseSuccess(data: data, callback: handler)
                                        case .failure(_):
                                            self?.parseFailure(data: data, callback: handler)
                                        }
                                     }
    }
    
    func upload(type: EndpointType, data: Data, handler: ResponseCallbck? = nil) {
        AF.upload(data,
                  to: type.url,
                  method: .put,
                  headers: type.headers).responseJSON { [weak self] data in
                    switch data.result {
                    case .success(_):
                        self?.parseSuccess(data: data, callback: handler)
                    case .failure(_):
                        self?.parseFailure(data: data, callback: handler)
                    }
                  }
    }
    
    func upload(type: EndpointType, data: Data, uploadProgress: @escaping Alamofire.Request.ProgressHandler, downloadProgress: @escaping Alamofire.Request.ProgressHandler, handler: @escaping (Data?, _ error: AlertMessage?) -> Void) {
        AF.upload(data,
                  to: type.url,
                  method: .put,
                  headers: type.headers).uploadProgress(closure: uploadProgress).downloadProgress(closure: downloadProgress).response(completionHandler: { (response) in
                    //here you able to access the DefaultDownloadResponse
                    //result closure
                    var error: AlertMessage?
                    if let afError = response.error {
                        error = AlertMessage(title: "", body: afError.errorDescription!)
                    }
                    
                    print(response)
                    
                    
                    handler(response.data, error)
                  })
    }
    
    func download(type: EndpointType, params: Parameters? = nil, progress: @escaping ((Double, URL) -> Void), handler: @escaping (_ localURL: URL?, _ remoteURL: URL, _ error: AlertMessage?) -> Void) {
        
        switch APIManager.dependencyType {
        case .default:
            service.startDownload(type, progress: { (progressInner) in
                progress(progressInner, type.url)
            }, handler: handler)
        case .alamofire:
            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, options: .removePreviousFile)
            
            AF.download(
                type.url,
                method: type.httpMethod,
                parameters: params,
                encoding: type.encoding,
                headers: nil,
                to: destination).downloadProgress { (progress2) in
                    progress(progress2.fractionCompleted, type.url)
                }.response(completionHandler: { (response) in
                    
                    var error: AlertMessage?
                    if let statusCode = response.response?.statusCode, (200..<300).contains(statusCode) {
                        // Success
                    } else if let afError = response.error {
                        // Fail
                        error = AlertMessage(title: "", body: afError.errorDescription!)
                    }
                    handler(response.fileURL, type.url, error)
                    
                    print(response)
                })
        }
    }
}

private extension APIManager {
    // MARK: - Parsing rasponse
    
    private func parseSuccess(data: AFDataResponse<Any>, callback: ResponseCallbck?) {
        guard case let .success(value) = data.result else { fatalError() }
        
        if let json = value as? [String: Any] {
            callback?(json, nil)
        } else {
            createSuccessResponse(callback: callback)
        }
    }
    
    private func parseFailure(data: AFDataResponse<Any>, callback: ResponseCallbck?) {
        guard case let .failure(error) = data.result else { fatalError() }
        
        if let statusCode = data.response?.statusCode, (200..<300).contains(statusCode) {
            createSuccessResponse(from: error, callback: callback)
            return
        }
        
        callback?(nil, parseApiError(data: data.data))
    }
    
    // MARK: - Generating response
    
    private func parseApiError(data: Data?) -> AlertMessage {
        if let jsonData = data, let error = try? JSONDecoder().decode(APIError.self, from: jsonData) {
            return AlertMessage(title: APIConstants.errorAlertTitle, body: error.message)
        }
        return AlertMessage(title: APIConstants.errorAlertTitle, body: APIConstants.genericErrorMessage)
    }
    
    private func parseApiError(error: Error?) -> AlertMessage {
        if let error = error {
            return AlertMessage(title: APIConstants.errorAlertTitle, body: error.localizedDescription)
        }
        return AlertMessage(title: APIConstants.errorAlertTitle, body: APIConstants.genericErrorMessage)
    }
    
    private func createSuccessResponse(from error: Alamofire.AFError? = nil, callback: ResponseCallbck?) {
        let successJSON = [kMessageKey: kSuccessMessage]
        callback?(successJSON, nil)
    }
}
