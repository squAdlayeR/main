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
    @IBOutlet weak var placeholder: UIImageView!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        cropArea.layer.borderWidth = 2
        cropArea.layer.borderColor = UIColor.red.cgColor
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panned))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinched))
        placeholder.addGestureRecognizer(pan)
        placeholder.addGestureRecognizer(pinch)
    }
    
    @IBAction func albumPressed(_ sender: Any) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func cameraPressed(_ sender: Any) {
        picker.allowsEditing = false
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        // TODO: Crop the image correctly and update database
        
    }
    
    func panned(_ sender: UIPanGestureRecognizer) {
        if sender.state == .changed {
            let translation = sender.translation(in: placeholder)
            placeholder.center.x += translation.x
            placeholder.center.y += translation.y
            sender.setTranslation(CGPoint.zero, in: placeholder)
        }
    }
    
    func pinched(_ sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        placeholder.transform = placeholder.transform.scaledBy(x: scale, y: scale)
        sender.scale = 1
    }
    
}

extension IconCropViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            placeholder.contentMode = .scaleAspectFit
            placeholder.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    
    }
}

