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
    // - Note: only keep one inner view
    var innerView: UIView? {
        willSet {
            innerView?.removeFromSuperview()
        }
        didSet {
            setInnerView()
        }
    }
    
    /// Initializes the info panel
    /// - Parameters:
    ///     - width: the width of the info panel
    ///     - height: the height of the info panel
    init(width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        prepareDisplay()
    }
    
    /// Load related elements and prepare for display
    /// Typically, initialize the background (blur) and inner view
    private func prepareDisplay() {
        initBackground()
        setInnerView()
    }
    
    /// Initializes the background
    private func initBackground() {
        let blurEffect = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurEffect.frame = self.bounds
        self.addSubview(blurEffect)
    }
    
    /// Sets the inner view of the info panel
    /// - Parameter innerView: the inner view of the info panel
    private func setInnerView() {
        guard innerView != nil else { return }
        innerView!.frame = self.bounds
        self.addSubview(innerView!)
    }
    
    /// Removes the current inner view
    private func removeCurrentInnerView() {
        guard let innerView = innerView else { return }
        innerView.removeFromSuperview()
        self.innerView = nil
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
