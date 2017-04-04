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
            
            if route.checkPoints.contains(where: {GeoUtil.getCoordinateDistance($0, source) < range}) &&
                route.checkPoints.contains(where: {GeoUtil.getCoordinateDistance($0, destination) < range}) {
                returnedRoutes.append(route)
            }
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










