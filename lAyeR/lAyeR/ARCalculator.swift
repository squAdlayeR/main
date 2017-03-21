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

struct ARCalculator {
    private let motion: CMDeviceMotion
    private let azimuth: Double
    private let superView: UIView
    private var rotationMatrix: CMRotationMatrix {
        return motion.attitude.rotationMatrix
    }
    
    init(motion: CMDeviceMotion, azimuth: Double, superView: UIView) {
        self.motion = motion
        self.azimuth = azimuth
        self.superView = superView
    }
    
    func calculateARLayoutAdjustment() -> ARViewLayoutAdjustment {
        let yawAngle = calculateYawAngle()
        let horzAngle = calculateHorzAngle()
        let verticalAngle = calculateVerticalAngle()
        
        let yawCos = cos(yawAngle)
        let yawSin = sin(yawAngle)
        
        let superViewWidth = superView.bounds.width
        let superViewHeight = superView.bounds.height
        let visionWidth = superViewWidth * CGFloat(abs(yawCos)) + superViewHeight * CGFloat(abs(yawSin))
        let visionHeight = superViewWidth * CGFloat(abs(yawSin)) + superViewHeight * CGFloat(abs(yawCos))
        
        // positive x direction is rigth
        let horzOffset = CGFloat(sin(horzAngle)) * visionWidth

        // positive y direction is down
        let verticalOffset = CGFloat(-sin(verticalAngle)) * visionHeight
        
        let xOffset = CGFloat(horzOffset) * CGFloat(yawCos) - CGFloat(verticalOffset) * CGFloat(yawSin)
        let yOffset = -(CGFloat(verticalOffset) * CGFloat(yawCos) + CGFloat(horzOffset) * CGFloat(yawSin))
        
        var isOutOfView = false
        if horzAngle > M_PI / 2 || horzAngle < -M_PI / 2 {
            isOutOfView = true
        }

        return ARViewLayoutAdjustment(xOffset: xOffset, yOffset: yOffset,
                                  yawRotationAngle: -(CGFloat)(yawAngle),
                                  horzRotationAngle: -(CGFloat)(horzAngle),
                                  isOutOfView: isOutOfView)
    }
    
    /**
     0 degree: vertical
     positive direction: yaw right
     range: -pi ~ pi
     */
    private func calculateYawAngle() -> Double {
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
    private func calculateVerticalAngle() -> Double {
        let m33 = -rotationMatrix.m33
        return atan2(m33, sqrt(1 - m33 * m33))
    }
    
    /**
     0 degree: back pointing to true north
     positive direction: roll left
     range: -pi ~ pi
     */
    private func calculateHorzAngleRelToNorth() -> Double {  // "RelTo": relative to
        return atan2(-rotationMatrix.m32, -rotationMatrix.m31)
    }
    
    /**
     0 degree: back pointing to the target
     positive direction: roll left
     range: -pi ~ pi
     */
    func calculateHorzAngle() -> Double {
        // the positive direction of azimuth is right, which is the opposite of rollAngle
        return angleWithinMinusPiToPi(calculateHorzAngleRelToNorth() + azimuth)
    }
    
    
    /// tranform an angle in the range from -2PI to 2PI to the equivalent one in the range from -PI to PI
    private func angleWithinMinusPiToPi(_ angle: Double) -> Double {
        if angle > M_PI {
            return angle - 2 * M_PI
        } else if angle < -M_PI {
            return angle + 2 * M_PI
        }
        return angle
    }
}
