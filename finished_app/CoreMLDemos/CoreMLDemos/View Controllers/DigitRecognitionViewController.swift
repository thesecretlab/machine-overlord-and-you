//
//  DigitRecognitionViewController.swift
//  CoreMLDemos
//
//  Created by Jon Manning on 10/7/18.
//  Copyright © 2018 Secret Lab. All rights reserved.
//

import UIKit
import Vision

class DigitRecognitionViewController: UIViewController {
    
    // The view that lets the user draw an image
    @IBOutlet weak var scribbleView: DrawingView!
    
    // The label that displays the result
    @IBOutlet weak var resultLabel: UILabel!
    
    // BEGIN mnist_variables
    lazy var model = VNCoreMLModel(for: MNIST().model)
    
    lazy var request = VNCoreMLRequest(model: model, completionHandler: handleClassificationResult)
    // END mnist_variables
    
    // BEGIN mnist_handle_classification_result
    func handleClassificationResult(_ request: VNRequest, _ error: Error?) {
        guard let result = request.results?.first as? VNClassificationObservation else {
            return
        }
        
        DispatchQueue.main.async {
            self.resultLabel.text = result.identifier
        }
    }
    // END mnist_handle_classification_result
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure that we start with a clean slate
        self.clear()
    }
    
    @IBAction func clear() {
        // Clear the displayed view
        scribbleView.clearScribble()
        
        // And clear the displayed result
        resultLabel.text = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // Find where the touch was in the view
        guard let location = touches.first?.location(in: scribbleView) else
        {
            return
        }
        
        // Clear the result label while we're drawing
        resultLabel.text = nil
        
        // Tell the scribble view to begin drawing a new stroke
        scribbleView.beginScribble(point: location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // Get the touch, and all other touches associated with the touch
        guard let touch = touches.first,
            let coalescedTouches = event?.coalescedTouches(for: touch) else {
            return
        }
        
        // Pass the touches into the scribble view, updating the stroke
        coalescedTouches.forEach {
            scribbleView.appendScribble(point: $0.location(in: scribbleView))
        }
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // Tell the scribble view that we're done with this stroke
        scribbleView.endScribble()
        
        // Perform analysis on the current contents of the view.
        performRecognition()
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?)
    {
        // Clear the scribble view when the device is shaken
        if motion == UIEvent.EventSubtype.motionShake
        {
            clear()            
        }
    }

    // Analyses the contents of the scribble view and presents the predicted
    // number, using Vision to process the image
    func performRecognitionWithVision() {
        
        // BEGIN mnist_perform_recognition_vision
        
        // Get the image we're about to analyse
        let originalImage = scribbleView.captureImage()
        
        // Create a handler that processes this specific image.
        let handler = VNImageRequestHandler(cgImage: originalImage.cgImage!, options: [:])
        
        // Run the handler through the request. Its completion handler will
        // execute after analysis is complete, which will set the label's text.
        try? handler.perform([request])
        
        // END mnist_perform_recognition_vision
        
    }
    
    // Analyses the contents of the scribble view and presents the predicted
    // number.
    func performRecognition() {
        
        // BEGIN mnist_perform_recognition_manually
        // Get the image that we're going to analyse
        let originalImage = scribbleView.captureImage()
        
        // The model expects an image that's 28x28, so we need to resize our
        // image to this size. (This is also why the ScribbleView is square - it
        // means that the image will be the correct shape that the model is
        // expecting.)
        let size = CGSize(width: 28, height: 28)
        
        guard let resizedImage = originalImage.resize(to: size) else {
            fatalError("Failed to resize image")
        }
        
        // We need to convert the image into a pixel buffer of the correct format.
        // because that's the type of data that the model is expecting.
        guard let pixelBuffer = resizedImage.pixelBuffer() else {
            fatalError("Failed to resize and create pixelbuffer")
        }
        
        // Create an instance of the model and make a prediction
        guard let result = try? MNIST().prediction(image: pixelBuffer) else {
            fatalError("Failed to create prediction")
        }
        
        // Get the class label that we matched on.
        let detectedNumber = result.classLabel
        
        // Display the number.
        resultLabel.text = String(detectedNumber)
        // END mnist_perform_recognition_manually
    }
    
}
