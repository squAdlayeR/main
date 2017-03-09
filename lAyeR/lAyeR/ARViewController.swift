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
            motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: .main, withHandler: { [unowned self] (data, error) in
                guard let rotationMatrix = data?.attitude.rotationMatrix else {
                    return
                }
                let rollSin = rotationMatrix.m32
                let pitchSin = rotationMatrix.m33

                let m31 = rotationMatrix.m31
                let m32 = rotationMatrix.m32
                let m33 = rotationMatrix.m33
                let m21 = rotationMatrix.m21
                let m22 = rotationMatrix.m22
                let m23 = rotationMatrix.m23
                
                // STEP 0. calculate "pure" yaw angle
                let deviceY = Vector3D(x: m21, y: m22, z: m23)
                
                // the horizontal vector perpendicular to the z-axis vector of the device
                let horzVectorPerpToDeviceZ = Vector3D(x: -m32, y: m31, z: 0)
                
                // the normal vector of the surface spanned by the following 2 vectors:
                // 1. the z-axis vector of the device
                // 2. horzVectorPerpToDeviceZ
                let normalVector = Vector3D(x: (m33 * m31) / (m32 * m32 + m31 * m31),
                                            y: (m33 * m32) / (m32 * m32 + m31 * m31),
                                            z: -1)
                
                let cos = -deviceY.projectionLength(on: normalVector) / deviceY.length
                var sin = sqrt(1 - cos * cos)
                if deviceY * horzVectorPerpToDeviceZ < 0 {
                    sin = -sin
                }
                
                let yawAngle = atan2(sin, cos)
                
                // update position and orientation of checkPointCards
                for checkPointCard in self.checkPointCards {
                    checkPointCard.isHidden = m31 > 0 ? true : false
                    
                    // STEP 1. update orientation
                    checkPointCard.transform = CGAffineTransform(rotationAngle: CGFloat(-yawAngle))
                    
                    
                    // STEP 2. update position
                    let superViewWidth = self.view.bounds.width
                    let superViewHeight = self.view.bounds.height
                    let visionWidth = superViewWidth * CGFloat(abs(cos)) + superViewHeight * CGFloat(abs(sin))
                    let visionHeight = superViewWidth * CGFloat(abs(sin)) + superViewHeight * CGFloat(abs(cos))
                    // positive x direction is rigth
                    let horzOffset = -CGFloat(rollSin) * visionWidth
                    // positive y direction is down
                    let verticalOffset = CGFloat(pitchSin) * visionHeight
                    
                    let xOffset = CGFloat(horzOffset) * CGFloat(cos) - CGFloat(verticalOffset) * CGFloat(sin)
                    let yOffset = CGFloat(verticalOffset) * CGFloat(cos) + CGFloat(horzOffset) * CGFloat(sin)
                    
                    checkPointCard.center.x = (self.view.bounds.width - checkPointCard.frame.height) / 2 + xOffset
                    checkPointCard.center.y = (self.view.bounds.height - checkPointCard.frame.width) / 2 - yOffset
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
















