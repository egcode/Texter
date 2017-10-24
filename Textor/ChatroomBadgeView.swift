//
//  ChatroomBadgeView.swift
//  Textor
//
//  Created by eugene golovanov on 2/1/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit
import Alamofire

@IBDesignable
class ChatroomBadgeView: UIView {
    
    let labelCount = UILabel()
    
    //-----------------------------------------------------------------
    //MARK: - Properties
    
    @IBInspectable var value: Int = 0 {
        didSet {
            self.labelCount.text = "\(value)"
            if value > 0 {
                self.alpha = 1
                self.labelCount.alpha = 1
            } else {
                self.alpha = 0
                self.labelCount.alpha = 0
            }
        }
    }
    
    @IBInspectable var valueColor: UIColor = UIColor.white {
        didSet {
            self.labelCount.textColor = valueColor
        }
    }
    
    @IBInspectable var fontSize: CGFloat = 12 {
        didSet {
            self.labelCount.font = UIFont.systemFont(ofSize: fontSize)
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
        self.labelCount.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
    }
    
    //-----------------------------------------------------------------
    //MARK: - Setup Configure
    
    func setup() {
        self.labelCount.text = "\(self.value)"
        self.labelCount.textColor = self.valueColor
        self.labelCount.textAlignment = NSTextAlignment.center
        self.labelCount.font = UIFont.systemFont(ofSize: fontSize)
        self.addSubview(self.labelCount)
    }
    
    func configure() {
        self.layer.cornerRadius = min(self.frame.width/2, self.frame.height/2)
        self.layer.masksToBounds = true
    }
    
    
    
}
