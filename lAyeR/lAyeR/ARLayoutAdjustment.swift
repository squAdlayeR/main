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
        
        var transform = CATransform3DIdentity
        transform.m34 = -1 / 108
        transform = CATransform3DRotate(transform, yawRotationAngle, 0, 0, 1)
        let halfWidth = view.bounds.width / 2
        let halfHeight = view.bounds.height / 2
        let diagonalLength = sqrt(halfWidth * halfWidth + halfHeight * halfHeight)
        transform = CATransform3DTranslate(transform, 0, 0, diagonalLength)
        transform = CATransform3DRotate(transform, horzRotationAngle, 0, 1, 0)
        view.layer.transform = transform
    }
}

