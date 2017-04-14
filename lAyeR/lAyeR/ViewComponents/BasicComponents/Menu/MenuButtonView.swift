//
//  MenuButtonView.swift
//  ViewComponentTesting
//
//  Created by Yang Zhuohan on 26/3/17.
//  Copyright © 2017 Yang Zhuohan. All rights reserved.
//

import UIKit

/**
 This is a class that is used to create menu buttons specially for
 lAyeR. However, the buttons could be changed with changes of its
 background image and button icon
 - Note: gesture recognizers will be defined outside this class
 */
class MenuButtonView: UIView {

    // Defines the vibrancy view of the icon
    private var vibrancyView: UIVisualEffectView!
    
    /// Initialization
    /// - Parameters:
    ///     - radius: the radius of the button (representing width and height)
    ///     - iconName: the name of the icon
    init(radius: CGFloat, iconName: String) {
        let frame = CGRect(x: 0, y: 0, width: radius, height: radius)
        super.init(frame: frame)
        initBackground()
        initIcon(with: iconName)
    }

    /// Initializes the background of the buttons
    private func initBackground() {
        
        // Initialize blur view effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = CGRect(x: 0, y: 0,
                                      width: self.bounds.width - 2 * MenuConstants.buttonInnerPadding,
                                      height: self.bounds.width - 2 * MenuConstants.buttonInnerPadding)
        blurEffectView.center = self.center
        blurEffectView.layer.cornerRadius = blurEffectView.bounds.width / 2
        blurEffectView.layer.masksToBounds = true
        
        // Initialize vibrancy effect view
        vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        vibrancyView.frame = blurEffectView.frame
        
        // Insert views inside
        self.addSubview(blurEffectView)
        self.addSubview(vibrancyView)
    }
    
    /// Initializes the icon on the button
    /// - Parameter iconName: the name of the icon image
    private func initIcon(with iconName: String) {
        let iconImage = UIImageView(image: UIImage(named: iconName))
        iconImage.frame = CGRect(x: vibrancyView.bounds.width * MenuConstants.iconPaddingPercent,
                                 y: vibrancyView.bounds.height * MenuConstants.iconPaddingPercent,
                                 width: vibrancyView.bounds.width * (1 - 2 * MenuConstants.iconPaddingPercent),
                                 height: vibrancyView.bounds.height * (1 - 2 * MenuConstants.iconPaddingPercent))
        vibrancyView.contentView.addSubview(iconImage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
