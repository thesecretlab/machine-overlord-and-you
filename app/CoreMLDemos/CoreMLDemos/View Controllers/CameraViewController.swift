//
//  CameraViewController.swift
//  CoreMLSandbox
//
//  Created by Jon Manning on 23/2/18.
//  Copyright © 2018 Jon Manning. All rights reserved.
//

import UIKit
import AVKit

class CameraViewController: UIViewController, CameraSessionDelegate {
    
    // This view controller does nothing except demonstrate the use of
    // CameraView.

    // Called every frame by CameraView, for which we are a delegate.
    func handle(pixelBuffer: CVPixelBuffer) {
        // We've received a pixel buffer that contains a single frame.
        
        // In this example, do nothing.
    }
    
}
