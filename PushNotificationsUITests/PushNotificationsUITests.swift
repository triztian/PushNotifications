//
//  PushNotificationsUITests.swift
//  PushNotificationsUITests
//
//  Created by Tristian Azuara on 3/14/21.
//

import os
import XCTest

class PushNotificationsUITests: XCTestCase {
    func test_display_push_message() throws {
        XCUIApplication().launch()

        // This will trigger a `xcrun simctl push` to be executed.
        os_log("XCUI-SEND-MESSAGE-XCUI", type: .default)

        let alertElem = XCUIApplication().descendants(matching: .staticText)["Notification Received"]

        waitFor(forElement: alertElem, timeout: 10)

        // NOTE: Using XCTFail to fail the test will hang `xcodebuild ... test` for some
        // unknown reason:
        //     XCTFail("remove me!!")
        //
        // To fail it use:
        //     XCTAssert(false, "Remove ME!!!")
    }
}

private func waitFor(forElement element: XCUIElement, timeout: TimeInterval) {
    let predicate = NSPredicate(format: "exists == true")
    let elemExists = XCTNSPredicateExpectation(predicate: predicate, object: element)
    XCTWaiter().wait(for: [elemExists], timeout: timeout)
}
