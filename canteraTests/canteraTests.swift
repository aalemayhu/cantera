//
//  canteraTests.swift
//  canteraTests
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import XCTest
@testable import cantera

class CanteraTests: XCTestCase {

    func testPayload() {
        let data = """
        {
        "image": {
        "scalable": true,
        "width": 1024,
        "type": "GENERAL",
        "url": "2017/9/vertical-2/29/3/105/376/_9531505.jpg",
        "height": 683
        },
        "score": "0.2679544687271118",
        "ad-type": "REALESTATE",
        "price": {
        "value": 15000
        },
        "description": "3-roms leilightet leies!",
        "location": "Oslo",
        "id": "105376903",
        "type": "AD",
        "tracking": {
        "adobe": {
          "event_name": "meta_recommendation",
          "type": "stream",
          "category": "relevant_ad",
          "url": "https://apps.finn.no/api/stream/discover/"
        },
        "ec": {
          "inScreen": [
            "https://www.finn.no/ec/USER/recommendationEvents?adIds=105376903&version=finn_meta_discovery_2b&recsys.uuid=80ec2f0c-44c9-435a-aeec-99e164304de9&recsys.position=recommend.app-discover.inScreen"
          ],
          "click": [
            "https://www.finn.no/ec/AD/NoOfPageViews_Main?finnkode=105376903",
            "https://www.finn.no/ec/USER/recommendationEvents?finnkode=105376903&version=finn_meta_discovery_2b&recsys.uuid=80ec2f0c-44c9-435a-aeec-99e164304de9&recsys.position=recommend.app-discover.click"
          ]
        }
        },
        "actions": {
        "block": [
          "https://www.finn.no/ec/USER/recommend.block?finnkode=105376903&version=finn_meta_discovery_2b&recsys.uuid=80ec2f0c-44c9-435a-aeec-99e164304de9&recsys.position=recommend.app-discover"
        ]
        },
        "version": "finn_meta_discovery_2b.finn_real_estate_als_r150.recommendItems"
        }
        """.data(using: .utf8)

        guard let payload = data else { XCTFail("Failed to setup payload"); return }
        do {
            let ad = try JSONDecoder().decode(AdResponse.self, from: payload)
            XCTAssertEqual(ad.description, "3-roms leilightet leies!")
            if let price = ad.price?.value {
                XCTAssertEqual(price, 15000)
            } else {
                XCTFail("Could not decode price!")
            }
            XCTAssertEqual(ad.location, "Oslo")
            XCTAssertEqual(ad.image.url, "2017/9/vertical-2/29/3/105/376/_9531505.jpg")

            // Check storage manager is acting sane
            let items: [AdObject] = [AdObject(adResponse: ad)]
            let sm = StorageManager()
            sm.persist(ads: items)
            let actual = sm.savedAds()
            XCTAssertNotNil(actual)
            sm.purge()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testEndpoints() {
        let expected = "https://images.finncdn.no/dynamic/480x360c/2017/9/vertical-2/29/3/105/376/_9531505.jpg"
        let actual = Endpoints.image("2017/9/vertical-2/29/3/105/376/_9531505.jpg").url()?.absoluteString
        XCTAssertEqual(expected, actual)

        XCTAssertNotNil(Endpoints.json.url())
    }
}
