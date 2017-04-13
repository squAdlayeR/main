//
//  PriceLevel.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 8/4/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 An enum that is used to specify the price level returned by Google api
 */
enum PriceLevel: Int {
    
    case free = 0
    case inexpensive = 1
    case moderate = 2
    case expensive = 3
    case veryExpensive = 4
    
    /// Returns the display text of the enum
    var text: String {
        switch self {
        case .free:
            return "Free"
        case .inexpensive:
            return "Inexpensive"
        case .moderate:
            return "Moderate"
        case .expensive:
            return "Expensive"
        case .veryExpensive:
            return "Very Expensive"
        }
    }
    
}
