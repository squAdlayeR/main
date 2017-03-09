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
    
    // for ar effect
    let motionManager = CMMotionManager()
    
    // setting constants
    let sampleCardWidth = 60
    let sampleCardHeight = 80
    let sampleCardAlpha: CGFloat = 0.38
    
    
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
    
    private func startObservingDeviceMotion() {
        if motionManager.isDeviceMotionAvailable && !motionManager.isDeviceMotionActive {
            motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: .main, withHandler: { [unowned self] (data, error) in
                guard let data = data else {
                    return
                }
                let rollSin = data.attitude.rotationMatrix.m32
                let pitchSin = data.attitude.rotationMatrix.m33
                
                // update position and orientation of checkPointCards
                for checkPointCard in self.checkPointCards {
                    checkPointCard.isHidden = data.attitude.rotationMatrix.m31 > 0 ? true : false
                    
                    // update position
                    let cardHeight = checkPointCard.frame.height
                    let cardWidth = checkPointCard.frame.width
                    
                    // positive x direction is rigth
                    let xOffset = -CGFloat(rollSin) * self.view.bounds.width
                    // positive y direction is down
                    let yOffset = CGFloat(pitchSin) * self.view.bounds.height

                    // update orientation

                    let x = data.attitude.rotationMatrix.m31
                    let y = data.attitude.rotationMatrix.m32
                    let z = data.attitude.rotationMatrix.m33
                    let m21 = data.attitude.rotationMatrix.m21
                    let m22 = data.attitude.rotationMatrix.m22
                    let m23 = data.attitude.rotationMatrix.m23
                    let m11 = data.attitude.rotationMatrix.m11
                    let m12 = data.attitude.rotationMatrix.m12
                    let m13 = data.attitude.rotationMatrix.m13
                    
                    let vz = [x, y, z]
                    let vy = [m21, m22, m23]
                    let vx = [m11, m12, m13]
                    var horiz = [-y, x, 0]
//                    if (vx[0]*horiz[0] + vx[1]*horiz[1] + vx[2]*horiz[2]) < 0 {
//                        horiz = [-y, x, 0]
//                    }
                    let norm = [(z*x)/(y*y+x*x), (z*y)/(y*y+x*x), -1]
                    let proj = (vy[0]*norm[0] + vy[1]*norm[1] + vy[2]*norm[2]) / sqrt(norm[0]*norm[0] + norm[1]*norm[1] + norm[2]*norm[2])
                    let cos = -proj / sqrt(vy[0]*vy[0] + vy[1]*vy[1] + vy[2]*vy[2])
                    var sin = sqrt(1 - cos * cos)
                    if (vy[0]*horiz[0] + vy[1]*horiz[1] + vy[2]*horiz[2]) < 0 {
                        sin = -sin
                    }
                    
                    let angle = atan2(sin, cos)
                    let xoff = CGFloat(xOffset) * CGFloat(cos) - CGFloat(yOffset) * CGFloat(sin)
                    let yoff = CGFloat(yOffset) * CGFloat(cos) + CGFloat(xOffset) * CGFloat(sin)
                    checkPointCard.transform = CGAffineTransform(rotationAngle: CGFloat(-angle))
                    
//                    print(xOffset);print(yOffset);print()
//                    print(angle)
//                    print(cos)
                    
                    checkPointCard.center.x = (self.view.bounds.width - cardWidth) / 2 + xoff
                    checkPointCard.center.y = (self.view.bounds.height - cardHeight) / 2 - yoff
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
















