//
//  EGTabInputButtonAppearance.swift
//  Textor
//
//  Created by eugene golovanov on 3/30/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

public struct EGTabInputButtonAppearance {
    public var images: [UIControlStateWrapper: UIImage]
    public var size: CGSize?
    
    public init(images: [UIControlStateWrapper: UIImage], size: CGSize?) {
        self.images = images
        self.size = size
    }
}

public class EGTabInputButton: UIButton {
    
    static public func makeInputButton(withAppearance appearance: EGTabInputButtonAppearance, accessibilityID: String? = nil) -> EGTabInputButton {
        let images = appearance.images
        let button = EGTabInputButton(type: .custom)
        button.isExclusiveTouch = true
        images.forEach { (state, image) in
            button.setImage(image, for: state.controlState)
        }
        if let accessibilityIdentifier = accessibilityID {
            button.accessibilityIdentifier = accessibilityIdentifier
        }
        button.size = appearance.size
        return button
    }
    
    private var size: CGSize?
    
    public override var intrinsicContentSize: CGSize {
        if let size = self.size {
            return size
        }
        return super.intrinsicContentSize
    }
}
