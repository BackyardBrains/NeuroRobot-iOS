//
//  FilesHandler.swift
//
//  Copyright © 2019 Go Go Encode.
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

class FilesHandler: NSObject {
    
    @objc static let shared = FilesHandler()
    
    private let fileManager = FileManager()
    
    private var progressCallback: ((Double) -> Void)?
    
    override private init() { }
    
    @discardableResult
    func copyFile(path: URL, to directory: URL = URL.temporaryDirectory(), directoryName: String? = nil) -> (Bool, URL?) {
        var directoryURL = directory
        if directoryName != nil {
            directoryURL.appendPathComponent(directoryName!)
            guard let _ = try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil) else { return (false, nil) }
        }
        
        directoryURL.appendPathComponent(path.path.splitString("/").last!)
        
        guard let _ = try? fileManager.copyItem(at: path, to: directoryURL) else { return (false, nil) }
        return (true, directoryURL)
    }
    
    @discardableResult
    func write(data: String, to dataURL: URL) -> Bool {
        if let directoryPath = dataURL.path.splitInReverseWithFirstOccuranceOf(separator: "/")?.first, !fileManager.fileExists(atPath: directoryPath) {
            guard let _ = try? fileManager.createDirectory(at: URL(fileURLWithPath: directoryPath), withIntermediateDirectories: false, attributes: nil) else { return false }
        }
        do {
            try data.write(to: dataURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error {
            print(error)
            return false
        }
        
        return true
    }
    
    @discardableResult
    @objc func remove(url: URL) -> Bool {
        
        do {
            try fileManager.removeItem(at: url)
        } catch let error {
            print(error)
            return false
        }
        
        return true
    }
    
    @objc func cleanDocoumentsFolder() {
        let documentsDirectoryPath = URL.documentsDirectory().path
        guard let files = try? fileManager.contentsOfDirectory(atPath: documentsDirectoryPath) else { return }
        files.forEach { (path) in
            let _ = try? fileManager.removeItem(atPath: documentsDirectoryPath + "/" + path)
        }
    }
    
    @objc func cleanTempFolder() {
        let directoryPath = URL.temporaryDirectory().path
        guard let files = try? fileManager.contentsOfDirectory(atPath: directoryPath) else { return }
        files.forEach { (path) in
            let _ = try? fileManager.removeItem(atPath: directoryPath + "/" + path)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "fractionCompleted"{
            let progress = object as! Progress
            print("fractions: \(progress.fractionCompleted)")
            progressCallback?(progress.fractionCompleted)
        }
    }
}
