//
//  ClusterController.swift
//  lAyeR
//
//  Created by Desperado on 18/06/2017.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

class ClusterController: POISetControlDelegate {
    static var expandedCluster: ClusterController?
    
    let pois: [POI]
    let cards: [PoiCard]
    
    init(pois: [POI], cards: [PoiCard]) {
        self.pois = pois
        self.cards = cards
    }
    
    func updateComponents(userPoint: GeoPoint, superView: UIView, fov: Double) {
        let centerPOI = pois[0]
        let azimuth = centerPOI.azimuth ?? centerPOI.calculateAzimuth(from: userPoint)
        let initialDistance = centerPOI.distance ?? centerPOI.calculateDistance(from: userPoint)
        let initialLayoutAdjustment = ARViewLayoutAdjustment(deviceMotionManager: motionManager,
                                                             distance: initialDistance, 
                                                             azimuth: azimuth,
                                                             superView: superView, 
                                                             fov: fov)
        cards[0].applyViewAdjustment(initialLayoutAdjustment)
        cards[0].setMarkerAlpha(to: 1)
        cards[0].update(initialDistance)
        for i in 1..<self.cards.count {
            let card = cards[i]
            let distance = pois[i].distance ?? pois[i].calculateDistance(from: userPoint)
            let layoutAdjustment = ARViewLayoutAdjustment(distance: distance,
                                                          following: initialLayoutAdjustment,
                                                          at: i)
            card.applyViewAdjustment(layoutAdjustment)
            card.update(distance)
            card.setMarkerAlpha(to: i < 5 ? CGFloat(5 - i) * 0.1 + 0.5 : 0)
        }
    }
    
    func cardTapped(defaultCallback: @escaping () -> Void = {}) {
        if ClusterController.expandedCluster !== self {
            ClusterController.expandedCluster?.pack()
            ClusterController.expandedCluster = self
            self.expand()
        } else {
            defaultCallback()
        }
    }
    
    private func pack() {
        
    }
    
    private func expand() {
        
    }
    
    deinit {
        cards.forEach {$0.removeFromSuperview()}
    }
}
