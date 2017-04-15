//
//  MiscConstants.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 13/4/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

class MiscConstants {

    // For text fields
    static let textFieldBorderWidth: CGFloat = 1
    static let textFieldBorderColor: CGColor = UIColor.white.cgColor
    static let textFieldFontSize: CGFloat = 26
    
    // For Route list cells
    static let overlayBackgroundColor: UIColor = UIColor(red: CGFloat(48 / 255),
                                                         green: CGFloat(52 / 255),
                                                         blue: CGFloat(65 / 255),
                                                         alpha: 0.5)
    static let cornerRadius: CGFloat = 5
    
    // For POI categories cell
    static let coloredIconExtension = "-colored"
    
    // For loading badge
    static let badgeOverLayFrame: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100)
    static let bdageIndicatorFrame: CGRect = CGRect(x: 0, y: 0, width: 60, height: 60)
    static let badgeCornerRadius: CGFloat = 10

}
