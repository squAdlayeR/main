//
//  ARCalculator.swift
//  lAyeR
//
//  Created by 罗宇阳 on 9/3/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import CoreMotion
import Foundation
import UIKit

class DeviceMotionManager {
    private static var deviceMotionManager: DeviceMotionManager?
    
    private let cmMotionManager = CMMotionManager()
    private var motion: CMDeviceMotion?
    private var rotationMatrix: CMRotationMatrix {
        if let deviceMotion = motion {
            return deviceMotion.attitude.rotationMatrix
        }
        return CMRotationMatrix()
    }
    
    static func getInstance() -> DeviceMotionManager {
        if deviceMotionManager == nil {
            deviceMotionManager = DeviceMotionManager()
        }
        return deviceMotionManager!
    }
    
    
    init() {
        if cmMotionManager.isDeviceMotionAvailable && !cmMotionManager.isDeviceMotionActive {
            cmMotionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: .main, withHandler: { [unowned self] (data, error) in
                if let deviceMotion = data {
                    self.motion = deviceMotion
                }
            })
        }
    }

    /**
     0 degree: vertical
     positive direction: yaw right
     range: -pi ~ pi
     */
    func getYawAngle() -> Double {
        let deviceZ = Vector3D(x: rotationMatrix.m31, y: rotationMatrix.m32, z: rotationMatrix.m33)
        let deviceY = Vector3D(x: rotationMatrix.m21, y: rotationMatrix.m22, z: rotationMatrix.m23)
        
        // the horizontal vector perpendicular to the z-axis vector of the device
        let horzVectorPerpToDeviceZ = Vector3D(x: -(deviceZ.y), y: deviceZ.x, z: 0)
        
        // the normal vector of the surface spanned by the following 2 vectors:
        // - the z-axis vector of the device
        // - horzVectorPerpToDeviceZ
        let normalVector = horzVectorPerpToDeviceZ.crossProduct(with: deviceZ)
        
        let yawCos = -deviceY.projectionLength(on: normalVector) / deviceY.length
        var yawSin = sqrt(1 - yawCos * yawCos)
        if deviceY * horzVectorPerpToDeviceZ < 0 {
            yawSin = -yawSin
        }
        
        return atan2(yawSin, yawCos)
    }
    
    /**
     0 degree: horizontal
     positive direction: pitch up
     range: -pi/2 ~ pi/2
     */
    func getVerticalAngle() -> Double {
        let m33 = -rotationMatrix.m33
        return atan2(m33, sqrt(1 - m33 * m33))
    }
    
    /**
     0 degree: back pointing to true north
     positive direction: roll left
     range: -pi ~ pi
     */
    func getHorzAngleRelToNorth() -> Double {  // "RelTo": relative to
        return atan2(-rotationMatrix.m32, -rotationMatrix.m31)
    }
}
