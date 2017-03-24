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
class CheckpointViewController: CardViewController {
    
    override init(center: CGPoint, distance: Double, superView: UIView) {
        super.init(center: center, distance: distance, superView: superView)
        initializeCardTitle()
        initializeCardButtons()
    }
    
    private func initializeCardTitle() {
        self.popupController.setTitle(checkpointTitle)
    }
    
    private func initializeCardButtons() {
        let closeButton = createCloseButton()
        self.popupController.addButtonToAlert(closeButton)
    }
    
    /// Creates a close button
    /// - Returns: a close button which will close the popup if it is clicked
    private func createCloseButton() -> UIButton {
        let newButton = UIButton()
        newButton.setTitle(confirmLabelText, for: .normal)
        newButton.titleLabel?.font = UIFont(name: buttonFontName, size: buttonFontSize)
        newButton.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        return newButton
    }
    
}

/**
 An extension that is used to define interactions of this class
 towards the outer elements
 */
extension CheckpointViewController {
    
    func setCheckpointName(_ name: String) {
        self.popupController.addText(with: nameLabel, and: name)
    }
    
    func setCheckpointDescription(_ description: String) {
        self.popupController.addText(with: descriptionLabel, and: description)
    }
    
}
