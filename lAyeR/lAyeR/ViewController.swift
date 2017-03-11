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
        
        
//        let button2 = UIButton()
//        button2.setTitle("Cancel", for: .normal)
//        button2.titleLabel?.font = UIFont(name: buttonFontName, size: buttonFontSize)
        
        let button1 = UIButton()
        button1.setTitle("OK", for: .normal)
        button1.titleLabel?.font = UIFont(name: buttonFontName, size: buttonFontSize)
        button1.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        
        let newLable = UILabel()
        newLable.text = "Welcome to lAyeR! Your AR jouney starts from here."
        newLable.font = UIFont(name: buttonFontName, size: 18)
        newLable.textColor = titleFontColor
        newLable.textAlignment = NSTextAlignment.center
        
        let frame = CGRect(x: view.bounds.width / 2 - 175,
                           y: view.bounds.height / 2 - 125,
                           width: 350,
                           height: 250)
        let newAlertController = BasicAlertController(title: "Welcome", frame: frame)
        newAlertController.addViewToAlert(newLable)
        newAlertController.addButtonToAlert(button1)
        newAlertController.presentAlert(within: mainView)
        testController = newAlertController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openClicked(_ sender: Any) {
        testController?.presentAlert(within: mainView)
    }

    @IBAction func closePressed(_ sender: Any) {
        testController?.closeAlert()
    }
    
    func confirmAction() {
        testController?.closeAlert()
    }
    
}

