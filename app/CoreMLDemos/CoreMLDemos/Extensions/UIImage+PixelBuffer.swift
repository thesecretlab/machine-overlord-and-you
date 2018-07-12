//
//  UIImage+PixelBuffer.swift
//  MNISTPrediction
//
//  Created by Philipp Gabriel on 15.02.18.
//  Copyright © 2018 Philipp Gabriel. All rights reserved.
//

import UIKit

extension UIImage {

    // Resizes an image by re-drawing it in an image context of the specified
    // size.
    func resize(to newSize: CGSize) -> UIImage? {

        // If the size that we were given is our current size, there's
        // nothing to do, so we just return ourself
        guard self.size != newSize else { return self }

        // Start a new graphics context of the specified size
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        // Draw this image in the context, scaled to the specified size.
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))

        // Clear the context after we return from this method
        defer { UIGraphicsEndImageContext() }
        
        // Get the image from the context and return it
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    // Converts the image into a pixel buffer containing 8-bit grayscale data.
    func pixelBuffer() -> CVPixelBuffer? {
        
        // The pixelbuffer we'll return.
        var pixelBuffer: CVPixelBuffer? = nil

        // The width and height of the pixel buffer.
        let width = Int(self.size.width)
        let height = Int(self.size.height)

        // Create the pixel buffer, specifying how to allocate memory, its size,
        // its pixel format, its attributes (nil), and where to put it
        CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                            kCVPixelFormatType_OneComponent8, nil, &pixelBuffer)
        
        // Lock the memory so that the CPU (i.e. this thread) can access the data
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue:0))
        
        // We'll fill the pixel buffer by rendering it into a drawing context
        // that's set up to do all drawing in 8-bit grayscale (the same as the
        // pixel buffer.)

        let colorspace = CGColorSpaceCreateDeviceGray()
        let bitmapContext =
            CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer!),
                      width: width, height: height, bitsPerComponent: 8,
                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                      space: colorspace, bitmapInfo: 0)!

        // Ensure that this image can be rendered into a CGContext
        guard let cg = self.cgImage else {
            return nil
        }

        // Perform the drawing. This will fill the pixel buffer with data.
        bitmapContext.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Unlock the pixel buffer, since we're done working with it on the CPU
        // for the moment. (Locking is only necessary when accessing the data
        // from the CPU; if the data is meant to be used from the GPU, locking
        // can impair performance.)
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        // It's now ready to be used.
        return pixelBuffer
    }
}
