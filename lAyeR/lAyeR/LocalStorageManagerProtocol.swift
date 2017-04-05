//
//  LocalStorageManagerProtocol.swift
//  lAyeR
//
//  Created by luoyuyang on 29/03/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation

protocol LocalStorageManagerProtocol {
    func saveAppSettings()
    func loadAppSettings()
    
    func saveRoute(_ route: Route)
    func getRoutes(between: GeoPoint, and: GeoPoint, inRange: Double) -> [Route]
}
