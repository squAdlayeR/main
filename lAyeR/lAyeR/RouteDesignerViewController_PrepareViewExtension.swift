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
        
        mostBottomBanner.addSubview(blurEffectView)
        mostBottomBanner.sendSubview(toBack: blurEffectView)
    }

}
