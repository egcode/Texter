//
//  EGChatInputBar.swift
//  Textor
//
//  Created by eugene golovanov on 3/29/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

public protocol EGChatInputBarDelegate: class {
    func inputBarShouldBeginTextEditing(_ inputBar: EGChatInputBar) -> Bool
    func inputBarDidBeginEditing(_ inputBar: EGChatInputBar)
    func inputBarDidEndEditing(_ inputBar: EGChatInputBar)
    func inputBarDidChangeText(_ inputBar: EGChatInputBar)
    func inputBarSendButtonPressed(_ inputBar: EGChatInputBar)
    func inputBar(_ inputBar: EGChatInputBar, shouldFocusOnItem item: ChatInputItemProtocol) -> Bool
    func inputBar(_ inputBar: EGChatInputBar, didReceiveFocusOnItem item: ChatInputItemProtocol)
}

@objc
open class EGChatInputBar: EGReusableXibView {
    
    public weak var delegate: EGChatInputBarDelegate?
    weak var presenter: EGChatInputBarPresenter?
    
    var typingAction = {}
    
    public var shouldEnableSendButton = { (inputBar: EGChatInputBar) -> Bool in
        if inputBar.textView.text.trim() != "" {
                return true
        }
        return false
    }

    @IBOutlet weak var scrollView: EGHorizontalStackScrollView!
    @IBOutlet weak var textView: EGExpandableTextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var topBorderHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var constraintsForHiddenTextView: [NSLayoutConstraint]!
    @IBOutlet var constraintsForVisibleTextView: [NSLayoutConstraint]!
    
    @IBOutlet var constraintsForVisibleSendButton: [NSLayoutConstraint]!
    @IBOutlet var constraintsForHiddenSendButton: [NSLayoutConstraint]!
    @IBOutlet var tabBarContainerHeightConstraint: NSLayoutConstraint!
    
    class open func loadNib() -> EGChatInputBar {
        let view = Bundle(for: self).loadNibNamed(self.nibName(), owner: nil, options: nil)!.first as! EGChatInputBar
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect.zero
        return view
    }
    
    override class func nibName() -> String {
        return "EGChatInputBar"
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.topBorderHeightConstraint.constant = 1 / UIScreen.main.scale
        self.textView.scrollsToTop = false
        self.textView.delegate = self
        self.scrollView.scrollsToTop = false
        self.sendButton.isEnabled = false
    }
    
    open override func updateConstraints() {
        if self.showsTextView {
            NSLayoutConstraint.activate(self.constraintsForVisibleTextView)
            NSLayoutConstraint.deactivate(self.constraintsForHiddenTextView)
        } else {
            NSLayoutConstraint.deactivate(self.constraintsForVisibleTextView)
            NSLayoutConstraint.activate(self.constraintsForHiddenTextView)
        }
        if self.showsSendButton {
            NSLayoutConstraint.deactivate(self.constraintsForHiddenSendButton)
            NSLayoutConstraint.activate(self.constraintsForVisibleSendButton)
        } else {
            NSLayoutConstraint.deactivate(self.constraintsForVisibleSendButton)
            NSLayoutConstraint.activate(self.constraintsForHiddenSendButton)
        }
        super.updateConstraints()
    }
    
    open var showsTextView: Bool = true {
        didSet {
            self.setNeedsUpdateConstraints()
            self.setNeedsLayout()
            self.updateIntrinsicContentSizeAnimated()
        }
    }
    
    open var showsSendButton: Bool = true {
        didSet {
            self.setNeedsUpdateConstraints()
            self.setNeedsLayout()
            self.updateIntrinsicContentSizeAnimated()
        }
    }
    
    public var maxCharactersCount: UInt? // nil -> unlimited
    
    private func updateIntrinsicContentSizeAnimated() {
        let options: UIViewAnimationOptions = [.beginFromCurrentState, .allowUserInteraction]
        UIView.animate(withDuration: 0.25, delay: 0, options: options, animations: { () -> Void in
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }, completion: nil)
    }
    
    open override func layoutSubviews() {
        self.updateConstraints() // Interface rotation or size class changes will reset constraints as defined in interface builder -> constraintsForVisibleTextView will be activated
        super.layoutSubviews()
    }
    
    var inputItems = [ChatInputItemProtocol]() {
        didSet {
            let inputItemViews = self.inputItems.map { (item: ChatInputItemProtocol) -> EGChatInputItemView in
                let inputItemView = EGChatInputItemView()
                inputItemView.inputItem = item
                inputItemView.delegate = self
                return inputItemView
            }
            self.scrollView.addArrangedViews(inputItemViews)
        }
    }
    
    open func becomeFirstResponderWithInputView(_ inputView: UIView?) {
        self.textView.inputView = inputView
        
        if self.textView.isFirstResponder {
            self.textView.reloadInputViews()
        } else {
            self.textView.becomeFirstResponder()
        }
    }
    
    public var inputText: String {
        get {
            return self.textView.text
        }
        set {
            self.textView.text = newValue
            self.updateSendButton()
        }
    }
    
    fileprivate func updateSendButton() {
        self.sendButton.isEnabled = self.shouldEnableSendButton(self)
    }
    
    @IBAction func buttonTapped(_ sender: AnyObject) {
        self.presenter?.onSendButtonPressed()
        self.delegate?.inputBarSendButtonPressed(self)
    }
    
    public func setTextViewPlaceholderAccessibilityIdentifer(_ accessibilityIdentifer: String) {
        self.textView.setTextPlaceholderAccessibilityIdentifier(accessibilityIdentifer)
    }
}

// MARK: - ChatInputItemViewDelegate
extension EGChatInputBar: EGChatInputItemViewDelegate {
    func inputItemViewTapped(_ view: EGChatInputItemView) {
        self.focusOnInputItem(view.inputItem)
    }
    
    public func focusOnInputItem(_ inputItem: ChatInputItemProtocol) {
        let shouldFocus = self.delegate?.inputBar(self, shouldFocusOnItem: inputItem) ?? true
        guard shouldFocus else { return }
        
        self.presenter?.onDidReceiveFocusOnItem(inputItem)
        self.delegate?.inputBar(self, didReceiveFocusOnItem: inputItem)
    }
}

// MARK: - ChatInputBarAppearance
extension EGChatInputBar {
    public func setAppearance(_ appearance: EGChatInputBarAppearance) {
        self.textView.font = appearance.textInputAppearance.font
        self.textView.textColor = appearance.textInputAppearance.textColor
        self.textView.textContainerInset = appearance.textInputAppearance.textInsets
        self.textView.setTextPlaceholderFont(appearance.textInputAppearance.placeholderFont)
        self.textView.setTextPlaceholderColor(appearance.textInputAppearance.placeholderColor)
        self.textView.setTextPlaceholder(appearance.textInputAppearance.placeholderText)
        self.tabBarInterItemSpacing = appearance.tabBarAppearance.interItemSpacing
        self.tabBarContentInsets = appearance.tabBarAppearance.contentInsets
        self.sendButton.contentEdgeInsets = appearance.sendButtonAppearance.insets
        self.sendButton.setTitle(appearance.sendButtonAppearance.title, for: .normal)
        appearance.sendButtonAppearance.titleColors.forEach { (state, color) in
            self.sendButton.setTitleColor(color, for: state.controlState)
        }
        self.sendButton.titleLabel?.font = appearance.sendButtonAppearance.font
        self.tabBarContainerHeightConstraint.constant = appearance.tabBarAppearance.height
    }
}

extension EGChatInputBar { // Tabar
    public var tabBarInterItemSpacing: CGFloat {
        get {
            return self.scrollView.interItemSpacing
        }
        set {
            self.scrollView.interItemSpacing = newValue
        }
    }
    
    public var tabBarContentInsets: UIEdgeInsets {
        get {
            return self.scrollView.contentInset
        }
        set {
            self.scrollView.contentInset = newValue
        }
    }
}

// MARK: UITextViewDelegate
extension EGChatInputBar: UITextViewDelegate {
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return self.delegate?.inputBarShouldBeginTextEditing(self) ?? true
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        self.presenter?.onDidEndEditing()
        self.delegate?.inputBarDidEndEditing(self)
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        self.presenter?.onDidBeginEditing()
        self.delegate?.inputBarDidBeginEditing(self)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        self.updateSendButton()
        self.delegate?.inputBarDidChangeText(self)
        self.typingAction()
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn nsRange: NSRange, replacementText text: String) -> Bool {
        let range = self.textView.text.bma_rangeFromNSRange(nsRange)
        if let maxCharactersCount = self.maxCharactersCount {
            let currentCount = textView.text.characters.count
            let rangeLength = textView.text.substring(with: range).characters.count
            let nextCount = currentCount - rangeLength + text.characters.count
            return UInt(nextCount) <= maxCharactersCount
        }
        return true
    }
}

private extension String {
    func bma_rangeFromNSRange(_ nsRange: NSRange) -> Range<String.Index> {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return  self.startIndex..<self.startIndex }
        return from ..< to
    }
}
