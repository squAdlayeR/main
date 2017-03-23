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
    var cameraView: UIView!
    var checkpointCardPairs: [(CheckPoint, CheckpointViewController)] = []
    private var currentPoiCardPairs: [(POI, CheckpointViewController)] = []
    
    private lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(updateLoop))
    
    // for displaying camera view
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var cameraViewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    let session = AVCaptureSession()
    var currentFrame: CIImage!
    var done = false
    
    // for AR effect
    let motionManager = DeviceMotionManager.getInstance()
    
    // for testing get current location
    let geoManager = GeoManager.getInstance()
    
    // setting constants
    let sampleCardWidth = 108
    let sampleCardHeight = 108
    let sampleCardAlpha: CGFloat = 0.48
    let framePerSecond = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCameraView()
        addCheckPointCards()
        setupAVCapture()
        startObservingDeviceMotion()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !done {
            session.startRunning()
        }
    }
    
    private func addCameraView() {
        cameraView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        cameraView.contentMode = .scaleAspectFit
        view.insertSubview(cameraView, at: 0)
    }
    
    private func addCheckPointCards() {
        // FOR TESTING PURPOSE
        
        let sampleCard = CheckpointViewController(center: view.center, name: "PGP", distance: 0, superView: view)
        checkpointCardPairs.append((CheckPoint(1.2909, 103.7813, "PGP"), sampleCard))
        
        let sampleCard2 = CheckpointViewController(center: view.center, name: "CP2", distance: 0, superView: view)
        checkpointCardPairs.append((CheckPoint(1.2923, 103.7799, "CP2"), sampleCard2))
        
        let sampleCard3 = CheckpointViewController(center: view.center, name: "CP1", distance: 0, superView: view)
        checkpointCardPairs.append((CheckPoint(1.2937, 103.7769, "CP1"), sampleCard3))
        
        let sampleCard4 = CheckpointViewController(center: view.center, name: "Biz link", distance: 0, superView: view)
        checkpointCardPairs.append((CheckPoint(1.2936, 103.7753, "Biz link"), sampleCard4))
    }
    
    private func updatePOI() {
        // update poi card list when the change of the user location exceed the threshod
        guard let pois = geoManager.getUpdatedNearbyPOIs() else {
            return
        }

        var newPOICardPairs: [(POI, CheckpointViewController)] = []

        for poiCardPair in currentPoiCardPairs {
            let previousPoi = poiCardPair.0
            let poiCard = poiCardPair.1
            if pois.contains(where: { $0.name == previousPoi.name }) {
                newPOICardPairs.append(poiCardPair)
            } else {
                poiCard.removeFromSuperview()
            }
        }
        
        for newPoi in pois {
            if !newPOICardPairs.contains(where: { $0.0.name == newPoi.name }) {
                guard let name = newPoi.name else {
                    break
                }
                let poiCard = CheckpointViewController(center: view.center, name: name, distance: 0, superView: view)
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
        updatePOI()
        let userPoint = geoManager.getUserPoint()

        // update position and orientation of checkPointCards
        for (checkPoint, checkPointCard) in self.checkpointCardPairs {
            let azimuth = GeoUtil.getAzimuth(between: userPoint, checkPoint)
            let distance = GeoUtil.getCoordinateDistance(userPoint, checkPoint)
            
            let layoutAdjustment = ARViewLayoutAdjustment(deviceMotionManager: motionManager, azimuth: azimuth, superView: self.view)
            checkPointCard.applyViewAdjustment(layoutAdjustment)
            checkPointCard.update(distance)
        }
        
        // update position and orientation of poiCards
        for (poi, poiCard) in self.currentPoiCardPairs {
            let azimuth = GeoUtil.getAzimuth(between: userPoint, poi)
            let distance = GeoUtil.getCoordinateDistance(userPoint, poi)
            
            let layoutAdjustment = ARViewLayoutAdjustment(deviceMotionManager: motionManager, azimuth: azimuth, superView: self.view)
            poiCard.applyViewAdjustment(layoutAdjustment)
            poiCard.update(distance)
        }
    }
}















