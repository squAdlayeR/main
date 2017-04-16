//
//  TrackPointTests.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/16.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import XCTest
@testable import lAyeR

class TrackPointTests: XCTestCase {
    
    func test_init() {
        let point1 = TrackPoint(20.1111, 30.1111)
        XCTAssertEqual(point1.latitude, 20.1111, "Incorrect initialization.")
        XCTAssertEqual(point1.longitude, 30.1111, "Incorrect initialization.")
        XCTAssertFalse(point1.up, "Incorrect initialization.")
        XCTAssertFalse(point1.down, "Incorrect initialization.")
        XCTAssertFalse(point1.left, "Incorrect initialization.")
        XCTAssertFalse(point1.right, "Incorrect initialization.")
    }
    
    func test_equal() {
        let point1 = TrackPoint(20.1111, 30.1111)
        let point2 = TrackPoint(20.1111, 30.1111)
        
        XCTAssertTrue(point1 == point2, "Incorrect equivalence.")
        XCTAssertTrue(point1 == point1, "Incorrect equivalence")
    }
    
    func test_hashValue() {
        let point1 = TrackPoint(20.1111, 30.1111)
        let point2 = TrackPoint(20.1111, 30.1111)
        
        XCTAssertTrue(point1.hashValue == point2.hashValue, "Incorrect equivalence.")
        XCTAssertTrue(point1.hashValue == point1.hashValue, "Incorrect equivalence")
    }
    
    func test_convertToStruct() {
        let point1 = TrackPoint(20.1111, 30.1111)
        point1.up = true
        let point2 = point1.convertToStruct()
        XCTAssertTrue(point1.hashValue == point2.hashValue, "Incorrect equivalence")
        XCTAssertTrue(point1.latitude == point2.latitude, "Incorrect equivalence")
        XCTAssertTrue(point1.longitude == point2.longitude, "Incorrect equivalence")
        XCTAssertTrue(point1.up == point2.up, "Incorrect equivalence")
        XCTAssertTrue(point1.down == point2.down, "Incorrect equivalence")
        XCTAssertTrue(point1.left == point2.left, "Incorrect equivalence")
        XCTAssertTrue(point1.right == point2.right, "Incorrect equivalence")
    }
}
