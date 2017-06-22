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
        let initialDistance = GeoUtil.getCoordinateDistance(userPoint, centerPOI)
        let initialLayoutAdjustment = ARViewLayoutAdjustment(deviceMotionManager: motionManager,
                                                      distance: initialDistance, azimuth: azimuth,
                                                      superView: superView, fov: fov)
        cards.first!.applyViewAdjustment(initialLayoutAdjustment)
        for i in 1..<self.cards.count {
            let card = cards[i]
            let distance = GeoUtil.getCoordinateDistance(userPoint, pois[i])
            let layoutAdjustment = ARViewLayoutAdjustment(distance: distance,
                                                          following: initialLayoutAdjustment,
                                                          at: i)
            card.applyViewAdjustment(layoutAdjustment)
            card.update(distance)
        }
    }
    
    deinit {
        _ = cards.map {$0.removeFromSuperview()}
    }
}
