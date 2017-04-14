//
//  GPSTracker.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/6.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import CoreLocation

/* GPSTracker is a class used to track user location and notify database
 * to upload trackpoints to cloud.
 */
/// MARK: Here, we devide the world map into approximately 11m * 11m
/// (0.0001 difference in degrees) grid, and use the edges in this
/// graph to track user walking and find walkable paths.
class GPSTracker {
    
    static let instance = GPSTracker()
    private var timer: Timer?
    private var prevLocation: GeoPoint?
    private let geoManager = GeoManager.getInstance()
    
    /// Starts the timer.
    func start() {
        timer = Timer.scheduledTimer(timeInterval: GPSGPXConstants.timeInterval, target: self, selector: #selector(track), userInfo: nil, repeats: true)
    }
    
    /// Fires every time interval to process current and previous 
    /// user location and notifies database to record the trackpoints if 
    /// needed.
    @objc func track() {
        
        // Get current user location.
        let currentLocation = geoManager.getLastUpdatedUserPoint()
        
        // If current user location is not updated yet, skip this round.
        guard currentLocation != GPSGPXConstants.defaultLocation else { return }
        
        // If the first location is recorded, update previous location.
        guard let prevLocation = prevLocation else {
            self.prevLocation = currentLocation
            return
        }
        
        // Computes delta distance, if still within grid range or went too far, skip this round.
        guard isWithinUnitRange(prevLocation, currentLocation) else {
            return
        }
        
        // Updates previous location when user is travelled far enough.
        self.prevLocation = currentLocation
        
        // Transforms CLLocation representation into GeoPoint.
        // Truncates coordinate to 4 decimal places, which approximates
        // around 10~15 meters in the world.
        let prev = getTruncatedTrackPoint(prevLocation)
        let curr = getTruncatedTrackPoint(currentLocation)
        
        // Double checks the grid coordinate, if the points are vetices of
        // same grid, recorded it. Otherwise discards and skips this round
        // because this might results from inaccurate GPS locating.
        guard isOnSameGrid(prev, curr) else { return }
        
        // Notifies database manager to save/update trackpoints in cloud.
        DatabaseManager.instance.sendLocationInfoToDatabase(from: prev, to: curr)
        DatabaseManager.instance.sendLocationInfoToDatabase(from: curr, to: prev)
        DatabaseManager.instance.sendLocationInfoToDatabase(from: GeoPoint(prev.latitude, curr.longitude), to: GeoPoint(curr.latitude, prev.longitude))
        DatabaseManager.instance.sendLocationInfoToDatabase(from: GeoPoint(curr.latitude, prev.longitude), to: GeoPoint(prev.latitude, curr.longitude))
    }
    
    /// Resets the timer.
    func reset() {
        timer?.invalidate()
        timer = nil
        prevLocation = nil
    }
    
    /// Returns true if the two locations' delta distance is within valid
    /// unit range.
    private func isWithinUnitRange(_ prev: GeoPoint, _ curr: GeoPoint) -> Bool {
        let deltaDistance = GeoUtil.getCoordinateDistance(prev, curr)
        return deltaDistance < GPSGPXConstants.maximumDeltaDistance && deltaDistance > GPSGPXConstants.minimumDeltaDistance
    }
    
    /// Returns true if the two locations are on the same unit grid.
    private func isOnSameGrid(_ prev: GeoPoint, _ curr: GeoPoint) -> Bool {
        let deltaLatitude = fabs(prev.latitude-curr.latitude)
        let deltaLongitude = fabs(prev.longitude-curr.longitude)
        return deltaLatitude <= GPSGPXConstants.approximationThreshold && deltaLongitude <= GPSGPXConstants.approximationThreshold
    }
    
    /// Truncates the geoPoint's coordinate to pre-defined precision.
    private func getTruncatedTrackPoint(_ geoPoint: GeoPoint) -> GeoPoint {
        let newLat = geoPoint.latitude.truncate(places: GPSGPXConstants.precision)
        let newLon = geoPoint.longitude.truncate(places: GPSGPXConstants.precision)
        return GeoPoint(newLat, newLon)
    }
    
}

