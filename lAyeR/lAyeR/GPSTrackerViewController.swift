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
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    let tracker = GPSTracker.instance
    
    var documentInteractionController = UIDocumentInteractionController()
    
    override func viewDidLoad() {
        
        documentInteractionController.delegate = self
        documentInteractionController.uti = "com.topografix.gpx"
    
    }

    @IBAction func savePressed(_ sender: Any) {
        promptExportDialog()
    }
    @IBAction func startPressed(_ sender: Any) {
        let title = startButton.title(for: .normal)!
        switch title {
        case "Start":
            startButton.setTitle("Pause", for: .normal)
            tracker.start()
            break
        case "Pause":
            startButton.setTitle("Resume", for: .normal)
            tracker.pause()
            promptInsertDialog()
            break
        case "Resume":
            startButton.setTitle("Pause", for: .normal)
            tracker.resume()
            break
        default:
            break
        }
    }
    
    @IBAction func stopPressed(_ sender: Any) {
        startButton.setTitle("Start", for: .normal)
        tracker.reset()
    }
    
    func promptExportDialog() {
        var nameTextField: UITextField?
        let prompt = UIAlertController(title: "Export To GPX", message: "Please name your route", preferredStyle: UIAlertControllerStyle.alert)
        prompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        prompt.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action) -> Void in
            let name = nameTextField?.text ?? "New Route"
            self.tracker.route?.setName(name: name)
            do {
                let url = try self.tracker.getExportURL()
                self.openDocumentIn(url: url)
            } catch {
                print(error.localizedDescription)
            }
        }))
        prompt.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Name"
            nameTextField = textField
        })
        present(prompt, animated: true, completion: nil)
    }
    
    
    func promptInsertDialog() {
        var nameTextField: UITextField?
        var descTextField: UITextField?
        let prompt = UIAlertController(title: "Insert Way Point", message: "Please key in information", preferredStyle: UIAlertControllerStyle.alert)
        prompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        prompt.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action) -> Void in
            self.tracker.insert(name: (nameTextField?.text!)!, description: (descTextField?.text)!)
        }))
        prompt.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Name"
            nameTextField = textField
        })
        prompt.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Description"
            descTextField = textField
        })
        present(prompt, animated: true, completion: nil)
    }
    
}

extension GPSTrackerViewController: UIDocumentInteractionControllerDelegate {
    
    func openDocumentIn(url: URL) {
        documentInteractionController.url = url
        documentInteractionController.presentOptionsMenu(from: CGRect.zero, in: view , animated: true)
    }
    
    func documentInteractionController(_ controller: UIDocumentInteractionController, willBeginSendingToApplication application: String?) {
    }
    
    func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
    }
    
    func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
    }
}
