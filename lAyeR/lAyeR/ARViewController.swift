//
//  ARViewController.swift
//  lAyeR
//
//  Created by luoyuyang on 08/03/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import AVFoundation
import CoreMotion
import Foundation
import MapKit
import UIKit
import SceneKit

class ARViewController: UIViewController {
    
    // setting constants
    let framePerSecond = 60
    var fov: Double!
    private let nearbyPOIsUpdatedNotificationName = NSNotification.Name(rawValue:
                                                                    Constant.nearbyPOIsUpdatedNotificationName)
    // Defines the notification name for user location update
    private let userLocationUpdatedNotificationName = NSNotification.Name(rawValue:
                                                                        Constant.userLocationUpdatedNotificationName)
    // for displaying camera view
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var cameraViewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    let session = AVCaptureSession()
    var currentFrame: CIImage!
    var done = false
    
    var cameraView: UIView!
    var checkpointCardControllers: [CheckpointCardController] = [] {
        didSet {
            miniMapController.checkpointCardControllers = checkpointCardControllers
        }
    }
    private var currentPoiCardControllers: [PoiCardController] = []
    
    private lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(updateLoop))

    let motionManager = DeviceMotionManager.getInstance()
    let geoManager = GeoManager.getInstance()

    // Defined for view control
    let menuController = MenuViewController()
    let miniMapController = MiniMapViewController()
    var updateSuccessAlertController: BasicAlertController!
    var mainMenuButton: MenuButtonView!
    
    // Temporarily store the destination text on the poi card
    var cardDestination: String?
    
    // for displaying path with SceneKit
    let cameraNode = SCNNode()
    let scene = SCNScene()
    var scnView: SCNView!
    var arrowNodes: [SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCameraView()
        setupAVCapture()
        fov = Double(captureDevice.activeFormat.videoFieldOfView) * Double.pi / 180
        monitorNearbyPOIsUpdate()
        monitorCurrentLocationUpdate()
        fov = Double(captureDevice.activeFormat.videoFieldOfView) * M_PI / 180
        startObservingDeviceMotion()
        displayLastUpdatedPOIs()
        
        prepareMenu()
        prepareMiniMap()
        prepareScene()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func addCameraView() {
        cameraView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        cameraView.contentMode = .scaleAspectFit
        view.insertSubview(cameraView, at: 0)
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
    
    private func monitorNearbyPOIsUpdate() {
        NotificationCenter.default.addObserver(forName: nearbyPOIsUpdatedNotificationName, object: nil, queue: nil,
                                               using: { [unowned self] _ in
            self.displayLastUpdatedPOIs()
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
        displayLink.preferredFramesPerSecond = framePerSecond
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
        
        updateScene()
    }
    
    @IBAction func unwindSegueToARView(segue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "arToDesignerImport" {
            if let url = sender as? URL, let dest = segue.destination as? RouteDesignerViewController {
                dest.importedURL = url
            }
            return
        }
        if segue.identifier == segueToDirectName {
            guard let dest = segue.destination as? RouteDesignerViewController else { return }
            if let destName = cardDestination {
                let currentUserPoint = geoManager.getLastUpdatedUserPoint()
                dest.myLocation = CLLocation(latitude: currentUserPoint.latitude, longitude: currentUserPoint.longitude)
                dest.searchBar.text = destName
                dest.getDirections(origin: "\(currentUserPoint.latitude) \(currentUserPoint.longitude)",
                    destination: destName,
                    waypoints: nil,
                    removeAllPoints: true,
                    at: 0,
                    completion: dest.getGpsRoutesUponCompletionOfGoogle(result:))
            }
        }
    }
    
}














