//
//  Setting.swift
//  lAyeR
//
//  Created by luoyuyang on 23/03/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit

class Constant {
    static let nearbyPOIsUpdatedNotificationName = "nearbyPOIsUpdatedNotification"
    static let userLocationUpdatedNotificationName = "userLocationUpdatedNotification"
    
    static let projectionPlaneDistance: CGFloat = 600
    
    static let maxPushBackDistance: CGFloat = 480
    static let maxSearchDistance: Double = 800
    static let pathArrowName = "arrow14"
    static let pathArrowExtension = "obj"
    static let movingOnActionKey: String = "movingOnAction"

    static let arrowGap = 1.8  // Unit: meter
    static let arrowOpacity = 0.38
    static let arrowDefaultColorR: CGFloat = 0
    static let arrowDefaultColorG: CGFloat = 0.9098
    static let arrowDefaultColorB: CGFloat = 0.9098
    static let arrowDefaultColorAlpha: CGFloat = 1.0
    static let arrowDefaultColor = UIColor(red: arrowDefaultColorR,
                                           green: arrowDefaultColorG,
                                           blue: arrowDefaultColorB,
                                           alpha: arrowDefaultColorAlpha)
    static let framePerSecond = 60
    
    static let numCheckpointDisplayedForward = 1
    static let numCheckpointDisplayedBackward = 0
    
    static let numArrowsDisplayedForward = 18
    static let numArrowsDisplayedBackward = 12
    
    static let arrivalDistanceThreshold: Double = 10
    static let checkCloseRange = 1
    
    static let arrowActionKey = "arrowAction"
    
    static let targetColorR: CGFloat = 1
    static let targetColorG: CGFloat = 1
    static let targetColorB: CGFloat = 1
    
    static let maxMarkerAlpha: CGFloat = 0.8
    static let markerAlphaChangeRange: CGFloat = 0.38
}










