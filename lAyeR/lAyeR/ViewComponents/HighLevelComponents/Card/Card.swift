//
//  Card.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 24/3/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 A super class that is used to represent a card that will display
 place icon and information
 */
class Card: NSObject {

    // The marker of the card
    private(set) var markerCard: BasicMarker!
    
    // The popup controller of the card
    private(set) var popupController: BasicAlertController!
    
    // The superview controller in which the marker and the popup will be
    // displayed
    private(set) var superViewController: UIViewController!
    
    // Defines the alpha of the marker. When it changes, it should change
    // The alpha of the marker accoridingly
    private(set) var markerAlpha: CGFloat = 1 {
        didSet {
            UIView.animate(withDuration: CardConstants.openDuration, animations: { [weak self] in
                guard self != nil else { return }
                self!.markerCard.alpha = self!.markerAlpha
            })
        }
    }
    
    /// Initialization
    /// - Parameters:
    ///     - distance: distance to that place that the card is representing
    ///     - icon: the name of icon that will be displayed on card
    ///     - superViewController: the controller of the super view
    init(distance: Double, icon: String, superViewController: UIViewController) {
        super.init()
        self.superViewController = superViewController
        initMarker(with: distance, and: icon)
        initAlert()
        prepareDisplay()
    }
    
    /// Initializes the marker with specified distance and icon name
    /// - Parameters:
    ///     - distance: the distance to that place
    ///     - icon: the name of the icon
    private func initMarker(with distance: Double, and icon: String) {
        let markerSize = CGSize(width: CardConstants.suggestedMarkerWidth,
                                height: CardConstants.suggestedMarkerHeight)
        let newMarker = BasicMarker(size: markerSize, icon: icon)
        newMarker.updateDistance(with: distance)
        self.markerCard = newMarker
        addMarkerGesture()
    }
    
    /// Adds a single tap gesture recognizor to the marker
    /// This gesture will open the alert
    private func addMarkerGesture() {
        let markerIsPressed = UITapGestureRecognizer(target: self, action: #selector(tapped))
        markerCard.addGestureRecognizer(markerIsPressed)
    }
    
    /// Initializes the alert popup
    private func initAlert() {
        let newAlertController = BasicAlertController(title: CardConstants.defaultTitle, size: popupSize)
        let alertWidth = popupSize.width
        let alertHeight = popupSize.height - BasicAlertConstants.topBannerHeight - BasicAlertConstants.bottomBannerHeight
        newAlertController.addViewToAlert(InformativeInnerView(width: alertWidth,
                                                               height: alertHeight,
                                                               subtitle: CardConstants.infoSubtitle))
        self.popupController = newAlertController
    }
    
    /// Prepares the card view for display
    private func prepareDisplay() {
        superViewController.view.addSubview(markerCard)
    }
    
    /// Calculates the size of the popup
    /// - Note: the frame is defined by suggested popup height/width proportion, which are
    ///     defined in constants file
    private var popupSize: CGSize {
        let superViewWidth = superViewController.view.bounds.width
        let superViewHeight = superViewController.view.bounds.height
        let suggestdPopupW = superViewWidth * CardConstants.widthPercentage <= BasicAlertConstants.maxAlertWidth
            ? superViewWidth * CardConstants.widthPercentage
            : BasicAlertConstants.maxAlertWidth
        let suggsetdPopupH = superViewHeight * CardConstants.heightPercentage <= BasicAlertConstants.maxAlertHeight
            ? superViewHeight * CardConstants.heightPercentage
            : BasicAlertConstants.maxAlertHeight
        return CGSize(width: suggestdPopupW, height: suggsetdPopupH)
    }
    
    /// Changes the alpha of the marker
    /// - Parameter alpha: the new alpha of the marker
    func setMarkerAlpha(to alpha: CGFloat) {
        self.markerAlpha = alpha
    }
    
}

/**
 An extension that is used to define interactions
 */
internal extension Card {
    
    /// GestureRecognizer target. Called when tapped.
    func tapped() {
        openPopup()
    }
    
    /// Opens the popup
    func openPopup() {
        popupController.presentAlert(within: superViewController.view)
        UIView.animate(withDuration: CardConstants.openDuration, animations: { [weak self] in
            self?.markerCard.isHidden = true
        })
    }
    
    /// Closes the popup
    func closePopup() {
        popupController.closeAlert()
        UIView.animate(withDuration: CardConstants.closeDuration, animations: { [weak self] in
            self?.markerCard.isHidden = false
        })
    }
    
    /// Updates the distance that will be displayed on marker card
    /// - Parameter distance: thte distance that will be displayed
    func update(_ distance: Double) {
        markerCard.updateDistance(with: distance)
    }

}

/**
 An extension that is to specify that this controller conforms `View-
 LayoutAdjustable`
 */
extension Card: ViewLayoutAdjustable {
    
    /// Applies view adjustment to the marker and popup when neccessary.
    /// - Parameter adjustment: the corresponding adjustment
    func applyViewAdjustment(_ adjustment: ARViewLayoutAdjustment) {
        markerCard.applyViewAdjustment(adjustment)
    }
    
    /// Removes the current checkpoint card from its super view
    func removeFromSuperview() {
        markerCard.removeFromSuperview()
        popupController.closeAlert()
    }
    
}
