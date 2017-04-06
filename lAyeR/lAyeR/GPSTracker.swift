//
//  GPSTracker.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/6.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import CoreLocation

class GPSTracker {
    
    private var timer: Timer?
    private var route: Route?
    private var prevLocation: GeoPoint?
    private var geoManager = GeoManager.getInstance()
    private let defaultLocation = GeoPoint(0, 0)
    
    func start() {
        route = Route("New Route")
        timer = Timer(timeInterval: 5, target: self, selector: #selector(track), userInfo: nil, repeats: true)
    }
    
    @objc func track() {
        let currentLocation = geoManager.getLastUpdatedUserPoint()
        guard currentLocation != defaultLocation else { return }
        guard let prevLocation = prevLocation else {
            self.prevLocation = currentLocation
            route?.append(CheckPoint(currentLocation, "Source", "", true))
            return
        }
        guard GeoUtil.getCoordinateDistance(prevLocation, currentLocation) > 5 else { return }
        self.prevLocation = currentLocation
        self.route?.append(CheckPoint(currentLocation, "Way Point"))
    }
    
    func save(routeName: String, uploadFlag: Bool, localFlag: Bool) {
        let currentLocation = geoManager.getLastUpdatedUserPoint()
        route?.append(CheckPoint(currentLocation, "Destination", "", true))
        route?.setName(name: routeName)
        //
        // Storage operation occurs here.
        //
        stop()
    }
    
    func insert(name: String, description: String) {
        guard let route = route else { return }
        timer?.invalidate()
        timer = nil
        let currentLocation = geoManager.getLastUpdatedUserPoint()
        self.prevLocation = currentLocation
        self.route?.append(CheckPoint(currentLocation, name, description, true))
        timer = Timer(timeInterval: 5, target: self, selector: #selector(track), userInfo: nil, repeats: true)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        route = nil
        prevLocation = nil
    }
}
