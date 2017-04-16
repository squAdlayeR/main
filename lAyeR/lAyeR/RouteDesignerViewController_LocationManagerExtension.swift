//
//  RouteDesignerViewController_LocationManagerExtension.swift
//  lAyeR
//
//  Created by Patrick Cho on 4/8/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

extension RouteDesignerViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        myLocation = location
        if mapView.isHidden {
            mapView.isHidden = false
            if usingCurrentLocationAsSource {
                mapView.camera = camera
            }
        } else {
            changeStartLocation()
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // print("Error: \(error)")
    }
    
    func changeStartLocation() {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        if !markers.isEmpty && usingCurrentLocationAsSource {
            modifyManualLine(at: 0)
        }
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
}
