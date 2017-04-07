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
    
    @IBOutlet weak var mask: UIImageView!
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        cropArea.addSubview(placeholder)
        cropArea.addSubview(mask)
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
        let image = viewCapture(view: cropArea)
        placeholder.image = image
        placeholder.contentMode = .center
    }
    
    func panned(_ sender: UIPanGestureRecognizer) {
        //placeholder.superview?.bringSubview(toFront: placeholder)
        var translation = sender.translation(in: placeholder)
        translation = translation.applying(placeholder.transform)
        placeholder.center.x += translation.x
        placeholder.center.y += translation.y
        sender.setTranslation(CGPoint.zero, in: placeholder)
        //_cropoptions.Center = self.center
    }
    
    func pinched(_ sender: UIPinchGestureRecognizer) {
        //placeholder.superview?.bringSubview(toFront: placeholder)
        let scale = sender.scale
        placeholder.transform = placeholder.transform.scaledBy(x: scale, y: scale)
        //_cropoptions.Height = self.frame.height
        //_cropoptions.Width = self.frame.width
        //sender.scale = 1.0
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
