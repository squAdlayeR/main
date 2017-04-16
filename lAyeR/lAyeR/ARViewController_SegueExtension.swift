//
//  ARViewController_SegueExtension.swift
//  lAyeR
//
//  Created by luoyuyang on 10/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension ARViewController {
    @IBAction func unwindSegueToARView(segue: UIStoryboardSegue) {
        currentPoiCardControllers.removeAll()
    }
    
    @IBAction func unwindFromRouteDesigner(segue: UIStoryboardSegue) {
        scnViewController.removeAllArrows()
        checkpointCardControllers.removeAll()
        miniMapController.mapView.clear()
        setMode(to: .explore)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "arToDesignerImport" {
            if let url = sender as? URL, let dest = segue.destination as? RouteDesignerViewController {
                dest.importedURL = url
            }
            return
        }
        if segue.identifier == "arToDesignerSegue" {
            guard let dest = segue.destination as? RouteDesignerViewController else { return }
            dest.removeAllPoints()
            let currentUserPoint = geoManager.getLastUpdatedUserPoint()
            dest.myLocation = CLLocation(latitude: currentUserPoint.latitude, longitude: currentUserPoint.longitude)
            for (idx, checkpoint) in route.checkPoints.enumerated() {
                dest.addPoint(coordinate: CLLocationCoordinate2D(latitude: checkpoint.latitude, longitude: checkpoint.longitude), isControlPoint: checkpoint.isControlPoint, at: idx)
            }
        }
        if segue.identifier == segueToDirectName {
            guard let dest = segue.destination as? RouteDesignerViewController else { return }
            if let destName = cardDestination {
                let currentUserPoint = geoManager.getLastUpdatedUserPoint()
                dest.myLocation = CLLocation(latitude: currentUserPoint.latitude, longitude: currentUserPoint.longitude)
                dest.importedSearchDestination = destName
                dest.getDirections(origin: "\(currentUserPoint.latitude) \(currentUserPoint.longitude)",
                    destination: destName,
                    waypoints: nil,
                    removeAllPoints: true,
                    at: 0,
                    completion: dest.getLayerAndGpsRoutesUponCompletionOfGoogle(result:))
            }
        }
    }
}
