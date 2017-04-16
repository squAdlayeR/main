//
//  RouteDesignerViewController_AutoCompleteExtension.swift
//  lAyeR
//
//  Created by Patrick Cho on 4/9/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

extension RouteDesignerViewController {
    
    func placeAutocomplete(query: String, completion: @escaping (_ results: [GMSAutocompletePrediction]?, _ error: Error?) -> ()) {
        let filter = GMSAutocompleteFilter()
        filter.country = UserConfig.country
        placesClient.autocompleteQuery(query, bounds: nil, filter: filter, callback: completion)
    }
}
