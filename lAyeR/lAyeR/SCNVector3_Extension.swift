//
//  SCNVector3_Extension.swift
//  lAyeR
//
//  Created by luoyuyang on 10/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import SceneKit


extension SCNVector3 {
    public static func +(v1: SCNVector3, v2: SCNVector3) -> SCNVector3 {
        return SCNVector3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
    }
}




