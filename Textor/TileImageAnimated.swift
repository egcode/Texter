//
//  TileImageAnimated.swift
//  Textor
//
//  Created by eugene golovanov on 3/6/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

@IBDesignable
class TileImageAnimated: UIView, CAAnimationDelegate {
    
    private let imageView1 = UIImageView()
    private let imageView2 = UIImageView()
    
    //-----------------------------------------------------------------
    //MARK: - Properties
    
    //Image
    @IBInspectable var image: UIImage? {
        didSet {
            imageView1.image = image
            imageView2.image = image
        }
    }
    
    //Gradient Color
    let layerColorGradient = CAGradientLayer()
    
    @IBInspectable var gradientStartColor: UIColor = UIColor.black {
        didSet {
            configureGradient()
        }
    }
    @IBInspectable var gradientEndColor: UIColor = UIColor.white {
        didSet {
            configureGradient()
        }
    }
    @IBInspectable var gradiendOpacity: Float = 1.0 {
        didSet {
            self.layerColorGradient.opacity = gradiendOpacity
        }
    }
    //Gradient Opacity
    let layerOpacityGradient = CAGradientLayer()
    
    //-----------------------------------------------------------------
    //MARK: - init
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.configureFrames()
    }
    
    //-----------------------------------------------------------------
    //MARK: - Setup Configure
    
    func setup() {
        self.imageView1.contentMode = .scaleAspectFill
        self.imageView2.contentMode = .scaleAspectFill
        self.addSubview(self.imageView1)
        self.addSubview(self.imageView2)
        
        //Setup Gradients
        layer.addSublayer(self.layerColorGradient)
        layer.addSublayer(self.layerOpacityGradient)
        
    }
    
    func configureGradient() {
        // Configure Color Gradient
        self.layerColorGradient.colors = [
            gradientStartColor.cgColor,
            gradientEndColor.cgColor
        ]
        self.layerColorGradient.startPoint = CGPoint(x: 0.9, y: 0.0)
        self.layerColorGradient.endPoint = CGPoint(x: 0.9, y: 1.0)
        self.layerColorGradient.opacity = self.gradiendOpacity
        
        // Configure Opacity
        self.layerOpacityGradient.colors = [
            UIColor.white.cgColor,
            UIColor.clear.cgColor  //Opacity TRICK
        ]
        self.layerOpacityGradient.startPoint = self.layerColorGradient.startPoint
        self.layerOpacityGradient.endPoint = self.layerColorGradient.endPoint
        self.layerOpacityGradient.opacity = 1
    }
    
    func configureFrames() {
        //        self.blurEffectView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        self.imageView1.frame = self.bounds
        self.imageView2.frame = CGRect(x: 0, y: -self.bounds.height, width: self.bounds.width, height: self.bounds.height)
        
        //Gradient layer frame
        self.layerColorGradient.frame = self.bounds
        self.layerOpacityGradient.frame = self.bounds
        
        UIView.setAnimationsEnabled(false)
        UIView.setAnimationsEnabled(true)
        UIView.animate(withDuration: 30, delay: 0, options: [.curveLinear, .repeat], animations: {
            self.imageView1.center.y += self.bounds.height
            self.imageView2.center.y += self.bounds.height
        }) { (complete) in
            //
        }
        self.layer.mask = layerOpacityGradient // Apply MASK
    }
    
    
}
