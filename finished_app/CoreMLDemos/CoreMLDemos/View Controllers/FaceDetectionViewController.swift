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
    
    // BEGIN face_detect_handle_results
    func handleRequestResults(_ request: VNRequest, _ error: Error?) {
        
        guard let observations = request.results as? [VNFaceObservation] else {
            // No observations
            return
        }
        
        DispatchQueue.main.async {
            
            // Construct paths for both face outlines and features
            let outlinesPath = CGMutablePath()
            let landmarksPath = CGMutablePath()
            
            let size = self.cameraView.bounds.size
            
            let flipped = self.cameraView.position == .front
            
            // For each face, add a box around it.
            for face in observations {
                
                // Get a path that draws a rectangle around the face
                let faceBox = self.boundingBoxPath(for: face, in: size, flipped: flipped)
                
                // Add it to the path that contains face outlines
                outlinesPath.addPath(faceBox)
                
                // Get a path that draws each individual feature of the face
                let landmarks = self.landmarksPath(for: face, in: size, flipped: flipped)
                
                // Add it to the path that contains face features
                landmarksPath.addPath(landmarks)
            }
            
            // Update the paths we're showing
            self.faceLayer.path = outlinesPath
            self.faceLandmarksLayer.path = landmarksPath
        }
    }
    // END face_detect_handle_results
    
    // BEGIN face_detect_request
    // Create a request to detect faces.
    lazy var request = VNDetectFaceLandmarksRequest(completionHandler: handleRequestResults)
    // END face_detect_request
    
    // Creates a path that draws a rectangle around a face.
    func boundingBoxPath(for face: VNFaceObservation, in size: CGSize, flipped: Bool) -> CGPath {
        
        let path = CGMutablePath()
        
        // BEGIN face_detect_box
        // The bounding box is normalized - (0,0) is bottom-left, (1,1) is top-right
        
        // We want to rotate it so that (0,0) is top-left, so we'll flip it
        // on the Y axis, and if we need to flip it horizontally, we'll do the
        // same thing on the X axis; this pushes it off-screen, so we'll push it back
        // by adding 1 to both axes. We'll then scale it to the size of the camera
        // view.
        
        let rect = face
            .boundingBox
            .applying(CGAffineTransform(scaleX: flipped ? -1 : 1, y: -1)) // flip it
            .applying(CGAffineTransform(translationX: flipped ? 1 : 0, y: 1)) // move it back
            .applying(CGAffineTransform(scaleX: size.width, y: size.height))
        
        path.addRect(rect)
        // END face_detect_box
        
        return path
        
    }
    
    // Creates a path that draws the features of a face.
    func landmarksPath(for face: VNFaceObservation, in size: CGSize, flipped: Bool) -> CGMutablePath {
        
        // Create the path that we'll end up returning
        let faceLandmarksPath = CGMutablePath()
        
        // BEGIN face_detect_landmarks
        // We'll need to flip two things: first, the bounding box of the face,
        // and second, the features themselves. Create a flip transform and store
        // it.
        let flipTransform =
            CGAffineTransform(scaleX: flipped ? -1 : 1, y: -1)
                .concatenating(CGAffineTransform(translationX: flipped ? 1 : 0, y: 1))
        
        // Flip the bounding box.
        let rect = face.boundingBox.applying(flipTransform)
        
        // Convert it into the coordinates for the camera view.
        let faceBounds = VNImageRectForNormalizedRect(rect, Int(size.width), Int(size.height))
        
        if let landmarks = face.landmarks {
            // Landmarks are relative to, and normalized within, face bounds
            let affineTransform =
                CGAffineTransform(translationX: faceBounds.origin.x, y: faceBounds.origin.y)
                .scaledBy(x: faceBounds.size.width, y: faceBounds.size.height)
            
            let featureTransform = flipTransform.concatenating(affineTransform)
            
            // Treat eyebrows and lines as open-ended regions when drawing paths.
            let openLandmarkRegions: [VNFaceLandmarkRegion2D] = [
                landmarks.leftEyebrow,
                landmarks.rightEyebrow,
                landmarks.faceContour,
                landmarks.noseCrest,
                landmarks.medianLine
                ].compactMap({$0})
            
            for openLandmarkRegion in openLandmarkRegions{
                self.addPoints(in: openLandmarkRegion,
                               to: faceLandmarksPath,
                               applying: featureTransform,
                               closingWhenComplete: false)
            }
            
            // Draw eyes, lips, and nose as closed regions.
            let closedLandmarkRegions: [VNFaceLandmarkRegion2D] = [
                landmarks.leftEye,
                landmarks.rightEye,
                landmarks.outerLips,
                landmarks.innerLips,
                landmarks.nose
            ].compactMap({$0})
            
            for closedLandmarkRegion in closedLandmarkRegions {
                self.addPoints(in: closedLandmarkRegion,
                               to: faceLandmarksPath,
                               applying: featureTransform,
                               closingWhenComplete: true)
            }
        }
        // END face_detect_landmarks
        
        return faceLandmarksPath
    }
    
    func handle(pixelBuffer: CVPixelBuffer) {
        // BEGIN face_detect_perform_request
        // We've received a pixel buffer from the camera view. Use it to
        // ask Vision to detect faces.
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        
        do {
            try handler.perform([request])
        } catch let error {
            print("Error perfoming request: \(error)")
        }
        // END face_detect_perform_request
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

