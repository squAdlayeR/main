//
//  LocalStorageManagerProtocol.swift
//  lAyeR
//
//  Created by luoyuyang on 29/03/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation

protocol LocalStorageManagerProtocol {
    /// overwrite the current app setting into the local storage
    /// any existing app setting will be removed from the local storage
    /// before the new one is stored
    func saveAppSettings()
    
    /// set the app setting to the one that is stored in the local storage
    /// if there is no app setting stored locally, nothing will happen
    func loadAppSettings()
    
    /// save the input route into the local storage
    func saveRoute(_ route: Route)
    
    
    func getRoutes(between: GeoPoint, and: GeoPoint, inRange: Double) -> [Route]
    
    /// get all the routes currently stored in the local storage
    func getLocalRoutes() -> [Route]
}
