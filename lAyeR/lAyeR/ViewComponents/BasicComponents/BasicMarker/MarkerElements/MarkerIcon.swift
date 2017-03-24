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
    
    var icon: UIImageView = ResourceManager.getImageView(by: markerIconName) {
        willSet {
            icon.removeFromSuperview()
        }
        didSet {
            setIcon()
        }
    }
    
    private(set) var marker: BasicMarker

    /// Initilaization
    /// - Parameters:
    ///     - marker: the marker that the icon belongs to
    ///     - icon: the icon inside the marker
    init(marker: BasicMarker) {
        self.marker = marker
        let frame = CGRect(x: 0, y: 0,
                           width: marker.frame.width,
                           height: marker.frame.width)
        super.init(frame: frame)
        prepareDisplay()
    }
    
    /// Prepares the icon view for display, including
    /// 1. prepares the background image
    /// 2. prepares the icon inside the icon view
    private func prepareDisplay() {
        initBackgroundImage()
        setIcon()
    }
    
    /// Initializes the background image
    private func initBackgroundImage() {
        let backgroundIamge = ResourceManager.getImageView(by: topBannerImage)
        backgroundIamge.frame = backgroundFrame
        self.addSubview(backgroundIamge)
    }
    
    /// Sets the icon
    private func setIcon() {
        icon.frame = iconFrame
        self.addSubview(icon)
    }
    
    /// Calculates the background image frame
    private var backgroundFrame: CGRect {
        return CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    /// Calculates the icon view frame
    private var iconFrame: CGRect {
        return CGRect(x: self.frame.width * markerIconPaddingPercent,
                      y: self.frame.height * markerIconPaddingPercent,
                      width: self.frame.width * (1 - 2 * markerIconPaddingPercent),
                      height: self.frame.height * (1 - 2 * markerIconPaddingPercent))
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        self.marker = BasicMarker(coder: aDecoder)!
        super.init(coder: aDecoder)
    }

}
