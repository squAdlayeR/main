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
 
 - Note: this controller explicitly assigns the alert to
    an alertView. This is to ensure the transformation will
    work properly. We only allow the animation being executed
    inside the alertView, which will not be interrupted by the
    transformation performed by the `ARViewLayoutAdjustment`
 */
class BasicAlertController: UIViewController {
    
    private(set) var alert: BasicAlert!
    private(set) var alertView: UIView!
    
    var cover: UIView!
    
    /// Initializes the alert controller
    init(title: String, frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        initializeAlertView(with: frame)
        initializeBasicAlert(with: title)
        prepareDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    /// Initializes the alert view that will be used to hold
    /// the alert popup
    /// - Parameter frame: the frame of the alert view
    private func initializeAlertView(with frame: CGRect) {
        let sanitizedFrame = sanitize(frame)
        let newAlertView = UIView(frame: sanitizedFrame)
        alertView = newAlertView
    }
    
    /// Initializes the basic alert popup that will be shown
    /// in the view
    /// - Parameter title: the title of the basic alert
    private func initializeBasicAlert(with title: String) {
        let newBasicAlert = createBaiscAlert(with: title)
        alert = newBasicAlert
    }
    
    /// Creates an alert with specified title
    /// - Parameter title: the title of the alert
    /// - Returns: a new basic alert
    private func createBaiscAlert(with title: String) -> BasicAlert {
        let newBasicAlert = BasicAlert(frame: alertFrame)
        newBasicAlert.setTitle(title)
        return newBasicAlert
    }
    
    /// Adds the alert into the alert view for display
    private func prepareDisplay() {
        alertView.addSubview(alert)
    }
    
    /// Sanitizes the frame. The main thing is to check
    /// Whether the height has exeeded the designed bounds
    /// - Parameter frame: the frame to be sanitized
    /// - Returns: the sanitized frame
    private func sanitize(_ frame: CGRect) -> CGRect {
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
    
    /// Calcualtes the frame of the alert in the view.
    /// - Returns: a frame of the same size as the view and 
    /// the origin is (0, 0)
    private var alertFrame: CGRect {
        return CGRect(x: 0, y: 0, width: alertView.frame.width, height: alertView.frame.height)
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
    
    /// Sets the title of the alert
    /// - Parameter title: the title of the alert
    func setAlertTitle(_ title: String) {
        alert.setTitle(title)
    }
    
    /// Adds a text content into the inner view of the alert.
    /// - Parameters:
    ///     - label: the label of the text content
    ///     - conetent: the text of the content
    ///     - iconName: the name of the icon that will be displayed in the label
    func addText(with label: String, iconName: String, and content: String) {
        if let innerView = alert.infoPanel.innerView as? InformativeInnerView {
            let infoBlock = InfoBlockView(label: label,
                                          iconName: iconName,
                                          content: content,
                                          width: innerView.bounds.width - innerViewSidePadding * 2)
            innerView.insertSubInfo(infoBlock)
        }
    }
    
    /// Sets the blur effect of the popup
    /// - Parameter openBlurEffect: determines whether the blur effect
    ///     is opened or not.
    func setBlurEffect(_ openBlurEffect: Bool) {
        alert.blurMode = openBlurEffect
    }
    
    /// Presents the alert inside a specified view
    /// - Parameter view: the view that will be holding the alert
    func presentAlert(within view: UIView) {
        cover = UIView(frame: view.bounds)
        cover.layer.zPosition = alertViewZPosition
        alertView.addSubview(alert)
        cover.addSubview(alertView)
        view.addSubview(cover)
//        alertView.layer.zPosition = alertViewZPosition
        alert.open()
    }
    
    /// Closes the alert
    @objc func closeAlert() {
        alert.close(inCompletion: { [weak self] in
            guard self != nil else { return }
            self!.alert.removeFromSuperview()
            self!.alertView.removeFromSuperview()
            self!.cover.removeFromSuperview()
            self?.removeFromParentViewController()
        })
    }
    
}


