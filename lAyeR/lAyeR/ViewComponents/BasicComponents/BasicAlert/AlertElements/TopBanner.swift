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
 A top banner might have:
 1. A title
 2. An icon (not implemented yet)
 */
class TopBanner: UIView {
    
    // The title label of the top banner
    var titleLabel: UILabel!
    
    // The title text of the top banner
    var title: String = titlePlaceHolder {
        didSet {
            titleLabel.text = title
        }
    }
    
    // The alert that this top banner is attached to
    private(set) var alert: BasicAlert!
    
    // The background image of the banner
    private var backgroundImageView: UIImageView!
    
    // The blur effect
    private var blurEffectView: UIVisualEffectView!
    
    // Sets blur mode. If it is true, blur view should
    // be shown.
    var blurMode: Bool = false {
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
    
    /// Initialization
    init(alert: BasicAlert) {
        self.alert = alert
        let topBannerFrame = CGRect(x: 0, y: alert.frame.height / 2 - topBannerHeight + 0.1,
                                    width: alert.frame.width,
                                    height: topBannerHeight)
        super.init(frame: topBannerFrame)
        prepareDisplay()
    }
    
    /// Load related elements and prepare for display
    private func prepareDisplay() {
        initBackgroundImage()
        initBlurEffect()
        initTitle()
    }
    
    /// Initializes background image of the top banner
    private func initBackgroundImage() {
        let backgroundImage = ResourceManager.getImageView(by: topBannerImage)
        backgroundImage.frame = imageFrame
        backgroundImageView = backgroundImage
        self.addSubview(backgroundImageView)
    }
    
    /// Initializes blur effect
    private func initBlurEffect() {
        let blurEffect = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurEffect.frame = imageFrame
        blurEffectView = blurEffect
        self.addSubview(blurEffectView)
        blurEffectView.isHidden = true
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
        newLable.font = UIFont(name: titleFontName, size: titleFontSize)
        newLable.textColor = titleFontColor
        newLable.textAlignment = NSTextAlignment.center
        return newLable
    }
    
    /// Calculates a relatively suitable background image frame
    private var imageFrame: CGRect {
        return CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    /// Calculates a relatively suitable title label frame
    private var titleFrame: CGRect {
        return CGRect(x: titlePadding, y: 0, width: self.frame.width - 2 * titlePadding, height: self.frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }

}

/**
 An extension that is used to set top banner movement / visibility
 */
extension TopBanner {
    
    /// Opens the top banner
    func open() {
        self.transform = CGAffineTransform(translationX: 0,
                                           y: 0 - (self.alert.frame.height / 2 - self.frame.height))
    }
    
    /// Closes the top banner
    func close() {
        self.transform = CGAffineTransform(translationX: 0,
                                           y: 0)
    }
    
    /// Show title
    func showTitle() {
        titleLabel?.alpha = 1
    }
    
    /// Hide title
    func hideTitle() {
        titleLabel?.alpha = 0
    }
    
}
