//
//  LocationManager.swift
//  lAyeR
//
//  Created by luoyuyang on 13/03/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import Alamofire
import GooglePlaces
import GoogleMaps

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager: CLLocationManager = CLLocationManager()
    var userLocation: CLLocation!
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
    
    func getUserPoint() -> GeoPoint {
        guard let userLocation = userLocation else {
            return GeoPoint(0, 0)
        }
        return GeoPoint(userLocation.coordinate.latitude,
                        userLocation.coordinate.longitude)
    }
}
