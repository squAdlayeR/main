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
    
    var imageView = UIImageView()
    let picker = UIImagePickerController()
    var originalWidth: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        cropArea.layer.borderWidth = 2
        cropArea.layer.borderColor = UIColor.red.cgColor
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panned))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinched))
        imageView.isUserInteractionEnabled = true
        imageView.frame = placeholder.frame
        imageView.center = placeholder.center
        imageView.addGestureRecognizer(pan)
        imageView.addGestureRecognizer(pinch)
        view.insertSubview(imageView, belowSubview: cropArea)
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
        guard let image = imageView.image else {
            showAlertMessage(message: "Please choose a photo.")
            return
        }
        let croppedImage = cropImage(image)
        load(croppedImage)
    }
    
    func panned(_ sender: UIPanGestureRecognizer) {
        if sender.state == .changed {
            let translation = sender.translation(in: placeholder)
            imageView.center.x += translation.x
            imageView.center.y += translation.y
            sender.setTranslation(CGPoint.zero, in: placeholder)
        }
    }
    
    func pinched(_ sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        imageView.transform = imageView.transform.scaledBy(x: scale, y: scale)
        sender.scale = 1
    }
    
    func load(_ image: UIImage) {
        
        imageView.image = image
        imageView.frame = placeholder.frame
        originalWidth = image.size.width
        imageView.center = placeholder.center
        imageView.contentMode = .scaleAspectFit
        let ratio = image.size.width/image.size.height
        var width = imageView.frame.width
        var height = imageView.frame.height
        if ratio > 1 {
            height = imageView.frame.width/ratio
        } else {
            width = imageView.frame.height*ratio
        }
        imageView.frame.size = CGSize(width: width, height: height)
        imageView.center = placeholder.center
        
    }
    
    func cropImage(_ image: UIImage) -> UIImage {
        
        let scale = imageView.frame.width/originalWidth
        switch image.imageOrientation {
        case .down:
            imageView.frame.applying(CGAffineTransform(rotationAngle: .pi))
            cropArea.frame.applying(CGAffineTransform(rotationAngle: .pi))
            break
        case .left:
            imageView.frame.applying(CGAffineTransform(rotationAngle: .pi/2))
            cropArea.frame.applying(CGAffineTransform(rotationAngle: .pi/2))
            break
        case .right:
            imageView.frame.applying(CGAffineTransform(rotationAngle: -.pi/2))
            cropArea.frame.applying(CGAffineTransform(rotationAngle: -.pi/2))
            break
        case .up:
            break
        default:
            break
        }
        let intersection = imageView.frame.intersection(cropArea.frame)
        let x = (intersection.origin.x - imageView.frame.origin.x)/scale
        let y = (intersection.origin.y - imageView.frame.origin.y)/scale
        let width = intersection.width/scale
        let height = intersection.height/scale
        let cropFrame = CGRect(x: x, y: y, width: width, height: height)
        let croppedCGImage = image.cgImage?.cropping(to: cropFrame)
        let croppedImage = UIImage(cgImage: croppedCGImage!)
        return croppedImage
        
    }
    
}

extension IconCropViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            load(pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    
    }
}



