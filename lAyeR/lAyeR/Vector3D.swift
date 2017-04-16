//
//  3DVector.swift
//  lAyeR
//
//  Created by 罗宇阳 on 9/3/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import Foundation


struct Vector3D {
    private(set) var x: Double
    private(set) var y: Double
    private(set) var z: Double
    
    var length: Double {
        return sqrt(x * x + y * y + z * z)
    }
    
    static prefix func -(v: Vector3D) -> Vector3D {
        return Vector3D(x: -(v.x), y: -(v.y), z: -(v.z))
    }
    
    /// - Returns: dot product of two 3d-vectors
    static func *(v1: Vector3D, v2: Vector3D) -> Double {
        return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
    }
    
    /// - Returns: the cross product of this vector and the input vector: "self" x "v"
    func crossProduct(with v: Vector3D) -> Vector3D {
        let x1 = self.x
        let y1 = self.y
        let z1 = self.z
        let x2 = v.x
        let y2 = v.y
        let z2 = v.z
        return Vector3D(x: y1 * z2 - z1 * y2,
                        y: z1 * x2 - x1 * z2,
                        z: x1 * y2 - y1 * x2)
    }
    
    /// - Returns: the length of the projection of this vector on the input vector "v"
    func projectionLength(on v: Vector3D) -> Double {
        if (v.length == 0) {
            return 0
        }
        return self * v / v.length
    }
}
