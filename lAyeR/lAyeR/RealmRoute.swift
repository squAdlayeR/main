//
//  RealmRute.swift
//  lAyeR
//
//  Created by luoyuyang on 15/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import RealmSwift

/**
 This is the class represents the Route class in the runtime
 It is used by Realm for local storage
 */

class RealmRoute: Object {
    dynamic private var name: String = ""
    private var checkPoints: List<RealmCheckPoint> = List<RealmCheckPoint>()
    
    convenience init(_ route: Route) {
        self.init()
        name = route.name
        
        let realmCheckPoints = route.checkPoints.map { return RealmCheckPoint($0) }
        checkPoints.removeAll()
        for realmCheckPoint in realmCheckPoints {
            checkPoints.append(realmCheckPoint)
        }
    }
    
    func get() -> Route {
        let returnRoute = Route.init(name)
        for point in checkPoints {
            returnRoute.append(point.get())
        }
        return returnRoute
    }
}
