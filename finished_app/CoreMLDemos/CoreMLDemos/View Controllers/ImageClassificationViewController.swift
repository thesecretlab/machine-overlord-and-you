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
    
    // BEGIN image_classification_variables
    // The model that the CoreML Request will use
    lazy var model = VNCoreMLModel(for: CatDogClassifier().model)
    
    // A request that uses the model, and calls handleClassificationResult when
    // it's done
    lazy var request = VNCoreMLRequest(model: model, completionHandler: handleClassificationResult)
    // END image_classification_variables
    
    // BEGIN image_classification_handle_result
    // Called when the VNCoreMLRequest has finished classifying.
    func handleClassificationResult(_ request: VNRequest, _ error: Error?) {
        
        // The type of the results depends on the model, so we don't know at
        // build time what they'll be. In this case, because the model is
        // a classifier, the results will be of type VNClassificationObservation,
        // so we'll cast to that (or bail out if that fails)
        guard let results = request.results as? [VNClassificationObservation] else {
            return
        }
        
        // Get up to four results from the classifier
        let firstResults = results.prefix(upTo: min(4, results.count-1))
        
        // Build a list of strings that combine the predictions with their
        // probabilities (expressed as a percentage)
        var resultStrings : [String] = []
        
        for result in firstResults {
            let id = result.identifier
            let confidence = Int(result.confidence * 100)
            resultStrings.append("\(id) (\(confidence)%)")
        }
        
        // We can only update the view from the main queue
        DispatchQueue.main.async {
            
            // Update the label
            self.resultLabel.text = resultStrings.joined(separator: "\n")
            
            // Indicate that we want to wait timeBetweenClassifications until
            // the next classification
            self.nextClassification = Date(timeIntervalSinceNow: self.timeBetweenClassifications)
        }
    }
    // END image_classification_handle_result
    
    // Called by the CameraView when a new pixel buffer is available
    func handle(pixelBuffer: CVPixelBuffer) {
        
        // BEGIN image_classification_handle_pixelbuffer
        // If the next classification date is in the future, do nothing with
        // this frame
        if Date() < nextClassification {
            return
        }
        
        // Create a handler that uses this pixel buffer
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        
        // Run our request through the handler
        try! handler.perform([request])
        // END image_classification_handle_pixelbuffer
        
    }
    

}
