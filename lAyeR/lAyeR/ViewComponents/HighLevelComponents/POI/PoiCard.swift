//
//  PoiCard.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 24/3/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 Note: this class is specifically used for poi marker.
 Main functionality:
 1. displayes a marker with a specified frame
 2. clicking on the marker will show an popup, which displays
 infomation about the marker. To be more specific, for
 poi, the possible information include
 - name
 - description
 - address
 - contact
 - website
 - rating
 - open status
 */
class PoiCard: Card {
    
    /// Initializes the poi view controller
    /// - Parameters:
    ///     - center: the initial center of the marker
    ///     - distance: the distance between current place and that place
    ///     - type: the type of the poi
    ///     - superView: the view that this popup & marker is attached to
    init(center: CGPoint, distance: Double, type: String, superView: UIView) {
        super.init(center: center, distance: distance, superView: superView)
        initializeCardTitle()
        initializeCardButtons()
        initializeCardIcon(with: type)
    }
    
    /// Initializes the card icon with its type
    /// - Parameter type: the type of the icon
    private func initializeCardIcon(with type: String) {
        var sanitizedType = type
        if let category = POICategory(rawValue: type) {
            let icon = ResourceManager.getImageView(by: category.rawValue)
            self.markerCard.setIconImage(icon)
            return
        }
        sanitizedType = otherIconType
        let icon = ResourceManager.getImageView(by: sanitizedType)
        self.markerCard.setIconImage(icon)
    }
    
    /// Initializes the card title
    private func initializeCardTitle() {
        self.popupController.setTitle(poiTitle)
    }
    
    /// Initializes the card buttons which include
    /// 1. close button
    /// 2. direct button
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
        newButton.titleLabel?.font = UIFont(name: alterDefaultFontRegular, size: buttonFontSize)
        newButton.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        return newButton
    }
    
    /// Creates a direct button
    /// - Returns: a direct button that would pass desired destination (a poi) to 
    ///     route designer
    private func createDirectButton() -> UIButton {
        let newButton = UIButton()
        newButton.setTitle(directLabelText, for: .normal)
        newButton.titleLabel?.font = UIFont(name: alterDefaultFontRegular, size: buttonFontSize)
        // TODO: add action here
        return newButton
    }
    
}

/**
 An extension that is used to define interactions of this class
 towards the outer elements
 */
extension PoiCard {
    
    /// Sets the name of poi
    /// - Parameter name: the name of the poi
    func setPoiName(_ name: String) {
        self.popupController.addText(with: nameLabel, and: name)
    }
    
    /// Sets the description of poi
    /// - Parameter description: the description of the poi
    func setPoiDescription(_ description: String) {
        self.popupController.addText(with: descriptionLabel, and: description)
    }
    
    /// Sets the addresss of poi
    /// - Parameter address: the address of the poi
    func setPoiAddress(_ address: String) {
        self.popupController.addText(with: poiAddressLabel, and: address)
    }
    
    /// Sets the contact of poi
    /// - Parameter contact: the contact of the poi
    func setPoiContact(_ contact: String) {
        self.popupController.addText(with: poiContactLabel, and: contact)
    }
    
    /// Sets the website of poi
    /// - Parameter website: the website of the poi
    func setPoiWebsite(_ website: String) {
        self.popupController.addText(with: poiWebsiteLabel, and: website)
    }
    
    /// Sets the rating of poi
    /// - Parameter rating: the rating of the poi
    func setPoiRating(_ rating: String) {
        self.popupController.addText(with: poiRatingLabel, and: rating)
    }
    
    /// Sets the open status of poi
    /// - Parameter status: the status of the poi
    func setPoiOpenStatus(_ status: String) {
        self.popupController.addText(with: poiOpenStatusLabel, and: status)
    }
    
}
