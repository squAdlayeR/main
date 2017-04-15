//
//  ExportViewControllerProtocol.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/7.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Shows an alert with given title and message within view.
    /// - Parameters:
    ///     - title: String: the title of the alert.
    ///     - message: String: the message to be shown.
    func showAlertMessage(title: String = Messages.errorTitle, message: String) {
        self.addChildViewController(CommonAlertController.instance)
        CommonAlertController.instance.showAlert(title, message, in: self.view)
    }
    
    /// Captures a screen show in given view's range includes its subview.
    /// - Parameters:
    ///     - view: UIView: the view to be captured.
    /// - Returns:
    ///     - UIImage: the UIImage of the screen capture.
    func viewCapture(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshot ?? UIImage()
    }
    
    /// Creates selected routes and prompts a export options menu.
    /// - Parameters:
    ///     - routes: [Route]: the routes to be saved and exported.
    func share(routes: [Route]) {
        do {
            let urls = try GPXFileManager.instance.save(routes: routes)
            showExportOptionsMenu(urls: urls)
        } catch {
            showAlertMessage(message: Messages.saveGPXFailureMessage)
        }
    }
    
    /// Prompts an activity view controller with file urls as activity
    /// items. 
    /// - Parameters:
    ///     - urls: [URL]: the file urls as activity items.
    /// MARK: As iPhone only allows modal presentation and iPad only allows
    /// popover presentation of popover controllers, we have to include a 
    /// UI-idiom check here to config proper presentation style of the 
    /// activity view controller.
    func showExportOptionsMenu(urls: [URL]) {
        let activityViewController = UIActivityViewController(activityItems: urls, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {
            (type, completed: Bool, items: [Any]?, error: Error?) in
            guard completed else { return }
            urls.forEach {
                GPXFileManager.instance.delete(url: $0)
            } // clear cache
        }
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width/2.0, y: self.view.bounds.height, width: 1, height: 1)
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
}

extension String {
    
    /// Returns true if a string is alphanumeric.
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}

extension Double {
    
    /// Returns a truncated double number to specified decimal places.
    /// - Parameter places: Int: number of decimal places remain after 
    ///                          truncation.
    /// - Returns:
    ///     - Double: truncated number.
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

extension UIImageView {
    
    /// Sets the image of a UIImageView from a url asynchronosly.
    /// - Parameter:
    ///     - url: String: the string path of the image file.
    public func imageFromUrl(url: String) {
        guard let url = URL(string: url) else { return }
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }
    }
}







