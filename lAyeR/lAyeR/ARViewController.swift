//
//  ARViewController.swift
//  lAyeR
//
//  Created by luoyuyang on 08/03/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//


import CoreMotion
import Foundation
import MapKit
import UIKit
import SceneKit

class ARViewController: UIViewController {

    var route: Route = Route("initial empty route")
    var controlRoute: Route = Route("the route formed by all the control points")
    var nextCheckpointIndex = 0
    var fov: Double!
    private let nearbyPOIsUpdatedNotificationName = NSNotification.Name(rawValue:
                                                                        Constant.nearbyPOIsUpdatedNotificationName)
    private let userLocationUpdatedNotificationName = NSNotification.Name(rawValue:
                                                                        Constant.userLocationUpdatedNotificationName)

    // for displaying checkpoint card and poi card
    var checkpointCardControllers: [CheckpointCardController] = [] {
        didSet {
            miniMapController.checkpointCardControllers = checkpointCardControllers
        }
    }
    private var currentPoiCardControllers: [PoiCardController] = []
    
    private lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(updateLoop))

    let motionManager = DeviceMotionManager.getInstance()
    let geoManager = GeoManager.getInstance()
    
    // for camera view
    let cameraViewController = CameraController()

    // Defined for view control
    let menuController = MenuViewController()
    let miniMapController = MiniMapViewController()
    var updateSuccessAlertController: BasicAlertController!
    var mainMenuButton: MenuButtonView!
    
    // Temporarily store the destination text on the poi card
    var cardDestination: String?
    
    // for displaying path with SceneKit
    let scnViewController = SCNViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(cameraViewController)
        cameraViewController.setupCameraView()
        
        monitorNearbyPOIsUpdate()
        monitorCurrentLocationUpdate()
        
        fov = Double(cameraViewController.captureDevice.activeFormat.videoFieldOfView) * M_PI / 180
        
        startObservingDeviceMotion()
        displayLastUpdatedPOIs()
        
        prepareMenu()
        prepareMiniMap()
        
        addChildViewController(scnViewController)
        scnViewController.setupScene()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// Prepares the minimap view
    private func prepareMiniMap() {
        miniMapController.prepareMiniMapView(inside: view)
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleMiniMapSize))
        miniMapController.view.addGestureRecognizer(tap)
    }
    
    func toggleMiniMapSize() {
        miniMapController.toggleMiniMapSize()
    }
    
    /// Monitors the update of the nearby Point of Interest
    private func monitorNearbyPOIsUpdate() {
        NotificationCenter.default.addObserver(forName: nearbyPOIsUpdatedNotificationName, object: nil, queue: nil, using: { [unowned self] _ in
            
            self.displayLastUpdatedPOIs()
        })
    }
    
    /// Monitors the update of the current user location
    private func monitorCurrentLocationUpdate() {
        NotificationCenter.default.addObserver(forName: userLocationUpdatedNotificationName, object: nil, queue: nil, using: { [unowned self] _ in
            
            let userPoint = self.geoManager.getLastUpdatedUserPoint()
            self.miniMapController.updateMiniMap(with: userPoint)
            self.updateCheckpointCardDisplay()
            self.scnViewController.updateArrowNodes()
        })
    }
    
    /// when detect user location changed, check whether should update the checkpoint card displayed
    func updateCheckpointCardDisplay() {
        updateNextCheckpointIndex()
        
        if nextCheckpointIndex > controlRoute.size - 1 {
            // arrive at the last checkpoint
            handleArrival()
        } else {
            displayCheckpointCards(nextCheckpointIndex: nextCheckpointIndex)
        }
    }
    
    private func updateNextCheckpointIndex() {
        for index in nextCheckpointIndex ..< nextCheckpointIndex + Constant.checkCloseRange {
            guard index >= 0 && index <= controlRoute.size - 1 else {
                continue
            }
            
            if doesArrive(at: controlRoute.checkPoints[index]) {
                // arrive at index
                // so the next checkpoint index should be index + 1
                nextCheckpointIndex = index + 1
                break
            }
        }
    }
    
    /// Check whether the user current location is close enough to the specified point 
    /// to be considered as arriving at that point
    private func doesArrive(at checkpoint: CheckPoint) -> Bool {
        let userPoint = geoManager.getLastUpdatedUserPoint()
        return GeoUtil.getCoordinateDistance(userPoint, checkpoint) < Constant.arrivalDistanceThreshold
    }
    
    /**
     Display the card of the checkpoint at the given index,
     as well as several previous checkpoints and several following checkpoints
     */
    private func displayCheckpointCards(nextCheckpointIndex: Int) {
        //checkpointCardControllers.removeAll()
        
        var newCheckpointCardControllers: [CheckpointCardController] = []
        let startIndex = nextCheckpointIndex - Constant.numCheckpointDisplayedBackward
        let endIndex = nextCheckpointIndex + Constant.numCheckpointDisplayedForward
        for i in startIndex ..< endIndex {
            guard i >= 0 && i <= controlRoute.size - 1 else {
                continue
            }
            let checkpoint = controlRoute.checkPoints[i]
            let cardController = createCheckpointCardController(of: checkpoint)
            if i == nextCheckpointIndex {
                cardController.setSelected(true)
            }
            newCheckpointCardControllers.append(cardController)
        }
        
        for controller in checkpointCardControllers {
            if !newCheckpointCardControllers.contains(where: {$0.checkpoint == controller.checkpoint}) {
                checkpointCardControllers.remove(at: checkpointCardControllers.index(where: {$0.checkpoint == controller.checkpoint})!)
            }
        }
        
        for controller in newCheckpointCardControllers {
            if !checkpointCardControllers.contains(where: {$0.checkpoint == controller.checkpoint}) {
                checkpointCardControllers.append(controller)
            }
        }
    }
    
    private func displayLastUpdatedPOIs() {
        let lastUpdatedPOIs = geoManager.getLastUpdatedNearbyPOIs()
        var newPOICardControllers: [PoiCardController] = []

        // keep the previous POI and corresponding card that also appears in the updated POI list
        // discard the obsolete POIs and remove corresponding card that does no appear in the updated list
        for poiCardController in currentPoiCardControllers {
            if lastUpdatedPOIs.contains(where: { $0.name == poiCardController.poiName }) {
                newPOICardControllers.append(poiCardController)
            }
        }
        
        // add the new POI and create corresponding card that appears in the updated list but not the previous list
        let group = DispatchGroup()
        for newPoi in lastUpdatedPOIs {
            if !newPOICardControllers.contains(where: { $0.poiName == newPoi.name }) {
                group.enter()
                let poiCard = PoiCard(center: self.view.center, distance: 0, type: newPoi.types.first!, superViewController: self)
                geoManager.getDetailedPOIInfo(newPoi) { poi in
                    if let name = poi.name { poiCard.setPoiName(name) }
                    if let address = poi.vicinity { poiCard.setPoiAddress(address) }
                    if let rating = poi.rating { poiCard.setPoiRating(rating) }
                    if let website = poi.website { poiCard.setPoiWebsite(website) }
                    if let contact = poi.contact { poiCard.setPoiContacet(contact) }
                    group.leave()
                }
                newPOICardControllers.append(PoiCardController(poi: newPoi, card: poiCard))
            }
        }
        
        currentPoiCardControllers = newPOICardControllers
    }
    
    /**
     After this method is called, the system will monitor the device motion,
     and update the view accordingly
     */
    private func startObservingDeviceMotion() {
        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
        displayLink.preferredFramesPerSecond = Constant.framePerSecond
    }
    
    @objc private func updateLoop() {
        let userPoint = geoManager.getLastUpdatedUserPoint()

        var count = 0
        for checkPointCardController in checkpointCardControllers {
            if count == 3 {  // TODO: put this constant into AppSettings
                break
            }
            checkPointCardController.updateCard(userPoint: userPoint, motionManager: motionManager,
                                                superView: view, fov: fov)
            count += 1
        }
        
        for poiCardController in currentPoiCardControllers {
            poiCardController.updateCard(userPoint: userPoint, motionManager: motionManager,
                                         superView: view, fov: fov)
        }
        
        scnViewController.updateSceneCameraOrientation()
    }
    
    private func createCheckpointCardController(of checkpoint: CheckPoint) -> CheckpointCardController {
        let checkpointCard = CheckpointCard(center: CGPoint(x: -100, y: -100),  // hide out of screen
                                            distance: 0, superViewController: self)
        checkpointCard.setCheckpointName(checkpoint.name)
        checkpointCard.setCheckpointDescription("Oops! This checkpoint has no specific description.")
        return CheckpointCardController(checkpoint: checkpoint, card: checkpointCard)
    }
    
    private func handleArrival() {
        // TODO: use this method to inform user arrival
    }
}






















