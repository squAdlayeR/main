//
//  CommonAlertController.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/14.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import UIKit


class CommonAlertController: BasicAlertController {
    
    private var button: UIButton!
    private var label: UILabel!
    
    static let instance: CommonAlertController = CommonAlertController()
    
    /// Initializes the common alert controller.
    init() {
        let alertFrame = CGRect(x: 0, y: 0, width: suggestedPopupWidth, height: suggestedPopupHeight)
        super.init(title: "", frame: alertFrame)
        initializeCloseButton()
        initializeMessageLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Creates a text field that shows success message.
    /// - Returns: a ui label with success text
    private func initializeMessageLabel() {
        label = UILabel()
        label.font = UIFont(name: alterDefaultFontLight, size: buttonFontSize)
        label.textAlignment = NSTextAlignment.center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = UIColor.lightGray
        addViewToAlert(label)
    }
    
    /// Creates a close button.
    private func initializeCloseButton() {
        button = UIButton()
        button.setTitle(confirmLabelText, for: .normal)
        button.titleLabel?.font = UIFont(name: alterDefaultFontRegular, size: buttonFontSize)
        button.addTarget(self, action: #selector(closeAlert), for: .touchUpInside)
        addButtonToAlert(button)
    }
    
    /// Displays the alert in specified view with given alert title and
    /// message.
    func showAlert(_ title: String, _ message: String, in view: UIView) {
        alert.setTitle(title)
        label.text = message
        alertView.center = view.center
        presentAlert(within: view)
    }
    

}

