//
//  TopBanner.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 3/9/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 A class that is used to hold the top banner.
 A top banner might have a title
 */
class TopBanner: UIView {
    
    // The title label of the top banner
    private var titleLabel: UILabel!
    
    // The title text of the top banner
    private var title = BasicAlertConstants.emptyString {
        didSet {
            titleLabel.text = title
        }
    }
    
    /// Initialization
    /// - Parameters:
    ///     - width: the width of the top banner
    ///     - height: the height of the top banner
    ///     - title: the title of the top banner
    init(width: CGFloat, height: CGFloat, title: String) {
        let initialFrame = CGRect(x: 0, y: 0, width: width, height: height)
        super.init(frame: initialFrame)
        self.title = title
        prepareDisplay()
    }
    
    /// Load related elements and prepare for display
    /// Typtically, initialize background and title
    private func prepareDisplay() {
        initBackground()
        initTitle()
    }
    
    /// Initializes background of the top banner (blur effect)
    private func initBackground() {
        let blurEffect = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurEffect.frame = self.bounds
        self.addSubview(blurEffect)
    }
    
    /// Initializes title label of the top banner
    private func initTitle() {
        titleLabel = makeNewTitleLable()
        self.addSubview(titleLabel)
    }
    
    /// Makes a new title lable according to the new title and config
    /// - Returns: a new title label
    private func makeNewTitleLable() -> UILabel {
        let newLable = UILabel()
        newLable.frame = titleFrame
        newLable.text = title
        newLable.font = UIFont(name: UIBasicConstants.defaultFontMedium, size: BasicAlertConstants.titleFontSize)
        newLable.textColor = UIColor.white
        newLable.textAlignment = NSTextAlignment.center
        return newLable
    }
    
    /// Calculates a relatively suitable title label frame
    private var titleFrame: CGRect {
        return CGRect(x: BasicAlertConstants.titlePadding,
                      y: 0,
                      width: self.bounds.width - 2 * BasicAlertConstants.titlePadding,
                      height: self.bounds.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /* public methods */
    
    /// Show title
    func showTitle() {
        titleLabel?.alpha = 1
    }
    
    /// Hide title
    func hideTitle() {
        titleLabel?.alpha = 0
    }

    /// Sets the title of the top banner
    /// - Parameter title: the title of the banner
    func setTitle(_ title: String) {
        self.title = title
    }

}
