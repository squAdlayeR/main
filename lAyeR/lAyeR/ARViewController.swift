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
    private var checkPointCards: [(CheckPoint, CheckpointViewController)] = []
    private var poiCards: [(POI, CheckpointViewController)] = []
    
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
        view.addSubview(cameraView)
    }
    
    private func addCheckPointCards() {
        // FOR TESTING PURPOSE
        
        let sampleCard = CheckpointViewController(center: view.center, name: "PGP", distance: 0, superView: view)
        checkPointCards.append((CheckPoint(1.2909, 103.7813, "PGP", 4), sampleCard))
        
        let sampleCard2 = CheckpointViewController(center: view.center, name: "CP2", distance: 0, superView: view)
        checkPointCards.append((CheckPoint(1.2923, 103.7799, "CP2", 3), sampleCard2))
        
        let sampleCard3 = CheckpointViewController(center: view.center, name: "CP1", distance: 0, superView: view)
        checkPointCards.append((CheckPoint(1.2937, 103.7769, "CP1", 2), sampleCard3))
        
        let sampleCard4 = CheckpointViewController(center: view.center, name: "Biz link", distance: 0, superView: view)
        checkPointCards.append((CheckPoint(1.2936, 103.7753, "Biz link", 1), sampleCard4))
    }
    
    private func updatePOI() {
        // update poi card list when the change of the user location exceed the threshod
        guard let pois = geoManager.getUpdatedNearbyPOIs() else {
            return
        }
        
        for (_, poiCard) in poiCards {
            poiCard.removeFromSuperview()
        }
        poiCards.removeAll()
        
        for poi in pois {
            guard let name = poi.name else {
                break
            }
            let poiCard = CheckpointViewController(center: view.center, name: name, distance: 0, superView: view)
            poiCards.append((poi, poiCard))
        }
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
        for (checkPoint, checkPointCard) in self.checkPointCards {
            let azimuth = GeoUtil.getAzimuth(between: userPoint, checkPoint)
            let distance = GeoUtil.getCoordinateDistance(userPoint, checkPoint)
            
            let layoutAdjustment = ARViewLayoutAdjustment(deviceMotionManager: motionManager, azimuth: azimuth, superView: self.view)
            checkPointCard.applyViewAdjustment(layoutAdjustment)
            checkPointCard.update(distance)
        }
        
        // update position and orientation of poiCards
        for (poi, poiCard) in self.poiCards {
            let azimuth = GeoUtil.getAzimuth(between: userPoint, poi)
            let distance = GeoUtil.getCoordinateDistance(userPoint, poi)
            
            let layoutAdjustment = ARViewLayoutAdjustment(deviceMotionManager: motionManager, azimuth: azimuth, superView: self.view)
            poiCard.applyViewAdjustment(layoutAdjustment)
            poiCard.update(distance)
        }
    }
}


extension ARViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func setupAVCapture() {
        session.sessionPreset = AVCaptureSessionPreset640x480
        guard let device = AVCaptureDevice
            .defaultDevice(withDeviceType: .builtInWideAngleCamera,
                           mediaType: AVMediaTypeVideo,
                           position: .back) else{
                            return
        }
        captureDevice = device
        beginSession()
        done = true
    }
    
    func beginSession() {
        var deviceInput: AVCaptureDeviceInput?
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error {
            deviceInput = nil
            print("error: \(error.localizedDescription)")
        }
        if self.session.canAddInput(deviceInput) {
            self.session.addInput(deviceInput)
        }
        
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        videoDataOutput.connection(withMediaType: AVMediaTypeVideo).isEnabled = true
        
        cameraViewLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraViewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        
        let rootLayer = cameraView.layer
        rootLayer.masksToBounds = true
        cameraViewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(cameraViewLayer)
        session.startRunning()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        currentFrame = convertImageFromCMSampleBufferRef(sampleBuffer)
    }
    
    // clean up AVCapture
    func stopCamera(){
        session.stopRunning()
        done = false
    }
    
    func convertImageFromCMSampleBufferRef(_ sampleBuffer:CMSampleBuffer) -> CIImage {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        return ciImage
    }
}
















