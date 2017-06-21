//
//  POISetControlDelegate.swift
//  lAyeR
//
//  Created by Desperado on 21/06/2017.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import Foundation

protocol POISetControlDelegate {
    
    /// Update position, orientation, opacity of the card and
    /// the distance displayed on the card
    ///
    /// - Parameters:
    ///   - userPoint: user's position
    ///   - superView: the super of components
    ///   - fov: the fov
    func updateComponents(userPoint: GeoPoint, superView: UIView, fov: Double)
}

extension POISetControlDelegate {
    var motionManager: DeviceMotionManager {
        get {
            return DeviceMotionManager.getInstance()
        }
    }
}
