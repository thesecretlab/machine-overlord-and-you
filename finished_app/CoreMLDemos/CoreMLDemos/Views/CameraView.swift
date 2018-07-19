//
//  CameraView.swift
//  CoreMLSandbox
//
//  Created by Jon Manning on 23/2/18.
//  Copyright © 2018 Jon Manning. All rights reserved.
//

import UIKit
import AVKit
import CoreImage

// A Camera Session manages an AVCaptureSession, and delivers frames of video
// to a specified handler.
class CameraSession : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // A capture session. This coordinates the flow of media, from the inputs
    // (the camera) to the outputs (the video handler, which is this class)
    let captureSession = AVCaptureSession()
    
    // The block that will be called when a new frame is available.
    var frameDelivered: ((CVPixelBuffer) -> Void)?
    
    var position : AVCaptureDevice.Position {
        didSet {
            setCameraPosition(position)
        }
    }
    
    override init() {
        
        // We get the video data via this AVCaptureVideoDataOutput.
        let captureOutput = AVCaptureVideoDataOutput()
        
        // Connect the output to the session
        captureSession.addOutput(captureOutput)
        
        // We'll be using the rear camera at start
        position = .back
        
        // Start the session running
        captureSession.startRunning()
        
        super.init()
        
        // We need to manually call setCameraPosition because property observers
        // don't run during init
        setCameraPosition(.back)
        
        // Tell it that we want to receive the samples as they come in from
        // the session
        captureOutput.setSampleBufferDelegate(
            self, queue: DispatchQueue(label: "videoQueue"))
        
        
    }
    
    // Configures the session to use the camera at the specified position.
    private func setCameraPosition(_ position: AVCaptureDevice.Position) {
        
        // Remove any existing inputs
        let inputs = captureSession.inputs
        
        for i in inputs {
            captureSession.removeInput(i)
        }
        
        // Set up an AVCaptureDevice.DiscoverySession by indicating what
        // kind of device we're looking for.
        let deviceTypes = [AVCaptureDevice.DeviceType.builtInWideAngleCamera]
        let mediaType = AVMediaType.video
        let position = position
        
        // Get the first device that matches these criteria, or throw a fatal error.
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: mediaType,
            position: position).devices.first else {
                fatalError("No usable device found.")
        }
        
        // Create an input that uses this device, and attach it to the session.
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            captureSession.addInput(input)
            
        } catch let error {
            fatalError("Failed to connect camera input: \(error)")
        }
        
        // Configure the connection between the input and output to make it
        // deliver frames in the right orientation (otherwise the CoreML models
        // get confused, and deliver less than great results)
        let captureOutput = captureSession.outputs.first as? AVCaptureVideoDataOutput
        
        let connection = captureOutput?.connection(with: .video)
        connection?.videoOrientation = .portrait
        
    }
    
    func toggleCameraPosition() -> AVCaptureDevice.Position {
        // Get the current camera position
        let currentCamera = captureSession.inputs.first as? AVCaptureDeviceInput
        let currentPosition = currentCamera?.device.position
        
        // Swap it for the alternative
        switch currentPosition {
        case .front?:
            position = .back
            return .back
        case .back?:
            position = .front
            return .front
        default:
            // Fall back to the rear camera if we don't know
            position = .back
            return .back
        }        
    }
    
    // Called by an AVCaptureVideoDataOutput when a new frame comes
    // in off the camera.
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        // We've received a CMSampleBuffer; we want to get its pixel buffer, and
        // produce a scaled version if it
        
        guard let originalPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            fatalError("Failed to convert a sample buffer to a pixel buffer!")
        }
        
        // Deliver the processed frame
        frameDelivered?(originalPixelBuffer)
        
    }
    
    
}

// Displays a view through the camera, and forwards the frames it displays to
// a delegate.
class CameraView: UIView {
    
    // The camera session.
    let cameraSession = CameraSession()
    
    // A preview layer. The output of the capture session will
    // appear in it.
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    var position : AVCaptureDevice.Position {
        get {
            return cameraSession.position
        }
        set {
            cameraSession.position = newValue
        }
    }
    
    // Called when this view is created from code.
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        prepareLayer()
    }
    
    // Called when this view is loaded from a nib.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        prepareLayer()
    }
    
    override func awakeFromNib() {
        
    }
    
    // Performs first-time setup to start the camera session.
    func prepareLayer() {
        
        // Tell the preview layer to use this session
        previewLayer.session = cameraSession.captureSession
        
        // Make the layer fill the screen
        previewLayer.frame = self.bounds
        
        // Add the layer and make it visible
        self.layer.insertSublayer(previewLayer, at: 0)
        
        cameraSession.frameDelivered = {
            // Deliver it to our delegate
            self.delegate?.handle(pixelBuffer: $0)
        }
    }
    
    // Called when the view has been laid out.
    override func layoutSubviews() {
        // We want the preview layer to fill the view at all times, so we'll
        // adjust the layer's frame to fill our bounds.
        previewLayer.frame = self.bounds
    }
    
    // When touched, switch between the rear and front cameras.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        _ = cameraSession.toggleCameraPosition()
    }
    
    // We'll deliver pixel buffers to this delegate every time we get a new frame
    @IBOutlet var delegate : CameraSessionDelegate?
    
}

// Classes that conform to this protocol can be connected to the 'delegate'
// property on a CameraSession; when they are, they'll get a pixel buffer every frame
@objc protocol CameraSessionDelegate {
    func handle(pixelBuffer: CVPixelBuffer)
}
