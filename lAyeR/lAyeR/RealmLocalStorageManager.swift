//
//  RealmLocalStorageManager.swift
//  lAyeR
//
//  Created by luoyuyang on 29/03/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import RealmSwift

class RealmLocalStorageManager: LocalStorageManagerProtocol {
    static private var instance: LocalStorageManagerProtocol!
    private var realm: Realm = try! Realm()
    
    static public func getInstance() -> LocalStorageManagerProtocol {
        if (instance == nil) {
            instance = RealmLocalStorageManager()
        }
        return instance!
    }
    
    private func realmAdd(_ object: Object) {
        try! realm.write {
            realm.add(object)
        }
    }
    
    private func realmDelete(_ object: Object) {
        try! realm.write {
            realm.delete(object)
        }
    }
    
    public func saveRoute(_ route: Route) {
        realmAdd(RealmRoute(route))
    }
    
    public func removeRoute(_ route: Route) {
        realmDelete(RealmRoute(route))
    }
    
    public func getRouteByName(_ name: String) -> Route? {
        return realm.objects(RealmRoute.self).filter("name == \(name)").first?.get()
    }

}

/**
 The following classes is a duplicate of the app model for Realm to store
 Realm can directly work with normal model, however, there are some restrictions:
    1. Model need to be a class, that is, structs can not be stored
    2. Model need to inherit from Object (Realm Object, not Swift Object)
    3. The properties of Model need to be dynamic
    4. The properties of Model must provide default value
 This restrictions, although will not cause much influence, and reasonable as well.
 it might reduce the flexibility when we design our app model, which should not be dependent on the storage implementation.
 Therefore, to reduce the coupling and dependency, also considering the possibility to change the storage implementation
 We define the following "duplicate" model, only for Realm storage purpose
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

class RealmRoute: Object {
    dynamic private var name: String = ""
    dynamic private var checkPoints: [RealmCheckPoint] = []

    convenience init(_ route: Route) {
        self.init()
        name = route.name
        checkPoints = route.checkPoints.map { return RealmCheckPoint($0) }
    }
    
    func get() -> Route {
        let returnRoute = Route.init(name)
        for point in checkPoints {
            returnRoute.append(point.get())
        }
        return returnRoute
    }
}

class RealmCheckPoint: RealmGeoPoint {
    dynamic private var name: String = ""
    dynamic private var desc: String = ""
    
    convenience init(_ checkpoint: CheckPoint) {
        self.init()
        name = checkpoint.name
        desc = checkpoint.description
        latitude = checkpoint.latitude
        longitude = checkpoint.longitude
    }
    
    override func get() -> CheckPoint {
        return CheckPoint(latitude, longitude, name, description)
    }
}














