//
//  ExportViewControllerProtocol.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/7.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlertMessage(title: String = errorTitle, message: String) {
        self.addChildViewController(CommonAlertController.instance)
        CommonAlertController.instance.showAlert(title, message, in: self.view)
    }
    
    func viewCapture(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshot ?? UIImage()
    }
    
    func share(routes: [Route]) {
        do {
            var urls: [URL] = []
            for route in routes {
                try GPXManager.save(route: route)
                let path = try GPXManager.getPath(with: route.name, ext: "gpx")
                let url = URL(fileURLWithPath: path)
                urls.append(url)
            }
            let activityViewController = UIActivityViewController(activityItems: urls, applicationActivities: nil)
            activityViewController.completionWithItemsHandler = {
                (type, completed: Bool, items: [Any]?, error: Error?) in
                guard completed else { return }
                urls.forEach { GPXManager.delete(url: $0) } // clear cache
            }
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width/2.0, y: self.view.bounds.height, width: 1, height: 1)
            }
            present(activityViewController, animated: true, completion: nil)
            
        } catch {
            showAlertMessage(title: "Oops", message: "Fail to create .gpx files.")
        }
    }
    
}



