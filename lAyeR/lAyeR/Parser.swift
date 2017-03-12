//
//  Parser.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/12.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import CoreLocation

class Parser {
    
    /// Parses poi search request.
    static func parsePOISearchRequest(_ radius: Double, _ type: String, _ location: CLLocation) -> String {
        let searchBase = AppConfig.mapQueryBaseURL
        let locationToken = "location=" + location.coordinate.latitude.description + "," + location.coordinate.longitude.description
        let radiusToken = "&radius=" + radius.description
        let typeToken = "&type=" + type.description
        let keyToken = "&key=" + AppConfig.apiKey
        return searchBase + locationToken + radiusToken + typeToken + keyToken
    }
    
    static func parseJSONToPOIs(_ json: NSDictionary) -> [POI] {
        guard let results = json["results"] as? [[String: Any]] else {
            return []
        }
        var pois: [POI] = []
        for result in results {
            guard let poi = parseJSONToPOI(result) else { continue }
            pois.append(poi)
        }
        return pois
    }
    
    static func parseJSONToPOI(_ jsonPOI: [String: Any]) -> POI? {
        guard let geometry = jsonPOI["geometry"] as? [String: Any],
            let location = geometry["location"] as? [String: Any],
            let latitude = location["lat"] as? Double,
            let longtitude = location["lng"] as? Double
        else { return nil }
        let poiLocation = CLLocation(latitude: latitude,
                                  longitude: longtitude)
        let poi = POI(poiLocation)
        if let name = jsonPOI["name"] as? String {
            poi.setName(name)
        }
        if let vicinity = jsonPOI["vicinity"] as? String {
            poi.setVicinity(vicinity)
        }
        if let types = jsonPOI["types"] as? [String] {
            poi.setTypes(types)
        }
        return poi
    }
    
    static func parseJSONToRoute() {
        
    }
    
    static func parseRouteToJSON() {
    
    }
}
