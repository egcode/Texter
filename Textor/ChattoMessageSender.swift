//
//  MessageSender.swift
//  Textor
//
//  Created by eugene golovanov on 9/28/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions

public protocol ChattoMessageModelProtocol: MessageModelProtocol {
    var status: MessageStatus { get set }
}

public class ChattoMessageSender {
    
    public var onMessageChanged: ((_ message: ChattoMessageModelProtocol) -> Void)?
    
//    public func sendMessages(_ messages: [DemoMessageModelProtocol]) {
//        for message in messages {
//            self.fakeMessageStatus(message)
//        }
//    }
    
    public func sendMessage(_ message: ChattoMessageModelProtocol) {
        self.messageStatus(message)
    }
    
    private func messageStatus(_ message: ChattoMessageModelProtocol) {
        switch message.status {
        case .success:
            break
        case .failed:
            self.updateMessage(message, status: .sending)
            self.messageStatus(message)
        case .sending:
            switch arc4random_uniform(100) % 5 {
            case 0:
                if arc4random_uniform(100) % 2 == 0 {
                    self.updateMessage(message, status: .failed)
                } else {
                    self.updateMessage(message, status: .success)
                }
            default:
                let delaySeconds: Double = Double(arc4random_uniform(1200)) / 1000.0
                let delayTime = DispatchTime.now() + Double(Int64(delaySeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.messageStatus(message)
                }
            }
        }
    }
    
    private func updateMessage(_ message: ChattoMessageModelProtocol, status: MessageStatus) {
        if message.status != status {
            message.status = status
            self.notifyMessageChanged(message)
        }
    }
    
    private func notifyMessageChanged(_ message: ChattoMessageModelProtocol) {
        self.onMessageChanged?(message)
    }
}
