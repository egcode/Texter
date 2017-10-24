//
//  UIImage+Multiply.swift
//  Textor
//
//  Created by eugene golovanov on 3/8/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

extension UIImage {
    
    /**
     Multiply to color
     This is similar to Photoshop's blend mode

     - parameter fillColor: UIColor
     
     - returns: UIImage
     */
    func multiplyToColor(_ fillColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw tint color
            context.setBlendMode(.normal)
            fillColor.setFill()
            context.fill(rect)
            
            context.setBlendMode(.multiply)
            context.draw(cgImage!, in: rect)
        }
    }
    
    /**
     Modified Image Context, apply modification on image
     
     - parameter draw: (CGContext, CGRect) -> ())
     
     - returns: UIImage
     */
    fileprivate func modifiedImage(_ draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}
