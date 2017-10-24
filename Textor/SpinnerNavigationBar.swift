//
//  SpinnerNavigationBar.swift
//  customNavigation
//
//  Created by eugene golovanov on 9/12/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit
@IBDesignable
class SpinnerNavigationBar: UINavigationBar {
    
    var bannerVerticalConstraint = NSLayoutConstraint()
    
    override func awakeFromNib() {
    }
    
    //----------------------------------------------------------------------------
    // MARK: - Label

    func showSpinnerLabel(_ message: String, navigationItem:UINavigationItem) {
        
        self.showDefaultLabel(navigationItem)
        
        //// Label //////
        let messageLabel = self.createDefaultTitleLabel(title: message, center: CGPoint(x: self.center.x, y: self.center.y - self.frame.size.height/2 + 2), textColor: UIColor.gray)
        
        /// Spinner ////
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating()
        loadingIndicator.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        messageLabel.addSubview(loadingIndicator)
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        let spinnerWidthConstraint = NSLayoutConstraint(item: loadingIndicator, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: loadingIndicator.frame.width)
        loadingIndicator.addConstraint(spinnerWidthConstraint)
        let spinnerHeightConstraint = NSLayoutConstraint(item: loadingIndicator, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: loadingIndicator.frame.height)
        messageLabel.addConstraint(spinnerHeightConstraint)
        let spinnerHorizontalConstraint = NSLayoutConstraint(item: loadingIndicator, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: messageLabel, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: -5)
        messageLabel.addConstraint(spinnerHorizontalConstraint)
        let spinnerVerticalConstraint = NSLayoutConstraint(item: loadingIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: messageLabel, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        messageLabel.addConstraint(spinnerVerticalConstraint)

        //Make parent
        navigationItem.titleView = messageLabel

    }
    
    func showDefaultLabel(_ navigationItem: UINavigationItem) {
        
        func createDefaultLabel() {
            if let title = navigationItem.title {
                let messageLabel = self.createDefaultTitleLabel(title: title, center: CGPoint(x: self.center.x, y: self.center.y - self.frame.size.height/2 + 2), textColor: UIColor.black)
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
    
   private func createDefaultTitleLabel(title:String, center:CGPoint, textColor: UIColor) -> UILabel {
        let messageLabel = UILabel(frame: CGRect( x: 0, y: 0, width: 300, height: 20))
        messageLabel.textColor = textColor
        messageLabel.text = title
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        messageLabel.backgroundColor = UIColor.clear
        messageLabel.textAlignment = NSTextAlignment.center
        messageLabel.numberOfLines = 0
        messageLabel.tag = CONNECTION_LABEL_NAV_TAG
        messageLabel.sizeToFit()
        messageLabel.center = center
        return messageLabel
    }
    
}
