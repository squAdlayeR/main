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
    private var checkPointCards: [UIView] = []
    
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
    let arCalculator = ARCalculator()
    
    // setting constants
    let sampleCardWidth = 60
    let sampleCardHeight = 80
    let sampleCardAlpha: CGFloat = 0.48
    
    
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
        let sampleCard = UIView()
        sampleCard.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        sampleCard.bounds.size = CGSize(width: sampleCardWidth, height: sampleCardHeight)
        sampleCard.backgroundColor = UIColor.white
        sampleCard.alpha = sampleCardAlpha
        checkPointCards.append(sampleCard)
        for card in checkPointCards {
            view.addSubview(card)
        }
    }
    
    /**
        After this method is called, the system will monitor the device motion,
        and update the view accordingly
    */
    private func startObservingDeviceMotion() {
        if motionManager.isDeviceMotionAvailable && !motionManager.isDeviceMotionActive {
            motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: .main,
                                                   withHandler: { [unowned self] (data, error) in
                guard let data = data else {
                    return
                }
                let layoutAdjustment = self.arCalculator.calculateARLayoutAdjustment(motion: data, azimuth: 0, within: self.view)
                
                // update position and orientation of checkPointCards
                for checkPointCard in self.checkPointCards {
                    let deviceZAxisX = data.attitude.rotationMatrix.m31
                    checkPointCard.isHidden = deviceZAxisX > 0 ? true : false
                    
                    layoutAdjustment.apply(to: checkPointCard, within: self.view)
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
















