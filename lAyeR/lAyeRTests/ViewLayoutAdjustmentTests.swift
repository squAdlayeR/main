//
//  ViewLayoutAdjustmentTests.swift
//  lAyeR
//
//  Created by luoyuyang on 23/03/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import XCTest
@testable import lAyeR

class ViewLayoutAdjustmentTests: XCTestCase {
    func testAngleWithinMinusPiToPi() {
        XCTAssertEqual(Double.pi / 2, angleWithinMinusPiToPi(Double.pi / 2))
        XCTAssertEqual(-Double.pi / 2, angleWithinMinusPiToPi(-Double.pi / 2))
        XCTAssertEqual(Double.pi, angleWithinMinusPiToPi(Double.pi))
        XCTAssertEqual(-Double.pi, angleWithinMinusPiToPi(-Double.pi))
        XCTAssertEqual(Double.pi / 2, angleWithinMinusPiToPi(-1.5 * Double.pi))
        XCTAssertEqual(-Double.pi / 2, angleWithinMinusPiToPi(1.5 * Double.pi))
        XCTAssertEqual(0, angleWithinMinusPiToPi(2 * Double.pi))
        XCTAssertEqual(0, angleWithinMinusPiToPi(-2 * Double.pi))
    }

    /// tranform an angle in the range from -2PI to 2PI to the equivalent one in the range from -PI to PI, both included
    private func angleWithinMinusPiToPi(_ angle: Double) -> Double {
        if angle > Double.pi {
            return angle - 2 * Double.pi
        } else if angle < -Double.pi {
            return angle + 2 * Double.pi
        }
        return angle
    }
}
