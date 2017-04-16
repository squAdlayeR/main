//
//  RouteDesignerViewController_SaveExportExtension.swift
//  lAyeR
//
//  Created by Patrick Cho on 4/15/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

extension RouteDesignerViewController {
    /// Saves the route
    func saveRoute() {
        closeStoreRoutePopup()
        let alert = UIAlertController(title: "Saving Route to Cloud", message: "Enter a Unique Name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Route Name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            if (textField.text != nil && textField.text != "") {
                let route = Route(textField.text!)
                route.append(CheckPoint(self.source!.latitude, self.source!.longitude, RouteDesignerConstants.checkpointDefaultName, RouteDesignerConstants.checkpointDefaultDescription, true))
                for marker in self.markers {
                    let markerData = marker.userData as! CheckPoint
                    route.append(markerData)
                }
                do {
                    let url = try GPXFileManager.instance.save(name: route.name, image: self.viewCapture(view: self.mapView))
                    route.setImage(path: url.absoluteString)
                } catch {
                    // print("where")
                }
                // TODO: separate local storage and server
                self.routeDesignerModel.saveToLocal(route: route)
                LoadingBadge.instance.showBadge(in: self.view)
                self.routeDesignerModel.saveToDB(route: route){ bool in
                    LoadingBadge.instance.hideBadge()
                    if bool {
                        let resultAlert = UIAlertController(title: RouteDesignerConstants.saveSuccessfulText, message: "Congrats", preferredStyle: .alert)
                        resultAlert.addAction(UIAlertAction(title: "Okay", style: .default))
                        self.present(resultAlert, animated: true, completion: nil)
                    } else {
                        let resultAlert = UIAlertController(title: RouteDesignerConstants.saveFailText, message: RouteDesignerConstants.duplicateRouteNameWarningText, preferredStyle: .alert)
                        resultAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
                            DatabaseManager.instance.updateRouteInDatabase(route: route)
                        }))
                        resultAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        self.present(resultAlert, animated: true, completion: nil)
                    }
                }
                
            } else {
                let resultAlert = UIAlertController(title: RouteDesignerConstants.saveFailText, message: RouteDesignerConstants.emptyRouteNameStringText, preferredStyle: .alert)
                resultAlert.addAction(UIAlertAction(title: "Okay", style: .default))
                self.present(resultAlert, animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// exports the route
    func exportRoute() {
        closeStoreRoutePopup()
        let alert = UIAlertController(title: "Exporting Route", message: "Enter a Unique Name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Route Name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Export", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            if (textField.text != nil && textField.text != "") {
                let route = Route(textField.text!)
                route.append(CheckPoint(self.source!.latitude, self.source!.longitude, RouteDesignerConstants.checkpointDefaultName, RouteDesignerConstants.checkpointDefaultDescription, true))
                for marker in self.markers {
                    let markerData = marker.userData as! CheckPoint
                    route.append(markerData)
                }
                self.share(routes: [route])
            } else {
                let resultAlert = UIAlertController(title: RouteDesignerConstants.saveFailText, message: RouteDesignerConstants.emptyRouteNameStringText, preferredStyle: .alert)
                resultAlert.addAction(UIAlertAction(title: "Okay", style: .default))
                self.present(resultAlert, animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
