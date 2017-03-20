//
//  BasicAlertController.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 3/12/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 A controller that is used to manage a basic alert.
 This controller is able to
 1. initialze an alert
 2. adds a view to an alert
 3. adds buttons to an alert
 4. present/close an alert in a specified view
 */
class BasicAlertController {
    
    private(set) var alert: BasicAlert!
    private(set) var alertView: UIView!
    
    /// Initializes the alert controller
    init(title: String, frame: CGRect) {
        let sanitizedFrame = sanitize(frame: frame)
        let newBaiscAlert = BasicAlert(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        let newAlertView = UIView(frame: sanitizedFrame)
        alert = newBaiscAlert
        alert.setTitle(title)
        alert.layer.borderColor = UIColor.yellow.cgColor
        alert.layer.borderWidth = 2.0
        alertView = newAlertView
        alertView.addSubview(alert)
    }
    
    /// Sanitizes the frame. The main thing is to check
    /// Whether the height has exeeded the bounds
    /// - Parameter frame: the frame to be sanitized
    /// - Returns: the sanitized frame
    private func sanitize(frame: CGRect) -> CGRect {
        var frameHeight = frame.height
        if frameHeight < minAlertHeight {
            frameHeight = minAlertHeight
        }
        if frameHeight > maxAlertHeight {
            frameHeight = maxAlertHeight
        }
        return CGRect(x: frame.origin.x, y: frame.origin.y,
                      width: frame.width, height: frameHeight)
    }

}

/**
 An extension which holds the methods that are related to operations
 on the alert
 */
extension BasicAlertController {
    
    /// Adds a view to the alert
    /// - Parameter view: the view that is to be displayed in
    ///     info panel
    func addViewToAlert(_ view: UIView) {
        alert.setView(view)
    }
    
    /// Adds a button into the alert
    /// - Parameter button: the button that is to be used
    func addButtonToAlert(_ button: UIButton) {
        alert.addButton(button)
    }
    
    func setAlertCenter(_ center: CGPoint) {
        alert.center = center
    }
    
    /// Sets the title of the alert
    /// - Paramter title: the title of the alert
    func setTitle(_ title: String) {
        alert.setTitle(title)
    }
    
    /// Presents the alert inside a specified view
    /// - Parameter view: the view that will be holding the alert
    func presentAlert(within view: UIView) {
        view.addSubview(alertView)
        alert.open()
    }
    
    /// Closes the alert
    func closeAlert() {
        alert.close(inCompletion: { self.alertView.removeFromSuperview() })
    }
    
}
