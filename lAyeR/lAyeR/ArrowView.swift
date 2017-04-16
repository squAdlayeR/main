//
//  ArrowView.swift
//  lAyeR
//
//  Created by luoyuyang on 03/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit


/**
 This is the UIView class that represents
 the arrow pointing to the highlight checkpoint (default is the next checkpoint) when it is out of the view
 */
class ArrowView: UIView {
    var arrowImageView: UIImageView!
    
    func setup() {
        self.frame.size = ARViewConstants.cardArrowViewSize
        
        arrowImageView = UIImageView(frame: ARViewConstants.arrowImageFrame)
        arrowImageView.image = UIImage(named: ARViewConstants.cardArrowImageName)
        arrowImageView.layer.transform = CATransform3DMakeRotation(CGFloat(-Double.pi / 2.0), 0, 0, 1)
        
        self.addSubview(arrowImageView)
    }
}
