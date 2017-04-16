//
//  GeoUtilTests.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/24.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import XCTest
import CoreLocation
@testable import lAyeR

class GeoUtilTests: XCTestCase {
    
    func test_isValidLatitude_validInput() {
        XCTAssertTrue(GeoUtil.isValidLatitude(90), "Incorrect validation")
        XCTAssertTrue(GeoUtil.isValidLatitude(-90), "Incorrect validation")
        XCTAssertTrue(GeoUtil.isValidLatitude(0), "Incorrect validation")
        XCTAssertTrue(GeoUtil.isValidLatitude(89.34), "Incorrect validation")
        XCTAssertTrue(GeoUtil.isValidLatitude(-89.43), "Incorrect validation")
    }
    
    func test_isValidLongitude_validInput() {
        XCTAssertTrue(GeoUtil.isValidLongitude(180), "Incorrect validation")
        XCTAssertTrue(GeoUtil.isValidLongitude(-180), "Incorrect validation")
        XCTAssertTrue(GeoUtil.isValidLongitude(0), "Incorrect validation")
        XCTAssertTrue(GeoUtil.isValidLongitude(179.34), "Incorrect validation")
        XCTAssertTrue(GeoUtil.isValidLongitude(-179.43), "Incorrect validation")
    }
    
    func test_isValidLatitude_invalidInput() {
        XCTAssertFalse(GeoUtil.isValidLatitude(90.001), "Incorrect validation")
        XCTAssertFalse(GeoUtil.isValidLatitude(-90.001), "Incorrect validation")
    }
    
    func test_isValidLongitude_invalidInput() {
        XCTAssertFalse(GeoUtil.isValidLongitude(-180.001), "Incorrect validation")
        XCTAssertFalse(GeoUtil.isValidLongitude(180.001), "Incorrect validation")
    }
    
    func test_getCoordinateDistance_samePointReturnZero() {
        let point = GeoPoint(1.298, 123.888)
        XCTAssertEqual(0, GeoUtil.getCoordinateDistance(point, point), "Incorrect coordinate distance.")
    }
    
    func test_getCoordinateDistance_distinctPoints() {
        /// Note: the result should be equal to the result computed
        /// using CLLocation.
        let point1 = GeoPoint(1.298, 123.888)
        let cllocation1 = CLLocation(latitude: 1.298, longitude: 123.888)
        let point2 = GeoPoint(1.345, 124.44)
        let cllocation2 = CLLocation(latitude: 1.345, longitude: 124.44)
        XCTAssertEqual(GeoUtil.getCoordinateDistance(point1, point2), cllocation1.distance(from: cllocation2), "Incorrect implementation of getting coordinate distance.")
    }
    
    /// MARK: There would be round up errors when calculating the azimuths
    /// as the computation is not done in a plane but a surface.
    func test_getAzimuth() {
        let referencePoint = GeoPoint(1, 1)
        let north = GeoPoint(2, 1)
        let south = GeoPoint(0, 1)
        let east = GeoPoint(1, 2)
        let west = GeoPoint(1, 0)
        XCTAssertEqual(GeoUtil.getAzimuth(between: referencePoint, north), 0)
        XCTAssertEqual(GeoUtil.getAzimuth(between: referencePoint, south), Double.pi)
        XCTAssertEqual(GeoUtil.getAzimuth(between: referencePoint, east), Double.pi/2)
        XCTAssertEqual(GeoUtil.getAzimuth(between: referencePoint, west), -Double.pi/2)
    }
}
