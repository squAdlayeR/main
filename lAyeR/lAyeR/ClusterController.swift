//
//  ClusterController.swift
//  lAyeR
//
//  Created by Desperado on 18/06/2017.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

class ClusterController: POISetControlDelegate {
    let pois: [POI]
    let cards: [PoiCard]
    
    init(pois: [POI], cards: [PoiCard]) {
        self.pois = pois
        self.cards = cards
    }
    
    func updateComponents(userPoint: GeoPoint, superView: UIView, fov: Double) {
        let centerPOI = pois.first!
        let azimuth = GeoUtil.getAzimuth(between: userPoint, centerPOI)
        let distance = GeoUtil.getCoordinateDistance(userPoint, centerPOI)
        
        let layoutAdjustment = ARViewLayoutAdjustment(deviceMotionManager: motionManager,
                                                      distance: distance, azimuth: azimuth,
                                                      superView: superView, fov: fov)
        for (i, card) in self.cards.enumerated() {
            card.applyViewAdjustment(layoutAdjustment)
            card.update(distance)
            card.setMarkerAlpha(to: (5 - CGFloat(i)) * 0.2)
        }
    }
    
    deinit {
        _ = cards.map {$0.removeFromSuperview()}
    }
}
