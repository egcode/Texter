//
//  EGChatInputItemView.swift
//  Textor
//
//  Created by eugene golovanov on 3/30/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

protocol EGChatInputItemViewDelegate: class {
    func inputItemViewTapped(_ view: EGChatInputItemView)
}

class EGChatInputItemView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    private func commonInit() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EGChatInputItemView.handleTap))
        gestureRecognizer.cancelsTouchesInView = false
        self.addGestureRecognizer(gestureRecognizer)
    }
    
    weak var delegate: EGChatInputItemViewDelegate?
    func handleTap() {
        self.delegate?.inputItemViewTapped(self)
    }
    
    var inputItem: ChatInputItemProtocol! {
        willSet {
            if self.inputItem != nil {
                self.inputItem.tabView.removeFromSuperview()
            }
        }
        didSet {
            if self.inputItem != nil {
                self.addSubview(self.inputItem.tabView)
                self.setNeedsLayout()
            }
        }
    }
}

// MARK: UIView
extension EGChatInputItemView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.inputItem.tabView.frame = self.bounds
    }
    
    override var intrinsicContentSize: CGSize {
        return self.inputItem.tabView.intrinsicContentSize
    }
}
