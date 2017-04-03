//
//  AppSettings.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 2/4/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

class AppSettings: NSObject {

    private static var instance: AppSettings?
    private(set) var maxNumberOfMarkers: Int
    private(set) var radiusOfDetection: Int
    private(set) var selectedPOICategrories: Set<String>
    
    static func getInstance() -> AppSettings {
        if instance == nil {
            self.instance = AppSettings()
        }
        return instance!
    }
    
    private override init() {
        maxNumberOfMarkers = 10
        radiusOfDetection = 500
        selectedPOICategrories = []
        super.init()
    }
    
    func updateMaxNumberOfMarkers(with newValue: Int) {
        maxNumberOfMarkers = newValue
    }
    
    func updateRadiusOfDetection(with newValue: Int) {
        radiusOfDetection = newValue
    }
    
    func addSelectedPOICategories(_ newValue: String) {
        selectedPOICategrories.insert(newValue)
    }
    
    func removePOICtegories(_ value: String) {
        selectedPOICategrories.remove(value)
    }
    
}
