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
    @IBOutlet weak var layerAlert: LayerAlert?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRect(x: view.bounds.width / 2 - 175,
                           y: view.bounds.height / 2 - 200,
                           width: 350,
                           height: 400)
        let newAlert = LayerAlert(frame: frame, topBannerHeight: 70, bottomBannerHeight: 70)
        layerAlert = newAlert
        mainView.addSubview(layerAlert!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openClicked(_ sender: Any) {
        layerAlert?.toggle()
    }

}

