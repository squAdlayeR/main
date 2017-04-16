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

    // The label that is used to display text
    private var label: UILabel!
    
    /// distance is able to change along the way.
    /// after it is set, change the corresponding label to display
    private var distance: Double = 0 {
        didSet {
            self.label.text = "\(String(format: BasicMarkerConstants.distanceFilter, distance))\(BasicMarkerConstants.distanceUnit)"
        }
    }
    
    /// Initialization
    /// - Parameters:
    ///     - width: the width of the marker
    ///     - height: the height of the marker
    init(width: CGFloat, height: CGFloat) {
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
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
        let backgroundImage = UIImageView(image:
            UIImage(named: BasicMarkerConstants.backgroundImageName))
        backgroundImage.frame = self.bounds
        self.addSubview(backgroundImage)
    }
    
    /// Initializes label
    private func initLable() {
        let newLabel = UILabel()
        newLabel.frame = self.bounds
        newLabel.text = "\(String(format: BasicMarkerConstants.distanceFilter, distance))\(BasicMarkerConstants.distanceUnit)"
        newLabel.font = UIFont(name: alterDefaultFontLight,
                               size: BasicMarkerConstants.labelFontSize)
        newLabel.textColor = UIColor.white
        newLabel.textAlignment = NSTextAlignment.center
        self.label = newLabel
        self.addSubview(label)
    }
    
    /// Updates the distance on the card accordingly
    /// - Parameter newValue: the new value of the distance
    func updateDistance(with newValue: Double) {
        self.distance = newValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
