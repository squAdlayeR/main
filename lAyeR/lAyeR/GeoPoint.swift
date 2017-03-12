//
//  GeoPoint.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import CoreLocation

class GeoPoint: NSCoding {
    
    private(set) var location: CLLocation
    
    init(_ location: CLLocation) {
        self.location = location
    }
    
    required init?(coder aDecoder: NSCoder) {
        let latitude = aDecoder.decodeDouble(forKey: "lat")
        let longtitude = aDecoder.decodeDouble(forKey: "lng")
        self.location = CLLocation(latitude: latitude,
                                   longitude: longtitude)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.location.coordinate.latitude, forKey: "lat")
        aCoder.encode(self.location.coordinate.longitude, forKey: "lng")
        aCoder.encode(self.location.altitude, forKey: "alt")
        aCoder.encode(self.location.timestamp, forKey: "timeStamp")
    }
    
    /// east is positive, west is negative
    func getLongtitudeInRadian() -> Double {
        return location.coordinate.longitude * (M_PI/180)
    }
    
    /// north is positive, south is negative
    func getLatitudeInRadian() -> Double {
        return location.coordinate.latitude * (M_PI/180)
    }

}




