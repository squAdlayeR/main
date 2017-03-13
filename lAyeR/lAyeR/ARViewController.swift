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
    private var checkPointCards: [(CheckPoint, CheckpointView)] = []
    
    // for displaying camera view
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var cameraViewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    let session = AVCaptureSession()
    var currentFrame: CIImage!
    var done = false
    
    // for AR effect
    let motionManager = CMMotionManager()
    
    // setting constants
    let sampleCardWidth = 108
    let sampleCardHeight = 108
    let sampleCardAlpha: CGFloat = 0.48
    
    
    // for testing get current location
//    let locationManager: CLLocationManager = CLLocationManager()
//    var mapViewDelegate: MapViewDelegate = MapViewDelegate()
    let locationManager = LocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCameraView()
        addCheckPointCards()
        setupAVCapture()
        
        // for getting the current location
//        locationManager.delegate = mapViewDelegate
//        locationManager.requestAlwaysAuthorization()
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.startUpdatingLocation()
        
        
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
        
//        let sampleCard = UIView()
//        sampleCard.bounds.size = CGSize(width: sampleCardWidth, height: sampleCardHeight)
//        sampleCard.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
//        sampleCard.backgroundColor = UIColor.orange
//        sampleCard.alpha = sampleCardAlpha
        let size = CGSize(width: suggestedPopupWidth, height: suggestedPopupHeight)
        let origin = CGPoint(x: (view.bounds.width - size.width) / 2,
                             y: (view.bounds.height - size.height) / 2)
        let frame = CGRect(origin: origin, size: size)
        let sampleCard = CheckpointView(frame: frame, name: "PGP", distance: 0)
        checkPointCards.append((CheckPoint(1.2909, 103.7813, "PGP", 4), sampleCard))
        
//        let sampleCard2 = UIView()
//        sampleCard2.bounds.size = CGSize(width: sampleCardWidth, height: sampleCardHeight)
//        sampleCard2.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
//        sampleCard2.backgroundColor = UIColor.blue
//        sampleCard2.alpha = sampleCardAlpha
        let sampleCard2 = CheckpointView(frame: frame, name: "CP2", distance: 0)
        checkPointCards.append((CheckPoint(1.2923, 103.7799, "CP2", 3), sampleCard2))
        
//        let sampleCard3 = UIView()
//        sampleCard3.bounds.size = CGSize(width: sampleCardWidth, height: sampleCardHeight)
//        sampleCard3.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
//        sampleCard3.backgroundColor = UIColor.yellow
//        sampleCard3.alpha = sampleCardAlpha
        let sampleCard3 = CheckpointView(frame: frame, name: "CP1", distance: 0)
        checkPointCards.append((CheckPoint(1.2937, 103.7769, "CP1", 2), sampleCard3))
        
//        let sampleCard4 = UIView()
//        sampleCard4.bounds.size = CGSize(width: sampleCardWidth, height: sampleCardHeight)
//        sampleCard4.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
//        sampleCard4.backgroundColor = UIColor.green
//        sampleCard4.alpha = sampleCardAlpha
        let sampleCard4 = CheckpointView(frame: frame, name: "Biz link", distance: 0)
        checkPointCards.append((CheckPoint(1.2936, 103.7753, "Biz link", 1), sampleCard4))
        
        for (_, card) in checkPointCards {
            view.addSubview(card)
        }
    }
    
    /**
     After this method is called, the system will monitor the device motion,
     and update the view accordingly
     */
    private func startObservingDeviceMotion() {
        if motionManager.isDeviceMotionAvailable && !motionManager.isDeviceMotionActive {
            motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: .main, withHandler: { [unowned self] (data, error) in
                guard let data = data else {
                    return
                }

                // update position and orientation of checkPointCards
                for (checkPoint, checkPointCard) in self.checkPointCards {
                    let userPoint = self.locationManager.getUserPoint()
                    let azimuth = GeoUtil.getAzimuth(between: userPoint, checkPoint)
                    let arCalculator = ARCalculator(motion: data, azimuth: azimuth, superView: self.view)
                    let layoutAdjustment = arCalculator.calculateARLayoutAdjustment()
                    
                    let horzAngle = arCalculator.calculateHorzAngle()
                    var isOutOfView = false
                    if horzAngle > M_PI / 2 || horzAngle < -M_PI / 2 {
                        isOutOfView = true
                    }
                    checkPointCard.isHidden = isOutOfView
                    layoutAdjustment.apply(to: checkPointCard, within: self.view)
                    
                    let distance = GeoUtil.getCoordinateDistance(userPoint, checkPoint)
                    checkPointCard.marker.setDistance(CGFloat(distance))
                }
            })
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
















