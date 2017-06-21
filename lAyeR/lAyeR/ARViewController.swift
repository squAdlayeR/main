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


enum Mode {
    // in navigation mode, checkpoint card and path arrow will be shown
    case navigation
    // in explore mode, point of interest card will be shown
    case explore
}


class ARViewController: UIViewController {

    private var mode: Mode = .explore
    var route: Route = Route("initial empty route") {
        didSet {
            miniMapController.setRoute(with: route)
        }
    }
    var controlRoute: Route = Route("the route formed by all the control points")
    var nextCheckpointIndex = 0
    var fov: Double!
    private let nearbyPOIsUpdatedNotificationName = NSNotification.Name(rawValue:
                                                                        ARViewConstants.nearbyPOIsUpdatedNotificationName)
    private let userLocationUpdatedNotificationName = NSNotification.Name(rawValue:
                                                                        ARViewConstants.userLocationUpdatedNotificationName)

    // for displaying checkpoint card and poi card
    internal var checkpointCardControllers: [CheckpointCardController] = []
    internal var currentPoiCardControllers: [PoiCardController] = []
    
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
        
        
        fov = Double(cameraViewController.captureDevice.activeFormat.videoFieldOfView) * Double.pi / 180
        
        startObservingDeviceMotion()
        displayLastUpdatedPOIs()
        
        prepareMenu()
        prepareMiniMap()
        
        addChildViewController(scnViewController)
        scnViewController.setupScene()
        
        geoManager.forceUpdateUserNearbyPOIS()
        GPSTracker.instance.start()
    }
    
    
    func setMode(to mode: Mode) {
        self.mode = mode
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
            
            if self.mode == .explore {
                self.displayLastUpdatedPOIs()
            }
        })
    }
    
    /// Monitors the update of the current user location
    private func monitorCurrentLocationUpdate() {
        NotificationCenter.default.addObserver(self, selector: #selector(observeUserLocationChange(_:)),
                                               name: userLocationUpdatedNotificationName, object: nil)
    }
    
    func observeUserLocationChange(_ notification: NSNotification) {
        if let currentLocation = notification.object as? GeoPoint {
            miniMapController.updateMiniMap(with: currentLocation)
            if mode == .navigation {
                updateCheckpointCardDisplay()
                scnViewController.updateArrowNodes()
            }
        }
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
    
    /**
     called when the change of user location is detected.
     It checks whether the user is close enough to the next checkpoint
     if so, the user is considered to reach the next checkpoint 
     and the index of the next checkpoint is increased by one
     */
    private func updateNextCheckpointIndex() {
        for index in nextCheckpointIndex ..< nextCheckpointIndex + ARViewConstants.checkCloseRange {
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
    
    /**
     Check whether the user current location is close enough to the specified point
     to be considered as arriving at that point
     */
    private func doesArrive(at controlPoint: CheckPoint) -> Bool {
        let userPoint = geoManager.getLastUpdatedUserPoint()
        return GeoUtil.getCoordinateDistance(userPoint, controlPoint) < ARViewConstants.arrivalDistanceThreshold
    }
    
    
    /**
     Display the card of the checkpoint at the given index,
     as well as several previous checkpoints and several following checkpoints
     */
    private func displayCheckpointCards(nextCheckpointIndex: Int) {
        
        let newCheckpointCardControllers = getCheckpointsToDisplay(withNextCheckpointAt: nextCheckpointIndex)

        // remove the obsolete checkpoint controllers
        for controller in checkpointCardControllers {
            if !newCheckpointCardControllers.contains(where: {$0.checkpoint == controller.checkpoint}) {
                checkpointCardControllers.remove(at: checkpointCardControllers.index(where: {$0.checkpoint == controller.checkpoint})!)
            }
        }
        
        // add the new checkpoint controllers
        for controller in newCheckpointCardControllers {
            if !checkpointCardControllers.contains(where: {$0.checkpoint == controller.checkpoint}) {
                checkpointCardControllers.append(controller)
            }
        }
    }
    
    private func getCheckpointsToDisplay(withNextCheckpointAt nextCheckpointIndex: Int) -> [CheckpointCardController] {
        var newCheckpointCardControllers: [CheckpointCardController] = []
        let startIndex = nextCheckpointIndex - ARViewConstants.numCheckpointDisplayedBackward
        let endIndex = nextCheckpointIndex + ARViewConstants.numCheckpointDisplayedForward
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
        return newCheckpointCardControllers
    }
    
    
    /// Gets the updated POI groups grouped by azimuth. Called on location update.
    ///
    /// - Returns: Array groups (arrays) of sorted POIs
    private func getUpdatedPOIGroupsByAzimuth() -> [[POI]] {
        let userPoint = geoManager.getLastUpdatedUserPoint()
        var sortedAzimuthPOITuples = geoManager.getLastUpdatedNearbyPOIs()
                                               .map {(GeoUtil.getAzimuth(between: userPoint, $0), $0)}
                                               .sorted {$0.0.0 > $0.1.0}
        var groups: [[POI]] = []
        let halfAngle = ARViewConstants.clusteringAngle * 0.5
        while !sortedAzimuthPOITuples.isEmpty {
            let centerTuple = sortedAzimuthPOITuples.removeFirst()
            var newGroup = [centerTuple.1]
            while let leftTuple = sortedAzimuthPOITuples.last {
                if (leftTuple.0 + 2 * .pi - centerTuple.0) < halfAngle {
                    newGroup.append(sortedAzimuthPOITuples.removeLast().1)
                }
            }
            while let rightTuple = sortedAzimuthPOITuples.first {
                if (centerTuple.0 - rightTuple.0 + 2 * .pi) < halfAngle {
                    newGroup.append(sortedAzimuthPOITuples.removeFirst().1)
                }
            }
            groups.append(newGroup)
        }
        return groups
    }
    
    
    /// update the cards of points of interest to be displayed
    /// remove the obsolete cards (in the current list but not in the new list)
    /// keep the cards that in both the current list and new list
    /// add in the cards that are in the new list but not in the current list
    private func displayLastUpdatedPOIs() {
//        let sortedPOIs = getUpdatedPOIGroupsByAzimuth()
//        var newPOICardControllers: [PoiCardController] = []
//
//        // keep the previous POI and corresponding card that also appears in the updated POI list
//        // discard the obsolete POIs and remove corresponding card that does no appear in the updated list
//        for poiCardController in currentPoiCardControllers {
//            if sortedPOIs.contains(where: { $0.name == poiCardController.poiName }) {
//                newPOICardControllers.append(poiCardController)
//            }
//        }
//        
//        // add the new POI and create corresponding card that appears in the updated list but not the previous list
//        let group = DispatchGroup()
//        for newPoi in sortedPOIs {
//            if !newPOICardControllers.contains(where: { $0.poiName == newPoi.name }) {
//                let poiCard = PoiCard(distance: 0, categoryName: newPoi.types.first!, superViewController: self)
//                guard let placeID = newPoi.placeID else { continue }
//                group.enter()
//                geoManager.getDetailedPOIInfo(placeID) { poi in
//                    if let poi = poi {
//                        if let name = poi.name { poiCard.setPoiName(name) }
//                        if let address = poi.vicinity { poiCard.setPoiAddress(address) }
//                        if let rating = poi.rating { poiCard.setPoiRating(rating) }
//                        if let website = poi.website { poiCard.setPoiWebsite(website) }
//                        if let contact = poi.contact { poiCard.setPoiContact(contact) }
//                    }
//                    group.leave()
//                }
//                newPOICardControllers.append(PoiCardController(poi: newPoi, card: poiCard))
//            }
//        }
//        
//        currentPoiCardControllers = newPOICardControllers
    }
    
    /**
     After this method is called, the system will monitor the device motion,
     and update the view accordingly
     */
    private func startObservingDeviceMotion() {
        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
        displayLink.preferredFramesPerSecond = ARViewConstants.framePerSecond
    }
    
    /**
     the main loop, it does the following every frame (currently set as 1/60 second)
     - update the display of Point of Interest cards
     - update the display of checkpoint cards
     - udpate the display of the path arrows
     these updates are based on the user location and device motion at that moment
     */
    @objc private func updateLoop() {
        let userPoint = geoManager.getLastUpdatedUserPoint()

        switch mode {
        case .navigation:
            for checkPointCardController in checkpointCardControllers {
                checkPointCardController.updateCard(userPoint: userPoint, motionManager: motionManager,
                                                    superView: view, fov: fov)
            }
        case .explore:
            for poiCardController in currentPoiCardControllers {
                poiCardController.updateComponents(userPoint: userPoint, superView: view, fov: fov)
            }
        }
        
        scnViewController.updateSceneCamera()
    }
    
    /**
     return a checkpoint card controller according to the input checkpoint
     */
    private func createCheckpointCardController(of checkpoint: CheckPoint) -> CheckpointCardController {
        let checkpointCard = CheckpointCard(distance: 0, superViewController: self)
        checkpointCard.setCheckpointName(checkpoint.name)
        let sanitizedDescription = checkpoint.description == "" ? "Oops! This checkpoint has no specific description." : checkpoint.description
        checkpointCard.setCheckpointDescription(sanitizedDescription)
        return CheckpointCardController(checkpoint: checkpoint, card: checkpointCard)
    }
    
    /**
     After the user reaches the destination,
     change back to the explore mode (display nearby POIs)
     */
    private func handleArrival() {
        scnViewController.removeAllArrows()
        checkpointCardControllers.removeAll()
        miniMapController.mapView.clear()
        geoManager.forceUpdateUserPoint()
        geoManager.forceUpdateUserNearbyPOIS()
        setMode(to: .explore)
    }
}






















