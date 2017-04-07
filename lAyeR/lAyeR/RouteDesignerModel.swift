//
//  RouteDesignerModel.swift
//  lAyeR
//
//  Created by Patrick Cho on 4/7/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces

class RouteDesignerModel {

    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    func getDirections(origin: String!, destination: String!, waypoints: Array<String>?, at markersIdx: Int, completion: @escaping (_ result: Bool, _ path: GMSPath?)->()) {
        
        if let originLocation = origin {
            if let destinationLocation = destination {
                var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&mode=walking"
                if let routeWaypoints = waypoints {
                    directionsURLString += "&waypoints=optimize:true"
                    
                    for waypoint in routeWaypoints {
                        directionsURLString += "|" + waypoint
                    }
                }
                directionsURLString = directionsURLString.addingPercentEscapes(using: String.Encoding.utf8)!
                let directionsURL = NSURL(string: directionsURLString)
                DispatchQueue.main.async( execute: { () -> Void in
                    let directionsData = NSData(contentsOf: directionsURL! as URL)
                    if directionsData == nil {
                        completion(false, nil)
                        return
                    }
                    do{
                        let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                        
                        let status = dictionary["status"] as! String
                        
                        if status == "OK" {
                            
                            let selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                            let overviewPolyline = selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                            
                            let route = overviewPolyline["points"] as! String
                            let path: GMSPath = GMSPath(fromEncodedPath: route)!
                            
                            completion(true, path)
                        }
                        else {
                            completion(false, nil)
                        }
                    }
                    catch {
                        completion(false, nil)
                    }
                })
            }
            else {
                completion(false, nil)
            }
        }
        else {
            completion(false, nil)
        }
    }
    
    func saveToLocal(route: Route) {
        RealmLocalStorageManager.getInstance().saveRoute(route)
    }
    
    func saveToDB(route: Route) {
        DataServiceManager.instance.addRouteToDatabase(route: route)
    }
    
    func getLayerRoutes(source: GeoPoint, dest: GeoPoint) -> [Route] {
        return RealmLocalStorageManager.getInstance().getRoutes(between: source, and: dest, inRange: UserConfig.queryRadius)
    }
}
