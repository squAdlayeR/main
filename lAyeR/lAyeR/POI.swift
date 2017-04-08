//
//  POI.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import CoreLocation
import ObjectMapper

class POI: GeoPoint {
    // to be implemented
    private(set) var placeID: String?
    private(set) var name: String?
    private(set) var vicinity: String?
    private(set) var openNow: Bool?
    private(set) var priceLevel: Double?
    private(set) var rating: Double?
    private(set) var contact: String?
    private(set) var website: String?
    private(set) var types: [String] = []
    
    override init(_ latitude: Double, _ longitude: Double) {
        super.init(latitude, longitude)
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    func setPlaceID(_ placeID: String) {
        self.placeID = placeID
    }
    
    func setName(_ name: String) {
        self.name = name
    }
    
    func setTypes(_ types: [String]) {
        self.types = types
    }
    
    func setVicinity(_ vicinity: String) {
        self.vicinity = vicinity
    }
    
    func setRating(_ rating: Double) {
        self.rating = rating
    }
    
    func setPriceLevel(_ priceLevel: Double) {
        self.priceLevel = priceLevel
    }
    
    func setContact(_ contact: String) {
        self.contact = contact
    }
    
    func setOpenNow(_ openNow: Bool) {
        self.openNow = openNow
    }
    
    func setWebsite(_ website: String) {
        self.website = website
    }
}
