//
//  ARViewController_SCNKitExtension.swift
//  lAyeR
//
//  Created by luoyuyang on 05/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SceneKit.ModelIO

/*
 The origin of the coordinate is the start point
 The positive direction of x axis points to the East
 The negative direction of z axis points to the North
 */
extension ARViewController {
    var firstCheckpoint: GeoPoint? {
        guard checkpointCardControllers.count > 0 else {
            return nil
        }
        return checkpointCardControllers[0].checkpoint
    }
    
    func prepareScene() {
        scnView = SCNView(frame: view.frame)
        scnView.backgroundColor = UIColor.clear
        scnView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        view.insertSubview(scnView, at: 2)
        scnView.scene = scene
        
        prepareNodes()
    }
    
    /**
     remvoe obsolete arrow nodes,
     then add camera node and arrow nodes
     */
    func prepareNodes() {
        removeAllArrows()
        setupArrowNodes()
        setupCameraNode()
    }
    
    /**
     return a SCNNode arrow that points to the North
     */
    private func getArrowSCNNode() -> SCNNode {
        let path = Bundle.main.path(forResource: Constant.pathArrowName, ofType: Constant.pathArrowExtension)!
        let asset = MDLAsset(url: URL(string: path)!)
        let arrowNode = SCNNode(mdlObject: asset.object(at: 0))
        arrowNode.geometry?.firstMaterial?.emission.contents = Constant.arrowDefaultColor
        
        arrowNode.transform = SCNMatrix4Rotate(SCNMatrix4Identity, Float(-M_PI / 2), 1, 0, 0)
        arrowNode.transform = SCNMatrix4Rotate(arrowNode.transform, Float(M_PI / 2), 0, 1, 0)
        
        return arrowNode
    }
    
    private func setupArrowNodes() {
        guard let firstCheckpoint = firstCheckpoint else {
            return
        }
        let userPoint = geoManager.getLastUpdatedUserPoint()
        
        var previousOffset = addArrows(from: userPoint, to: firstCheckpoint, firstOffset: 0.8)
        for i in 0 ..< checkpointCardControllers.count - 1 {
            let src = checkpointCardControllers[i].checkpoint
            let dest = checkpointCardControllers[i + 1].checkpoint
            previousOffset = addArrows(from: src, to: dest, firstOffset: previousOffset)
        }
    }
    
    private func setupCameraNode() {
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
    }
    
    /**
     add arrows starting from the source to the destination
     - Parameters: firstOffset  the distance in meters from the source to the first arrow
     */
    func addArrows(from src: GeoPoint, to dest: GeoPoint, firstOffset: Double) -> Double {
        guard let firstPoint = firstCheckpoint else {
            return 0
        }
        
        let srcDestDistance = GeoUtil.getCoordinateDistance(src, dest)
        let srcDestAzimuth = GeoUtil.getAzimuth(between: src, dest)
        
        let originSrcDistance = GeoUtil.getCoordinateDistance(firstPoint, src)
        let originSrcAzimuth = GeoUtil.getAzimuth(between: firstPoint, src)
        
        let srcPosition = azimuthDistanceToCoordinate(azimuth: originSrcAzimuth, distance: originSrcDistance)
        
        var currentOffset = firstOffset
        while currentOffset <= srcDestDistance {
            let arrow = getArrowSCNNode()
        
            let rotationTransformation = SCNMatrix4Rotate(arrow.transform,
                                                          -Float(GeoUtil.getAzimuth(between: src, dest)),
                                                          0, 1, 0)
            arrow.transform = rotationTransformation
            
            arrow.scale = SCNVector3(x: 1/24, y: 1/24, z: 1/108)
            
            let distance = currentOffset
            let positionRelToSrc = azimuthDistanceToCoordinate(azimuth: srcDestAzimuth, distance: distance)
            arrow.position = srcPosition + positionRelToSrc + SCNVector3(0, -Constant.arrowGap, 0)
            
            arrowNodes.append(arrow)
            scene.rootNode.addChildNode(arrow)
            
            currentOffset += Constant.arrowGap
        }
        return currentOffset - srcDestDistance
    }
    
    /**
     remove all arrow nodes from memory
     */
    private func removeAllArrows() {
        for arrow in arrowNodes {
            arrow.removeFromParentNode()
        }
        arrowNodes = []
    }
    
    func updateScene() {
        let pitch = motionManager.getVerticalAngle()
        let yaw = motionManager.getYawAngle()
        let roll = motionManager.getHorzAngleRelToNorth()
        
        // Note: the transfomation concatenation is the reversed order
        var transform = SCNMatrix4Rotate(SCNMatrix4Identity, Float(-yaw), 0, 0, 1)
        transform = SCNMatrix4Rotate(transform, Float(pitch), 1, 0, 0)
        transform = SCNMatrix4Rotate(transform, Float(roll), 0, 1, 0)
        
        if checkpointCardControllers.count > 0 {
            let source = checkpointCardControllers[0].checkpoint
            let userPoint = geoManager.getLastUpdatedUserPoint()
            let azimuth = GeoUtil.getAzimuth(between: userPoint, source)
            let distance = GeoUtil.getCoordinateDistance(userPoint, source)
            let v = azimuthDistanceToCoordinate(azimuth: azimuth, distance: distance)
            
            transform = SCNMatrix4Translate(transform, -(v.x), 0, -(v.z))
        }
        
        cameraNode.transform = transform
        
        updateOpacity()
    }
    
    private func updateOpacity() {
        // show arorws in the decreasing opacity
        let opacityGap = Constant.arrowOpacity / Double(Constant.numDisplayedArrow)
        for i in 0 ..< arrowNodes.count {
            let opacity = Constant.arrowOpacity - Double(i) * opacityGap
            arrowNodes[i].opacity = CGFloat(opacity < 0 ? 0 : opacity)
        }
    }
    
    
    private func azimuthDistanceToCoordinate(azimuth: Double, distance: Double) -> SCNVector3 {
        let x = distance * sin(azimuth)  // positive: to East
        let y = distance * cos(azimuth)  // positive: to North
        return SCNVector3(x: Float(x), y: 0, z: Float(-y))
    }
    
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let tappedPoint = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(tappedPoint, options: [:])
        
        // check that click on at least one object
        if hitResults.count > 0 {
            animateMovingOn()
        }
    }
    
    func animateMovingOn() {
        let count = arrowNodes.count > Constant.numDisplayedArrow ?
                    Constant.numDisplayedArrow :
                    arrowNodes.count
        
        let pr: CGFloat = (1 - Constant.arrowDefaultColorR) / 0.18
        let pg: CGFloat = (1 - Constant.arrowDefaultColorG) / 0.18
        let pb: CGFloat = (1 - Constant.arrowDefaultColorB) / 0.18
        
        let changeColorAction = SCNAction.sequence([
            SCNAction.customAction(duration: 0.38, action: { (node, time) in
                let color = UIColor(red: pr * time,
                                    green: Constant.arrowDefaultColorG + pg * time,
                                    blue: Constant.arrowDefaultColorB + pb * time, alpha: 1)
                node.geometry!.firstMaterial!.emission.contents = color
            }),
            
            SCNAction.customAction(duration: 0.28, action: { (node, time) in
                let color = UIColor(red: 1 - pr * time,
                                    green: 1 - pg * time,
                                    blue: 1 - pb * time, alpha: 1)
                node.geometry!.firstMaterial!.emission.contents = color
            })
        ])
        
        let floatAction = SCNAction.sequence([
            SCNAction.moveBy(x: 0, y: 0.08, z: 0, duration: 0.28),
            SCNAction.moveBy(x: 0, y: -0.08, z: 0, duration: 0.28),
        ])
        
        for i in 0 ..< count {
            arrowNodes[i].runAction(SCNAction.sequence([
                SCNAction.wait(duration: Double(i) * 0.38),
                SCNAction.group([changeColorAction, floatAction])  // parallely
            ]))
        }
    }
}


extension SCNVector3 {
    public static func +(v1: SCNVector3, v2: SCNVector3) -> SCNVector3 {
        return SCNVector3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
    }
}


























