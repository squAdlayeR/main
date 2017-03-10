//
//  GeoPoint.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import CoreLocation

class GeoPoint {
    
    private(set) var location: CLLocation
    
    init(_ location: CLLocation) {
        self.location = location
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




