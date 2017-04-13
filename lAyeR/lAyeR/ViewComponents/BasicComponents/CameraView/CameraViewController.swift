//
//  CameraViewController.swift
//  ViewComponentTesting
//
//  Created by Yang Zhuohan on 29/3/17.
//  Copyright © 2017 Yang Zhuohan. All rights reserved.
//

import UIKit
import AVFoundation

/**
 A class that is used to set up camera view. To use this controller,
 you can simply 
 1. initialize a new controller in your `viewDidLoad` function
 2. set a suitable frame for camera display
 3. add the view of this controller to your super view.
 */
class CameraViewController: UIViewController {

    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var cameraViewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    let session = AVCaptureSession()
    var currentFrame: CIImage!
    var done = false
    
    // Defines the camera view
    var cameraView: UIView!
    
    /// Overrieds view did load so that when the view is
    /// loaded, the camera will be set up
    override func viewDidLoad() {
        super.viewDidLoad()
        addCameraView()
        setupAVCapture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Adds the camera view to the view of this controller
    private func addCameraView() {
        cameraView = UIView(frame: view.bounds)
        cameraView.contentMode = .scaleAspectFill
        view.addSubview(cameraView)
    }

}

/**
 An extension that is used to define / preprocess the camera view
 */
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
 
    /// Overrides the function so that when the view appears, camera
    /// session should be starting running
    override func viewDidAppear(_ animated: Bool) {
        if !done {
            session.startRunning()
        }
    }
    
    /// Sets up the AV capture
    func setupAVCapture() {
        session.sessionPreset = AVCaptureSessionPreset352x288
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
    
    /// Begins the capture session
    func beginSession() {
        setupDeviceInput()
        setupDataOutput()
        setupCameraView()
        session.startRunning()
    }
    
    /// Tests whether there exists an input for the device that
    /// is being used. If the input exists, add it into the session
    private func setupDeviceInput() {
        var deviceInput: AVCaptureDeviceInput?
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error {
            deviceInput = nil
            print("\(CameraViewConstants.errorMessagePrefix)\(error.localizedDescription)")
        }
        if self.session.canAddInput(deviceInput) {
            self.session.addInput(deviceInput)
        }
    }
    
    /// Sets up the corresponding properties of video data output
    private func setupDataOutput() {
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutputQueue = DispatchQueue(label: CameraViewConstants.dispatchQueueLabel)
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        if session.canAddOutput(videoDataOutput) { session.addOutput(videoDataOutput) }
        videoDataOutput.connection(withMediaType: AVMediaTypeVideo).isEnabled = true
    }
    
    /// Sets up the real camera view that will be displaying the video data
    private func setupCameraView() {
        cameraViewLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        let rootLayer = cameraView.layer
        rootLayer.masksToBounds = true
        cameraViewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(cameraViewLayer)
    }
    
    /// clean up AVCapture
    func stopCamera(){
        session.stopRunning()
        done = false
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        currentFrame = convertImageFromCMSampleBufferRef(sampleBuffer)
    }
    
    func convertImageFromCMSampleBufferRef(_ sampleBuffer:CMSampleBuffer) -> CIImage {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        return ciImage
    }
    
}
