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
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(track), userInfo: nil, repeats: true)
    }
    
    @objc func track() {
        let currentLocation = geoManager.getLastUpdatedUserPoint()
        guard currentLocation != defaultLocation else { return }
        guard let prevLocation = prevLocation else {
            self.prevLocation = currentLocation
            return
        }
        let deltaDistance = GeoUtil.getCoordinateDistance(prevLocation, currentLocation)
        guard deltaDistance > 10 else { return }
        self.prevLocation = currentLocation
        let prev = GeoPoint(prevLocation.latitude.truncate(places: 4),
                            prevLocation.longitude.truncate(places: 4))
        let curr = GeoPoint(currentLocation.latitude.truncate(places: 4),
                            currentLocation.longitude.truncate(places: 4))
        DatabaseManager.instance.sendLocationInfoToDatabase(from: prev, to: curr)
        DatabaseManager.instance.sendLocationInfoToDatabase(from: curr, to: prev) // bi-directions
    }
    
    func reset() {
        pause()
        prevLocation = nil
    }

}

