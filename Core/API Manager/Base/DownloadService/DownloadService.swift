//
//  APIManager.swift
//
//  Copyright © 2020 Go Go Encode.
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation
import Alamofire

/// Downloads song snippets, and stores in local file.
/// Allows cancel, pause, resume download.
class DownloadService: NSObject {
    //
    // MARK: - Variables And Properties
    //
    var activeDownloads: [URL: Download] = [ : ]
    
    /// SearchViewController creates downloadsSession
    var downloadsSession: URLSession!
    
    
    override init() {
        super.init()
        
        let configuration = URLSessionConfiguration.background(withIdentifier:
                                                                "com.raywenderlich.HalfTunes.bgSession")
        downloadsSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    //
    // MARK: - Internal Methods
    //
    func cancelDownload(_ track: EndpointType) {
        guard let download = activeDownloads[track.url] else {
            return
        }
        download.task?.cancel()
        
        activeDownloads[track.url] = nil
    }
    
    func pauseDownload(_ track: EndpointType) {
        guard
            let download = activeDownloads[track.url],
            download.isDownloading
        else {
            return
        }
        
        download.task?.cancel(byProducingResumeData: { data in
            download.resumeData = data
        })
        
        download.isDownloading = false
    }
    
    func resumeDownload(_ track: EndpointType) {
        guard let download = activeDownloads[track.url] else {
            return
        }
        
        if let resumeData = download.resumeData {
            download.task = downloadsSession.downloadTask(withResumeData: resumeData)
        } else {
            download.task = downloadsSession.downloadTask(with: download.track.url)
        }
        
        download.task?.resume()
        download.isDownloading = true
    }
    
    func startDownload(_ track: EndpointType, progress: @escaping ((Double) -> Void), handler: @escaping (_ localURL: URL?, _ remoteURL: URL, _ error: AlertMessage?) -> Void) {
        // 1
        let download = Download(track: track)
        // 2
        download.task = downloadsSession.downloadTask(with: track.url)
        // 3
        download.task?.resume()
        // 4
        download.isDownloading = true
        
        download.progressCallback = progress
        download.callbackHandler = handler
        // 5
        activeDownloads[download.track.url] = download
    }
    
    private func localFilePath(for url: URL) -> URL {
        return FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
    }
}

//
// MARK: - URL Session Delegate
//
extension DownloadService: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}

//
// MARK: - URL Session Download Delegate
//
extension DownloadService: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        
        guard let download = activeDownloads[sourceURL] else { return }
        activeDownloads[sourceURL] = nil
        
        let destinationURL = localFilePath(for: sourceURL)
        
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        var error: AlertMessage?
        if download.progress == 0 {
            error = AlertMessage(title: "Error", body: "Error while downloading a clip")
        } 
        
        DispatchQueue.main.async {
            download.callbackHandler?(destinationURL, download.track.url, error)
            try? fileManager.removeItem(at: destinationURL)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let url = downloadTask.originalRequest?.url, let download = activeDownloads[url] else { return }
        
        var progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        if progress < 0 {
            progress = 0
        } else if progress > 1 {
            progress = 1
        }
        
        download.progress = progress
        DispatchQueue.main.async {
            download.progressCallback?(progress)
        }
    }
}
