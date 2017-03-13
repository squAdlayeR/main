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
 passed as an parameter during initialization
 */
class InfoPanel: UIView {

    var innerView: UIView? {
        willSet { removeCurrentInnerView() }
        didSet { setInnerView() }
    }
    
    private(set) var alert: BasicAlert!
    
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
        setInnerView()
        self.transform = CGAffineTransform(scaleX: 1, y: 0.2)
    }
    
    /// Initializes the background image
    private func initBackgroundImage() {
        let backgroundImage = ResourceManager.getImageView(by: infoPanelImage)
        backgroundImage.frame = imageFrame
        self.addSubview(backgroundImage)
    }
    
    /// Sets the inner view of the info panel
    /// - Parameter innerView: the inner view of the info panel
    private func setInnerView() {
        guard let innerView = innerView else { return }
        innerView.frame = innerViewFrame
        innerView.alpha = 1
        self.innerView = innerView
        self.addSubview(innerView)
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
        return CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
