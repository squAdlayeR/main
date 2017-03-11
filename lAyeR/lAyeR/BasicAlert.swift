//
//  LayerAlert.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 3/9/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 An alert class that is to hold a basic alert in the application
 A basic alert has the following elements:
 1. top banner, which is used to hold title and icons
 2. bottom banner, which is used to hold buttons for interaction
 3. info panel, which is used to display infomation
 
 To use alert, should give a title first. Feel free to add info
 panel view and buttons before `prepareDisplay` is called.
 
 - Note: 
    1. remember to call `prepareDisplay` in order to display
    the alert
    2. Once `prepareDisplay` is called, the alert is no longer
    modifiable
 */
class BasicAlert: UIView {
    
    var bottomBanner: BottomBanner!
    var infoPanel: InfoPanel!
    var topBanner: TopBanner!
    private(set) var title: String?
    private var modifiable = true
    
    /// Initialized the alert
    /// - Parameters:
    ///     - frame: the frame of the alert
    ///     - title: the title of the alert, which is optional
    init(frame: CGRect, title: String?) {
        self.title = title
        super.init(frame: frame)
        initElements()
    }
    
    /// Initializes banners and info panel
    private func initElements() {
        initInfoPanel()
        initTopBanner()
        initBottomBanner()
    }
    
    /// Creates a new top banner
    private func initTopBanner() {
        let newTopBanner = TopBanner(alert: self, title: title)
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
    func prepareDisplay() {
        guard modifiable else { return }
        topBanner.prepareDisplay()
        bottomBanner.prepareDisplay()
        infoPanel.prepareDisplay()
        self.addSubview(infoPanel)
        self.addSubview(topBanner)
        self.addSubview(bottomBanner)
        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.alpha = 0
        modifiable = false
    }
    
    /// Inserts a view as the display view into the info panel
    func addView(_ view: UIView) {
        guard modifiable else { return }
        infoPanel.innerView = view
    }
    
    /// Adds a button into the info the bottom banner
    func addButton(_ button: UIButton) {
        guard modifiable else { return }
        bottomBanner.buttons.append(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

/**
 An extension that is used to specify all the open/close and display
 animations
 */
extension BasicAlert {
    
    /// opens the alert
    func open() {
        self.alpha = 0.3
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.alpha = 1
        }, completion: { isFinished in
            self.openBanners()
        })
    }
    
    /// opens the banners and info panel
    func openBanners() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 1
            self.topBanner.open()
            self.bottomBanner.open()
            self.infoPanel.open()
        }, completion: { isFinished in
            self.showInfo()
        })
    }
    
    /// displays info
    func showInfo() {
        UIView.animate(withDuration: 0.5, animations: {
            self.bottomBanner.showButtons()
            self.infoPanel.showInfo()
        })
    }
    
    /// closes the alert
    func close() {
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(scaleX: 0.1, y: 1)
            self.alpha = 0
        }, completion: { isFinished in
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.topBanner.close()
            self.bottomBanner.hideButtons()
            self.bottomBanner.close()
            self.infoPanel.hideInfo()
            self.infoPanel.close()
        })
    }
    
}
