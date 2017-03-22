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

class GeoManager: NSObject, CLLocationManagerDelegate {
    
    private static var instance: GeoManager?
    private let locationManager: CLLocationManager = CLLocationManager()
    
    private var userLocation: CLLocation!
    private var pois: [POI] = []
    private var poiUpdated = false
    
    static func getInstance() -> GeoManager {
        if instance == nil {
            instance = GeoManager()
        }
        return instance!
    }
    
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
        
        /// TODO: Change after implement application settings
        let userPoint = GeoPoint(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        let url = Parser.parsePOISearchRequest(500, "food", userPoint)
        Alamofire.request(url).responseJSON { [unowned self] response in
            if let json = response.result.value as? [String: Any] {
                self.pois = Parser.parseJSONToPOIs(json)
                
                self.poiUpdated = true
            }
        }
    }
    
    func getUserPoint() -> GeoPoint {
        guard let userLocation = userLocation else {
            return GeoPoint(0, 0)
        }
        return GeoPoint(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
    }
    
    func getUpdatedNearbyPOIs() -> [POI]? {
        if (poiUpdated) {
            poiUpdated = false
            return pois
        }
        return nil
    }
    
    
    
    
    
    
    /// TODO: Change after implement application settings.
    func getNearbyPOIS(around geoPoint: GeoPoint, complete: @escaping (_ results: [POI]) -> Void) {
        let url = Parser.parsePOISearchRequest(500, "food", geoPoint)
        Alamofire.request(url).responseJSON { response in
            if let json = response.result.value as? [String: Any] {
                let results = Parser.parseJSONToPOIs(json)
                complete(results)
            }
        }
    }
}






