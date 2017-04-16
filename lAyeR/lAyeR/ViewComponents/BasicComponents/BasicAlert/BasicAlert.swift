//
//  LayerAlert.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 3/9/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit
import AVFoundation

/**
 An alert class that is to hold a basic alert in the application
 A basic alert has the following elements:
 1. top banner, which is used to hold title and icons
 2. bottom banner, which is used to hold buttons for interaction
 3. info panel, which is used to display infomation
 
 To use alert, feel free to add info panel view, buttons and 
 alert title using functions provided:
 1. setView
 2. addButton
 3. setTitle
 */
class BasicAlert: UIView {
    
    // The bottom banner of the alert. it will be holding interactive
    // buttons
    var bottomBanner: BottomBanner!
    
    // The info panel of the alert. it will be displaying detailed
    // information
    var infoPanel: InfoPanel!
    
    // The top banner of the alert. it will be displaying title
    var topBanner: TopBanner!

    
    /// Initialized the alert
    /// - Parameters:
    ///     - width: the width of the alert
    ///     - height: the height of the alert
    ///     - title: the title of the alert
    init(width: CGFloat, height: CGFloat, title: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        stylizeAlert()
        initElements(with: title)
    }
    
    /// Defines basic styling of the alert
    private func stylizeAlert() {
        self.layer.cornerRadius = BasicAlertConstants.alertCornerRadius
        self.layer.masksToBounds = true
    }
    
    /// Initializes banners and info panel
    /// - Parameter title: the title of top banner
    private func initElements(with title: String) {
        initInfoPanel()
        initTopBanner(with: title)
        initBottomBanner()
    }
    
    /// Creates a new top banner with title
    /// - Parameter title: the title of the alert
    private func initTopBanner(with title: String) {
        let newTopBanner = TopBanner(width: self.bounds.width,
                                     height: BasicAlertConstants.topBannerHeight,
                                     title: title)
        newTopBanner.frame.origin = CGPoint(x: 0,
                                            y: self.bounds.height / 2
                                                - BasicAlertConstants.topBannerHeight
                                                + BasicAlertConstants.topBannerErrorOffset)
        topBanner = newTopBanner
        self.addSubview(topBanner)
    }
    
    /// Creates a new bottom banner
    private func initBottomBanner() {
        let newBottomBanner = BottomBanner(width: self.bounds.width,
                                           height: BasicAlertConstants.bottomBannerHeight)
        newBottomBanner.frame.origin = CGPoint(x: 0,
                                               y: self.bounds.height / 2)
        bottomBanner = newBottomBanner
        self.addSubview(bottomBanner)
    }
    
    /// Creates a new info panel
    private func initInfoPanel() {
        let newInfoPanel = InfoPanel(width: self.bounds.width,
                                     height: self.bounds.height
                                        - BasicAlertConstants.topBannerHeight
                                        - BasicAlertConstants.bottomBannerHeight)
        newInfoPanel.frame.origin = CGPoint(x: 0, y: BasicAlertConstants.topBannerHeight)
        infoPanel = newInfoPanel
        self.addSubview(infoPanel)
    }
    
    /// Inserts a view as the display view into the info panel
    /// - Parameter view: the view that is going to be inserted into info panel
    func setView(_ view: UIView) {
        infoPanel.innerView = view
    }
    
    /// Adds a button into the info the bottom banner
    /// - Parameter button: the button that is to be added into bottom panel
    func addButton(_ button: UIButton) {
        bottomBanner.addButton(button)
    }
    
    /// Sets the title of the alert
    /// - Parameter title: the title of the alert
    func setTitle(_ title: String) {
        topBanner.setTitle(title)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

/**
 An extension that is used to specify all the open/close and display
 animations
 */
extension BasicAlert {
    
    /// opens the alert
    func open() {
        prepareOpen()
        ResourceManager.playSound(with: UIBasicConstants.openSound)
        UIView.animate(withDuration: BasicAlertConstants.openDuration, animations: { [weak self] in
            guard self != nil else { return }
            self!.transform = BasicAlertConstants.originalScale
            self!.alpha = 1
        }, completion: { [weak self] isFinished in
            self?.openBanners()
        })
    }
    
    /// Sets all elements to the transformation before animation
    private func prepareOpen() {
        self.alpha = 0
        self.transform = BasicAlertConstants.initialScale
        self.topBanner.transform = BasicAlertConstants.topBannerInitialScale
        self.bottomBanner.hideButtons()
        self.bottomBanner.transform = BasicAlertConstants.bottomBannerInitialScale
        self.infoPanel.hideInfo()
        self.infoPanel.transform = BasicAlertConstants.infoPanelInitialScale
    }
    
    /// opens the banners and info panel
    func openBanners() {
        UIView.animate(withDuration: BasicAlertConstants.bannerOpenDuration, animations: { [weak self] in
            guard self != nil else { return }
            self!.alpha = 1
            self!.topBanner.transform = CGAffineTransform(translationX: 0,
                                                          y: 0 - (self!.bounds.height / 2 - self!.topBanner.bounds.height))
            self!.bottomBanner.transform = CGAffineTransform(translationX: 0,
                                                             y: self!.bounds.height / 2 - self!.bottomBanner.bounds.height)
            self!.infoPanel.transform = BasicAlertConstants.originalScale
        }, completion: { [weak self] isFinished in
            self?.showInfo()
        })
    }
    
    /// displays info
    func showInfo() {
        UIView.animate(withDuration: BasicAlertConstants.showInfoDuration, animations: { [weak self] in
            guard self != nil else { return }
            self!.bottomBanner.showButtons()
            self!.infoPanel.showInfo()
        })
    }
    
    /// closes the alert
    /// - Parameter inCompletion: the function that is going to
    ///     be executed after the animation is completed
    /// - Note: the function need to add @escaping since inCompletion
    ///     may refer to some functions that has reference to `self`
    func close(inCompletion: @escaping () -> Void) {
        UIView.animate(withDuration: BasicAlertConstants.closeDuration, animations: { [weak self] in
            guard self != nil else { return }
            self!.transform = BasicAlertConstants.closeScale
            self!.alpha = 0
        }, completion: { isFinished in
            inCompletion()
        })
    }
    
}
