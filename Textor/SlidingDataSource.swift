//
//  SlidingDataSource.swift
//  Textor
//
//  Created by Eugene Golovanov on 5/13/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions

final class SlidingDataSource {
    
    static let PAGE_SIZE:Int = 30

    var messages = [ChatItemProtocol]()
    var chatroom:Chatroom
    
    init(chatroom:Chatroom) {
        self.chatroom = chatroom
        self.messages = self.firstPageConvertRealmToChattoMessages(chatroom: chatroom)
    }
    
    /**
     Function loads first page on init
     */
    private func firstPageConvertRealmToChattoMessages(chatroom:Chatroom) -> [MessageModelProtocol] {
        var result = [EGMessageModelProtocol]()
        //From REALM
        let chatroomPredicate = NSPredicate(format: "chatroomId = %@", chatroom.id)
        let realmMessagesArray = chatroom.getRealm().objects(Message.self).filter(chatroomPredicate).sorted(byProperty: "timestamp",ascending: false)
        //Convert
        for (index, realmMessage) in realmMessagesArray.enumerated() {
            if index == SlidingDataSource.PAGE_SIZE { break }
            let chattoMessage = ChattorHelpers.convertRealmToChattoMessage(realmMessage: realmMessage, allowUnseenSeparator: true)
            result.append(chattoMessage as! EGMessageModelProtocol)
        }
        return result.reversed()
    }
    
    /**
     Function gets more next page messages if exist
     */
    func getMorePageMessagesFromRealm(chatroom:Chatroom, firstRealmMessage:Message) {
        var result = [EGMessageModelProtocol]()
        //From REALM
        let realmMessagesArray = chatroom.getRealm().objects(Message.self).filter("chatroomId = %@ AND timestamp < %@", chatroom.id, firstRealmMessage.timestamp).sorted(byProperty: "timestamp",ascending: false)
        
        if realmMessagesArray.count > 0 {
            //Convert
            for (index, realmMessage) in realmMessagesArray.enumerated() {
                if index == SlidingDataSource.PAGE_SIZE { break }
                let chattoMessage = ChattorHelpers.convertRealmToChattoMessage(realmMessage: realmMessage, allowUnseenSeparator: true)
                result.append(chattoMessage as! EGMessageModelProtocol)
            }
            var olderMessages:[EGMessageModelProtocol] = result.reversed()
            
            for m in self.messages {
                olderMessages.append(m as! EGMessageModelProtocol)
            }
            self.messages = olderMessages
            print("Sliding Messages Count: \(self.messages.count)")
        }
        }
    
    /**
     Function checks in realm if we have previous messages
     */
    func checkForMoreInRealm(chatroom:Chatroom, firstRealmMessage:Message) -> Bool {
        //From REALM
        let realmMessagesArray = chatroom.getRealm().objects(Message.self).filter("chatroomId = %@ AND timestamp < %@", chatroom.id, firstRealmMessage.timestamp).sorted(byProperty: "timestamp",ascending: false)
        if realmMessagesArray.count > 0 {
            return true
        } else {
            if chatroom.firstMessageUID == nil {
                //Check if we did not scrolled to top
                self.getMorePages(chatroom: chatroom, firstRealmMessage: firstRealmMessage)
            }
            return false
        }
    }
    
    /**
     Function checks if we have more messages on server
     */
    var isLoading = false
    private func getMorePages(chatroom:Chatroom, firstRealmMessage:Message) {
        if let user = DataManager.model.currentUser {
            if self.isLoading == false {
                self.isLoading = true
                SocketIOManager.sharedInstance.fetchChatroomPageFromTimestamp(chatroom, timestamp:firstRealmMessage.timestamp, user:user, pageSize:SlidingDataSource.PAGE_SIZE, messageCallback: { (chatroomMessages) in
                    if chatroomMessages.count == 0 {
                        user.write {
                            chatroom.firstMessageUID = firstRealmMessage.creationId
                        }
                    }
                    self.isLoading = false
                })
            }
        }

    }

}
