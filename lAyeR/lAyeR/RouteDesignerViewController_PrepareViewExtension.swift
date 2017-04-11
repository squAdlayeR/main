//
//  RouteDesignerViewController_PrepareView.swift
//  lAyeR
//
//  Created by BillStark on 4/11/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

extension RouteDesignerViewController {

    func prepareBottomBanner() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = mostBottomBanner.bounds
        
        let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        vibrancyView.frame = blurEffectView.bounds
        for subview in mostBottomBanner.subviews {
            subview.removeFromSuperview()
            vibrancyView.contentView.addSubview(subview)
        }
        mostBottomBanner.addSubview(blurEffectView)
        mostBottomBanner.addSubview(vibrancyView)
    }

}
