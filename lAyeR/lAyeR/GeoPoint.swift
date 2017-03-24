//
//  GeoPoint.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import ObjectMapper

class GeoPoint: Mappable {
    
    private(set) var latitude: Double
    private(set) var longitude: Double
    
    init(_ latitude: Double, _ longitude: Double) {
        self.latitude = GeoUtil.isValidLatitude(latitude) ? latitude : 0
        self.longitude = GeoUtil.isValidLongitude(longitude) ? longitude : 0
    }
    
    //required init?(coder aDecoder: NSCoder) {
    //  self.latitude = aDecoder.decodeDouble(forKey: "latitude")
    //self.longitude = aDecoder.decodeDouble(forKey: "longitude")
    //}
    
    //func encode(with aCoder: NSCoder) {
    // aCoder.encode(self.latitude, forKey: "latitude")
    // aCoder.encode(self.longitude, forKey: "longitude")
    //}
    
    required init?(map: Map) {
        guard let latitude = map.JSON["latitude"] as? Double,
            let longitude = map.JSON["longitude"] as? Double else {
                return nil
        }
        self.latitude = GeoUtil.isValidLatitude(latitude) ? latitude : 0
        self.longitude = GeoUtil.isValidLongitude(longitude) ? longitude : 0
    }
    
    func mapping(map: Map) {
        latitude <- map["latitude"]
        longitude <- map["longitude"]
    }
    
}

extension GeoPoint: Equatable {
    static func==(lhs: GeoPoint, rhs: GeoPoint) -> Bool {
        return lhs.latitude == rhs.latitude
            && lhs.longitude == rhs.longitude
    }
}

