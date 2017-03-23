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
    
    // dot product
    // projection
}
