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
    
    var color: UIColor {
        switch self {
        case .atm:
            return UIColor(red: 0.4549, green: 0.6588, blue: 0.3686, alpha: 1)
        case .busStation:
            return UIColor(red: 0.9765, green: 0.6392, blue: 0.2353, alpha: 1)
        case .cafe:
            return UIColor(red: 0.9686, green: 0.9686, blue: 0.9686, alpha: 1)
        case .gym:
            return UIColor(red: 0.3922, green: 0.3922, blue: 0.4235, alpha: 1)
        case .hospital:
            return UIColor(red: 0.8627, green: 0.3294, blue: 0.2667, alpha: 1)
        case .library:
            return UIColor(red: 0.6275, green: 0.3451, blue: 0.2275, alpha: 1)
        case .restaurant:
            return UIColor(red: 0.4510, green: 0.5137, blue: 0.5020, alpha: 1)
        case .store:
            return UIColor(red: 0.9098, green: 0.7176, blue: 0.6000, alpha: 1)
        case .university:
            return UIColor(red: 0.1529, green: 0.1529, blue: 0.1529, alpha: 1)
        case .other:
            return UIColor.cyan
        }
    }
    
}
