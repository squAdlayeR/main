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
    private let nearbyPOIsUpdatedNotificationName = NSNotification.Name(rawValue:
        Setting.nearbyPOIsUpdatedNotificationName)
    
    private static var instance: GeoManager?
    private let locationManager: CLLocationManager = CLLocationManager()
    private var appSettings: AppSettings = AppSettings.getInstance()
    private var userPoint: GeoPoint = GeoPoint(0, 0)
    private var pois: [POI] = []

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
        guard let userLocation = locations.last else {
            return
        }
        userPoint = GeoPoint(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        
        
        /// TODO: Change after implement application settings
        let url = Parser.parsePOISearchRequest(appSettings.radiusOfDetection, appSettings.selectedPOICategrories, userPoint)
        Alamofire.request(url).responseJSON { [unowned self] response in
            if let json = response.result.value as? [String: Any] {
                
                self.pois = Array(Parser.parseJSONToPOIs(json).prefix(self.appSettings.maxNumberOfMarkers))
                
                NotificationCenter.default.post(name: self.nearbyPOIsUpdatedNotificationName,
                                                object: nil)
            }
        }
    }
    
    func getLastUpdatedUserPoint() -> GeoPoint {
        return userPoint
    }
    
    func getLastUpdatedNearbyPOIs() -> [POI] {
        return pois
    }

    /// TODO: Change after implement application settings.
    func getNearbyPOIS(around geoPoint: GeoPoint, complete: @escaping (_ results: [POI]) -> Void) {
        let url = Parser.parsePOISearchRequest(500, ["food"], geoPoint)
        Alamofire.request(url).responseJSON { response in
            if let json = response.result.value as? [String: Any] {
                let results = Parser.parseJSONToPOIs(json)
                complete(results)
            }
        }
    }
}






