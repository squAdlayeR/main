//
//  AppSettingsViewController.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 2/4/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

class AppSettingsViewController: UIViewController {

    
    @IBOutlet weak var settingTitle: UILabel!
    @IBOutlet weak var poiSubtitle: UILabel!
    @IBOutlet weak var detectionRadiusText: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var detectionRadius: UILabel!
    @IBOutlet weak var numberOfMarkerText: UILabel!
    @IBOutlet weak var numberOfMarkerSlider: UISlider!
    @IBOutlet weak var numberOfMarker: UILabel!
    @IBOutlet weak var categoriesText: UILabel!
    @IBOutlet weak var categoriesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
