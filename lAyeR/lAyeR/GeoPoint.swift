//
//  GeoPoint.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import ObjectMapper
/*
 * This class is used to wrap geoLocation on the earth using their latitude and logitude.
 */
class GeoPoint: Mappable {
    
    /// Represents latitude and logitude of a GeoPoint
    private(set) var latitude: Double
    private(set) var longitude: Double
    
    /// Initializes a GeoPoint with latitude and logitude
    /// - Parameters:
    ///     - latitude: Double: latitude of the point in degrees
    ///     - longitude: Double: longitude of the point in degrees
    init(_ latitude: Double, _ longitude: Double) {
        self.latitude = GeoUtil.isValidLatitude(latitude) ? latitude : 0
        self.longitude = GeoUtil.isValidLongitude(longitude) ? longitude : 0
    }
    
    /// Initializes a GeoPoint with a map
    /// - Parameters:
    ///     - map: Map: mapping of the fields
    required init?(map: Map) {
        guard let latitude = map.JSON[ModelConstants.latitudeKey] as? Double,
            let longitude = map.JSON[ModelConstants.longitudeKey] as? Double else {
                return nil
        }
        self.latitude = GeoUtil.isValidLatitude(latitude) ? latitude : 0
        self.longitude = GeoUtil.isValidLongitude(longitude) ? longitude : 0
    }
    
    /// Forms the mapping.
    /// - Parameters:
    ///     - map: Map: mapping of the fields
    func mapping(map: Map) {
        latitude <- map[ModelConstants.latitudeKey]
        longitude <- map[ModelConstants.longitudeKey]
    }
    
}

extension GeoPoint: Equatable {}

/// Returns true if the latitude and longitude of the geo points are equal
func ==(lhs: GeoPoint, rhs: GeoPoint) -> Bool {
    return lhs.latitude == rhs.latitude
        && lhs.longitude == rhs.longitude
}

