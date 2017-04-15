//
//  TrackPoint.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/9.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import ObjectMapper

/*
 * TrackPoint inherits CheckPoint and represents a vertex of an approximately 10m by 10m
 * grid in the world. It has four boolean values that specify whether from this point can
 * go up, down, left, or right to reach another vertex.
 */
class TrackPoint: CheckPoint {
    
    /// Defines the reachable directions of the track point
    var up: Bool = false
    var down: Bool = false
    var left: Bool = false
    var right: Bool = false
    
    /// Initializes the track point with latitude and longitude
    /// - Parameters:
    ///     - latitude: Double
    ///     - logitude: Double
    init(_ latitude: Double, _ longitude: Double) {
        super.init(latitude, longitude, "", "", false)
    }
    
    /// Initializes the track point from a map
    /// MARK: This method is not used as to assist database stroage and query
    /// the structure is changed on the cloud.
    required init?(map: Map) {
        self.up = map.JSON[ModelConstants.upKey] as? Bool ?? false
        self.down = map.JSON[ModelConstants.downKey] as? Bool ?? false
        self.left = map.JSON[ModelConstants.leftKey] as? Bool ?? false
        self.right = map.JSON[ModelConstants.rightKey] as? Bool ?? false
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        up <- map[ModelConstants.upKey]
        down <- map[ModelConstants.downKey]
        left <- map[ModelConstants.leftKey]
        right <- map[ModelConstants.rightKey]
    }
    
    /// Converts the class to an equivalent struct
    func convertToStruct() -> TrackPointStruct {
        return TrackPointStruct(latitude, longitude, up, down, left, right)
    }

}

/*
 * TrackPointStruct is used to facilitate calculations of shortest path and 
 * used as a walkaround method for comparison and hashing.
 */
struct TrackPointStruct {
    
    /// Defines the geo location of the track point
    var latitude: Double
    var longitude: Double
    
    /// Defines the reachable directions of the track point
    var up: Bool = false
    var down: Bool = false
    var left: Bool = false
    var right: Bool = false
    
    /// Initializes a track point struct
    init(_ latitude: Double, _ longitude: Double, _ up: Bool, _ down: Bool, _ left: Bool, _ right: Bool) {
        self.latitude = latitude
        self.longitude = longitude
        self.up = up
        self.down = down
        self.left = left
        self.right = right
    }
    
    /// Initializes a track point struct
    init(_ latitude: Double, _ longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension TrackPointStruct: Hashable {
    
    /// Returns the hash value of the struct.
    var hashValue: Int {
        let latInt = Int(round(self.latitude * ModelConstants.scaleFactor))
        let lonInt = Int(round(self.longitude * ModelConstants.scaleFactor))
        return "\(latInt),\(lonInt)".hashValue
    }
    
    /// Returns true if the track point structs are equal
    static func ==(lhs: TrackPointStruct, rhs: TrackPointStruct) -> Bool {
        return abs(lhs.latitude - rhs.latitude) < ModelConstants.errorThreshold && abs(lhs.longitude - rhs.longitude) < ModelConstants.errorThreshold
    }
}

extension TrackPoint: Hashable {
    
    /// Returns the hashvalue of the track point
    var hashValue: Int {
        let latInt = Int(round(self.latitude * ModelConstants.scaleFactor))
        let lonInt = Int(round(self.longitude * ModelConstants.scaleFactor))
        return "\(latInt),\(lonInt)".hashValue
    }

}

/// Returns true if thr track points are equal
func ==(lhs: TrackPoint, rhs: TrackPoint) -> Bool {
    return abs(lhs.latitude - rhs.latitude) < ModelConstants.errorThreshold && abs(lhs.longitude - rhs.longitude) < ModelConstants.errorThreshold
}
