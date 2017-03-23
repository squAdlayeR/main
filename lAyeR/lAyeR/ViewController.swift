//
//  ViewController.swift
//  lAyeR
//
//  Created by BillStark on 3/1/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController, CLLocationManagerDelegate {

    var placesClient: GMSPlacesClient?
    let locationManger: CLLocationManager = CLLocationManager()
    var userLocation: CLLocation?
    
    // Instantiate a pair of UILabels in Interface Builder
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    // Test
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManger.delegate = self
        locationManger.requestAlwaysAuthorization()
        locationManger.requestWhenInUseAuthorization()
        placesClient = GMSPlacesClient()
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.startUpdatingLocation()
    }
    
    // Add a UIButton in Interface Builder to call this function
    // Test
    @IBAction func getLocation(_ sender: Any) {
        placesClient?.currentPlace(callback: {
            (placeLikelihoodList: GMSPlaceLikelihoodList?, error: Error?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            self.nameLabel.text = "No current place"
            self.addressLabel.text = ""
            
            if let placeLicklihoodList = placeLikelihoodList {
                let place = placeLicklihoodList.likelihoods.first?.place
                if let place = place {
                    self.nameLabel.text = place.name
                    self.addressLabel.text = place.formattedAddress
                    
                }
            }
            
        })
        //print(userLocation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// Test
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("called")
        userLocation = locations.last
        guard let userLocation = userLocation else {
            print("unrecognizable location.")
            return
        }
        print(userLocation.altitude)
    }

}

