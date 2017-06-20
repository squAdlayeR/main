//
//  PoiCardController.swift
//  lAyeR
//
//  Created by luoyuyang on 01/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit

class PoiCardController {
    let poi: POI
    let card: PoiCard
    
    var poiName: String? {
        return poi.name
    }
    
    init(poi: POI, card: PoiCard) {
        self.poi = poi
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
        card.setMarkerAlpha(to: calculateAlpha(distance: layoutAdjustment.pushBackDistance))
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
