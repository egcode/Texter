//
//  PieImageLoader.swift
//  Textor
//
//  Created by eugene golovanov on 1/26/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit
import Alamofire

@IBDesignable
class PieImageLoader: UIView {
    
    weak var avatarRequest: Alamofire.Request?

    let imageView = UIImageView()
    let pieSpapeLayer = CAShapeLayer()
    let shadowLayer = CAShapeLayer()

    //-----------------------------------------------------------------
    //MARK: - Properties

    //Image
    @IBInspectable var image: UIImage? {
        didSet {
            imageView.image = image
            self.pieSpapeLayer.path = UIBezierPath().cgPath
            self.pieSpapeLayer.opacity = 0
        }
    }

    //Pie Shape
    @IBInspectable var percent: CGFloat = 0 {
        didSet {
            if percent > 0 {
                self.pieSpapeLayer.path = drawSlice(rect: self.bounds, startPercent: 0, endPercent: percent).cgPath
                self.pieSpapeLayer.opacity = 0.7
            } else {
                self.pieSpapeLayer.path = UIBezierPath().cgPath
                self.pieSpapeLayer.opacity = 0
            }
        }
    }
    
    @IBInspectable var pieColor: UIColor = UIColor.black {
        didSet {
            self.pieSpapeLayer.fillColor = pieColor.cgColor
            self.pieSpapeLayer.strokeColor = pieColor.cgColor
        }
    }
    
    //Shadow
    @IBInspectable var castShadow: Bool = false {
        didSet {
            if castShadow {
                shadowLayer.shadowColor = UIColor.black.cgColor
                shadowLayer.shadowRadius = 5
                shadowLayer.shadowOpacity = 0.6
                shadowLayer.shadowOffset = CGSize(width: 0, height: 4)
            } else {
                shadowLayer.shadowColor = UIColor.clear.cgColor
                shadowLayer.shadowRadius = 0
                shadowLayer.shadowOpacity = 0
                shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
            }
        }
    }
    @IBInspectable var shadowLayerMargin: CGFloat = 1 { //Remove Kayomka
        didSet {
            self.updateShadowLayer(margin: shadowLayerMargin)
        }
    }
    
    //-----------------------------------------------------------------
    //MARK: - init
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        configure()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
        configure()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateShadowLayer(margin: shadowLayerMargin)
        self.imageView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        self.pieSpapeLayer.path = drawSlice(rect: self.bounds, startPercent: 0, endPercent: percent).cgPath
    }
    
    //-----------------------------------------------------------------
    //MARK: - Setup Configure
    
    func setup() {
        
        //Shadow
        shadowLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: (self.bounds.height/2.0)).cgPath
        shadowLayer.fillColor = UIColor.black.cgColor
        shadowLayer.masksToBounds = false
        layer.addSublayer(shadowLayer)
        
        self.addSubview(self.imageView)
        
        self.pieSpapeLayer.path = drawSlice(rect: self.bounds, startPercent: 0, endPercent: 23).cgPath
        self.pieSpapeLayer.strokeColor = pieColor.cgColor
        self.pieSpapeLayer.fillColor = pieColor.cgColor
        self.pieSpapeLayer.opacity = 0
        layer.addSublayer(self.pieSpapeLayer)
    }
    
    func configure() {
        self.imageView.layer.cornerRadius = min(self.frame.width/2, self.frame.height/2)
        self.imageView.layer.masksToBounds = true
    }
    
    //-----------------------------------------------------------------
    //MARK: - Pie Helpers
    
    private func drawSlice(rect: CGRect, startPercent: CGFloat, endPercent: CGFloat) -> UIBezierPath {
        let center = CGPoint(x: rect.origin.x + rect.width / 2, y: rect.origin.y + rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        let startAngle = startPercent / 100 * CGFloat(M_PI) * 2 - CGFloat(M_PI_2)
        let endAngle = endPercent / 100 * CGFloat(M_PI) * 2 - CGFloat(M_PI_2)
        let path = UIBezierPath()
        path.move(to: center)
        path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.close()
        return path
    }
    
    private func updateShadowLayer(margin:CGFloat) {
        let radiusRect = CGRect(x: margin/2, y: margin/2, width: self.bounds.width - margin, height: self.bounds.height - margin)
        self.shadowLayer.path = UIBezierPath(roundedRect: radiusRect, cornerRadius: self.bounds.height).cgPath
    }
    
    //-----------------------------------------------------------------
    // MARK: - Download
    func getImageWithUrl(avatarUrl:String) {
        
        //Check image from cache
        if let img = DataManager.imageCache.object(forKey: avatarUrl as NSString) {
            self.image = img
            return
        }
        
        //Avatar download
        ImageUtils.downloadAvatar(url: avatarUrl, request: self.avatarRequest) { (success, progress, image) in
            if let im = image {
                self.image = im
                self.percent = 0
                DataManager.imageCache.setObject(im, forKey: avatarUrl as NSString)
            } else {
                self.percent = CGFloat(progress * 100)
                
                // completion(false,1.0, nil)// Failed download
                if progress == 1 {
                    self.percent = 0
                    magic("failed to download image")
                }
            }
        }
        
    }

    
}
