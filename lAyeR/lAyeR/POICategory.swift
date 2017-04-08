//
//  POICategory.swift
//  lAyeR
//
//  Created by BillStark on 4/7/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

enum POICategory: String {

    case atm = "atm"
    case busStation = "bus_station"
    case cafe = "cafe"
    case gym = "gym"
    case hospital = "hospital"
    case library = "library"
    case restaurant = "restaurant"
    case store = "store"
    case university = "university"
    case other = "other"
    
    var text: String {
        switch self {
        case .atm:
            return "atm"
        case .busStation:
            return "bus station"
        case .cafe:
            return "cafe"
        case .gym:
            return "gym"
        case .hospital:
            return "hospital"
        case .library:
            return "library"
        case .restaurant:
            return "restaurant"
        case .store:
            return "store"
        case .university:
            return "university"
        case .other:
            return "other"
        }
    }
    
}
