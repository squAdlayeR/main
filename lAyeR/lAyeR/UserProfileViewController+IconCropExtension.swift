//
//  UserProfileViewController+IconCropExtension.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/15.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import UIKit
import TOCropViewController

/*
 * This extension defines user action related with image pikcer.
 */
extension UserProfileViewController {
    
    func changeIcon() {
        let alert = createActionSheet()
        /// Checks iPad UI idiom.
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width/2.0, y: self.view.bounds.height, width: 1, height: 1)
        }
        present(alert, animated: true, completion: nil)
    }
    
    /// Creates the action sheet to present
    /// - Returns:
    ///     - UIAlertController: the action sheet
    private func createActionSheet() -> UIAlertController {
        let alert = UIAlertController(title: Messages.imagePickerTitle, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: Messages.cancelTitle, style: .cancel, handler: nil)
        let album = UIAlertAction(title: Messages.albumTitle, style: .default, handler: { _ in
            self.openAlbum()
        })
        let camera = UIAlertAction(title: Messages.cameraTitle, style: .default, handler: { _ in
            self.openCamera()
        })
        alert.view.tintColor = UIColor.darkGray
        alert.addAction(cancel)
        alert.addAction(album)
        alert.addAction(camera)
        return alert
    }
    
    /// Opens user camera for user to take photo
    private func openCamera() {
        picker.allowsEditing = false
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    /// Opens user album for image picking
    private func openAlbum() {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }

}

/* This extension allows UserProfileViewController to use UIImagePickerController
 * to pick image files from album or take photo from camera.
 */
extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// After user picks up an image, dismiss the image picker and presents
    /// an image cropper for user to crop the image and use it as their icon.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        dismiss(animated: true) {
            let cropper = TOCropViewController(croppingStyle: TOCropViewCroppingStyle.circular, image: pickedImage)
            cropper.delegate = self
            self.present(cropper, animated: true, completion: nil)
        }
    }
    
    /// Dismisses the image picker if user cancels image picking
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

/*
 * This extension utilizes TOCropViewController to allow user crop their icon
 * in circular shape and save it as their profile icon.
 */
extension UserProfileViewController: TOCropViewControllerDelegate {
    
    /// Dismisses the image cropper if user cancels image cropping
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        dismiss(animated: true, completion: nil)
    }
    
    /// After user crops the image, dismiss the image cropper, save the image 
    /// and refreshes user profile
    func cropViewController(_ cropViewController: TOCropViewController, didCropToCircularImage image: UIImage, with cropRect: CGRect, angle: Int) {
        dismiss(animated: true) { _ in
            self.refreshProfile(with: image)
        }
    }
    
    /// Refreshes User Profile with cropped image
    /// - Parameters: 
    ///     - image: UIImage: the new user icon
    private func refreshProfile(with image: UIImage) {
        do {
            let url = try GPXFileManager.instance.save(name: GPSGPXConstants.iconName, image: image)
            avatar.imageFromUrl(url: url.absoluteString)
            userProfile?.setAvatar(url.absoluteString)
            guard let profile = userProfile, dataService.enabled else {
                showAlertMessage(message: Messages.databaseDisconnectedMessage)
                return
            }
            dataService.updateUserProfile(profile)
        } catch {
            self.showAlertMessage(message: Messages.savePNGFailureMessage)
        }
    }
    
}
