//
//  BottomBanner.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 3/9/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 A class that is used to hold the bottom banner.
 A button banner may have a list of buttons
 */
class BottomBanner: UIView {

    var buttonsView: UIStackView?
    var buttons = [UIButton]()
    private(set) var alert: BasicAlert!
    
    /// Initialization
    init(alert: BasicAlert) {
        self.alert = alert
        let bottomBannerFrame = CGRect(x: 0, y: alert.frame.height / 2,
                                    width: alert.frame.width,
                                    height: bottomBannerHeight)
        super.init(frame: bottomBannerFrame)
    }
    
    /// Load related elements and prepare for display
    func prepareDisplay() {
        initBackgroundImage()
        initButtons()
    }

    /// Initializes background image of the top banner
    private func initBackgroundImage() {
        let backgroundImage = ResourceManager.getImageView(by: bottomBannerImage)
        backgroundImage.frame = imageFrame
        self.addSubview(backgroundImage)
    }
    
    /// Initializes the buttons of the alert with specified buttons
    private func initButtons() {
        let newButtonsView = makeNewButtonsView(with: buttons)
        buttonsView = newButtonsView
        self.addSubview(buttonsView!)
    }
    
    /// Makes a stack view for buttons to display
    /// - Parameter buttons: the buttons that to be displayed
    /// - Returns: the stackview that holds all the buttons
    private func makeNewButtonsView(with buttons: [UIButton]) -> UIStackView {
        let buttonStackView = UIStackView(arrangedSubviews: buttons)
        let stackViewFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        buttonStackView.frame = stackViewFrame
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        buttonStackView.alpha = 0
        return buttonStackView
    }
    
    /// Calculates a relatively suitable background image frame
    private var imageFrame: CGRect {
        return CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/**
 An extension that is used to set bottom banner movement / visibility
 */
extension BottomBanner {
    
    /// Opens the top banner
    func open() {
        self.transform = CGAffineTransform(translationX: 0,
                                           y: self.alert.frame.height / 2 - self.frame.height)
    }
    
    /// Closes the top banner
    func close() {
        self.transform = CGAffineTransform(translationX: 0,
                                           y: 0)
    }
    
    /// Shows the buttons
    func showButtons() {
        buttonsView?.alpha = 1
    }
    
    /// Hides the buttons
    func hideButtons() {
        buttonsView?.alpha = 0
    }
    
}
