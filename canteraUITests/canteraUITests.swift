//
//  canteraUITests.swift
//  canteraUITests
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import XCTest

class CanteraUITests: XCTestCase {

    // testFetchingAds is not a UI test but actually a integration test to trigger requests to the API.
    func testFetchingAds() {
        let expectation = XCTestExpectation(description: "Wait until we have a payload from the API")
        let api = RequestHandler()

        api.fetch { (ads) in
            XCTAssertTrue(ads.count > 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }

}
