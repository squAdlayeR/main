//
//  RouteDesignerViewController_SearchBarExtension.swift
//  lAyeR
//
//  Created by Patrick Cho on 4/15/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

extension RouteDesignerViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == sourceBar {
            useSourceCoordinates = false
        } else if textField == searchBar {
            useDestCoordinates = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
