//
//  IconCropViewController.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/8.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit

class IconCropViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cropArea: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var placeholder: UIImageView!
    
    
    @IBAction func promptOptions(_ sender: Any) {
        let picker = UIImagePickerController(rootViewController: self)
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: Any) {
    }
    
}
