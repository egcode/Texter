//
//  RoundedUIImageView.swift
//  Textor
//
//  Created by eugene golovanov on 1/19/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit
import Alamofire

@IBDesignable
class RoundedUIImageView: UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = min(self.frame.size.height/2, self.frame.size.width/2)
            self.clipsToBounds = true
            if cornerRadius > 0 {layer.cornerRadius = cornerRadius}
        }
    }
    
    //-----------------------------------------------------------------
    // MARK: - init
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
    }
    //MARK: - Setup Configure
    
    func setup() {
    }
    func configure() {
    }

}
