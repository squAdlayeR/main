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
    
    private(set) var name: String
    
    init(_ location: CLLocation, _ name: String) {
        self.name = name
        super.init(location)
    }

    override func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        super.encode(with: aCoder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        super.init(coder: aDecoder)
    }

}
