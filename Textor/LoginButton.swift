//
//  LoginButton.swift
//  Textor
//
//  Created by eugene golovanov on 3/6/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

@IBDesignable
public class LoginButton: UIControl {
    
    fileprivate lazy var imageView : UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    fileprivate lazy var label : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "Avenir-Black", size: 20.0)
        label.textColor = UIColor.white
        return label
    }()
    
    //---------------------------------------------------------------------------------------------------
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInitalization()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public override func awakeFromNib() {
        self.sharedInitalization()
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.sharedInitalization()
    }
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.sharedInitalization()
    }
    
}
//---------------------------------------------------------------------------------------------------
// MARK:- Public API
extension LoginButton {
    
    @IBInspectable
    var image : UIImage? {
        get {
            return imageView.image
        }
        set(newImage) {
            imageView.image = newImage?.withRenderingMode(.automatic)
        }
    }
    
    @IBInspectable
    var text : String? {
        get {
            return label.text
        }
        set(newText) {
            label.text = newText
        }
    }
}
//---------------------------------------------------------------------------------------------------
// MARK: Utilities
extension LoginButton {
    
    fileprivate func sharedInitalization() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        self.addSubview(label)
        
        let imageSize:CGFloat = 60
        self.imageView.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
        self.label.frame = CGRect(x: imageSize, y: 0, width: self.frame.width - imageSize, height: imageSize)
        self.layer.cornerRadius = 4
        self.addGestureRecognizer()
        
        //Shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
}
//---------------------------------------------------------------------------------------------------
//MARK: Tap Functionality
extension LoginButton {
    fileprivate func addGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginButton.handleIconTapped(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    func handleIconTapped(_ sender:UITapGestureRecognizer) {
        sendActions(for: .touchUpInside)//Send Event Like UIButton
    }
    
    //Change Color While TAP
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        animateTintAdjustmentMode(.dimmed)
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        animateTintAdjustmentMode(.normal)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        animateTintAdjustmentMode(.normal)
    }
    
    fileprivate func animateTintAdjustmentMode(_ mode: UIViewTintAdjustmentMode) {
        UIView.animate(withDuration: mode == .normal ? 0.3 : 0.01, animations: {
            self.tintAdjustmentMode = mode
            self.imageView.alpha = (mode == .normal ? 1 : 0.2)
            self.label.alpha = (mode == .normal ? 1 : 0.2)
            self.label.textColor = UIColor.white
        })
    }
    
    
}

