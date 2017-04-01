//
//  CheckpointCardController.swift
//  lAyeR
//
//  Created by luoyuyang on 01/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit

class CheckpointCardController {
    let checkpoint: CheckPoint
    let card: CheckpointCard
    
    init(checkpoint: CheckPoint, card: CheckpointCard) {
        self.checkpoint = checkpoint
        self.card = card
    }
    
    // update position and orientation of card
    // update the distance shown on the card
    func updateCard(userPoint: GeoPoint, motionManager: DeviceMotionManager,
                    superView: UIView, fov: Double) {
        let azimuth = GeoUtil.getAzimuth(between: userPoint, checkpoint)
        let distance = GeoUtil.getCoordinateDistance(userPoint, checkpoint)
        
        let layoutAdjustment = ARViewLayoutAdjustment(deviceMotionManager: motionManager,
                                                      distance: distance, azimuth: azimuth,
                                                      superView: superView, fov: fov)
        card.applyViewAdjustment(layoutAdjustment)
        card.update(distance)
    }
}
