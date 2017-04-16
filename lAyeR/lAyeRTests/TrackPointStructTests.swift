//
//  TrackPointStructTests.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/16.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import XCTest
@testable import lAyeR

class TrackPointStructTests: XCTestCase {
    
    func test_init() {
        let point1 = TrackPointStruct(20.1111, 30.1111)
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
}
