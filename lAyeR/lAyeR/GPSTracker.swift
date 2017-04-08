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
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(track), userInfo: nil, repeats: true)
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
        DatabaseManager.instance.sendLocationInfoToDatabase(from: prevLocation, to: currentLocation)
        self.prevLocation = currentLocation
    }
    
    func reset() {
        pause()
        prevLocation = nil
    }

}

