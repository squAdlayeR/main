//
//  CheckpointView.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 3/12/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

class CheckpointView: UIView {

    var marker: BasicMarker!
    var alertController: BasicAlertController!
    
    init(frame: CGRect, name: String, distance: Double, description: String) {
        super.init(frame: frame)
        let markerFrame = CGRect(x: (frame.width - suggestedMarkerWidth) / 2,
                                 y: (frame.height - suggestedMarkerHeight) / 2,
                                 width: suggestedMarkerWidth,
                                 height: suggestedMarkerHeight)
        let alertFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        initMarker(with: markerFrame, distance: CGFloat(distance))
        initAlert(with: alertFrame, name: name)
        prepareDisplay()
    }
    
    private func initMarker(with frame: CGRect, distance: CGFloat) {
        let newMarker = BasicMarker(frame: frame)
        newMarker.setDistance(distance)
        self.marker = newMarker
        addMarkerGesture()
    }
    
    private func addMarkerGesture() {
        let markerIsPressed = UITapGestureRecognizer(target: self, action: #selector(openPopup))
        marker.addGestureRecognizer(markerIsPressed)
    }
    
    private func initAlert(with frame: CGRect, name: String) {
        let newAlertController = BasicAlertController(title: name, frame: frame)
        let closeButton = createCloseButton()
        newAlertController.addButtonToAlert(closeButton)
        newAlertController.setTitle(name)
        self.alertController = newAlertController
    }
    
    private func createCloseButton() -> UIButton {
        let newButton = UIButton()
        newButton.setTitle("OK", for: .normal)
        newButton.titleLabel?.font = UIFont(name: buttonFontName, size: buttonFontSize)
        newButton.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        return newButton
    }
    
    private func prepareDisplay() {
        self.addSubview(marker)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func openPopup() {
        alertController.presentAlert(within: self)
    }
    
    func closePopup() {
        alertController.closeAlert()
    }

}
