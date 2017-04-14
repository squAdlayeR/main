//
//  AppSettingsConstants.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 3/4/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

let poiCategories: [POICategory] = [.atm,
                                    .busStation,
                                    .cafe,
                                    .gym,
                                    .hospital,
                                    .library,
                                    .restaurant,
                                    .store,
                                    .university]
let categoryIndex = 0
let categoryNameIndex = 1
let categoriesReusableIdentifier = "categoryCell"
let defaultCategories: Set<String> = ["atm",
                                      "bus_station",
                                      "restaurant"]
let defaultNumberOfMarkers: Int = 10
let defaultDetectionRadius: Int = 500
