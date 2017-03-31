//
//  ARViewLayoutAdjustment.swift
//  lAyeR
//
//  Created by luoyuyang on 09/03/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit

struct ARViewLayoutAdjustment {
    var xPosition: CGFloat = 0
    var yPosition: CGFloat = 0
    var yawRotationAngle: CGFloat = 0
    var horzRotationAngle: CGFloat = 0
    
    private let superView: UIView
    private let fov: Double  //  "fov" stands for field of view (angle in radian)
    
    private let deviceMotionManager: DeviceMotionManager
    private let distance: Double
    private let azimuth: Double
    
    var pushBackDistance: CGFloat {
        if (distance > Setting.distanceBound) {
            return CGFloat(Setting.distanceBound)
        } else {
            return CGFloat(distance)
        }
    }
    
    var perspectiveYPosition: CGFloat {
        let projectionPlaneDistance = Setting.projectionPlaneDistance
        let projectionPlaneToTargeDistance = CGFloat(distance)
        let eyeYPositioin = superView.bounds.height * 0.38
        let range = superView.bounds.height * 0.18
        let declineOffset = projectionPlaneDistance / (projectionPlaneDistance + projectionPlaneToTargeDistance) * range
        return eyeYPositioin + declineOffset
    }
    
    init(deviceMotionManager: DeviceMotionManager, distance: Double, azimuth: Double,
         superView: UIView, fov: Double) {
        self.deviceMotionManager = deviceMotionManager
        self.distance = distance
        self.azimuth = azimuth
        self.superView = superView
        self.fov = fov
        calculateParameters()
    }
    
    mutating func calculateParameters() {
        let yawAngle = deviceMotionManager.getYawAngle()
        let horzAngle = getHorzAngle()
        let verticalAngle = deviceMotionManager.getVerticalAngle()
        
        let yawCos = cos(yawAngle)
        let yawSin = sin(yawAngle)
        
        let superViewWidth = superView.bounds.width
        let superViewHeight = superView.bounds.height
        let visionWidth = superViewWidth * CGFloat(abs(yawCos)) + superViewHeight * CGFloat(abs(yawSin))
        let visionHeight = superViewWidth * CGFloat(abs(yawSin)) + superViewHeight * CGFloat(abs(yawCos))
        
        // positive x direction is rigth
        let horzOffset = CGFloat(horzAngle / fov) * visionWidth
        
        // positive y direction is down
        let verticalOffset = CGFloat(-sin(verticalAngle)) * visionHeight
        
        let xOffset = CGFloat(horzOffset) * CGFloat(yawCos) - CGFloat(verticalOffset) * CGFloat(yawSin)
        let yOffset = -(CGFloat(verticalOffset) * CGFloat(yawCos) + CGFloat(horzOffset) * CGFloat(yawSin))
        
        xPosition = superView.bounds.width / 2 + xOffset
        yPosition = perspectiveYPosition + yOffset
        
        yawRotationAngle = -(CGFloat)(yawAngle)
        horzRotationAngle = -(CGFloat)(horzAngle)
    }
    
    /**
     0 degree: back pointing to the target
     positive direction: roll left
     range: -pi ~ pi
     */
    private func getHorzAngle() -> Double {
        // the positive direction of azimuth is right, which is the opposite of rollAngle
        return angleWithinMinusPiToPi(deviceMotionManager.getHorzAngleRelToNorth() + azimuth)
    }
    
    /// tranform an angle in the range from -2PI to 2PI to the equivalent one in the range from -PI to PI, both included
    private func angleWithinMinusPiToPi(_ angle: Double) -> Double {
        if angle > M_PI {
            return angle - 2 * M_PI
        } else if angle < -M_PI {
            return angle + 2 * M_PI
        }
        return angle
    }
}













