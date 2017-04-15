//
//  RealmAppSetting.swift
//  lAyeR
//
//  Created by luoyuyang on 15/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import RealmSwift

/**
 This is the class represents the AppSettings class in the runtime
 It is used by Realm for local storage
 */

class RealmAppSettings: Object {
    dynamic private var maxNumberOfMarkers: Int = 0
    dynamic private var radiusOfDetection: Int = 0
    private var selectedPOICategrories: List<RealmString> = List<RealmString>()
    
    convenience init(_ settings: AppSettings) {
        self.init()
        maxNumberOfMarkers = settings.maxNumberOfMarkers
        radiusOfDetection = settings.radiusOfDetection
        
        for category in settings.selectedPOICategrories {
            selectedPOICategrories.append(RealmString(category))
        }
    }
    
    func applyToAppSettings() {
        let settings = AppSettings.getInstance()
        settings.updateMaxNumberOfMarkers(with: maxNumberOfMarkers)
        settings.updateRadiusOfDetection(with: radiusOfDetection)
        
        // remove all categories in the current setting
        for category in settings.selectedPOICategrories {
            settings.removePOICategories(category)
        }
        
        // add all the new categories to the setting
        for newCategory in selectedPOICategrories {
            settings.addSelectedPOICategories(newCategory.get())
        }
    }
}
