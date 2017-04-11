//
//  RouteDesignerViewController_SegueExtesnsion.swift
//  lAyeR
//
//  Created by luoyuyang on 10/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces


extension RouteDesignerViewController {
    // ---------------- back segue to AR view --------------------//
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let arViewController = segue.destination as? ARViewController {

            let route = createRoute(from: markers)
            arViewController.route = route
            arViewController.controlRoute = extractControlRoute(from: route)
            arViewController.scnViewController.route = route

            arViewController.displayCheckpointCards(nextCheckpointIndex: 0)
            
            arViewController.prepareNodes()
            
            //TODO: force update the POI in ARView
        }
    }
    
    private func createRoute(from markers: [GMSMarker]) -> Route {
        let route = Route("the name of the route")
        for marker in markers {
            guard let checkpoint = marker.userData as? CheckPoint else {
                continue
            }
            route.append(checkpoint)
        }
        return route
    }
    
    private func extractControlRoute(from route: Route) -> Route {
        let controlRoute = Route("the route formed by control points")
        for checkpoint in route.checkPoints {
            if checkpoint.isControlPoint {
                controlRoute.append(checkpoint)
            }
        }
        return controlRoute
    }
}
