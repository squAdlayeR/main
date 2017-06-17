//
//  GeoUtil.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/11.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import CoreLocation
/*
 * Provides calculation for geopoint math.
 */
class GeoUtil {
    
    /// Returns the coordinate distance between two points in meters
    /// - Parameters:
    ///     - geoPoint1: GeoPoint
    ///     - geoPoint2: GeoPoint
    /// - Returns:
    ///     - Double: coordinate distance of the points in meters
    static func getCoordinateDistance(_ geoPoint1: GeoPoint, _ geoPoint2: GeoPoint) -> Double {
        let location1 = CLLocation(latitude: geoPoint1.latitude,
                                   longitude: geoPoint1.longitude)
        let location2 = CLLocation(latitude: geoPoint2.latitude,
                                   longitude: geoPoint2.longitude)
        return location1.distance(from: location2)
    }
    
    /// Returns the azimuth between two points with respect to the first point in radians
    /// - Parameters:
    ///     - geoPoint1: GeoPoint
    ///     - geoPoint2: GeoPoint
    /// - Returns:
    ///     - Double: azimuth between with respect to the first point in radians
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
    
    /// Returns true if the given latitude is valid
    /// - Parameters: 
    ///     - lat: Double: latitude to check
    /// - Returns: 
    ///     - Bool: true if the given latitude is valid
    static func isValidLatitude(_ lat: Double) -> Bool {
        return ModelConstants.minLat <= lat && lat <= ModelConstants.maxLat
    }
    
    /// Returns true if the given longitude is valid
    /// - Parameters:
    ///     - lon: Double: longitude to check
    /// - Returns:
    ///     - Bool: true if the given longitude is valid
    static func isValidLongitude(_ lon: Double) -> Bool {
        return ModelConstants.minLon <= lon && lon <= ModelConstants.maxLon
    }
    
    /// Returns true if the routes has similar shapes specified by threshold
    /// - Parameters:
    ///     - route1: Route
    ///     - route2: Route
    ///     - threshold: Double: error threshold for comparison
    /// - Returns:
    ///     - Bool: true if the routes are similar
    /// MARK: We use approximation methods here, the dissimilarity score is the sum
    /// of the minimum distance of each point in one route to the line segments in
    /// another route
    static func isSimilar(route1: Route, route2: Route, threshold: Double) -> Bool {
        let pathScore1 = getPathDissimilarityScore(from: route1, to: route2)
        let pathScore2 = getPathDissimilarityScore(from: route2, to: route1)
        return pathScore1/Double(route1.checkPoints.count) + pathScore2/Double(route2.checkPoints.count) <= threshold
    }
    
    /// Returns the dissimilarity score from route1 to route2
    /// - Parameters:
    ///     - route1: Route
    ///     - route2: Route
    /// - Returns:
    ///     - Double: the dissimilarity score
    static func getPathDissimilarityScore(from route1: Route, to route2: Route) -> Double {
        var sum: Double = 0
        for index in 0..<route1.checkPoints.count {
            let pt = route1.checkPoints[index]
            var min: Double = .greatestFiniteMagnitude
            for idx in 0..<route2.checkPoints.count - 1 {
                let pt1 = route2.checkPoints[idx]
                let pt2 = route2.checkPoints[idx + 1]
                let delta = distanceFromPointToLine(point: pt, fromLineSegmentBetween: pt1, and: pt2)
                min = min > delta ? delta : min
            }
            sum += min
        }
        return sum
    }
    
    /// Returns the distance from a point to the line segment
    /// - Parameters:
    ///     - p: GeoPoint: reference point
    ///     - l1: GeoPoint: one point of the line segment
    ///     - l2: GeoPoint: the other point of the line segment
    /// - Returns:
    ///     - Double: the distance from p to l1l2
    static func distanceFromPointToLine(point p: GeoPoint, fromLineSegmentBetween l1: GeoPoint, and l2: GeoPoint) -> Double {
        let a = p.latitude - l1.latitude
        let b = p.longitude - l1.longitude
        let c = l2.latitude - l1.latitude
        let d = l2.longitude - l1.longitude
        
        let dot = a * c + b * d
        let lenSq = c * c + d * d
        let param = dot / lenSq
        
        var xx: Double!
        var yy: Double!
        
        if param < 0 || (l1.latitude == l2.latitude && l1.longitude == l2.longitude) {
            xx = l1.latitude
            yy = l1.longitude
        } else if (param > 1) {
            xx = l2.latitude
            yy = l2.longitude
        } else {
            xx = l1.latitude + param * c
            yy = l1.longitude + param * d
        }
        
        let dx = p.latitude - xx
        let dy = p.longitude - yy
        
        return sqrt(dx * dx + dy * dy)
    }
    
}

