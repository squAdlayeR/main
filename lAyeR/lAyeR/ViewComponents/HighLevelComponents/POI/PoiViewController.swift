//
//  PoiViewController.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 24/3/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

class PoiViewController: CardViewController {
    
    init(center: CGPoint, distance: Double, type: String, superView: UIView) {
        super.init(center: center, distance: distance, superView: superView)
        initializeCardTitle()
        initializeCardButtons()
        initializeCardIcon(with: type)
    }
    
    private func initializeCardIcon(with type: String) {
        if iconSet.contains(type) {
            let icon = ResourceManager.getImageView(by: type + imageExtension)
            self.markerCard.setIconImage(icon)
            return
        }
        let icon = ResourceManager.getImageView(by: otherIconType + imageExtension)
        self.markerCard.setIconImage(icon)
    }
    
    private func initializeCardTitle() {
        self.popupController.setTitle(poiTitle)
    }
    
    private func initializeCardButtons() {
        let closeButton = createCloseButton()
        let directButton = createDirectButton()
        self.popupController.addButtonToAlert(closeButton)
        self.popupController.addButtonToAlert(directButton)
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
    
    /// Creates a direct button
    /// - Returns: a direct button that would pass desired destination (a poi) to 
    ///     route designer
    private func createDirectButton() -> UIButton {
        let newButton = UIButton()
        newButton.setTitle(directLabelText, for: .normal)
        newButton.titleLabel?.font = UIFont(name: buttonFontName, size: buttonFontSize)
        // TODO: add action here
        return newButton
    }
    
}

/**
 An extension that is used to define interactions of this class
 towards the outer elements
 */
extension PoiViewController {
    
    func setPoiName(_ name: String) {
        self.popupController.addText(with: nameLabel, and: name)
    }
    
    func setPoiDescription(_ description: String) {
        self.popupController.addText(with: descriptionLabel, and: description)
    }
    
    func setPoiAddress(_ address: String) {
        self.popupController.addText(with: poiAddressLabel, and: address)
    }
    
    func setPoiContact(_ contact: String) {
        self.popupController.addText(with: poiContactLabel, and: contact)
    }
    
    func setPoiWebsite(_ website: String) {
        self.popupController.addText(with: poiWebsiteLabel, and: website)
    }
    
    func setPoiRating(_ rating: String) {
        self.popupController.addText(with: poiRatingLabel, and: rating)
    }
    
    func setPoiOpenStatus(_ status: String) {
        self.popupController.addText(with: poiOpenStatusLabel, and: status)
    }
    
}
