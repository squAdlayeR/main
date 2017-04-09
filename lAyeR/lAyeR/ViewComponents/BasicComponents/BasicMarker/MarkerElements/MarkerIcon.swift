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
    
    // The icon that will be displayed on the marker
    var icon: UIImageView = ResourceManager.getImageView(by: markerIconName) {
        willSet {
            icon.removeFromSuperview()
        }
        didSet {
            setIcon()
        }
    }
    
    // The marker that this marker icon is attached to
    private(set) var marker: BasicMarker!
    
    // The background image of the banner
    private var backgroundImageView: UIImageView!
    
    // The blur effect
    private var blurEffectView: UIVisualEffectView!
    
    // Sets blur mode. If it is true, blur view should
    // be shown.
    var blurMode: Bool = true {
        didSet {
            if blurMode {
                backgroundImageView.isHidden = true
                blurEffectView.isHidden = false
                return
            }
            backgroundImageView.isHidden = false
            blurEffectView.isHidden = true
        }
    }

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
        initBlurEffect()
        setIcon()
    }
    
    /// Initializes the background image
    private func initBackgroundImage() {
        let backgroundIamge = ResourceManager.getImageView(by: topBannerImage)
        backgroundIamge.frame = backgroundFrame
        backgroundImageView = backgroundIamge
        self.addSubview(backgroundImageView)
    }
    
    /// Initializes the blur effect
    private func initBlurEffect() {
        let blurEffect = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurEffect.frame = backgroundFrame
        blurEffectView = blurEffect
        self.addSubview(blurEffectView)
        blurEffectView.isHidden = true
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
        super.init(coder: aDecoder)
    }

}
