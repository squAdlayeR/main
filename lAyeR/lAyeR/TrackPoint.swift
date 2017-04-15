//
//  TrackPoint.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/9.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import ObjectMapper

class TrackPoint: CheckPoint {
    var up: Bool = false
    var down: Bool = false
    var left: Bool = false
    var right: Bool = false
    
    init(_ latitude: Double, _ longitude: Double) {
        super.init(latitude, longitude, "", "", false)
    }
    
    required init?(map: Map) {
        self.up = map.JSON[ModelConstants.upKey] as? Bool ?? false
        self.down = map.JSON[ModelConstants.downKey] as? Bool ?? false
        self.left = map.JSON[ModelConstants.leftKey] as? Bool ?? false
        self.right = map.JSON[ModelConstants.rightKey] as? Bool ?? false
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        up <- map[ModelConstants.upKey]
        down <- map[ModelConstants.downKey]
        left <- map[ModelConstants.leftKey]
        right <- map[ModelConstants.rightKey]
    }
    
    func convertToStruct() -> TrackPointStruct {
        return TrackPointStruct(latitude, longitude, up, down, left, right)
    }

}

struct TrackPointStruct {
    var latitude: Double
    var longitude: Double
    
    var up: Bool = false
    var down: Bool = false
    var left: Bool = false
    var right: Bool = false
    
    init(_ latitude: Double, _ longitude: Double, _ up: Bool, _ down: Bool, _ left: Bool, _ right: Bool) {
        self.latitude = latitude
        self.longitude = longitude
        self.up = up
        self.down = down
        self.left = left
        self.right = right
    }
    
    init(_ latitude: Double, _ longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension TrackPointStruct: Hashable {
    
    var hashValue: Int {
        let latInt = Int(round(self.latitude * 10000))
        let lonInt = Int(round(self.longitude * 10000))
        return "\(latInt),\(lonInt)".hashValue
    }
    
    static func ==(lhs: TrackPointStruct, rhs: TrackPointStruct) -> Bool {
        return abs(lhs.latitude - rhs.latitude) < 0.00001 && abs(lhs.longitude - rhs.longitude) < 0.00001
    }
}

extension TrackPoint: Hashable {

    var hashValue: Int {
        let latInt = Int(round(self.latitude * 10000))
        let lonInt = Int(round(self.longitude * 10000))
        return "\(latInt),\(lonInt)".hashValue
    }

}

func ==(lhs: TrackPoint, rhs: TrackPoint) -> Bool {
    return abs(lhs.latitude - rhs.latitude) < 0.00001 && abs(lhs.longitude - rhs.longitude) < 0.00001
}
