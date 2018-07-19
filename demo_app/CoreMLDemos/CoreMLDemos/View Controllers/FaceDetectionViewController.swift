//
//  FaceDetectionViewController.swift
//  CoreMLSandbox
//
//  Created by Jon Manning on 26/2/18.
//  Copyright © 2018 Jon Manning. All rights reserved.
//

import UIKit
import Vision
import CoreVideo

class FaceDetectionViewController: UIViewController, CameraSessionDelegate {
    
    @IBOutlet weak var cameraView: CameraView!
    
    var faceLayer = CAShapeLayer()
    var faceLandmarksLayer = CAShapeLayer()
    
    
    override func viewDidLoad() {
        // After the view controller has loaded its view, we'll create and
        // prepare the layers that display the shapes
        cameraView.layer.addSublayer(faceLayer)
        cameraView.layer.addSublayer(faceLandmarksLayer)
        
        faceLayer.strokeColor = UIColor.red.cgColor
        faceLayer.fillColor = UIColor.clear.cgColor
        faceLayer.lineWidth = 2
        
        faceLandmarksLayer.strokeColor = UIColor.green.cgColor
        faceLandmarksLayer.fillColor = UIColor.clear.cgColor
        faceLandmarksLayer.lineWidth = 2
    }
    
    // SNIP: face_detect_handle_results
    
    // SNIP: face_detect_request
    
    // Creates a path that draws a rectangle around a face.
    func boundingBoxPath(for face: VNFaceObservation, in size: CGSize, flipped: Bool) -> CGPath {
        
        let path = CGMutablePath()
        
        // SNIP: face_detect_box
        
        return path
        
    }
    
    // Creates a path that draws the features of a face.
    func landmarksPath(for face: VNFaceObservation, in size: CGSize, flipped: Bool) -> CGMutablePath {
        
        // Create the path that we'll end up returning
        let faceLandmarksPath = CGMutablePath()
        
        // SNIP: face_detect_landmarks
        
        return faceLandmarksPath
    }
    
    func handle(pixelBuffer: CVPixelBuffer) {
        // SNIP: face_detect_perform_request
    }
    
    // Adds the points in a landmark region to a path
    private func addPoints(in landmarkRegion: VNFaceLandmarkRegion2D,
                           to path: CGMutablePath,
                           applying affineTransform: CGAffineTransform,
                           closingWhenComplete closePath: Bool) {
        
        guard landmarkRegion.pointCount > 1 else {
            return
        }
        
        // Begin a new subpath by moving to the first point in the landmark
        let points: [CGPoint] = landmarkRegion.normalizedPoints
        path.move(to: points[0], transform: affineTransform)
        
        // Draw lines between each point
        path.addLines(between: points, transform: affineTransform)
        
        // If we need to close this subpath, add one more line and close it
        if closePath {
            path.addLine(to: points[0], transform: affineTransform)
            path.closeSubpath()
        }
        
    }    

}

