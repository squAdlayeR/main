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
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var exportButton: UIButton!
    
    @IBOutlet weak var testTextField: UITextField!
    
    let tracker = GPSTracker.instance
    var timer = Timer()
    
    
    var documentInteractionController = UIDocumentInteractionController()
    
    override func viewDidLoad() {
        
        let path = URL(fileURLWithPath: Bundle.main.path(forResource: "confirm", ofType: "wav")!)
        //let path =
        documentInteractionController = UIDocumentInteractionController(url: path)
        documentInteractionController.delegate = self
        documentInteractionController.uti = "wav"
    
    }
    
    @IBAction func test(_ sender: Any) {
        openDocumentIn()
    }
    
    @IBAction func startPressed(_ sender: Any) {
        tracker.start()
    }
    
    @IBAction func pausePressed(_ sender: Any) {
        tracker.pause()
    }
    
    @IBAction func stopPressed(_ sender: Any) {
        tracker.stop()
    }
    
    @IBAction func uploadPressed(_ sender: Any) {
    }
    
    
    @IBAction func exportPressed(_ sender: Any) {
    }
}

extension GPSTrackerViewController: UIDocumentInteractionControllerDelegate {
    
    func openDocumentIn() {
        documentInteractionController.presentOptionsMenu(from: CGRect.zero, in: view , animated: true)
    }
    
    func documentInteractionController(_ controller: UIDocumentInteractionController, willBeginSendingToApplication application: String?) {
        
    }
    
    func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
        
    }
    
    func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
        
    }
}
