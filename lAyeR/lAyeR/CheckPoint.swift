//
//  CheckPoint.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import ObjectMapper

/*
 * CheckPoint subclasses GeoPoint to represent a check point on a route.
 * A CheckPoint should have:
 * - name: String
 * - description: String
 * - isControlPoint: Bool, determines whether a check point is a control point
 * that should be shown in the route
 */
class CheckPoint: GeoPoint {
    
    // Represents the name, description
    private(set) var name: String = ""
    private(set) var description: String = ""
    
    // Specifies if the point is control point
    var isControlPoint = true
    
    // Initializes a check point from latitude and logitude.
    init(_ latitude: Double, _ longitude: Double,
         _ name: String, _ description: String = "",
         _ isControlPoint: Bool = true) {
        self.name = name
        self.description = description
        self.isControlPoint = isControlPoint
        super.init(latitude, longitude)
    }
    
    // Initializes a check point from a geo point.
    init(_ geoPoint: GeoPoint,
         _ name: String, _ description: String = "",
         _ isControlPoint: Bool = false) {
        self.name = name
        self.description = description
        self.isControlPoint = isControlPoint
        super.init(geoPoint.latitude, geoPoint.longitude)
    }
    
    required init?(map: Map) {
        guard let name = map.JSON[ModelConstants.nameKey] as? String else {
            return nil
        }
        self.name = name
        self.description = map.JSON[ModelConstants.descriptionKey] as? String ?? ""
        self.isControlPoint = map.JSON[ModelConstants.isControlPointKey] as? Bool ?? false
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        name <- map[ModelConstants.nameKey]
        description <- map[ModelConstants.descriptionKey]
        isControlPoint <- map[ModelConstants.isControlPointKey]
    }
    
}


func ==(lhs: CheckPoint, rhs: CheckPoint) -> Bool {
    let areEqual = lhs.name == rhs.name &&
        lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude
    
    return areEqual
}
