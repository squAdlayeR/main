//
//  Parser.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/12.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import CoreLocation
import ObjectMapper

class Parser {
    
    static let instance = Parser()
    
    /// Parses poi search request.
    static func parsePOISearchRequest(_ radius: Int, _ type: String, _ location: GeoPoint) -> String {
        let searchBase = AppConfig.mapQueryBaseURL
        let locationToken = "location=\(location.latitude),\(location.longitude)"
        let radiusToken = "&radius=\(radius)"
        let typeToken = "&type=\(type)"
        let keyToken = "&key=\(AppConfig.apiKey)"
        return searchBase + locationToken + radiusToken + typeToken + keyToken
    }
    
    static func parsePOIDetailSearchRequest(_ placeID: String) -> String {
        let searchbase = AppConfig.poiQueryBaseURL
        let placeToken = "placeid=\(placeID)"
        let keyToken = "&key=\(AppConfig.apiKey)"
        return searchbase + placeToken + keyToken
    }
    
    static func parseJSONToPOIs(_ json: [String: Any]) -> [POI] {
        guard let results = json["results"] as? [[String: Any]] else {
            return []
        }
        var pois: [POI] = []
        for result in results {
            guard let poi = parseJSONToPOI(result) else {
                continue
            }
            pois.append(poi)
        }
        return pois
    }
    
    static func parseJSONToPOI(_ jsonPOI: [String: Any]) -> POI? {
        guard let geometry = jsonPOI["geometry"] as? [String: Any], let location = geometry["location"] as? [String: Any], let latitude = location["lat"] as? Double, let longitude = location["lng"] as? Double else {
            return nil
        }
        let poi = POI(latitude, longitude)
        if let placeID = jsonPOI["place_id"] as? String {
            poi.setPlaceID(placeID)
        }
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
    
    static func parseDetailedPOI(_ json: [String: Any]) -> POI? {
        guard let jsonPOI = json["result"] as? [String: Any] else {
            return nil
        }
        guard let poi = parseJSONToPOI(jsonPOI) else {
            return nil
        }
        if let address = jsonPOI["formatted_address"] as? String {
            poi.setVicinity(address)
        }
        if let priceLevel = jsonPOI["price"] as? Double {
            poi.setPriceLevel(priceLevel)
        }
        if let openHours = jsonPOI["opening_hours"] as? [String: Any], let openNow = openHours["open_now"] as? Bool {
            poi.setOpenNow(openNow)
        }
        if let rating = jsonPOI["rating"] as? Double {
            poi.setRating(rating)
        }
        if let website = jsonPOI["website"] as? String {
            poi.setWebsite(website)
        }
        if let contact = jsonPOI["international_phone_number"] as? String {
            poi.setContact(contact)
        }
        return poi
    }
    
    static func parseJSONToRoutes(_ jsonRoutes: [String: Any]) -> [Route] {
        guard let results = jsonRoutes["routes"] as? [[String: Any]] else {
            return []
        }
        var routes: [Route] = []
        for result in results {
            guard let route = parseJSONToRoute(result) else { continue }
            routes.append(route)
        }
        return routes
    }
    
    static func parseJSONToRoute(_ jsonRoute: [String: Any]) -> Route? {
        guard let name = jsonRoute["name"] as? String,
            let checkPoints = jsonRoute["checkPoints"] as? [[String: Any]] else {
                return nil
        }
        let route = Route(name)
        for point in checkPoints {
            guard let checkPoint = parseJSONToCheckPoint(point) else { continue
            }
            route.append(checkPoint)
        }
        return route
    }
    
    static func parseRoute(_ value: Any?) -> Route? {
        guard let jsonRoute = value as? [String: Any], let points = jsonRoute["checkPoints"] as? [[String: Any]], let name = jsonRoute["name"] as? String, let checkPoints = points.map ({ CheckPoint(JSON: $0) }) as? [CheckPoint], let image = jsonRoute["imagePath"] as? String else {
            return nil
        }
        let route = Route(name, checkPoints)
        route.setImage(path: image)
        return route
    }
    
    
    
    static func parseJSONToCheckPoint(_ jsonCheckPoint: [String: Any]) -> CheckPoint? {
        guard let name = jsonCheckPoint["name"] as? String,
            let lat = jsonCheckPoint["latitude"] as? Double,
            let lng = jsonCheckPoint["longitude"] as? Double,
            let description = jsonCheckPoint["description"] as? String,
            let isControlPoint = jsonCheckPoint["isControlPoint"] as? Bool else {
               return nil
            
        }
        return CheckPoint(lat, lng, name, description, isControlPoint)
    }
}
