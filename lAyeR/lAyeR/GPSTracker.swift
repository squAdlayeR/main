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
    
    static let instance = GPSTracker()
    private var timer: Timer?
    private var prevLocation: GeoPoint?
    private var geoManager = GeoManager.getInstance()
    private let defaultLocation = GeoPoint(0, 0)
    
    func start() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(track), userInfo: nil, repeats: true)
    }
    
    @objc func track() {
        let currentLocation = geoManager.getLastUpdatedUserPoint()
        guard currentLocation != defaultLocation else { return }
        guard let prevLocation = prevLocation else {
            self.prevLocation = currentLocation
            return
        }
        let deltaDistance = GeoUtil.getCoordinateDistance(prevLocation, currentLocation)
        /// acceptable threshold
        guard deltaDistance > 10 && deltaDistance < 25 else {
            return
        }
        self.prevLocation = currentLocation
        let prev = GeoPoint(prevLocation.latitude.truncate(places: 4),
                            prevLocation.longitude.truncate(places: 4))
        let curr = GeoPoint(currentLocation.latitude.truncate(places: 4),
                            currentLocation.longitude.truncate(places: 4))
        guard fabs(prev.latitude-curr.latitude) <= 0.0001 && fabs(prev.longitude-curr.longitude) <= 0.0001 else {
            return //accross grid
        }
        DatabaseManager.instance.sendLocationInfoToDatabase(from: prev, to: curr)
        DatabaseManager.instance.sendLocationInfoToDatabase(from: curr, to: prev) // bi-directions
        DatabaseManager.instance.sendLocationInfoToDatabase(from: GeoPoint(prev.latitude, curr.longitude), to: GeoPoint(curr.latitude, prev.longitude))
        DatabaseManager.instance.sendLocationInfoToDatabase(from: GeoPoint(curr.latitude, prev.longitude), to: GeoPoint(prev.latitude, curr.longitude))
    }
    
    func reset() {
        pause()
        prevLocation = nil
    }

}

