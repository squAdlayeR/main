//
//  MarkerInfo.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 3/12/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 A class that is used to hold the distance info of a marker
 */
class MarkerInfo: UIView {

    private(set) var label: UILabel!
    private(set) var marker: BasicMarker!
    
    /// distance is able to change along the way. 
    /// 1. before it is set, check whether it is greater than 0
    /// 2. after it is set, change the corresponding label to display
    var distance: CGFloat = 0 {
        didSet {
            self.label.text = String(format: markerDistanceFilter, distance) + markerDistanceUnit
        }
    }
    
    /// Initialization
    /// - Parameter marker: the marker that this label belongs to
    init(marker: BasicMarker) {
        self.marker = marker
        let frame = CGRect(x: 0, y: marker.frame.width + marker.markerGap,
                           width: marker.frame.width,
                           height: marker.frame.height - marker.frame.width - marker.markerGap)
        super.init(frame: frame)
        prepareDisplay()
    }
    
    /// Prepares the info for display
    /// 1. sets the background image
    /// 2. sets the label in the info panel
    private func prepareDisplay() {
        initBackgroundImage()
        initLable()
    }
    
    /// Initializes background image
    private func initBackgroundImage() {
        let backgroundImage = ResourceManager.getImageView(by: bottomBannerImage)
        backgroundImage.frame = labelFrame
        self.addSubview(backgroundImage)
    }
    
    /// Initializes label
    private func initLable() {
        let newLabel = UILabel()
        newLabel.frame = labelFrame
        newLabel.text = String(format: markerDistanceFilter, distance) + markerDistanceUnit
        newLabel.font = UIFont(name: buttonFontName,
                               size: self.frame.height * (1 - markerLabelPaddingPercent * 2))
        newLabel.textColor = titleFontColor
        newLabel.textAlignment = NSTextAlignment.center
        self.label = newLabel
        self.addSubview(label)
    }
    
    /// Calculates the frame of the label
    private var labelFrame: CGRect {
        return CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
}
