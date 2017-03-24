//
//  CheckPointTests.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/24.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import XCTest
@testable import lAyeR

class CheckPointTests: XCTestCase {
    
    func test_init_validParametersWithoutDescription() {
        let point1 = CheckPoint(90, 180, "point1")
        XCTAssertEqual(point1.name, "point1", "Incorrect initialization.")
        XCTAssertEqual(point1.latitude, 90, "Incorrect initialization.")
        XCTAssertEqual(point1.longitude, 180, "Incorrect initialization.")
        XCTAssertEqual(point1.description, "", "Incorrect initialization.")
    }
    
    func test_init_validParametersWithDescription() {
        let point1 = CheckPoint(90, 180, "point1", "some description")
        XCTAssertEqual(point1.name, "point1", "Incorrect initialization.")
        XCTAssertEqual(point1.latitude, 90, "Incorrect initialization.")
        XCTAssertEqual(point1.longitude, 180, "Incorrect initialization.")
        XCTAssertEqual(point1.description, "some description", "Incorrect initialization.")
    }
    
    func test_init_invalidParameters() {
        let point = CheckPoint(90.0001, 180.0001, "point")
        XCTAssertEqual(point.latitude, 0, "Invalid parameters not reset to default.")
        XCTAssertEqual(point.longitude, 0, "Invalid parameters not reset to default.")
    }
    
    func test_equal() {
        let point1 = CheckPoint(90, 180, "point1")
        let point2 = CheckPoint(90, 180, "point2")
        let point3 = CheckPoint(90, -180, "point1")
        let point4 = CheckPoint(-90, 180, "point1")
        let point5 = CheckPoint(90, 180, "point1")
        
        XCTAssertTrue(point1 == point5, "Incorrect equivalence.")
        XCTAssertFalse(point1 == point2, "Incorrect equivalence")
        XCTAssertFalse(point1 == point3, "Incorrect equivalence")
        XCTAssertFalse(point1 == point4, "Incorrect equivalence")
    }
    
}
