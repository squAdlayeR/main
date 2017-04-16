//
//  LocationManager.swift
//  lAyeR
//
//  Created by luoyuyang on 13/03/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//
import Alamofire
import CoreLocation

/*
 * GeoManager monitors user location and nearby places of interest update.
 * It would send notification to notify relative view controllers to update.
 */
class GeoManager: NSObject, CLLocationManagerDelegate {
    
    /// Defines the nearby pois update notification.
    private let nearbyPOIsUpdatedNotificationName = NSNotification.Name(rawValue: ARViewConstants.nearbyPOIsUpdatedNotificationName)
    
    /// Defines user location update notification.
    private let userLocationUpdatedNotificationName = NSNotification.Name(rawValue: ARViewConstants.userLocationUpdatedNotificationName)
    
    /// Defines a singleton instance of GeoManager.
    private static var instance: GeoManager?
    
    /// Defines location manager to monitor user location update.
    private let locationManager: CLLocationManager = CLLocationManager()
    
    /// Defines app settings used to query for nearby pois.
    private var appSettings: AppSettings = AppSettings.getInstance()
    
    /// Defines default user point.
    private var userPoint: GeoPoint = GPSGPXConstants.defaultLocation
    
    /// Defines previous recorded user location.
    private var prevPoint: GeoPoint?
    
    /// Defines last updated pois.
    private var pois: [POI] = []
    
    /// Returns the singleton instance of GeoManager.
    static func getInstance() -> GeoManager {
        if instance == nil {
            instance = GeoManager()
        }
        return instance!
    }
    
    /// Initializes the geomanager.
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
    }
    
    /// Updates user points and queries for nearby pois if needed.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        /// Updates user point
        guard let userLocation = locations.last else {
            return
        }
        let currentLocation = GeoPoint(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        userPoint = currentLocation
        
        // Update user's location for mini map
        NotificationCenter.default.post(name: self.userLocationUpdatedNotificationName, object: self.userPoint)
        
        /// Initializes previous user point when first updats user location.
        guard let prevPoint = self.prevPoint else {
            self.prevPoint = userPoint
            NotificationCenter.default.post(name: self.userLocationUpdatedNotificationName, object: self.userPoint)
            forceUpdateUserNearbyPOIS()
            return
        }
        
        /// Updates previous point and requests for nearby when the distance between previous
        /// and current location excceeds maximum delta.
        guard GeoUtil.getCoordinateDistance(prevPoint, currentLocation) > GPSGPXConstants.maximumDeltaDistance else {
            return
        }
        self.prevPoint = userPoint
        forceUpdateUserNearbyPOIS()

    }
    
    /// Returns the last updated user point.
    func getLastUpdatedUserPoint() -> GeoPoint {
        return userPoint
    }
    
    /// Returns the last updated nearby pois.
    func getLastUpdatedNearbyPOIs() -> [POI] {
        return pois
    }
    
    /// Forces location manager to update user point.
    func forceUpdateUserPoint() {
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingLocation()
    }
    
    /// Forces to query nearby pois information and updates nearby pois.
    func forceUpdateUserNearbyPOIS() {
        let group = DispatchGroup()
        var candidates: [POI] = []
        for type in appSettings.selectedPOICategrories {
            group.enter()
            let url = Parser.parsePOISearchRequest(appSettings.radiusOfDetection, type, userPoint)
            Alamofire.request(url).responseJSON { [unowned self] response in
                let routes = Parser.parsePOIs(response.result.value)
                candidates.append(contentsOf: Array(routes.prefix(self.appSettings.maxNumberOfMarkers)))
                group.leave()
            }
        }
        group.notify(queue: .main) {
            candidates.sort(by: { pt1, pt2 in
                GeoUtil.getCoordinateDistance(self.userPoint, pt1) < GeoUtil.getCoordinateDistance(self.userPoint, pt2)
            })
            self.pois = Array(candidates.prefix(self.appSettings.maxNumberOfMarkers))
            NotificationCenter.default.post(name: self.nearbyPOIsUpdatedNotificationName, object: nil)
        }
    }
    
    /// Gathers the detailes information of a poi and pass it to completion handler.
    /// - Parameters:
    ///     - poi: POI: the poi to find information.
    func getDetailedPOIInfo(_ placeID: String, completion: @escaping (_ newPOI: POI?) -> ()) {
        let url = Parser.parsePOIDetailSearchRequest(placeID)
        Alamofire.request(url).responseJSON { response in
            let newPOI = Parser.parseDetailedPOI(response.result.value)
            completion(newPOI)
        }
    }
    
}






