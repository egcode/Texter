//
//  BaseMessageHandler.swift
//  Textor
//
//  Created by eugene golovanov on 8/10/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions

public protocol TXMessageViewModelProtocol {
    var messageModel: TXMessageModelProtocol { get }
}

class BaseMessageHandler {

    private let messageSender: TXMessageSender
    init (messageSender: TXMessageSender) {
        self.messageSender = messageSender
    }
    func userDidTapOnTextFailIcon(viewModel: TXMessageViewModelProtocol) {
        print("user Did TapOn TEXT FailIcon")
        self.messageSender.failedMessagePrompt(viewModel.messageModel)
    }
    
    func userDidTapOnPhotoFailIcon(viewModel: TXMessageViewModelProtocol) {
        print("user Did Tap On PHOTO FailIcon")
        self.messageSender.failedMessagePrompt(viewModel.messageModel)
    }
    
    func userDidTapOnPhoto(viewModel:TXMessageViewModelProtocol) {
        print("user Did Tap On PHOTO IMAGE")
        self.messageSender.photoTapped(viewModel.messageModel)
    }

    func userDidTapOnAvatar(viewModel: MessageViewModelProtocol) {
        print("userDidTapOnAvatar")
    }

    func userDidTapOnBubble(viewModel: TXMessageViewModelProtocol) {
        print("userDidTapOnBubble")
    }

    func userDidBeginLongPressOnBubble(viewModel: TXMessageViewModelProtocol) {
        print("userDidBeginLongPressOnBubble")
        self.messageSender.longPressBubblePrompt(viewModel.messageModel)
    }

    func userDidEndLongPressOnBubble(viewModel: TXMessageViewModelProtocol) {
        print("userDidEndLongPressOnBubble")
    }
}
