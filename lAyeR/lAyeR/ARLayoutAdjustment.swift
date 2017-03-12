//
//  ARLayoutAdjustment.swift
//  lAyeR
//
//  Created by luoyuyang on 09/03/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit

struct ARLayoutAdjustment {
    let xOffset: CGFloat
    let yOffset: CGFloat
    let yawRotationAngle: CGFloat
    let horzRotationAngle: CGFloat
    
    func apply(to view: UIView, within superView: UIView) {
        view.transform = CGAffineTransform(rotationAngle: CGFloat(yawRotationAngle))
        view.center.x = (superView.bounds.width - view.frame.width) / 2 + xOffset
        view.center.y = (superView.bounds.height - view.frame.height) / 2 + yOffset
        
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
        perspectiveTransform.m34 = -1 / 108
        
        // apply the 3 transformations in the order described above
        var transform = CATransform3DConcat(horzRotationTransform, yawRotationTransform)
        transform = CATransform3DConcat(transform, perspectiveTransform)

        view.layer.transform = transform
    }
}

