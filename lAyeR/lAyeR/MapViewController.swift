//
//  MapViewController.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit
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
        let urlPath: String = MapQueryParser.googleServerURL
        let url: NSURL = NSURL(string: urlPath)!
        let request1: NSURLRequest = NSURLRequest(url: url as URL)
        let response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
        
        
        do{
            
            let dataVal = try NSURLConnection.sendSynchronousRequest(request1 as URLRequest, returning: response)
            
            print(response)
            do {
//                if let jsonResult = try JSONSerialization.jsonObject(with: dataVal, options: []) as? NSDictionary {
//                    print("Synchronous\(jsonResult)")
//                }
                MapQueryParser.parseServerResponse(dataVal)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            
            
        }catch let error as NSError
        {
            print(error.localizedDescription)
        }
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
