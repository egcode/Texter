//
//  UIWindow+ConnectionBanner.swift
//
//
//  Created by eugene golovanov on 6/27/16.
//   All rights reserved.
//

import UIKit

extension UIWindow {
    
    
    //-------------------------------------------------------------------------------------------------------------------------
    //MARK: - Connecting Label
    
    func showConnectingLabel(_ message: String) {
        
        guard let vc = self.rootViewController else {magic("Got no root view controller for window");return}
        let masterView = vc.view
        
        //Delete If previous still exists
        self.cleanupConnectingLabel(masterView!)
        
        
        //// Label //////
        let incomeMessageLabel = UILabel(frame: CGRect( x: 0, y: 0, width: 100, height: 20))
        incomeMessageLabel.textColor = UIColor.gray
        incomeMessageLabel.text = message
        incomeMessageLabel.font = UIFont.systemFont(ofSize: 15)
        incomeMessageLabel.backgroundColor = UIColor.green
        incomeMessageLabel.textAlignment = NSTextAlignment.center
        incomeMessageLabel.numberOfLines = 0
        incomeMessageLabel.tag = CONNECTION_LABEL_TAG
        incomeMessageLabel.alpha = 0.0  //ANIM
        
        masterView?.addSubview(incomeMessageLabel)
        
        incomeMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelWidthConstraint = NSLayoutConstraint(item: incomeMessageLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: incomeMessageLabel.frame.width)
        incomeMessageLabel.addConstraint(labelWidthConstraint)
        let labelHeightConstraint = NSLayoutConstraint(item: incomeMessageLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: incomeMessageLabel.frame.height)
        incomeMessageLabel.addConstraint(labelHeightConstraint)
        let labelHorizontalConstraint = NSLayoutConstraint(item: incomeMessageLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: masterView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        masterView?.addConstraint(labelHorizontalConstraint)
        let labelVerticalConstraint = NSLayoutConstraint(item: incomeMessageLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: masterView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 30)
        masterView?.addConstraint(labelVerticalConstraint)
        
        
        /// Spinner ////
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.color = UIColor.blue
        loadingIndicator.startAnimating()
        loadingIndicator.alpha = 0.0   //ANIM
        loadingIndicator.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        incomeMessageLabel.addSubview(loadingIndicator)
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        let spinnerWidthConstraint = NSLayoutConstraint(item: loadingIndicator, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: loadingIndicator.frame.width)
        loadingIndicator.addConstraint(spinnerWidthConstraint)
        let spinnerHeightConstraint = NSLayoutConstraint(item: loadingIndicator, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: loadingIndicator.frame.height)
        loadingIndicator.addConstraint(spinnerHeightConstraint)
        let spinnerHorizontalConstraint = NSLayoutConstraint(item: loadingIndicator, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: incomeMessageLabel, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        incomeMessageLabel.addConstraint(spinnerHorizontalConstraint)
        let spinnerVerticalConstraint = NSLayoutConstraint(item: loadingIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: incomeMessageLabel, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        incomeMessageLabel.addConstraint(spinnerVerticalConstraint)
        
        ////////ANIMATION START//////////
        UIView.animate(withDuration: 0.5, animations: {
            incomeMessageLabel.alpha = 1.0
            loadingIndicator.alpha = 1.0
        })
        //////ANIMATION END//////////
    }
    
    /**
     Hides connection banner if its exists
     */
    func hideConnectingLabel() {
        
        guard let incomeMessageLabel = viewWithTag(CONNECTION_LABEL_TAG) else {
            print("connecting label does not exists with tag, Ignoring")
            return
        }
        
        guard let vc = self.rootViewController else {magic("Got no root view controller for window");return}
        let masterView = vc.view
        
        
        ////////ANIMATION START//////////
        UIView.animate(withDuration: 0.5, animations: {
            incomeMessageLabel.alpha = 0.0
        }, completion: { (completed) in
            if completed {
//                   incomeMessageLabel.removeFromSuperview()
                self.cleanupConnectingLabel(masterView!)
            }
        }) 
        //////ANIMATION END//////////
    }
    
    //-------------------------------------------------------------------------------------------------------------------------
    //MARK: - Private

    /**
     Remove old before animation begin if exists
     */
    fileprivate func cleanupConnectingLabel(_ masterView: UIView) {
        var count = 0
        for view: UIView in masterView.subviews {
            if view.viewWithTag(CONNECTION_LABEL_TAG) != nil {
                view.removeFromSuperview()
                count += 1
            }
        }
        print("Done connectiong cleaning, cleared: \(count) labels")
    }
    
}
