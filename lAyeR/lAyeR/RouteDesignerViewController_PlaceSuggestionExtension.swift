//
//  RouteDesignerViewController_PlaceSuggestionExtension.swift
//  lAyeR
//
//  Created by Patrick Cho on 4/10/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

extension RouteDesignerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestedPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        cell.textLabel?.text = suggestedPlaces[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectingSource {
            self.sourceText = suggestedPlaces[indexPath.row]
            self.sourceBar.text = self.sourceText
            selectingSource = false
            self.selectPlacesView.isHidden = true
            if self.useDestCoordinates {
                self.startSearch(destination: searchBar.text!)
            } else {
                self.placeAutocomplete(query: self.searchBar.text!) {(results2, error2) -> Void in
                    if error2 != nil {
                        self.cantFindDestinationLocation()
                        return
                    }
                    self.dealWithSuggestedDestinations(results: results2)
                }
            }
        } else {
            self.selectPlacesView.isHidden = true
            startSearch(destination: suggestedPlaces[indexPath.row])
        }
    }
    
}
