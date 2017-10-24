//
//  EGTextChatInputItem.swift
//  Textor
//
//  Created by eugene golovanov on 3/16/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

/**
 Added Custom class to trim input
 */
open class EGTextChatInputItem {
    typealias Class = EGTextChatInputItem
    public var textInputHandler: ((String) -> Void)?
    
    let buttonAppearance: EGTabInputButtonAppearance
    public init(tabInputButtonAppearance: EGTabInputButtonAppearance = Class.createDefaultButtonAppearance()) {
        self.buttonAppearance = tabInputButtonAppearance
    }
    
    public static func createDefaultButtonAppearance() -> EGTabInputButtonAppearance {
        let images: [UIControlStateWrapper: UIImage] = [
            UIControlStateWrapper(state: .normal): UIImage(named: "text-icon-unselected", in: Bundle(for: TextChatInputItem.self), compatibleWith: nil)!,
            UIControlStateWrapper(state: .selected): UIImage(named: "text-icon-selected", in: Bundle(for: TextChatInputItem.self), compatibleWith: nil)!,
            UIControlStateWrapper(state: .highlighted): UIImage(named: "text-icon-selected", in: Bundle(for: TextChatInputItem.self), compatibleWith: nil)!
        ]
        return EGTabInputButtonAppearance(images: images, size: nil)
    }
    
    lazy fileprivate var internalTabView: EGTabInputButton = {
        return EGTabInputButton.makeInputButton(withAppearance: self.buttonAppearance, accessibilityID: "text.chat.input.view")
    }()
    
    open var selected = false {
        didSet {
            self.internalTabView.isSelected = self.selected
        }
    }
}

// MARK: - ChatInputItemProtocol
extension EGTextChatInputItem : ChatInputItemProtocol {
    public var presentationMode: ChatInputItemPresentationMode {
        return .keyboard
    }
    
    public var showsSendButton: Bool {
        return true
    }
    
    public var inputView: UIView? {
        return nil
    }
    
    public var tabView: UIView {
        return self.internalTabView
    }
    
    public func handleInput(_ input: AnyObject) {
        if let text = input as? String {
            if text.trim() != "" {
                self.textInputHandler?(text.trim())////Trim Text
            }
        }
    }
}
