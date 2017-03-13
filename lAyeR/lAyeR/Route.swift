//
//  Route.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import ObjectMapper

class Route: NSCoding, Mappable {
    
    /// Stores check points on the route.
    private(set) var name: String
    private var checkPoints: [CheckPoint] = []
    
    init(_ name: String) {
        self.name = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: "routeName") as? String, let checkPoints = aDecoder.decodeObject(forKey: "checkPoints") as? [CheckPoint] else {
            return nil
        }
        self.name = name
        self.checkPoints = checkPoints
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "routeName")
        aCoder.encode(checkPoints, forKey: "checkPoints")
    }
    
    required init?(map: Map) {
        guard let name = map.JSON["name"] as? String,
            let checkPoints = map.JSON["checkPoints"] as? [CheckPoint] else {
                return nil
        }
        self.name = name
        self.checkPoints = checkPoints
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        checkPoints <- map["checkPoints"]
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
    
    /// Removes the check point at specifed location.
    func remove(at index: Int) {
        let _ = checkPoints.remove(at: index)
    }
    
    /// Removes the given check point in the route.
    func remove(_ checkPoint: CheckPoint) {
        // see if really needed later.
    }

}
