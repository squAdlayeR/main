//
//  InputTextFeild.swift
//  ViewComponentTesting
//
//  Created by Yang Zhuohan on 28/3/17.
//  Copyright © 2017 Yang Zhuohan. All rights reserved.
//

import UIKit

class InputTextFeild: UITextField {

    init(placeHolder: String, size: CGSize) {
        super.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        self.placeholder = placeHolder
        initializeStyling()
    }
    
    private func initializeStyling() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.clear
        self.font = UIFont(name: "HomenajeMod-Regular", size: 26)
        self.textColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 25, y: 20, width: self.bounds.width - 50, height: self.bounds.height)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 25, y: 20, width: self.bounds.width - 50, height: self.bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 25, y: 20, width: self.bounds.width - 50, height: self.bounds.height)
    }
    
}
