//
//  LoadingOverlay.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/5.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit

public class LoadingBadge {
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    static let instance: LoadingBadge = LoadingBadge()
    
    init() {
        overlayView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        overlayView.backgroundColor = UIColor.darkGray
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = overlayView.center
        overlayView.addSubview(activityIndicator)
    }
    
    public func showBadge(in view: UIView) {
        overlayView.center = view.center
        view.addSubview(overlayView)
        view.bringSubview(toFront: overlayView)
        activityIndicator.startAnimating()
    }
    
    public func hideBadge() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}
