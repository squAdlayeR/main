//
//  BasicMarker.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 3/12/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 A class that is used to define a marker to be displayed on the screen
 */
class BasicMarker: UIView {
    
    // The icon of the marker
    private(set) var icon: MarkerIcon!
    
    // The info of the marker. Usually will be displaying distances
    private(set) var info: MarkerInfo!

    /// Initialization
    /// - Parameters:
    ///     - width: the width of the marker
    ///     - height: the height of the marker
    ///     - icon: the icon of the marker
    init(size: CGSize, icon: String) {
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        super.init(frame: frame)
        initializeElements(with: icon)
        stylizeMarker()
    }
    
    /// Initializes the marker elements
    /// - Parameter icon: the icon image of the marker
    private func initializeElements(with icon: String) {
        initIcon(with: icon)
        initInfo()
    }
    
    /// Initializes the icon of the marker
    /// - Parameter icon: the icon image
    private func initIcon(with icon: String) {
        let newIcon = MarkerIcon(width: self.bounds.width,
                                 height: self.bounds.width,
                                 icon: icon)
        newIcon.frame.origin = CGPoint(x: 0, y: 0)
        self.addSubview(newIcon)
    }
    
    /// Initializes the marker info
    private func initInfo() {
        let newInfo = MarkerInfo(width: self.bounds.width,
                                 height: self.bounds.height * (1 - BasicMarkerConstants.gapPercentage) - self.bounds.width)
        newInfo.frame.origin = CGPoint(x: 0,
                                       y: self.bounds.height * BasicMarkerConstants.gapPercentage + self.bounds.width)
        self.info = newInfo
        self.addSubview(self.info)
    }
    
    /// Defines stylings of the marker
    private func stylizeMarker() {
        self.layer.cornerRadius = BasicMarkerConstants.cornerRadius
        self.layer.masksToBounds = true
    }
    
    /// Sets the distance displayed on the marker
    /// - Parameter newDistance: the new distance to be displayed
    func updateDistance(with newDistance: Double) {
        self.info.updateDistance(with: newDistance)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
