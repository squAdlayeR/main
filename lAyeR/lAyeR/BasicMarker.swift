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
    
    private(set) var icon: MarkerIcon!
    private(set) var info: MarkerInfo!

    /// Initialization
    /// - Parameters:
    ///     - frame: the frame of the marker
    ///     - icon: the icon of the marker
    init(frame: CGRect, icon: UIImageView) {
        super.init(frame: frame)
        initializeElements(with: icon)
        prepareDisplay()
    }
    
    /// Initializes the marker elements
    /// - Parameter icon: the icon image of the marker
    private func initializeElements(with icon: UIImageView) {
        initIcon(with: icon)
        initInfo()
    }
    
    /// Initializes the icon of the marker
    /// - Parameter iconImage: the icon image
    private func initIcon(with iconImage: UIImageView) {
        let newIcon = MarkerIcon(marker: self, icon: iconImage)
        self.icon = newIcon
    }
    
    /// Initializes the marker info
    private func initInfo() {
        let newInfo = MarkerInfo(marker: self)
        self.info = newInfo
    }
    
    /// Prepares the marker for display. i.e. add them
    /// all into subview
    private func prepareDisplay() {
        self.addSubview(self.icon)
        self.addSubview(self.info)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Calculates the gap of between maker icon and marker label
    var markerGap: CGFloat {
        return self.frame.height * markerGapPercent
    }

}
