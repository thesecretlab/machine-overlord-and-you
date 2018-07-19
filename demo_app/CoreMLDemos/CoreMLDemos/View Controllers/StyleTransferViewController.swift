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
    
    // SNIP: style_transfer_request
    
    // SNIP: style_transfer_requestformodel
    
    
    // SNIP: style_transfer_handle_result
    
    // Called when the view is loaded from the storyboard.
    override func awakeFromNib() {
        
        // SNIP: style_transfer_awakefromnib
        
    }
    
    
    // Each of these methods replaces the current model with a different one
    
    @IBAction func selectTheScream(_ sender: Any) {
        // SNIP: style_transfer_select_methods_select
    }
    
    @IBAction func selectFeathers(_ sender: Any) {
        // SNIP: style_transfer_select_methods_select
        
    }
    
    @IBAction func selectCandy(_ sender: Any) {
        // SNIP: style_transfer_select_methods_select
        
    }
    
    @IBAction func selectLaMuse(_ sender: Any) {
        // SNIP: style_transfer_select_methods_select
        
    }
    
    @IBAction func selectMosaic(_ sender: Any) {
        // SNIP: style_transfer_select_methods_select
        
    }
    
    @IBAction func selectUdnie(_ sender: Any) {
        // SNIP: style_transfer_select_methods_select
        
    }
    
    @IBAction func saveImage(_ sender: Any) {
        // SNIP: style_transfer_save
    }
    
    @IBAction func flipCamera(_ sender: Any) {
        _ = session.toggleCameraPosition()
    }
}
