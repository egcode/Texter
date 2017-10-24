//
//  UIViewController+Spinner.swift
//  Textor
//
//  Created by Eugene Golovanov on 6/11/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public func showSpinner(message:String? = nil) {
        guard let mainView = self.view else { magic("no view"); return }
        
        //Reset
        self.hideSpinner()
        mainView.isUserInteractionEnabled = false
        
        let indicator = StrokeSpinner()
        indicator.frame = CGRect(x:0.0, y:0.0, width: 40,height: 40)
        mainView.addSubview(indicator)
        indicator.bringSubview(toFront: indicator)
        
        //BG view
        let bgView = UIView(frame: CGRect(x: -self.view.frame.width - 20, y: -self.view.frame.height - 20, width: self.view.frame.width, height: self.view.frame.height))
        bgView.backgroundColor = UIColor.black
        bgView.isUserInteractionEnabled = true
        bgView.alpha = 0.7
        indicator.insertSubview(bgView, at: 0)
        
        //Indicator Constraints
        indicator.translatesAutoresizingMaskIntoConstraints = false
        let spinnerWidthConstraint = NSLayoutConstraint(item: indicator, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: indicator.frame.width)
        indicator.addConstraint(spinnerWidthConstraint)
        let spinnerHeightConstraint = NSLayoutConstraint(item: indicator, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: indicator.frame.height)
        indicator.addConstraint(spinnerHeightConstraint)
        let spinnerHorizontalConstraint = NSLayoutConstraint(item: indicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        mainView.addConstraint(spinnerHorizontalConstraint)
        let spinnerVerticalConstraint = NSLayoutConstraint(item: indicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        mainView.addConstraint(spinnerVerticalConstraint)
        
        //Bg View Constraints
        bgView.translatesAutoresizingMaskIntoConstraints = false
        let bgViewWidthConstraint = NSLayoutConstraint(item: bgView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: bgView.frame.width)
        bgView.addConstraint(bgViewWidthConstraint)
        let bgViewHeightConstraint = NSLayoutConstraint(item: bgView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: bgView.frame.height)
        bgView.addConstraint(bgViewHeightConstraint)
        let bgViewHorizontalConstraint = NSLayoutConstraint(item: bgView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        mainView.addConstraint(bgViewHorizontalConstraint)
        let bgViewVerticalConstraint = NSLayoutConstraint(item: bgView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        mainView.addConstraint(bgViewVerticalConstraint)
        
        if let m = message {
            let messageLabel = UILabel(frame: CGRect( x: 0, y: 0, width: 300, height: 20))
            messageLabel.textColor = UIColor.white
            messageLabel.text = m
            messageLabel.font = UIFont.systemFont(ofSize: 15)
            messageLabel.backgroundColor = UIColor.clear
            messageLabel.textAlignment = NSTextAlignment.center
            messageLabel.numberOfLines = 0
            messageLabel.sizeToFit()
            messageLabel.center = bgView.center
            
            bgView.addSubview(messageLabel)
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            let offset:CGFloat = -(indicator.frame.size.height + messageLabel.frame.size.height)/2 - 40
            let messageLabelVerticalConstraint = NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: bgView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: offset)
            bgView.addConstraint(messageLabelVerticalConstraint)
            
            let messageLabelViewHeightConstraint = NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: messageLabel.frame.height)
            messageLabel.addConstraint(messageLabelViewHeightConstraint)
            let leadingConstraint = NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: bgView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
            bgView.addConstraint(leadingConstraint)
            let trailingConstraint = NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: bgView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
            bgView.addConstraint(trailingConstraint)
        }
    }
    
    public func hideSpinner() {
        guard let mainView = self.view else { magic("no view"); return }
        mainView.isUserInteractionEnabled = true
        for view in mainView.subviews {
            if  view.isKind(of: StrokeSpinner.self) {
                view.removeFromSuperview()
            }
        }
    }
    
}
