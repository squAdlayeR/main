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
    
    private(set) var name: String
    private(set) var index: Int
    
    init(_ latitude: Double, _ longitude: Double,
         _ name: String, _ index: Int) {
        self.name = name
        self.index = index
        super.init(latitude, longitude)
    }

    override func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(index, forKey: "index")
        super.encode(with: aCoder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: "name") as? String,
            let index = aDecoder.decodeObject(forKey: "index") as? Int else {
            return nil
        }
        self.name = name
        self.index = index
        super.init(coder: aDecoder)
    }
    
    required init?(map: Map) {
        guard let name = map.JSON["name"] as? String,
            let index = map.JSON["index"] as? Int else {
                return nil
        }
        self.name = name
        self.index = index
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        name <- map["name"]
        index <- map["index"]
    }

}
