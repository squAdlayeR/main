//
//  GeoPoint.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import CoreLocation
import ObjectMapper

class GeoPoint: NSCoding, Mappable {
    
    private(set) var latitude: Double
    private(set) var longitude: Double
    
    init(_ latitude: Double, _ longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.latitude = aDecoder.decodeDouble(forKey: "latitude")
        self.longitude = aDecoder.decodeDouble(forKey: "longitude")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.latitude, forKey: "latitude")
        aCoder.encode(self.longitude, forKey: "longitude")
    }
    
    required init?(map: Map) {
        guard let latitude = map.JSON["latitude"] as? Double,
            let longitude = map.JSON["longitude"] as? Double else {
                return nil
        }
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func mapping(map: Map) {
        latitude <- map["latitude"]
        longitude <- map["longitude"]
    }
    
    /// east is positive, west is negative
    func getLongtitudeInRadian() -> Double {
        return longitude * (M_PI/180)
    }
    
    /// north is positive, south is negative
    func getLatitudeInRadian() -> Double {
        return latitude * (M_PI/180)
    }

}




