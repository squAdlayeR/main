//
//  MapViewController.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import GooglePlaces
import GoogleMaps

class MapViewController: UIViewController {

    var placesClient: GMSPlacesClient?
    let locationManager: CLLocationManager = CLLocationManager()
    var userLocation: CLLocation?
    var mapViewDelegate: MapViewDelegate = MapViewDelegate()
    
    // Instantiate a pair of UILabels in Interface Builder
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    // Test
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = mapViewDelegate
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        //placesClient = GMSPlacesClient()
    }
    
    func test() {
        
    }
    
    // Test
    @IBAction func getLocation(_ sender: Any) {
        // test method
        //print(mapViewDelegate.userLocation)
        test()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    
}
