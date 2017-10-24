//
//  EGChatInputBarPresenter.swift
//  Textor
//
//  Created by eugene golovanov on 3/29/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

protocol EGChatInputBarPresenter: class {
    var chatInputBar: EGChatInputBar { get }
    func onDidBeginEditing()
    func onDidEndEditing()
    func onSendButtonPressed()
    func onDidReceiveFocusOnItem(_ item: ChatInputItemProtocol)
}

@objc
public class EGBasicChatInputBarPresenter: NSObject, EGChatInputBarPresenter {
    let chatInputBar: EGChatInputBar
    let chatInputItems: [ChatInputItemProtocol]
    let notificationCenter: NotificationCenter
    
    public init(chatInputBar: EGChatInputBar,
                chatInputItems: [ChatInputItemProtocol],
                chatInputBarAppearance: EGChatInputBarAppearance,
                notificationCenter: NotificationCenter = NotificationCenter.default) {
        self.chatInputBar = chatInputBar
        self.chatInputItems = chatInputItems
        self.chatInputBar.setAppearance(chatInputBarAppearance)
        self.notificationCenter = notificationCenter
        super.init()
        
        self.chatInputBar.presenter = self
        self.chatInputBar.inputItems = self.chatInputItems
        self.notificationCenter.addObserver(self, selector: #selector(EGBasicChatInputBarPresenter.keyboardDidChangeFrame), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
        self.notificationCenter.addObserver(self, selector: #selector(EGBasicChatInputBarPresenter.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.notificationCenter.addObserver(self, selector: #selector(EGBasicChatInputBarPresenter.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    deinit {
        self.notificationCenter.removeObserver(self)
    }
    
    fileprivate(set) var focusedItem: ChatInputItemProtocol? {
        willSet {
            self.focusedItem?.selected = false
        }
        didSet {
            self.focusedItem?.selected = true
        }
    }
    
    fileprivate func updateFirstResponderWithInputItem(_ inputItem: ChatInputItemProtocol) {
        let responder = self.chatInputBar.textView!
        let inputView = inputItem.inputView
        responder.inputView = inputView
        if responder.isFirstResponder {
            self.setHeight(forInputView: inputView)
            responder.reloadInputViews()
        } else {
            responder.becomeFirstResponder()
        }
    }
    
    fileprivate func firstKeyboardInputItem() -> ChatInputItemProtocol? {
        var firstKeyboardInputItem: ChatInputItemProtocol? = nil
        for inputItem in self.chatInputItems {
            if inputItem.presentationMode == .keyboard {
                firstKeyboardInputItem = inputItem
                break
            }
        }
        return firstKeyboardInputItem
    }
    
    private var lastKnownKeyboardHeight: CGFloat?
    
    private func setHeight(forInputView inputView: UIView?) {
        guard let inputView = inputView else { return }
        guard let keyboardHeight = self.lastKnownKeyboardHeight else { return }
        
        var mask = inputView.autoresizingMask
        mask.remove(.flexibleHeight)
        inputView.autoresizingMask = mask
        
        let accessoryViewHeight = self.chatInputBar.textView.inputAccessoryView?.bounds.height ?? 0
        let inputViewHeight = keyboardHeight - accessoryViewHeight
        
        if let heightConstraint = inputView.constraints.filter({ $0.firstAttribute == .height }).first {
            heightConstraint.constant = inputViewHeight
        } else {
            inputView.frame.size.height = inputViewHeight
        }
    }
    
    private var allowListenToChangeFrameEvents = true
    
    @objc
    private func keyboardDidChangeFrame(_ notification: Notification) {
        guard self.allowListenToChangeFrameEvents else { return }
        guard let value = (notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        self.lastKnownKeyboardHeight = value.cgRectValue.height
    }
    
    @objc
    private func keyboardWillHide(_ notification: Notification) {
        self.allowListenToChangeFrameEvents = false
    }
    
    @objc
    private func keyboardWillShow(_ notification: Notification) {
        self.allowListenToChangeFrameEvents = true
    }
}

// MARK: ChatInputBarPresenter
extension EGBasicChatInputBarPresenter {
    public func onDidEndEditing() {
        self.focusedItem = nil
        self.chatInputBar.textView.inputView = nil
        self.chatInputBar.showsTextView = true
        self.chatInputBar.showsSendButton = true
    }
    
    public func onDidBeginEditing() {
        if self.focusedItem == nil {
            self.focusedItem = self.firstKeyboardInputItem()
        }
    }
    
    func onSendButtonPressed() {
        if let focusedItem = self.focusedItem {
            focusedItem.handleInput(self.chatInputBar.inputText as AnyObject)
        } else if let keyboardItem = self.firstKeyboardInputItem() {
            keyboardItem.handleInput(self.chatInputBar.inputText as AnyObject)
        }
        self.chatInputBar.inputText = ""
    }
    
    func onDidReceiveFocusOnItem(_ item: ChatInputItemProtocol) {
        guard item.presentationMode != .none else { return }
        guard item !== self.focusedItem else { return }
        
        self.focusedItem = item
        self.chatInputBar.showsSendButton = item.showsSendButton
        self.chatInputBar.showsTextView = item.presentationMode == .keyboard
        self.updateFirstResponderWithInputItem(item)
    }
}
