//
//  movie_appUITests.swift
//  movie-appUITests
//
//  Created by Julian Jans on 30/07/2018.
//  Copyright © 2018 Julian Jans. All rights reserved.
//

import XCTest

class UITests: XCTestCase {
    
    func testUserFlow() {
        givenAppOpens()
        shouldDisplay(value: "Mission: Impossible - Fallout")
        shouldDisplay(value: "Jurassic World: Fallen Kingdom")
        select("Mission: Impossible - Fallout")
        shouldDisplay(value: "Mission: Impossible - Fallout")
        swipeUp()
        shouldDisplay(value: "Mission: Impossible Collection")
        select("Mission: Impossible")
        go("Back")
        go("Back")
        shouldDisplay(value: "Jurassic World: Fallen Kingdom")
        select("Jurassic World: Fallen Kingdom")
        swipeUp()
        shouldDisplay(value: "Jurassic Park Collection")
        go("Back")
    }
    
    func testUserFlowMultipleOrientations() {
        givenAppOpens()
        rotate()
        shouldDisplay(value: "Mission: Impossible - Fallout")
        rotate()
        shouldDisplay(value: "Jurassic World: Fallen Kingdom")
        rotate()
        select("Mission: Impossible - Fallout")
        rotate()
        shouldDisplay(value: "Mission: Impossible - Fallout")
        rotate()
        swipeUp()
        rotate()
        shouldDisplay(value: "Mission: Impossible Collection")
        select("Mission: Impossible")
        rotate()
        go("Back")
        rotate()
        go("Back")
        rotate()
        shouldDisplay(value: "Jurassic World: Fallen Kingdom")
        rotate()
        select("Jurassic World: Fallen Kingdom")
        rotate()
        swipeUp()
        rotate()
        shouldDisplay(value: "Jurassic Park Collection")
        rotate()
        go("Back")
        XCUIDevice.shared.orientation = .portrait
    }
    
}

extension UITests {
    
    func givenAppOpens() {
        continueAfterFailure = false
        let app = XCUIApplication()
        // Comment this to test the live API
        app.launchArguments.append("APIClientMock")
        app.launch()
        XCUIDevice.shared.orientation = .portrait
    }
    
    func select(_ input: String) {
        let app = XCUIApplication()
        app.staticTexts[input].firstMatch.tap()
    }
    
    func go(_ input: String) {
        let app = XCUIApplication()
        app.navigationBars["Movie"].buttons[input].tap()
    }
    
    func swipeUp() {
        let app = XCUIApplication()
        app.windows.element.firstMatch.swipeUp()
    }
    
    func shouldDisplay(value: String) {
        let app = XCUIApplication()
        XCTAssertTrue(app.staticTexts[value].firstMatch.isHittable)
    }
    
    func rotate() {
        XCUIDevice.shared.orientation = XCUIDevice.shared.orientation.isPortrait ? .landscapeLeft : .portrait
    }
    
}
