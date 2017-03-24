//
//  InfoPanel.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 3/9/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 A class that is used to hold the information panel.
 An information panel might have an inner view which could be
 passed as an parameter and be set in the panel
 */
class InfoPanel: UIView {

    // The inner view of the info panel
    var innerView: UIView? {
        willSet {
            innerView?.removeFromSuperview()
        }
        didSet {
            setInnerView()
        }
    }
    
    // The alert that this panel is attached to
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
    
    /// Initializes the info panel
    init(alert: BasicAlert) {
        self.alert = alert
        let infoPanelFrame = CGRect(x: 0, y: topBannerHeight,
                                    width: alert.frame.width,
                                    height: alert.frame.height - topBannerHeight - bottomBannerHeight)
        super.init(frame: infoPanelFrame)
        prepareDisplay()
    }
    
    /// Load related elements and prepare for display
    private func prepareDisplay() {
        initBackgroundImage()
        initBlurEffect()
        setInnerView()
    }
    
    /// Initializes the background image
    private func initBackgroundImage() {
        let backgroundImage = ResourceManager.getImageView(by: infoPanelImage)
        backgroundImage.frame = imageFrame
        backgroundImageView = backgroundImage
        self.addSubview(backgroundImageView)
    }
    
    /// Initializes blur effect
    private func initBlurEffect() {
        let blurEffect = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurEffect.frame = imageFrame
        blurEffectView = blurEffect
        self.addSubview(blurEffectView)
        blurEffectView.isHidden = true
    }
    
    /// Sets the inner view of the info panel
    /// - Parameter innerView: the inner view of the info panel
    private func setInnerView() {
        guard innerView != nil else { return }
        innerView!.frame = innerViewFrame
        self.addSubview(innerView!)
    }
    
    /// Removes the current inner view
    private func removeCurrentInnerView() {
        guard let innerView = innerView else { return }
        innerView.removeFromSuperview()
        self.innerView = nil
    }
    
    /// The frame of the background image
    private var imageFrame: CGRect {
        return CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    /// The frame of the inner view
    private var innerViewFrame: CGRect {
        return CGRect(x: 0, y: 0, width: self.frame.width, height: innerViewHeight)
    }
    
    /// Calculates the height of the inner panel
    private var innerViewHeight: CGFloat {
        return alert.frame.height - alert.topBanner.frame.height - alert.bottomBanner.frame.height
    }

    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
}

/**
 An extension that is used to specify the panel transformation / visibility
 */
extension InfoPanel {
    
    /// Opens the panel
    func open() {
        self.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    
    /// Closes the panel
    func close() {
        self.transform = CGAffineTransform(scaleX: 1, y: 0.2)
    }
    
    /// Shows the info
    func showInfo() {
        self.innerView?.alpha = 1
    }
    
    /// Hides the info
    func hideInfo() {
        self.innerView?.alpha = 0
    }
    
}
