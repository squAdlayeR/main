//
//  Vector3DTests.swift
//  lAyeR
//
//  Created by luoyuyang on 09/03/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import XCTest
@testable import lAyeR

class Vector3DTests: XCTestCase {
    
    func testVectorLength() {
        let v = Vector3D(x: 1, y: -1, z: 1)
        XCTAssertEqual(v.length, sqrt(3))
    }
    
    func testOppositeVector() {
        let v = Vector3D(x: 1, y: 2, z: 3)
        let oppositeV = -v
        XCTAssertEqual(-1, oppositeV.x,
                       "The opposite-direction vector of \(v) is incorrect!")
        XCTAssertEqual(-2, oppositeV.y,
                       "The opposite-direction vector of \(v) is incorrect!")
        XCTAssertEqual(-3, oppositeV.z,
                       "The opposite-direction vector of \(v) is incorrect!")
    }
    
    func testEquivalentMinusSignOnVector() {
        let v = Vector3D(x: 1, y: 2, z: 3)
        XCTAssertEqual((-v).x, -(v.x),
                       "The opposite-direction vector of \(v) is incorrect!")
        XCTAssertEqual((-v).y, -(v.y),
                       "The opposite-direction vector of \(v) is incorrect!")
        XCTAssertEqual((-v).z, -(v.z),
                       "The opposite-direction vector of \(v) is incorrect!")
    }
    
    func testNormalDotProduct() {
        let v1 = Vector3D(x: 1, y: 2, z: 3)
        let v2 = Vector3D(x: 3, y: 2, z: 1)
        XCTAssertEqual(v1 * v2, 10,
                       "The dot product is incorrect!")

    }
    
    func testDotProductWithZeroVector() {
        let zero = Vector3D(x: 0, y: 0, z: 0)
        let v = Vector3D(x: 1, y: 3, z: 9)
        XCTAssertEqual(zero * v, 0,
                       "The dot product with zero vector is incorrect!")
    }
    
    func testDotProductWithPerpendicularVector() {
        let x = Vector3D(x: 1, y: 0, z: 0)
        let y = Vector3D(x: 0, y: 1, z: 0)
        let z = Vector3D(x: 0, y: 0, z: 1)
        XCTAssertEqual(x * y, 0,
                       "The dot product between 2 perpendicular vectors is not 0!")

        XCTAssertEqual(y * z, 0,
                       "The dot product between 2 perpendicular vectors is not 0!")

        XCTAssertEqual(x * z, 0,
                       "The dot product between 2 perpendicular vectors is not 0!")

    }
    
    func testNormalProjectionLength() {
        let v1 = Vector3D(x: 1, y: 1, z: 1)
        let v2 = Vector3D(x: 1, y: 1, z: 0)
        print(v1.projectionLength(on: v2))
        XCTAssertEqualWithAccuracy(v1.projectionLength(on: v2), sqrt(2), accuracy: 1e-8)
    }
    
    func testProjectionLengthOnZeroVector() {
        let zero = Vector3D(x: 0, y: 0, z: 0)
        let v = Vector3D(x: 1, y: 3, z: 9)
        XCTAssertEqual(v.projectionLength(on: zero), 0)
    }
    
    func testProjectionOfZero() {
        let zero = Vector3D(x: 0, y: 0, z: 0)
        let v = Vector3D(x: 1, y: 3, z: 9)
        XCTAssertEqual(zero.projectionLength(on: v), 0)
    }
    
    func testProjectionLengthOnPerpendicularVector() {
        let x = Vector3D(x: 1, y: 0, z: 0)
        let y = Vector3D(x: 0, y: 1, z: 0)
        let z = Vector3D(x: 0, y: 0, z: 1)
        XCTAssertEqual(x.projectionLength(on: y), 0)
        XCTAssertEqual(y.projectionLength(on: z), 0)
        XCTAssertEqual(x.projectionLength(on: z), 0)
    }
}






