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
        let backgroundImage = UIImageView(image: UIImage(named: menuButtonBackgroundImage))
        backgroundImage.frame = CGRect(x: 0, y: 0,
                                       width: self.bounds.width,
                                       height: self.bounds.height)
        self.addSubview(backgroundImage)
    }
    
    /// Initializes the icon on the button
    private func initIcon(with iconName: String) {
        let iconImage = UIImageView(image: UIImage(named: iconName))
        iconImage.frame = CGRect(x: self.bounds.width * menuButtonIconPaddingPercent,
                                 y: self.bounds.height * menuButtonIconPaddingPercent,
                                 width: self.bounds.width * (1 - 2 * menuButtonIconPaddingPercent),
                                 height: self.bounds.height * (1 - 2 * menuButtonIconPaddingPercent))
        self.addSubview(iconImage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
