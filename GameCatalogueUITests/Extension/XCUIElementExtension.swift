//
//  XCUIElementExtension.swift
//  GameCatalogueUITests
//
//  Created by Jamal on 28/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import XCTest

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear a non-string value")
            return
        }
        
        self.tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}
