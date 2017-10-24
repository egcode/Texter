//
//  EGHorizontalStackScrollView.swift
//  Textor
//
//  Created by eugene golovanov on 3/30/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

open class EGHorizontalStackScrollView: UIScrollView {
    
    private var arrangedViews: [UIView] = []
    private var arrangedViewContraints: [NSLayoutConstraint] = []
    var interItemSpacing: CGFloat = 0.0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    func addArrangedViews(_ views: [UIView]) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
        self.arrangedViews.append(contentsOf: views)
        self.setNeedsUpdateConstraints()
    }
    
    override open func updateConstraints() {
        super.updateConstraints()
        self.removeConstraintsForArrangedViews()
        self.addConstraintsForArrengedViews()
    }
    
    private func removeConstraintsForArrangedViews() {
        for constraint in self.arrangedViewContraints {
            self.removeConstraint(constraint)
        }
        self.arrangedViewContraints.removeAll()
    }
    
    private func addConstraintsForArrengedViews() {
        for (index, view) in arrangedViews.enumerated() {
            switch index {
            case 0:
                let constraint = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
                self.addConstraint(constraint)
                self.arrangedViewContraints.append(constraint)
            case arrangedViews.count-1:
                let constraint = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
                self.addConstraint(constraint)
                self.arrangedViewContraints.append(constraint)
                fallthrough
            default:
                let constraint = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: arrangedViews[index-1], attribute: .trailing, multiplier: 1, constant: self.interItemSpacing)
                self.addConstraint(constraint)
                self.arrangedViewContraints.append(constraint)
            }
            self.addConstraint(NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        }
    }
}
