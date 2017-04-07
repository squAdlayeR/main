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
    private(set) var route: Route?
    private var prevLocation: GeoPoint?
    private var geoManager = GeoManager.getInstance()
    private let defaultLocation = GeoPoint(0, 0)
    private(set) var distance: Double = 0
    private(set) var isStarted: Bool = false
    
    func start() {
        route = Route("New Route")
        isStarted = true
        resume()
    }
    
    @objc func track() {
        let currentLocation = geoManager.getLastUpdatedUserPoint()
        guard currentLocation != defaultLocation else { return }
        guard let prevLocation = prevLocation else {
            self.prevLocation = currentLocation
            route?.append(CheckPoint(currentLocation, "Source", "", true))
            return
        }
        let deltaDistance = GeoUtil.getCoordinateDistance(prevLocation, currentLocation)
        guard deltaDistance > 5 else { return }
        self.distance += deltaDistance
        self.prevLocation = currentLocation
        self.route?.append(CheckPoint(currentLocation, "Way Point"))
    }
    
    func insert(name: String, description: String) {
        guard route != nil else { return }
        let currentLocation = geoManager.getLastUpdatedUserPoint()
        let deltaDistance = GeoUtil.getCoordinateDistance(self.prevLocation!, currentLocation)
        self.distance += deltaDistance
        self.prevLocation = currentLocation
        self.route?.append(CheckPoint(currentLocation, name, description, true))
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
    }
    
    func resume() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(track), userInfo: nil, repeats: true)
    }
    
    func reset() {
        isStarted = false
        pause()
        route = nil
        prevLocation = nil
        distance = 0
    }
    
    func getExportURL() throws -> URL {
        guard let route = route else {
            throw GPXError.noRouteFound
        }
        //let route = Route.testRoute
        try GPXManager.save(route: route)
        let path = try GPXManager.getPath(with: route.name)
        return URL(fileURLWithPath: path)
    }
    
    func deleteCache(name: String) {
        GPXManager.delete(routeName: name)
    }
}

