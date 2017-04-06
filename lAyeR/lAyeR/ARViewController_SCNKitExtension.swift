//
//  ARViewController_SCNKitExtension.swift
//  lAyeR
//
//  Created by luoyuyang on 05/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import SceneKit
import SceneKit.ModelIO

/*
 The origin of the coordinate is the start point
 The positive direction of x axis points to the East
 The negative direction of z axis points to the North
 */
extension ARViewController {
    /**
     return a SCNNode arrow that points to the North
    */
    private func getArrowSCNNode() -> SCNNode {
        let path = Bundle.main.path(forResource: Constant.pathArrowName, ofType: Constant.pathArrowExtension)!
        let asset = MDLAsset(url: URL(string: path)!)
        let arrowNode = SCNNode(mdlObject: asset.object(at: 0))
        arrowNode.geometry?.firstMaterial?.emission.contents = arrowColor
        
        arrowNode.transform = SCNMatrix4Rotate(SCNMatrix4Identity, Float(-M_PI), 1, 0, 0)
        
        return arrowNode
    }
    
    func prepareScene() {
        let scnView = SCNView(frame: view.frame)
        scnView.backgroundColor = UIColor.clear
        view.insertSubview(scnView, at: 1)
        scnView.scene = scene
        
        setupCameraNode()
        //setupArrows()
        
        guard checkpointCardControllers.count > 1 else {
            return
        }
        for i in 0 ..< checkpointCardControllers.count - 1 {
            let src = checkpointCardControllers[i].checkpoint
            let dest = checkpointCardControllers[i + 1].checkpoint
            addArrows(from: src, to: dest)
        }
    }
    
    private func setupCameraNode() {
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
    }
    
    func addArrows(from src: GeoPoint, to dest: GeoPoint) {
        guard checkpointCardControllers.count > 0 else {
            return
        }
        
        let firstPoint = checkpointCardControllers[0].checkpoint
        
        let srcDestDistance = GeoUtil.getCoordinateDistance(src, dest)
        let azimuth = GeoUtil.getAzimuth(between: src, dest)
        let num = Int(floor(srcDestDistance / gap) - 1)
        
        let originSrcDistance = GeoUtil.getCoordinateDistance(firstPoint, src)
        let originSrcAzimuth = GeoUtil.getAzimuth(between: firstPoint, src)
        
        let srcPosition = azimuthDistanceToCoordinate(azimuth: originSrcAzimuth, distance: originSrcDistance)
        
        for i in 1 ... num {
            let arrow = getArrowSCNNode()
        
            let rotationTransformation = SCNMatrix4Rotate(arrow.transform,
                                                          -Float(GeoUtil.getAzimuth(between: src, dest)),
                                                          0, 1, 0)
            arrow.transform = rotationTransformation
            
            arrow.scale = SCNVector3(x: 1/108, y: 1/108, z: 1/60)
            let distance = gap * Double(i)
            let positionRelToSrc = azimuthDistanceToCoordinate(azimuth: azimuth, distance: distance)
            arrow.position = srcPosition + positionRelToSrc + SCNVector3(0, -1.6, 0)
            
            arrowNodes.append(arrow)
            scene.rootNode.addChildNode(arrow)
        }
    }
    
    func updateScene() {
        let pitch = motionManager.getVerticalAngle()
        let yaw = motionManager.getYawAngle()
        let roll = motionManager.getHorzAngleRelToNorth()
        
        var r1 = SCNMatrix4Rotate(SCNMatrix4Identity, Float(-yaw), 0, 0, 1)
        r1 = SCNMatrix4Rotate(r1, Float(pitch), 1, 0, 0)
        r1 = SCNMatrix4Rotate(r1, Float(roll), 0, 1, 0)
        
        if checkpointCardControllers.count > 0 {
            let source = checkpointCardControllers[0].checkpoint
            let userPoint = geoManager.getLastUpdatedUserPoint()
            let azimuth = GeoUtil.getAzimuth(between: userPoint, source)
            let distance = GeoUtil.getCoordinateDistance(userPoint, source)
            let v = azimuthDistanceToCoordinate(azimuth: azimuth, distance: distance)
            
            r1 = SCNMatrix4Translate(r1, -(v.x), 0, -(v.z))
        }
        
        cameraNode.transform = r1
    }
    
    
    private func azimuthDistanceToCoordinate(azimuth: Double, distance: Double) -> SCNVector3 {
        let x = distance * sin(azimuth)  // positive: to East
        let y = distance * cos(azimuth)  // positive: to North
        return SCNVector3(x: Float(x), y: 0, z: Float(-y))
    }
}


extension SCNVector3 {
    public static func +(v1: SCNVector3, v2: SCNVector3) -> SCNVector3 {
        return SCNVector3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
    }
}


























