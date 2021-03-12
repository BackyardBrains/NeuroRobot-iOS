//
//  NeurorobotTests.swift
//  NeurorobotTests
//
//  Created by Djordje Jovic on 17/11/2019.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import XCTest
//import Neuro_Robot
import Accelerate

class NeurorobotTests: XCTestCase {
    
    override func setUp() {
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testMatlabCases() {
        
        var matlabTestData: [[Float]]?
        var matlabTestResultsData: [[Float]]?
        
        if let data = readDataFromCSV(fileName: "test", fileType: "csv") {
            matlabTestData = data
        }
        if let data = readDataFromCSV(fileName: "test_results", fileType: "csv") {
            matlabTestResultsData = data
        }
        
        if let testData = matlabTestData, let testResults = matlabTestResultsData, testData.count == testResults.count {
            
            for i in 0..<testData.count {
                let test = testData[i]
                let testResult = testResults[i]
                
                let maxAmp = UnsafeMutablePointer<Float>.allocate(capacity: 1)
                let maxFreq = UnsafeMutablePointer<Float>.allocate(capacity: 1)
                let samples = UnsafeMutablePointer<Float>.allocate(capacity: test.count)
                for j in 0..<test.count {
                    samples.advanced(by: j).pointee = test[j]
                }
                brain_test_processAudio2(samples, Int32(test.count), 16000, maxAmp, maxFreq)
                
                XCTAssertEqual(maxAmp.pointee, testResult[0], accuracy: 0.1, "Computed max amplitude is wrong")
                XCTAssertEqual(maxFreq.pointee, testResult[1], accuracy: 0.1, "Computed max frequency is wrong")
            }
        }
    }

//    func testAudioProcessingConstant() {
//
////        // In matlab
////        x = 2.* ones(1000 ,1)'
////        x = [x x(1:24)];
////        fs = 8000;
////        n = length(x);
////        y = fft(x);
////        pw = (abs(y).^2)/n;
////        fx = (0:n-1)*(fs/n);
////        stdDev = std(pw);
////        pw = (pw - mean(pw)) / stdDev;
////        [max_amp, j] = max(pw(1:250));
////        max_freq = fx(j);
//
//        let maxAmp = UnsafeMutablePointer<Float>.allocate(capacity: 1)
//        let maxFreq = UnsafeMutablePointer<Float>.allocate(capacity: 1)
//        let n = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
//        n.pointee = 1000
//        let audioData = UnsafeMutablePointer<Int16>.allocate(capacity: Int(n.pointee))
//        for i in 0..<Int(n.pointee) {
//            audioData.advanced(by: i).pointee = 5
//        }
//        brain_test_processAudio(audioData, n.pointee, maxAmp, maxFreq)
//
//        XCTAssertEqual(maxAmp.pointee, 31.96875, accuracy: 0.1, "Computed max amplitude is wrong")
//        XCTAssertEqual(maxFreq.pointee, 0, accuracy: 0.1, "Computed max frequency is wrong")
//        print("done")
//    }
//
//    func testAudioProcessingSin() {
//
////        In matlab
////        x = sin(0:(2*pi/100):(10 * 2*pi - 2*pi/100))
////        x = [x x(1:24)]
////        fs = 8000
////        n = length(x);
////        y = fft(x);
////        pw = (abs(y).^2)/n;
////        fx = (0:n-1)*(fs/n);
////        stdDev = std(pw);
////        pw = (pw - mean(pw)) / stdDev;
////        [max_amp, j] = max(pw(1:250));
////        max_freq = fx(j);
//
//        let maxAmp = UnsafeMutablePointer<Float>.allocate(capacity: 1)
//        let maxFreq = UnsafeMutablePointer<Float>.allocate(capacity: 1)
//        let n = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
//        n.pointee = 1000
//        let audioDataFloat = UnsafeMutablePointer<Float>.allocate(capacity: Int(n.pointee))
//        let audioDataInt = UnsafeMutablePointer<Int16>.allocate(capacity: Int(n.pointee))
//        let samples = UnsafeMutablePointer<Float>.allocate(capacity: Int(n.pointee))
//
//        for i in 0..<n.pointee {
//            let percent = Float(i) * 2 * Float.pi / 100
//            samples.advanced(by: Int(i)).pointee = percent
//        }
//
//        vvsinf(audioDataFloat, samples, n)
//
//        for i in 0..<Int(n.pointee) {
//            audioDataInt.advanced(by: i).pointee = Int16(audioDataFloat[i] * 1000)
//        }
//
//
//        brain_test_processAudio(audioDataInt, n.pointee, maxAmp, maxFreq)
////        brain_test_processAudio2(audioDataFloat, n.pointee, maxAmp, maxFreq)
//
//        XCTAssertEqual(maxAmp.pointee, 22.45, accuracy: 0.1, "Computed max amplitude is wrong")
//        XCTAssertEqual(maxFreq.pointee, 78.125, accuracy: 0.1, "Computed max frequency is wrong")
//        print("done")
//    }
//
//    func testAudioProcessingCos() {
//
////        In matlab
////        x = cos(0:(2*pi/100):(10 * 2*pi - 2*pi/100))
////        x = [x x(1:24)]
////        fs = 8000
////        n = length(x);
////        y = fft(x);
////        pw = (abs(y).^2)/n;
////        fx = (0:n-1)*(fs/n);
////        stdDev = std(pw);
////        pw = (pw - mean(pw)) / stdDev;
////        [max_amp, j] = max(pw(1:250));
////        max_freq = fx(j);
//
//        let maxAmp = UnsafeMutablePointer<Float>.allocate(capacity: 1)
//        let maxFreq = UnsafeMutablePointer<Float>.allocate(capacity: 1)
//        let n = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
//        n.pointee = 1000
//        let audioDataFloat = UnsafeMutablePointer<Float>.allocate(capacity: Int(n.pointee))
//        let audioDataInt = UnsafeMutablePointer<Int16>.allocate(capacity: Int(n.pointee))
//        let samples = UnsafeMutablePointer<Float>.allocate(capacity: Int(n.pointee))
//
//        for i in 0..<n.pointee {
//            let percent = Float(i) * 2 * Float.pi / 100
//            samples.advanced(by: Int(i)).pointee = percent
//        }
//
//        vvcosf(audioDataFloat, samples, n)
//
//        for i in 0..<Int(n.pointee) {
//            audioDataInt.advanced(by: i).pointee = Int16(audioDataFloat[i] * 1000)
//        }
//
//
//        brain_test_processAudio(audioDataInt, n.pointee, maxAmp, maxFreq)
////        brain_test_processAudio2(audioDataFloat, n.pointee, maxAmp, maxFreq)
//
//        XCTAssertEqual(maxAmp.pointee, 22.45, accuracy: 0.1, "Computed max amplitude is wrong")
//        XCTAssertEqual(maxFreq.pointee, 78.125, accuracy: 0.1, "Computed max frequency is wrong")
//        print("done")
//    }
    
    
    
    func readDataFromCSV(fileName:String, fileType: String) -> [[Float]]? {
            
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType) else { return nil }
        
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return csv(data: cleanRows(file: contents))
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    func cleanRows(file:String) -> String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
     
    func csv(data: String) -> [[Float]] {
        var result: [[Float]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows where row.count != 0 {
            var numbers = [Float]()
            let columns = row.components(separatedBy: ",")
            for column in columns {
                let fooNum = (column as NSString).floatValue
                numbers.append(fooNum)
            }
            result.append(numbers)
        }
        return result
    }
}


//csvwrite('test1', x)
