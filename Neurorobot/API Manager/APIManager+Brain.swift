//
//  APIManager+Brain.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 9.3.21..
//  Copyright © 2021 Backyard Brains. All rights reserved.
//

import Foundation

extension APIManager {
    
    // Dispatch group
    private static let group = DispatchGroup()
    
    func getBrains(callback: ((URL) -> Void)? = nil) {
        
        let url1 = "https://github.com/BackyardBrains/NeuroRobot/raw/master/NeuroRobotToolbox/Brains"
        
        func urlToDownloadBrain(brainName: String) -> URL {
            let baseURL = "https://github.com/BackyardBrains/NeuroRobot/blob/master/NeuroRobotToolbox/Brains"
            return URL(string: baseURL + "/" + brainName + "?raw=true")!
        }
        
        APIManager.shared().download(type: .getBrains(url1)) { (progress, url) in
            print(progress)
        } handler: { [weak self] (htmlLocalURL, url, message) in
            
            guard let htmlPath = htmlLocalURL else { return }
            guard let htmlString = try? String(contentsOfFile: htmlPath.path) else { return }
            guard let regex = try? NSRegularExpression(pattern: "title=\"[A-Za-z0-9 ]*[.]{1}mat", options: .caseInsensitive) else { return }
            let matches = regex.matches(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.count))
            let matchedStrings: [String] = matches.map {
                let stringNew = (htmlString as NSString).substring(with: $0.range)
                return stringNew as String
            }
            let urls: [URL] = matchedStrings.compactMap({
                let splited = $0.splitString("\"")
                guard splited.count >= 2 else { return nil }
                let brainName = splited.last!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                return urlToDownloadBrain(brainName: brainName)
            })
            
            var localURLs = [URL]()
            urls.forEach { (url) in
                APIManager.group.enter()
                self?.getBrain(url: url, callback: { (localURL) in
                    localURLs.append(localURL)
                })
            }
            
            APIManager.group.notify(queue: .main) {
                let brainsDirectoryURL = URL.documentsDirectory().appendingPathComponent("Brains")
                FilesHandler.shared.remove(url: brainsDirectoryURL)
                localURLs.forEach { (url) in
                    FilesHandler.shared.copyFile(path: url, to: URL.documentsDirectory(), directoryName: "Brains")
                    FilesHandler.shared.remove(url: url)
                }
                FilesHandler.shared.remove(url: htmlLocalURL!)
                
                callback?(brainsDirectoryURL)
            }
        }
    }
    
    private func getBrain(url: URL, callback: @escaping ((URL) -> Void)) {
        APIManager.shared().download(type: .getBrain(url.absoluteString)) { (progress, url) in
            
        } handler: { (localURL, url, message) in
            APIManager.group.leave()
            guard localURL != nil else { return }
            callback(localURL!)
        }
    }
}
