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
        let azimuth = centerPOI.azimuth!
        let initialDistance = centerPOI.distance!
        let initialLayoutAdjustment = ARViewLayoutAdjustment(deviceMotionManager: motionManager,
                                                      distance: initialDistance, azimuth: azimuth,
                                                      superView: superView, fov: fov)
        cards.first!.applyViewAdjustment(initialLayoutAdjustment)
        cards.first!.setMarkerAlpha(to: 1)
        cards.first!.update(initialDistance)
        for i in 1..<self.cards.count {
            let card = cards[i]
            let distance = GeoUtil.getCoordinateDistance(userPoint, pois[i])
            let layoutAdjustment = ARViewLayoutAdjustment(distance: distance,
                                                          following: initialLayoutAdjustment,
                                                          at: i)
            card.applyViewAdjustment(layoutAdjustment)
            card.update(distance)
            card.setMarkerAlpha(to: CGFloat(5 - i) * 0.2)
        }
    }
    
    deinit {
        _ = cards.map {$0.removeFromSuperview()}
    }
}
