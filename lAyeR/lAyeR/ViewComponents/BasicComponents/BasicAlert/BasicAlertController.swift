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
 - initialze an alert
 - adds a view to an alert
 - adds buttons to an alert
 - present/close an alert in a specified view
 
 - Note: this controller explicitly assigns the alert to
    an alertView. This is to ensure the transformation will
    work properly. We only allow the animation being executed
    inside the alertView, which will not be interrupted by the
    transformation performed by the `ARViewLayoutAdjustment`
 */
class BasicAlertController: UIViewController {
    
    private(set) var alert: BasicAlert!
    private var alertView: UIView!
    private var cover: UIView!
    
    /// Initializes the alert controller lazily
    /// - Note: it does not create an alert until present alert is called
    init(title: String, size: CGSize) {
        super.init(nibName: nil, bundle: nil)
        prepareBasicAlert(with: title, and: sanitize(size))
        prepareAlertView(with: sanitize(size))
        prepareCover()
    }
    
    /// Sanitizes the frame. The main thing is to check
    /// Whether the height has exeeded the designed bounds
    /// - Parameter frame: the frame to be sanitized
    /// - Returns: the sanitized frame
    private func sanitize(_ size: CGSize) -> CGSize {
        var height = size.height
        if height < BasicAlertConstants.minAlertHeight {
            height = BasicAlertConstants.minAlertHeight
        }
        if height > BasicAlertConstants.maxAlertHeight {
            height = BasicAlertConstants.maxAlertHeight
        }
        return CGSize(width: size.width, height: height)
    }
    
    /// Initializes the basic alert popup that will be shown in the view
    /// - Parameters:
    ///     - title: the title on the card
    ///     - size: the size of the alert
    private func prepareBasicAlert(with title: String, and size: CGSize) {
        let newBasicAlert = BasicAlert(width: size.width, height: size.height, title: title)
        alert = newBasicAlert
    }
    
    /// Initializes the alert view that will be used to hold the alert popup
    /// - Parameter size: the size of the alert view
    private func prepareAlertView(with size: CGSize) {
        let newAlertView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        alertView = newAlertView
    }
    
    /// Prepares a cover so that user cannot click on other things unless he closes
    /// the popup
    private func prepareCover() {
        let cover = UIView(frame: view.bounds)
        cover.layer.zPosition = BasicAlertConstants.zPosition
        self.cover = cover
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /* public functions */
    
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
    
    /// Adds a text content into the inner view of the alert.
    /// - Note: only useful when the inner view is `InformativeInnerView`
    /// - Parameters:
    ///     - label: the label of the text content
    ///     - iconName: the name of the icon that will be displayed in the label
    ///     - conetent: the text of the content
    func addText(with label: String, iconName: String, and content: String) {
        if let innerView = alert.infoPanel.innerView as? InformativeInnerView {
            let infoBlock = InfoBlockView(label: label,
                                          iconName: iconName,
                                          content: content,
                                          width: innerView.bounds.width
                                            - InnerViewConstants.innerViewSidePadding * 2)
            innerView.insertSubInfo(infoBlock)
        }
    }
    
    /// Presents the alert inside a specified view
    /// - Parameter view: the view that will be holding the alert
    func presentAlert(within view: UIView) {
        alertView.center = cover.center
        alertView.addSubview(alert)
        cover.addSubview(alertView)
        view.addSubview(cover)
        alert.open()
    }
    
    /// Closes the alert
    @objc func closeAlert() {
        alert.close(inCompletion: { [weak self] in
            self?.alert.removeFromSuperview()
            self?.alertView.removeFromSuperview()
            self?.cover.removeFromSuperview()
            self?.removeFromParentViewController()
        })
    }

}

