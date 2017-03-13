//
//  ViewController.swift
//  lAyeR
//
//  Created by BillStark on 3/1/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    var testController: BasicAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let checkpointFrame = CGRect(x: (view.bounds.width - suggestedPopupWidth) / 2,
                                 y: (view.bounds.height - suggestedPopupHeight) / 2,
                                 width: suggestedPopupWidth,
                                 height: suggestedPopupHeight)
        let newMarker = CheckpointView(frame: checkpointFrame, name: "Check Point #1", distance: 100.0, description: "test")
        mainView.addSubview(newMarker)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

