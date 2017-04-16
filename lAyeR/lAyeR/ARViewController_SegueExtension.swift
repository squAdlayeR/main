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
        if segue.identifier == StoryboardConstants.arToDesignerImportSegue {
            prepareSegueToRouteDesignerImport(for: segue, sender: sender)
        } else if segue.identifier == StoryboardConstants.arToDesignerSegue {
            prepareSegueToDesigner(for: segue, sender: sender)
        } else if segue.identifier == StoryboardConstants.directToDesignerSegue {
            prepareSegueToRouteDesignerWithDirect(for: segue, sender: sender)
        }
    }
    
    private func prepareSegueToRouteDesignerImport(for segue: UIStoryboardSegue, sender: Any?) {
        if let url = sender as? URL, let dest = segue.destination as? RouteDesignerViewController {
            dest.importedURL = url
        }
    }
    
    private func prepareSegueToDesigner(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? RouteDesignerViewController else {
            return
        }
        dest.removeAllPoints()
        let currentUserPoint = geoManager.getLastUpdatedUserPoint()
        dest.myLocation = CLLocation(latitude: currentUserPoint.latitude, longitude: currentUserPoint.longitude)
        for (idx, checkpoint) in route.checkPoints.enumerated() {
            dest.addPoint(coordinate: CLLocationCoordinate2D(latitude: checkpoint.latitude,
                                                             longitude: checkpoint.longitude),
                          isControlPoint: checkpoint.isControlPoint,
                          at: idx)
        }
    }
    
    private func prepareSegueToRouteDesignerWithDirect(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? RouteDesignerViewController else {
            return
        }
        
        guard let destName = cardDestination else {
            return
        }
        
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








