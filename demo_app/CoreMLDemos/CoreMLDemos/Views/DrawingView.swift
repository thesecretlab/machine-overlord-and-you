//
//  DrawingView.swift
//  CoreMLDemos
//
//  Created by Jon Manning on 15/7/18.
//  Copyright © 2018 Secret Lab. All rights reserved.
//

import UIKit

class DrawingView: UIView {

    let backgroundLayer = CAShapeLayer()
    let drawingLayer = CAShapeLayer()
    
    var strokeColor: UIColor = UIColor.black
    var lineWidth: CGFloat = 20.0
    
    let path = UIBezierPath()
    
    override func awakeFromNib() {
        backgroundLayer.strokeColor = strokeColor.cgColor
        backgroundLayer.fillColor = nil
        backgroundLayer.lineWidth = CGFloat(lineWidth)
        
        drawingLayer.strokeColor = strokeColor.cgColor
        drawingLayer.fillColor = nil
        drawingLayer.lineWidth = CGFloat(lineWidth)
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(drawingLayer)
        
        layer.masksToBounds = true
    }
    
    func captureImage() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, self.window?.screen.scale ?? 1.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            fatalError("Failed to create image context")
        }
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        UIColor.black.setFill()
        UIColor.white.setStroke()
        
        UIBezierPath(rect: self.bounds).fill()
        
        let path = UIBezierPath(cgPath: backgroundLayer.path!)
        
        path.lineWidth = CGFloat(self.lineWidth)
        
        path.stroke()
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Failed to get image from image context")
        }
        
        return image
        
    }
    
    func beginScribble(point: CGPoint)
    {
        path.removeAllPoints()
        
        path.move(to: point)
    }
    
    func appendScribble(point: CGPoint)
    {
        path.addLine(to: point)
        
        drawingLayer.path = path.cgPath
    }
    
    func endScribble()
    {
        if let backgroundPath = backgroundLayer.path
        {
            path.append(UIBezierPath(cgPath: backgroundPath))
        }
        
        backgroundLayer.path = path.cgPath
        
        path.removeAllPoints()
        
        drawingLayer.path = path.cgPath
    }
    
    func clearScribble()
    {
        backgroundLayer.path = nil
    }

}
