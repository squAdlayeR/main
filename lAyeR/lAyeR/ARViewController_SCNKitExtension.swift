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

extension ARViewController {
    private func getArrowSCNNode() -> SCNNode {
        let path = Bundle.main.path(forResource: Constant.pathArrowName, ofType: Constant.pathArrowExtension)!
        let asset = MDLAsset(url: URL(string: path)!)
        let arrowNode = SCNNode(mdlObject: asset.object(at: 0))
        arrowNode.geometry?.firstMaterial?.emission.contents = UIColor.orange
        return arrowNode
    }
    
    func prepareScene() {
        let scnView = SCNView(frame: view.frame)
        scnView.backgroundColor = UIColor.clear
        view.insertSubview(scnView, at: 1)
        scnView.scene = scene
        
        setupCameraNode()
        setupArrows()
    }
    
    func setupCameraNode() {
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
    }
    
    func setupArrows() {
        for i in 0 ... 12 {  // show 8 arrows
            arrowNodes.append(getArrowSCNNode())
            
            let r1 = SCNMatrix4Rotate(SCNMatrix4Identity, Float(-M_PI), 1, 0, 0)
            arrowNodes[i].transform = r1
            arrowNodes[i].scale = SCNVector3(x: 1/38, y: 1/38, z: 1/18)
            arrowNodes[i].position = SCNVector3(x: 0, y: -1.6, z: Float(-3.8 * Double(i)))
            
            scene.rootNode.addChildNode(arrowNodes[i])
        }
    }
    
    func updateScene() {
        let direction = M_PI / 2
        
        let pitch = motionManager.getVerticalAngle()
        let yaw = motionManager.getYawAngle()
        let roll = motionManager.getHorzAngleRelToNorth()
        
        var r1 = SCNMatrix4Rotate(SCNMatrix4Identity, Float(roll + direction), 0, 1, 0)
        r1 = SCNMatrix4Rotate(r1, Float(pitch), 1, 0, 0)
        r1 = SCNMatrix4Rotate(r1, Float(-yaw), 0, 0, 1)
        cameraNode.transform = r1
    }
}
