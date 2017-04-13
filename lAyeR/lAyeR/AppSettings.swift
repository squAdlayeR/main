//
//  AppSettings.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 2/4/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 This is a singleton class that is used to store application settings.
 The settings currently includes:
 - max number of markers
 - the radius of detection of pois
 - the categories of pois to be displayed on the screeen
 */
class AppSettings: NSObject {

    // The instance for app settings
    private static var instance: AppSettings?
    
    // max number of markers
    private(set) var maxNumberOfMarkers: Int
    
    // radius of detection for pois
    private(set) var radiusOfDetection: Int
    
    // categories of pois for display
    private(set) var selectedPOICategrories: Set<String>
    /// The method that ensures there is only one instance for app settings
    /// - Returns: the instance for `AppSettings`
    static func getInstance() -> AppSettings {
        if instance == nil {
            self.instance = AppSettings()
            RealmLocalStorageManager.getInstance().loadAppSettings()
        }
        return instance!
    }
    
    /// Initialization
    private override init() {
        maxNumberOfMarkers = 10
        radiusOfDetection = 500
        selectedPOICategrories = ["restaurant", "atm", "bus_station"]
        super.init()
    }
    
    /// Updates the max number of markers 
    /// - Parameter newValue: the new value for the max number of markers
    func updateMaxNumberOfMarkers(with newValue: Int) {
        maxNumberOfMarkers = newValue
    }
    
    /// Updats the radius for poi detection
    /// - Parameter newValue: the new value for the radius
    func updateRadiusOfDetection(with newValue: Int) {
        radiusOfDetection = newValue
    }
    
    /// Adds prefered poi category for display
    /// - Parameter newValue: the new value to be added into the prefered poi
    ///     categories for display
    func addSelectedPOICategories(_ newValue: String) {
        selectedPOICategrories.insert(newValue)
    }
    
    /// Removes the specified prefered poi category for display
    /// - Parameter value: the value that is to be removed
    func removePOICategories(_ value: String) {
        selectedPOICategrories.remove(value)
    }
    
}
