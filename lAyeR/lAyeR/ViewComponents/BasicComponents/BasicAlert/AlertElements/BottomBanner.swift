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

    // The view of buttons
    private var buttonsView: UIStackView!
    
    /// Initialization
    /// - Parameters:
    ///     - width: the width of the bottom banner
    ///     - height: the height of the bottom banner
    init(width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        prepareDisplay()
    }
    
    /// Load related elements and prepare for display
    /// Typically, background and button view
    private func prepareDisplay() {
        initBackground()
        initButtonsView()
    }

    /// Initializes background image of the top banner
    private func initBackground() {
        let blurEffect = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurEffect.frame = self.bounds
        self.addSubview(blurEffect)
    }
    
    /// Initializes a stack will be used to contain buttons
    private func initButtonsView() {
        let newButtonsView = makeNewButtonsView()
        buttonsView = newButtonsView
        self.addSubview(buttonsView!)
    }
    
    /// Makes a stack view for buttons to display
    /// - Returns: the stackview that holds all the buttons
    private func makeNewButtonsView() -> UIStackView {
        let buttonStackView = UIStackView()
        let stackViewFrame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        buttonStackView.frame = stackViewFrame
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        return buttonStackView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Shows the buttons
    func showButtons() {
        buttonsView?.alpha = 1
    }
    
    /// Hides the buttons
    func hideButtons() {
        buttonsView?.alpha = 0
    }
    
    /// Adds a button into the buttons view
    func addButton(_ button: UIButton) {
        buttonsView?.addArrangedSubview(button)
    }

}
