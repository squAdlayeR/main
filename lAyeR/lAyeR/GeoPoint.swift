//
//  GeoPoint.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import CoreLocation

class GeoPoint {
    
    private var location: CLLocation
    
    init(_ location: CLLocation) {
        self.location = location
    }
    
    /// east is positive, west is negative
    func getLongtitudeInRadian() -> Double {
        return location.coordinate.longitude * (M_PI/180)
    }
    
    /// north is positive, south is negative
    func getLatitudeInRadian() -> Double {
        return location.coordinate.latitude * (M_PI/180)
    }
    
    /// Returns the distance between this point and given point in meters
    /// (Coordinate distance)
    func getDistance(to geoPoint: GeoPoint) -> Double {
        return location.distance(from: geoPoint.location)
    }
    
    /// MARK: Methods below should be called after range check to preserve 
    /// accuracy.
    /// Returns the azimuth with respect to given geopoint.
    func getAzimuthInRadian(withRespectTo geoPoint: GeoPoint) -> Double {
        let referencePoint = CLLocation(latitude: geoPoint.location.coordinate.latitude, longitude: location.coordinate.longitude)
        let longtitudeDistance = referencePoint.distance(from: geoPoint.location)
        let latitudeDistance = referencePoint.distance(from: location)
        return atan2(longtitudeDistance, latitudeDistance)
    }
    
    func getAltitudeAngleInRadian(withRespectTo geoPoint: GeoPoint) -> Double {
        let coordinateDistance = getDistance(to: geoPoint)
        let altitudeDistance = location.altitude - geoPoint.location.altitude
        return atan2(altitudeDistance, coordinateDistance)
    }

}




