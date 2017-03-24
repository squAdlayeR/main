//
//  CheckPoint.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//
import Foundation
import CoreLocation
import ObjectMapper

class CheckPoint: GeoPoint {
    
    var name: String
    
    init(_ latitude: Double, _ longitude: Double,
         _ name: String) {
        self.name = name
        super.init(latitude, longitude)
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(index, forKey: "index")
        super.encode(with: aCoder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: "name") as? String else {
            return nil
        }
        self.name = name
        super.init(coder: aDecoder)
    }
    
    //required init?(map: Map) {
        //guard let name = map.JSON["name"] as? String else {
        //    return nil
        //}
        //self.name = name
       // super.init(map: map)
   // }
    
   // override func mapping(map: Map) {
        //super.mapping(map: map)
        //name <- map["name"]
    //}
    
}

extension CheckPoint: Equatable {}

func ==(lhs: CheckPoint, rhs: CheckPoint) -> Bool {
    let areEqual = lhs.name == rhs.name &&
        lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude
    
    return areEqual
}
