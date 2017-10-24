//
//  SpinnerNavigationBar+Banner.swift
//  Textor
//
//  Created by Eugene Golovanov on 4/8/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

extension SpinnerNavigationBar {
    //----------------------------------------------------------------------------
    // MARK: - Banner
    
    func initBanner() {
        
        //Banner itself
        let bannerFrame = CGRect(
            x: 0,
            y: -BANNER_HEIGHT,
            width: self.frame.size.width,
            height: BANNER_HEIGHT)
        let bannerView = UIView(frame: bannerFrame)
        bannerView.backgroundColor = TXColor.bannerDark
//        bannerView.alpha = 0.3
        
        self.addSubview(bannerView)
        self.sendSubview(toBack: bannerView)
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        
        let bannerLeadingConstraint = NSLayoutConstraint(item: bannerView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        self.addConstraint(bannerLeadingConstraint)
        let bannerTrailingConstraint = NSLayoutConstraint(item: bannerView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        self.addConstraint(bannerTrailingConstraint)
        let bannerHeightConstraint = NSLayoutConstraint(item: bannerView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: BANNER_HEIGHT)
        bannerView.addConstraint(bannerHeightConstraint)
        self.bannerVerticalConstraint = NSLayoutConstraint(item: bannerView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -BANNER_HEIGHT)
        self.addConstraint(bannerVerticalConstraint)
        
        //// Label //////
        let incomeMessageLabel = UILabel(frame: CGRect( x: 0, y: 0, width: 140, height: 20))
        incomeMessageLabel.textColor = UIColor.white
        incomeMessageLabel.text = "Waiting for network"
        incomeMessageLabel.font = UIFont.systemFont(ofSize: 15)
        incomeMessageLabel.backgroundColor = UIColor.clear
        incomeMessageLabel.textAlignment = NSTextAlignment.center
        incomeMessageLabel.numberOfLines = 0
//        incomeMessageLabel.alpha = 0.0  //ANIM
        
        bannerView.addSubview(incomeMessageLabel)
        
        incomeMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelWidthConstraint = NSLayoutConstraint(item: incomeMessageLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: incomeMessageLabel.frame.width)
        incomeMessageLabel.addConstraint(labelWidthConstraint)
        let labelHeightConstraint = NSLayoutConstraint(item: incomeMessageLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: incomeMessageLabel.frame.height)
        incomeMessageLabel.addConstraint(labelHeightConstraint)
        let labelHorizontalConstraint = NSLayoutConstraint(item: incomeMessageLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: bannerView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        bannerView.addConstraint(labelHorizontalConstraint)
        let labelVerticalConstraint = NSLayoutConstraint(item: incomeMessageLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: bannerView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        bannerView.addConstraint(labelVerticalConstraint)
        
        
        /// Spinner ////
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        //        loadingIndicator.color = UIColor.blueColor()
        loadingIndicator.startAnimating()
        //        loadingIndicator.alpha = 0.0   //ANIM
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
        
    }

    
    /**
     Hides connection banner if its exists
     */
    func hideNavBanner() {
        self.bannerVerticalConstraint.constant = -BANNER_HEIGHT
        UIView.animate(withDuration: 0.5, animations: {
            self.layoutIfNeeded()
        })
    }
    
    func showNavBanner() {
        self.bannerVerticalConstraint.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.layoutIfNeeded()
        })
    }
}
