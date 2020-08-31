//
//  GameCatalogueTests.swift
//  GameCatalogueTests
//
//  Created by Jamal on 28/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import XCTest
@testable import Game_Catalogue

class GameCatalogueTests: XCTestCase {
    var gameViewController = GameViewController()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testNavItemTitle() {
        gameViewController.beginAppearanceTransition(true, animated: true)
        XCTAssertEqual(gameViewController.navigationItem.title, "Game Catalogue")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
