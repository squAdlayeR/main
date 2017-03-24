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
    
    func testDotProductWithZeroVector() {
        let zero = Vector3D(x: 0, y: 0, z: 0)
        let v = Vector3D(x: 1, y: 3, z: 9)
        XCTAssertEqual(zero * v, 0,
                       "The dot product with zero vector is incorrect!")
    }
}






