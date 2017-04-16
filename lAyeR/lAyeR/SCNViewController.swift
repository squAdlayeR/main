//
//  SCNViewController.swift
//  lAyeR
//
//  Created by luoyuyang on 10/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SceneKit.ModelIO



/**
 This is the clas that controls the display of the path arrows
 (It might also controls other ui components displayed using SceneKit in the future)
 
 The origin of the coordinate is the first check point
 The positive direction of x axis points to the East
 The negative direction of z axis points to the North
 */
class SCNViewController: UIViewController {
    // for displaying path with SceneKit
    let cameraNode = SCNNode()
    private let scene = SCNScene()
    private var scnView: SCNView!
    private var arrowNodes: [SCNNode] = []
    private let motionManager = DeviceMotionManager.getInstance()
    private let geoManager = GeoManager.getInstance()
    
    var route: Route!
    
    var nextCheckpointIndex = 0
    
    var isAnimating: Bool = true
    
    var animatingArrowIndex = 0
    
    /**
     The first checkpoint of the route to be displayed
     This checkpoint defines the origin of the coordinate
     */
    private var firstCheckpoint: GeoPoint? {
        guard route.size > 0 else {
            return nil
        }
        return route.checkPoints[0]
    }
   
    /**
     The next checkpoint the user is currently aiming to
     */
    private var nextCheckpoint: GeoPoint? {
        guard nextCheckpointIndex >= 0 && nextCheckpointIndex <= route.size - 1 else {
            return nil
        }
        return route.checkPoints[nextCheckpointIndex]
    }
    
    /**
     this method will be called when the AR view finish loading
     */
    func setupScene() {
        guard let arViewController = parent as? ARViewController else {
            return
        }
        scnView = SCNView(frame: view.frame)
        scnView.backgroundColor = UIColor.clear
        scnView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        
        view.addSubview(scnView)
        arViewController.view.insertSubview(view, at: 2)
        
        scnView.scene = scene
        
        route = arViewController.route
        
        prepareNodes()
    }
    
    /**
     remvoe obsolete arrow nodes,
     then add camera node and arrow nodes
     */
    func prepareNodes() {
        removeAllArrows()
        cameraNode.removeFromParentNode()
        updateArrowNodes()
        setupCameraNode()
    }
    
    /**
     return a SCNNode arrow that faces up and points to the North
     */
    private func getArrowSCNNode() -> SCNNode {
        let path = Bundle.main.path(forResource: ARViewConstants.pathArrowName, ofType: ARViewConstants.pathArrowExtension)!
        let asset = MDLAsset(url: URL(string: path)!)
        let arrowNode = SCNNode(mdlObject: asset.object(at: 0))
        arrowNode.geometry?.firstMaterial?.emission.contents = ARViewConstants.arrowDefaultColor
        
        arrowNode.transform = SCNMatrix4Rotate(SCNMatrix4Identity, Float(-Double.pi / 2), 1, 0, 0)
        arrowNode.transform = SCNMatrix4Rotate(arrowNode.transform, Float(Double.pi / 2), 0, 1, 0)
        
        arrowNode.scale = SCNVector3(x: 1 / 24.0, y: 1 / 24.0, z: 1 / 108.0)
        
        return arrowNode
    }
    
    /**
     udpate the arrows displayed
     when the change of user location is detected
     */
    func updateArrowNodes() {
        updateArrowsToBeDisplayed()
        
        updateSize()
        updateOpacity()
        
        if isAnimating {
            animateMovingOn()
        }
    }

    private func updateArrowsToBeDisplayed() {
        updateNextCheckpointIndex()
        
        guard let nextCheckpoint = nextCheckpoint else {
            return
        }
        
        removeAllArrows()
        
        var (previousOffset, leftCount) = addArrows(from: geoManager.getLastUpdatedUserPoint(),
                                                    to: nextCheckpoint,
                                                    firstOffset: ARViewConstants.firstArrowOffset,
                                                    leftCount: ARViewConstants.numArrowsDisplayedForward)
        
        for index in nextCheckpointIndex ..< route.size - 1 {
            if leftCount <= 0 {
                break
            }
            let src = route.checkPoints[index]
            let dest = route.checkPoints[index + 1]
            (previousOffset, leftCount) = addArrows(from: src , to: dest,
                                                    firstOffset: previousOffset,
                                                    leftCount: leftCount)
        }
    }
    
    /**
     update the index of the next checkpoint according to the user current location
     */
    private func updateNextCheckpointIndex() {
        for index in nextCheckpointIndex ..< nextCheckpointIndex + ARViewConstants.checkCloseRange {
            guard index >= 0 && index <= route.size - 1 else {
                return
            }
            
            if doesArrive(at: route.checkPoints[index]) {
                nextCheckpointIndex = index + 1
            }
        }
    }
    
    /**
     return a boolean value that indicates
     whether the user current location can be considered as arriving at the input checkpoint
     */
    private func doesArrive(at checkpoint: CheckPoint) -> Bool {
        let userPoint = geoManager.getLastUpdatedUserPoint()
        return GeoUtil.getCoordinateDistance(userPoint, checkpoint) < ARViewConstants.arrivalDistanceThreshold
    }
    
    /**
     add arrows starting from the source to the destination
     - Parameters: firstOffset  the distance in meters from the source to the first arrow
     - Returns: a tuple whose first element is the offset of the first checkpoint in the next segment
                whose second element is the number of arrows to be displayed left
     */
    private func addArrows(from src: GeoPoint, to dest: GeoPoint,
                   firstOffset: Double, leftCount: Int) -> (Double, Int) {
        
        guard let firstPoint = firstCheckpoint else {
            return (0, leftCount)
        }
        
        var leftCount = leftCount
        
        let srcDestDistance = GeoUtil.getCoordinateDistance(src, dest)
        let srcDestAzimuth = GeoUtil.getAzimuth(between: src, dest)
        
        let originSrcDistance = GeoUtil.getCoordinateDistance(firstPoint, src)
        let originSrcAzimuth = GeoUtil.getAzimuth(between: firstPoint, src)
        
        let srcPosition = azimuthDistanceToCoordinate(azimuth: originSrcAzimuth, distance: originSrcDistance)
        
        var currentOffset = firstOffset
        
        while currentOffset <= srcDestDistance && leftCount > 0 {
            let arrow = getArrowSCNNode()
            
            let rotationTransformation = SCNMatrix4Rotate(arrow.transform,
                                                          -Float(GeoUtil.getAzimuth(between: src, dest)),
                                                          0, 1, 0)
            arrow.transform = rotationTransformation
            
            let distance = currentOffset
            let positionRelToSrc = azimuthDistanceToCoordinate(azimuth: srcDestAzimuth, distance: distance)
            arrow.position = srcPosition + positionRelToSrc + SCNVector3(0, -ARViewConstants.arrowGap, 0)
            
            arrowNodes.append(arrow)
            scene.rootNode.addChildNode(arrow)
            
            currentOffset += ARViewConstants.arrowGap
            leftCount -= 1
        }
        return (currentOffset - srcDestDistance, leftCount)
    }

    private func setupCameraNode() {
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
    }
    
    /**
     remove all arrow nodes from memory
     */
    func removeAllArrows() {
        for arrow in arrowNodes {
            arrow.removeFromParentNode()
        }
        arrowNodes = []
    }
    
    func updateSceneCamera() {
        updateSceneCameraOrientation()
        updateSceneCameraPosition()
    }
    
    /**
     update the orientation of the camera node according to the data from the device motion manager
     */
    func updateSceneCameraOrientation() {
        let pitch = motionManager.getVerticalAngle()
        let yaw = motionManager.getYawAngle()
        let roll = motionManager.getHorzAngleRelToNorth()
        
        // Note: the transfomation concatenation is the reversed order
        var transform = SCNMatrix4Rotate(SCNMatrix4Identity, Float(-yaw), 0, 0, 1)
        transform = SCNMatrix4Rotate(transform, Float(pitch), 1, 0, 0)
        transform = SCNMatrix4Rotate(transform, Float(roll), 0, 1, 0)

        cameraNode.transform = transform
    }
    
    /**
     udpate the location of the camera node
     */
    func updateSceneCameraPosition() {
        guard let source = firstCheckpoint else {
            return
        }

        let userPoint = geoManager.getLastUpdatedUserPoint()
        let azimuth = GeoUtil.getAzimuth(between: userPoint, source)
        let distance = GeoUtil.getCoordinateDistance(userPoint, source)
        let v = azimuthDistanceToCoordinate(azimuth: azimuth, distance: distance)
        
        cameraNode.transform = SCNMatrix4Translate(cameraNode.transform, -(v.x), 0, -(v.z))
    }
    
    /**
     update the size of the arrows displayed when the change of user location is detected
     to simulate the perspective projection
     */
    private func updateSize() {
        guard arrowNodes.count > 0 else {
            return
        }
        let firstArrow = arrowNodes[0]
        for arrow in arrowNodes {
            let dx = arrow.position.x - firstArrow.position.x
            let dy = arrow.position.y - firstArrow.position.y
            let distance = Double(sqrt(dx * dx + dy * dy))
            
            let largerPercentage: Double = distance / (2 * ARViewConstants.arrowGap * Double(ARViewConstants.numArrowsDisplayedForward))

            let x = Double(arrow.scale.x)
            let y = Double(arrow.scale.y)
            let z = arrow.scale.z
            let newX = Float(x * (1.0 + largerPercentage))
            let newY = Float(y * (1.0 + largerPercentage))
            arrow.scale = SCNVector3(x: newX, y: newY, z: z)
        }
    }
    
    /**
     show arorws in the decreasing opacity
     */
    private func updateOpacity() {
        let opacityGap = ARViewConstants.arrowOpacity / Double(ARViewConstants.numArrowsDisplayedForward)
        for i in 0 ..< arrowNodes.count {
            let opacity = ARViewConstants.arrowOpacity - Double(i) * opacityGap
            arrowNodes[i].opacity = CGFloat(opacity < 0 ? 0 : opacity)
        }
    }
    
    /**
     given the azimuth and the distance of a certain point
     transform to the corresponding coordinate
     with positive x axis pointing to the East
     positive y axis pointing to the North
     - Parameters: The azimuth and the distance of the target point
     - Returns: the corresponding coordinate with positive x axis pointing to the East
                and the negative y axis pointing to the North
     */
    private func azimuthDistanceToCoordinate(azimuth: Double, distance: Double) -> SCNVector3 {
        let x = distance * sin(azimuth)  // positive: to East
        let y = distance * cos(azimuth)  // positive: to North
        return SCNVector3(x: Float(x), y: 0, z: Float(-y))
    }
    
    /**
     toggle whether should display the "moving on" animation
     when users tap at one of the arrow
     */
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let tappedPoint = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(tappedPoint, options: [:])
        
        // check that click on at least one object
        if hitResults.count > 0 {
            if isAnimating {
                stopAnimation()
            } else {
                animateMovingOn()
            }
        }
    }

    /**
     the action to change the color of a arrow to the one for highlight
     then change back to the normal color
     */
    private var changeColorAction: SCNAction {
        let pr: CGFloat = (ARViewConstants.targetColorR - ARViewConstants.arrowDefaultColorR) / 0.18
        let pg: CGFloat = (ARViewConstants.targetColorG - ARViewConstants.arrowDefaultColorG) / 0.18
        let pb: CGFloat = (ARViewConstants.targetColorB - ARViewConstants.arrowDefaultColorB) / 0.18
        
        return SCNAction.sequence([
            // change to color for highlighting
            SCNAction.customAction(duration: 0.38, action: { (node, time) in
                let color = UIColor(red: pr * time,
                                    green: ARViewConstants.arrowDefaultColorG + pg * time,
                                    blue: ARViewConstants.arrowDefaultColorB + pb * time, alpha: 1)
                node.geometry!.firstMaterial!.emission.contents = color
            }),
            
            // change back to normal color
            SCNAction.customAction(duration: 0.28, action: { (node, time) in
                let color = UIColor(red: ARViewConstants.targetColorR - pr * time,
                                    green: ARViewConstants.targetColorG - pg * time,
                                    blue: ARViewConstants.targetColorB - pb * time, alpha: 1)
                node.geometry!.firstMaterial!.emission.contents = color
            })
        ])
    }
    
    /** 
     the action to move the arrow up for a certain distance
     then move back to the original position
     */
    private var floatAction: SCNAction {
        return SCNAction.sequence([
            SCNAction.moveBy(x: 0, y: 0.08, z: 0, duration: 0.28),
            SCNAction.moveBy(x: 0, y: -0.08, z: 0, duration: 0.28),
        ])
    }
    
    private func animateMovingOn() {
        let count = arrowNodes.count > ARViewConstants.numArrowsDisplayedForward ?
                    ARViewConstants.numArrowsDisplayedForward :
                    arrowNodes.count
        
        for i in getOneRoundIndices(startFrom: animatingArrowIndex) {
            let relativeIndex = getRelativeIndexInOneIteration(startIndex: animatingArrowIndex,
                                                               actualIndex: i, length: count)
            
            let oneIteration = SCNAction.sequence([
                SCNAction.group([  // parallely
                    changeColorAction,
                    floatAction,
                    SCNAction.customAction(duration: 0, action: { _,_ in self.animatingArrowIndex = i })
                ]),
                SCNAction.wait(duration: Double(count) * 0.38),
            ])
        
            let foreverIteration = SCNAction.sequence([
                SCNAction.wait(duration: Double(relativeIndex) * 0.38),
                SCNAction.repeatForever(oneIteration)
            ])
            
            arrowNodes[i].runAction(foreverIteration, forKey: ARViewConstants.arrowActionKey)
        }
        isAnimating = true
    }
    
    private func getOneRoundIndices(startFrom firstIndex: Int) -> [Int] {
        var range: [Int] = []
        let count = arrowNodes.count > ARViewConstants.numArrowsDisplayedForward ?
                    ARViewConstants.numArrowsDisplayedForward :
                    arrowNodes.count
        var index = firstIndex
        while index <= count - 1 {
            range.append(index)
            index += 1
        }
        index = 0
        while index <= firstIndex - 1 {
            range.append(index)
            index += 1
        }
        return range
    }
    
    private func getRelativeIndexInOneIteration(startIndex: Int, actualIndex: Int, length: Int) -> Int {
        if actualIndex > startIndex {
            return actualIndex - startIndex
        } else {
            return actualIndex + length - startIndex
        }
    }
    
    /**
     stop the moving on animation of the arrows
     */
    private func stopAnimation() {
        let count = arrowNodes.count > ARViewConstants.numArrowsDisplayedForward ?
                    ARViewConstants.numArrowsDisplayedForward :
                    arrowNodes.count
        for i in 0 ..< count {
            arrowNodes[i].removeAction(forKey: ARViewConstants.arrowActionKey)
        }
        isAnimating = false
    }
}









