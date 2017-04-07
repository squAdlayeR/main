//
//  ExportViewControllerProtocol.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/7.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit

extension RouteDesignerViewController {
    
    func handleOpenUrl(url: URL) {
        // load route here.
        do {
            let routes = try GPXManager.load(with: url)
            // load routes
        } catch {
            showAlertMessage(message: "Fail to load the routes.")
        }
    }
    
}

extension UIViewController {
    
    func showAlertMessage(message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

/// Using DocumentInteractionViewController
extension UIViewController: UIDocumentInteractionControllerDelegate {
    
//    func export(route: Route) {
//        do {
//            try GPXManager.save(route: route)
//            let path = try GPXManager.getPath(with: route.name)
//            let url = URL(fileURLWithPath: path)
//            openDocumentIn(url: url)
//        } catch {
//            showAlertMessage(message: "Fail to create .gpx file.")
//        }
//    }
//        
//    func openDocumentIn(url: URL) {
//        let documentInteractionController = UIDocumentInteractionController()
//        documentInteractionController.delegate = self
//        documentInteractionController.uti = "com.topografix.gpx"
//        documentInteractionController.url = url
//        documentInteractionController.presentOptionsMenu(from: CGRect.zero, in: view , animated: true)
//    }
    
    func share(routes: [Route]) {
        do {
            var urls: [URL] = []
            for route in routes {
                try GPXManager.save(route: route)
                let path = try GPXManager.getPath(with: route.name)
                let url = URL(fileURLWithPath: path)
                urls.append(url)
            }
            let activityViewController = UIActivityViewController(activityItems: urls, applicationActivities: nil)
            activityViewController.completionWithItemsHandler = {
                (type, completed: Bool, items: [Any]?, error: Error?) in
                guard completed else { return }
                urls.forEach { GPXManager.delete(url: $0) } // clear cache
            }
            present(activityViewController, animated: true, completion: nil)
        } catch {
            showAlertMessage(message: "Fail to create .gpx files.")
        }
    }
    
}
