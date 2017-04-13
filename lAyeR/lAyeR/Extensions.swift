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
    
    func showAlertMessage(message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func viewCapture(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshot ?? UIImage()
    }
}

/// Using DocumentInteractionViewController
extension UIViewController {
    
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
            showAlertMessage(message: "Fail to create .gpx files.")
        }
    }
    
}

extension UIButton {
    
    func addEvent(_ event: UIControlEvents, completion: @escaping () -> ()) {
        completion()
    }
    
}


