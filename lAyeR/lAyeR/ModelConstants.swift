//
//  ModelConstants.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/15.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

class ModelConstants {

    // UserProfile
    static let defaultUserName: String = "lAyeR user"
    static let defaultUserIcon: String = "profile.png"
    static let usernameKey: String = "username"
    static let emailKey: String = "email"
    static let avatarRefKey: String = "avatarRef"
    static let designedRouteKey: String = "designedRoutes"
    
    // Parser keys
    static let resultKey: String = "result"
    static let resultsKey: String = "results"
    static let geometryKey: String = "geometry"
    static let locationKey: String = "location"
    
    // GeoPoint
    static let nameKey: String = "name"
    static let latitudeKey: String = "latitude"
    static let longitudeKey: String = "longitude"
    
    // CheckPoint
    static let descriptionKey: String = "description"
    static let isControlPointKey: String = "isControlPoint"
    
    // POI
    static let poiLatKey: String = "lat"
    static let poiLonKey: String = "lng"
    static let placeIDKey: String = "place_id"
    static let vicinityKey: String = "vicinity"
    static let typesKey: String = "types"
    static let addressKey: String = "formatted_address"
    static let contactKey: String = "international_phone_number"
    static let priceLevelKey: String = "price_level"
    static let openStatusKey: String = "opening_hours"
    static let openNowKey: String = "open_now"
    static let ratingKey: String = "rating"
    static let websiteKey: String = "website"
    
    // TrackPoint
    static let upKey: String = "up"
    static let downkey: String = "down"
    static let leftKey: String = "left"
    static let rightKey: String = "right"
    
    // Route
    static let checkPointsKey: String = "checkPoints"
    static let imagePathKey: String = "imagePath"
    
    // Geographic constants
    static let minLat: Double = -90
    static let maxLat: Double = 90
    static let minLon: Double = -180
    static let maxLon: Double = 180
    
    // Calculation
    static let errorThreshold: Double = 0.00001
    static let scaleFactor: Double = 10000
}
