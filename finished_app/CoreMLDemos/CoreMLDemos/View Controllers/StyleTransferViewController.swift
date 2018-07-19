//
//  StyleTransferViewController.swift
//  CoreMLDemos
//
//  Created by Jon Manning on 10/7/18.
//  Copyright © 2018 Secret Lab. All rights reserved.
//

import UIKit
import Vision
import Photos

class StyleTransferViewController: UIViewController {
    
    // The image view that the resulting image will be shown in
    @IBOutlet weak var resultImageView: UIImageView!
    
    // Create the camera session, which will provide us with frames
    let session = CameraSession()
    
    // When true, the model is currently processing an image. This means that
    // we won't try to queue up more than one request at a time.
    var processing = false
    
    // BEGIN style_transfer_request
    // The initial request uses the FNSTheScream model
    lazy var request : VNCoreMLRequest = self.request(for: FNSTheScream().model)
    // END style_transfer_request
    
    // BEGIN style_transfer_requestformodel
    // Produces a request, given a CoreML model.
    func request(for model: MLModel) -> VNCoreMLRequest {
        
        // Create a VNCoreMLModel that wraps this MLModel
        let model = try! VNCoreMLModel(for: model)
        
        // Produce the request
        return VNCoreMLRequest(
            model: model,
            completionHandler: handleImageProcessingResult
        )
    }
    // END style_transfer_requestformodel
    
    
    // BEGIN style_transfer_handle_result
    func handleImageProcessingResult(_ request: VNRequest, _ error: Error?) {
        // Ensure that we got a VNPixelBufferObservation to use
        guard let result = request.results?.first as? VNPixelBufferObservation else {
            return
        }
        
        // Get the pixel buffer from the result
        let pixelBuffer = result.pixelBuffer
        
        // Create a CIImage from this pixel buffer
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        // Create a UIImage that uses this CIImage, and specify its scale
        // and orientation
        let image = UIImage(ciImage: ciImage, scale: CGFloat(1.0), orientation: UIImageOrientation.left)
        
        DispatchQueue.main.async {
            // Update the image view
            self.resultImageView.image = image
            
            // Signal that we're done processing this
            self.processing = false
        }
    }
    // END style_transfer_handle_result
    
    // Called when the view is loaded from the storyboard.
    override func awakeFromNib() {
        
        // BEGIN style_transfer_awakefromnib
        // Tell the session to run this code when a new frame arrives off the
        // camera
        session.frameDelivered = {
            
            // Are we in the middle of processing a frame?
            if self.processing {
                // Do nothing with it
                return
            }
            
            // Flag that we're busy
            self.processing = true
            
            // Run the pixel buffer through the model
            let handler = VNImageRequestHandler(cvPixelBuffer: $0)
            try! handler.perform([self.request])
        }
        // END style_transfer_awakefromnib
    }
    
    
    // BEGIN style_transfer_select_methods_noskip
    // Each of these methods replaces the current model with a different one
    
    @IBAction func selectTheScream(_ sender: Any) {
        // BEGIN style_transfer_select_methods_select
        request = request(for: FNSTheScream().model)
        // END style_transfer_select_methods_select
    }
    
    @IBAction func selectFeathers(_ sender: Any) {
        // BEGIN style_transfer_select_methods_select
        request = request(for: FNSFeathers().model)
        // END style_transfer_select_methods_select
    }
    
    @IBAction func selectCandy(_ sender: Any) {
        // BEGIN style_transfer_select_methods_select
        request = request(for: FNSCandy().model)
        // END style_transfer_select_methods_select
    }
    
    @IBAction func selectLaMuse(_ sender: Any) {
        // BEGIN style_transfer_select_methods_select
        request = request(for: FNSLaMuse().model)
        // END style_transfer_select_methods_select
    }
    
    @IBAction func selectMosaic(_ sender: Any) {
        // BEGIN style_transfer_select_methods_select
        request = request(for: FNSMosaic().model)
        // END style_transfer_select_methods_select
    }
    
    @IBAction func selectUdnie(_ sender: Any) {
        // BEGIN style_transfer_select_methods_select
        request = request(for: FNSUdnie().model)
        // END style_transfer_select_methods_select
    }
    // END style_transfer_select_methods_noskip
    
    @IBAction func saveImage(_ sender: Any) {
        
        // BEGIN style_transfer_save
        guard let image = resultImageView.image?.ciImage else {
            return
        }
        
        // We need to transfer the image data from the GPU to the CPU. It's
        // currently in a CIImage; we need to convert it to a CGImage, which
        // can be saved.
        let context = CIContext(options: nil)
        
        // Get a CGImage from the CIImage.
        guard let cgImage = context.createCGImage(image, from: image.extent) else {
            return
        }
        
        // Construct a UIImage that refers to the CGImage.
        let imageWithCGImage = UIImage(cgImage: cgImage)
        
        // Save this UIImage to the photo library.
        PHPhotoLibrary.shared().performChanges({
            PHAssetCreationRequest.creationRequestForAsset(from: imageWithCGImage)
        })
        
        resultImageView.alpha = 0
        
        UIView.animate(withDuration: 0.25) {
            self.resultImageView.alpha = 1
        }
        // END style_transfer_save
        
    }
    @IBAction func flipCamera(_ sender: Any) {
        session.toggleCameraPosition()
    }
}
