//
//  ViewLayoutAdjustable.swift
//  lAyeR
//
//  Created by luoyuyang on 21/03/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit

protocol ViewLayoutAdjustable {
    func applyViewAdjustment(_ adjustment: ARViewLayoutAdjustment);
    func removeFromSuperview()
}


extension UIView: ViewLayoutAdjustable {
    func applyViewAdjustment(_ adjustment: ARViewLayoutAdjustment) {

        let view = self

        let yawRotationAngle = adjustment.yawRotationAngle
        let horzRotationAngle = adjustment.horzRotationAngle
        
        view.center.x = adjustment.xPosition
        view.center.y = adjustment.yPosition
        
        // set z position for the layer to solve the following problem:
        // when rotate, the further half of the layer will disappear
        let halfWidth = view.bounds.width / 2
        let halfHeight = view.bounds.height / 2
        let diagonalLength = sqrt(halfWidth * halfWidth + halfHeight * halfHeight)
        view.layer.zPosition = diagonalLength
        
        // define the matrices for the following 3 transformation:
        // 1. rotation around the veritical line
        // 2. rotaiton around the z-axis of the device
        // 3. perspective projection
        let horzRotationTransform = CATransform3DMakeRotation(horzRotationAngle, 0, 1, 0)
        let yawRotationTransform = CATransform3DMakeRotation(yawRotationAngle, 0, 0, 1)
        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = -1 / 600
        
        // apply the 3 transformations in the order described above
        var transform = CATransform3DIdentity
        transform = CATransform3DConcat(transform, horzRotationTransform)
        transform = CATransform3DConcat(transform, yawRotationTransform)
        transform = CATransform3DConcat(transform, perspectiveTransform)
        
        view.layer.transform = transform
    }
}
