//
//  MarkerIcon.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 3/12/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 A class that is to hold the icon of the marker
 - Note: the marker icon cannot be changed after initialization. During initialization, the
    marker icon is default a "marker"
 */
class MarkerIcon: UIView {

    /// Initilaization
    /// - Parameters:
    ///     - width: the width of the Icon badge
    ///     - height: the height of the icon badge
    ///     - icon: name of the icon inside the marker
    init(width: CGFloat, height: CGFloat, icon: String) {
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        super.init(frame: frame)
        prepareDisplay(with: icon)
    }
    
    /// Prepares the icon view for display, including
    /// 1. prepares the background image
    /// 2. prepares the icon inside the icon view
    private func prepareDisplay(with icon: String) {
        initBackgroundImage()
        setIcon(with: icon)
    }
    
    /// Initializes the background image
    private func initBackgroundImage() {
        let backgroundImage = UIImageView(image:
            UIImage(named: BasicMarkerConstants.backgroundImageName))
        backgroundImage.frame = self.bounds
        self.addSubview(backgroundImage)
    }
    
    /// Sets the icon
    private func setIcon(with iconName: String) {
        let icon = UIImageView(image: UIImage(named: iconName))
        icon.frame = iconFrame
        self.addSubview(icon)
    }
    
    /// Calculates the icon view frame
    private var iconFrame: CGRect {
        return CGRect(x: self.bounds.width * BasicMarkerConstants.iconPaddingPercentage,
                      y: self.bounds.height * BasicMarkerConstants.iconPaddingPercentage,
                      width: self.bounds.width * (1 - 2 * BasicMarkerConstants.iconPaddingPercentage),
                      height: self.bounds.height * (1 - 2 * BasicMarkerConstants.iconPaddingPercentage))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
