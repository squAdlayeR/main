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
    let rotationAngle: CGFloat
    
    func apply(to view: UIView, within superView: UIView) {
        view.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
        view.center.x = (superView.bounds.width - view.frame.width) / 2 + xOffset
        view.center.y = (superView.bounds.height - view.frame.height) / 2 + yOffset
    }
}

