//
//  BasicAlertConstants.swift
//  lAyeR
//
//  Created by BillStark on 4/14/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

class BasicAlertConstants {

    static let titlePadding: CGFloat = 30
    static let titleFontSize: CGFloat = 30
    static let topBannerHeight: CGFloat = 60
    static let emptyString: String = ""
    static let topBannerErrorOffset: CGFloat = 0.1
    static let bottomBannerHeight: CGFloat = 80
    static let alertCornerRadius: CGFloat = 20
    
    // For animations
    static let openDuration: TimeInterval = 0.15
    static let originalScale: CGAffineTransform = CGAffineTransform(scaleX: 1, y: 1)
    static let initialScale: CGAffineTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    static let topBannerInitialScale: CGAffineTransform = CGAffineTransform(translationX: 0, y: 0)
    static let bottomBannerInitialScale: CGAffineTransform = CGAffineTransform(translationX: 0, y: 0)
    static let infoPanelInitialScale: CGAffineTransform = CGAffineTransform(scaleX: 1, y: 0.2)
    static let closeScale: CGAffineTransform = CGAffineTransform(scaleX: 0.1, y: 1)
    
    static let bannerOpenDuration: TimeInterval = 0.25
    static let showInfoDuration: TimeInterval = 0.5
    static let closeDuration: TimeInterval = 0.15
    
    // For alert controller
    static let maxAlertHeight: CGFloat = 800
    static let minAlertHeight: CGFloat = 250
    static let maxAlertWidth: CGFloat = 500
    static let zPosition: CGFloat = 10000
    
}
