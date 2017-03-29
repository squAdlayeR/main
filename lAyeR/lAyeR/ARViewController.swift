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

class ARViewController: UIViewController {
    
    // setting constants
    let sampleCardWidth = 108
    let sampleCardHeight = 108
    let sampleCardAlpha: CGFloat = 0.48
    let framePerSecond = 60
    private let nearbyPOIsUpdatedNotificationName = NSNotification.Name(rawValue:
        Setting.nearbyPOIsUpdatedNotificationName)
    
    // for displaying camera view
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var cameraViewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    let session = AVCaptureSession()
    var currentFrame: CIImage!
    var done = false
    
    var cameraView: UIView!
    var checkpointCardPairs: [(CheckPoint, CheckpointViewController)] = []
    private var currentPoiCardPairs: [(POI, PoiViewController)] = []
    
    private lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(updateLoop))

    let motionManager = DeviceMotionManager.getInstance()
    let geoManager = GeoManager.getInstance()

    let menuController = MenuViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCameraView()
        addCheckPointCards()
        setupAVCapture()
        monitorNearbyPOIsUpdate()
        startObservingDeviceMotion()
        displayLastUpdatedPOIs()
        prepareMenu()
    }
    
    private func addCameraView() {
        cameraView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        cameraView.contentMode = .scaleAspectFit
        view.insertSubview(cameraView, at: 0)
    }
    
    private func addCheckPointCards() {
        // FOR TESTING PURPOSE

        let sampleCard = CheckpointViewController(center: view.center, distance: 0, superView: view)
        sampleCard.setCheckpointName("Prince Geroges' Park Residences")
        sampleCard.setCheckpointDescription("Prince George's Park Residences. One of the most famous residences in NUS, it is usually a place for foreign students to live. Most Chinese studenting are living here. This is the destination.")
        checkpointCardPairs.append((CheckPoint(1.2909, 103.7813, "PGP Residence"), sampleCard))
        // can set blur mode using below code
        sampleCard.setBlurEffect(true)
    }
    
    private func monitorNearbyPOIsUpdate() {
        NotificationCenter.default.addObserver(forName: nearbyPOIsUpdatedNotificationName, object: nil, queue: nil,
                                               using: { [unowned self] _ in
            self.displayLastUpdatedPOIs()
        })
    }
    
    private func displayLastUpdatedPOIs() {
        let lastUpdatedPOIs = geoManager.getLastUpdatedNearbyPOIs()
        var newPOICardPairs: [(POI, PoiViewController)] = []

        for poiCardPair in currentPoiCardPairs {
            let previousPoi = poiCardPair.0
            let poiCard = poiCardPair.1
            if lastUpdatedPOIs.contains(where: { $0.name == previousPoi.name }) {
                newPOICardPairs.append(poiCardPair)
            } else {
                poiCard.removeFromSuperview()
            }
        }
        
        for newPoi in lastUpdatedPOIs {
            if !newPOICardPairs.contains(where: { $0.0.name == newPoi.name }) {
                guard let name = newPoi.name else {
                    break
                }
                let poiCard = PoiViewController(center: view.center, distance: 0, type: "library", superView: view)
                poiCard.setPoiName(name)
                poiCard.setPoiDescription("To be specified...")
                poiCard.setPoiAddress(newPoi.vicinity!)
                newPOICardPairs.append((newPoi, poiCard))
            }
        }
        
        currentPoiCardPairs = newPOICardPairs
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

        // update position and orientation of checkPointCards
        for (checkPoint, checkPointCard) in self.checkpointCardPairs {
            let azimuth = GeoUtil.getAzimuth(between: userPoint, checkPoint)
            let distance = GeoUtil.getCoordinateDistance(userPoint, checkPoint)
            
            let layoutAdjustment = ARViewLayoutAdjustment(deviceMotionManager: motionManager,
                                                          distance: distance, azimuth: azimuth, superView: self.view)
            checkPointCard.applyViewAdjustment(layoutAdjustment)
            checkPointCard.update(distance)
        }
        
        // update position and orientation of poiCards
        for (poi, poiCard) in self.currentPoiCardPairs {
            let azimuth = GeoUtil.getAzimuth(between: userPoint, poi)
            let distance = GeoUtil.getCoordinateDistance(userPoint, poi)
            
            let layoutAdjustment = ARViewLayoutAdjustment(deviceMotionManager: motionManager,
                                                          distance: distance, azimuth: azimuth, superView: self.view)
            poiCard.applyViewAdjustment(layoutAdjustment)
            poiCard.update(distance)
        }
    }  
}








