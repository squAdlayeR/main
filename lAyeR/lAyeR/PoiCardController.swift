//
//  PoiCardController.swift
//  lAyeR
//
//  Created by luoyuyang on 01/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import UIKit

class PoiCardController: POISetControlDelegate {
    let poi: POI
    let card: PoiCard
    
    init(poi: POI, card: PoiCard) {
        self.poi = poi
        self.card = card
    }
    
    func updateComponents(userPoint: GeoPoint, superView: UIView, fov: Double) {
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
    
    deinit {
        card.removeFromSuperview()
    }
}
