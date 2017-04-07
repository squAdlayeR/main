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
            if sourceIndex >= 0 && destIndex >= 0 {
                let section = destIndex >= sourceIndex ? route.checkPoints[sourceIndex ... destIndex] : route.checkPoints[destIndex ... sourceIndex]
                let returnRoute = Route(route.name)
                for checkpoint in section {
                    returnRoute.append(checkpoint)
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
    
    // currently, only allow one user setting per device
    public func saveAppSettings() {
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










