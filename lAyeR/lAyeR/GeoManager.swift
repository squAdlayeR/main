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
                                                                        Constant.nearbyPOIsUpdatedNotificationName)
    private let userLocationUpdatedNotificationName = NSNotification.Name(rawValue:
                                                                        Constant.userLocationUpdatedNotificationName)
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
        let currentLocation = GeoPoint(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        userPoint = currentLocation
        
        // Update user's location for mini map
        NotificationCenter.default.post(name: self.userLocationUpdatedNotificationName, object: self.userPoint)
        
        /// Sets a threshold for poi query
        guard GeoUtil.getCoordinateDistance(userPoint, currentLocation) > 25 else { return }
        let group = DispatchGroup()
        var candidates: [POI] = []
        for type in appSettings.selectedPOICategrories {
            group.enter()
            let url = Parser.parsePOISearchRequest(appSettings.radiusOfDetection, type, userPoint)
            Alamofire.request(url).responseJSON { [unowned self] response in
                guard let json = response.result.value as? [String: Any] else {
                    return
                }
                candidates.append(contentsOf: Array(Parser.parseJSONToPOIs(json).prefix(self.appSettings.maxNumberOfMarkers)))
                group.leave()
            }
        }
        group.notify(queue: .main) {
            self.pois = candidates
            NotificationCenter.default.post(name: self.nearbyPOIsUpdatedNotificationName, object: nil)
        }
    }
    
    func getLastUpdatedUserPoint() -> GeoPoint {
        return userPoint
    }
    
    func getLastUpdatedNearbyPOIs() -> [POI] {
        return pois
    }
    
    func forceUpdateUserNearbyPOIS() {
        let group = DispatchGroup()
        var candidates: [POI] = []
        for type in appSettings.selectedPOICategrories {
            group.enter()
            let url = Parser.parsePOISearchRequest(appSettings.radiusOfDetection, type, userPoint)
            Alamofire.request(url).responseJSON { [unowned self] response in
                guard let json = response.result.value as? [String: Any] else {
                    return
                }
                candidates.append(contentsOf: Array(Parser.parseJSONToPOIs(json).prefix(self.appSettings.maxNumberOfMarkers)))
                group.leave()
            }
        }
        group.notify(queue: .main) {
            self.pois = candidates
            NotificationCenter.default.post(name: self.nearbyPOIsUpdatedNotificationName, object: nil)
        }
        
    }
    
    func getDetailedPOIInfo(_ poi: POI, completion: @escaping (_ newPOI: POI) -> ()) {
        guard let placeID = poi.placeID else { return }
        let url = Parser.parsePOIDetailSearchRequest(placeID)
        Alamofire.request(url).responseJSON { response in
            guard let json = response.result.value as? [String: Any],
                let newPOI = Parser.parseDetailedPOI(json) else {
                return
            }
            completion(newPOI)
        }
    }
    
    func forceUpdateUserPoint() {
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingLocation()
    }
}






