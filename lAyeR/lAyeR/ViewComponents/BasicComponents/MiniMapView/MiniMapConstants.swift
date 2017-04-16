//
//  MiniMapConstants.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 13/4/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

struct MiniMapConstants {

    /// Strings
    static let initialRouteName: String = "route to be shown in minimap"
    static let kMapStyleNight: String = "[" +
        "{" +
        "\"elementType\": \"geometry\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#242f3e\"" +
        "}" +
        "]" +
        "}," +
        "{" +
        "\"elementType\": \"labels.text.fill\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#746855\"" +
        "}" +
        "]" +
        "}," +
        "{" +
        "\"elementType\": \"labels.text.stroke\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#242f3e\"" +
        "}" +
        "]" +
        "}," +
        "{" +
        "\"featureType\": \"administrative.locality\"," +
        "\"elementType\": \"labels.text.fill\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#d59563\"" +
        "}" +
        "]" +
        "}," +
        "{" +
        "\"featureType\": \"poi\"," +
        "\"elementType\": \"labels.text.fill\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#d59563\"" +
        "}" +
        "]" +
        "}," +
        "{" +
        "\"featureType\": \"poi.park\"," +
        "\"elementType\": \"geometry\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#263c3f\"" +
        "}" +
        "]" +
        "}," +
        "{" +
        "\"featureType\": \"poi.park\"," +
        "\"elementType\": \"labels.text.fill\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#6b9a76\"" +
        "}" +
        "]" +
        "}," +
        "{" +
        "\"featureType\": \"road\"," +
        "\"elementType\": \"geometry\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#38414e\"" +
        "}" +
        "]" +
        "}," +
        "{" +
        "\"featureType\": \"road\"," +
        "\"elementType\": \"geometry.stroke\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#212a37\"" +
        "}" +
        "]" +
        "}," +
        "{" +
        "\"featureType\": \"road\"," +
        "\"elementType\": \"labels.text.fill\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#9ca5b3\"" +
        "}" +
        "]" +
        "}," +
        "{" +
        "\"featureType\": \"road.highway\"," +
        "\"elementType\": \"geometry\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#746855\"" +
        "}" +
        "]" +
        "}," +
        "{" +
        "\"featureType\": \"road.highway\"," +
        "\"elementType\": \"geometry.stroke\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#1f2835\"" +
        "}" +
        "]" +
        "}," +
        "{" +
        "\"featureType\": \"road.highway\"," +
        "\"elementType\": \"labels.text.fill\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#f3d19c\"" +
        "}" +
        "]" +
        "}," +
        "{" +
        "\"featureType\": \"transit\"," +
        "\"elementType\": \"geometry\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#2f3948\"" +
        "}" +
        "]" +
        "}," +
        "{" +
        "\"featureType\": \"transit.station\"," +
        "\"elementType\": \"labels.text.fill\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#d59563\"" +
        "}" +
        "]" +
        "}," +
        "{" +
        "\"featureType\": \"water\"," +
        "\"elementType\": \"geometry\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#17263c\"" +
        "}" +
        "]" +
        "}," +
        "{" +
        "\"featureType\": \"water\"," +
        "\"elementType\": \"labels.text.fill\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#515c6d\"" +
        "}" +
        "]" +
        "}," +
        "{" +
        "\"featureType\": \"water\"," +
        "\"elementType\": \"labels.text.stroke\"," +
        "\"stylers\": [" +
        "{" +
        "\"color\": \"#17263c\"" +
        "}" +
        "]" +
        "}" +
    "]"
    
    /// View constants
    static let alpha: CGFloat = 0.8
    static let sizePercentage: CGFloat = 0.35
    static let paddingRight: CGFloat = 20
    static let paddingTop: CGFloat = 30
    static let borderRadius: CGFloat = 15
    static let strokeWidth: CGFloat = 3.0
    static let strokeColor: UIColor = UIColor(red: 0.1294, green: 0.7373, blue: 0.7882, alpha: 1)

    /// zPosition
    static let zPozition: CGFloat = 10000
    
    /// Animations
    static let delay: TimeInterval = 0
    static let openCloseTime: TimeInterval = 0.3
    
    /// others
    static let zoomLevel: Float = 15.5
    
}
