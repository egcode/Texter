//
//  MessageDataSource.swift
//  Textor
//
//  Created by eugene golovanov on 9/28/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions

class ChattoMessageDataSource: ChatDataSourceProtocol {
    //    public var hasMoreNext: Bool { get }
    //
    //    public var hasMorePrevious: Bool { get }
    //
    //    public var chatItems: [ChatItemProtocol] { get }
    //
    //    weak public var delegate: ChatDataSourceDelegateProtocol? { get set }
    //
    //    public func loadNext()
    //
    //    public func loadPrevious()
    //
    //    public func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: ((Bool)) -> Swift.Void)
    
    
    
    var nextMessageId: Int = 0
    let preferredMaxWindowSize = 500
    var messages = [ChatItemProtocol]()
    
    init(messages: [ChatItemProtocol], pageSize: Int) {
        self.messages = messages
        self.nextMessageId = messages.count
    }
    
    
    
    lazy var messageSender: TXMessageSender = {
        let sender = TXMessageSender()
        sender.onMessageChanged = { [weak self] (message) in
            guard let sSelf = self else { return }
            sSelf.delegate?.chatDataSourceDidUpdate(sSelf)
        }
        return sender
    }()
    
    var hasMoreNext: Bool {
        return false
    }
    
    var hasMorePrevious: Bool {
        return false
    }
    
    var chatItems: [ChatItemProtocol] {
        return self.messages
    }
    
    weak var delegate: ChatDataSourceDelegateProtocol?
    
    func loadNext() {
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }
    
    func loadPrevious() {
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }
    
    func addTextMessage(_ text: String) {
        let uid = "\(self.nextMessageId)"
        self.nextMessageId += 1
        let message = createTextMessageModel(uid, text: text, isIncoming: false)
        self.messageSender.sendMessage(message)
        
        self.messages.append(message)
        self.delegate?.chatDataSourceDidUpdate(self)
    }
    
    
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion:((didAdjust: Bool)) -> Void) {
//        let didAdjust = self.slidingWindow.adjustWindow(focusPosition: focusPosition, maxWindowSize: preferredMaxCount ?? self.preferredMaxWindowSize)
//        completion((didAdjust: didAdjust))
        completion(false)

    }
    
}




//-------------------------------------------------------------------------------------------------
// MARK: -

func createTextMessageModel(_ uid: String, text: String, isIncoming: Bool) -> TXTextMessageModel {
    let messageModel = createMessageModel(uid, isIncoming: isIncoming, type: TextMessageModel<MessageModel>.chatItemType)
    let textMessageModel = TXTextMessageModel(messageModel: messageModel, text: text)
    return textMessageModel
}

func createMessageModel(_ uid: String, isIncoming: Bool, type: String) -> MessageModel {
    let senderId = isIncoming ? "1" : "2"
    let messageStatus = isIncoming || arc4random_uniform(100) % 3 == 0 ? MessageStatus.success : .failed
    let messageModel = MessageModel(uid: uid, senderId: senderId, type: type, isIncoming: isIncoming, date: Date(), status: messageStatus)
    return messageModel
}

extension TextMessageModel {
    static var chatItemType: ChatItemType {
        return "text"
    }
}

extension PhotoMessageModel {
    static var chatItemType: ChatItemType {
        return "photo"
    }
}

