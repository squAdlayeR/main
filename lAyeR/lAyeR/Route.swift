//
//  Route.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import ObjectMapper
/*
 * Route represents the path formed by a series of check points with name
 * and a screenshot.
 */
class Route: Mappable {
    
    /// Defines the name of the route
    private(set) var name: String
    
    /// Defines the check points in the route
    private(set) var checkPoints: [CheckPoint] = []
    
    /// Defines the image file path of the route
    private(set) var imagePath: String = ""
    
    /// Initializes the route with name and check points
    /// - Parameters:
    ///     - name: String: name of the route
    ///     - checkPoints: [CheckPoint]: array of check points
    init(_ name: String, _ checkPoints: [CheckPoint] = []) {
        self.name = name
        self.checkPoints = checkPoints
    }
    
    /// Initializes the route from a map
    /// - Parameters:
    ///     - map: Map: the mapping of fields
    required init?(map: Map) {
        guard let name = map.JSON[ModelConstants.nameKey] as? String,
            let checkPoints = map.JSON[ModelConstants.checkPointsKey] as? [CheckPoint],
            let imagePath = map.JSON[ModelConstants.imagePathKey] as? String else {
                return nil
        }
        self.name = name
        self.checkPoints = checkPoints
        self.imagePath = imagePath
    }
    
    /// Forms the mapping of fields
    /// - Parameters:
    ///     - map: Map: the mapping of fields
    func mapping(map: Map) {
        name <- map[ModelConstants.nameKey]
        checkPoints <- map[ModelConstants.checkPointsKey]
        imagePath <- map[ModelConstants.imagePathKey]
    }
    
    /// Sets the name of the route
    /// - Parameters:
    ///     - name: String: tthe route name
    func setName(name: String) {
        self.name = name
    }
    
    /// Sets the image reference
    /// - Parameters:
    ///     - path: String: the file path
    func setImage(path: String) {
        self.imagePath = path
    }
    
    /// Returns the number of check points on the route
    var size: Int {
        return checkPoints.count
    }
    
    /// Returns the source of the route
    var source: CheckPoint? {
        return checkPoints.first
    }
    
    /// Returns the destination of the route
    var destination: CheckPoint? {
        return checkPoints.last
    }
    
    /// Appends the check point to the route
    /// - Parameter checkPoint: CheckPoint
    func append(_ checkPoint: CheckPoint) {
        checkPoints.append(checkPoint)
    }
    
    /// Inserts a check point
    /// - Parameters:
    ///     - checkPoint: CheckPoint
    ///     - index: Int: position of the check point to be placed
    func insert(_ checkPoint: CheckPoint, at index: Int) {
        checkPoints.insert(checkPoint, at: index)
    }
    
    /// Removes the check point at specifed location
    /// - Parameter index: Int: index of the check point to be removed
    func remove(at index: Int) {
        let _ = checkPoints.remove(at: index)
    }
    
    /// Route specification
    private func _checkRep() -> Bool {
        return checkPoints.count >= 2
    }
    
    /// Returns the total length of the route in meters
    var distance: Double {
        var dist: Double = 0
        if size < 1 {
            return dist
        }
        for i in 0..<size - 1 {
            dist += GeoUtil.getCoordinateDistance(checkPoints[i], checkPoints[i+1])
        }
        return dist
    }
    
    /// Returns the distance description of the route
    var distanceDescription: String {
        return "\(ModelConstants.desc)\(Int(distance))\(ModelConstants.unit)"
    }
}
