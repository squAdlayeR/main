//
//  RealmCheckPoint.swift
//  lAyeR
//
//  Created by luoyuyang on 15/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import RealmSwift

/**
 This is the class represents the CheckPoint class in the runtime
 It is used by Realm for local storage
 */
class RealmCheckPoint: RealmGeoPoint {
    dynamic private var name: String = ""
    dynamic private var desc: String = ""
    dynamic private var isControlPoint: Bool = true
    
    convenience init(_ checkpoint: CheckPoint) {
        self.init()
        name = checkpoint.name
        desc = checkpoint.description
        latitude = checkpoint.latitude
        longitude = checkpoint.longitude
        isControlPoint = checkpoint.isControlPoint
    }
    
    override func get() -> CheckPoint {
        return CheckPoint(latitude, longitude, name, description, isControlPoint)
    }
}
