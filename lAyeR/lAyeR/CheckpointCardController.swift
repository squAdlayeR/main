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
    private var layoutAdjustment: ARViewLayoutAdjustment!
    private var selected: Bool = false
    private var arrow: UIView!
    
    private var isInsideView: Bool {
        guard let superView = card.superView else {
            return false
        }
        return card.markerCard.frame.intersects(superView.frame)
    }
    
    
    init(checkpoint: CheckPoint, card: CheckpointCard) {
        self.checkpoint = checkpoint
        self.card = card
        
        initializeArrow()
    }

    
    private func initializeArrow() {
        arrow = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 38))
        arrow.backgroundColor = UIColor.white
    }
    
    
    func setSelected(_ selected: Bool) {
        self.selected = selected
        
        guard let superView = card.superView else {
            return
        }
        if selected {
            superView.addSubview(arrow)
        } else {
            arrow.removeFromSuperview()
        }
    }
    
    
    // update position and orientation of card
    // update the distance shown on the card
    func updateCard(userPoint: GeoPoint, motionManager: DeviceMotionManager,
                    superView: UIView, fov: Double) {
        let azimuth = GeoUtil.getAzimuth(between: userPoint, checkpoint)
        let distance = GeoUtil.getCoordinateDistance(userPoint, checkpoint)
        
        layoutAdjustment = ARViewLayoutAdjustment(deviceMotionManager: motionManager,
                                                  distance: distance, azimuth: azimuth,
                                                  superView: superView, fov: fov)
        card.applyViewAdjustment(layoutAdjustment)
        card.update(distance)
        
        guard selected else {
           return
        }
        if !isInsideView {
            displayArrow()
        } else {
            arrow.isHidden = true
        }
    }
    
    
    private func displayArrow() {
        guard let superView = card.superView else {
            return
        }
        arrow.isHidden = false
        let xOffset = layoutAdjustment.xPosition - superView.center.x
        let yOffset = superView.center.y - layoutAdjustment.yPosition
        let angle = atan2(xOffset, yOffset)
        arrow.layer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        
        arrow.center = CGPoint(x: superView.center.x, y: superView.center.y)
        let screenDiagonalAngle = atan2(superView.bounds.width, superView.bounds.height)
        
        let halfSuperviewWidth = superView.bounds.width / 2
        let halfSuperviewHeight = superView.bounds.height / 2
        if angle > -(CGFloat(M_PI) - screenDiagonalAngle) && angle < -screenDiagonalAngle {
            arrow.center.y = halfSuperviewHeight + halfSuperviewWidth / tan(angle)
            arrow.center.x = 0
        } else if angle > screenDiagonalAngle && angle < CGFloat(M_PI) - screenDiagonalAngle {
            arrow.center.y = halfSuperviewHeight - halfSuperviewWidth / tan(angle)
            arrow.center.x = 2 * halfSuperviewWidth
        } else if angle > -screenDiagonalAngle && angle < screenDiagonalAngle {
            arrow.center.y = 0
            arrow.center.x = halfSuperviewWidth + halfSuperviewHeight * tan(angle)
        } else if angle < -(CGFloat(M_PI) - screenDiagonalAngle) || angle > CGFloat(M_PI) - screenDiagonalAngle {
            arrow.center.y = 2 * halfSuperviewHeight
            arrow.center.x = halfSuperviewWidth - halfSuperviewHeight * tan(angle)
        }
    }
    
    
    func removeCard() {
        card.removeFromSuperview()
    }
    
    
    deinit {
        removeCard()
    }
}














