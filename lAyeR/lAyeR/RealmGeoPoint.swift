//
//  RealmGeoPoint.swift
//  lAyeR
//
//  Created by luoyuyang on 15/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import RealmSwift

/**
 This is the class represents the GeoPoint class in the runtime
 It is used by Realm for local storage
 */

class RealmGeoPoint: Object {
    dynamic var latitude: Double = 0
    dynamic var longitude: Double = 0
    
    convenience init(_ geoPoint: GeoPoint) {
        self.init()
        latitude = geoPoint.latitude
        longitude = geoPoint.longitude
    }
    
    func get() -> GeoPoint {
        return GeoPoint(latitude, longitude)
    }
}
