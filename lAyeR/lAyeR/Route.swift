//
//  Route.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import ObjectMapper

class Route: Mappable {
    
    /// Stores check points on the route.
    private(set) var name: String
    private(set) var checkPoints: [CheckPoint] = []
    private(set) var imagePath: String = ""
    //private(set) var distance: Double = 0
    
    init(_ name: String, _ checkPoints: [CheckPoint] = []) {
        self.name = name
        self.checkPoints = checkPoints
    }
    
    static var testRoute: Route {
        let test = Route("Test")
        test.append(CheckPoint(1,1,"1"))
        test.append(CheckPoint(1,2,"2"))
        test.append(CheckPoint(1,3,"3"))
        return test
    }
    
    required init?(map: Map) {
        guard let name = map.JSON["name"] as? String,
            let checkPoints = map.JSON["checkPoints"] as? [CheckPoint],
            let imagePath = map.JSON["imagePath"] as? String else {
                return nil
        }
        self.name = name
        self.checkPoints = checkPoints
        self.imagePath = imagePath
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        checkPoints <- map["checkPoints"]
        imagePath <- map["imagePath"]
    }
    
    func setImage(path: String) {
        self.imagePath = path
    }
    
    /// Returns the number of check points on the route.
    var size: Int {
        return checkPoints.count
    }
    
    /// Returns the source of the route.
    var source: CheckPoint? {
        return checkPoints.first
    }
    
    /// Returns the destination of the route.
    var destination: CheckPoint? {
        return checkPoints.last
    }
    
    /// Appends the check point to the route.
    func append(_ checkPoint: CheckPoint) {
        checkPoints.append(checkPoint)
    }
    
    /// Inserts a check point
    func insert(_ checkPoint: CheckPoint, at index: Int) {
        checkPoints.insert(checkPoint, at: index)
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    /// Removes the check point at specifed location.
    func remove(at index: Int) {
        let _ = checkPoints.remove(at: index)
    }
    
    /// Removes the given check point in the route.
    func remove(_ checkPoint: CheckPoint) {
        // see if really needed later.
    }
    
    /// Route specification
    private func _checkRep() -> Bool {
        return checkPoints.count >= 2
    }
    
    var distance: Double {
        var dist = 0.0
        if size < 1 { return dist }
        for i in 0..<size-1 {
            dist += GeoUtil.getCoordinateDistance(checkPoints[i], checkPoints[i+1])
        }
        return dist
    }
}
