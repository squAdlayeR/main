//
//  GeoUtil.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/11.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import CoreLocation

/*
 * Provides calculation for geopoint math.
 */
class GeoUtil {
    
    /// Returns the coordinate distance between two points in meters.
    static func getCoordinateDistance(_ geoPoint1: GeoPoint, _ geoPoint2: GeoPoint) -> Double {
        return geoPoint1.location.distance(from: geoPoint2.location)
    }
    
    /// Returns the altitude difference between two points in meters.
    static func getAltitudeDifference(_ geoPoint1: GeoPoint, _ geoPoint2: GeoPoint) -> Double {
        return geoPoint1.location.altitude - geoPoint2.location.altitude
    }
    
    /// Returns the azimuth between two points with respect to the first
    /// point in radians.
    static func getAzimuth(between geoPoint1: GeoPoint, _ geoPoint2: GeoPoint) -> Double {
        let referencePoint = CLLocation(latitude: geoPoint2.location.coordinate.latitude, longitude: geoPoint1.location.coordinate.longitude)
        let longtitudeDistance = referencePoint.distance(from: geoPoint2.location)
        let latitudeDistance = referencePoint.distance(from: geoPoint1.location)
        return atan2(longtitudeDistance, latitudeDistance)
    }
    
    /// Returns the altitude angle between two points in radians.
    static func getAltitudeAngleInRadian(_ geoPoint1: GeoPoint, _ geoPoint2: GeoPoint) -> Double {
        let coordinateDistance = getCoordinateDistance(geoPoint1, geoPoint2)
        let altitudeDistance = getAltitudeDifference(geoPoint2, geoPoint1)
        return atan2(altitudeDistance, coordinateDistance)
    }
    
}

