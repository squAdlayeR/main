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
    
    var name: String?
    
    /// Initializes the poi view controller
    /// - Parameters:
    ///     - center: the initial center of the marker
    ///     - distance: the distance between current place and that place
    ///     - type: the type of the poi
    ///     - superView: the view that this popup & marker is attached to
    init(center: CGPoint, distance: Double, type: String, superViewController: UIViewController) {
        super.init(center: center, distance: distance, superViewController: superViewController)
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
        newButton.addTarget(self, action: #selector(segueToDesigner), for: .touchUpInside)
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
        self.name = name
        self.popupController.addText(with: nameLabel, iconName: descriptionIcon, and: name)
    }
    
    /// Sets the address of poi
    /// - Parameter address: the address of the poi
    func setPoiAddress(_ address: String) {
        let sanitizedAddress = address.isEmpty ? infoBlockPlaceHolder : address
        self.popupController.addText(with: poiAddressLabel, iconName: addressIcon, and: sanitizedAddress)
    }
    
    /// Sets the contact of poi
    /// - Parameter contact: the contact of the poi
    func setPoiContacet(_ contact: String) {
        self.popupController.addText(with: poiContactLabel, iconName: contactIcon, and: contact)
    }
    
    /// Sets the website of poi
    /// - Parameter website: the website of the poi
    func setPoiWebsite(_ website: String) {
        self.popupController.addText(with: poiWebsiteLabel, iconName: websiteIcon, and: website)
    }
    
    /// Sets the rating of poi
    /// - Parameter rating: the rating of the poi
    func setPoiRating(_ rating: Double) {
        let starString = getStarString(rating)
        self.popupController.addText(with: poiRatingLabel, iconName: ratingsIcon, and: starString)
    }
    
    /// Gets a string of stars according the a number
    /// - Parameter number: the number that will be converted into stars
    
    private func getStarString(_ number: Double) -> String {
        let numberOfFullStar = floor(number)
        let remaining = number - numberOfFullStar
        let numberOfHalfStar = remaining < 0.5 ? 0 : 1
        var result = String()
        for _ in 1...Int(numberOfFullStar) {
            result = result.appending(infoBlockFullStar)
        }
        if numberOfHalfStar == 1 {
            result = result.appending(infoBlockHalfStar)
        }
        return result
    }
    
    /// Sets the open hours of poi
    /// - Parameter hours: the open hours of the poi
    func setPoiOpenHours(_ hours: String) {
        self.popupController.addText(with: poiOpenHoursLabel, iconName: statusIcon, and: hours)
    }
    
    /// Sets the price level of poi
    /// - Parameter level: the price level of the poi
    func setPoiPriceLevel(_ level: Int) {
        self.popupController.addText(with: poiPriceLevelLabel, iconName: nameIcon, and: convertPriceLevel(level))
    }
    
    /// Converts price level integer into string
    /// - Parameter levle: the price level number
    /// - Returns: string description of the price level
    private func convertPriceLevel(_ level: Int) -> String {
        if let priceLevel = PriceLevel(rawValue: level) {
            return priceLevel.text
        }
        return infoBlockPlaceHolder
    }
    
}
