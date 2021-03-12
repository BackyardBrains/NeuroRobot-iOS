//
//  APIManager.swift
//
//  Copyright © 2020 Go Go Encode.
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

class Download {
    //
    // MARK: - Variables And Properties
    //
    var isDownloading = false
    var progressCallback: ((Double) -> Void)?
    var callbackHandler: ((_ localURL: URL?, _ remoteURL: URL, _ error: AlertMessage?) -> Void)? 
    var resumeData: Data?
    var task: URLSessionDownloadTask?
    var track: EndpointType
    var progress: Double = 0
    
    //
    // MARK: - Initialization
    //
    init(track: EndpointType) {
        self.track = track
    }
}
