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

class ARCalculator {
//    static func calculateViewAdjustment(motion: CMDeviceMotion) -> ViewAdjustment {
//        let rotationMatrix = motion.attitude.rotationMatrix
//        
//    }
}


struct ViewAdjustment {
    let xOffset: CGFloat
    let yOffset: CGFloat
    let alpha: CGFloat
    let rotationAngle: CGFloat
    
    func apply(to view: UIView, within superView: UIView) {
        
    }
}
