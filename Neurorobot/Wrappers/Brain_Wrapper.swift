//
//  Brain_Wrapper.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 8/28/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit.UIColor

enum BrainError: Error {
    case videoSizeNotSet
    case cannotLoadBrain
}

protocol BrainDelegate: class {
    func brainStopped()
    func brainStarted()
}

/// Bridge for ColorSpace enum
enum BrainColorSpace: Int32 {
    case rgb = 0
    case bgra
}

final class Brain
{
    public var isRunning = false
    
    weak var delegate: BrainDelegate?
    
    private var brainObject: UnsafeRawPointer?
    private var isVideoSizeSet = false
    
    static let brainsDirectory = URL.documentsDirectory().appendingPathComponent("Brains")
    
    static func availableBrains() -> [String]? {
        guard let fileNames = getBrainPaths() else { return nil }
        let brainPaths = fileNames.map({ $0.replace(".mat", with: "") })
        
        return brainPaths
    }
    
    static func availableBrainPaths() -> [String]? {
        guard let fileNames = getBrainPaths() else { return nil }
        let brainPaths = fileNames.map({ brainsDirectory.path + "/" + $0 })
        
        return brainPaths
    }
    
    static private func getBrainPaths() -> [String]? {
        guard var fileNames = try? FileManager.default.contentsOfDirectory(atPath: brainsDirectory.path) else { return nil }
        fileNames.sort()
        return fileNames
    }
    
    init(colorSpace: BrainColorSpace) {
        brainObject = brain_Init(colorSpace.rawValue)
    }
    
    func setVideoSize(width: Int, height: Int) {
        guard let brainObject = brainObject else { return }
        brain_setVideoSize(brainObject, Int32(width), Int32(height))
        isVideoSizeSet = true
    }
    
    func load(pathToMatFile: String) throws {
        guard let brainObject = brainObject else { return }
        guard isVideoSizeSet else { throw BrainError.videoSizeNotSet }
        
        let pathToMatFilePointer = UnsafeMutablePointer<Int8>(mutating: (pathToMatFile as NSString).utf8String)
        
        let error = brain_load(brainObject, pathToMatFilePointer)
        
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
    
    /// Obtains tone frequency.
    /// Sometimes is used first digit (of frequency) as index of audio samples stored in Sounds folder. It depends on AppSettings.shared.isVocalEnabled.
    ///
    /// - Returns: Audio frequency
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
    
    func getDaConnectToMe() -> [[[Double]]]? {
        guard let brainObject = brainObject else { return nil }
        
        let numberOfNeuronsPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        let numberOfParams1Pointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        let numberOfParams2Pointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        
        let valuesPointer = brain_getDaConnectToMe(brainObject, numberOfNeuronsPointer, numberOfParams1Pointer, numberOfParams2Pointer)
        
        let numberOfNeurons = Int(numberOfNeuronsPointer.pointee)
        numberOfNeuronsPointer.deallocate()
        let numberOfParams1 = Int(numberOfParams1Pointer.pointee)
        numberOfParams1Pointer.deallocate()
        let numberOfParams2 = Int(numberOfParams2Pointer.pointee)
        numberOfParams2Pointer.deallocate()
        
        let arrayPointer1 = UnsafeBufferPointer(start: valuesPointer, count: numberOfNeurons)
        let colorValues = Array(arrayPointer1)
        
        var values = [[[Double]]]()
        for i in 0..<colorValues.count {
            let arrayPointer2 = UnsafeBufferPointer(start: colorValues[i], count: numberOfParams1)
            let params1 = Array(arrayPointer2)
            
            var paramValues = [[Double]]()
            
            for j in 0..<params1.count {
                let arrayPointer3 = UnsafeBufferPointer(start: params1[j], count: numberOfParams2)
                let params2 = Array(arrayPointer3)
                
                paramValues.append(params2)
            }
            
            values.append(paramValues)
        }
        valuesPointer?.deallocate()
        
        return values
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
    
    func getColors() -> [UIColor]? {
        guard let brainObject = brainObject else { return nil }
        
        let numberOfNeuronsPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        let numberOfColorsPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        
        let colorsPointer = brain_getColors(brainObject, numberOfNeuronsPointer, numberOfColorsPointer)
        
        let numberOfNeurons = Int(numberOfNeuronsPointer.pointee)
        numberOfNeuronsPointer.deallocate()
        let numberOfColors = Int(numberOfColorsPointer.pointee)
        numberOfColorsPointer.deallocate()
        
        let arrayPointer1 = UnsafeBufferPointer(start: colorsPointer, count: numberOfNeurons)
        let colorValues = Array(arrayPointer1)
        
        var colors = [UIColor]()
        for i in 0..<colorValues.count {
            let arrayPointer2 = UnsafeBufferPointer(start: colorValues[i], count: numberOfColors)
            let colorValue = Array(arrayPointer2)
            
            let color = UIColor(red: CGFloat(colorValue[0]), green: CGFloat(colorValue[1]), blue: CGFloat(colorValue[2]), alpha: 1.0)
            
            colors.append(color)
        }
        colorsPointer?.deallocate()
        
        return colors
    }
    
    func getVisPrefs() -> [[[Bool]]]? {
        guard let brainObject = brainObject else { return nil }
        
        let numberOfNeuronsPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        let numberOfParamsPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        let numberOfCamsPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        
        let visPrefsPointer = brain_getVisPrefs(brainObject, numberOfNeuronsPointer, numberOfParamsPointer, numberOfCamsPointer)
        
        let numberOfNeurons = Int(numberOfNeuronsPointer.pointee)
        numberOfNeuronsPointer.deallocate()
        let numberOfParams = Int(numberOfParamsPointer.pointee)
        numberOfParamsPointer.deallocate()
        let numberOfCams = Int(numberOfCamsPointer.pointee)
        numberOfCamsPointer.deallocate()
        
        let arrayPointer1 = UnsafeBufferPointer(start: visPrefsPointer, count: numberOfNeurons)
        let colorValues = Array(arrayPointer1)
        
        var visPrefs = [[[Bool]]]()
        for i in 0..<colorValues.count {
            let arrayPointer2 = UnsafeBufferPointer(start: colorValues[i], count: numberOfParams)
            let params = Array(arrayPointer2)
            
            var paramValues = [[Bool]]()
            
            for j in 0..<params.count {
                let arrayPointer3 = UnsafeBufferPointer(start: params[j], count: numberOfCams)
                let cams = Array(arrayPointer3)
                
                paramValues.append([cams[0], cams[1]])
            }
            
            visPrefs.append(paramValues)
        }
        visPrefsPointer?.deallocate()
        
        return visPrefs
    }
    
    static func getSpectrum(audioData: Data, sampleRate: Int) -> [Double: Double]? {

        let audioDataPointer = audioData.copyBytes(as: Int16.self)
        let numberOfSamples = audioDataPointer.count

        let amplitudePointer = UnsafeMutablePointer<Float>.allocate(capacity: numberOfSamples)
        let frequencyPointer = UnsafeMutablePointer<Float>.allocate(capacity: numberOfSamples)
        let countPointer = UnsafeMutablePointer<Int32>.allocate(capacity: 1)

        defer {
            amplitudePointer.deallocate()
            frequencyPointer.deallocate()
            countPointer.deallocate()
        }

        brain_getSpectrum(audioDataPointer.baseAddress!, Int32(numberOfSamples), Int32(sampleRate), amplitudePointer, frequencyPointer, countPointer)

        func getValues(pointer: UnsafeMutablePointer<Float>, count: Int) -> [Float] {
            let values = Array(UnsafeBufferPointer(start: pointer, count: count))
            return values
        }

        // Because of mirror, omit the second half of the samples
        let counter = Int(countPointer.pointee) / 2
        guard counter > 0 else { return nil }

        let amplitude = getValues(pointer: amplitudePointer, count: counter)
        let frequency = getValues(pointer: frequencyPointer, count: counter)

        // Resolution is 250Hz
        let range = 250

        // Find index of 500Hz
        let index_125 = range / 2 * counter / sampleRate

        guard index_125 > 0 else { return nil }

        // Index of 250Hz
        let index_250 = index_125 * 2

        // Collect values (250Hz) around ((250Hz * n) ± 125Hz) and put under one value (250Hz * n), n > 0
        var dict = [Double: Double]()
        for i in stride(from: index_125, to: counter, by: index_250) {

            var total: Double = 0

            let subsetCount = min(i + index_250, counter)
            for j in i..<subsetCount {
                total += Double(amplitude[j])
            }
            if total < 0 {
                total = 0
            }
            let ampl = total / Double(index_250)

            dict[Double(frequency[min(i + index_125, frequency.count - 1)])] = ampl
        }

        return dict
    }
}
