//
//  CheckPoint.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import ObjectMapper

class CheckPoint: GeoPoint {
    
    private(set) var name: String = ""
    private(set) var description: String = ""
    var isControlPoint = true
    
    init(_ latitude: Double, _ longitude: Double,
         _ name: String, _ description: String = "",
         _ isControlPoint: Bool = true) {
        self.name = name
        self.description = description
        self.isControlPoint = isControlPoint
        super.init(latitude, longitude)
    }
    
   // override func encode(with aCoder: NSCoder) {
     //   aCoder.encode(name, forKey: "name")
      //  aCoder.encode(index, forKey: "index")
      //  super.encode(with: aCoder)
   // }
    
   // required init?(coder aDecoder: NSCoder) {
      //  guard let name = aDecoder.decodeObject(forKey: "name") as? String else {
      //      return nil
      //  }
      //  self.name = name
      //  super.init(coder: aDecoder)
   // }
    
    required init?(map: Map) {
        guard let name = map.JSON["name"] as? String else {
            return nil
        }
        self.name = name
        self.description = map.JSON["description"] as? String ?? ""
        self.isControlPoint = map.JSON["isControlPoint"] as? Bool ?? false
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        name <- map["name"]
        description <- map["description"]
        isControlPoint <- map["isControlPoint"]
    }
    
}


func ==(lhs: CheckPoint, rhs: CheckPoint) -> Bool {
    let areEqual = lhs.name == rhs.name &&
        lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude
    
    return areEqual
}
