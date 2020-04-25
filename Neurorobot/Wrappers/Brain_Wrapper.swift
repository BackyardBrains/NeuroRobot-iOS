//
//  Brain_Wrapper.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 8/28/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import Foundation
import CoreGraphics

enum BrainError: Error {
    case videoSizeNotSet
    case cannotLoadBrain
}

protocol BrainDelegate: class {
    func brainStopped()
    func brainStarted()
}

final class Brain
{
    public var isRunning = false
    
    weak var delegate: BrainDelegate?
    
    private var brainObject: UnsafeRawPointer?
    private var isVideoSizeSet = false
    
    static func availableBrains() -> [String] {
        var brainPaths = [String]()
        
        if let pathToDirectory = Bundle.main.path(forResource: "Brains", ofType: nil) {
            if var fileNames = try? FileManager.default.contentsOfDirectory(atPath: pathToDirectory) {
                fileNames.sort()
                for brainName in fileNames {
                    brainPaths.append(brainName.replacingOccurrences(of: ".mat", with: ""))
                }
            }
        }
        return brainPaths
    }
    
    static func availableBrainPaths() -> [String] {
        var brainPaths = [String]()
        
        if let pathToDirectory = Bundle.main.path(forResource: "Brains", ofType: nil) {
            if var fileNames = try? FileManager.default.contentsOfDirectory(atPath: pathToDirectory) {
                fileNames.sort()
                for brainName in fileNames {
                    brainPaths.append(pathToDirectory + "/" + brainName)
                }
            }
        }
        
        return brainPaths
    }
    
    init() {
        brainObject = brain_Init()
    }
    
    func setVideoSize(width: Int, height: Int) {
        guard let brainObject = brainObject else { return }
        brain_setVideoSize(brainObject, Int32(width), Int32(height))
        isVideoSizeSet = true
    }
    
    func load(pathToMatFile: String) throws {
        guard let brainObject = brainObject else { return }
        guard isVideoSizeSet else { throw BrainError.videoSizeNotSet }
        
//        let errorPtr = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        let pathToMatFilePointer = UnsafeMutablePointer<Int8>(mutating: (pathToMatFile as NSString).utf8String)
        
        let error = brain_load(brainObject, pathToMatFilePointer)
        
//        let error = Int(errorPtr.pointee)
//        errorPtr.deallocate()
        if error != 0 {
            throw BrainError.cannotLoadBrain
        }
    }
    
    func start() {
        guard let brainObject = brainObject else { return }
        
        isRunning = true
        brain_start(brainObject)
        delegate?.brainStarted()
    }
    
    func stop() {
        guard let brainObject = brainObject else { return }
        
        isRunning = false
        brain_stop(brainObject)
        delegate?.brainStopped()
    }
    
    deinit {
        guard let brainObject = brainObject else { return }
        brain_deinit(brainObject)
    }
    
    func setDistance(distance: Int32) {
        guard let brainObject = brainObject else { return }
        
        brain_setDistance(brainObject, distance)
    }
    
    func setVideo(videoFrame: UnsafePointer<UInt8>) {
        guard let brainObject = brainObject else { return }
        
        brain_setVideo(brainObject, videoFrame);
    }
    
    func setAudio(audioData: Data, sampleRate: Int) {
        guard let brainObject = brainObject else { return }
        
        let foo = audioData.copyBytes(as: Float.self)
        
        brain_setAudio(brainObject, foo.baseAddress!, Int32(foo.count), Int32(sampleRate))
    }
    
    func getLeftTorque() -> Int {
        guard let brainObject = brainObject else { return 0 }
        
        return Int(brain_getLeftTorque(brainObject));
    }
    
    func getRightTorque() -> Int {
        guard let brainObject = brainObject else { return 0 }
        
        return Int(brain_getRightTorque(brainObject));
    }
    
    func getSpeakerTone() -> Int {
        guard let brainObject = brainObject else { return 0 }
        
        return Int(brain_getSpeakerTone(brainObject));
    }
    
    func getNeuronValues() -> [Double] {
        guard let brainObject = brainObject else { return [Double]() }
        
        let numberOfNeuronsPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        let neuronValuesPointer = brain_getNeuronValues(brainObject, numberOfNeuronsPointer)
        let neuronValuesBufferPointer = UnsafeBufferPointer(start: neuronValuesPointer, count: Int(numberOfNeuronsPointer.pointee))
        
        numberOfNeuronsPointer.deallocate()
        neuronValuesPointer?.deallocate()
        
        let neuronValues = Array(neuronValuesBufferPointer)
        return neuronValues
    }
    
    func getFiringNeurons() -> [Bool] {
        guard let brainObject = brainObject else { return [Bool]() }
        
        let numberOfNeuronsPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        let neuronValuesPointer = brain_getFiringNeurons(brainObject, numberOfNeuronsPointer)
        let neuronValuesBufferPointer = UnsafeBufferPointer(start: neuronValuesPointer, count: Int(numberOfNeuronsPointer.pointee))
        
        numberOfNeuronsPointer.deallocate()
        
        let neuronValues = Array(neuronValuesBufferPointer)
        return neuronValues
    }
    
    func getPosition() -> [Coordinate]? {
        guard let brainObject = brainObject else { return nil }
        
        let numberOfNeuronsPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        
        let xValuesPointer = brain_getX(brainObject, numberOfNeuronsPointer)
        let yValuesPointer = brain_getY(brainObject, numberOfNeuronsPointer)
        
        let numberOfNeurons = Int(numberOfNeuronsPointer.pointee)
        numberOfNeuronsPointer.deallocate()
        
        let xBufferPointer = UnsafeBufferPointer(start: xValuesPointer, count: numberOfNeurons)
        let yBufferPointer = UnsafeBufferPointer(start: yValuesPointer, count: numberOfNeurons)
        
        let xValues = Array(xBufferPointer)
        let yValues = Array(yBufferPointer)
        
        xValuesPointer?.deallocate()
        yValuesPointer?.deallocate()
        
        var coordinates = [Coordinate]()
        for i in 0..<numberOfNeurons {
            var x = CGFloat(xValues[i])
            var y = CGFloat(yValues[i])
            x.limit(lower: -3, upper: 3)
            y.limit(lower: -3, upper: 3)
            
            // upper right is positive quadrant
            
            coordinates.append(Coordinate(x: x, y: y))
        }
        
        return coordinates
    }
    
    func getInnerConnections() -> [[Double]]? {
        guard let brainObject = brainObject else { return nil }
        
        let numberOfNeuronsPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        
        let connectionsPointer = brain_getConnectToMe(brainObject, numberOfNeuronsPointer)
        
        let numberOfNeurons = Int(numberOfNeuronsPointer.pointee)
        numberOfNeuronsPointer.deallocate()
        
        let xBufferPointer = UnsafeBufferPointer(start: connectionsPointer, count: numberOfNeurons)
        let xValues = Array(xBufferPointer)
        
        var connections = [[Double]]()
        for i in 0..<xValues.count {
            let yBufferPointer = UnsafeBufferPointer(start: xValues[i], count: numberOfNeurons)
            let yValues = Array(yBufferPointer)
            
            connections.append(yValues)
        }
        connectionsPointer?.deallocate()
        
        return connections
    }
    
    func getOuterConnections() -> [[Double]]? {
        guard let brainObject = brainObject else { return nil }
        
        let numberOfNeuronsPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        let numberOfConnectionsPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        
        let connectionsPointer = brain_getContacts(brainObject, numberOfNeuronsPointer, numberOfConnectionsPointer)
        
        let numberOfNeurons = Int(numberOfNeuronsPointer.pointee)
        numberOfNeuronsPointer.deallocate()
        let numberOfConnections = Int(numberOfConnectionsPointer.pointee)
        numberOfConnectionsPointer.deallocate()
        
        let xBufferPointer = UnsafeBufferPointer(start: connectionsPointer, count: numberOfNeurons)
        let xValues = Array(xBufferPointer)
        
        var connections = [[Double]]()
        for i in 0..<xValues.count {
            let yBufferPointer = UnsafeBufferPointer(start: xValues[i], count: numberOfConnections)
            let yValues = Array(yBufferPointer)
            
            connections.append(yValues)
        }
        connectionsPointer?.deallocate()
        
        return connections
    }
}
