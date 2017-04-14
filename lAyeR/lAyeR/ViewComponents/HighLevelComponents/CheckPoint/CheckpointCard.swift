//
//  CheckpointView.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 3/12/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 Note: this class is specifically used for check point marker.
 Main functionality:
 1. displayes a marker with a specified frame
 2. clicking on the marker will show an popup, which displays
    infomation about the marker. To be more specific, for 
    checkpoints, only name and a short description will be 
    displayed
 */
class CheckpointCard: Card {
    
    /// Initialization
    /// - Parameters:
    ///     - center: the initial center of the marker
    ///     - distance: the distance between current place to the check point
    ///     - superView: the super view that the check point view is attachend to
    init(distance: Double, superViewController: UIViewController) {
        super.init(distance: distance, icon: "marker", superViewController: superViewController)
        initializeCardTitle()
        initializeCardButtons()
    }
    
    /// Initializes the card title
    private func initializeCardTitle() {
        self.popupController.setAlertTitle(checkpointTitle)
    }
    
    /// Initializes the buttons on the card
    private func initializeCardButtons() {
        let closeButton = createCloseButton()
        self.popupController.addButtonToAlert(closeButton)
    }
    
    /// Creates a close button
    /// - Returns: a close button which will close the popup if it is clicked
    private func createCloseButton() -> UIButton {
        let newButton = UIButton()
        newButton.setTitle(confirmLabelText, for: .normal)
        newButton.titleLabel?.font = UIFont(name: alterDefaultFontRegular, size: buttonFontSize)
        newButton.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        return newButton
    }
    
}

/**
 An extension that is used to define interactions of this class
 towards the outer elements
 */
extension CheckpointCard {
    
    /// Sets the name of the check point
    /// - Parameter name: the name of the check point
    func setCheckpointName(_ name: String) {
        self.popupController.addText(with: nameLabel, iconName: nameIcon, and: name)
    }
    
    /// Sets the description of the check point
    /// - Parameter description: the description of the check point
    func setCheckpointDescription(_ description: String) {
        self.popupController.addText(with: descriptionLabel, iconName: descriptionIcon, and: description)
    }
    
}
