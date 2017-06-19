//
//  ClusterCardController.swift
//  lAyeR
//
//  Created by Desperado on 18/06/2017.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

class ClusterCardController {
    let pois: [POI]
    let card: ClusterCard
    var poiName: String? {
        return pois.name
    }
    
    init(pois: [POI], card: ClusterCard) {
        self.pois = pois
        self.card = card
    }
    
    /**
     update position and orientation of card
     update the distance displayed on the card
     update the opacity of the card
     */
    func updateCard(userPoint: GeoPoint, motionManager: DeviceMotionManager,
                    superView: UIView, fov: Double) {
        let azimuth = GeoUtil.getAzimuth(between: userPoint, poi)
        let distance = GeoUtil.getCoordinateDistance(userPoint, poi)
        
        let layoutAdjustment = ARViewLayoutAdjustment(deviceMotionManager: motionManager,
                                                      distance: distance, azimuth: azimuth,
                                                      superView: superView, fov: fov)
        card.applyViewAdjustment(layoutAdjustment)
        card.update(distance)
        card.setMarkderAlpha(to: calculateAlpha(distance: layoutAdjustment.pushBackDistance))
    }
    
    private func calculateAlpha(distance: CGFloat) -> CGFloat {
        return ARViewConstants.maxMarkerAlpha - ARViewConstants.markerAlphaChangeRange * distance / ARViewConstants.maxPushBackDistance
    }
    
    func removeCard() {
        card.removeFromSuperview()
    }
    
    deinit {
        removeCard()
    }
}
