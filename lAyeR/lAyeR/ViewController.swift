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
    @IBOutlet weak var layerAlert: BasicAlert?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button1 = UIButton()
        button1.setTitle("OK", for: .normal)
        button1.titleLabel?.font = UIFont(name: buttonFontName, size: buttonFontSize)
        let button2 = UIButton()
        button2.setTitle("Cancel", for: .normal)
        button2.titleLabel?.font = UIFont(name: buttonFontName, size: buttonFontSize)
        let newLable = UILabel()
        newLable.text = "This is just for testing."
        newLable.font = UIFont(name: buttonFontName, size: 18)
        newLable.textColor = titleFontColor
        newLable.textAlignment = NSTextAlignment.center
        let frame = CGRect(x: view.bounds.width / 2 - 175,
                           y: view.bounds.height / 2 - 125,
                           width: 350,
                           height: 250)
        let newAlert = BasicAlert(frame: frame, title: nil)
        layerAlert = newAlert
        newAlert.addButton(button1)
        newAlert.addButton(button2)
        newAlert.insertIntoInfoPanel(with: newLable)
        newAlert.prepareDisplay()
        mainView.addSubview(layerAlert!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openClicked(_ sender: Any) {
        layerAlert?.open()
    }

    @IBAction func closePressed(_ sender: Any) {
        layerAlert?.close()
    }
}

