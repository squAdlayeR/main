//
//  AppSettingsConstants.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 3/4/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

struct AppSettingsConstants {

    static let poiCategories: [POICategory] = [.atm,
                                    .busStation,
                                    .cafe,
                                    .gym,
                                    .hospital,
                                    .library,
                                    .restaurant,
                                    .store,
                                    .university]
    static let categoryIndex = 0
    static let categoryNameIndex = 1
    static let categoriesReusableIdentifier = "categoryCell"
    static let defaultCategories: Set<String> = ["atm",
                                      "bus_station",
                                      "restaurant"]
    static let defaultNumberOfMarkers: Int = 10
    static let defaultDetectionRadius: Int = 500
}
