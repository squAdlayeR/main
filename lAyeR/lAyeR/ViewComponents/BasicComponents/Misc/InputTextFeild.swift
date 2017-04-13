//
//  InputTextFeild.swift
//  ViewComponentTesting
//
//  Created by Yang Zhuohan on 28/3/17.
//  Copyright © 2017 Yang Zhuohan. All rights reserved.
//

import UIKit

/**
 This is a class designed for input text field. This is especially designed for
 lAyeR. To use it, you can specify a place holder and its size, then it will
 create a round corner text field with placeholder
 */
class InputTextFeild: UITextField {

    /// Initializes the text field with place holder and size
    /// - Parameters:
    ///     - placeHolder: the place holder of the text field
    ///     - size: the size of the buttom
    init(placeHolder: String, size: CGSize) {
        super.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        self.placeholder = placeHolder
        initializeStyling()
    }
    
    /// Initializes the styling of the text field
    private func initializeStyling() {
        self.layer.borderWidth = defaultBorderWidth
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.clear
        self.font = UIFont(name: alterDefaultFontRegular, size: inputFieldFontSize)
        self.textColor = defaultFontColor
        self.keyboardAppearance = .dark
    }
    
    /// Specifies the padding of the text in the text field
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let originalBound = super.textRect(forBounds: bounds)
        return CGRect(x: originalBound.origin.x + paddingLeft,
                      y: originalBound.origin.y,
                      width: originalBound.width - paddingLeft,
                      height: originalBound.height)
    }
    
    /// Specifies the padding of the text in the text field while editing
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let originalBound = super.editingRect(forBounds: bounds)
        return CGRect(x: originalBound.origin.x + paddingLeft,
                      y: originalBound.origin.y,
                      width: originalBound.width - paddingLeft,
                      height: originalBound.height)
    }
    
    /// Calculates the left padding according to the size of the text field
    private var paddingLeft: CGFloat {
        return self.bounds.height / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
