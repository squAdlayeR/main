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
class CheckpointViewController: NSObject, CardDisplayController {

    var marker: BasicMarker!
    var alertController: BasicAlertController!
    
    var superView: UIView!
    
    var center: CGPoint! {
        didSet {
            marker.center = center
            alertController.alert.center = center
        }
    }
    
    /// Initialization
    /// - Parameters:
    ///     - frame: the frame of the POPUP
    ///     - name: name of the checkpoint
    ///     - distance: distance to that check point
    ///     - description: description of the check point
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
        self.marker = newMarker
        addMarkerGesture()
    }
    
    /// Adds a single tap gesture recognizor to the marker
    private func addMarkerGesture() {
        let markerIsPressed = UITapGestureRecognizer(target: self, action: #selector(openPopup))
        marker.addGestureRecognizer(markerIsPressed)
    }
    
    /// Initializes the alert with its frame and name
    /// - Parameters:
    ///     - frame: the frame of the popup in the check point view
    ///     - name: the name of the check point
    private func initAlert(with name: String) {
        let newAlertController = BasicAlertController(title: name, frame: popupFrame)
        let closeButton = createCloseButton()
        newAlertController.addButtonToAlert(closeButton)
        newAlertController.setTitle(name)
        self.alertController = newAlertController
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
        superView.addSubview(marker)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var markerFrame: CGRect {
        let originX = center.x - suggestedMarkerWidth / 2
        let originY = center.y - suggestedMarkerHeight / 2
        return CGRect(x: originX, y: originY, width: suggestedMarkerWidth, height: suggestedMarkerHeight)
    }
    
    private var popupFrame: CGRect {
        let originX = center.x - suggestedPopupWidth / 2
        let originY = center.y - suggestedPopupHeight / 2
        return CGRect(x: originX, y: originY, width: suggestedPopupWidth, height: suggestedPopupHeight)
    }
    
    /// Opens the popup
    func openPopup() {
        alertController.presentAlert(within: superView)
        UIView.animate(withDuration: 0.2, animations: {
            self.marker.alpha = 0
        })
    }
    
    /// Closes the popup
    func closePopup() {
        alertController.closeAlert()
        UIView.animate(withDuration: 0.2, animations: {
            self.marker.alpha = 1
        })
    }
    
}
