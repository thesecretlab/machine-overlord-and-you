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
    
    // SNIP: mnist_variables
    
    // SNIP: mnist_handle_classification_result
    
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
    
    // Analyses the contents of the scribble view and presents the predicted
    // number, using Vision to process the image
    func performRecognitionWithVision() {
        
        // SNIP: mnist_perform_recognition_vision
    }
    
    // Analyses the contents of the scribble view and presents the predicted
    // number.
    func performRecognition() {
        
        // SNIP: mnist_perform_recognition_manually
        
    }
    
}
