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
    var markerCard: BasicMarker!
    
    // The popup controller of the card
    var popupController: BasicAlertController!
    
    // The superview in which the marker and the popup will be
    // displayed
    var superViewController: UIViewController!
    
    /// Initialization
    /// - Parameters:
    ///     - center: the center of the popup & marker card
    ///     - distance: distance to that place that the card is representing
    ///     - superView: the super view in which the marker card & popup will
    ///         be displayed
    init(distance: Double, icon: String, superViewController: UIViewController) {
        super.init()
        self.superViewController = superViewController
        initMarker(with: distance, and: icon)
        initAlert()
        prepareDisplay()
    }
    
    /// Initializes the marker with specified frame and distance
    /// - Parameters:
    ///     - frame: the frame of the marker in the card view
    ///     - distance: the distance to that place
    private func initMarker(with distance: Double, and icon: String) {
        let markerSize = CGSize(width: suggestedMarkerWidth, height: suggestedMarkerHeight)
        let newMarker = BasicMarker(size: markerSize, icon: icon)
        newMarker.updateDistance(with: distance)
        self.markerCard = newMarker
        addMarkerGesture()
    }
    
    /// Adds a single tap gesture recognizor to the marker
    private func addMarkerGesture() {
        let markerIsPressed = UITapGestureRecognizer(target: self, action: #selector(openPopup))
        markerCard.addGestureRecognizer(markerIsPressed)
    }
    
    /// Initializes the popup with its name
    /// - Parameters:
    ///     - name: the name of the check point
    private func initAlert() {
        let newAlertController = BasicAlertController(title: defaultTitle, size: popupSize)
        let alertWidth = popupSize.width
        let alertHeight = popupSize.height - BasicAlertConstants.topBannerHeight - BasicAlertConstants.bottomBannerHeight
        newAlertController.addViewToAlert(InformativeInnerView(width: alertWidth,
                                                               height: alertHeight,
                                                               subtitle: titleText))
        self.popupController = newAlertController
    }
    
    /// Prepares the card view for display
    private func prepareDisplay() {
        superViewController.view.addSubview(markerCard)
    }
    
    /// Calculates the frame of the popup
    /// - Note: the frame is defined by suggested popup height/width, which are
    ///     defined in config
    private var popupSize: CGSize {
        let suggestdPopupW = superViewController.view.bounds.width * 0.8 <= 500 ? superViewController.view.bounds.width * 0.8 : 500
        let suggsetdPopupH = superViewController.view.bounds.height * 0.5 <= 800 ? superViewController.view.bounds.height * 0.5 : 800
        return CGSize(width: suggestdPopupW, height: suggsetdPopupH)
    }
    
}

/**
 An extension that is used to define interactions
 */
extension Card {
    
    /// Opens the popup
    func openPopup() {
        popupController.presentAlert(within: superViewController.view)
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard self != nil else { return }
            self!.markerCard.alpha = 0
        })
    }
    
    /// Closes the popup
    func closePopup() {
        popupController.closeAlert()
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard self != nil else { return }
            self!.markerCard.alpha = 1
        })
    }
    
    /// Updates the distance that will be displayed on marker card
    /// - Parameter distance: thte distance that will be displayed
    func update(_ distance: Double) {
        markerCard.updateDistance(with: distance)
    }
    
    func setMarkderAlpha(to alpha: CGFloat) {
        markerCard.alpha = alpha
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
