//
//  POI.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import CoreLocation

class POI {
    // to be implemented
    private(set) var name: String?
    private(set) var vicinity: String?
    private(set) var types: [String] = []
    private(set) var location: CLLocation
    
    init(_ location: CLLocation) {
        self.location = location
    }
    
    func setName(_ name: String) {
        self.name = name
    }
    
    func setVicinity(_ vicinity: String) {
        self.vicinity = vicinity
    }
    
    func setTypes(_ types: [String]) {
        self.types = types
    }
    
    /// rating, price level etc to be implemented.
}
