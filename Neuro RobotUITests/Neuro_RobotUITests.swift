//
//  Neuro_RobotUITests.swift
//  Neuro RobotUITests
//
//  Created by Djordje Jovic on 04/04/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import XCTest
//@testable import Neuro_Robot

class Neuro_RobotUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBrains() throws {
        
        let app = XCUIApplication()
        app.launch()
        
        let brains = availableBrains()
        
        app.staticTexts["Don't have a robot?"].tap()
        app.staticTexts["You have to grant access to camera in order to use the app."].tap()
        
        let playButton = app.navigationBars["Neuro_Robot.VideoStreamWithoutRobotView"].buttons["Play"]
        let picker = app.pickerWheels.element
        
        for brain in brains {
            playButton.tap()
            picker.adjust(toPickerWheelValue: brain)
            app.staticTexts["Done"].tap()
            app.navigationBars[brain].buttons["Pause"].tap()
        }
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }

    func availableBrains() -> [String] {
        var availableBrains = [String]()
        let testBundle = Bundle(for: type(of: self))
        
        if let pathToDirectory = testBundle.path(forResource: "Brains", ofType: nil) {
            if var fileNames = try? FileManager.default.contentsOfDirectory(atPath: pathToDirectory) {
                fileNames.sort()
                for brainName in fileNames {
                    availableBrains.append(brainName.replacingOccurrences(of: ".mat", with: ""))
                }
            }
        }
        
        return availableBrains
    }
}

