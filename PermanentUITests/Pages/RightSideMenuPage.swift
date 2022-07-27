//
//  RightSideMenu.swift
//  PermanentUITests
//
//  Created by Lucian Cerbu on 27.07.2022.
//

import Foundation
import XCTest

class RightSideMenuPage {
    let app: XCUIApplication
    let accountEmail: String
    var emailStaticText: XCUIElement {
        app.staticTexts[accountEmail]
    }
    
    init(app: XCUIApplication, testCase: XCTestCase, accountEmail: String) {
        self.app = app
        self.accountEmail = accountEmail
    }
    
    func waitForExistence() {
        XCTAssertTrue(emailStaticText.waitForExistence(timeout: 5))
    }
    
    func logOut() {
        let logoutButton = app.tables.staticTexts["Log Out"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()
    }
}
