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
class CheckpointViewController: NSObject, ViewLayoutAdjustable {

    // The marker of the checkpoint
    var markerCard: BasicMarker!
    
    // The popup controller of the checkpoint
    var popupController: BasicAlertController!
    
    // The superview in which the marker and the alert will be
    // displayed
    var superView: UIView!
    
    // Specifies the center of the checkpoint card
    var center: CGPoint!
    
    /// Initialization
    /// - Parameters:
    ///     - center: the center of the popup & marker card
    ///     - name: name of the checkpoint
    ///     - distance: distance to that check point
    ///     - superView: the super view in which the marker card & popup will
    ///         be displayed
    init(center: CGPoint, name: String, distance: Double, superView: UIView) {
        super.init()
        self.center = center
        self.superView = superView
        initMarker(with: CGFloat(distance))
        initAlert(with: name)
        prepareDisplay()
    }
    
    /// Initializes the marker with specified frame and distance
    /// - Parameters:
    ///     - frame: the frame of the marker in the check point view
    ///     - distance: the distance to that check point
    private func initMarker(with distance: CGFloat) {
        let newMarker = BasicMarker(frame: markerFrame)
        newMarker.setDistance(distance)
        self.markerCard = newMarker
        addMarkerGesture()
    }
    
    /// Adds a single tap gesture recognizor to the marker
    private func addMarkerGesture() {
        let markerIsPressed = UITapGestureRecognizer(target: self, action: #selector(openPopup))
        markerCard.addGestureRecognizer(markerIsPressed)
    }
    
    /// Initializes the alert with its name
    /// - Parameters:
    ///     - name: the name of the check point
    private func initAlert(with name: String) {
        let newAlertController = BasicAlertController(title: name, frame: popupFrame)
        let closeButton = createCloseButton()
        newAlertController.addButtonToAlert(closeButton)
        newAlertController.setTitle(checkpointTitle)
        let alertWidth = newAlertController.alert.infoPanel.bounds.width
        let alertHeight = newAlertController.alert.infoPanel.bounds.height
        newAlertController.addViewToAlert(InformativeInnerView(width: alertWidth,
                                                               height: alertHeight))
        self.popupController = newAlertController
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
    
    /// Prepares the check point view for display
    private func prepareDisplay() {
        superView.addSubview(markerCard)
    }
    
    /// Applies view adjustment to the marker and popup when neccessary.
    /// - Parameter adjustment: the corresponding adjustment
    func applyViewAdjustment(_ adjustment: ARViewLayoutAdjustment) {
        markerCard.applyViewAdjustment(adjustment)
        popupController.alertView.applyViewAdjustment(adjustment)
    }
    
    /// Updates the distance that will be displayed on marker card
    /// - Parameter distance: thte distance that will be displayed
    func update(_ distance: Double) {
        markerCard.setDistance(CGFloat(distance))
    }
    
    /// Adds a text content into the inner view of the alert.
    /// - Parameters:
    ///     - label: the label of the text content
    ///     - conetent: the text of the content 
    func addText(with label: String, and content: String) {
        if let innerView = popupController.alert.infoPanel.innerView as? InformativeInnerView {
            let infoBlock = InfoBlock(label: label,
                                      content: content,
                                      width: innerView.bounds.width - 40)
            innerView.insertSubInfo(infoBlock)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Calculates the frame of the marker
    /// - Note: the frame is defined by suggested maker height/width, which are
    ///     defined in config
    private var markerFrame: CGRect {
        let originX = center.x - suggestedMarkerWidth / 2
        let originY = center.y - suggestedMarkerHeight / 2
        return CGRect(x: originX, y: originY, width: suggestedMarkerWidth, height: suggestedMarkerHeight)
    }
    
    /// Calculates the frame of the popup
    /// - Note: the frame is defined by suggested popup height/width, which are
    ///     defined in config
    private var popupFrame: CGRect {
        let originX = center.x - suggestedPopupWidth / 2
        let originY = center.y - suggestedPopupHeight / 2
        return CGRect(x: originX, y: originY, width: suggestedPopupWidth, height: suggestedPopupHeight)
    }
    
    /// Opens the popup
    func openPopup() {
        popupController.presentAlert(within: superView)
        UIView.animate(withDuration: 0.2, animations: {
            self.markerCard.alpha = 0
        })
    }
    
    /// Closes the popup
    func closePopup() {
        popupController.closeAlert()
        UIView.animate(withDuration: 0.2, animations: {
            self.markerCard.alpha = 1
        })
    }
    
    func removeFromSuperview() {
        markerCard.removeFromSuperview()
        popupController.closeAlert()
    }
}
