//
//  RealmLocalStorageManager.swift
//  lAyeR
//
//  Created by luoyuyang on 29/03/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import RealmSwift


/**
 For each app model to be stored using Realm, we create a corresponding Realm class,
 which is of the similar purpose as defining the correponding database table.
 The following classes is a duplicate of the app model for Realm to store
 1. Model need to be a class, that is, structs can not be stored
 2. Model need to inherit from Object (Realm Object, not Swift Object)
 3. The properties of Model need to be dynamic
 4. The properties of Model must provide default value
 5. Realm does not support Array, Set and so on.
 Thus need to use Realm List instead, which the generic type of List must be subclasses of Object
 The primitive types such as String and Integer cannot be the content of the List
 This restrictions, although will not cause much influence, and reasonable as well.
 it might reduce the flexibility when we design our app model, which should not be dependent on the storage implementation.
 Therefore, to reduce the coupling and dependency, also considering the possibility to change the storage implementation
 We define the following "duplicate" model, only for Realm storage purpose
 */

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
    
    public func getRoutes(between source: GeoPoint, and destination: GeoPoint, inRange range: Double) -> [Route] {
        var returnedRoutes: [Route] = []
        let realmRoutes = realm.objects(RealmRoute.self)
        for realmRoute in realmRoutes {
            let route = realmRoute.get()
            var sourceIndex = -1
            var destIndex = -1
            var sourceDist = range
            var destDist = range
            for i in 0 ..< route.size {
                let newSourceDist = GeoUtil.getCoordinateDistance(route.checkPoints[i], source)
                if newSourceDist < sourceDist {
                    sourceIndex = i
                    sourceDist = newSourceDist
                }
                let newDestDist = GeoUtil.getCoordinateDistance(route.checkPoints[i], destination)
                if  newDestDist < destDist {
                    destIndex = i
                    destDist = newDestDist
                }
            }
            if sourceIndex == destIndex {
                continue
            }
            if sourceIndex >= 0 && destIndex >= 0 {
                let section = destIndex > sourceIndex ? route.checkPoints[sourceIndex ... destIndex] : route.checkPoints[destIndex ... sourceIndex]
                let returnRoute = Route(route.name)
                for checkpoint in section {
                    if destIndex > sourceIndex {
                        returnRoute.append(checkpoint)
                    } else {
                        returnRoute.insert(checkpoint, at: 0)
                    }
                }
                returnedRoutes.append(returnRoute)
            }
        }
        return returnedRoutes
    }
    
    public func getLocalRoutes() -> [Route] {
        var returnedRoutes: [Route] = []
        let realmRoutes = realm.objects(RealmRoute.self)
        for realmRoute in realmRoutes {
            returnedRoutes.append(realmRoute.get())
        }
        return returnedRoutes
    }
    
    public func saveAppSettings() {
        // currently, only allow one user setting per device
        for setting in realm.objects(RealmAppSettings.self) {
            realmDelete(setting)
        }
        realmAdd(RealmAppSettings(AppSettings.getInstance()))
    }
    
    /// Load setting stored in the device
    public func loadAppSettings() {
        guard let setting = realm.objects(RealmAppSettings.self).first else {
            return
        }
        setting.applyToAppSettings()
    }
}










