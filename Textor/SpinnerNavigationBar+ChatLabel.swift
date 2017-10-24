//
//  SpinnerNavigationBar+ChatLabel.swift
//  Textor
//
//  Created by Eugene Golovanov on 4/8/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

extension SpinnerNavigationBar {
    
    //----------------------------------------------------------------------------
    // MARK: Chat Label
    
    func showChatLabel(_ navigationItem: UINavigationItem, status:String, statusLabelColor:UIColor) {
        
        func createDefaultLabel() {
            if let title = navigationItem.title {
                let messageLabel = self.createDefaultChatLabel(title: title, status: status, center: CGPoint(x: self.center.x, y: self.center.y - self.frame.size.height/2 + 2), statusLabelColor: statusLabelColor)
                navigationItem.titleView = messageLabel
            } else {
                navigationItem.titleView = UIView()
            }
        }
        
        if let connectiongLabel = viewWithTag(CONNECTION_LABEL_NAV_TAG)  {
            connectiongLabel.removeFromSuperview()
            createDefaultLabel()
        } else {
            createDefaultLabel()
        }
    }
    
    private func createDefaultChatLabel(title:String, status:String, center:CGPoint, statusLabelColor:UIColor) -> UIView {
        
        let contentView = UIView(frame: CGRect.zero)
        contentView.backgroundColor = UIColor.clear
        contentView.tag = CONNECTION_LABEL_NAV_TAG
        contentView.frame = CGRect( x: 0, y: 0, width: 30, height: 30)
        contentView.center = center
        
        //Add Title label
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.textColor = UIColor.black
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.numberOfLines = 0
        titleLabel.sizeToFit()
        titleLabel.alpha = 0.8
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let messageWidthConstraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: titleLabel.frame.width)
        titleLabel.addConstraint(messageWidthConstraint)
        let messageHeightConstraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: titleLabel.frame.height)
        titleLabel.addConstraint(messageHeightConstraint)
        let messageXCenterConstraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        contentView.addConstraint(messageXCenterConstraint)
        let messageYCenterConstraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: -titleLabel.frame.height/2)
        contentView.addConstraint(messageYCenterConstraint)
        
        //Add Status label
        let statusLabel = UILabel(frame: CGRect.zero)
        statusLabel.textColor = statusLabelColor
        statusLabel.text = status
        statusLabel.font = UIFont.systemFont(ofSize: 12)
        statusLabel.backgroundColor = UIColor.clear
        statusLabel.textAlignment = NSTextAlignment.center
        statusLabel.numberOfLines = 0
        statusLabel.sizeToFit()
        statusLabel.alpha = 0.8
        contentView.addSubview(statusLabel)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        let statusWidthConstraint = NSLayoutConstraint(item: statusLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: statusLabel.frame.width)
        statusLabel.addConstraint(statusWidthConstraint)
        let statusHeightConstraint = NSLayoutConstraint(item: statusLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: statusLabel.frame.height)
        statusLabel.addConstraint(statusHeightConstraint)
        let statusXCenterConstraint = NSLayoutConstraint(item: statusLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        contentView.addConstraint(statusXCenterConstraint)
        let statusYCenterConstraint = NSLayoutConstraint(item: statusLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: statusLabel.frame.height/2)
        contentView.addConstraint(statusYCenterConstraint)
        
        
        return contentView
    }

}
