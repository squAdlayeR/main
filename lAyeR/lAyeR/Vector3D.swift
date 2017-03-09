//
//  3DVector.swift
//  lAyeR
//
//  Created by 罗宇阳 on 9/3/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import Foundation

class Vector3D {
    private(set) var x: Double
    private(set) var y: Double
    private(set) var z: Double
    
    var length: Double {
        return sqrt(x * x + y * y + z * z)
    }
    
    init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    /// - Returns: dot product of two 3d-vectors
    static func *(v1: Vector3D, v2: Vector3D) -> Double {
        return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
    }
    
    /// - Returns: the length of the projection of this vector on the input vector "v"
    func projectionLength(on v: Vector3D) -> Double {
        return self * v / v.length
    }
}
