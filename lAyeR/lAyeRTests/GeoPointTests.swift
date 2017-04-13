//
//  GeoPointTests.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/24.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import XCTest
//import ObjectMapper
@testable import lAyeR

class GeoPointTests: XCTestCase {
    
    func test_init_validParameters() {
        let point = GeoPoint(90, 180)
        XCTAssertEqual(point.latitude, 90, "Incorrect initialization")
        XCTAssertEqual(point.longitude, 180, "Incorrect initialization")
    }
    
    func test_init_invalidParameters() {
        let point = GeoPoint(90.0001, 180.0001)
        XCTAssertEqual(point.latitude, 0, "Invalid parameters not reset to default.")
        XCTAssertEqual(point.longitude, 0, "Invalid parameters not reset to default.")
    }
    
    func test_Equal() {
        let point1 = GeoPoint(90, 180)
        let point2 = GeoPoint(90, 180)
        let point3 = GeoPoint(90, -180)
        XCTAssertTrue(point1 == point2, "Incorrect equivalence.")
        XCTAssertFalse(point1 == point3, "Incorrect equivalence")
    }
    
    func test_init_fromMapping() {
        let point1 = GeoPoint(11, 111.233)
        let jsonPoint = point1.toJSONString(prettyPrint: true)
        XCTAssertNotNil(jsonPoint, "Failed convention to JSON.")
        let point2 = GeoPoint(JSONString: jsonPoint!)
        XCTAssertTrue(point1 == point2, "Incorrect convertion.")
    }
}
