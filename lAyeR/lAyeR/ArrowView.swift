//
//  ArrowView.swift
//  lAyeR
//
//  Created by luoyuyang on 03/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit

class ArrowView: UIView {
    var arrowImageView: UIImageView!
    
    func setup() {
        self.frame.size = CGSize(width: 28, height: 60)
        
        let arrowFrame = CGRect(x: 0, y: 38, width: 28, height: 22)
        arrowImageView = UIImageView(frame: arrowFrame)
        arrowImageView.image = UIImage(named: Constant.cardArrowImageName)
        arrowImageView.layer.transform = CATransform3DMakeRotation(CGFloat(-M_PI / 2.0), 0, 0, 1)
        
        self.addSubview(arrowImageView)
    }
}
