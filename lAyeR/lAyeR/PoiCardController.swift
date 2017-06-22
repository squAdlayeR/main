//
//  PoiCardController.swift
//  lAyeR
//
//  Created by luoyuyang on 01/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import UIKit

class PoiCardController: POISetControlDelegate, Hashable {
    let poi: POI
    let card: PoiCard
    
    init(poi: POI, card: PoiCard) {
        self.poi = poi
        self.card = card
    }
    
    func updateComponents(userPoint: GeoPoint, superView: UIView, fov: Double) {
        let layoutAdjustment = ARViewLayoutAdjustment(deviceMotionManager: motionManager,
                                                      distance: poi.distance, azimuth: poi.azimuth,
                                                      superView: superView, fov: fov)
        card.applyViewAdjustment(layoutAdjustment)
        card.update(poi.distance)
        card.setMarkerAlpha(to: calculateAlpha(distance: layoutAdjustment.pushBackDistance))
    }
    
    /// Calculates the alpha of the card based on distance
    ///
    /// - Parameter distance: Distance for calculation
    /// - Returns: the calculated alpha value
    private func calculateAlpha(distance: CGFloat) -> CGFloat {
        return ARViewConstants.maxMarkerAlpha - ARViewConstants.markerAlphaChangeRange * distance / ARViewConstants.maxPushBackDistance
    }
    
    deinit {
        card.removeFromSuperview()
    }
    
    static func == (lhs: PoiCardController, rhs: PoiCardController) -> Bool {
        return lhs.poi.name == rhs.poi.name
    }
    
    var hashValue: Int {
        return (poi.name ?? "").hashValue
    }
}
