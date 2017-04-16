//
//  LoadingOverlay.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/5.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import UIKit
/*
 * LoadingBadge is a singleton instance of a partially customized
 * actitivity indicator view to show process.
 */
public class LoadingBadge {
    
    /// Defines the overlay view of the badge
    private var overlayView = UIView()
    
    /// Defines the activity indicator view of the badge
    private var activityIndicator = UIActivityIndicatorView()
    
    /// Returns the instance of the loading badge
    static let instance: LoadingBadge = LoadingBadge()
    
    /// Initializes the badge.
    init() {
        overlayView.frame = MiscConstants.badgeOverLayFrame
        overlayView.backgroundColor = UIColor.darkGray
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = MiscConstants.badgeCornerRadius
        activityIndicator.frame = MiscConstants.bdageIndicatorFrame
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = overlayView.center
        overlayView.addSubview(activityIndicator)
    }
    
    /// Shows the badge in specified UIView and start animating
    /// - Parameter view: UIView: the view to display to the badge
    public func showBadge(in view: UIView) {
        overlayView.center = view.center
        view.addSubview(overlayView)
        view.bringSubview(toFront: overlayView)
        activityIndicator.startAnimating()
    }
    
    /// Hides the badge and remove it from super view
    public func hideBadge() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
    
}
