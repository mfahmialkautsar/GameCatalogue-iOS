//
//  GameCatalogueUITests.swift
//  GameCatalogueUITests
//
//  Created by Jamal on 28/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import XCTest

class GameCatalogueUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    // If you wanna run this test, make sure you activate simulator software keyboard
    func testEditProfile() {
        
        let app = XCUIApplication()
        app.launch()
        
        app.tabBars.buttons["Profile"].tap()
        app.navigationBars["Game Catalogue"].buttons["Item"].tap()
                
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        
        let name = "Thor"
        let title = "God of Thunder"
        let about = "Whosoever holds this hammer, if he be worthy, shall possess the power of Thor."
        
        let nameTextField = elementsQuery.textFields["Name"]
        nameTextField.clearText()
        app.typeText(name)
        
        let titleTextField = elementsQuery.textFields["Title"]
        titleTextField.clearText()
        app.typeText(title)
        
        let aboutTextField = elementsQuery.textFields["About"]
        aboutTextField.clearText()
        app.typeText(about)
        
        elementsQuery.buttons["Save"].tap()
        
        XCTAssertEqual(app.staticTexts["Name"].label, name)
        XCTAssertEqual(app.staticTexts["Title"].label, title)
        XCTAssertEqual(app.staticTexts["About"].label, about)
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
