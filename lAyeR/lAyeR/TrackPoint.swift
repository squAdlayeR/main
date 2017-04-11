//
//  TrackPoint.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/9.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreLocation

class TrackPoint: CheckPoint {
    var up: Bool = false
    var down: Bool = false
    var left: Bool = false
    var right: Bool = false
    
    init(_ latitude: Double, _ longitude: Double) {
        super.init(latitude, longitude, "", "", false)
    }
    
    required init?(map: Map) {
        self.up = map.JSON["up"] as? Bool ?? false
        self.down = map.JSON["down"] as? Bool ?? false
        self.left = map.JSON["left"] as? Bool ?? false
        self.right = map.JSON["right"] as? Bool ?? false
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        up <- map["up"]
        down <- map["down"]
        left <- map["left"]
        right <- map["right"]
    }
    
    struct TrackPointStruct {
        var latitude: Double
        var longitude: Double
        init(_ latitude: Double, _ longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }
    
    func convertToStruct() -> TrackPointStruct {
        return TrackPointStruct(latitude, longitude)
    }

}


extension TrackPoint: Hashable {
//    override func isEqual(object: AnyObject?) -> Bool {
//        guard let obj = object as? TrackPoint else {
//            return false
//        }
//        return obj.latitude == latitude && obj.longitude == longitude
//    }
    var hashValue: Int {
        let latInt = Int(self.latitude * 1000)
        let lonInt = Int(self.longitude * 1000)
        return "\(latInt),\(lonInt)".hashValue
    }

}

func ==(lhs: TrackPoint, rhs: TrackPoint) -> Bool {
    print ("EQUATABLE")
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
