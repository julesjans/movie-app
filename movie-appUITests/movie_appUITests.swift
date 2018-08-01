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
        shouldDisplay(value: "Mission: Impossible Collection")
        go("Back")
        shouldDisplay(value: "Jurassic World: Fallen Kingdom")
        select("Jurassic World: Fallen Kingdom")
        shouldDisplay(value: "Jurassic Park Collection")
        go("Back")
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
        app.staticTexts[input].tap()
    }
    
    func go(_ input: String) {
        let app = XCUIApplication()
        app.navigationBars["Movie"].buttons[input].tap()
    }
    
    func shouldDisplay(value: String) {
        let app = XCUIApplication()
        XCTAssertTrue(app.staticTexts[value].isHittable)
    }
    
}
