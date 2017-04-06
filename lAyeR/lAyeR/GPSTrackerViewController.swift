//
//  GPSTrackerView.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/7.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit

class GPSTrackerViewController: UIViewController {
    
    var documentInteractionController = UIDocumentInteractionController()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.black
        let path = URL(fileURLWithPath: Bundle.main.path(forResource: "confirm", ofType: "wav")!)
        //let path =
        documentInteractionController = UIDocumentInteractionController(url: path)
        documentInteractionController.delegate = self
        documentInteractionController.uti = "wav"
    
    }
    
    @IBAction func test(_ sender: Any) {
        openDocumentIn()
        //do {
            //let gpx = try GPSTrackerParser.instace.parseRouteToGPX(route: Route.testRoute)
            //print(gpx)
            //let routes = try GPSTrackerParser.instace.parseGPXToRoute(filePath: "/Users/victoriaduan/Downloads/t.gpx")
            //print(routes.first?.name)
        //} catch {
            //print(error.localizedDescription)
        //}
        
    }
}

extension GPSTrackerViewController: UIDocumentInteractionControllerDelegate {
    
    func openDocumentIn() {
        
        //documentInteractionController.presentOpenInMenu(from: CGRect(x: 0, y: 0, width: 200, height: 300), in: view, animated: true)
        //documentInteractionControllerWillPresentOptionsMenu(self)
        documentInteractionController.presentOptionsMenu(from: CGRect.zero, in: view , animated: true)
    }
    
    func documentInteractionController(_ controller: UIDocumentInteractionController, willBeginSendingToApplication application: String?) {
        
    }
    
    func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
        
    }
    
    func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
        
    }
}
