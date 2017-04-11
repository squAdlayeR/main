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
    
    // Specifies the blur mode of the alert
    var blurMode: Bool = true {
        didSet {
            if blurMode {
                setSubviewsBlurMode(true)
                return
            }
            setSubviewsBlurMode(false)
        }
    }

    
    /// Initialized the alert
    /// - Parameter frame: the frame of the alert
    override init(frame: CGRect) {
        super.init(frame: frame)
        initElements()
        prepareDisplay()
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
    }
    
    /// Initializes banners and info panel
    private func initElements() {
        initInfoPanel()
        initTopBanner()
        initBottomBanner()
    }
    
    /// Creates a new top banner
    private func initTopBanner() {
        let newTopBanner = TopBanner(alert: self)
        topBanner = newTopBanner
    }
    
    /// Creates a new bottom banner
    private func initBottomBanner() {
        let newBottomBanner = BottomBanner(alert: self)
        bottomBanner = newBottomBanner
    }
    
    /// Creates a new info panel
    private func initInfoPanel() {
        let newInfoPanel = InfoPanel(alert: self)
        infoPanel = newInfoPanel
    }
    
    /// Prepares the alert for display
    private func prepareDisplay() {
        self.addSubview(infoPanel)
        self.addSubview(topBanner)
        self.addSubview(bottomBanner)
    }
    
    /// Inserts a view as the display view into the info panel
    func setView(_ view: UIView) {
        infoPanel.innerView = view
    }
    
    /// Adds a button into the info the bottom banner
    func addButton(_ button: UIButton) {
        bottomBanner.buttonsView.addArrangedSubview(button)
    }
    
    /// Sets the title of the alert
    func setTitle(_ title: String) {
        topBanner.title = title
    }
    
    /// Sets the blur mode of subview to specified blur mode
    /// - Parameter isBlurMode: specifies the blur mode
    private func setSubviewsBlurMode(_ isBlurMode: Bool) {
        topBanner.blurMode = isBlurMode
        infoPanel.blurMode = isBlurMode
        bottomBanner.blurMode = isBlurMode
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
        ResourceManager.playSound(with: openSound)
        UIView.animate(withDuration: 0.15, animations: { [weak self] in
            guard self != nil else { return }
            self!.transform = CGAffineTransform(scaleX: 1, y: 1)
            self!.alpha = 1
        }, completion: { [weak self] isFinished in
            self?.openBanners()
        })
    }
    
    /// Sets all elements to the transformation before animation
    private func prepareOpen() {
        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.alpha = 0
        self.topBanner.close()
        self.bottomBanner.hideButtons()
        self.bottomBanner.close()
        self.infoPanel.hideInfo()
        self.infoPanel.close()
    }
    
    /// opens the banners and info panel
    func openBanners() {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            guard self != nil else { return }
            self!.alpha = 1
            self!.topBanner.open()
            self!.bottomBanner.open()
            self!.infoPanel.open()
        }, completion: { [weak self] isFinished in
            self?.showInfo()
        })
    }
    
    /// displays info
    func showInfo() {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
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
        //ResourceManager.playSound(with: closeSound)
        UIView.animate(withDuration: 0.15, animations: { [weak self] in
            guard self != nil else { return }
            self!.transform = CGAffineTransform(scaleX: 0.1, y: 1)
            self!.alpha = 0
        }, completion: { isFinished in
            inCompletion()
        })
    }
    
}
