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

/**
 The following classes is a duplicate of the app model for Realm to store
 Realm can directly work with normal model, however, there are some restrictions:
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

class RealmAppSettings: Object {
    dynamic private var maxNumberOfMarkers: Int = 0
    dynamic private var radiusOfDetection: Int = 0
    private var selectedPOICategrories: List<RealmString> = List<RealmString>()
    
    convenience init(_ settings: AppSettings) {
        self.init()
        maxNumberOfMarkers = settings.maxNumberOfMarkers
        radiusOfDetection = settings.radiusOfDetection

        for category in settings.selectedPOICategrories {
            selectedPOICategrories.append(RealmString(category))
        }
    }
    
    func applyToAppSettings() {
        let settings = AppSettings.getInstance()
        settings.updateMaxNumberOfMarkers(with: maxNumberOfMarkers)
        settings.updateRadiusOfDetection(with: radiusOfDetection)
        
        // remove all categories in the current setting
        for category in settings.selectedPOICategrories {
            settings.removePOICategories(category)
        }
        
        // add all the new categories to the setting
        for newCategory in selectedPOICategrories {
            settings.addSelectedPOICategories(newCategory.get())
        }
    }
}

/**
 RealmString is the wrapper class of Swift String class
 This is becuase Realm List can only contains the subclasses of Object
 */
class RealmString: Object {
    dynamic var content: String = ""
    convenience init(_ input: String) {
        self.init()
        content = input
    }
    func get() -> String {
        return content
    }
}






















