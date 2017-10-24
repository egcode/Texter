//
//  EGChatInputBarAppearance.swift
//  Textor
//
//  Created by eugene golovanov on 3/29/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

public struct EGChatInputBarAppearance {
    public struct SendButtonAppearance {
        public var font = UIFont.systemFont(ofSize: 16)
        public var insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        public var title = ""
        public var titleColors: [UIControlStateWrapper: UIColor] = [
            UIControlStateWrapper(state: .disabled): UIColor.bma_color(rgb: 0x9AA3AB),
            UIControlStateWrapper(state: .normal): UIColor.bma_color(rgb: 0x007AFF),
            UIControlStateWrapper(state: .highlighted): UIColor.bma_color(rgb: 0x007AFF).bma_blendWithColor(UIColor.white.withAlphaComponent(0.4))
        ]
    }
    
    public struct TabBarAppearance {
        public var interItemSpacing: CGFloat = 10
        public var height: CGFloat = 44
        public var contentInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    public struct TextInputAppearance {
        public var font = UIFont.systemFont(ofSize: 12)
        public var textColor = UIColor.black
        public var placeholderFont = UIFont.systemFont(ofSize: 12)
        public var placeholderColor = UIColor.gray
        public var placeholderText = ""
        public var textInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    public var sendButtonAppearance = SendButtonAppearance()
    public var tabBarAppearance = TabBarAppearance()
    public var textInputAppearance = TextInputAppearance()
    
    public init() {}
}


// Workaround for SR-2223
public struct UIControlStateWrapper: Hashable {
    
    public let controlState: UIControlState
    
    public init(state: UIControlState) {
        self.controlState = state
    }
    
    public var hashValue: Int {
        return Int(self.controlState.rawValue)
    }
}

public func == (lhs: UIControlStateWrapper, rhs: UIControlStateWrapper) -> Bool {
    return lhs.controlState == rhs.controlState
}
