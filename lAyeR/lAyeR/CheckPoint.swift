//
//  CheckPoint.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import CoreLocation

class CheckPoint: GeoPoint {
    
    private(set) var poi: POI?
    private(set) var name: String
    
    init(_ location: CLLocation, _ name: String) {
        self.name = name
        super.init(location)
    }
    
    
    func setPOIInformation(_ poi: POI) {
        self.poi = poi
    }
}
