//
//  POI.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import ObjectMapper
/*
 * POI represents the point of interest on a map.
 * It must contain geo location information:
 * - latitude: Double
 * - longitude: Double
 * It can contain various fields:
 * - placeID: String?: used by Google Places API to query for detailed information
 * - name: String?: name of the location
 * - vicinity: String?: a brief description of address
 * - openNow: Bool?: current open status 
 * - priceLevel: Double?: price level of the place
 * - rating: Double?: rating of the place
 * - contact: String?: contact number of the place
 * - website: String?: website of the place
 * - types: [String]: type information of the place
 */
class POI: GeoPoint {
    
    /// Defines the attributes of a POI
    private(set) var placeID: String?
    private(set) var name: String?
    private(set) var vicinity: String?
    private(set) var openNow: Bool?
    private(set) var priceLevel: Double?
    private(set) var rating: Double?
    private(set) var contact: String?
    private(set) var website: String?
    private(set) var types: [String] = []
    
    /// Initializes POI from latitude and longitude
    /// - Parameters:
    ///     - latitude: Double: latitude of the point in degrees
    ///     - longitude: Double: longitude of the point in degrees
    override init(_ latitude: Double, _ longitude: Double) {
        super.init(latitude, longitude)
    }
    
    /// MARK: This method is not implemented because google places response structure
    /// is different from POI strcture and POI will not be used for query and storage
    required init?(map: Map) {
        super.init(map: map)
    }
    
    /// Sets the place id of the place
    /// Parameter placeID: String: place id of the place
    func setPlaceID(_ placeID: String) {
        self.placeID = placeID
    }
    
    /// Sets the name of the place
    /// Parameter placeID: String: name of the place
    func setName(_ name: String) {
        self.name = name
    }
    
    /// Sets the types of the place
    /// Parameter types: [String]: types of the place
    func setTypes(_ types: [String]) {
        self.types = types
    }
    
    /// Sets the vicinity of the place
    /// Parameter vicinity: String: vicinity of the place
    func setVicinity(_ vicinity: String) {
        self.vicinity = vicinity
    }
    
    /// Sets the rating of the place
    /// Parameter rating: Double: rating of the place
    func setRating(_ rating: Double) {
        self.rating = rating
    }
    
    /// Sets the price level of the place
    /// Parameter priceLevel: Double: price level of the place
    func setPriceLevel(_ priceLevel: Double) {
        self.priceLevel = priceLevel
    }
    
    /// Sets the contact of the place
    /// Parameter contact: String: contact of the place
    func setContact(_ contact: String) {
        self.contact = contact
    }
    
    /// Sets the open now status of the place
    /// Parameter openNow: Bool: open status of the place
    func setOpenNow(_ openNow: Bool) {
        self.openNow = openNow
    }
    
    /// Sets the website of the place
    /// Parameter website: String: website of the place
    func setWebsite(_ website: String) {
        self.website = website
    }
}
