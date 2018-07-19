//
//  ImageClassificationViewController.swift
//  CoreMLDemos
//
//  Created by Jon Manning on 12/7/18.
//  Copyright © 2018 Secret Lab. All rights reserved.
//

import UIKit
import Vision

class ImageClassificationViewController: UIViewController, CameraSessionDelegate {
    
    // Wait half a second between classifications
    let timeBetweenClassifications: TimeInterval = 0.5
    
    // The time that we'll next do a classification
    var nextClassification = Date()
    
    // The label that we'll show the result in
    @IBOutlet weak var resultLabel : UILabel!
    
    // SNIP: image_classification_variables
    
    // SNIP: image_classification_handle_result
    
    // Called by the CameraView when a new pixel buffer is available
    func handle(pixelBuffer: CVPixelBuffer) {
        
        // SNIP: image_classification_handle_pixelbuffer
        
        
    }
    

}
