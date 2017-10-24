//
//  StrokeSpinner.swift
//  Textor
//
//  Created by Eugene Golovanov on 6/11/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

@IBDesignable
class StrokeSpinner: UIView {
    
    //---------------------------------------------------------
    // MARK: - Properties
    
    let circleLayer = CAShapeLayer()
    
    //Animation
    var duration:CFTimeInterval = 1.75 {
        didSet {
            rotateAnimation.duration = self.duration
            circleLayer.removeAnimation(forKey: "transform.rotation.z")
            circleLayer.add(rotateAnimation, forKey: "transform.rotation.z")
        }
    }
    fileprivate let rotateAnimation: CAAnimation = {
        let rotationAnim = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnim.duration = 3.75
        rotationAnim.repeatCount = Float.infinity
        rotationAnim.fromValue = Float(Double.pi * 2.0)
        rotationAnim.toValue = 0.0
        rotationAnim.fillMode = kCAFillModeForwards
        rotationAnim.isRemovedOnCompletion = false
        return rotationAnim
    }()
    
    //---------------------------------------------------------
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    //---------------------------------------------------------
    // MARK: - Setup
    
    fileprivate func setup() {
        rotateAnimation.duration = self.duration
        
        circleLayer.lineWidth = 2
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.init(colorLiteralRed: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        circleLayer.lineCap = kCALineCapSquare
        layer.addSublayer(circleLayer)
        circleLayer.add(rotateAnimation, forKey: "transform.rotation.z")
        tintColorDidChange()
    }
    
    //---------------------------------------------------------
    //MARK: - View Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 1.8 - circleLayer.lineWidth/2
        let startAngle = CGFloat(-Double.pi/2)
        let endAngle = startAngle + CGFloat(Double.pi * 2)
        
        let path = UIBezierPath(arcCenter: CGPoint.zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        circleLayer.lineCap = kCALineCapRound
        circleLayer.position = center
        circleLayer.path = path.cgPath
        circleLayer.strokeEnd = 0.75
        
    }
}
