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
        let location1 = CLLocation(latitude: geoPoint1.latitude,
                                   longitude: geoPoint1.longitude)
        let location2 = CLLocation(latitude: geoPoint2.latitude,
                                   longitude: geoPoint2.longitude)
        return location1.distance(from: location2)
    }
    
    /// Returns the altitude difference between two points in meters.
//    static func getAltitudeDifference(_ geoPoint1: GeoPoint, _ geoPoint2: GeoPoint) -> Double {
//        return geoPoint1.location.altitude - geoPoint2.location.altitude
//    }
    
    /// Returns the azimuth between two points with respect to the first
    /// point in radians.
    static func getAzimuth(between geoPoint1: GeoPoint, _ geoPoint2: GeoPoint) -> Double {
        let location1 = CLLocation(latitude: geoPoint1.latitude,
                                   longitude: geoPoint1.longitude)
        let location2 = CLLocation(latitude: geoPoint2.latitude,
                                   longitude: geoPoint2.longitude)
        let referencePoint = CLLocation(latitude: geoPoint2.latitude,
                                        longitude: geoPoint1.longitude)
        var longtitudeDistance = referencePoint.distance(from: location2)
        var latitudeDistance = referencePoint.distance(from: location1)
        if geoPoint2.longitude < geoPoint1.longitude {
            longtitudeDistance = -longtitudeDistance
        }
        if geoPoint2.latitude < geoPoint1.latitude {
            latitudeDistance = -latitudeDistance
        }
        return atan2(longtitudeDistance, latitudeDistance)
    }
    
    /// Returns the altitude angle between two points in radians.
//    static func getAltitudeAngleInRadian(_ geoPoint1: GeoPoint, _ geoPoint2: GeoPoint) -> Double {
//        let coordinateDistance = getCoordinateDistance(geoPoint1, geoPoint2)
//        let altitudeDistance = getAltitudeDifference(geoPoint2, geoPoint1)
//        return atan2(altitudeDistance, coordinateDistance)
//    }
    
}

